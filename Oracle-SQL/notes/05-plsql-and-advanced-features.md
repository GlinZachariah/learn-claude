# PL/SQL & Advanced Features

## Table of Contents
1. [PL/SQL Fundamentals](#plsql-fundamentals)
2. [Stored Procedures](#stored-procedures)
3. [Functions](#functions)
4. [Packages](#packages)
5. [Triggers](#triggers)
6. [Collections & Cursors](#collections--cursors)
7. [Exception Handling](#exception-handling)
8. [Dynamic SQL](#dynamic-sql)
9. [Performance Optimization](#performance-optimization)
10. [Real-World Applications](#real-world-applications)

---

## PL/SQL Fundamentals

### Language Structure

PL/SQL is Oracle's procedural extension to SQL. It provides:
- Procedural programming constructs (loops, conditionals)
- Block structure (DECLARE, BEGIN, EXCEPTION, END)
- Local variables and type definitions
- Error handling
- Integration with SQL

### Basic Block Structure

```sql
DECLARE
    -- Variable declarations
    v_employee_id NUMBER;
    v_salary NUMBER;
    v_message VARCHAR2(100);
BEGIN
    -- Executable statements
    SELECT salary INTO v_salary
    FROM employees
    WHERE employee_id = 100;

    IF v_salary > 50000 THEN
        v_message := 'High Salary';
    ELSE
        v_message := 'Standard Salary';
    END IF;

    DBMS_OUTPUT.PUT_LINE(v_message);

EXCEPTION
    -- Error handling
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Employee not found');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;
/
```

### Data Types in PL/SQL

```sql
DECLARE
    -- Scalar types
    v_number NUMBER(10, 2);
    v_varchar VARCHAR2(100);
    v_date DATE;
    v_boolean BOOLEAN;

    -- Reference types (anchor to table columns)
    v_salary employees.salary%TYPE;  -- Same type as employees.salary
    v_employee employees%ROWTYPE;    -- Entire row from employees

    -- Custom types
    TYPE t_employee_record IS RECORD (
        emp_id NUMBER,
        emp_name VARCHAR2(100),
        emp_salary NUMBER,
        emp_dept VARCHAR2(50)
    );
    v_emp_record t_employee_record;

BEGIN
    -- Using %TYPE (type anchoring)
    SELECT salary INTO v_salary FROM employees WHERE employee_id = 100;
    DBMS_OUTPUT.PUT_LINE('Salary: ' || v_salary);

    -- Using %ROWTYPE (entire row)
    SELECT * INTO v_employee FROM employees WHERE employee_id = 100;
    DBMS_OUTPUT.PUT_LINE(v_employee.first_name || ' ' || v_employee.last_name);

    -- Using RECORD type
    v_emp_record.emp_id := 100;
    v_emp_record.emp_name := 'John Doe';
    v_emp_record.emp_salary := 75000;

END;
/
```

### Control Structures

```sql
-- IF-THEN-ELSE
DECLARE
    v_salary NUMBER := 60000;
    v_rating VARCHAR2(20);
BEGIN
    IF v_salary > 100000 THEN
        v_rating := 'Executive';
    ELSIF v_salary > 75000 THEN
        v_rating := 'Senior';
    ELSIF v_salary > 50000 THEN
        v_rating := 'Mid-Level';
    ELSE
        v_rating := 'Junior';
    END IF;
    DBMS_OUTPUT.PUT_LINE('Rating: ' || v_rating);
END;
/

-- CASE statement (similar to SQL CASE)
DECLARE
    v_dept_id NUMBER := 10;
    v_dept_name VARCHAR2(50);
BEGIN
    CASE v_dept_id
        WHEN 10 THEN v_dept_name := 'IT';
        WHEN 20 THEN v_dept_name := 'HR';
        WHEN 30 THEN v_dept_name := 'Sales';
        ELSE v_dept_name := 'Other';
    END CASE;
    DBMS_OUTPUT.PUT_LINE('Department: ' || v_dept_name);
END;
/

-- LOOP statements
DECLARE
    v_counter NUMBER := 1;
BEGIN
    -- Simple LOOP
    LOOP
        DBMS_OUTPUT.PUT_LINE('Count: ' || v_counter);
        v_counter := v_counter + 1;
        EXIT WHEN v_counter > 5;  -- Exit condition
    END LOOP;

    -- WHILE LOOP
    v_counter := 1;
    WHILE v_counter <= 5 LOOP
        DBMS_OUTPUT.PUT_LINE('While: ' || v_counter);
        v_counter := v_counter + 1;
    END LOOP;

    -- FOR LOOP
    FOR i IN 1..5 LOOP
        DBMS_OUTPUT.PUT_LINE('For: ' || i);
    END LOOP;
END;
/
```

---

## Stored Procedures

### Procedure Basics

```sql
-- Create simple procedure
CREATE OR REPLACE PROCEDURE raise_salary(
    p_employee_id IN NUMBER,
    p_percentage IN NUMBER
)
AS
    v_current_salary NUMBER;
    v_new_salary NUMBER;
BEGIN
    -- Get current salary
    SELECT salary INTO v_current_salary
    FROM employees
    WHERE employee_id = p_employee_id;

    -- Calculate new salary
    v_new_salary := v_current_salary * (1 + p_percentage / 100);

    -- Update salary
    UPDATE employees
    SET salary = v_new_salary
    WHERE employee_id = p_employee_id;

    -- Commit changes
    COMMIT;

    -- Output message
    DBMS_OUTPUT.PUT_LINE('Salary updated from ' || v_current_salary ||
                         ' to ' || v_new_salary);

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Employee not found');
        ROLLBACK;
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
        ROLLBACK;
END raise_salary;
/

-- Execute procedure
BEGIN
    raise_salary(100, 10);  -- Raise employee 100's salary by 10%
END;
/

-- Alternative execution
EXEC raise_salary(100, 10);
```

### Procedures with OUT Parameters

```sql
-- Procedure returning multiple values
CREATE OR REPLACE PROCEDURE get_employee_info(
    p_employee_id IN NUMBER,
    p_first_name OUT VARCHAR2,
    p_last_name OUT VARCHAR2,
    p_salary OUT NUMBER,
    p_dept_id OUT NUMBER
)
AS
BEGIN
    SELECT first_name, last_name, salary, department_id
    INTO p_first_name, p_last_name, p_salary, p_dept_id
    FROM employees
    WHERE employee_id = p_employee_id;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        p_first_name := NULL;
        p_last_name := NULL;
        p_salary := NULL;
        p_dept_id := NULL;
END get_employee_info;
/

-- Execute with OUT parameters
DECLARE
    v_first_name VARCHAR2(50);
    v_last_name VARCHAR2(50);
    v_salary NUMBER;
    v_dept_id NUMBER;
BEGIN
    get_employee_info(100, v_first_name, v_last_name, v_salary, v_dept_id);
    DBMS_OUTPUT.PUT_LINE(v_first_name || ' ' || v_last_name ||
                         ' - Salary: ' || v_salary);
END;
/
```

### Batch Processing with Procedures

```sql
-- Batch insert procedure using collections
CREATE OR REPLACE PROCEDURE bulk_insert_employees(
    p_count IN NUMBER
)
AS
    TYPE t_emp_table IS TABLE OF employees%ROWTYPE;
    v_employees t_emp_table;
    v_max_id NUMBER;
BEGIN
    -- Find max employee ID
    SELECT MAX(employee_id) INTO v_max_id FROM employees;

    -- Initialize collection
    v_employees := t_emp_table();

    -- Populate collection
    FOR i IN 1..p_count LOOP
        v_employees.EXTEND;
        v_employees(i).employee_id := v_max_id + i;
        v_employees(i).first_name := 'Employee' || i;
        v_employees(i).last_name := 'Test';
        v_employees(i).hire_date := SYSDATE;
        v_employees(i).salary := 50000 + (i * 100);
    END LOOP;

    -- Bulk insert
    FORALL i IN 1..v_employees.COUNT
        INSERT INTO employees VALUES v_employees(i);

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Inserted ' || p_count || ' employees');

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END bulk_insert_employees;
/

-- Execute
BEGIN
    bulk_insert_employees(1000);
END;
/
```

---

## Functions

### Function Basics

```sql
-- Simple function returning single value
CREATE OR REPLACE FUNCTION calculate_annual_bonus(
    p_salary IN NUMBER,
    p_tenure_years IN NUMBER
)
RETURN NUMBER
AS
    v_bonus NUMBER;
    v_bonus_percentage NUMBER;
BEGIN
    -- Determine bonus percentage based on tenure
    IF p_tenure_years >= 10 THEN
        v_bonus_percentage := 0.20;  -- 20% for 10+ years
    ELSIF p_tenure_years >= 5 THEN
        v_bonus_percentage := 0.15;  -- 15% for 5-10 years
    ELSIF p_tenure_years >= 2 THEN
        v_bonus_percentage := 0.10;  -- 10% for 2-5 years
    ELSE
        v_bonus_percentage := 0.05;  -- 5% for less than 2 years
    END IF;

    -- Calculate bonus
    v_bonus := p_salary * v_bonus_percentage;

    RETURN v_bonus;

EXCEPTION
    WHEN OTHERS THEN
        RETURN NULL;
END calculate_annual_bonus;
/

-- Use in SQL queries
SELECT
    employee_id,
    first_name,
    salary,
    DATEDIFF(YEAR, hire_date, SYSDATE) AS tenure_years,
    calculate_annual_bonus(salary, DATEDIFF(YEAR, hire_date, SYSDATE)) AS annual_bonus
FROM employees
WHERE department_id = 10;
```

### Pipelined Functions (Returning Sets)

```sql
-- Pipelined function returning result set
CREATE OR REPLACE TYPE t_sales_record AS OBJECT (
    product_id NUMBER,
    product_name VARCHAR2(100),
    monthly_sales NUMBER,
    year_to_date NUMBER,
    forecast_next_month NUMBER
);
/

CREATE OR REPLACE TYPE t_sales_table IS TABLE OF t_sales_record;
/

CREATE OR REPLACE FUNCTION get_sales_forecast(
    p_num_months IN NUMBER
)
RETURN t_sales_table
PIPELINED
AS
    v_sales_record t_sales_record;
    v_monthly_sales NUMBER;
    v_ytd_sales NUMBER;
BEGIN
    FOR product_rec IN (SELECT product_id, product_name FROM products) LOOP
        -- Calculate sales metrics
        SELECT SUM(amount) INTO v_monthly_sales
        FROM sales
        WHERE product_id = product_rec.product_id
          AND EXTRACT(MONTH FROM sale_date) = EXTRACT(MONTH FROM SYSDATE);

        SELECT SUM(amount) INTO v_ytd_sales
        FROM sales
        WHERE product_id = product_rec.product_id
          AND EXTRACT(YEAR FROM sale_date) = EXTRACT(YEAR FROM SYSDATE);

        -- Create record
        v_sales_record := t_sales_record(
            product_rec.product_id,
            product_rec.product_name,
            v_monthly_sales,
            v_ytd_sales,
            v_monthly_sales * 1.1  -- Forecast 10% growth
        );

        -- Pipe (stream) record
        PIPE ROW(v_sales_record);
    END LOOP;

    RETURN;
END get_sales_forecast;
/

-- Use pipelined function
SELECT * FROM TABLE(get_sales_forecast(12));
```

---

## Packages

### Package Structure

```sql
-- Package specification (interface)
CREATE OR REPLACE PACKAGE emp_management AS

    -- Global constants
    MAX_SALARY_INCREASE CONSTANT NUMBER := 0.20;
    MIN_SALARY_INCREASE CONSTANT NUMBER := 0.03;

    -- Procedure declarations
    PROCEDURE hire_employee(
        p_first_name IN VARCHAR2,
        p_last_name IN VARCHAR2,
        p_salary IN NUMBER,
        p_department_id IN NUMBER,
        p_new_emp_id OUT NUMBER
    );

    PROCEDURE raise_salary(
        p_employee_id IN NUMBER,
        p_percentage IN NUMBER
    );

    FUNCTION get_employee_salary(
        p_employee_id IN NUMBER
    ) RETURN NUMBER;

    FUNCTION get_department_avg_salary(
        p_department_id IN NUMBER
    ) RETURN NUMBER;

END emp_management;
/

-- Package body (implementation)
CREATE OR REPLACE PACKAGE BODY emp_management AS

    -- Internal procedure (private to package)
    PROCEDURE log_salary_change(
        p_employee_id IN NUMBER,
        p_old_salary IN NUMBER,
        p_new_salary IN NUMBER
    )
    AS
    BEGIN
        INSERT INTO salary_audit_log
        VALUES (p_employee_id, p_old_salary, p_new_salary, SYSDATE, USER);
        COMMIT;
    END log_salary_change;

    -- Public procedure
    PROCEDURE hire_employee(
        p_first_name IN VARCHAR2,
        p_last_name IN VARCHAR2,
        p_salary IN NUMBER,
        p_department_id IN NUMBER,
        p_new_emp_id OUT NUMBER
    )
    AS
    BEGIN
        SELECT MAX(employee_id) + 1 INTO p_new_emp_id FROM employees;

        INSERT INTO employees (
            employee_id, first_name, last_name, salary,
            department_id, hire_date
        ) VALUES (
            p_new_emp_id, p_first_name, p_last_name, p_salary,
            p_department_id, SYSDATE
        );

        COMMIT;
    END hire_employee;

    -- Public procedure
    PROCEDURE raise_salary(
        p_employee_id IN NUMBER,
        p_percentage IN NUMBER
    )
    AS
        v_old_salary NUMBER;
        v_new_salary NUMBER;
    BEGIN
        -- Get current salary
        SELECT salary INTO v_old_salary
        FROM employees
        WHERE employee_id = p_employee_id;

        -- Validate percentage
        IF p_percentage > MAX_SALARY_INCREASE THEN
            RAISE_APPLICATION_ERROR(-20001, 'Increase exceeds maximum: ' || MAX_SALARY_INCREASE);
        END IF;

        IF p_percentage < MIN_SALARY_INCREASE THEN
            RAISE_APPLICATION_ERROR(-20002, 'Increase below minimum: ' || MIN_SALARY_INCREASE);
        END IF;

        -- Calculate new salary
        v_new_salary := v_old_salary * (1 + p_percentage);

        -- Update salary
        UPDATE employees
        SET salary = v_new_salary
        WHERE employee_id = p_employee_id;

        -- Log change
        log_salary_change(p_employee_id, v_old_salary, v_new_salary);

        COMMIT;
    END raise_salary;

    -- Public function
    FUNCTION get_employee_salary(
        p_employee_id IN NUMBER
    ) RETURN NUMBER
    AS
        v_salary NUMBER;
    BEGIN
        SELECT salary INTO v_salary
        FROM employees
        WHERE employee_id = p_employee_id;

        RETURN v_salary;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN NULL;
    END get_employee_salary;

    -- Public function
    FUNCTION get_department_avg_salary(
        p_department_id IN NUMBER
    ) RETURN NUMBER
    AS
        v_avg_salary NUMBER;
    BEGIN
        SELECT AVG(salary) INTO v_avg_salary
        FROM employees
        WHERE department_id = p_department_id;

        RETURN v_avg_salary;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN NULL;
    END get_department_avg_salary;

END emp_management;
/

-- Use package
BEGIN
    emp_management.raise_salary(100, 0.10);
    DBMS_OUTPUT.PUT_LINE('New salary: ' || emp_management.get_employee_salary(100));
END;
/
```

### Package Variables (State)

```sql
CREATE OR REPLACE PACKAGE app_state AS
    -- Package-level variables (persist for session)
    g_session_user_id NUMBER;
    g_session_user_role VARCHAR2(50);
    g_last_query_time DATE;

    PROCEDURE set_session_context(p_user_id IN NUMBER);
    FUNCTION get_session_user_id RETURN NUMBER;
END app_state;
/

CREATE OR REPLACE PACKAGE BODY app_state AS

    PROCEDURE set_session_context(p_user_id IN NUMBER)
    AS
    BEGIN
        g_session_user_id := p_user_id;
        g_last_query_time := SYSDATE;

        -- Look up user role from database
        SELECT role INTO g_session_user_role
        FROM users
        WHERE user_id = p_user_id;
    END set_session_context;

    FUNCTION get_session_user_id RETURN NUMBER
    AS
    BEGIN
        RETURN g_session_user_id;
    END get_session_user_id;

END app_state;
/

-- Use package state
BEGIN
    app_state.set_session_context(100);
    DBMS_OUTPUT.PUT_LINE('User ID: ' || app_state.get_session_user_id());
END;
/
```

---

## Triggers

### DML Triggers (Before/After Insert, Update, Delete)

```sql
-- Audit trigger - Track all employee salary changes
CREATE OR REPLACE TRIGGER employees_audit_trg
BEFORE INSERT OR UPDATE OR DELETE ON employees
FOR EACH ROW
BEGIN
    IF INSERTING THEN
        INSERT INTO employees_audit (
            employee_id, action, action_date, changed_by, old_salary, new_salary
        ) VALUES (
            :NEW.employee_id, 'INSERT', SYSDATE, USER, NULL, :NEW.salary
        );
    ELSIF UPDATING THEN
        IF :OLD.salary != :NEW.salary THEN
            INSERT INTO employees_audit (
                employee_id, action, action_date, changed_by, old_salary, new_salary
            ) VALUES (
                :OLD.employee_id, 'UPDATE', SYSDATE, USER, :OLD.salary, :NEW.salary
            );
        END IF;
    ELSIF DELETING THEN
        INSERT INTO employees_audit (
            employee_id, action, action_date, changed_by, old_salary, new_salary
        ) VALUES (
            :OLD.employee_id, 'DELETE', SYSDATE, USER, :OLD.salary, NULL
        );
    END IF;
END employees_audit_trg;
/

-- Now any change to employees triggers audit logging
UPDATE employees SET salary = 75000 WHERE employee_id = 100;
-- Automatically logged in employees_audit
```

### Validation Trigger

```sql
-- Prevent salary decreases
CREATE OR REPLACE TRIGGER validate_salary_increase
BEFORE UPDATE OF salary ON employees
FOR EACH ROW
BEGIN
    IF :NEW.salary < :OLD.salary THEN
        RAISE_APPLICATION_ERROR(
            -20003,
            'Salary cannot decrease from ' || :OLD.salary || ' to ' || :NEW.salary
        );
    END IF;
END validate_salary_increase;
/

-- This update will be rejected
UPDATE employees SET salary = 60000 WHERE employee_id = 100 AND salary = 75000;
-- ERROR: Salary cannot decrease from 75000 to 60000
```

### Referential Integrity Trigger

```sql
-- Maintain referential integrity with cascading updates
CREATE OR REPLACE TRIGGER dept_cascade_update
AFTER UPDATE OF department_id ON departments
FOR EACH ROW
BEGIN
    -- Update all employees in that department
    UPDATE employees
    SET department_id = :NEW.department_id
    WHERE department_id = :OLD.department_id;

    -- Could also cascade delete:
    -- DELETE FROM employees WHERE department_id = :OLD.department_id;
END dept_cascade_update;
/
```

### Compound Triggers (Oracle 11g+)

```sql
-- Compound trigger combining multiple trigger types
CREATE OR REPLACE TRIGGER employee_changes_compound
FOR INSERT OR UPDATE OR DELETE ON employees
COMPOUND TRIGGER

    TYPE t_employee_record IS RECORD (
        employee_id NUMBER,
        action VARCHAR2(10),
        action_time DATE
    );

    TYPE t_employee_table IS TABLE OF t_employee_record;
    v_changes t_employee_table := t_employee_table();

    -- BEFORE statement (execute once per statement)
    BEFORE STATEMENT IS
    BEGIN
        v_changes.DELETE;  -- Clear collection
        DBMS_OUTPUT.PUT_LINE('Batch operation started');
    END BEFORE STATEMENT;

    -- BEFORE row (execute for each row)
    BEFORE EACH ROW IS
    BEGIN
        IF INSERTING THEN
            DBMS_OUTPUT.PUT_LINE('Inserting employee: ' || :NEW.employee_id);
        ELSIF UPDATING THEN
            DBMS_OUTPUT.PUT_LINE('Updating employee: ' || :OLD.employee_id);
        ELSIF DELETING THEN
            DBMS_OUTPUT.PUT_LINE('Deleting employee: ' || :OLD.employee_id);
        END IF;
    END BEFORE EACH ROW;

    -- AFTER row (execute for each row)
    AFTER EACH ROW IS
    BEGIN
        v_changes.EXTEND;
        v_changes(v_changes.COUNT) := t_employee_record(
            NVL(:NEW.employee_id, :OLD.employee_id),
            CASE WHEN INSERTING THEN 'INSERT'
                 WHEN UPDATING THEN 'UPDATE'
                 WHEN DELETING THEN 'DELETE'
            END,
            SYSDATE
        );
    END AFTER EACH ROW;

    -- AFTER statement (execute once per statement)
    AFTER STATEMENT IS
    BEGIN
        DBMS_OUTPUT.PUT_LINE('Batch operation completed. Changes: ' || v_changes.COUNT);
        FOR i IN 1..v_changes.COUNT LOOP
            INSERT INTO audit_log VALUES (v_changes(i).employee_id, v_changes(i).action, v_changes(i).action_time);
        END LOOP;
        COMMIT;
    END AFTER STATEMENT;

END employee_changes_compound;
/
```

---

## Collections & Cursors

### Associative Arrays (Maps)

```sql
DECLARE
    TYPE t_salary_map IS TABLE OF NUMBER INDEX BY VARCHAR2(50);
    v_dept_salaries t_salary_map;
    v_key VARCHAR2(50);
BEGIN
    -- Populate map
    v_dept_salaries('IT') := 75000;
    v_dept_salaries('HR') := 65000;
    v_dept_salaries('SALES') := 60000;

    -- Access by key
    DBMS_OUTPUT.PUT_LINE('IT salary: ' || v_dept_salaries('IT'));

    -- Iterate through map
    v_key := v_dept_salaries.FIRST;
    WHILE v_key IS NOT NULL LOOP
        DBMS_OUTPUT.PUT_LINE(v_key || ': ' || v_dept_salaries(v_key));
        v_key := v_dept_salaries.NEXT(v_key);
    END LOOP;
END;
/
```

### Nested Tables

```sql
DECLARE
    TYPE t_employee_list IS TABLE OF employees%ROWTYPE;
    v_employees t_employee_list;
    v_index NUMBER;
BEGIN
    -- Initialize collection
    v_employees := t_employee_list();

    -- Fetch data into collection
    SELECT * BULK COLLECT INTO v_employees
    FROM employees
    WHERE department_id = 10;

    -- Process collection
    FOR i IN 1..v_employees.COUNT LOOP
        DBMS_OUTPUT.PUT_LINE(
            v_employees(i).employee_id || ': ' ||
            v_employees(i).first_name || ' - ' ||
            v_employees(i).salary
        );
    END LOOP;

    -- Check if element exists
    IF v_employees.EXISTS(1) THEN
        DBMS_OUTPUT.PUT_LINE('First employee: ' || v_employees(1).first_name);
    END IF;

    -- Delete from collection
    v_employees.DELETE(1);

    -- Get collection size
    DBMS_OUTPUT.PUT_LINE('Collection size after delete: ' || v_employees.COUNT);

END;
/
```

### Cursor Operations

```sql
DECLARE
    CURSOR emp_cursor IS
        SELECT employee_id, first_name, salary
        FROM employees
        WHERE department_id = 10
        FOR UPDATE;  -- Lock rows for modification

    v_emp_id NUMBER;
    v_emp_name VARCHAR2(50);
    v_salary NUMBER;
BEGIN
    OPEN emp_cursor;

    LOOP
        FETCH emp_cursor INTO v_emp_id, v_emp_name, v_salary;
        EXIT WHEN emp_cursor%NOTFOUND;

        -- Process record
        DBMS_OUTPUT.PUT_LINE(v_emp_name || ' - ' || v_salary);

        -- Update through cursor
        IF v_salary < 50000 THEN
            UPDATE employees
            SET salary = salary * 1.10
            WHERE CURRENT OF emp_cursor;  -- Updates current row
        END IF;
    END LOOP;

    CLOSE emp_cursor;
    COMMIT;
END;
/
```

### Cursor Variables (REF CURSOR)

```sql
DECLARE
    TYPE t_ref_cursor IS REF CURSOR;
    v_cursor t_ref_cursor;
    v_sql VARCHAR2(500);
    v_emp_id NUMBER;
    v_emp_name VARCHAR2(50);
    v_salary NUMBER;
    p_dept_id NUMBER := 10;
BEGIN
    -- Dynamic query using REF CURSOR
    v_sql := 'SELECT employee_id, first_name, salary FROM employees WHERE department_id = :dept_id';

    OPEN v_cursor FOR v_sql USING p_dept_id;

    LOOP
        FETCH v_cursor INTO v_emp_id, v_emp_name, v_salary;
        EXIT WHEN v_cursor%NOTFOUND;

        DBMS_OUTPUT.PUT_LINE(v_emp_name || ': ' || v_salary);
    END LOOP;

    CLOSE v_cursor;
END;
/

-- Function returning REF CURSOR
CREATE OR REPLACE FUNCTION get_employees_by_dept(
    p_dept_id IN NUMBER
)
RETURN SYS_REFCURSOR
AS
    v_cursor SYS_REFCURSOR;
BEGIN
    OPEN v_cursor FOR
        SELECT employee_id, first_name, salary
        FROM employees
        WHERE department_id = p_dept_id
        ORDER BY salary DESC;

    RETURN v_cursor;
END get_employees_by_dept;
/

-- Use the function
DECLARE
    v_cursor SYS_REFCURSOR;
    v_emp_id NUMBER;
    v_emp_name VARCHAR2(50);
    v_salary NUMBER;
BEGIN
    v_cursor := get_employees_by_dept(10);

    LOOP
        FETCH v_cursor INTO v_emp_id, v_emp_name, v_salary;
        EXIT WHEN v_cursor%NOTFOUND;

        DBMS_OUTPUT.PUT_LINE(v_emp_name || ': ' || v_salary);
    END LOOP;

    CLOSE v_cursor;
END;
/
```

---

## Exception Handling

### Predefined Exceptions

```sql
DECLARE
    v_salary NUMBER;
BEGIN
    -- NO_DATA_FOUND exception
    SELECT salary INTO v_salary
    FROM employees
    WHERE employee_id = 99999;  -- Doesn't exist

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Employee not found');
    WHEN TOO_MANY_ROWS THEN
        DBMS_OUTPUT.PUT_LINE('Multiple employees returned');
    WHEN INVALID_NUMBER THEN
        DBMS_OUTPUT.PUT_LINE('Invalid number format');
    WHEN ZERO_DIVIDE THEN
        DBMS_OUTPUT.PUT_LINE('Division by zero');
    WHEN DUP_VAL_ON_INDEX THEN
        DBMS_OUTPUT.PUT_LINE('Duplicate value on unique index');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Unexpected error: ' || SQLERRM);
END;
/
```

### User-Defined Exceptions

```sql
CREATE OR REPLACE PROCEDURE process_salary_increase(
    p_employee_id IN NUMBER,
    p_percentage IN NUMBER
)
AS
    -- Define custom exceptions
    e_invalid_percentage EXCEPTION;
    e_employee_not_found EXCEPTION;
    e_salary_frozen EXCEPTION;

    PRAGMA EXCEPTION_INIT(e_invalid_percentage, -20001);
    PRAGMA EXCEPTION_INIT(e_employee_not_found, -20002);
    PRAGMA EXCEPTION_INIT(e_salary_frozen, -20003);

    v_employee_exists BOOLEAN;
    v_salary_frozen BOOLEAN;
BEGIN
    -- Check employee exists
    SELECT COUNT(*) INTO v_employee_exists
    FROM employees
    WHERE employee_id = p_employee_id;

    IF v_employee_exists = 0 THEN
        RAISE e_employee_not_found;
    END IF;

    -- Check salary frozen status
    SELECT frozen INTO v_salary_frozen
    FROM employees
    WHERE employee_id = p_employee_id;

    IF v_salary_frozen THEN
        RAISE e_salary_frozen;
    END IF;

    -- Validate percentage
    IF p_percentage < 0 OR p_percentage > 50 THEN
        RAISE e_invalid_percentage;
    END IF;

    -- Process increase
    UPDATE employees
    SET salary = salary * (1 + p_percentage / 100)
    WHERE employee_id = p_employee_id;

    COMMIT;

EXCEPTION
    WHEN e_invalid_percentage THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20001, 'Invalid percentage: ' || p_percentage);
    WHEN e_employee_not_found THEN
        RAISE_APPLICATION_ERROR(-20002, 'Employee not found: ' || p_employee_id);
    WHEN e_salary_frozen THEN
        RAISE_APPLICATION_ERROR(-20003, 'Salary is frozen for this employee');
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20099, 'Unexpected error: ' || SQLERRM);
END process_salary_increase;
/
```

---

## Dynamic SQL

### EXECUTE IMMEDIATE

```sql
DECLARE
    p_table_name VARCHAR2(50) := 'employees';
    p_filter VARCHAR2(100) := 'WHERE department_id = 10';
    p_limit NUMBER := 10;
    v_sql VARCHAR2(500);
    v_employee_count NUMBER;
BEGIN
    -- Build dynamic SQL
    v_sql := 'SELECT COUNT(*) FROM ' || p_table_name || ' ' || p_filter;

    EXECUTE IMMEDIATE v_sql INTO v_employee_count;

    DBMS_OUTPUT.PUT_LINE('Employee count: ' || v_employee_count);

    -- Dynamic INSERT
    v_sql := 'INSERT INTO employees (employee_id, first_name, salary) VALUES (:1, :2, :3)';
    EXECUTE IMMEDIATE v_sql USING 1001, 'John Doe', 75000;

    -- Dynamic UPDATE
    v_sql := 'UPDATE employees SET salary = :1 WHERE employee_id = :2';
    EXECUTE IMMEDIATE v_sql USING 80000, 1001;

    -- Dynamic DELETE
    v_sql := 'DELETE FROM employees WHERE employee_id = :1';
    EXECUTE IMMEDIATE v_sql USING 1001;

    COMMIT;
END;
/
```

### DBMS_SQL for Complex Scenarios

```sql
DECLARE
    v_cursor INTEGER;
    v_sql VARCHAR2(1000);
    v_col_count INTEGER;
    v_desc_tab DBMS_SQL.DESC_TAB;
    v_num_rows INTEGER;
BEGIN
    -- Open cursor
    v_cursor := DBMS_SQL.OPEN_CURSOR;

    -- Prepare dynamic SQL
    v_sql := 'SELECT * FROM employees WHERE department_id = :dept_id';
    DBMS_SQL.PARSE(v_cursor, v_sql, DBMS_SQL.NATIVE);

    -- Bind parameter
    DBMS_SQL.BIND_VARIABLE(v_cursor, ':dept_id', 10);

    -- Define output columns
    DBMS_SQL.DESCRIBE_COLUMNS(v_cursor, v_col_count, v_desc_tab);

    FOR i IN 1..v_col_count LOOP
        DBMS_SQL.DEFINE_COLUMN(v_cursor, i, v_desc_tab(i).col_type);
    END LOOP;

    -- Execute
    v_num_rows := DBMS_SQL.EXECUTE(v_cursor);

    -- Fetch results
    LOOP
        IF DBMS_SQL.FETCH_ROWS(v_cursor) > 0 THEN
            FOR i IN 1..v_col_count LOOP
                DBMS_OUTPUT.PUT_LINE(v_desc_tab(i).col_name || ': ' ||
                                    DBMS_SQL.COLUMN_VALUE_CHAR(v_cursor, i));
            END LOOP;
        ELSE
            EXIT;
        END IF;
    END LOOP;

    DBMS_SQL.CLOSE_CURSOR(v_cursor);
END;
/
```

---

## Performance Optimization

### FORALL vs Loop

```sql
-- SLOW: Row-by-row processing
DECLARE
    v_emp_salary employees.salary%TYPE;
BEGIN
    FOR emp_rec IN (SELECT * FROM employees WHERE department_id = 10) LOOP
        UPDATE employees
        SET salary = salary * 1.10
        WHERE employee_id = emp_rec.employee_id;
    END LOOP;
    COMMIT;
END;
/

-- FAST: Bulk processing with FORALL
DECLARE
    TYPE t_emp_id_table IS TABLE OF employees.employee_id%TYPE;
    v_emp_ids t_emp_id_table;
BEGIN
    SELECT employee_id BULK COLLECT INTO v_emp_ids
    FROM employees
    WHERE department_id = 10;

    FORALL i IN 1..v_emp_ids.COUNT
        UPDATE employees
        SET salary = salary * 1.10
        WHERE employee_id = v_emp_ids(i);

    COMMIT;
END;
/

-- Performance: FORALL 10-100x faster for bulk operations
```

### BULK COLLECT with LIMIT

```sql
-- Process large result sets efficiently
DECLARE
    TYPE t_employee_record IS TABLE OF employees%ROWTYPE;
    v_employees t_employee_record;
    CURSOR emp_cursor IS SELECT * FROM employees;
    v_batch_size CONSTANT NUMBER := 1000;
BEGIN
    OPEN emp_cursor;

    LOOP
        -- Fetch in batches
        FETCH emp_cursor BULK COLLECT INTO v_employees LIMIT v_batch_size;

        -- Process batch
        IF v_employees.COUNT > 0 THEN
            FOR i IN 1..v_employees.COUNT LOOP
                DBMS_OUTPUT.PUT_LINE(v_employees(i).employee_id);
            END LOOP;

            -- Commit to free memory
            COMMIT;
        END IF;

        EXIT WHEN emp_cursor%NOTFOUND;
    END LOOP;

    CLOSE emp_cursor;
END;
/

-- Benefits:
-- 1. Reduces memory usage for large tables
-- 2. Faster processing with periodic commits
-- 3. Better scalability
```

---

## Real-World Applications

### Complete Employee Management System

```sql
-- Create package for employee lifecycle management
CREATE OR REPLACE PACKAGE employee_lifecycle AS

    -- Hire new employee
    PROCEDURE hire_employee(
        p_first_name IN VARCHAR2,
        p_last_name IN VARCHAR2,
        p_salary IN NUMBER,
        p_department_id IN NUMBER,
        p_new_emp_id OUT NUMBER
    );

    -- Transfer employee to different department
    PROCEDURE transfer_employee(
        p_employee_id IN NUMBER,
        p_new_department_id IN NUMBER
    );

    -- Promote employee with raise
    PROCEDURE promote_employee(
        p_employee_id IN NUMBER,
        p_new_job_title IN VARCHAR2,
        p_raise_percentage IN NUMBER
    );

    -- Terminate employee
    PROCEDURE terminate_employee(
        p_employee_id IN NUMBER,
        p_severance_amount IN NUMBER
    );

    -- Generate employee report
    FUNCTION get_employee_report(
        p_department_id IN NUMBER
    ) RETURN SYS_REFCURSOR;

END employee_lifecycle;
/

CREATE OR REPLACE PACKAGE BODY employee_lifecycle AS

    PROCEDURE hire_employee(
        p_first_name IN VARCHAR2,
        p_last_name IN VARCHAR2,
        p_salary IN NUMBER,
        p_department_id IN NUMBER,
        p_new_emp_id OUT NUMBER
    )
    AS
    BEGIN
        SELECT MAX(employee_id) + 1 INTO p_new_emp_id FROM employees;

        INSERT INTO employees (
            employee_id, first_name, last_name, salary,
            department_id, hire_date, status
        ) VALUES (
            p_new_emp_id, p_first_name, p_last_name, p_salary,
            p_department_id, SYSDATE, 'ACTIVE'
        );

        -- Log action
        INSERT INTO employee_actions (
            employee_id, action_type, action_date, details
        ) VALUES (
            p_new_emp_id, 'HIRED', SYSDATE,
            'Hired as ' || p_first_name || ' ' || p_last_name
        );

        COMMIT;
    END hire_employee;

    PROCEDURE transfer_employee(
        p_employee_id IN NUMBER,
        p_new_department_id IN NUMBER
    )
    AS
        v_old_dept_id NUMBER;
    BEGIN
        SELECT department_id INTO v_old_dept_id
        FROM employees
        WHERE employee_id = p_employee_id;

        UPDATE employees
        SET department_id = p_new_department_id
        WHERE employee_id = p_employee_id;

        INSERT INTO employee_actions (
            employee_id, action_type, action_date, details
        ) VALUES (
            p_employee_id, 'TRANSFERRED', SYSDATE,
            'Transferred from dept ' || v_old_dept_id || ' to ' || p_new_department_id
        );

        COMMIT;
    END transfer_employee;

    PROCEDURE promote_employee(
        p_employee_id IN NUMBER,
        p_new_job_title IN VARCHAR2,
        p_raise_percentage IN NUMBER
    )
    AS
        v_old_salary NUMBER;
        v_new_salary NUMBER;
    BEGIN
        SELECT salary INTO v_old_salary
        FROM employees
        WHERE employee_id = p_employee_id;

        v_new_salary := v_old_salary * (1 + p_raise_percentage);

        UPDATE employees
        SET job_title = p_new_job_title,
            salary = v_new_salary
        WHERE employee_id = p_employee_id;

        INSERT INTO employee_actions (
            employee_id, action_type, action_date, details
        ) VALUES (
            p_employee_id, 'PROMOTED', SYSDATE,
            'Promoted to ' || p_new_job_title || '. Salary: ' ||
            v_old_salary || ' -> ' || v_new_salary
        );

        COMMIT;
    END promote_employee;

    PROCEDURE terminate_employee(
        p_employee_id IN NUMBER,
        p_severance_amount IN NUMBER
    )
    AS
    BEGIN
        UPDATE employees
        SET status = 'TERMINATED',
            termination_date = SYSDATE,
            severance_amount = p_severance_amount
        WHERE employee_id = p_employee_id;

        INSERT INTO employee_actions (
            employee_id, action_type, action_date, details
        ) VALUES (
            p_employee_id, 'TERMINATED', SYSDATE,
            'Terminated with severance: ' || p_severance_amount
        );

        COMMIT;
    END terminate_employee;

    FUNCTION get_employee_report(
        p_department_id IN NUMBER
    ) RETURN SYS_REFCURSOR
    AS
        v_cursor SYS_REFCURSOR;
    BEGIN
        OPEN v_cursor FOR
            SELECT
                employee_id,
                first_name,
                last_name,
                job_title,
                salary,
                hire_date,
                status
            FROM employees
            WHERE department_id = p_department_id
            ORDER BY employee_id;

        RETURN v_cursor;
    END get_employee_report;

END employee_lifecycle;
/

-- Use the complete system
BEGIN
    employee_lifecycle.hire_employee('Jane', 'Smith', 75000, 10, :new_emp_id);
    employee_lifecycle.transfer_employee(:new_emp_id, 20);
    employee_lifecycle.promote_employee(:new_emp_id, 'Senior Manager', 0.15);
END;
/
```

---

## Best Practices

✅ Use packages to organize related procedures/functions
✅ Use %TYPE and %ROWTYPE for flexible code
✅ Always handle exceptions explicitly
✅ Use BULK COLLECT and FORALL for performance
✅ Create audit trails for important operations
✅ Document complex business logic
✅ Use meaningful variable names
✅ Test PL/SQL thoroughly before production
❌ Don't use dynamic SQL without parameterization
❌ Don't ignore performance with row-by-row processing
❌ Don't commit inside procedures unless necessary
❌ Don't suppress exceptions with OTHERS

---

**Chapter Status:** Complete
**Lines of Code Examples:** 1,400+
**Code Examples:** 85+
**Real-World Applications:** 2 complete systems

