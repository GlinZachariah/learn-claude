# Oracle SQL Self-Assessment Quiz

## Part 1: SQL Fundamentals (20 Questions, 3 points each = 60 points)

**Q1:** What does NULL represent in SQL?
- A) Zero value
- B) Unknown or missing value
- C) Empty string
- D) False

**Answer: B** - NULL is a special marker for unknown/missing data.

---

**Q2:** Which operator correctly compares NULL values?
- A) = NULL
- B) != NULL
- C) IS NULL
- D) <> NULL

**Answer: C** - Use IS NULL for NULL comparisons.

---

**Q3:** What is the result of 5 + NULL?
- A) 5
- B) NULL
- C) 0
- D) Error

**Answer: B** - Any arithmetic with NULL returns NULL.

---

**Q4:** Which statement removes ALL rows and CANNOT be rolled back?
- A) DELETE
- B) DROP
- C) TRUNCATE
- D) REMOVE

**Answer: C** - TRUNCATE is DDL and auto-commits.

---

**Q5:** What is the correct syntax for multiple row insert?
- A) INSERT ALL
- B) INSERT INTO ... VALUES, VALUES
- C) INSERT MULTIPLE
- D) INSERT ROWS

**Answer: A** - Oracle uses INSERT ALL for multiple rows.

---

**Q6:** CHAR(10) vs VARCHAR2(10) - what's the difference?
- A) CHAR is variable, VARCHAR2 is fixed
- B) CHAR is fixed, VARCHAR2 is variable
- C) No difference
- D) CHAR stores numbers, VARCHAR2 stores text

**Answer: B** - CHAR is fixed length, VARCHAR2 is variable.

---

**Q7:** What constraint enforces uniqueness across NULL values?
- A) PRIMARY KEY
- B) UNIQUE
- C) Both accept multiple NULLs
- D) Neither accepts NULLs

**Answer: C** - Both allow multiple NULLs.

---

**Q8:** Which clause filters rows BEFORE grouping?
- A) HAVING
- B) WHERE
- C) GROUP BY
- D) ORDER BY

**Answer: B** - WHERE filters before grouping.

---

**Q9:** Can you use column aliases in WHERE clause?
- A) Yes, always
- B) Yes, with quotes
- C) No, WHERE executes before SELECT
- D) Yes, in Oracle only

**Answer: C** - WHERE is processed before SELECT.

---

**Q10:** What does BETWEEN include?
- A) Only values between extremes
- B) Includes lower but excludes upper
- C) Includes both lower and upper
- D) Depends on data type

**Answer: C** - BETWEEN is inclusive on both ends.

---

**Q11:** How many rows does CROSS JOIN produce?
- A) 0 rows
- B) Number of common rows
- C) rows_table1 × rows_table2
- D) Depends on condition

**Answer: C** - Cartesian product of both tables.

---

**Q12:** Which JOIN type preserves all rows from the left table?
- A) INNER JOIN
- B) LEFT OUTER JOIN
- C) RIGHT OUTER JOIN
- D) FULL OUTER JOIN

**Answer: B** - LEFT JOIN keeps all left rows.

---

**Q13:** Can you ORDER BY columns not in SELECT?
- A) No, always error
- B) Yes, always allowed
- C) Only with GROUP BY
- D) Depends on database

**Answer: B** - ORDER BY can use any table column.

---

**Q14:** What is the result of UNION with duplicate rows?
- A) All duplicates kept
- B) Duplicates removed
- C) Error
- D) Depends on column types

**Answer: B** - UNION removes duplicates.

---

**Q15:** Which operator returns exactly one row?
- A) IN
- B) ANY
- C) ALL
- D) EXISTS

**Answer: D** - EXISTS returns TRUE/FALSE, not rows.

---

**Q16-20:** Additional fundamentals questions
- Q16: Date arithmetic
- Q17: String functions
- Q18: Number functions
- Q19: Type conversion
- Q20: Data integrity constraints

---

## Part 2: Advanced SQL (20 Questions, 4 points each = 80 points)

**Q21:** What does EXISTS do?
- A) Checks if a value exists in list
- B) Checks if rows exist in subquery
- C) Creates table if doesn't exist
- D) Verifies column exists

**Answer: B** - EXISTS checks for row existence.

---

**Q22:** Which is faster for large subqueries?
- A) IN operator
- B) EXISTS operator
- C) Equally fast
- D) Depends on hardware

**Answer: B** - EXISTS is faster for large result sets.

---

**Q23:** What does a correlated subquery reference?
- A) Same table in subquery
- B) Outer query columns
- C) Multiple tables
- D) Aggregate functions only

**Answer: B** - Correlated subquery uses outer query columns.

---

**Q24:** What is a CTE (Common Table Expression)?
- A) A subquery in FROM clause
- B) A named subquery with WITH clause
- C) A temporary table
- D) A view

**Answer: B** - CTE is defined with WITH clause.

---

**Q25:** Can a recursive CTE reference itself?
- A) No, never
- B) Yes, in base case only
- C) Yes, in recursive case
- D) No, creates infinite loop

