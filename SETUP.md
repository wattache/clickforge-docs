# Setup Guide

## ClickForge Configuration

Create a ClickHouse connection configuration at `~/.clickforge/clickhouse.yaml`:

```yaml
my-clickhouse:
  host: your-clickhouse-host.com
  port: 8443
  user: your_user
  password: your_password 
  database: clickforge
  cluster: default
```

For production environments, you can use GCP Secret Manager to store passwords securely:

```yaml
production:
  host: prod.clickhouse.example.com
  port: 8443
  user: prod_user
  password:
    secret_manager: gcp
    project_id: my-project
    secret_name: clickhouse-password
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