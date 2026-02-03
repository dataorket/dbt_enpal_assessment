# Sales Funnel Analysis - Solution Documentation

## Solution Overview

This project implements a complete **3-layer dbt pipeline** for Pipedrive CRM sales funnel analysis with dual environment support (DEV and PROD).

### Architecture

```
Source Data (public schema)
    ↓
Staging Layer (5 views) → Data cleaning & standardization
    ↓
Intermediate Layer (2 tables) → Business logic transformations
    ↓
Reporting Layer (1 table) → Final sales funnel report
```

### Models Summary

**Total: 8 models**

- **Staging** (5 view models):
  - `stg_activity` - Cleaned activity data
  - `stg_activity_types` - Activity type lookup
  - `stg_deal_changes` - Deal stage change tracking
  - `stg_stages` - Sales stage definitions
  - `stg_users` - User information

- **Intermediate** (2 table models):
  - `int_completed_activities` - Filtered completed activities with types
  - `int_deal_stage_history` - First stage entry per deal (window functions)

- **Reporting** (1 table model):
  - `rep_sales_funnel_monthly` - 11-step sales funnel report (128 rows)

### Final Report Structure

**Table:** `rep_sales_funnel_monthly`

**Columns:**
- `month` - Monthly aggregation period
- `kpi_name` - Descriptive funnel step name
- `funnel_step` - Numeric step identifier (1-9, including 2.1 and 3.1)
- `deals_count` - Number of deals at each step

**Funnel Steps (11 total):**
1. Step 1: Lead Generation
2. Step 2: Qualified Lead
3. **Step 2.1: Sales Call 1** (activity-based)
4. Step 3: Needs Assessment
5. **Step 3.1: Sales Call 2** (activity-based)
6. Step 4: Proposal/Quote Preparation
7. Step 5: Negotiation
8. Step 6: Closing
9. Step 7: Implementation/Onboarding
10. Step 8: Follow-up/Customer Success
11. Step 9: Renewal/Expansion

---

## Environment Configuration

This project supports **two environments** using schema separation:

### DEV Environment
```bash
# Development and testing
dbt run --target dev
```
- **Schema:** `public_pipedrive_analytics`
- **Purpose:** Development, testing, experimentation
- **Access:** Data team (read/write)
- **Data Refresh:** On-demand (manual)

### PROD Environment
```bash
# Production deployment
dbt run --target prod
```
- **Schema:** `prod_pipedrive_analytics`
- **Purpose:** Production analytics
- **Access:** Business users (read-only)
- **Data Refresh:** Scheduled (in production would be automated)

### Environment Switching

The same SQL code runs in different schemas based on the `--target` flag. Configuration is managed in `profiles.yml`:

```yaml
enpal_assessment_project:
  outputs:
    dev:
      schema: public_pipedrive_analytics
    prod:
      schema: prod_pipedrive_analytics
  target: dev  # Default
```

---

## Running the Project

### Prerequisites
- Docker Desktop installed and running
- Python 3.11+ with virtual environment
- dbt-core and dbt-postgres installed

### Step-by-Step Commands

#### 1. Start Database
```bash
# From project root
docker compose up -d

# Verify database is running
psql -h 127.0.0.1 -U admin -d postgres -c "\dn"
```

#### 2. Activate Virtual Environment
```bash
# Navigate to project
cd ~/Desktop/dbt_enpal_assessment

# Activate venv (if using one)
source venv/bin/activate  # macOS/Linux
```

#### 3. Test Connection
```bash
# Test DEV connection
dbt debug --target dev

# Test PROD connection
dbt debug --target prod
```

#### 4. Run Models

**Run all models in DEV:**
```bash
dbt run --target dev
```

**Run all models in PROD:**
```bash
dbt run --target prod
```

**Run specific layers:**
```bash
# Staging only
dbt run --select staging.* --target dev

# Intermediate only
dbt run --select intermediate.* --target dev

# Reporting only
dbt run --select rep_sales_funnel_monthly --target dev
```

#### 5. Run Data Quality Tests

**Test DEV:**
```bash
dbt test --target dev
```

**Test PROD:**
```bash
dbt test --target prod
```

**Expected output:** `PASS=5` (5 data quality tests)

Tests validate:
- ✅ No NULL values in critical columns
- ✅ Funnel steps are valid (1-9, including 2.1 and 3.1)
- ✅ Data integrity across environments

#### 6. Verify Output

