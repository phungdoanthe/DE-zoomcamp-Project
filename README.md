# London Bicycle Counts — End-to-End Data Engineering Pipeline

A portfolio-grade data engineering pipeline that ingests, transforms, and visualises London bicycle count data from Transport for London (TfL).

---

## Architecture

```
TfL S3 Bucket (CSV)
      ↓
download.py          — downloads raw CSVs by year range
      ↓
GCS (raw/)           — raw CSV storage
      ↓
Dataproc + PySpark   — repartitions and converts to Parquet
      ↓
GCS (parquet/)       — partitioned Parquet files
      ↓
BigQuery             — external table over Parquet files
      ↓
dbt                  — staging → intermediate → marts
      ↓
Streamlit            — visualisation layer
```

**Stack:** Python · PySpark · Terraform · GCP (GCS, BigQuery, Dataproc) · dbt (dbt-bigquery) · Streamlit · GitHub Actions · uv

---

## Project Structure

```
de-zoomcamp-project/
├── .env                          ← local env vars (never commit)
├── .gitignore
├── .gitattributes                ← enforces LF line endings
├── pyproject.toml                ← pipeline dependencies (uv)
├── run_local_setup.sh            ← runs the full pipeline locally
├── run_dbt.sh                    ← runs dbt (standalone or called from setup)
│
├── ingestion/
│   ├── download.py               ← downloads CSVs from TfL S3
│   └── upload_to_gcs.sh          ← uploads data/ folder to GCS
│
├── terraform/
│   ├── main.tf                   ← GCS bucket, BigQuery dataset, Dataproc cluster
│   ├── variables.tf
│   └── run_infrastructure.sh
│
├── cloud/
│   |── dataproc/
│   |    ├── repartition.py        ← PySpark job: CSV → Parquet
│   |    └── run_repartitioning.sh
│   ├── bigquery/
|        ├── create_external_tables.sql ← Create external table in bigquery dataset for source.yml in dbt
|
├── dbt/
|   ├── refine_seed_columns.py  ← refine columns name in seed to match the requirement of google bigquery
│   └── dbt_bigquery_transformation/
│       ├── dbt_project.yml
│       ├── profiles.yml  ← move this to your home/user/.dbt/profiles.yml
│       ├── packages.yml
│       ├── seeds/
│       │   ├── monitoring_location.csv
│       │   └── seeds_properties.yml
│       ├── models/
│       │   ├── staging/
│       │   │   ├── source.yml
│       │   │   ├── stg_london_bike_counts.sql
│       │   │   └── schema.yml
│       │   ├── intermediate/
│       │   │   ├── int_bike_counts_enriched.sql
|       |   |   └── schema.yml
│       │   └── marts/
│       │       ├── rpt_counts_by_weather_year.sql
│       │       ├── rpt_renting_percentage_by_mode.sql
│       │       ├── rpt_peak_time_by_area.sql
|       |       └── schema.yml
│       └── tests/
│           ├── assert_rpt_mode_percentages_sum_to_100.sql
│           ├── assert_no_negative_bike_counts.sql
│           ├── assert_peak_times_one_row_per_area.sql
│           ├── assert_int_no_orphaned_sites.sql
│           └── assert_enriched_monitor_id_unique.sql
│
└── streamlit/
    └── app.py
```

---

## Prerequisites

