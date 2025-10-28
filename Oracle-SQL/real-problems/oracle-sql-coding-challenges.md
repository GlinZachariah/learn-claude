# Oracle SQL Coding Challenges

## Challenge 1: Multi-Level Data Aggregation (Intermediate, 2.5 hours)

### Problem
Create a comprehensive sales analysis dashboard showing:
- Total sales by department and month
- Ranking employees by sales within departments
- Year-over-year growth comparison
- Running total of sales throughout year

### Requirements
- Use window functions for ranking
- Join multiple date dimensions
- Calculate growth percentages
- Use CTEs for clarity

### Starter Code
```sql
-- Create sample tables
CREATE TABLE sales (
    sale_id NUMBER,
    employee_id NUMBER,
    amount NUMBER,
    sale_date DATE,
    department_id NUMBER
);

-- TODO: Write query combining all requirements
```

### Expected Solution Pattern
```sql
WITH monthly_sales AS (
    -- Aggregate by month
    SELECT ...
),
year_comparison AS (
    -- Year-over-year logic
    SELECT ...,
           LAG(...) OVER (...)
)
SELECT ...
ORDER BY ...
```

---

## Challenge 2: Recursive Hierarchy Navigation (Advanced, 3 hours)

### Problem
Build organizational hierarchy analyzer:
- Find all subordinates under a manager
- Calculate depth in organization
- Show reporting chain
- Identify wide vs tall hierarchies

### Requirements
- Recursive CTE for tree traversal
- Path construction
- Depth calculation
- Hierarchy statistics

---

## Challenge 3: Customer Segmentation (Intermediate, 2 hours)

### Problem
Segment customers based on:
- Purchase frequency (RFM analysis)
- Lifetime value
- Recent activity
- Customer loyalty

### Solution Pattern
```sql
WITH customer_metrics AS (
    SELECT
        customer_id,
        COUNT(*) as purchase_count,
        SUM(amount) as lifetime_value,
        MAX(purchase_date) as last_purchase,
        -- Recency, Frequency, Monetary calculations
    FROM orders
    GROUP BY customer_id
),
segmentation AS (
    SELECT
        customer_id,
        CASE
            WHEN frequency_rank <= 0.25 AND monetary_rank >= 0.75 THEN 'VIP'
            WHEN frequency_rank <= 0.5 AND monetary_rank >= 0.5 THEN 'Regular'
            ELSE 'At Risk'
        END as segment
    FROM customer_metrics
)
SELECT * FROM segmentation;
```

---

## Challenge 4: Time Series Analysis (Advanced, 3.5 hours)

### Problem
Analyze sales trends over time:
- Moving averages
- Trend detection
- Seasonality identification
- Forecast pattern

### Key Functions
```sql
-- Moving average
AVG(amount) OVER (ORDER BY sale_date ROWS BETWEEN 29 PRECEDING AND CURRENT ROW)

-- Growth rate
(amount - LAG(amount) OVER (ORDER BY sale_date)) /
LAG(amount) OVER (ORDER BY sale_date)

-- Seasonal decomposition
amounts relative to monthly average
```

---

## Challenge 5: Complex PIVOT Analysis (Intermediate, 2.5 hours)

### Problem
Create cross-tabulation reports:
- Sales by product and month
- Employees by department and job title
- Multiple metrics (count, sum, average)

### Example
```sql
SELECT * FROM (
    SELECT product_id, month, sales_amount FROM sales
)
PIVOT (
    SUM(sales_amount) AS total,
    COUNT(*) AS transaction_count,
    AVG(sales_amount) AS avg_amount
    FOR month IN (1 AS jan, 2 AS feb, 3 AS mar, ...)
);
```

---

## Challenge 6: Data Quality Assessment (Intermediate, 2 hours)

### Problem
Evaluate data quality metrics:
- Null value percentages
- Duplicate detection
- Outlier identification
- Referential integrity checks

