CREATE SCHEMA schulich;
CREATE TABLE instructors (
    first_name VARCHAR(255),
    last_name VARCHAR(255),
    age integer
);


INSERT INTO schulich.instructors (first_name, last_name, age)
VALUES ('Nara', 'Tan', 18);

INSERT INTO schulich.instructors (first_name, last_name, age)
VALUES ('Kanmani', 'RATNA', 16);

UPDATE schulich.instructors
SET age = 25
WHERE first_name = 'Kanmani'
 AND  last_name = 'RATNA';

ALTER TABLE schulich.instructors
ADD COLUMN instructor_id INTEGER;

UPDATE schulich.instructors
SET instructor_id = 1
WHERE first_name = 'Nara'

UPDATE schulich.instructors
SET instructor_id = 2
WHERE first_name = 'Kanmani'

INSERT INTO schulich.instructors (first_name, last_name, age)
VALUES ('Joanna', 'Wang', 5);

INSERT INTO schulich.instructors (first_name, last_name, age)
VALUES ('Tina', 'Fell', 20);

UPDATE schulich.instructors
SET instructor_id = 3
WHERE first_name = 'Joanna'

UPDATE schulich.instructors
SET instructor_id = 4
WHERE first_name = 'Joanna'
 AND  age = '5'

INSERT INTO schulich.instructors (first_name, last_name, age)
VALUES ('Joanna', 'Wang', 15);

DELETE FROM schulich.instructors
WHERE instructors.instructor_id IS NULL

SELECT *
FROM schulich.instructors

SELECT first_name,
       last_name,
       age
FROM schulich.instructors

SELECT COUNT(*)
FROM schulich.instructors;

SELECT COUNT(first_name)
FROM schulich.instructors

SELECT COUNT(DISTINCT first_name)
FROM schulich.instructors

SELECT AVG(age)
FROM schulich.instructors

SELECT COUNT(*)
FROM assignment01.bakery_sales;

SELECT COUNT(*) AS row_count
FROM assignment01.bakery_sales;

SELECT MAX(unit_price) AS highest_price,
       MIN(unit_price) AS lowest_price,
       AVG(unit_price) AS average_price
FROM assignment01.bakery_sales;

SELECT *
FROM assignment01.bakery_sales
WHERE unit_price = (SELECT MAX(unit_price) FROM assignment01.bakery_sales)
   OR unit_price = (SELECT MIN(unit_price) FROM assignment01.bakery_sales);

SELECT MAX(bs.unit_price) AS highest_price,
       MIN(bs.unit_price) AS lowest_price,
       AVG(bs.unit_price) AS average_price
FROM assignment01.bakery_sales AS bs;

SELECT MAX(bs.unit_price) AS highest_price,
       MIN(bs.unit_price) AS lowest_price,
       AVG(bs.unit_price) AS average_price
FROM assignment01.bakery_sales AS bs
WHERE bs.sale_date = '2021-01-02'
 AND bs.sale_time BETWEEN '9:00:00' AND '10:00:00';

SELECT MAX(bs.unit_price) AS highest_price,
       MIN(bs.unit_price) AS lowest_price,
       AVG(bs.unit_price) AS average_price
FROM assignment01.bakery_sales AS bs
WHERE bs.article = 'BAGUETTE'

SELECT bs.article,
       MAX(bs.unit_price) AS highest_price,
       MIN(bs.unit_price) AS lowest_price
FROM assignment01.bakery_sales AS bs
WHERE bs.article LIKE '% BAGUETTE%'
GROUP BY bs.article;

SELECT bs.sale_datetime,
       bs.ticket_number,
       bs.article,
       bs.quantity,
       bs.unit_price*quantity AS revenue
FROM assignment01.bakery_sales AS bs
WHERE bs.article LIKE '% BAGUETTE';


SELECT bs.sale_datetime,
       bs.ticket_number,
       bs.article,
       LOWER(bs.article) AS article_name_lowercase,
       bs.quantity,
       bs.unit_price*quantity AS revenue
