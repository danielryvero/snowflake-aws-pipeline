--This is the Snowflake Worksheet used to create the database and trigger the data to fall into its table
--CREATE DATABASE
create database manage_db;

--CREATE FILE FORMAT
CREATE OR REPLACE file format MANAGE_DB.PUBLIC.CSV_FILEFORMAT
    type = csv
    field_delimiter = ','
    skip_header = 1
    null_if = ('NULL','null')
    empty_field_as_null = TRUE    
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'  
    ;

--CREATE STAGE TO QUERY S3 DATA
create or replace stage s3_external
url = 's3://snowflaketransferuswest/csv/'
storage_integration = S3_connection
;

--QUERY DATA WITHOUT LOADING IT, JUST TO SEE IF IT'S THERE
select $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12
from @MANAGE_DB.PUBLIC.S3_EXTERNAL
(file_format=>MANAGE_DB.PUBLIC.CSV_FILEFORMAT);

--CREATE TABLE TO STORE THE DATA
create or replace table manage_db.public.movie_titles (
show_id string,
type string,
title string,
director string,
cast string,
country string,
date_added string,
release_year number,
rating string,
duration string,
listed_in string,
description string
);

--COPY DATA INTO THE TABLE
copy into MANAGE_DB.PUBLIC.MOVIE_TITLES
from @MANAGE_DB.PUBLIC.S3_EXTERNAL
FILE_FORMAT = MANAGE_DB.PUBLIC.csv_fileformat;

--CHECK DATA WAS COPIED
SELECT *
FROM MANAGE_DB.PUBLIC.MOVIE_TITLES;


--------SNOWPIPING----------
--CREATE EMPLOYEES TABLE TO STORE THE DATA IN IT
create table employees (
id int,
first_name string,
last_name string,
email string,
location string,
department string
);

--CREATE STAGE FOR SNOWPIPE (WITH ACCOUNTADMIN IF YOU CREATED THE INTEGRATION WITH THAT ROLE)
create or replace stage MANAGE_DB.PUBLIC.S3_SNOWPIPE
url='s3://snowflaketransferuswest/snowpipe/'
storage_integration = S3_connection
;

--drop the file called "employee_data_1.csv" in your S3 bucket
--check data in stages
list @MANAGE_DB.PUBLIC.S3_SNOWPIPE;

list @MANAGE_DB.PUBLIC.S3_EXTERNAL;

----CREATE SCHEMA FOR SNOWPIPE
create or replace schema manage_db.pipes;

--DEFINE PIPE
create or replace pipe manage_db.pipes.employee_pipe
auto_ingest=TRUE
AS
COPY INTO MANAGE_DB.PUBLIC.EMPLOYEES
FROM @MANAGE_DB.PUBLIC.S3_SNOWPIPE
FILE_FORMAT = MANAGE_DB.PUBLIC.csv_fileformat
;

--CHECK PIPE
DESC PIPE employee_pipe;

--drop the file called "employee_data_2.csv" in your S3 bucket
--CHECK DATA IN TABLE
TRUNCATE TABLE MANAGE_DB.PUBLIC.EMPLOYEES; --TRUNCATE TO ITERATE IF SOMETHING WENT WRONG


--CHECK AMOUNT OF ROWS AND CONTENT OF THE TABLE
SELECT *
FROM MANAGE_DB.PUBLIC.EMPLOYEES;

SELECT count(*)
FROM MANAGE_DB.PUBLIC.EMPLOYEES;

--now drop the files called "employee_data_3.csv" and "employee_data_3.csv" in your S3 bucket
--CHECKING FILES AND STATUS OF PIPELINE
alter pipe employee_pipe refresh;

select system$pipe_status('employee_pipe');

--COMMAND TO CHECK ERRORS ON THE PIPES:
SELECT *
FROM TABLE(VALIDATE_PIPE_LOAD(
    PIPE_NAME => 'MANAGE_DB.PIPES.EMPLOYEE_PIPE',
    START_TIME => DATEADD(HOUR, -2, CURRENT_TIMESTAMP())
));

--QUERY THE COPY HISTORY TABLE
SELECT * 
FROM TABLE (INFORMATION_SCHEMA.COPY_HISTORY(
table_name => 'MANAGE_DB.PUBLIC.EMPLOYEES',
START_TIME => DATEADD(HOUR, -2, CURRENT_TIMESTAMP())
));


--MANAGE PIPES 
SHOW PIPES;

DESC PIPE MANAGE_DB.PIPES.EMPLOYEE_PIPE;

SHOW PIPES IN DATABASE MANAGE_DB;

SHOW PIPES LIKE '%employee%';

--PAUSE THE PIPE
ALTER PIPE MANAGE_DB.PIPES.EMPLOYEE_PIPE SET PIPE_EXECUTION_PAUSED = TRUE;

--RESUME THE PIPE
ALTER PIPE MANAGE_DB.PIPES.EMPLOYEE_PIPE SET PIPE_EXECUTION_PAUSED = FALSE;
