# Oracle SQL Interview Questions

## Part 1: Fundamentals & Query Design (12 Questions)

### Q1: Explain the difference between UNION and UNION ALL

**Question:** When would you use UNION vs UNION ALL? Provide performance implications.

**Answer:**

```
UNION:
- Removes duplicate rows
- Performs DISTINCT operation
- Slower for large datasets
- Requires sorting

UNION ALL:
- Keeps all rows including duplicates
- No sorting overhead
- Faster execution
- Better performance with large datasets

Example:
-- UNION (removes duplicates)
SELECT dept_id FROM emp_2023
UNION
SELECT dept_id FROM emp_2024;

-- UNION ALL (keeps duplicates)
SELECT dept_id FROM emp_2023
UNION ALL
SELECT dept_id FROM emp_2024;

Rule of thumb:
- Use UNION ALL when duplicates don't matter
- Use UNION only when you need unique values
```

**Discussion Points:**
- Performance difference with millions of rows
- When to use each in different business scenarios
- Alternative using DISTINCT with UNION ALL
- Cost of duplicate elimination

---

### Q2: When to use EXISTS vs IN with subqueries?

**Answer:**

```
EXISTS:
- More efficient for large subqueries
- Returns as soon as one match found
- Better with correlated subqueries
- Handles NULL values correctly

IN:
- Better for small lists
- Less efficient with large subqueries
- Has issues with NULL values
- Predicate pushdown advantage with indexes

Example:
-- EXISTS (preferred for large datasets)
SELECT * FROM departments d
WHERE EXISTS (
    SELECT 1 FROM employees WHERE dept_id = d.dept_id
);

-- IN (problematic with NULLs)
SELECT * FROM departments d
WHERE dept_id IN (SELECT dept_id FROM employees);

-- Better: use NOT EXISTS instead of NOT IN
SELECT * FROM departments d
WHERE NOT EXISTS (
    SELECT 1 FROM employees WHERE dept_id = d.dept_id
);
```

---

### Q3: Explain NULL handling in SQL queries

**Answer:**

```
NULL Behavior:
- NULL is unknown, not zero or empty string
- NULL = NULL returns NULL, not TRUE
- NULL in comparisons returns NULL
- NULL in AND/OR uses three-valued logic

Example:
SELECT * FROM employees WHERE commission IS NULL;
SELECT * FROM employees WHERE salary + commission > 100000;
  -- Rows with NULL commission not returned

Three-valued logic:
NULL AND TRUE = NULL
NULL AND FALSE = FALSE
NULL OR TRUE = TRUE
NULL OR FALSE = NULL

Best practices:
- Always use IS NULL or IS NOT NULL
- Use NVL() or COALESCE() for default values
- Be aware of NULL in aggregates (ignored in SUM, COUNT, AVG)
```

---

### Q4: What is the difference between Cartesian product and JOIN?

**Answer:**

```
Cartesian Product (CROSS JOIN):
- Returns all combinations of rows
- No join condition
- Results in rows_table1 × rows_table2

Example:
SELECT * FROM emp CROSS JOIN dept;  -- 100 emp × 10 dept = 1000 rows

JOIN:
- Combines tables based on condition
- Returns only matching rows
- More predictable results

INNER JOIN: Only matching rows
LEFT JOIN: All from left + matching from right
FULL OUTER JOIN: All rows from both tables
```

---

### Q5: Explain execution plan and how to read EXPLAIN PLAN

**Answer:**

```
Execution Plan:
- Shows steps Oracle uses to execute query
- Helps identify performance bottlenecks
- Shows access methods (TABLE ACCESS FULL, INDEX RANGE SCAN)

Example:
EXPLAIN PLAN FOR
SELECT * FROM employees WHERE dept_id = 10;

SELECT PLAN_TABLE_OUTPUT FROM TABLE(DBMS_XPLAN.DISPLAY());

Reading plan:
- Indentation shows operation hierarchy
- Cost = estimated resource units
- Cardinality = estimated rows
- Bytes = estimated data size

Key operations:
TABLE ACCESS FULL: Scans all blocks (slow for large tables)
INDEX RANGE SCAN: Uses index (fast)
SORT: Sorts data (expensive)
NESTED LOOPS: Join method
HASH JOIN: Better for large joins
```

---

### Q6: When to use HAVING vs WHERE clause?

**Answer:**

```
WHERE:
- Filters rows BEFORE grouping
- Applied to individual rows
- Works with non-aggregated columns

HAVING:
- Filters groups AFTER grouping
- Applied to aggregated values
- Works with aggregate functions

Example:
SELECT dept_id, COUNT(*) as emp_count, AVG(salary)
FROM employees
WHERE salary > 50000        -- Filters before grouping
GROUP BY dept_id
HAVING COUNT(*) > 5         -- Filters after grouping
  AND AVG(salary) > 70000;  -- Can use aggregates
```

---

### Q7: Explain recursive CTEs and their use cases

**Answer:**

```
Recursive CTEs:
- Used for hierarchical data
- Employee-manager relationships
- Organization structures
- Navigating tree structures

Example:
WITH RECURSIVE emp_hierarchy AS (
    -- Base case: top managers
    SELECT emp_id, manager_id, name, 1 as level
    FROM employees
    WHERE manager_id IS NULL

    UNION ALL

    -- Recursive case: subordinates
    SELECT e.emp_id, e.manager_id, e.name, eh.level + 1
    FROM employees e
    JOIN emp_hierarchy eh ON e.manager_id = eh.emp_id
    WHERE eh.level < 10  -- Prevent infinite recursion
)
SELECT * FROM emp_hierarchy ORDER BY level;

Use cases:
- Organization charts
- Bill of materials
- Network traversal
- Hierarchical categories
```