### Solution Components
```sql
-- Null percentage by column
SELECT
    column_name,
    COUNT(CASE WHEN column_value IS NULL THEN 1 END) / COUNT(*) * 100 as null_pct
FROM table

-- Duplicate detection
SELECT column, COUNT(*) as count
FROM table
GROUP BY column
HAVING COUNT(*) > 1

-- Outlier detection (values beyond 3 standard deviations)
WHERE value > avg + (3 * stddev)
```

---

## Challenge 7: Financial Reconciliation (Advanced, 3 hours)

### Problem
Match transactions between two systems:
- Find unmatched transactions
- Identify timing differences
- Detect duplicate entries
- Calculate reconciliation variance

### Key Requirements
- Fuzzy matching logic
- Amount variance tolerance
- Date window matching
- Exception reporting

---

## Challenge 8: ETL Data Validation (Intermediate, 2.5 hours)

### Problem
Validate data loads:
- Row count validation
- Column value distribution
- Referential integrity
- Business rule validation

### Example
```sql
-- Validate data completeness
SELECT
    COUNT(*) as total_rows,
    COUNT(primary_key) as non_null_keys,
    COUNT(DISTINCT primary_key) as unique_keys,
    COUNT(*) - COUNT(DISTINCT primary_key) as duplicate_keys
FROM loaded_data;

-- Check for business rule violations
SELECT * FROM orders
WHERE order_date > ship_date;  -- Should be 0 rows
```

---

## Challenge 9: Performance Optimization (Advanced, 4 hours)

### Problem
Given slow queries, optimize them:
- Rewrite with appropriate JOINs
- Add indexes
- Use window functions instead of subqueries
- Reorder operations

### Before/After Pattern
```sql
-- SLOW: Correlated subquery
SELECT *
FROM employees e
WHERE salary > (
    SELECT AVG(salary) FROM employees WHERE dept_id = e.dept_id
);

-- FAST: Join with aggregation
SELECT e.*
FROM employees e
JOIN (
    SELECT dept_id, AVG(salary) as avg_sal FROM employees GROUP BY dept_id
) d ON e.dept_id = d.dept_id
WHERE e.salary > d.avg_sal;
```

---

## Challenge 10: Incremental Data Load (Advanced, 3 hours)

### Problem
Implement CDC (Change Data Capture):
- Identify new records
- Track modifications
- Handle deletions
- Maintain audit trail

### Solution Pattern
```sql
MERGE INTO target_table t
USING (SELECT * FROM source_table WHERE last_modified > last_sync_date) s
ON (t.id = s.id)
WHEN MATCHED AND s.last_modified > t.last_modified THEN
    UPDATE SET t.columns = s.columns, t.last_modified = SYSDATE
WHEN NOT MATCHED THEN
    INSERT VALUES (s.columns, SYSDATE);
```

---

## General Evaluation Criteria

| Criteria | Points |
|----------|--------|
| **Correctness** | 40% |
| **Performance** | 25% |
| **Code Quality** | 20% |
| **Documentation** | 15% |

---

## Time Summary

| Challenge | Level | Time |
|-----------|-------|------|
| 1 | Intermediate | 2.5h |
| 2 | Advanced | 3h |
| 3 | Intermediate | 2h |
| 4 | Advanced | 3.5h |
| 5 | Intermediate | 2.5h |
| 6 | Intermediate | 2h |
| 7 | Advanced | 3h |
| 8 | Intermediate | 2.5h |
| 9 | Advanced | 4h |
| 10 | Advanced | 3h |
| **Total** | **Mixed** | **28h** |

---

## Success Indicators

After completing these challenges, you should be able to:

✅ Write complex multi-level aggregations
✅ Navigate hierarchical data with recursion
✅ Implement customer segmentation logic
✅ Perform time series analysis
✅ Create pivot tables for reporting
✅ Assess data quality
✅ Reconcile financial data
✅ Validate data loads
✅ Optimize query performance
✅ Implement incremental loads

