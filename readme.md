## Project Structure
Here is a breakdown of the core directories and their purposes:

### `bigquery/`
Contains the shell scripts, JSON definitions and SQL required to provision the infrastructure in BigQuery.
* **`medallion.sh`**: Provisions the `mk_bronze`, `mk_silver`, and `mk_gold` BigQuery datasets.
* **`pubsubsubscription.sh`**: Configures Pub/Sub subscriptions to stream US and BR sales topics directly into the Bronze BigQuery tables. It also configures Dead-Letter Topics (DLTs) for error handling.
* **`bronze.sh`**: Creates BigQuery external tables for products (CSV) and stores (JSON) that read directly from GCS buckets and standard tables in BigQuery for US and BR sales (definition in `ddl/` folder).


### `dbt/`
Contains the data transformation logic, configuration, and testing managed by dbt.
* **`models/silver/`**: Staging models responsible for flattening nested structures, standardizing naming conventions, masking sensitive data, and casting data types.
* **`models/gold/`**: The final business-ready layer containing dimension tables (e.g., `dim_customers`, `dim_stores`, `dim_products`) and aggregated fact tables (e.g. `fact_sales`).
* **`profiles.yml` & `dbt_project.yml`**: Configuration files linking the local dbt project to the BigQuery environment using a service account.

### `cloude_run_service/`
This directory contains a custom FastAPI Python application containerized via Docker. It acts as the bridge between an external Kafka cluster and our internal GCP Pub/Sub topics. Because Cloud Run is an HTTP-driven serverless platform, this service is triggered on a schedule to consume batches of data.
* **`main.py`**: The core FastAPI application. It exposes a POST endpoint (`/consume/{country}`) that connects to Kafka, pulls a batch of messages, validates the JSON payload, and publishes it to the appropriate Pub/Sub topic. Invalid messages are intelligently routed to a Dead-Letter Topic (DLT) with the error attached.
* **`schema.py`**: Contains strict Pydantic models used by the FastAPI app to enforce data quality and validate the schema of incoming US and BR sales payloads.
* **`config.py`**: Manages environment variables.
* **`script.sh`**: The deployment script. It provisions the Pub/Sub topics, creates the Service Accounts, builds the Docker image in Artifact Registry, deploys the Cloud Run service, and sets up **Cloud Scheduler** to trigger the consumption endpoints every 5 minutes.


### `auto_dq/`
This directory contains the configuration and automation scripts for Google Cloud Dataplex AutoDQ. It provides automated data quality monitoring for the serving layer (Gold).
* **`create_scans.sh`**: A shell script that automates the provisioning of Dataplex Data Quality scans.
* **`rules/`**: A sub-directory containing table-specific YAML definitions for data quality expectations.

### `terraform/`
This directory contains the IaC