FROM assignment01.bakery_sales AS bs
WHERE LOWER(bs.article) LIKE 'baguette%';

SELECT distinct (bs.article)
FROM assignment01.bakery_sales AS bs
WHERE bs.article LIKE '%BAGUETTE%'

--Find all records for the DEMI and Cereal BAGUETTES
SELECT*
FROM assignment01.bakery_sales AS bs
WHERE bs.article = 'DEMI BAGUETTE'
OR bs.article = 'CEREAL BAGUETTES'

SELECT*
FROM assignment01.bakery_sales AS bs
WHERE bs.article IN ('DEMI BAGUETTE','CEREAL BAGUETTES')

SELECT*
FROM assignment01.bakery_sales AS bs
WHERE bs.ticket_number IN (150060, 150065, 150078)

SELECT*
FROM assignment01.bakery_sales AS bs
WHERE cast(bs.ticket_number AS text) LIKE '1500__'--("_" only represent one decimal place, "__" represents two decimal places)

-- TIME FUNCTIONS: DATE_PART
SELECT*
FROM assignment01.bakery_sales AS bs
WHERE cast(bs.sale_time AS text) LIKE '09:%'

SELECT bs.sale_datetime,
       date_part('year', bs.sale_datetime) AS sale_year,
       date_part('month', bs.sale_datetime) AS sale_month,
       date_part('day', bs.sale_datetime) AS sale_day,
       date_part('hour', bs.sale_datetime) AS sale_hour,
       date_part('millisecond', bs.sale_datetime) AS sale_millisecond,
       bs.sale_date,
       bs.ticket_number,
       bs.article,
       bs.quantity
FROM assignment01.bakery_sales AS bs;

SELECT*
FROM assignment01.bakery_sales AS bs
WHERE cast(bs.sale_time AS text) LIKE '09:%'

SELECT bs.sale_datetime,
       date_part('year', bs.sale_datetime) AS sale_year,
       extract('year' FROM  bs.sale_datetime) AS sale_year_with_extract,
       date_part('month', bs.sale_datetime) AS sale_month,
       date_part('day', bs.sale_datetime) AS sale_day,
       date_part('hour', bs.sale_datetime) AS sale_hour,
       date_part('millisecond', bs.sale_datetime) AS sale_millisecond,
       bs.sale_date,
       bs.ticket_number,
       bs.article,
       bs.quantity
FROM assignment01.bakery_sales AS bs;

SELECT CURRENT_DATE,
SELECT CURRENT_TIMESTAMP --UTC time

SELECT CURRENT_DATE,
       date_part('year', CURRENT_DATE),
       date_part('month', CURRENT_DATE),
       date_part('day', CURRENT_DATE),
       date_part('dow', CURRENT_DATE)--day of week

--CALCULATE Revenue by Year and Month
SELECT date_part('year', bs.sale_datetime) AS sale_year,
       date_part('month', bs.sale_datetime) AS sale_month,
       SUM(bs.quantity*bs.unit_price) AS revenue
FROM assignment01.bakery_sales AS bs
GROUP BY sale_year, sale_month;
ORDER BY sale_year, sale_month;

WITH monthly_sales AS (
            SELECT date_part('year', bs.sale_datetime)  AS sale_year,
                   date_part('month', bs.sale_datetime) AS sale_month,
                   SUM(bs.quantity * bs.unit_price)  AS revenue
            FROM assignment01.bakery_sales AS bs
            GROUP BY sale_year, sale_month
            ORDER BY sale_year, sale_month
)
SELECT sale_year, avg(revenue)
FROM monthly_sales
GROUP BY sale_year;

SELECT date_part('year', bs.sale_datetime) AS sale_year,
       date_part('month', bs.sale_datetime) AS sale_month,
       SUM(bs.quantity*bs.unit_price) AS revenue
FROM assignment01.bakery_sales AS bs
GROUP BY sale_year, sale_month;
ORDER BY sale_year, sale_month;
avg(revenue);
GROUP BY sale_year;