**Check model count:**
```bash
psql -h 127.0.0.1 -U admin -d postgres -c "
SELECT 
    schemaname, 
    count(*) as model_count 
FROM pg_tables 
WHERE schemaname IN ('public_pipedrive_analytics', 'prod_pipedrive_analytics') 
GROUP BY schemaname;
"
```

**View final report:**
```bash
# DEV
psql -h 127.0.0.1 -U admin -d postgres -c "
SELECT * FROM public_pipedrive_analytics.rep_sales_funnel_monthly 
ORDER BY month, funnel_step 
LIMIT 20;
"

# PROD
psql -h 127.0.0.1 -U admin -d postgres -c "
SELECT * FROM prod_pipedrive_analytics.rep_sales_funnel_monthly 
ORDER BY month, funnel_step 
LIMIT 20;
"
```

**Compare DEV and PROD (side-by-side):**
```bash
psql -h 127.0.0.1 -U admin -d postgres -c "
SELECT 'DEV' as env, * 
FROM public_pipedrive_analytics.rep_sales_funnel_monthly 
WHERE month = '2024-02-01' 
UNION ALL 
SELECT 'PROD' as env, * 
FROM prod_pipedrive_analytics.rep_sales_funnel_monthly 
WHERE month = '2024-02-01' 
ORDER BY env, funnel_step;
"
```

**Expected output:**
```
 env  |   month    |              kpi_name              | funnel_step | deals_count
------+------------+------------------------------------+-------------+-------------
 DEV  | 2024-02-01 | Step 1: Lead Generation            |           1 |         194
 DEV  | 2024-02-01 | Step 2: Qualified Lead             |           2 |          74
 DEV  | 2024-02-01 | Step 2.1: Sales Call 1             |         2.1 |          64
 DEV  | 2024-02-01 | Step 3: Needs Assessment           |           3 |          27
 DEV  | 2024-02-01 | Step 3.1: Sales Call 2             |         3.1 |          59
 DEV  | 2024-02-01 | Step 4: Proposal/Quote Preparation |           4 |          17
 DEV  | 2024-02-01 | Step 5: Negotiation                |           5 |          10
 DEV  | 2024-02-01 | Step 6: Closing                    |           6 |           8
 DEV  | 2024-02-01 | Step 7: Implementation/Onboarding  |           7 |           1
 DEV  | 2024-02-01 | Step 9: Renewal/Expansion          |           9 |           2
 PROD | 2024-02-01 | Step 1: Lead Generation            |           1 |         194
 PROD | 2024-02-01 | Step 2: Qualified Lead             |           2 |          74
 PROD | 2024-02-01 | Step 2.1: Sales Call 1             |         2.1 |          64
 PROD | 2024-02-01 | Step 3: Needs Assessment           |           3 |          27
 PROD | 2024-02-01 | Step 3.1: Sales Call 2             |         3.1 |          59
 PROD | 2024-02-01 | Step 4: Proposal/Quote Preparation |           4 |          17
 PROD | 2024-02-01 | Step 5: Negotiation                |           5 |          10
 PROD | 2024-02-01 | Step 6: Closing                    |           6 |           8
 PROD | 2024-02-01 | Step 7: Implementation/Onboarding  |           7 |           1
 PROD | 2024-02-01 | Step 9: Renewal/Expansion          |           9 |           2
(20 rows)
```

**Verify row count (should be 128 in both):**
```bash
psql -h 127.0.0.1 -U admin -d postgres -c "
SELECT 'DEV' as env, COUNT(*) FROM public_pipedrive_analytics.rep_sales_funnel_monthly
UNION ALL
SELECT 'PROD' as env, COUNT(*) FROM prod_pipedrive_analytics.rep_sales_funnel_monthly;
"
```

---

## Data Quality Tests

This project includes 5 automated data quality tests for the final reporting model:

### Test Suite

| Test | Column | Purpose | Result |
|------|--------|---------|--------|
| `not_null` | month | Ensures every row has a month value | ✅ PASS |
| `not_null` | kpi_name | Ensures every step has a descriptive name | ✅ PASS |
| `not_null` | funnel_step | Ensures every row has a step identifier | ✅ PASS |
| `not_null` | deals_count | Ensures count is always present | ✅ PASS |
| `accepted_values` | funnel_step | Validates only allowed steps (1-9, 2.1, 3.1) | ✅ PASS |

### Running Tests

```bash
# Test DEV
dbt test --target dev

# Test PROD
dbt test --target prod

# Expected: PASS=5 WARN=0 ERROR=0
```

### What Tests Catch

