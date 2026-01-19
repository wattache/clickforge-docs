# ClickForge Documentation

> ClickHouse Performance Testing & Monitoring Dashboard

ClickForge is a toolkit for benchmarking ClickHouse query performance and monitoring cluster health through an interactive Streamlit dashboard.

## Features

- **Load Testing**: Run parameterized queries at scale and measure throughput, latency, and resource usage
- **Query Time Analysis**: Visualize query performance over time from `system.query_log`
- **Query Plan Viewer**: Analyze index filtering efficiency and compare schema strategies
- **Cluster Monitoring**: Track table sizes, fragmentation, compression, and growth trends

## Quick Start

```bash
# Install
pip install clickforge

# Run a load test
clickforge --experiment examples/load-test/amazon_reviews_qps_test.yaml

# Launch the dashboard
clickforge-dashboard
```

Then open http://localhost:8501 in your browser.

## Dashboard Pages

### [Cluster Monitor](cluster-monitor/README.md)

Monitor table storage, fragmentation, and compression efficiency across your ClickHouse cluster.

- Track total storage usage and table counts
- Identify largest and most fragmented tables
- Analyze compression ratios and storage efficiency
- View historical growth trends

### [Query Time Analysis](query-time-plot/README.md)

Visualize query performance metrics over time from `system.query_log`.

- Track query duration and rows read trends
- Filter by custom conditions (site, user, etc.)
- Identify slow query patterns with heatmaps
- Add deployment markers to correlate performance changes

### [Query Plan Viewer](query-plan-viewer/README.md)

Analyze how ClickHouse index filters progressively reduce data scanned.

- Visualize index filtering stages (MinMax, Partition, PrimaryKey, Skip)
- See granules and parts reduction at each stage
- Compare different table schemas and index strategies
- Identify opportunities for adding or improving indexes

### [Load Test Results](load-test/README.md)

Analyze throughput, latency, and resource usage from load tests.

- Compare multiple test configurations
- View P95/P99 latency metrics
- Track memory usage patterns
- Identify performance bottlenecks

## Configuration

ClickForge reads ClickHouse connection settings from:
- `.clickforge/clickhouse.yaml` (project-level)
- `~/.clickforge/clickhouse.yaml` (user-level)

See the **[Setup Guide](SETUP.md)** for detailed configuration instructions and example dataset setup.

## Coming Soon

Full source code and installation instructions will be available soon. Stay tuned!