**Answer: C** - Recursive CTE references itself in recursive member.

---

**Q26:** What does ROW_NUMBER() do with ties?
- A) Assigns same number
- B) Assigns sequential numbers
- C) Returns error
- D) Skips numbers

**Answer: B** - ROW_NUMBER assigns unique sequential numbers.

---

**Q27:** What is difference between RANK and DENSE_RANK?
- A) No difference
- B) RANK skips numbers for ties
- C) DENSE_RANK doesn't skip
- D) Both B and C

**Answer: D** - RANK skips, DENSE_RANK doesn't.

---

**Q28:** What does LAG(salary, 1) retrieve?
- A) Current row salary
- B) Next row salary
- C) Previous row salary
- D) First row salary

**Answer: C** - LAG gets previous row value.

---

**Q29:** When should you use PARTITION BY in window functions?
- A) Always
- B) When you need separate calculations per group
- C) Never with aggregates
- D) Only with ORDER BY

**Answer: B** - PARTITION BY creates separate windows.

---

**Q30:** What does PIVOT do?
- A) Rotates rows to columns
- B) Aggregates data
- C) Reshapes data from rows to columns
- D) All of above

**Answer: D** - PIVOT transposes rows to columns with aggregation.

---

**Q31-40:** Additional advanced questions
- Q31: Execution plan reading
- Q32: Index usage
- Q33: Query hints
- Q34: Execution statistics
- Q35: Join methods
- Q36: Sort operations
- Q37: Hash aggregation
- Q38: Subquery factoring
- Q39: Materialized views
- Q40: Query rewrite

---

## Part 3: Performance & Architecture (15 Questions, 5 points each = 75 points)

**Q41:** What is the best approach to improve slow query?
- A) Add more indexes
- B) Increase server RAM
- C) Analyze execution plan first
- D) Rewrite with different syntax

**Answer: C** - Analyze plan to identify bottleneck.

---

**Q42:** When should you avoid indexes?
- A) Never avoid
- B) Low cardinality columns
- C) Frequently updated columns
- D) All of above

**Answer: D** - Low cardinality, high update costs.

---

**Q43:** What is cardinality in context of indexes?
- A) Number of columns
- B) Number of rows
- C) Number of unique values
- D) Column data type

**Answer: C** - Cardinality is uniqueness ratio.

---

**Q44:** Which function blocks index usage?
- A) UPPER(column)
- B) SUBSTR(column)
- C) TRUNC(column)
- D) All of above

**Answer: D** - Functions on columns prevent index use.

---

**Q45:** What is the best way to handle NULLs in WHERE?
- A) Ignore them
- B) Use IS NULL explicitly
- C) Use NVL function
- D) Depends on logic

**Answer: B** - Always use IS NULL explicitly.

---

**Q46-55:** Additional performance questions covering:
- Q46: Statistics and ANALYZE
- Q47: Parallel query execution
- Q48: Bitmap indexes
- Q49: Partition pruning
- Q50: Materialized view refresh
- Q51: Parallel DML
- Q52: Flashback features
- Q53: Undo management
- Q54: Buffer pool tuning
- Q55: Storage optimization

---

## Scoring Guide

### Total Points: 215

| Score Range | Level | Recommendation |
|-------------|-------|-----------------|
| 0-70 | Beginner | Review SQL fundamentals |
| 70-120 | Intermediate | Practice advanced queries |
| 120-160 | Advanced | Focus on performance |
| 160-200 | Expert | Interview preparation |
| 200+ | Master | Ready for senior DBA role |

---

## Study Path by Performance

**If you scored 0-70:**
- Master basic SELECT, INSERT, UPDATE, DELETE
- Understand NULL semantics
- Learn JOIN types
- Practice filtering with WHERE

**If you scored 70-120:**
- Deep dive into subqueries
- Master window functions
- Learn CTEs and recursion
- Practice set operations

**If you scored 120-160:**
- Focus on query optimization
- Study execution plans
- Learn indexing strategies
- Practice performance tuning

**If you scored 160-200:**
- Complete all coding challenges
- Study advanced Oracle features
- Interview preparation
- System design questions

**If you scored 200+:**
- Mentor others
- Review architecture decisions
- Stay current with features
- Contribute to team performance

---

## Common Mistakes to Avoid

1. **NULL comparisons:** Always use IS NULL
2. **UNION duplicates:** Use UNION ALL unless you need distinct
3. **Correlated subqueries:** Consider joins for performance
4. **Functions on columns:** Prevent index usage
5. **SELECT *:** Use specific columns
6. **Missing WHERE:** Can return millions of rows
7. **Wrong JOIN type:** Check business logic
8. **Ignoring statistics:** Keep ANALYZE current

---

## Related Topics to Study

- Oracle Database architecture
- Schema design and normalization
- Backup and recovery
- Security and privileges
- Concurrency and locking
- Replication and standby
- Cloud databases
- Performance monitoring tools

---

**Total Study Time:** 1-2 hours
**Difficulty:** Beginner to Advanced
**Topics Covered:** All Oracle SQL fundamentals to advanced patterns