- Python 3.11+
- [uv](https://docs.astral.sh/uv/) — Python package manager
- [Terraform](https://developer.hashicorp.com/terraform) >= 1.7
- [gcloud CLI](https://cloud.google.com/sdk/docs/install)
- A GCP project with billing enabled
- A GCP service account key JSON file

---

## Environment Variables

Create a `.env` file in the project root:

```dotenv
export GOOGLE_APPLICATION_CREDENTIALS="/mnt/d/path/to/your/key.json"
export PROJECT_ID=your-gcp-project-id
export REGION=asia-southeast1
export GCS_BUCKET_NAME=your-bucket-name
export CLUSTER_NAME=your-dataproc-cluster
export BIGQUERY_DATASET_NAME=london_bicycle

START_YEAR=2019 ← the START_YEAR and END_YEAR will be created or overwriten when using download.sh --years in the run_local_setup.sh
END_YEAR=2022

```

> **Important:** Always use absolute WSL paths (starting with `/mnt/`) for `GOOGLE_APPLICATION_CREDENTIALS`. Relative paths break depending on which directory the script is called from.

> **Important:** Make sure `.env` uses **LF line endings**, not CRLF. If you edited it on Windows run `sed -i 's/\r//' .env` before running any scripts.

---

## Running the Pipeline

### Full pipeline (recommended)

Runs everything end-to-end: download → infrastructure → upload → repartition → dbt:

```bash
bash run_local_setup.sh
```

### dbt only

`run_dbt.sh` works both standalone and when called from `run_local_setup.sh`. It loads `.env` itself if not already sourced:

```bash
# Full dbt pipeline — deps → seed → run → test
bash run_dbt.sh

# Individual commands
bash run_dbt.sh deps
bash run_dbt.sh seed
bash run_dbt.sh run
bash run_dbt.sh test
bash run_dbt.sh debug
```

> **How env vars work between scripts:** When `run_local_setup.sh` sources `.env` with `set -o allexport`, all vars are exported and inherited by any child process it spawns (including `run_dbt.sh`). When `run_dbt.sh` is run standalone, it loads `.env` itself. Either way works with no changes needed.

---

## dbt Model Overview

| Model | Layer | Materialisation | Description |
|---|---|---|---|
| `stg_london_bike_counts` | staging | view | Cleaned raw bike count data |
| `int_bike_counts_enriched` | intermediate | table | Joined counts + site info, deduplicated |
| `rpt_counts_by_weather_year` | marts | table | Total counts by weather and year |
| `rpt_renting_percentage_by_mode` | marts | table | Mode share as percentage |
| `rpt_peak_time_by_area` | marts | table | Peak cycling time per functional area |

BigQuery output datasets (controlled by `+schema` in `dbt_project.yml`):

```
your-gcp-project
├── london_bicycle_staging
├── london_bicycle_intermediate
└── london_bicycle_marts        ← what Streamlit queries
```

---

## Known Issues & Fixes

### General — WSL

**CRLF line endings (`\r: command not found`)**
Windows saves files with CRLF which breaks bash in WSL. The setup script fixes `.sh` files automatically but not `.env`:
```bash
sed -i 's/\r//' .env
```
Prevent future issues with `.gitattributes`:
```
*.sh    text eol=lf
*.env   text eol=lf
*.py    text eol=lf
```

**`uv: command not found` after install**
uv was just installed but PATH has not updated yet. Add to `~/.bashrc`:
```bash
echo 'source $HOME/.local/bin/env' >> ~/.bashrc
source ~/.bashrc
```

**DNS failure (`Temporary failure in name resolution`)**
WSL DNS resets when switching networks or restarting. This causes intermittent download failures. Fix permanently:
```bash
sudo bash -c 'echo "nameserver 8.8.8.8\nnameserver 8.8.4.4" > /etc/resolv.conf'
sudo bash -c 'echo "[network]\ngenerateResolvConf = false" > /etc/wsl.conf'
```
Then from PowerShell:
```powershell
wsl --shutdown
```

**SSL certificate errors (`certificate verify failed`)**
Usually caused by a corporate VPN or proxy doing SSL inspection. Try disconnecting from VPN first. If the issue persists:
```bash
sudo apt-get install --reinstall ca-certificates
sudo update-ca-certificates
```

**`GOOGLE_APPLICATION_CREDENTIALS` not found — relative path**
Relative paths break depending on the working directory. Get the absolute path:
```bash
realpath key/your-key.json   # paste this output into .env
```

**`User not authorized to act as service account ... -compute@developer.gserviceaccount.com`**
Your service account needs permission to impersonate the Compute Engine default SA:
```bash
gcloud iam service-accounts add-iam-policy-binding \
  <project-number>-compute@developer.gserviceaccount.com \
  --member="serviceAccount:your-sa@your-project.iam.gserviceaccount.com" \
  --role="roles/iam.serviceAccountUser"
```

**`certificate is not valid ... registry.terraform.io`**
WSL certificate store is outdated or VPN is intercepting. Try disconnecting VPN first, or:
```bash
sudo apt-get install --reinstall ca-certificates
sudo update-ca-certificates
# Use cached providers without hitting registry
terraform init -upgrade=false
```
---

### `dbt/` — Transformations

**`Permission denied: 'integration_tests'` during `dbt deps`**
WSL struggles with rename/delete on Windows-mounted drives (`/mnt/d/`). Move `dbt_packages` to the WSL filesystem:
```yaml
# dbt_project.yml
packages-install-path: /home/your-username/.dbt/packages/london_bicycle
```


Trigger manually or on a schedule:
```yaml
on:
  workflow_dispatch:           # manual trigger button in GitHub UI
  schedule:
    - cron: '0 6 * * *'       # daily at 6am UTC
```

---

## Streamlit Dashboard

The dashboard queries BigQuery marts directly and always reflects the latest dbt run.

**Local development:**
```bash
cd streamlit
streamlit run app.py
```

## Data Source

London bicycle count data from [Transport for London's Active Travel Counts Programme](https://cycling.data.tfl.gov.uk/), available as CSV files partitioned by year and quarter.