---

### Q8-12: Additional Questions (Summary)

**Q8:** Explain partitioning and when to use it
- Range, List, Hash, Composite partitioning
- Partition pruning benefits
- Maintenance advantages

**Q9:** What are materialized views and when to use them?
- Difference from regular views
- Performance benefits
- Refresh strategies
- Query rewrite capability

**Q10:** Explain indexes and their overhead
- B-tree indexes
- Bitmap indexes
- Index overhead (space, INSERT/UPDATE/DELETE cost)
- When to avoid indexes

**Q11:** What is row chaining and how to avoid it?
- Causes of row chaining
- Performance impact
- Rebuild table solution

**Q12:** Explain database locks and isolation levels
- Row locks, table locks
- Deadlock prevention
- Isolation levels (READ UNCOMMITTED, READ COMMITTED, SERIALIZABLE)

---

## Part 2: Advanced Performance & Tuning (10 Questions)

### Q13: How to optimize slow queries?

**Answer:**

```
Query Optimization Steps:

1. Analyze with EXPLAIN PLAN
2. Check statistics (ANALYZE command)
3. Review indexes
4. Check execution plan cost
5. Rewrite query if needed

Common optimizations:
- Add indexes on WHERE columns
- Join on indexed columns
- Use INNER JOIN instead of OUTER when possible
- Avoid functions on indexed columns
- Use BETWEEN instead of OR for ranges
- Use IN with small lists
- Consider materialized views

Example:
-- Bad: Function prevents index usage
SELECT * FROM employees WHERE UPPER(last_name) = 'SMITH';

-- Good: Index can be used
SELECT * FROM employees WHERE last_name = 'SMITH';
```

---

### Q14-23: Additional Advanced Questions (Summary)

**Q14:** Explain full table scan vs index scan trade-offs
**Q15:** How to handle skewed data and histogram statistics?
**Q16:** Explain hints and when to use them
**Q17:** What is bind variable and why use them?
**Q18:** Explain parallel query execution
**Q19:** How to identify and resolve deadlocks?
**Q20:** Explain caching and buffer pool management
**Q21:** How to monitor and tune I/O operations?
**Q22:** Explain fragmentation and maintenance strategies

---

## Part 3: Real-World Scenarios (8 Questions)

### Q23: Design a fact/dimension table schema for sales data

**Answer:**

```
OLTP Schema vs OLAP Schema:

OLTP (Operational):
- Normalized (3NF)
- Many small tables
- Row-by-row operations
- Fast for transactions

OLAP (Analytical):
- Star/Snowflake schema
- Denormalized
- Fact and dimension tables
- Fast for aggregations

Example Star Schema:
Fact_Sales:
- sale_id (PK)
- date_id (FK)
- product_id (FK)
- customer_id (FK)
- amount

Dim_Date:
- date_id (PK)
- date, month, quarter, year

Dim_Product:
- product_id (PK)
- product_name, category, price

Benefits:
- Fast aggregate queries
- Easy to understand
- Good compression
```

---

### Q24-30: Additional Scenario Questions (Summary)

**Q24:** Design backup and recovery strategy
**Q25:** Handle large data migrations
**Q26:** Optimize data warehouse queries
**Q27:** Implement audit/compliance requirements
**Q28:** Design for high availability
**Q29:** Handle real-time data synchronization
**Q30:** Optimize batch processing jobs

---

## Coding Questions

### CQ1: Write query for salary increases with historical tracking

```sql
-- Track salary changes with effective dates
CREATE TABLE salary_history (
    emp_id NUMBER,
    salary NUMBER,
    effective_date DATE,
    PRIMARY KEY (emp_id, effective_date)
);

-- Query: Get current salary and % change from previous
SELECT
    emp_id,
    salary,
    effective_date,
    LAG(salary) OVER (PARTITION BY emp_id ORDER BY effective_date) as prev_salary,
    ROUND((salary - LAG(salary) OVER (PARTITION BY emp_id ORDER BY effective_date)) /
          LAG(salary) OVER (PARTITION BY emp_id ORDER BY effective_date) * 100, 2) as pct_change
FROM salary_history
WHERE effective_date = (SELECT MAX(effective_date) FROM salary_history WHERE emp_id = emp_id);
```

### CQ2: Find top products by sales across time periods

```sql
-- Using window functions for multi-period analysis
SELECT * FROM (
    SELECT
        product_id,
        quarter,
        sales,
        RANK() OVER (PARTITION BY quarter ORDER BY sales DESC) as rank_in_quarter,
        LAG(sales) OVER (PARTITION BY product_id ORDER BY quarter) as prev_quarter_sales
    FROM quarterly_sales
)
WHERE rank_in_quarter <= 10;
```

### CQ3-CQ10: Additional Coding Challenges (Summary)
- Complex JOIN scenarios with multiple conditions
- Recursive queries for organizational structures
- PIVOT operations for cross-tab reports
- Set operations for data consolidation
- Correlated subqueries for analytics
- Common table expressions for complex logic

---

## Best Practices Summary

✅ Always use EXPLAIN PLAN for query analysis
✅ Use indexes on frequently filtered columns
✅ Avoid functions on indexed columns
✅ Handle NULLs explicitly
✅ Use appropriate JOIN types
✅ Consider query rewrite options
✅ Monitor query performance regularly
✅ Keep statistics current
✅ Use bind variables for repeated queries
✅ Document complex business logic

---

**Interview Tips:**
- Explain your reasoning
- Discuss trade-offs
- Show knowledge of execution plans
- Mention performance considerations
- Provide real-world examples
- Ask clarifying questions