**Example of data issues that would fail:**
```sql
-- This would FAIL not_null tests:
month       | kpi_name | funnel_step | deals_count
------------|----------|-------------|------------
2024-01-01  | NULL     | 1           | 50          ❌ kpi_name is NULL
NULL        | Closing  | 6           | 10          ❌ month is NULL

-- This would FAIL accepted_values test:
month       | kpi_name     | funnel_step | deals_count
------------|--------------|-------------|------------
2024-01-01  | Invalid Step | 99          | 5           ❌ 99 not allowed
```

---

## Development Workflow

### Typical Development Cycle

```bash
# 1. Make changes to models
code models/staging/stg_activity.sql

# 2. Test in DEV
dbt run --select stg_activity --target dev

# 3. Verify output
psql -h 127.0.0.1 -U admin -d postgres -c "SELECT * FROM public_pipedrive_analytics.stg_activity LIMIT 5;"

# 4. Run dependent models
dbt run --select stg_activity+ --target dev  # + runs downstream dependencies

# 5. Run full pipeline
dbt run --target dev

# 6. Run tests
dbt test --target dev

# 7. Deploy to PROD when ready
dbt run --target prod
dbt test --target prod

# 8. Commit changes
git add models/
git commit -m "feat: Update activity staging model"
git push origin main
```

### Best Practices Applied

✅ **Single Codebase** - Same SQL for DEV and PROD  
✅ **Source Definitions** - All source tables documented in `models/sources.yml`  
✅ **Layered Architecture** - Staging → Intermediate → Reporting  
✅ **Materialization Strategy** - Views for staging (fresh), tables for downstream (performance)  
✅ **CTEs** - Readable SQL with common table expressions  
✅ **Proper References** - `{{ source() }}` and `{{ ref() }}` for dependencies  
✅ **Data Quality Tests** - Automated validation of output data  
✅ **Git Best Practices** - Clear commits, .gitignore for artifacts

---

## CI/CD & Future Enhancements

### Current State
- Manual deployment via `dbt run --target prod`
- Local development and testing
- Schema-based environment separation
- Automated data quality tests

### Recommended Production Setup

#### 1. **GitHub Actions CI/CD Pipeline**

**CI Pipeline** (`.github/workflows/ci.yml`):
```yaml
name: dbt CI

on: [pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.11'
      
      - name: Install dbt
        run: |
          pip install dbt-core dbt-postgres
      
      - name: Run dbt
        env:
          DBT_DEV_PASSWORD: ${{ secrets.DBT_DEV_PASSWORD }}
        run: |
          dbt deps
          dbt run --target dev
          dbt test --target dev
      
      - name: Check compilation
        run: dbt compile
```

**CD Pipeline** (`.github/workflows/cd.yml`):
```yaml
name: dbt CD

on:
  push:
    branches: [main]

jobs:
  deploy-prod:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.11'
      
      - name: Install dbt
        run: pip install dbt-core dbt-postgres
      
      - name: Deploy to PROD
        env:
          DBT_PROD_PASSWORD: ${{ secrets.DBT_PROD_PASSWORD }}
        run: |
          dbt run --target prod
          dbt test --target prod
      
      - name: Notify team
        run: echo "PROD deployment complete"
```

#### 2. **Scheduled Refreshes**

**Daily PROD Refresh** (`.github/workflows/schedule.yml`):
```yaml
name: Daily PROD Refresh

on:
  schedule:
    - cron: '0 6 * * *'  # 6 AM UTC daily

jobs:
  refresh:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Install dbt
        run: pip install dbt-core dbt-postgres
      - name: Refresh PROD
        env:
          DBT_PROD_PASSWORD: ${{ secrets.DBT_PROD_PASSWORD }}
        run: |
          dbt run --target prod
          dbt test --target prod
```

#### 3. **Infrastructure as Code**

**Separate Infrastructure** (for real production):
```
Development:
├─ Database: AWS RDS (small instance, dev data)
├─ Cost: ~$50/month
└─ Access: VPN + team credentials

Production:
├─ Database: AWS RDS (large, multi-AZ, full data)
├─ Cost: ~$2000/month
├─ Backup: Automated daily snapshots
├─ Access: Service account only (via CI/CD)
└─ Monitoring: CloudWatch alerts
```

#### 4. **Advanced Data Quality Tests**

**Additional tests to consider:**
```yaml
# In models/reporting/schema.yml
models:
  - name: rep_sales_funnel_monthly
    tests:
      - dbt_utils.unique_combination_of_columns:
          combination_of_columns:
            - month
            - funnel_step
      - dbt_utils.recency:
          datepart: month
          field: month
          interval: 3
```

