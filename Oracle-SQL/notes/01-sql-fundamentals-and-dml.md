# Oracle SQL Fundamentals & Data Manipulation Language

## Table of Contents
1. [SQL Architecture](#sql-architecture)
2. [SELECT Statement](#select-statement)
3. [WHERE Clause & Filtering](#where-clause--filtering)
4. [ORDER BY & DISTINCT](#order-by--distinct)
5. [INSERT Statement](#insert-statement)
6. [UPDATE Statement](#update-statement)
7. [DELETE Statement](#delete-statement)
8. [MERGE Statement](#merge-statement)
9. [Data Types](#data-types)
10. [Constraints](#constraints)
11. [Table Operations](#table-operations)
12. [NULL Handling](#null-handling)
13. [TRUNCATE vs DELETE](#truncate-vs-delete)
14. [Transactions & COMMIT/ROLLBACK](#transactions--commitrollback)
15. [Best Practices](#best-practices)

---

## 1. SQL Architecture

Oracle SQL operates on a client-server architecture with multiple layers:

```
┌─────────────────────────────────────────┐
│         SQL Query                        │
├─────────────────────────────────────────┤
│    Parser (Syntax Check)                 │
│    Translator (Semantic Check)           │
│    Optimizer (Query Plan)                │
│    Compiler (Bytecode Generation)        │
├─────────────────────────────────────────┤
│    Execution Engine                      │
├─────────────────────────────────────────┤
│    Database Storage Engine               │
└─────────────────────────────────────────┘
```

### Query Processing Steps

```sql
-- Step 1: Parsing - Checks syntax
SELECT * FROM employees WHERE salary > 50000;

-- Step 2: Validation - Checks table/column existence
-- Step 3: Compilation - Creates executable form
-- Step 4: Optimization - Determines most efficient plan
-- Step 5: Execution - Runs the query
-- Step 6: Fetching - Returns results
```

---

## 2. SELECT Statement

### Basic SELECT Syntax

```sql
-- Simple SELECT with all columns
SELECT * FROM employees;

-- SELECT specific columns
SELECT employee_id, first_name, last_name, salary
FROM employees;

-- SELECT with aliases
SELECT employee_id AS emp_id,
       first_name AS fname,
       salary AS monthly_salary
FROM employees;

-- SELECT with expressions
SELECT employee_id,
       first_name,
       salary,
       salary * 12 AS annual_salary,
       salary * 0.15 AS tax_amount,
       salary * 0.85 AS net_salary
FROM employees;

-- SELECT with string concatenation
SELECT employee_id,
       CONCAT(first_name, ' ', last_name) AS full_name,
       first_name || ' ' || last_name AS full_name_operator
FROM employees;

-- SELECT with CASE expression
SELECT employee_id,
       first_name,
       salary,
       CASE
           WHEN salary >= 10000 THEN 'High'
           WHEN salary >= 5000 THEN 'Medium'
           ELSE 'Low'
       END AS salary_grade
FROM employees;

-- SELECT with column calculation and rounding
SELECT product_id,
       product_name,
       unit_price,
       quantity_in_stock,
       unit_price * quantity_in_stock AS inventory_value,
       ROUND(unit_price * quantity_in_stock, 2) AS rounded_value
FROM products;
```

### SELECT with LIMIT (Oracle 12c+)

```sql
-- Get top 10 employees
SELECT employee_id, first_name, salary
FROM employees
ORDER BY salary DESC
FETCH FIRST 10 ROWS ONLY;

-- Get top 10 with ties
SELECT employee_id, first_name, salary
FROM employees
ORDER BY salary DESC
FETCH FIRST 10 ROWS WITH TIES;

-- Get top 10% of employees
SELECT employee_id, first_name, salary
FROM employees
ORDER BY salary DESC
FETCH FIRST 10 PERCENT ROWS ONLY;

-- Get rows between offset
SELECT employee_id, first_name, salary
FROM employees
ORDER BY employee_id
OFFSET 10 ROWS
FETCH NEXT 20 ROWS ONLY;
```

### SELECT with DISTINCT

```sql
-- Find unique departments
SELECT DISTINCT department_id
FROM employees;

-- Find unique combinations
SELECT DISTINCT department_id, job_id
FROM employees
ORDER BY department_id, job_id;

-- Count unique values
SELECT COUNT(DISTINCT department_id) AS unique_departments
FROM employees;
```

---

## 3. WHERE Clause & Filtering

### Comparison Operators

```sql
-- Equal to
SELECT * FROM employees WHERE department_id = 10;

-- Not equal
SELECT * FROM employees WHERE department_id != 10;
SELECT * FROM employees WHERE department_id <> 10;

-- Greater than, Less than
SELECT * FROM employees WHERE salary > 50000;
SELECT * FROM employees WHERE hire_date < '2020-01-01';

-- Greater than or equal, Less than or equal
SELECT * FROM employees WHERE salary >= 50000;
SELECT * FROM employees WHERE salary <= 100000;

-- Range check
SELECT * FROM employees WHERE salary BETWEEN 50000 AND 100000;
SELECT * FROM employees WHERE hire_date BETWEEN '2020-01-01' AND '2023-12-31';
```

### Logical Operators

```sql
-- AND condition
SELECT * FROM employees
WHERE department_id = 10 AND salary > 50000;

-- OR condition
SELECT * FROM employees
WHERE department_id = 10 OR department_id = 20;

-- NOT condition
SELECT * FROM employees
WHERE NOT (department_id = 10);

-- Complex conditions
SELECT * FROM employees
WHERE (department_id = 10 OR department_id = 20)
  AND salary > 50000
  AND NOT (job_id = 'CLERK');
```

### IN and NOT IN

```sql
-- IN operator
SELECT * FROM employees
WHERE department_id IN (10, 20, 30);

-- NOT IN operator
SELECT * FROM employees
WHERE department_id NOT IN (10, 20, 30);

-- IN with subquery
SELECT * FROM employees
WHERE department_id IN (
    SELECT department_id FROM departments WHERE location_id = 1700
);
```

### LIKE Pattern Matching

```sql
-- Starts with 'John'
SELECT * FROM employees WHERE first_name LIKE 'John%';

-- Ends with 'son'
SELECT * FROM employees WHERE first_name LIKE '%son';

-- Contains 'oh'
SELECT * FROM employees WHERE first_name LIKE '%oh%';

-- Exact 4 characters starting with 'J'
SELECT * FROM employees WHERE first_name LIKE 'J___';

-- Case insensitive search
SELECT * FROM employees
WHERE UPPER(first_name) LIKE 'JOHN%';

-- Escape special characters
SELECT * FROM products WHERE product_name LIKE '%\_%' ESCAPE '\';
```

### IS NULL and IS NOT NULL

```sql
-- Find NULL values
SELECT * FROM employees WHERE manager_id IS NULL;

-- Find non-NULL values
SELECT * FROM employees WHERE commission_pct IS NOT NULL;

-- Complex NULL handling
SELECT employee_id, first_name, commission_pct,
       CASE WHEN commission_pct IS NULL THEN 'No Commission'
            ELSE 'Has Commission'
       END AS commission_status
FROM employees;
```

---

## 4. ORDER BY & DISTINCT

### ORDER BY Fundamentals

```sql
-- Sort ascending (default)
SELECT employee_id, first_name, salary
FROM employees
ORDER BY salary;

-- Sort descending
SELECT employee_id, first_name, salary
FROM employees
ORDER BY salary DESC;

-- Sort by multiple columns
SELECT employee_id, first_name, department_id, salary
FROM employees
ORDER BY department_id ASC, salary DESC;

-- Sort by column position
SELECT employee_id, first_name, salary
FROM employees
ORDER BY 3 DESC;

-- Sort by expression
SELECT employee_id, first_name, salary * 12 AS annual_salary
FROM employees
ORDER BY salary * 12 DESC;

-- Sort with NULLS FIRST/LAST
SELECT employee_id, first_name, commission_pct
FROM employees
ORDER BY commission_pct DESC NULLS FIRST;

SELECT employee_id, first_name, commission_pct
FROM employees
ORDER BY commission_pct ASC NULLS LAST;
```

---

## 5. INSERT Statement

### Basic INSERT

```sql
-- Insert all columns
INSERT INTO employees
VALUES (9999, 'John', 'Doe', 'john.doe@example.com', '555-1234',
        '2024-01-15', 'SOFTWARE_ENGINEER', 75000, 0.1, 100, 10);

-- Insert specific columns
INSERT INTO employees (employee_id, first_name, last_name, hire_date, department_id)
VALUES (9999, 'John', 'Doe', '2024-01-15', 10);

-- Insert with expressions
INSERT INTO employees (employee_id, first_name, last_name, hire_date, salary, department_id)
VALUES (9999, UPPER('john'), LOWER('DOE'), SYSDATE, 75000, 10);

-- Insert multiple rows (Oracle 9i+)
INSERT ALL
    INTO employees (employee_id, first_name, last_name, salary, department_id)
         VALUES (9999, 'John', 'Doe', 75000, 10)
    INTO employees (employee_id, first_name, last_name, salary, department_id)
         VALUES (9998, 'Jane', 'Smith', 80000, 20)
    INTO employees (employee_id, first_name, last_name, salary, department_id)
         VALUES (9997, 'Bob', 'Johnson', 70000, 30)
SELECT * FROM dual;

-- Insert with subquery
INSERT INTO employees_backup
SELECT * FROM employees WHERE department_id = 10;

-- Insert with conditional logic
INSERT INTO employees_archive
SELECT * FROM employees
WHERE hire_date < '2015-01-01';
```

---

## 6. UPDATE Statement

### Basic UPDATE

```sql
-- Update single column
UPDATE employees SET salary = 85000 WHERE employee_id = 9999;

-- Update multiple columns
UPDATE employees
SET salary = 85000,
    commission_pct = 0.15
WHERE employee_id = 9999;

-- Update with expression
UPDATE employees
SET salary = salary * 1.10
WHERE department_id = 10;

-- Update with subquery
UPDATE employees
SET salary = (SELECT AVG(salary) FROM employees WHERE department_id = 20)
WHERE department_id = 10;

-- Update with CASE
UPDATE employees
SET salary = CASE
                WHEN job_id = 'MANAGER' THEN salary * 1.15
                WHEN job_id = 'CLERK' THEN salary * 1.05
                ELSE salary * 1.10
             END
WHERE department_id = 10;

-- Update with JOIN (12c+)
UPDATE employees e
SET e.salary = (
    SELECT AVG(salary) FROM employees WHERE department_id = e.department_id
)
WHERE EXISTS (
    SELECT 1 FROM departments d WHERE d.department_id = e.department_id
);
```

---

## 7. DELETE Statement

### Basic DELETE

```sql
-- Delete specific rows
DELETE FROM employees WHERE employee_id = 9999;

-- Delete with complex condition
DELETE FROM employees
WHERE department_id = 10 AND salary < 50000;

-- Delete all rows from table (use with caution)
DELETE FROM employees;

-- Delete with subquery
DELETE FROM employees
WHERE department_id IN (
    SELECT department_id FROM departments
    WHERE location_id NOT IN (1700, 1800)
);

-- Delete with NOT EXISTS
DELETE FROM employees e
WHERE NOT EXISTS (
    SELECT 1 FROM departments d
    WHERE d.department_id = e.department_id
);

-- Conditional DELETE
DELETE FROM employees
WHERE EXTRACT(YEAR FROM hire_date) < 2000
  AND salary < 30000;
```

---

## 8. MERGE Statement

MERGE is useful for insert-if-not-exists or update-if-exists logic:

```sql
-- Basic MERGE
MERGE INTO employees e
USING employees_staging es
ON (e.employee_id = es.employee_id)
WHEN MATCHED THEN
    UPDATE SET e.salary = es.salary, e.last_update = SYSDATE
WHEN NOT MATCHED THEN
    INSERT (employee_id, first_name, last_name, salary, last_update)
    VALUES (es.employee_id, es.first_name, es.last_name, es.salary, SYSDATE);

-- MERGE with DELETE
MERGE INTO employees e
USING employees_staging es
ON (e.employee_id = es.employee_id)
WHEN MATCHED THEN
    UPDATE SET e.salary = es.salary
    DELETE WHERE e.salary < 20000
WHEN NOT MATCHED THEN
    INSERT (employee_id, first_name, last_name, salary)
    VALUES (es.employee_id, es.first_name, es.last_name, es.salary);

-- MERGE with conditions
MERGE INTO employees e
USING employees_staging es
ON (e.employee_id = es.employee_id)
WHEN MATCHED AND es.salary IS NOT NULL THEN
    UPDATE SET e.salary = es.salary
WHEN MATCHED AND es.salary IS NULL THEN
    DELETE
WHEN NOT MATCHED AND es.active = 'Y' THEN
    INSERT (employee_id, first_name, last_name, salary)
    VALUES (es.employee_id, es.first_name, es.last_name, es.salary);
```

---

## 9. Data Types

### Numeric Data Types

```sql
-- NUMBER(precision, scale)
-- precision: total digits, scale: digits after decimal
NUMBER(10,2)     -- Max 12345678.90
NUMBER(5)        -- Integer up to 99999
NUMBER(10)       -- Integer up to 9999999999

-- BINARY_FLOAT and BINARY_DOUBLE (IEEE 754)
BINARY_FLOAT     -- Single precision (32-bit)
BINARY_DOUBLE    -- Double precision (64-bit)

-- Example table
CREATE TABLE financial_data (
    transaction_id NUMBER(10),
    amount NUMBER(15,2),
    interest_rate BINARY_DOUBLE,
    quantity BINARY_FLOAT
);
```

### Character Data Types

```sql
-- VARCHAR2(size) - variable length, max 4000 bytes
-- CHAR(size) - fixed length, max 2000 bytes
-- NVARCHAR2(size) - Unicode variable length
-- NCHAR(size) - Unicode fixed length

CREATE TABLE employees (
    employee_id NUMBER(6),
    first_name VARCHAR2(20),      -- Variable length
    last_name VARCHAR2(25),       -- Variable length
    email CHAR(30),               -- Fixed length
    phone_number NVARCHAR2(20)    -- Unicode support
);

-- Character comparison
SELECT * FROM employees
WHERE last_name = 'Smith';  -- CHAR comparison is padded
```

### Date & Time Data Types

```sql
-- DATE - Year, Month, Day, Hour, Minute, Second
-- TIMESTAMP - DATE + fractional seconds
-- TIMESTAMP WITH TIME ZONE
-- TIMESTAMP WITH LOCAL TIME ZONE
-- INTERVAL YEAR TO MONTH
-- INTERVAL DAY TO SECOND

CREATE TABLE events (
    event_id NUMBER(6),
    event_date DATE,
    event_timestamp TIMESTAMP,
    event_tz TIMESTAMP WITH TIME ZONE,
    event_duration INTERVAL DAY TO SECOND
);

-- Date examples
INSERT INTO events VALUES (
    1,
    '15-JAN-2024',
    '15-JAN-2024 10:30:45.123',
    '15-JAN-2024 10:30:45.123 -05:00',
    INTERVAL '5' DAY
);
```

### LOB Data Types

```sql
-- BLOB - Binary Large Object (binary data)
-- CLOB - Character Large Object (text)
-- NCLOB - National Character Large Object (Unicode)
-- BFILE - Binary file (external)

CREATE TABLE documents (
    document_id NUMBER(6),
    document_name VARCHAR2(100),
    document_content CLOB,        -- Text content
    document_file BLOB,           -- Binary content (images, PDFs)
    external_file BFILE           -- Reference to OS file
);
```

---

## 10. Constraints

### PRIMARY KEY

```sql
-- Single column primary key
CREATE TABLE employees (
    employee_id NUMBER(6) PRIMARY KEY,
    first_name VARCHAR2(20),
    last_name VARCHAR2(25)
);

-- Multi-column primary key
CREATE TABLE employee_projects (
    employee_id NUMBER(6),
    project_id NUMBER(6),
    PRIMARY KEY (employee_id, project_id)
);

-- Named constraint
CREATE TABLE departments (
    department_id NUMBER(6),
    department_name VARCHAR2(30),
    CONSTRAINT pk_departments PRIMARY KEY (department_id)
);
```

### FOREIGN KEY

```sql
CREATE TABLE employees (
    employee_id NUMBER(6) PRIMARY KEY,
    first_name VARCHAR2(20),
    department_id NUMBER(6),
    CONSTRAINT fk_emp_dept FOREIGN KEY (department_id)
    REFERENCES departments(department_id)
);

-- With cascade delete
CREATE TABLE employee_assignments (
    assignment_id NUMBER(6) PRIMARY KEY,
    employee_id NUMBER(6),
    project_id NUMBER(6),
    CONSTRAINT fk_assign_emp FOREIGN KEY (employee_id)
    REFERENCES employees(employee_id)
    ON DELETE CASCADE
);

-- With cascade update
CONSTRAINT fk_assign_proj FOREIGN KEY (project_id)
REFERENCES projects(project_id)
ON DELETE SET NULL
```

### UNIQUE Constraint

```sql
CREATE TABLE employees (
    employee_id NUMBER(6) PRIMARY KEY,
    email VARCHAR2(100) UNIQUE,
    social_security_number VARCHAR2(11) UNIQUE,
    CONSTRAINT uk_email UNIQUE (email)
);
```

### CHECK Constraint

```sql
CREATE TABLE employees (
    employee_id NUMBER(6) PRIMARY KEY,
    first_name VARCHAR2(20),
    salary NUMBER(10,2),
    commission_pct NUMBER(3,2),
    hire_date DATE,
    CONSTRAINT chk_salary CHECK (salary > 0),
    CONSTRAINT chk_commission CHECK (commission_pct BETWEEN 0 AND 1),
    CONSTRAINT chk_hire_date CHECK (hire_date <= SYSDATE)
);
```

### NOT NULL Constraint

```sql
CREATE TABLE employees (
    employee_id NUMBER(6) PRIMARY KEY,
    first_name VARCHAR2(20) NOT NULL,
    last_name VARCHAR2(25) NOT NULL,
    email VARCHAR2(100) NOT NULL,
    hire_date DATE NOT NULL,
    salary NUMBER(10,2) NOT NULL
);
```

### DEFAULT Values

```sql
CREATE TABLE employees (
    employee_id NUMBER(6) PRIMARY KEY,
    first_name VARCHAR2(20) NOT NULL,
    hire_date DATE DEFAULT SYSDATE,
    active_flag CHAR(1) DEFAULT 'Y',
    created_date TIMESTAMP DEFAULT SYSTIMESTAMP,
    commission_pct NUMBER(3,2) DEFAULT 0
);
```

---

## 11. Table Operations

### CREATE TABLE

```sql
-- Basic table creation
CREATE TABLE employees (
    employee_id NUMBER(6) PRIMARY KEY,
    first_name VARCHAR2(20) NOT NULL,
    last_name VARCHAR2(25) NOT NULL,
    email VARCHAR2(100) UNIQUE NOT NULL,
    phone_number VARCHAR2(20),
    hire_date DATE NOT NULL,
    job_id VARCHAR2(10),
    salary NUMBER(10,2),
    commission_pct NUMBER(3,2),
    manager_id NUMBER(6),
    department_id NUMBER(6) NOT NULL,
    created_date TIMESTAMP DEFAULT SYSTIMESTAMP,
    CONSTRAINT chk_salary CHECK (salary > 0),
    CONSTRAINT fk_emp_mgr FOREIGN KEY (manager_id) REFERENCES employees(employee_id),
    CONSTRAINT fk_emp_dept FOREIGN KEY (department_id) REFERENCES departments(department_id)
);

-- Create table as SELECT (CTAS)
CREATE TABLE employees_backup AS
SELECT * FROM employees WHERE department_id = 10;

-- CTAS with WHERE FALSE (structure only)
CREATE TABLE employees_empty AS
SELECT * FROM employees WHERE 1=0;
```

### ALTER TABLE

```sql
-- Add column
ALTER TABLE employees ADD (age NUMBER(3));

-- Add multiple columns
ALTER TABLE employees ADD (
    country_id NUMBER(6),
    city VARCHAR2(30)
);

-- Modify column
ALTER TABLE employees MODIFY (first_name VARCHAR2(50));

-- Add constraint
ALTER TABLE employees ADD CONSTRAINT chk_age CHECK (age >= 18);

-- Rename column (12c+)
ALTER TABLE employees RENAME COLUMN phone_number TO contact_number;

-- Drop column
ALTER TABLE employees DROP COLUMN age;

-- Set unused then drop (for large tables)
ALTER TABLE employees SET UNUSED COLUMN age;
ALTER TABLE employees DROP UNUSED COLUMNS;
```

### DROP TABLE

```sql
-- Drop table with data
DROP TABLE employees;

-- Drop with cascading constraints
DROP TABLE departments CASCADE CONSTRAINTS;

-- Drop and don't wait for locks
DROP TABLE employees PURGE;
```

### RENAME TABLE

```sql
RENAME employees TO employees_old;
RENAME employees_new TO employees;
```

---

## 12. NULL Handling

### NULL Semantics

```sql
-- NULL is not equal to anything, including itself
SELECT * FROM employees WHERE commission_pct = NULL;  -- Returns 0 rows

-- Correct NULL comparison
SELECT * FROM employees WHERE commission_pct IS NULL;

-- NULL in arithmetic operations
SELECT employee_id, salary, commission_pct,
       salary + commission_pct AS result  -- Result is NULL
FROM employees;

-- NVL function
SELECT employee_id, salary, commission_pct,
       NVL(commission_pct, 0) AS commission_default
FROM employees;

-- NVL2 function
SELECT employee_id,
       NVL2(commission_pct, salary * commission_pct, 0) AS commission_amount
FROM employees;

-- COALESCE function (returns first non-null)
SELECT employee_id,
       COALESCE(commission_pct, bonus_amount, 0) AS total_bonus
FROM employees;

-- NULLIF function
SELECT employee_id, first_name,
       NULLIF(salary, max_salary) AS below_max
FROM employees;
```

---

## 13. TRUNCATE vs DELETE

### Comparison

```sql
-- DELETE - Slower, generates undo/redo, triggers fired
DELETE FROM employees WHERE department_id = 10;
COMMIT;

-- TRUNCATE - Faster, minimal logging, no triggers
TRUNCATE TABLE employees;

-- TRUNCATE with REUSE storage
TRUNCATE TABLE employees REUSE STORAGE;

-- Key differences table:
-- DELETE: Slow, row-by-row, triggers fire, can rollback, keeps extents
-- TRUNCATE: Fast, deallocates blocks, no triggers, DDL (auto-commit), resets identity
```

---

## 14. Transactions & COMMIT/ROLLBACK

### Transaction Control

```sql
-- Begin implicit transaction
INSERT INTO employees (employee_id, first_name, last_name)
VALUES (9999, 'John', 'Doe');

UPDATE employees SET salary = 75000 WHERE employee_id = 9999;

-- Commit transaction
COMMIT;

-- Rollback transaction
ROLLBACK;

-- Savepoint
INSERT INTO employees VALUES (9999, 'John', 'Doe', ...);
SAVEPOINT sp1;

UPDATE employees SET salary = 75000 WHERE employee_id = 9999;
DELETE FROM employee_assignments WHERE employee_id = 9999;

-- Rollback to savepoint
ROLLBACK TO SAVEPOINT sp1;

-- Release savepoint
RELEASE SAVEPOINT sp1;

-- Final commit
COMMIT;

-- Set transaction properties
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
BEGIN
    -- Transaction code
    COMMIT;
END;
/

-- Read-only transaction
SET TRANSACTION READ ONLY;
SELECT * FROM employees;
COMMIT;
```

### Atomicity Example

```sql
-- Bank transfer example (atomic operation)
BEGIN
    UPDATE accounts SET balance = balance - 500 WHERE account_id = 1;
    UPDATE accounts SET balance = balance + 500 WHERE account_id = 2;
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END;
/
```

---

## 15. Best Practices

### SQL Formatting Best Practices

```sql
-- ✅ GOOD: Clear, readable formatting
SELECT employee_id,
       first_name,
       last_name,
       salary
FROM employees
WHERE department_id = 10
  AND salary > 50000
ORDER BY last_name, first_name;

-- ❌ BAD: Cramped, hard to read
SELECT e.employee_id, e.first_name, e.last_name, e.salary FROM employees e WHERE e.department_id = 10 AND e.salary > 50000 ORDER BY e.last_name, e.first_name;
```

### Performance Best Practices

```sql
-- ✅ Use aliases for clarity
SELECT e.employee_id, e.first_name, d.department_name
FROM employees e
JOIN departments d ON e.department_id = d.department_id;

-- ✅ Use specific columns instead of *
SELECT employee_id, first_name, last_name
FROM employees;

-- ❌ Avoid functions on indexed columns
SELECT * FROM employees WHERE UPPER(last_name) = 'SMITH';  -- Bad
SELECT * FROM employees WHERE last_name = 'SMITH';  -- Good

-- ✅ Use BETWEEN for ranges
SELECT * FROM employees WHERE salary BETWEEN 50000 AND 100000;

-- ✅ Use IN with small lists, subquery with large lists
SELECT * FROM employees WHERE department_id IN (10, 20, 30);
```

### Data Integrity Best Practices

```sql
-- ✅ Always validate data before insert/update
BEGIN
    IF salary > 0 AND hire_date <= SYSDATE THEN
        INSERT INTO employees VALUES (...);
    ELSE
        RAISE_APPLICATION_ERROR(-20001, 'Invalid data');
    END IF;
END;
/

-- ✅ Use constraints to enforce rules
CREATE TABLE employees (
    employee_id NUMBER(6) PRIMARY KEY,
    salary NUMBER(10,2) NOT NULL,
    CONSTRAINT chk_salary CHECK (salary > 0)
);

-- ✅ Use transactions for multi-step operations
BEGIN
    INSERT INTO orders VALUES (...);
    INSERT INTO order_items VALUES (...);
    UPDATE inventory SET quantity = quantity - 5;
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END;
/
```

### Naming Conventions

```sql
-- Table names: Plural, uppercase
CREATE TABLE employees (
    -- Column names: Singular, lowercase with underscores
    employee_id NUMBER(6),
    first_name VARCHAR2(20),
    last_name VARCHAR2(25),
    hire_date DATE,
    -- Constraint names: descriptive, prefixed with constraint type
    CONSTRAINT pk_employees PRIMARY KEY (employee_id),
    CONSTRAINT uk_employee_email UNIQUE (email),
    CONSTRAINT fk_emp_dept FOREIGN KEY (department_id) REFERENCES departments
);

-- Index naming
CREATE INDEX idx_emp_dept ON employees(department_id);
CREATE INDEX idx_emp_last_name ON employees(last_name);

-- View naming
CREATE VIEW v_employee_salaries AS ...;
CREATE MATERIALIZED VIEW mv_dept_summaries AS ...;
```

---

## Summary

**Chapter Coverage:**
- SQL fundamentals and architecture (8-10 hours)
- 60+ practical code examples
- Best practices throughout
- Real-world scenarios

**Key Takeaways:**
1. Master SELECT, INSERT, UPDATE, DELETE, MERGE
2. Understand data types and constraints
3. Handle NULLs correctly
4. Use transactions for data consistency
5. Follow naming conventions
6. Optimize queries for performance

**Next Chapter:** Advanced Queries & Subqueries

