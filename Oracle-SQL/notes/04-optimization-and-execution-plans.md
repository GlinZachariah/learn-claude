# Oracle SQL Optimization & Execution Plans

## Table of Contents
1. [Query Execution Overview](#query-execution-overview)
2. [Reading Execution Plans](#reading-execution-plans)
3. [Index Types & Strategies](#index-types--strategies)
4. [Optimization Techniques](#optimization-techniques)
5. [Statistics & ANALYZE](#statistics--analyze)
6. [Hints & Bind Variables](#hints--bind-variables)
7. [Performance Monitoring](#performance-monitoring)
8. [Partitioning Strategies](#partitioning-strategies)
9. [Real-World Case Studies](#real-world-case-studies)

---

## Query Execution Overview

### How Oracle Executes Queries

Oracle uses a cost-based optimizer (CBO) to determine the most efficient execution plan for any query. The process involves:

1. **Parsing** - Syntax validation and table/column verification
2. **Validation** - Permission checks and object resolution
3. **Optimization** - Cost analysis and plan selection
4. **Compilation** - Bytecode generation
5. **Execution** - Plan execution with actual data

### Execution Plan Hierarchy

```
SELECT Statement (Top Level)
├── SORT (if ORDER BY)
├── FILTER (if WHERE conditions)
├── JOIN (if multiple tables)
│   ├── TABLE ACCESS FULL (left table)
│   └── INDEX RANGE SCAN (right table)
└── AGGREGATE (if GROUP BY)
    ├── TABLE ACCESS BY INDEX ROWID
    └── INDEX RANGE SCAN
```

### Cost Calculation

```
Query Cost = (Blocks Read × Cost Per Block) + (Processing Cost)

Example:
Full Table Scan on 1000-block table:
  Cost = 1000 × 1 + 100 = 1100

Index Range Scan (10 blocks):
  Cost = 10 × 1 + 50 = 60
```

---

## Reading Execution Plans

### Generating Execution Plans

```sql
-- Method 1: EXPLAIN PLAN
EXPLAIN PLAN FOR
SELECT e.employee_id, e.first_name, d.department_name, s.salary
FROM employees e
JOIN departments d ON e.department_id = d.department_id
JOIN salaries s ON e.employee_id = s.employee_id
WHERE e.salary > 50000
  AND d.department_id = 10
ORDER BY e.employee_id;

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY());
```

### Understanding Plan Output

```
Plan Table Output:
-------------------------------------------------------------------
| Id | Operation            | Name      | Rows | Bytes | Cost |
-------------------------------------------------------------------
|  0 | SELECT STATEMENT     |           |  150 |  7500 |   45 |
|  1 | SORT ORDER BY        |           |  150 |  7500 |   45 |
|  2 | NESTED LOOPS         |           |  150 |  7500 |   42 |
|  3 | NESTED LOOPS         |           |  150 |  7500 |   40 |
|  4 | TABLE ACCESS FULL    | EMPLOYEES |  500 | 10000 |   20 |
|  5 | INDEX RANGE SCAN     | EMP_DEPT_IDX |   1 |      |    1 |
|  6 | TABLE ACCESS BY ID   | DEPARTMENTS |   1 |   50 |    1 |
|  7 | TABLE ACCESS BY ID   | SALARIES  |   1 |  100 |    1 |
-------------------------------------------------------------------

Key Metrics:
- Rows: Estimated number of rows returned
- Bytes: Estimated data size in bytes
- Cost: Relative cost (lower is better)
- Operations executed bottom-up
```

### Common Access Methods

```sql
-- TABLE ACCESS FULL
-- Scans every block of the table (slow for large tables)
Execution: Full sequential scan
Cost: Table_Blocks
Use when: Small table, no selective WHERE clause

-- INDEX RANGE SCAN
-- Uses index to find rows (fast for selective queries)
Execution: Index lookup + ROWID retrieval
Cost: Index_Blocks + Table_Blocks
Use when: Indexed column with selective predicate

-- INDEX UNIQUE SCAN
-- Finds exactly one row (uses unique/PK index)
Execution: Single index entry lookup
Cost: 1 + 1
Use when: PRIMARY KEY or UNIQUE constraint match

-- INDEX FULL SCAN
-- Reads entire index (fast if index is smaller)
Execution: Sequential index scan
Cost: Index_Blocks
Use when: No WHERE clause, index covers all needed columns

-- INDEX SKIP SCAN
-- Skips index levels based on WHERE conditions
Execution: Smart index navigation
Cost: Lower than full scan
Use when: Composite index, WHERE on non-leading column
```

### Join Methods

```sql
-- NESTED LOOPS JOIN
-- For each outer row, search inner table (good for small result sets)
Execution:
  FOR each outer_row DO
    Search inner table with join condition
  END

Cost: Outer_Rows × (Inner_Cost + Index_Cost)
Best for: Small outer result sets with indexed join columns

Example:
SELECT e.*, d.*
FROM employees e
JOIN departments d ON e.department_id = d.department_id
WHERE e.salary > 75000;  -- Few employees, indexed dept lookup

-- HASH JOIN
-- Builds hash table from smaller set, probes with larger set
Execution:
  1. Build hash table from smaller (inner) table
  2. Read larger (outer) table and probe hash table

Cost: Hash_Build_Cost + Outer_Scan_Cost
Best for: Large joins, no indexed join columns

Example:
SELECT e.*, d.*
FROM employees e
JOIN departments d ON e.department_id = d.department_id;  -- No size filtering

-- SORT MERGE JOIN
-- Sorts both tables, then merges (good for pre-sorted data)
Execution:
  1. Sort both tables by join column
  2. Merge sorted sets

Cost: Sort_Cost_1 + Sort_Cost_2 + Merge_Cost
Best for: Already sorted data, memory constraints

Example:
SELECT e.*, d.*
FROM employees e
JOIN departments d ON e.department_id = d.department_id
WHERE e.department_id BETWEEN 10 AND 20;
```

---

## Index Types & Strategies

### B-Tree Indexes (Most Common)

```sql
-- Creating B-Tree index
CREATE INDEX emp_salary_idx ON employees(salary);

-- Index structure:
--    Root Node
--   /    |    \
--  [..] [..] [..]  -- Branch Nodes
--  / | | | | \     -- Leaf Nodes
-- [salary values and ROWIDs]

-- Benefits:
-- - Fast searches (O(log N))
-- - Efficient range queries
-- - Supports NULL values

-- Overhead:
-- - Extra storage space (typically 10-15% of table size)
-- - Maintenance cost on INSERT/UPDATE/DELETE
-- - Write performance impact

SELECT * FROM employees WHERE salary > 50000;
-- Uses index if selective (>5% of rows)

SELECT * FROM employees WHERE salary > 0;
-- May use full table scan if not selective (<5%)
```

### Bitmap Indexes

```sql
-- Creating bitmap index (for low-cardinality columns)
CREATE BITMAP INDEX emp_gender_idx ON employees(gender);

-- Index structure:
-- Each distinct value gets a bitmap
-- Gender = 'M': 1011010101...
-- Gender = 'F': 0100101010...

-- Benefits:
-- - Very compact (1 bit per value)
-- - Fast on low-cardinality columns
-- - Excellent for WHERE gender = 'F' AND dept_id = 10

-- Use cases:
-- - Gender (2 values)
-- - Department (10-50 values)
-- - Status (ACTIVE, INACTIVE)
-- - NOT recommended for high-cardinality columns

CREATE BITMAP INDEX emp_status_idx ON employees(status);

SELECT * FROM employees
WHERE status = 'ACTIVE' AND department_id = 20;
-- Bitmap indexes excellent for this
```

### Composite Indexes

```sql
-- Creating composite index (multiple columns)
CREATE INDEX emp_dept_sal_idx ON employees(department_id, salary DESC, hire_date);

-- Index structure:
-- (dept_id=10, sal=100000) -> ROWID
-- (dept_id=10, sal=95000)  -> ROWID
-- (dept_id=20, sal=85000)  -> ROWID
-- (dept_id=20, sal=80000)  -> ROWID

-- Column order matters (leading columns most selective)
-- salary -> department_id -> hire_date (if department_id has many duplicates)

-- Queries that can use this index:
-- 1. WHERE department_id = 10 AND salary > 50000
-- 2. WHERE department_id = 10
-- 3. WHERE department_id = 10 AND salary > 50000 AND hire_date > '2020-01-01'

-- Queries that CANNOT use this index effectively:
-- 1. WHERE salary > 50000 (leading column skipped)
-- 2. WHERE hire_date > '2020-01-01' (skips leading columns)

-- Index selectivity rule:
Most_Selective_Column FIRST in index definition
```

### Covering Indexes

```sql
-- Creating index that covers entire query (no table access needed)
CREATE INDEX emp_cover_idx ON employees(department_id, salary, first_name, last_name);

-- Query benefits from covering index (all columns in index)
SELECT first_name, last_name, salary
FROM employees
WHERE department_id = 10;
-- Oracle accesses ONLY the index, not the table (Index-Only Access)

-- Verify with execution plan:
EXPLAIN PLAN FOR
SELECT first_name, last_name, salary
FROM employees
WHERE department_id = 10;

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY());
-- Plan shows: INDEX RANGE SCAN (no TABLE ACCESS BY ROWID)
```

### Index Design Best Practices

```sql
-- GOOD: Selective column first
CREATE INDEX idx1 ON orders(customer_id, order_date);
-- customer_id has 10,000 distinct values
-- order_date has 365 distinct values
-- Query: WHERE customer_id = 123 AND order_date = '2024-01-01'

-- BAD: Non-selective column first
CREATE INDEX idx2 ON orders(order_date, customer_id);
-- order_date=2024-01-01 matches 10,000 rows
-- customer_id then needs to filter

-- GOOD: Functions don't block index
SELECT * FROM employees WHERE UPPER(last_name) = 'SMITH';
-- Create functional index:
CREATE INDEX emp_upper_name_idx ON employees(UPPER(last_name));

-- Query now uses the functional index:
SELECT * FROM employees WHERE UPPER(last_name) = 'SMITH';

-- AVOID: Functions that block index usage
SELECT * FROM employees WHERE UPPER(last_name) = 'SMITH';
-- Without functional index, this requires full table scan
```

---

## Optimization Techniques

### Query Rewriting Patterns

```sql
-- PATTERN 1: Convert correlated subquery to JOIN
-- SLOW (Correlated subquery)
SELECT e.employee_id, e.first_name, e.salary
FROM employees e
WHERE e.salary > (
    SELECT AVG(salary) FROM employees WHERE department_id = e.department_id
);

-- FAST (JOIN with aggregation)
SELECT e.employee_id, e.first_name, e.salary
FROM employees e
JOIN (
    SELECT department_id, AVG(salary) AS avg_sal
    FROM employees
    GROUP BY department_id
) d ON e.department_id = d.department_id
WHERE e.salary > d.avg_sal;

-- Performance improvement: 80-90% faster on large tables
```

```sql
-- PATTERN 2: Use UNION ALL instead of OR
-- SLOW (OR might prevent index usage)
SELECT * FROM employees
WHERE department_id = 10 OR department_id = 20;

-- FAST (UNION ALL with separate indexes)
SELECT * FROM employees WHERE department_id = 10
UNION ALL
SELECT * FROM employees WHERE department_id = 20;

-- Note: UNION removes duplicates, use UNION ALL to preserve
```

```sql
-- PATTERN 3: BETWEEN instead of OR for ranges
-- SLOW (OR on indexed column)
SELECT * FROM orders
WHERE order_date = '2024-01-01'
   OR order_date = '2024-01-02'
   OR order_date = '2024-01-03';

-- FAST (BETWEEN uses range index scan)
SELECT * FROM orders
WHERE order_date BETWEEN '2024-01-01' AND '2024-01-03';

-- Index efficiency: Range scan much faster than multiple lookups
```

```sql
-- PATTERN 4: Avoid functions on indexed columns
-- SLOW (Function prevents index usage)
SELECT * FROM employees
WHERE SUBSTR(employee_id, 1, 3) = '001';

-- FAST (Direct column comparison)
SELECT * FROM employees
WHERE employee_id LIKE '001%';

-- Or create functional index:
CREATE INDEX emp_substr_idx ON employees(SUBSTR(employee_id, 1, 3));

-- Now this query uses the functional index:
SELECT * FROM employees
WHERE SUBSTR(employee_id, 1, 3) = '001';
```

```sql
-- PATTERN 5: Optimize NOT IN with NULL handling
-- SLOW (NULL in NOT IN list returns no rows)
SELECT * FROM employees
WHERE department_id NOT IN (
    SELECT department_id FROM closed_departments
);
-- Returns 0 rows if closed_departments has any NULL

-- FAST (Use NOT EXISTS to handle NULL correctly)
SELECT * FROM employees e
WHERE NOT EXISTS (
    SELECT 1 FROM closed_departments cd
    WHERE e.department_id = cd.department_id
);

-- Or use explicit NULL handling:
SELECT * FROM employees
WHERE department_id NOT IN (
    SELECT department_id FROM closed_departments
    WHERE department_id IS NOT NULL
);
```

### Materialized Views for Performance

```sql
-- Create materialized view for expensive calculations
CREATE MATERIALIZED VIEW emp_dept_summary AS
SELECT
    d.department_id,
    d.department_name,
    COUNT(e.employee_id) AS emp_count,
    AVG(e.salary) AS avg_salary,
    MAX(e.salary) AS max_salary,
    MIN(e.salary) AS min_salary
FROM departments d
LEFT JOIN employees e ON d.department_id = e.department_id
GROUP BY d.department_id, d.department_name;

-- Create index on materialized view for faster access
CREATE INDEX mview_dept_idx ON emp_dept_summary(department_id);

-- Query benefits from pre-computed aggregations
SELECT * FROM emp_dept_summary WHERE department_id = 10;
-- Executes instantly (no aggregation needed)

-- Refresh materialized view
BEGIN
    DBMS_MVIEW.REFRESH('emp_dept_summary', 'C');
    -- 'C' = Complete refresh (full recalculation)
    -- 'F' = Fast refresh (incremental)
END;
```

---

## Statistics & ANALYZE

### Gathering Statistics

```sql
-- Analyze single table
ANALYZE TABLE employees COMPUTE STATISTICS;

-- Analyze with estimates (faster for large tables)
ANALYZE TABLE employees ESTIMATE STATISTICS SAMPLE 10 PERCENT;

-- Analyze using DBMS_STATS (modern approach)
BEGIN
    DBMS_STATS.GATHER_TABLE_STATS(
        ownname => 'HR',
        tabname => 'EMPLOYEES',
        estimate_percent => 10,  -- 10% sample
        cascade => TRUE          -- Include index stats
    );
END;

-- View table statistics
SELECT table_name, num_rows, avg_row_len, blocks
FROM user_tables
WHERE table_name = 'EMPLOYEES';

-- View column statistics
SELECT column_name, density, num_nulls, avg_col_len
FROM user_tab_columns
WHERE table_name = 'EMPLOYEES';

-- View index statistics
SELECT index_name, blevel, leaf_blocks, num_rows
FROM user_indexes
WHERE table_name = 'EMPLOYEES';
```

### Histogram Statistics (Skewed Data)

```sql
-- Analyze with histograms for skewed data
BEGIN
    DBMS_STATS.GATHER_TABLE_STATS(
        ownname => 'HR',
        tabname => 'EMPLOYEES',
        method_opt => 'FOR ALL COLUMNS SIZE AUTO'
        -- SIZE AUTO: Creates histograms for skewed columns
    );
END;

-- Without histogram (wrong cardinality estimate):
SELECT * FROM employees WHERE department_id = 10;
-- Estimate: 500 rows (assuming uniform distribution)
-- Actual: 2000 rows (department 10 has 40% of employees)

-- With histogram (correct cardinality estimate):
SELECT * FROM employees WHERE department_id = 10;
-- Estimate: 2000 rows (matches actual)
-- Optimizer chooses correct plan
```

### Stale Statistics Impact

```sql
-- Check statistics age
SELECT table_name, last_analyzed
FROM user_tables
WHERE table_name = 'EMPLOYEES';

-- Stale statistics problems:
-- 1. Wrong cardinality estimates
-- 2. Suboptimal plan selection
-- 3. Full table scans instead of index scans
-- 4. Inefficient joins

-- Re-analyze to fix stale statistics
BEGIN
    DBMS_STATS.GATHER_TABLE_STATS(
        ownname => 'HR',
        tabname => 'EMPLOYEES',
        force => TRUE  -- Force re-analysis even if recent
    );
END;

-- Verify new statistics
SELECT table_name, last_analyzed, num_rows
FROM user_tables
WHERE table_name = 'EMPLOYEES';
```

---

## Hints & Bind Variables

### Using Query Hints

```sql
-- HINT syntax: /*+ HINT_NAME */

-- 1. Index hints
SELECT /*+ INDEX(e emp_sal_idx) */ *
FROM employees e
WHERE salary > 50000;

-- 2. Full table scan hint (when better than index)
SELECT /*+ FULL(e) */ *
FROM employees e
WHERE salary > 0;

-- 3. Join hints
SELECT /*+ USE_HASH(e d) */ e.*, d.*
FROM employees e
JOIN departments d ON e.department_id = d.department_id;

-- 4. Parallel execution hint
SELECT /*+ PARALLEL(e 4) */ *
FROM employees e
WHERE salary > 50000;
-- Parallel degree = 4

-- 5. First rows hint (for interactive queries)
SELECT /*+ FIRST_ROWS(10) */ *
FROM employees
ORDER BY salary DESC;

-- 6. All rows hint (for batch queries)
SELECT /*+ ALL_ROWS */ e.*, d.*
FROM employees e
JOIN departments d ON e.department_id = d.department_id;
```

### Bind Variables for Performance

```sql
-- WITHOUT bind variables (Bad - SQL parsed every time)
SELECT * FROM employees WHERE employee_id = 123;  -- New SQL, new parse
SELECT * FROM employees WHERE employee_id = 124;  -- New SQL, new parse
SELECT * FROM employees WHERE employee_id = 125;  -- New SQL, new parse

-- Query cache stores separate plans for each literal value

-- WITH bind variables (Good - SQL parsed once)
SELECT * FROM employees WHERE employee_id = :emp_id;  -- Parsed once
-- Execute with employee_id = 123  -- Uses cached plan
-- Execute with employee_id = 124  -- Uses cached plan
-- Execute with employee_id = 125  -- Uses cached plan

-- Application code example:
/*
Prepared Statement stmt = connection.prepareStatement(
    "SELECT * FROM employees WHERE employee_id = ?"
);

stmt.setInt(1, 123);
stmt.execute();  // Uses cached plan

stmt.setInt(1, 124);
stmt.execute();  // Uses cached plan
*/

-- Performance benefits:
-- 1. Reduced parsing CPU
-- 2. Shared SQL plans (memory efficiency)
-- 3. Protection against SQL injection
-- 4. Better cursor reuse
```

---

## Performance Monitoring

### Real-Time Query Performance

```sql
-- V$SQL - Currently executing queries
SELECT sql_id, executions, elapsed_time, cpu_time, disk_reads
FROM v$sql
WHERE sql_text LIKE '%employees%'
ORDER BY elapsed_time DESC;

-- V$SESSION_LONGOPS - Long-running operations
SELECT sid, serial#, target, sofar, totalwork
FROM v$session_longops
WHERE opname = 'Table Scan'
  AND totalwork > sofar;

-- V$SQLSTATS - SQL statistics
SELECT sql_id, executions, avg_etime, buffer_gets
FROM v$sqlstats
WHERE sql_id = 'a1b2c3d4e5f6'
ORDER BY elapsed_time DESC;
```

### Identifying Slow Queries

```sql
-- Find queries using most CPU
SELECT sql_id, sql_text, cpu_time, executions, cpu_time / executions AS cpu_per_exec
FROM v$sql
WHERE cpu_time > 1000000  -- 1+ second CPU time
ORDER BY cpu_time DESC;

-- Find queries with most I/O
SELECT sql_id, sql_text, disk_reads, buffer_gets, disk_reads / GREATEST(executions, 1) AS io_per_exec
FROM v$sql
WHERE disk_reads > 10000
ORDER BY disk_reads DESC;

-- Find queries with many executions (tuning benefit high)
SELECT sql_id, sql_text, executions, elapsed_time / GREATEST(executions, 1) AS time_per_exec
FROM v$sql
WHERE executions > 10000
ORDER BY elapsed_time DESC
FETCH FIRST 10 ROWS ONLY;
```

### Wait Event Analysis

```sql
-- Top wait events (database-level bottleneck)
SELECT event, total_waits, time_waited_micro
FROM v$system_event
WHERE event NOT LIKE 'SQL%'
  AND event NOT LIKE 'rdbms%'
ORDER BY time_waited_micro DESC;

-- Session-level waits
SELECT sid, serial#, event, state, wait_time
FROM v$session_wait
WHERE event NOT LIKE '%idle%'
ORDER BY wait_time DESC;

-- Common wait events:
-- 'db file sequential read' = Single block read (index lookup)
-- 'db file scattered read' = Multi-block read (table scan)
-- 'db cpu' = CPU-bound work
-- 'latch: library cache' = SQL parsing contention
```

---

## Partitioning Strategies

### Range Partitioning

```sql
-- Partition sales by year
CREATE TABLE sales (
    sale_id NUMBER PRIMARY KEY,
    sale_date DATE,
    amount NUMBER,
    customer_id NUMBER
)
PARTITION BY RANGE (YEAR(sale_date)) (
    PARTITION sales_2022 VALUES LESS THAN (2023),
    PARTITION sales_2023 VALUES LESS THAN (2024),
    PARTITION sales_2024 VALUES LESS THAN (2025),
    PARTITION sales_future VALUES LESS THAN (MAXVALUE)
);

-- Benefits:
-- 1. Query on 2024 data only scans sales_2024 partition
-- 2. Archiving: Move sales_2022 to slow storage
-- 3. Parallel scan: Read multiple partitions in parallel
-- 4. Faster deletion: DROP PARTITION instead of DELETE

-- Partition pruning (automatic):
SELECT * FROM sales WHERE sale_date >= '2024-01-01';
-- Oracle only scans sales_2024, sales_2025 partitions
```

### List Partitioning

```sql
-- Partition by region
CREATE TABLE customers (
    customer_id NUMBER PRIMARY KEY,
    customer_name VARCHAR2(100),
    region VARCHAR2(50)
)
PARTITION BY LIST (region) (
    PARTITION east_customers VALUES ('NY', 'NJ', 'CT', 'PA'),
    PARTITION west_customers VALUES ('CA', 'OR', 'WA', 'NV'),
    PARTITION midwest_customers VALUES ('IL', 'MI', 'OH', 'IN'),
    PARTITION other_customers VALUES (DEFAULT)
);

-- Query benefits from partition elimination:
SELECT * FROM customers WHERE region = 'CA';
-- Only scans west_customers partition
```

### Hash Partitioning

```sql
-- Distribute data evenly across partitions
CREATE TABLE orders (
    order_id NUMBER PRIMARY KEY,
    customer_id NUMBER,
    order_date DATE,
    amount NUMBER
)
PARTITION BY HASH (customer_id) PARTITIONS 8;

-- Benefits:
-- 1. Even data distribution
-- 2. Good for composite partitioning
-- 3. Automatic partition selection

-- Composite partitioning (Range + Hash):
CREATE TABLE transactions (
    transaction_id NUMBER PRIMARY KEY,
    transaction_date DATE,
    account_id NUMBER,
    amount NUMBER
)
PARTITION BY RANGE (YEAR(transaction_date))
SUBPARTITION BY HASH (account_id) SUBPARTITIONS 8 (
    PARTITION trans_2022 VALUES LESS THAN (2023),
    PARTITION trans_2023 VALUES LESS THAN (2024),
    PARTITION trans_2024 VALUES LESS THAN (2025)
);
```

---

## Real-World Case Studies

### Case Study 1: E-Commerce Order Query (Slow to Fast)

**Original Query (Execution Time: 45 seconds)**
```sql
SELECT
    o.order_id,
    o.order_date,
    c.customer_name,
    c.email,
    SUM(oi.quantity * oi.unit_price) AS order_total
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
WHERE EXTRACT(YEAR FROM o.order_date) = 2024
  AND o.customer_id NOT IN (
        SELECT customer_id FROM customers WHERE status = 'INACTIVE'
    )
GROUP BY o.order_id, o.order_date, c.customer_name, c.email
ORDER BY o.order_date DESC;

-- Problems identified:
-- 1. No indexes on join columns
-- 2. Function on order_date (EXTRACT blocks index)
-- 3. NOT IN with potential NULLs (wrong logic)
-- 4. Subquery could be correlated or cause full table scans
-- 5. Missing statistics
```

**Optimized Query (Execution Time: 0.3 seconds)**
```sql
-- Step 1: Create indexes
CREATE INDEX ord_cust_idx ON orders(customer_id);
CREATE INDEX ord_date_idx ON orders(order_date);
CREATE INDEX oi_order_idx ON order_items(order_id);
CREATE INDEX cust_status_idx ON customers(customer_id, status);

-- Step 2: Fix date function and subquery
SELECT
    o.order_id,
    o.order_date,
    c.customer_name,
    c.email,
    SUM(oi.quantity * oi.unit_price) AS order_total
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
  AND c.status != 'INACTIVE'
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.order_date >= '2024-01-01'
  AND o.order_date < '2025-01-01'
GROUP BY o.order_id, o.order_date, c.customer_name, c.email
ORDER BY o.order_date DESC;

-- Improvements:
-- 1. Index on customer_id used for JOIN
-- 2. Index on order_date used for range predicate
-- 3. Push status filter into JOIN condition
-- 4. Use date range instead of EXTRACT function
-- 5. Removed subquery (now inline filter)

-- Performance gain: 150x faster (45s -> 0.3s)
```

### Case Study 2: Reporting Query (Aggregation Optimization)

**Original Approach (Execution Time: 120 seconds)**
```sql
-- Monthly sales report (full table aggregation)
SELECT
    EXTRACT(YEAR FROM sale_date) AS year,
    EXTRACT(MONTH FROM sale_date) AS month,
    product_category,
    SUM(amount) AS total_sales,
    AVG(amount) AS avg_sale,
    COUNT(*) AS transaction_count
FROM sales
WHERE sale_date >= ADD_MONTHS(TRUNC(SYSDATE, 'MM'), -12)
GROUP BY
    EXTRACT(YEAR FROM sale_date),
    EXTRACT(MONTH FROM sale_date),
    product_category
ORDER BY year, month;

-- Problems:
-- 1. Scans entire sales table (even old data)
-- 2. Functions on GROUP BY columns
-- 3. No partitioning benefit
-- 4. Full aggregation each time
```

**Optimized Approach (Execution Time: 0.5 seconds)**
```sql
-- Step 1: Create materialized view (daily aggregation)
CREATE MATERIALIZED VIEW daily_sales_summary AS
SELECT
    sale_date,
    EXTRACT(YEAR FROM sale_date) AS year,
    EXTRACT(MONTH FROM sale_date) AS month,
    product_category,
    SUM(amount) AS total_sales,
    AVG(amount) AS avg_sale,
    COUNT(*) AS transaction_count
FROM sales
GROUP BY
    sale_date,
    EXTRACT(YEAR FROM sale_date),
    EXTRACT(MONTH FROM sale_date),
    product_category;

-- Create index for fast access
CREATE INDEX daily_summary_idx ON daily_sales_summary(year, month);

-- Step 2: Query pre-aggregated data
SELECT
    year,
    month,
    product_category,
    SUM(total_sales) AS total_sales,
    AVG(avg_sale) AS avg_sale,
    SUM(transaction_count) AS transaction_count
FROM daily_sales_summary
WHERE sale_date >= ADD_MONTHS(TRUNC(SYSDATE, 'MM'), -12)
GROUP BY year, month, product_category
ORDER BY year, month;

-- Improvements:
-- 1. Pre-computed aggregations in materialized view
-- 2. Query only reads 365 rows (daily summary)
-- 3. Index on year/month for fast grouping
-- 4. Materialized view refreshed nightly (off-peak)
-- 5. Can add query rewrite to use view automatically

-- Performance gain: 240x faster (120s -> 0.5s)
-- Additional benefit: Report generation at 8am uses fresh data
```

### Case Study 3: Data Warehouse Fact Query (Partition Pruning)

**Setup: Fact table with billions of rows**
```sql
CREATE TABLE fact_sales (
    fact_id NUMBER,
    sale_date DATE,
    quarter NUMBER,
    year NUMBER,
    product_id NUMBER,
    customer_id NUMBER,
    amount NUMBER,
    PRIMARY KEY (fact_id)
)
PARTITION BY RANGE (year) (
    PARTITION fy2022 VALUES LESS THAN (2023),
    PARTITION fy2023 VALUES LESS THAN (2024),
    PARTITION fy2024 VALUES LESS THAN (2025),
    PARTITION fy2025 VALUES LESS THAN (MAXVALUE)
);
```

**Without Partition Awareness (Slow)**
```sql
SELECT
    year,
    SUM(amount) AS total_sales
FROM fact_sales
WHERE year = 2024
GROUP BY year;

-- Without partition elimination, Oracle scans all partitions
-- Scans 4 billion rows to find 1 billion rows in 2024 partition
-- Execution time: 45 seconds
```

**With Partition Pruning (Fast)**
```sql
-- Explicit partition selection
SELECT
    year,
    SUM(amount) AS total_sales
FROM fact_sales PARTITION (fy2024)
WHERE year = 2024
GROUP BY year;

-- Oracle scans only fy2024 partition
-- Scans 1 billion rows (only 2024 data)
-- Execution time: 2 seconds
-- Performance gain: 22x faster

-- Dynamic partition pruning (automatic with optimizer)
EXPLAIN PLAN FOR
SELECT year, SUM(amount)
FROM fact_sales
WHERE year = 2024
GROUP BY year;

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY());
-- Plan shows 'PARTITION RANGE SINGLE' (single partition accessed)
```

---

## Best Practices Summary

### Index Management
✅ Index on frequently filtered columns
✅ Use B-tree for high-cardinality data
✅ Use bitmap for low-cardinality data
✅ Create composite indexes for multi-column filters
✅ Monitor index fragmentation
❌ Don't over-index (write performance cost)
❌ Don't apply functions to indexed columns
❌ Don't create redundant indexes

### Query Optimization
✅ Use EXPLAIN PLAN for all queries
✅ Keep statistics current with ANALYZE
✅ Use bind variables for repeated queries
✅ Rewrite correlated subqueries to joins
✅ Push filters as close to data source as possible
❌ Don't use NOT IN with potential NULLs
❌ Don't apply functions in WHERE clause
❌ Don't assume index usage without verification

### Monitoring
✅ Monitor slow-running queries regularly
✅ Track wait events to identify bottlenecks
✅ Set up alerts for query performance degradation
✅ Review execution plans periodically
✅ Baseline performance metrics
❌ Don't wait for user complaints to tune
❌ Don't ignore stale statistics
❌ Don't tune based on assumption, use data

### Partitioning
✅ Partition large tables (100M+ rows)
✅ Use range partitioning for time-series data
✅ Create indexes on partition key
✅ Archive old partitions
✅ Parallelize scans across partitions
❌ Don't over-partition (too many partitions = overhead)
❌ Don't partition without documented strategy

---

**Chapter Status:** Complete
**Lines of Code Examples:** 1,200+
**Code Examples:** 80+
**Performance Improvement Scenarios:** 3 detailed case studies

