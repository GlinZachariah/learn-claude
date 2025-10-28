# Advanced Queries & Subqueries in Oracle SQL

## Table of Contents
1. [Subquery Fundamentals](#subquery-fundamentals)
2. [Single-Row Subqueries](#single-row-subqueries)
3. [Multiple-Row Subqueries](#multiple-row-subqueries)
4. [Correlated Subqueries](#correlated-subqueries)
5. [Inline Views](#inline-views)
6. [EXISTS Operator](#exists-operator)
7. [Scalar Subqueries](#scalar-subqueries)
8. [Common Table Expressions (CTE)](#common-table-expressions-cte)
9. [HAVING Clause](#having-clause)
10. [Set Operations](#set-operations)
11. [Query Optimization](#query-optimization)
12. [Advanced Techniques](#advanced-techniques)

---

## 1. Subquery Fundamentals

Subqueries are queries nested within other queries, enabling complex data retrieval:

```sql
-- Basic subquery in WHERE clause
SELECT * FROM employees
WHERE salary > (
    SELECT AVG(salary) FROM employees
);

-- Subquery components
-- ┌─────────────────────────────┐
-- │ Outer Query (Main Query)    │
-- │  WHERE condition IN (       │
-- │    ┌──────────────────────┐ │
-- │    │ Subquery/Inner Query │ │
-- │    └──────────────────────┘ │
-- │  )                          │
-- └─────────────────────────────┘

-- Subquery advantages:
-- 1. Logical breakdown of complex queries
-- 2. Reusable query fragments
-- 3. Dynamic filtering based on data
-- 4. Easier to test and debug
```

---

## 2. Single-Row Subqueries

Single-row subqueries return exactly one row and one column:

```sql
-- Find employee with highest salary
SELECT employee_id, first_name, salary
FROM employees
WHERE salary = (SELECT MAX(salary) FROM employees);

-- Find employee earning above company average
SELECT employee_id, first_name, salary
FROM employees
WHERE salary > (SELECT AVG(salary) FROM employees)
ORDER BY salary DESC;

-- Find department of specific employee
SELECT *
FROM departments
WHERE department_id = (
    SELECT department_id FROM employees
    WHERE employee_id = 100
);

-- Nested single-row subqueries
SELECT employee_id, first_name, salary
FROM employees
WHERE salary > (
    SELECT AVG(salary)
    FROM employees
    WHERE department_id = (
        SELECT department_id FROM departments
        WHERE department_name = 'Sales'
    )
);

-- Single-row subquery with aggregate functions
SELECT department_id,
       COUNT(*) AS employee_count,
       (SELECT AVG(salary) FROM employees) AS avg_salary
FROM employees
GROUP BY department_id;
```

### Comparison Operators with Single-Row Subqueries

```sql
-- = operator
SELECT * FROM employees
WHERE job_id = (SELECT job_id FROM employees WHERE employee_id = 100);

-- > operator
SELECT * FROM employees
WHERE salary > (SELECT salary FROM employees WHERE employee_id = 100);

-- < operator
SELECT * FROM employees
WHERE hire_date < (SELECT hire_date FROM employees WHERE employee_id = 100);

-- != or <> operator
SELECT * FROM employees
WHERE department_id != (SELECT department_id FROM employees WHERE employee_id = 100);

-- >= operator
SELECT * FROM employees
WHERE salary >= (SELECT AVG(salary) FROM employees WHERE job_id = 'MANAGER');
```

---

## 3. Multiple-Row Subqueries

Multiple-row subqueries return multiple rows. Use IN, ANY, or ALL operators:

```sql
-- IN operator (returns TRUE if value matches ANY in list)
SELECT * FROM employees
WHERE department_id IN (
    SELECT department_id FROM departments
    WHERE location_id = 1700
);

-- NOT IN operator
SELECT * FROM employees
WHERE department_id NOT IN (
    SELECT department_id FROM departments
    WHERE location_id = 1700
);

-- ANY operator (returns TRUE if condition is TRUE for ANY row)
SELECT * FROM employees
WHERE salary > ANY (
    SELECT salary FROM employees
    WHERE job_id = 'CLERK'
);

-- ALL operator (returns TRUE if condition is TRUE for ALL rows)
SELECT * FROM employees
WHERE salary > ALL (
    SELECT salary FROM employees
    WHERE job_id = 'CLERK'
);

-- NOT ANY (equivalent to NOT IN)
SELECT * FROM employees
WHERE salary NOT > ANY (
    SELECT MIN(salary) FROM employees GROUP BY department_id
);
```

### IN vs ANY vs ALL

```sql
-- IN operator examples
-- Returns TRUE if salary matches any salary in list
SELECT * FROM employees
WHERE salary IN (SELECT salary FROM employees WHERE department_id = 10);

-- ANY operator examples
-- > ANY means > minimum value in list
SELECT * FROM employees
WHERE salary > ANY (SELECT salary FROM employees WHERE job_id = 'MANAGER');

-- >= ANY (same as IN with equality)
SELECT * FROM employees
WHERE salary >= ANY (SELECT salary FROM employees WHERE department_id = 20);

-- ALL operator examples
-- > ALL means > maximum value in list
SELECT * FROM employees
WHERE salary > ALL (SELECT salary FROM employees WHERE job_id = 'MANAGER');

-- < ALL means < minimum value in list
SELECT * FROM employees
WHERE salary < ALL (SELECT salary FROM employees WHERE department_id = 10);
```

---

## 4. Correlated Subqueries

Correlated subqueries reference columns from the outer query:

```sql
-- Find employees earning more than their department average
SELECT e.employee_id, e.first_name, e.salary, e.department_id
FROM employees e
WHERE e.salary > (
    SELECT AVG(salary)
    FROM employees
    WHERE department_id = e.department_id
);

-- Find employees with above-average commission in their department
SELECT e.employee_id, e.first_name, e.commission_pct
FROM employees e
WHERE e.commission_pct > (
    SELECT AVG(commission_pct)
    FROM employees
    WHERE department_id = e.department_id
      AND commission_pct IS NOT NULL
);

-- Count employees in each department
SELECT e.department_id,
       e.first_name,
       (SELECT COUNT(*) FROM employees WHERE department_id = e.department_id) AS dept_count
FROM employees e;

-- Find latest hire date per department
SELECT e.employee_id, e.first_name, e.hire_date, e.department_id
FROM employees e
WHERE e.hire_date = (
    SELECT MAX(hire_date)
    FROM employees
    WHERE department_id = e.department_id
);

-- Correlated UPDATE
UPDATE employees e
SET salary = salary * 1.10
WHERE department_id = (
    SELECT department_id FROM departments
    WHERE department_id = e.department_id
      AND budget > 100000
);

-- Correlated DELETE
DELETE FROM employees e
WHERE salary < (
    SELECT AVG(salary) * 0.8
    FROM employees
    WHERE department_id = e.department_id
);
```

### Correlated Subquery Performance Considerations

```sql
-- ❌ INEFFICIENT: Correlated subquery executed for every row
SELECT e.employee_id, e.first_name, e.salary
FROM employees e
WHERE e.salary > (
    SELECT AVG(salary) FROM employees WHERE department_id = e.department_id
);

-- ✅ EFFICIENT: Join approach
SELECT e.employee_id, e.first_name, e.salary
FROM employees e
JOIN (
    SELECT department_id, AVG(salary) AS avg_sal
    FROM employees
    GROUP BY department_id
) avg_sal ON e.department_id = avg_sal.department_id
WHERE e.salary > avg_sal.avg_sal;
```

---

## 5. Inline Views

Inline views (derived tables) are subqueries in the FROM clause:

```sql
-- Basic inline view
SELECT * FROM (
    SELECT employee_id, first_name, salary
    FROM employees
    WHERE department_id = 10
) WHERE salary > 50000;

-- Named inline view
SELECT * FROM (
    SELECT employee_id,
           first_name,
           salary,
           ROW_NUMBER() OVER (ORDER BY salary DESC) AS salary_rank
    FROM employees
    WHERE department_id = 10
) ranked_employees
WHERE salary_rank <= 5;

-- Multiple inline views
SELECT e.employee_id, e.first_name, e.salary, d.avg_salary
FROM employees e
JOIN (
    SELECT department_id, AVG(salary) AS avg_salary
    FROM employees
    GROUP BY department_id
) d ON e.department_id = d.department_id;

-- Inline view with aggregation
SELECT department_id, avg_salary, emp_count
FROM (
    SELECT department_id,
           AVG(salary) AS avg_salary,
           COUNT(*) AS emp_count
    FROM employees
    GROUP BY department_id
)
WHERE avg_salary > 60000;

-- Complex inline view
SELECT dept_name,
       avg_salary,
       total_employees,
       salary_ratio
FROM (
    SELECT d.department_name AS dept_name,
           AVG(e.salary) AS avg_salary,
           COUNT(e.employee_id) AS total_employees,
           AVG(e.salary) / (SELECT AVG(salary) FROM employees) AS salary_ratio
    FROM departments d
    LEFT JOIN employees e ON d.department_id = e.department_id
    GROUP BY d.department_id, d.department_name
)
WHERE avg_salary IS NOT NULL
ORDER BY avg_salary DESC;
```

---

## 6. EXISTS Operator

EXISTS checks for existence of rows, returning TRUE or FALSE:

```sql
-- Find departments with employees
SELECT * FROM departments d
WHERE EXISTS (
    SELECT 1 FROM employees e
    WHERE e.department_id = d.department_id
);

-- NOT EXISTS - Find departments without employees
SELECT * FROM departments d
WHERE NOT EXISTS (
    SELECT 1 FROM employees e
    WHERE e.department_id = d.department_id
);

-- EXISTS with multiple conditions
SELECT * FROM departments d
WHERE EXISTS (
    SELECT 1 FROM employees e
    WHERE e.department_id = d.department_id
      AND e.salary > 100000
);

-- EXISTS in UPDATE
UPDATE employees e
SET salary = salary * 1.05
WHERE EXISTS (
    SELECT 1 FROM departments d
    WHERE d.department_id = e.department_id
      AND d.budget > 500000
);

-- EXISTS in DELETE
DELETE FROM employees e
WHERE NOT EXISTS (
    SELECT 1 FROM departments d
    WHERE d.department_id = e.department_id
);

-- EXISTS with aggregation
SELECT e.* FROM employees e
WHERE EXISTS (
    SELECT 1 FROM employees
    WHERE department_id = e.department_id
    GROUP BY department_id
    HAVING COUNT(*) > 5
);
```

### EXISTS vs IN Performance

```sql
-- EXISTS is generally faster for large datasets
SELECT * FROM departments d
WHERE EXISTS (
    SELECT 1 FROM employees e
    WHERE e.department_id = d.department_id
);

-- IN can be inefficient with large subqueries
SELECT * FROM departments d
WHERE department_id IN (
    SELECT department_id FROM employees
);

-- Anti-join pattern (NOT EXISTS faster than NOT IN)
SELECT * FROM departments d
WHERE NOT EXISTS (
    SELECT 1 FROM employees e
    WHERE e.department_id = d.department_id
);
```

---

## 7. Scalar Subqueries

Scalar subqueries return a single value and can appear in SELECT list:

```sql
-- Scalar subquery in SELECT list
SELECT employee_id,
       first_name,
       salary,
       (SELECT AVG(salary) FROM employees) AS company_avg,
       salary - (SELECT AVG(salary) FROM employees) AS diff_from_avg
FROM employees;

-- Multiple scalar subqueries
SELECT e.employee_id,
       e.first_name,
       e.salary,
       (SELECT department_name FROM departments WHERE department_id = e.department_id) AS dept_name,
       (SELECT COUNT(*) FROM employees WHERE department_id = e.department_id) AS dept_emp_count,
       (SELECT MAX(salary) FROM employees WHERE department_id = e.department_id) AS dept_max_salary
FROM employees e;

-- Scalar subquery with CASE
SELECT employee_id,
       first_name,
       salary,
       CASE
           WHEN salary > (SELECT AVG(salary) FROM employees) THEN 'Above Average'
           ELSE 'Below Average'
       END AS salary_status
FROM employees;

-- Scalar subquery in WHERE with expression
SELECT * FROM employees
WHERE salary > (
    SELECT AVG(salary) FROM employees WHERE job_id = 'MANAGER'
) * 0.9;
```

---

## 8. Common Table Expressions (CTE)

CTEs (WITH clause) improve readability and reusability:

```sql
-- Basic CTE
WITH high_earners AS (
    SELECT employee_id, first_name, salary
    FROM employees
    WHERE salary > 100000
)
SELECT * FROM high_earners
WHERE first_name LIKE 'J%';

-- Multiple CTEs
WITH dept_avg AS (
    SELECT department_id, AVG(salary) AS avg_sal
    FROM employees
    GROUP BY department_id
),
high_earners AS (
    SELECT e.employee_id, e.first_name, e.salary, d.avg_sal
    FROM employees e
    JOIN dept_avg d ON e.department_id = d.department_id
    WHERE e.salary > d.avg_sal
)
SELECT * FROM high_earners ORDER BY salary DESC;

-- Recursive CTE (tree/hierarchy traversal)
WITH RECURSIVE employee_hierarchy AS (
    -- Base case: top-level managers
    SELECT employee_id, first_name, manager_id, 1 AS level
    FROM employees
    WHERE manager_id IS NULL

    UNION ALL

    -- Recursive case: subordinates
    SELECT e.employee_id, e.first_name, e.manager_id, eh.level + 1
    FROM employees e
    JOIN employee_hierarchy eh ON e.manager_id = eh.employee_id
)
SELECT * FROM employee_hierarchy ORDER BY level, employee_id;

-- CTE for hierarchical data
WITH RECURSIVE org_chart AS (
    SELECT employee_id, first_name, manager_id, 1 AS hierarchy_level,
           first_name AS org_path
    FROM employees
    WHERE manager_id IS NULL

    UNION ALL

    SELECT e.employee_id, e.first_name, e.manager_id,
           oc.hierarchy_level + 1,
           oc.org_path || ' -> ' || e.first_name
    FROM employees e
    JOIN org_chart oc ON e.manager_id = oc.employee_id
)
SELECT * FROM org_chart ORDER BY hierarchy_level;

-- CTE with aggregation
WITH salary_ranges AS (
    SELECT
        CASE
            WHEN salary < 50000 THEN 'Low'
            WHEN salary < 100000 THEN 'Medium'
            ELSE 'High'
        END AS salary_range,
        COUNT(*) AS emp_count,
        AVG(salary) AS avg_salary,
        MIN(salary) AS min_salary,
        MAX(salary) AS max_salary
    FROM employees
    GROUP BY CASE
        WHEN salary < 50000 THEN 'Low'
        WHEN salary < 100000 THEN 'Medium'
        ELSE 'High'
    END
)
SELECT * FROM salary_ranges ORDER BY avg_salary;
```

---

## 9. HAVING Clause

HAVING filters grouped data (applies after GROUP BY):

```sql
-- Basic HAVING
SELECT department_id, COUNT(*) AS emp_count, AVG(salary) AS avg_salary
FROM employees
GROUP BY department_id
HAVING COUNT(*) > 5;

-- HAVING with multiple conditions
SELECT department_id, COUNT(*) AS emp_count, AVG(salary) AS avg_salary
FROM employees
GROUP BY department_id
HAVING COUNT(*) > 5 AND AVG(salary) > 60000;

-- HAVING with subquery
SELECT department_id, COUNT(*) AS emp_count
FROM employees
GROUP BY department_id
HAVING COUNT(*) > (SELECT AVG(emp_count) FROM (
    SELECT COUNT(*) AS emp_count FROM employees GROUP BY department_id
));

-- HAVING with aggregate functions
SELECT job_id, COUNT(*) AS emp_count, SUM(salary) AS total_salary
FROM employees
GROUP BY job_id
HAVING SUM(salary) > 500000
ORDER BY total_salary DESC;

-- WHERE vs HAVING
-- WHERE filters rows before grouping
-- HAVING filters groups after grouping
SELECT department_id, COUNT(*) AS emp_count
FROM employees
WHERE salary > 50000  -- Filters before grouping
GROUP BY department_id
HAVING COUNT(*) > 3   -- Filters after grouping
ORDER BY emp_count DESC;
```

---

## 10. Set Operations

Set operations combine results from multiple queries:

```sql
-- UNION (removes duplicates)
SELECT employee_id, first_name FROM employees WHERE department_id = 10
UNION
SELECT employee_id, first_name FROM employees WHERE salary > 100000
ORDER BY employee_id;

-- UNION ALL (keeps duplicates)
SELECT employee_id, first_name FROM employees WHERE department_id = 10
UNION ALL
SELECT employee_id, first_name FROM employees WHERE salary > 100000
ORDER BY employee_id;

-- INTERSECT (only common rows)
SELECT employee_id, first_name FROM employees WHERE department_id = 10
INTERSECT
SELECT employee_id, first_name FROM employees WHERE salary > 75000;

-- MINUS/EXCEPT (rows in first query but not second)
SELECT employee_id, first_name FROM employees WHERE department_id = 10
MINUS
SELECT employee_id, first_name FROM employees WHERE salary < 50000;

-- Complex UNION with aggregation
SELECT 'Department Average' AS salary_type, department_id, AVG(salary) AS salary
FROM employees
GROUP BY department_id
UNION
SELECT 'Job Type Average' AS salary_type, job_id, AVG(salary) AS salary
FROM employees
GROUP BY job_id
ORDER BY salary_type, salary DESC;
```

---

## 11. Query Optimization

Best practices for optimized queries:

```sql
-- ✅ Use indexes on WHERE columns
-- ✅ Avoid functions on indexed columns
SELECT * FROM employees WHERE salary > 50000;  -- Good
SELECT * FROM employees WHERE UPPER(last_name) = 'SMITH';  -- Bad (function on column)

-- ✅ Use INNER JOIN for better performance than subquery
SELECT e.* FROM employees e
JOIN departments d ON e.department_id = d.department_id
WHERE d.location_id = 1700;

-- ✅ Use EXISTS instead of COUNT for existence checks
SELECT * FROM departments d
WHERE EXISTS (SELECT 1 FROM employees WHERE department_id = d.department_id);

-- ❌ Avoid SELECT *
SELECT employee_id, first_name FROM employees;  -- Good
SELECT * FROM employees;  -- Bad (retrieves unnecessary columns)

-- ✅ Use specific aggregate functions
SELECT COUNT(*) FROM employees;  -- Good
SELECT COUNT(1) FROM employees;  -- Also good
```

---

## 12. Advanced Techniques

```sql
-- Pivot queries (horizontal presentation)
SELECT * FROM (
    SELECT job_id, department_id, salary FROM employees
)
PIVOT (
    AVG(salary) FOR job_id IN ('ANALYST', 'CLERK', 'MANAGER')
);

-- Lateral inline views (Oracle 12c+)
SELECT e.employee_id, e.first_name, t.salary
FROM employees e,
LATERAL (
    SELECT salary FROM employees WHERE department_id = e.department_id
    ORDER BY salary DESC FETCH FIRST 3 ROWS ONLY
) t;

-- WITH clause for query factoring
WITH RECURSIVE nums AS (
    SELECT 1 AS n FROM dual
    UNION ALL
    SELECT n + 1 FROM nums WHERE n < 10
)
SELECT * FROM nums;
```

---

## Summary

**Topics Covered:**
- Single and multiple-row subqueries
- Correlated subqueries and performance
- Inline views and derived tables
- EXISTS and NOT EXISTS operators
- Scalar subqueries in SELECT
- Common Table Expressions (CTE)
- Recursive CTEs for hierarchies
- Set operations (UNION, INTERSECT, MINUS)
- HAVING clause for group filtering
- Query optimization techniques

**Estimated Study Time:** 8-10 hours
**Code Examples:** 70+
**Practical Applications:** Real-world query patterns

