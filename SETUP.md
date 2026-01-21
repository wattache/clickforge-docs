# Setup Guide

## ClickForge Configuration

ClickForge supports multiple configuration methods, checked in this order:

1. **Environment variables** (recommended for deployment)
2. `.clickforge/clickhouse.yaml` (project-level)
3. `~/.clickforge/clickhouse.yaml` (user-level)

### Option 1: Environment Variables (Recommended for Deployment)

Define ClickHouse services using the pattern `CLICKHOUSE_<SERVICE>_<FIELD>`:

```bash
# Production service
export CLICKHOUSE_PRODUCTION_HOST=prod.clickhouse.example.com
export CLICKHOUSE_PRODUCTION_PORT=8443
export CLICKHOUSE_PRODUCTION_USER=default
export CLICKHOUSE_PRODUCTION_PASSWORD=secret
export CLICKHOUSE_PRODUCTION_DATABASE=analytics
export CLICKHOUSE_PRODUCTION_CLUSTER=default  # optional

# Staging service
export CLICKHOUSE_STAGING_HOST=staging.clickhouse.example.com
export CLICKHOUSE_STAGING_PORT=8443
export CLICKHOUSE_STAGING_USER=default
export CLICKHOUSE_STAGING_PASSWORD=secret
export CLICKHOUSE_STAGING_DATABASE=analytics
```

**Required fields:** `HOST`, `USER`, `PASSWORD`, `DATABASE`

**Optional fields:** `PORT` (default: 8443), `CLUSTER` (default: "default")

### Option 2: YAML Configuration File

Create a configuration file at `~/.clickforge/clickhouse.yaml` or `.clickforge/clickhouse.yaml`:

```yaml
my-clickhouse:
  host: your-clickhouse-host.com
  port: 8443
  user: your_user
  password: your_password
  database: clickforge
  cluster: default
```

### Password Configuration

The `password` field supports three formats:

**1. Literal string:**
```yaml
production:
  host: prod.example.com
  password: "my-secret-password"
```

**2. Environment variable reference** (for Kubernetes mounted secrets):
```yaml
production:
  host: prod.example.com
  password:
    env: MY_CLICKHOUSE_PASSWORD
```

**3. GCP Secret Manager:**
```yaml
production:
  host: prod.clickhouse.example.com
  port: 8443
  user: prod_user
  password:
    secret_manager: gcp
    project_id: my-project
    secret_name: clickhouse-password
    version: latest  # optional
  database: clickforge
```

## Amazon Reviews Dataset

Create the `amazon_reviews` table in ClickHouse:

```sql
CREATE TABLE clickforge.amazon_reviews
(
    `review_date` Date,
    `marketplace` LowCardinality(String),
    `customer_id` UInt64,
    `review_id` String,
    `product_id` String,
    `product_parent` UInt64,
    `product_title` String,
    `product_category` LowCardinality(String),
    `star_rating` UInt8,
    `helpful_votes` UInt32,
    `total_votes` UInt32,
    `vine` Bool,
    `verified_purchase` Bool,
    `review_headline` String,
    `review_body` String,
    PROJECTION helpful_votes
    (
        SELECT *
        ORDER BY helpful_votes
    )
)
ENGINE = MergeTree
ORDER BY (review_date, product_category)
```

Load 10 million rows from the public dataset:

```sql
INSERT INTO clickforge.amazon_reviews SELECT *
FROM s3('https://datasets-documentation.s3.eu-west-3.amazonaws.com/amazon_reviews/amazon_reviews_*.snappy.parquet')
LIMIT 10000000
```

Verify the data was loaded successfully:

```sql
SELECT
    disk_name,
    formatReadableSize(sum(data_compressed_bytes) AS size) AS compressed,
    formatReadableSize(sum(data_uncompressed_bytes) AS usize) AS uncompressed,
    round(usize / size, 2) AS compr_rate,
    sum(rows) AS rows,
    count() AS part_count
FROM system.parts
WHERE (active = 1) AND (table = 'amazon_reviews')
GROUP BY disk_name
ORDER BY size DESC
```