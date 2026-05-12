--This is the Snowflake Worksheet used to create the integration with S3
--in your S3 bucket, create the folders as mentioned below
--then copy the ARN for the role created to allow snowflake access the bucket (snowflake-access-role)
create or replace storage integration S3_connection
    type = external_stage
    storage_provider = s3
    storage_aws_role_arn = 'arn:aws:iam::026090558923:role/snowflake-access-role'
    enabled = true
    storage_allowed_locations = ( 's3://snowflaketransferuswest/csv/', 's3://snowflaketransferuswest/json/', 's3://snowflaketransferuswest/snowpipe/' )
    -- storage_blocked_locations = ( 's3://<location1>', 's3://<location2>' )
    -- comment = '<comment>'
    ;

--from the description of your integration, 
--grab the STORAGE_AWS_EXTERNAL_ID and paste it in the access policy for the bucket
desc integration S3_connection;

--another way to configure the SNS and SQS ingration is by creating a PIPE pointing
--to the stage with the integration to the S3 bucket and do:
show pipes;

--then copy the ARN in the notification_channel column and paste it
--in the "SQS queue ARN" option of the S3 bucket properties
