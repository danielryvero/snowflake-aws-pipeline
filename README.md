# ☁️ Snowflake-AWS Pipeline

This project demonstrates how to build a pipeline between an AWS S3 bucket and a Snowflake table using SQS and Storage Integration. With this setup, data uploaded to S3 will be automatically ingested into Snowflake using **Snowpipe**.

---

## 🚀 Prerequisites

- An **AWS account**
- A **Snowflake account**
- Basic knowledge of SQL and AWS IAM roles

---

## 🏗️ Setup Instructions

### 1. Create Your S3 Bucket

- Go to the AWS Console.
- Create a new **S3 bucket** in the **same region** as your Snowflake account.
- Inside the bucket, create the following folders:  
/csv  
/snowpipe


### 2. Create IAM Role for Snowflake

- Go to **IAM > Roles**.
- Create a new role called `snowflake-access-role`.
- Attach the **AmazonS3FullAccess** policy to it.
- Take note of the **ARN** of the role — you'll need it for Snowflake.

---

## 🧩 Integrate Snowflake and S3

Follow the instructions in [`S3_integration.sql`](./S3_integration.sql) to:

- Create a **storage integration** in Snowflake.
- Grant access to your S3 bucket using the ARN of the role created above.

---

## 📥 Upload Data and Automate Ingestion

1. Use the sample files provided in [`txt_files`](./txt_files) to upload into your S3 bucket.
2. Follow the instructions in [`S3_data_&_snowpipe.sql`](./S3_data_&_snowpipe.sql) to:

 - Define a Snowflake **file format**
 - Create a **Snowpipe** to auto-load data from S3
 - Monitor the data as it flows into your Snowflake table

---

## 📂 Repo Structure

```bash
├── S3_integration.sql           # Setup Snowflake <-> S3 integration
├── S3_data_&_snowpipe.sql       # Define file formats and snowpipe
├── txt_files/                   # Sample data files to test the pipeline
