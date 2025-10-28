# Window Functions & Analytics in Oracle SQL

## Table of Contents
1. [Window Function Fundamentals](#window-function-fundamentals)
2. [Ranking Functions](#ranking-functions)
3. [Aggregate Window Functions](#aggregate-window-functions)
4. [Analytic Functions](#analytic-functions)
5. [OVER Clause & Partitioning](#over-clause--partitioning)
6. [Framing Clauses](#framing-clauses)
7. [LAG & LEAD Functions](#lag--lead-functions)
8. [First/Last Value Functions](#firstlast-value-functions)
9. [Pivot & Unpivot](#pivot--unpivot)
10. [Advanced Analytics](#advanced-analytics)

---

## 1. Window Function Fundamentals

Window functions perform calculations across a set of rows without collapsing them:

```sql
-- Basic window function syntax
SELECT column1, column2,
       function() OVER (
           [PARTITION BY column(s)]
           [ORDER BY column(s) [ASC|DESC]]
           [frame specification]
       ) AS window_result
FROM table;

-- Key advantage: No GROUP BY needed, original rows preserved
SELECT employee_id,
       first_name,
       salary,
       AVG(salary) OVER () AS company_avg,
       salary - AVG(salary) OVER () AS diff
FROM employees;

-- Window functions vs aggregate functions
-- Aggregate: Collapses rows, uses GROUP BY
SELECT department_id, COUNT(*), AVG(salary)
FROM employees
GROUP BY department_id;

-- Window: Preserves rows, uses OVER clause
SELECT employee_id,
       department_id,
       COUNT(*) OVER (PARTITION BY department_id) AS dept_count,
       AVG(salary) OVER (PARTITION BY department_id) AS dept_avg
FROM employees;
```

---

## 2. Ranking Functions

### ROW_NUMBER()

```sql
-- Assign sequential number to rows
SELECT employee_id, first_name, salary,
       ROW_NUMBER() OVER (ORDER BY salary DESC) AS salary_rank
FROM employees;

-- Row number by department
SELECT employee_id, first_name, department_id, salary,
       ROW_NUMBER() OVER (PARTITION BY department_id ORDER BY salary DESC) AS dept_rank
FROM employees;

-- Get top 3 employees per department
SELECT * FROM (
    SELECT employee_id, first_name, department_id, salary,
           ROW_NUMBER() OVER (PARTITION BY department_id ORDER BY salary DESC) AS rank
    FROM employees
)
WHERE rank <= 3;
```

### RANK() and DENSE_RANK()

```sql
-- RANK() - Skips ranks for ties
SELECT employee_id, first_name, salary,
       RANK() OVER (ORDER BY salary DESC) AS rank,
       DENSE_RANK() OVER (ORDER BY salary DESC) AS dense_rank
FROM employees;

-- Example output:
-- Salary: 100000, RANK: 1, DENSE_RANK: 1
-- Salary: 100000, RANK: 1, DENSE_RANK: 1
-- Salary: 95000,  RANK: 3, DENSE_RANK: 2
-- Salary: 95000,  RANK: 3, DENSE_RANK: 2
-- Salary: 90000,  RANK: 5, DENSE_RANK: 3

-- RANK() by department
SELECT employee_id, first_name, department_id, salary,
       RANK() OVER (PARTITION BY department_id ORDER BY salary DESC) AS dept_rank
FROM employees;

-- Find salary range for specific rank
SELECT * FROM (
    SELECT employee_id, first_name, salary,
           RANK() OVER (ORDER BY salary DESC) AS salary_rank
    FROM employees
)
WHERE salary_rank BETWEEN 10 AND 20;
```

### NTILE()

```sql
-- Distribute rows into N equal groups
SELECT employee_id, first_name, salary,
       NTILE(4) OVER (ORDER BY salary) AS salary_quartile
FROM employees;

-- Distribute employees into 10 salary deciles
SELECT employee_id, first_name, salary,
       NTILE(10) OVER (ORDER BY salary) AS salary_decile
FROM employees;

-- NTILE by department
SELECT employee_id, first_name, department_id, salary,
       NTILE(3) OVER (PARTITION BY department_id ORDER BY salary) AS salary_tertile
FROM employees;
```

---

## 3. Aggregate Window Functions

```sql
-- SUM window function
SELECT employee_id, first_name, salary,
       SUM(salary) OVER () AS total_payroll,
       SUM(salary) OVER (PARTITION BY department_id) AS dept_payroll,
       ROUND(salary / SUM(salary) OVER (PARTITION BY department_id) * 100, 2) AS pct_of_dept
FROM employees;

-- AVG window function
SELECT employee_id, first_name, salary,
       AVG(salary) OVER () AS company_avg,
       AVG(salary) OVER (PARTITION BY department_id) AS dept_avg,
       salary - AVG(salary) OVER (PARTITION BY department_id) AS diff_from_dept_avg
FROM employees;

-- COUNT window function
SELECT employee_id, first_name, department_id,
       COUNT(*) OVER () AS total_employees,
       COUNT(*) OVER (PARTITION BY department_id) AS dept_employees
FROM employees;

-- MIN/MAX window functions
SELECT employee_id, first_name, salary,
       MIN(salary) OVER (PARTITION BY department_id) AS dept_min_salary,
       MAX(salary) OVER (PARTITION BY department_id) AS dept_max_salary,
       MAX(salary) OVER (PARTITION BY department_id) - salary AS diff_from_max
FROM employees;
```

---

## 4. Analytic Functions

### PERCENT_RANK() and CUME_DIST()

```sql
-- PERCENT_RANK: Relative rank as percentage
SELECT employee_id, first_name, salary,
       PERCENT_RANK() OVER (ORDER BY salary) AS percentile
FROM employees;

-- CUME_DIST: Cumulative distribution (0 to 1)
SELECT employee_id, first_name, salary,
       CUME_DIST() OVER (ORDER BY salary) AS cumulative_dist
FROM employees;

-- Salary percentiles by department
SELECT employee_id, first_name, department_id, salary,
       PERCENT_RANK() OVER (PARTITION BY department_id ORDER BY salary) AS dept_percentile
FROM employees;
```

---

## 5. OVER Clause & Partitioning

```sql
-- Empty OVER - All rows as single partition
SELECT employee_id, first_name, salary,
       AVG(salary) OVER () AS company_avg
FROM employees;

-- PARTITION BY - Multiple windows
SELECT employee_id, first_name, department_id, salary,
       AVG(salary) OVER (PARTITION BY department_id) AS dept_avg
FROM employees;

-- ORDER BY - Enables frame specification
SELECT employee_id, first_name, salary,
       SUM(salary) OVER (ORDER BY salary) AS running_total
FROM employees;

-- PARTITION BY and ORDER BY combined
SELECT employee_id, first_name, department_id, hire_date, salary,
       SUM(salary) OVER (PARTITION BY department_id ORDER BY hire_date) AS running_dept_total
FROM employees;

-- Multiple PARTITION BY columns
SELECT employee_id, first_name, department_id, job_id, salary,
       AVG(salary) OVER (PARTITION BY department_id, job_id) AS job_avg
FROM employees;
```

---

## 6. Framing Clauses

Framing specifies which rows to include relative to current row:

```sql
-- ROWS BETWEEN: Physical frame
SELECT employee_id, first_name, salary,
       AVG(salary) OVER (
           ORDER BY salary
           ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING
       ) AS moving_avg_3
FROM employees;

-- UNBOUNDED PRECEDING to CURRENT ROW (default for ORDER BY without ROWS)
SELECT employee_id, first_name, salary,
       SUM(salary) OVER (
           ORDER BY salary
           ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
       ) AS running_total
FROM employees;

-- RANGE BETWEEN: Logical frame
SELECT employee_id, first_name, salary,
       COUNT(*) OVER (
           ORDER BY salary
           RANGE BETWEEN 1000 PRECEDING AND 1000 FOLLOWING
       ) AS employees_within_1000
FROM employees;

-- Moving average example
SELECT employee_id, first_name, salary,
       AVG(salary) OVER (
           ORDER BY salary
           ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
       ) AS ma_3
FROM employees;

-- Year-to-date running total
SELECT employee_id, transaction_date, amount,
       SUM(amount) OVER (
           PARTITION BY EXTRACT(YEAR FROM transaction_date)
           ORDER BY transaction_date
           ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
       ) AS ytd_total
FROM transactions;
```

---

## 7. LAG & LEAD Functions

Access data from previous or following rows:

```sql
-- LAG: Get previous row value
SELECT employee_id, first_name, hire_date, salary,
       LAG(salary) OVER (ORDER BY hire_date) AS previous_salary
FROM employees;

-- LEAD: Get next row value
SELECT employee_id, first_name, hire_date, salary,
       LEAD(salary) OVER (ORDER BY hire_date) AS next_salary
FROM employees;

-- Calculate salary change
SELECT employee_id, first_name, hire_date, salary,
       LAG(salary) OVER (ORDER BY hire_date) AS previous_salary,
       salary - LAG(salary) OVER (ORDER BY hire_date) AS salary_change,
       ROUND((salary - LAG(salary) OVER (ORDER BY hire_date)) / LAG(salary) OVER (ORDER BY hire_date) * 100, 2) AS pct_change
FROM employees;

-- LAG with default value
SELECT employee_id, first_name, salary,
       LAG(salary, 1, 0) OVER (PARTITION BY department_id ORDER BY salary) AS prev_salary
FROM employees;

-- LAG with multiple rows back
SELECT employee_id, first_name, salary,
       LAG(salary, 2) OVER (ORDER BY salary) AS salary_2_rows_back,
       LAG(salary, 3) OVER (ORDER BY salary) AS salary_3_rows_back
FROM employees;

-- Year-over-year comparison
SELECT year, month, sales,
       LAG(sales) OVER (PARTITION BY EXTRACT(MONTH FROM month_date) ORDER BY year) AS previous_year_sales,
       sales - LAG(sales) OVER (PARTITION BY EXTRACT(MONTH FROM month_date) ORDER BY year) AS yoy_change
FROM monthly_sales;
```

---

## 8. First/Last Value Functions

```sql
-- FIRST_VALUE: Get first value in window
SELECT employee_id, first_name, department_id, salary,
       FIRST_VALUE(salary) OVER (PARTITION BY department_id ORDER BY salary) AS dept_min_salary
FROM employees;

-- LAST_VALUE: Get last value in window
SELECT employee_id, first_name, department_id, salary,
       LAST_VALUE(salary) OVER (
           PARTITION BY department_id
           ORDER BY salary
           ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
       ) AS dept_max_salary
FROM employees;

-- Employee closest to department average
SELECT employee_id, first_name, department_id, salary,
       FIRST_VALUE(first_name) OVER (
           PARTITION BY department_id
           ORDER BY ABS(salary - AVG(salary) OVER (PARTITION BY department_id))
       ) AS closest_to_avg
FROM employees;

-- Salary progression within department
SELECT employee_id, first_name, department_id, hire_date, salary,
       FIRST_VALUE(salary) OVER (PARTITION BY department_id ORDER BY hire_date) AS starting_salary,
       LAST_VALUE(salary) OVER (
           PARTITION BY department_id
           ORDER BY hire_date
           ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
       ) AS latest_salary
FROM employees;
```

---

## 9. Pivot & Unpivot

### PIVOT

```sql
-- Basic PIVOT
SELECT * FROM (
    SELECT job_id, department_id, salary FROM employees
)
PIVOT (
    AVG(salary) FOR job_id IN ('ANALYST', 'CLERK', 'MANAGER', 'PRESIDENT')
);

-- PIVOT with multiple aggregate functions
SELECT * FROM (
    SELECT job_id, department_id, salary FROM employees
)
PIVOT (
    AVG(salary) AS avg_sal,
    COUNT(*) AS emp_count,
    MAX(salary) AS max_sal
    FOR job_id IN ('ANALYST', 'CLERK', 'MANAGER')
);

-- PIVOT with column aliases
SELECT * FROM (
    SELECT job_id, department_id, salary FROM employees
)
PIVOT (
    AVG(salary) FOR job_id IN (
        'ANALYST' AS analyst_avg,
        'CLERK' AS clerk_avg,
        'MANAGER' AS manager_avg
    )
);
```

### UNPIVOT

```sql
-- Basic UNPIVOT
SELECT * FROM (
    SELECT department_id, analyst_avg, clerk_avg, manager_avg
    FROM salary_by_job
)
UNPIVOT (
    salary FOR job IN (analyst_avg, clerk_avg, manager_avg)
);

-- UNPIVOT with include/exclude nulls
SELECT * FROM salary_matrix
UNPIVOT INCLUDE NULLS (
    salary FOR quarter IN (Q1, Q2, Q3, Q4)
);
```

---

## 10. Advanced Analytics

### Complex Window Function Patterns

```sql
-- Cumulative percentage calculation
SELECT employee_id, first_name, salary,
       ROUND(salary / SUM(salary) OVER () * 100, 2) AS salary_pct,
       ROUND(SUM(salary) OVER (ORDER BY salary DESC) / SUM(salary) OVER () * 100, 2) AS cumulative_pct
FROM employees
ORDER BY salary DESC;

-- Employee ranking with multiple criteria
SELECT employee_id, first_name, department_id, salary, hire_date,
       ROW_NUMBER() OVER (PARTITION BY department_id ORDER BY salary DESC, hire_date ASC) AS emp_rank
FROM employees;

-- Identify salary bands
SELECT employee_id, first_name, salary,
       CASE
           WHEN PERCENT_RANK() OVER (ORDER BY salary) <= 0.25 THEN 'Bottom 25%'
           WHEN PERCENT_RANK() OVER (ORDER BY salary) <= 0.50 THEN '25-50%'
           WHEN PERCENT_RANK() OVER (ORDER BY salary) <= 0.75 THEN '50-75%'
           ELSE 'Top 25%'
       END AS salary_band
FROM employees;

-- Period-over-period analysis
SELECT year, month, sales,
       LAG(sales) OVER (PARTITION BY month ORDER BY year) AS prior_year,
       ROUND((sales - LAG(sales) OVER (PARTITION BY month ORDER BY year)) /
             LAG(sales) OVER (PARTITION BY month ORDER BY year) * 100, 2) AS yoy_growth
FROM monthly_sales;

-- Running totals with window specification
SELECT transaction_date, amount,
       SUM(amount) OVER (ORDER BY transaction_date ROWS BETWEEN 29 PRECEDING AND CURRENT ROW) AS amt_30day
FROM transactions
ORDER BY transaction_date;
```

---

## Summary

**Topics Covered:**
- Window function fundamentals
- Ranking functions (ROW_NUMBER, RANK, DENSE_RANK, NTILE)
- Aggregate window functions
- Analytic functions (PERCENT_RANK, CUME_DIST)
- OVER clause and partitioning
- Frame specifications
- LAG and LEAD functions
- FIRST_VALUE and LAST_VALUE
- PIVOT and UNPIVOT operations
- Advanced analytics patterns

**Key Advantages:**
- No GROUP BY needed
- Preserves all original rows
- Enables running calculations
- Simplifies complex analysis
- Better performance than subqueries

**Estimated Study Time:** 8-10 hours
**Code Examples:** 80+
**Real-World Applications:** Analytics, reporting, comparisons