#### 5. **Documentation**

Generate dbt docs:
```bash
dbt docs generate
dbt docs serve
```

Opens interactive documentation at `http://localhost:8080` with:
- Lineage graphs
- Column-level documentation
- SQL source code
- Test results

#### 6. **Monitoring & Alerting**

**Slack Integration:**
- Notify on failed dbt runs
- Daily deployment summaries
- Data quality test failures

**dbt Cloud** (SaaS option):
- Managed scheduling
- Built-in monitoring
- Web-based IDE
- Automatic documentation hosting

---

## Project Structure

```
dbt_enpal_assessment/
├── models/
│   ├── sources.yml              # Source table definitions
│   ├── staging/
│   │   ├── stg_activity.sql
│   │   ├── stg_activity_types.sql
│   │   ├── stg_deal_changes.sql
│   │   ├── stg_stages.sql
│   │   └── stg_users.sql
│   ├── intermediate/
│   │   ├── int_completed_activities.sql
│   │   └── int_deal_stage_history.sql
│   └── reporting/
│       ├── rep_sales_funnel_monthly.sql
│       └── schema.yml           # Data quality tests
├── profiles.yml                 # Environment configurations
├── dbt_project.yml             # Project settings
├── docker-compose.yml          # PostgreSQL setup
├── init.sql                    # Database initialization
├── raw_data/                   # Source CSV files
│   ├── activity.csv
│   ├── activity_types.csv
│   ├── deal_changes.csv
│   ├── fields.csv
│   ├── stages.csv
│   ├── users.csv
│   └── load_data.sh           # Data loading script
├── .gitignore                  # Excludes target/, logs/, venv/
├── README.md                   # Setup instructions
└── SOLUTION.md                 # This file (solution documentation)
```

---

## Technical Specifications

### Data Pipeline
- **Source:** 6 tables, ~20K total rows
- **Processing:** dbt SQL transformations
- **Output:** 128 rows (monthly funnel aggregates)
- **Execution Time:** ~0.3 seconds (full pipeline)
- **Data Quality:** 5 automated tests (100% pass rate)

### Technology Stack
- **dbt-core:** 1.11.2
- **dbt-postgres:** 1.10.0
- **PostgreSQL:** 14+ (Docker)
- **Python:** 3.11

### Performance
- **Staging:** Views (no storage, instant refresh)
- **Intermediate:** Tables (materialized for performance)
- **Reporting:** Table (optimized for BI tool consumption)

---

## Troubleshooting

### Connection Issues

**Error: "role admin does not exist"**
```bash
# Check if local PostgreSQL is running
brew services list | grep postgresql

# Stop local PostgreSQL if conflicting
brew services stop postgresql

# Verify Docker container is running
docker ps | grep postgres
```

**Error: "password authentication failed"**
```bash
# Test connection
psql -h 127.0.0.1 -U admin -d postgres -c "\conninfo"

# Check profiles.yml has correct credentials
cat profiles.yml | grep -A 5 "password"
```

### dbt Run Issues

**Error: "Did not find relation"**
```bash
# Ensure sources are defined
dbt compile

# Run upstream models first
dbt run --select staging.* --target dev
```

**Models not found:**
```bash
# Clear dbt cache
dbt clean

# Recompile
dbt compile
```

### Environment Issues

**Wrong schema created:**
```bash
# Check which target is active
dbt debug

# Explicitly specify target
dbt run --target prod

# Drop wrong schema if needed
psql -h 127.0.0.1 -U admin -d postgres -c "DROP SCHEMA wrong_schema CASCADE;"
```

### Test Failures

**If tests fail:**
```bash
# Run with detailed output
dbt test --target dev --store-failures

# Check failed test results
SELECT * FROM <schema>.<failed_test_name>;

# Fix data issues in models
# Re-run models and tests
dbt run --target dev
dbt test --target dev
```

---

## Contact & Submission

**Repository:** https://github.com/dataorket/dbt_enpal_assessment  
**Pull Request:** https://github.com/aramayis1991/dbt_enpal_assessment/pull/10  

**Assessment Deliverables:**
- ✅ Complete dbt pipeline (8 models)
- ✅ 11-step sales funnel report (128 rows)
- ✅ DEV and PROD environments
- ✅ 5 data quality tests (100% pass rate)
- ✅ Git commits and PR
- ✅ Comprehensive documentation

---

## License

This project was created as part of the Enpal Analytics Engineer Assessment.
