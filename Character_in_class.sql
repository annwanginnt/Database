CREATE SCHEMA simpsons;


CREATE TABLE simpsons.characters (
    character_id Integer,
    first_name VARCHAR(255),
    last_name VARCHAR(255),
    dob date,
    salary numeric);

DROP TABLE simpsons.characters;

INSERT INTO simpsons.characters (character_id, first_name, last_name, dob, salary)
VALUES (1, 'Homer', 'simpson', '1985-01-01', 50000),
       (2, 'Marge', 'simpson', '1982-03-15', 40000),
        (3, 'Ned', 'Flanders', '1981-10-12', 70000),
        (4, 'Moe', 'Szyslak', '1980-02-01', 80000),
        (5, 'Clancy', 'Wiggum', '1979-05-30', 65000),
        (6, 'Monotgomery', 'burns', '1950-08-07', 50000),
        (7, 'Maggie', 'Simpson', '2020-12-25',0),
        (8, 'Ralph', 'Wiggum', '2014-09-23', 0),
        (9, 'Bart', 'Simpson', '2012-05-01', 0),
        (10, 'Lisa', 'simpson', '2014-07-15', 0),
        (11, 'Sideshow', 'Bob', '1970-01-01',80000);

----- case & when statement
---Create new column 'salary_range' <50k, 50-100k, 100k+

SELECT c.*
FROM simpsons.characters AS c;



--- delete rows no value.
DELETE FROM simpsons.characters
WHERE last_name = 'Thompson';

DELETE FROM simpsons.characters
WHERE salary IS NULL ;

---CASE & WHEN
SELECT c.first_name,
        c.last_name,
        c.dob,
        c.salary,
        CASE
            WHEN c.salary < 50000 THEN '<50k'
            WHEN c.salary BETWEEN 50000 AND 100000 THEN  '50k-100k'
            WHEN c.salary > 100000 THEN '100k+'
            ELSE 'unknown'  ----- SQL do not handle NULL value, that is why must set a value for NULL
        END AS salary_range
------No 标点符号在上面这部分
FROM simpsons.characters AS c
ORDER BY c.salary ASC;

----- you can see SQL does not know how to handle the NULL value. Null as 100k +
UPDATE  simpsons.characters
SET salary = NULL
WHERE first_name = 'Maggie';

---RANK, DENSE-RANK, ROW
----WRITE a query to get the top 3 earners(people with the highest salaries)
---- if there are 100 people's salry is 80000, and you LIMIT 3, then they will not show,
SELECT c.first_name,
       c.last_name,
       c.salary
FROM simpsons.characters AS c
WHERE c.salary IS NOT NULL
ORDER BY c.salary DESC
LIMIT 5;


----WINDOW FUNCTION
----排名
----RANK (1, 1, 3
----DENSE RANK ( no gap) (1, 1, 2, )
SELECT c.first_name,
       c.last_name,
       c.salary,
        RANK() OVER (ORDER BY c.salary DESC) AS salary_rank,
        DENSE_RANK() OVER (ORDER BY c.salary DESC) AS salary_dense_rank
FROM simpsons.characters AS c
WHERE c.salary IS NOT NULL;



SELECT c.first_name,
       c.last_name,
       c.salary,
        RANK() OVER (ORDER BY c.salary DESC) AS salary_rank,
        DENSE_RANK() OVER (ORDER BY c.salary DESC) AS salary_dense_rank,
        ROW_NUMBER() over (ORDER BY c.salary DESC) AS salary_row_number
FROM simpsons.characters AS c
WHERE c.salary IS NOT NULL;

------RANK by family by salary

SELECT c.first_name,
       c.last_name,
       c.salary,
       RANK() OVER (PARTITION BY c.last_name ORDER BY c.salary DESC) AS salary_rank
FROM simpsons.characters AS c
WHERE c.salary IS NOT NULL
ORDER BY c.last_name, c.salary DESC;


----RANK families by total income

SELECT c.last_name,
    SUM(c.salary) AS total_income,
    RANK() OVER (ORDER BY SUM(c.salary) DESC) AS family_rank
FROM simpsons.characters AS c
GROUP BY c.last_name;


-----EXTRACT date, month, etc
SELECT c.first_name,
       c.last_name,
       c.dob,
       DATE_PART('year', c.dob) AS birth_year,
       DATE_PART('month', c.dob) AS birth_month,
       AGE(c.dob)
FROM simpsons.characters AS c;


SELECT c.first_name,
       c.last_name,
       c.dob,
       DATE_PART('year', c.dob) AS birth_year,
       EXTRACT('year' FROM c.dob) AS birth_month,
       EXTRACT('year' FROM AGE(c.dob))

FROM simpsons.characters AS c;

----RANK people by age, the youngest #1
SELECT c.first_name,
       c.last_name,
       c.dob,
       c.salary,
        RANK() OVER (ORDER BY AGE(C.dob) ASC) AS age_rank
FROM simpsons.characters AS c;


-----SWITCH to bakery sale

SELECT bs.article,
       SUM(bs.quantity*unit_price) AS revenue,
        RANK() OVER (ORDER BY SUM(bs.quantity*unit_price) DESC) As sales_rank
FROM assignment01.bakery_sales AS bs
where unit_price IS NOT NULL
GROUP BY bs.article
ORDER BY revenue DESC;

SELECT EXTRACT('year' FROM bs.sale_datetime) AS sale_year,
        EXTRACT('month' FROM bs.sale_datetime) AS sale_month,
        bs.article,
        SUM(bs.quantity*unit_price) AS revenue,
        RANK() OVER (
            PARTITION BY EXTRACT('year' FROM bs.sale_datetime),  EXTRACT('month' FROM bs.sale_datetime)
            ORDER BY SUM(bs.quantity*bs.unit_price) DESC
            ) AS sale_rank
FROM assignment01.bakery_sales AS bs
WHERE bs.unit_price IS NOT NULL
GROUP BY 1, 2, 3
ORDER BY 1,2,4 DESC ;


WITH ranked_products AS (SELECT EXTRACT('year' FROM bs.sale_datetime)  AS sale_year,
                                EXTRACT('month' FROM bs.sale_datetime) AS sale_month,
                                bs.article,
                                SUM(bs.quantity * unit_price)          AS revenue,
                                RANK() OVER (
                                    PARTITION BY EXTRACT('year' FROM bs.sale_datetime), EXTRACT('month' FROM bs.sale_datetime)
                                    ORDER BY SUM(bs.quantity * bs.unit_price) DESC
                                    )  AS sale_rank
                         FROM assignment01.bakery_sales AS bs
                         WHERE bs.unit_price IS NOT NULL
                         GROUP BY 1, 2, 3
                         ORDER BY 1, 2, 4 DESC)
SELECT *
FROM ranked_products
WHERE sale_rank <= 3;
