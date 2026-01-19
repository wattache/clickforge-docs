Base query: 

```clickhouse
SELECT
    product_title, star_rating
FROM
    clickforge.amazon_reviews
WHERE
    review_date = '2015-02-23'
    AND product_category = 'Books'
    AND total_votes > 10
```

New DDL where `INDEX idx_total_votes total_votes TYPE minmax GRANULARITY 4` is added:

```clickhouse
CREATE TABLE clickforge.amazon_reviews_indexed
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
    
    INDEX idx_total_votes total_votes TYPE minmax GRANULARITY 1,
    
    PROJECTION helpful_votes
    (
        SELECT *
        ORDER BY helpful_votes
    )
)
ENGINE = MergeTree
ORDER BY (review_date, product_category)
```