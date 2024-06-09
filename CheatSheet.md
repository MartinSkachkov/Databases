## INSERT

```sql
INSERT INTO table_name (column1, column2, column3, ...)
VALUES (value1, value2, value3, ...);
```


## DELETE

```sql
DELETE FROM table_name 
WHERE condition;
```

## UPDATE

SQL

```sql
UPDATE table_name
SET column1 = value1, column2 = value2, ...
WHERE condition;
```
## ALTER TABLE

```sql
ALTER TABLE table_name
ADD column_name datatype;
```

```sql
ALTER TABLE table_name
DROP COLUMN column_name;
```

```sql
CONSTRAINT c_name DEFAULT def_value
CONSTRAINT c_name PRIMARY KEY (col1, ...)
CONSTRAINT c_name FOREIGN KEY (col1, ...)
CONSTRAINT c_name UNIQUE (col1, ...)
CONSTRAINT c_name CHECK (YEAR >= 1975)
```
## CREATE VIEW

```sql
CREATE VIEW view_name AS
SELECT column1, column2, ...
FROM table_name
WHERE condition
GO;
```

## CREATE VIEW WITH SCHEMABINDING

```sql
CREATE VIEW view_name WITH SCHEMABINDING AS
SELECT column1, column2, ...
FROM schema_name.table_name
WHERE condition
GO;
```

## CREATE VIEW WITH CHECK OPTION

```sql
CREATE VIEW view_name AS
SELECT column1, column2, ...
FROM table_name
WHERE condition
WITH CHECK OPTION
GO;
```

## ALTER VIEW


```sql
ALTER VIEW view_name AS
SELECT column1, column2, ...
FROM table_name
WHERE condition;
```

## DROP VIEW

```sql
DROP VIEW view_name;
```


## CREATE TRIGGER

```sql
CREATE TRIGGER trigger_name ON table_name
AFTER/INSTEAD OF INSERT/UPDATE/DELETE
AS
BEGIN
   -- SQL statements to be executed
END
GO;
```

## ALTER TRIGGER

SQL

```sql
ALTER TRIGGER trigger_name ON table_name
AFTER/INSTEAD OF INSERT/UPDATE/DELETE
AS
BEGIN
   -- SQL statements to be executed
END
GO;
```

## DROP TRIGGER

```sql
DROP TRIGGER trigger_name;
```

## Използване на  `CASE WHEN`  в SQL

```sql
SELECT employee_id,
    CASE 
        WHEN salary > 50000 THEN 'High'
        ELSE 'Low'
    END as salary_category
FROM employees;
```

## Използване на  `CASE WHEN`  с агрегатни функции

```sql
SELECT AVG(CASE WHEN salary > 50000 THEN salary ELSE NULL END) as AverageHighSalary
FROM employees;
```