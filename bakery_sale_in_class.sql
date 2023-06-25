CREATE SCHEMA schulich;


CREATE TABLE instructors (
    first_name VARCHAR(255),
    last_name VARCHAR(255),
    age integer
);

DROP TABLE instructors

INSERT INTO schulich.instructors(first_name, last_name, age)
VALUES('Ann', 'Wang', 25)

INSERT INTO schulich.instructors(first_name, last_name, age)







SELECT COUNT(*)
FROM assignment01.bakery_sales;


SELECT *
FROM assignment01.bakery_sales;

SELECT COUNT(*)
FROM assignment01.bakery_sales
WHERE ticket_number = 150043;

SELECT min(unit_price) as lowest_price
FROM assignment01.bakery_sales

SELECT max(unit_price) as highest_price
FROM assignment01.bakery_sales

SELECT avg(unit_price) as average
FROM assignment01.bakery_sales

SELECT MIN(bs.unit_price)AS min_unit_price,
       MAX(bs.unit_price) AS max_unit_price,
       avg(bs.unit_price) AS avg_unit_price
FROM assignment01.bakery_sales AS bs;
WHERE bs.sale_date = '20210-1-02'

SELECT MIN(unit_price) min_unit_price,
       MAX(unit_price) max_unit_price,
       avg(unit_price) avg_unit_price
FROM assignment01.bakery_sales;

SELECT MIN(bs.unit_price)AS min_unit_price,
       MAX(bs.unit_price) AS max_unit_price,
       avg(bs.unit_price) AS avg_unit_price
FROM assignment01.bakery_sales AS bs
WHERE bs.sale_date = '2021-01-02'
 AND bs.sale_time BETWEEN '9:00:00' AND '10:00:00';


SELECT MIN(bs.unit_price)AS min_unit_price,
       MAX(bs.unit_price) AS max_unit_price,
       avg(bs.unit_price) AS avg_unit_price
FROM assignment01.bakery_sales AS bs
WHERE bs.article = 'TRADITIONAL BAGUETTE'

SELECT bs.article,
       MIN(bs.unit_price) AS min_unit_price,
       MAX(bs.unit_price) AS max_unit_price,
       avg(bs.unit_price) AS avg_unit_price
FROM assignment01.bakery_sales AS bs
GROUP BY bs.article;




SELECT bs.article,
       MIN(bs.unit_price) AS min_unit_price,
       MAX(bs.unit_price) AS max_unit_price
FROM assignment01.bakery_sales AS bs
GROUP BY bs.article;

SELECT bs.article,
       MIN(bs.unit_price) AS min_unit_price,
       MAX(bs.unit_price) AS max_unit_price
FROM assignment01.bakery_sales AS bs
WHERE bs.article LIKE '%BAGUETTE%'
GROUP BY bs.article;

SELECT bs.article,
       MIN(bs.unit_price) AS min_unit_price,
       MAX(bs.unit_price) AS max_unit_price
FROM assignment01.bakery_sales AS bs
WHERE bs.article LIKE '%BAGUETTE'
GROUP BY bs.article;

SELECT bs.article,
       MIN(bs.unit_price) AS min_unit_price,
       MAX(bs.unit_price) AS max_unit_price
FROM assignment01.bakery_sales AS bs
WHERE bs.article LIKE '% BAGUETTE'
GROUP BY bs.article;

--- write a query to return sales, date, time,ticket number, article, quantity, revenue
SELECT bs.sale_datetime,
       bs.ticket_number,
       bs.article,
        bs.quantity,
       bs.quantity*unit_price AS revenue
FROM assignment01.bakery_sales AS bs
WHERE bs.ticket_number = 150062;

SELECT bs.sale_datetime,
       bs.ticket_number,
       bs.article,
        bs.quantity,
       bs.quantity*unit_price AS revenue
FROM assignment01.bakery_sales AS bs
WHERE bs.ticket_number = 150062
AND   bs.quantity*unit_price = 0.15;

SELECT bs.sale_datetime,
       bs.ticket_number,
       bs.article,
        bs.quantity,
       bs.quantity*unit_price AS revenue
FROM assignment01.bakery_sales AS bs
WHERE bs.ticket_number = 150062
AND   bs.quantity*unit_price > 2;

SELECT bs.sale_datetime,
       bs.ticket_number,
       bs.article,
        bs.quantity,
       bs.quantity*unit_price AS revenue
FROM assignment01.bakery_sales AS bs
WHERE bs.ticket_number = 150062
AND   bs.quantity*unit_price < 0;

SELECT bs.sale_datetime,
       bs.ticket_number,
       bs.article,
        bs.quantity,
       bs.quantity*unit_price AS revenue
FROM assignment01.bakery_sales AS bs
WHERE bs.ticket_number >= 150060
AND   bs.quantity*unit_price <= 150070;

SELECT bs.sale_datetime,
       bs.ticket_number,
       bs.article,
        bs.quantity,
       bs.quantity*unit_price AS revenue
FROM assignment01.bakery_sales AS bs
WHERE bs.ticket_number BETWEEN 150060 AND 150070;

SELECT bs.sale_datetime,
       bs.ticket_number,
       bs.article,
        bs.quantity,
       bs.quantity*unit_price AS revenue
FROM assignment01.bakery_sales AS bs
WHERE bs.sale_date between '2022-01-01' and '2022-01-31'
ORDER BY bs.sale_date desc;

---comparing operators: not equal <>  or !=

SELECT bs.sale_datetime,
       bs.ticket_number,
       bs.article,
        bs.quantity,
       bs.quantity*unit_price AS revenue
FROM assignment01.bakery_sales AS bs
WHERE bs.ticket_number = 150063
ORDER BY bs.unit_price*bs.quantity;

--- YOU CAN ORDER BY Column number
SELECT bs.sale_datetime,
       bs.ticket_number,
       bs.article,
        bs.quantity,
       bs.quantity*unit_price AS revenue
FROM assignment01.bakery_sales AS bs
WHERE bs.ticket_number = 150063
ORDER BY 5 DESC;
--- compare string, you need use ''
--- LIKE (WILDCARDS) notation
-- filter for and| or operators
SELECT bs.sale_datetime,
       bs.ticket_number,
       bs.article,
        bs.quantity,
       bs.quantity*unit_price AS revenue
FROM assignment01.bakery_sales AS bs
WHERE bs.article = 'Mexican Baguette'
OR bs.article = 'Italian Baguette'
OR bs.article = 'Veggie Baguette';

--- when you not sure how many types ariticles you have.
--- case sensitive
SELECT bs.sale_datetime,
       bs.ticket_number,
       bs.article,
        bs.quantity,
       bs.quantity*unit_price AS revenue
FROM assignment01.bakery_sales AS bs
WHERE bs.article LIKE '%Baguette';

--- convert lower or upper case
SELECT bs.sale_datetime,
       bs.ticket_number,
       bs.article,
       ---lower(bs.article) AS artical_name_lowercase,
        bs.quantity,
       bs.quantity*unit_price AS revenue
FROM assignment01.bakery_sales AS bs
WHERE LOWER(bs.article)LIKE '%baguette';


---retrieve unique values from a specific column or combination of columns in a result set. It eliminates duplicate rows,
SELECT DISTINCT (bs.article)
FROM assignment01.bakery_sales AS bs
WHERE upper(bs.article) LIKE '%BAGUETTE%';

SELECT bs.article
FROM assignment01.bakery_sales AS bs
WHERE upper(bs.article) LIKE '%BAGUETTE%';

--Find all records for the DEMI and CEREAL BAGUETTES
SELECT *
FROM assignment01.bakery_sales AS bs
WHERE bs.article = 'DEMI BAGUETTES'
    OR bs.article ='CEREAL BAGUETTE';

SELECT *
FROM assignment01.bakery_sales AS bs
WHERE bs.article IN ('DEMI BAGUETTES', 'CEREAL BAGUETTE');


SELECT *
FROM assignment01.bakery_sales AS bs
WHERE bs.ticket_number IN (150060, 150061, 150062, 150063);

---Ticket_number is int, not str. '_' exactly ONE. __ two.
--  the CAST function is used to convert a value of one data type to another data type.
SELECT *
FROM assignment01.bakery_sales AS bs
WHERE CAST(bs.ticket_number AS TEXT) LIKE '1500__';

UPDATE assignment01.bakery_sales (article)
VALUES ('test_baguette')
WHERE upper()

SELECT *
FROM assignment01.bakery_sales AS bs
WHERE CAST(bs.sale_date AS text) LIKE '2022-01-01';

SELECT *
FROM assignment01.bakery_sales AS bs
WHERE CAST(bs.sale_time AS text) LIKE '09:%'

-- Revenue by month, year.
-- Time function, extract
SELECT bs.sale_datetime,
       date_part('year', bs.sale_datetime) AS sale_year,
       date_part('month', bs.sale_datetime) AS sale_month,
       date_part('day', bs.sale_datetime) AS sale_day,
       date_part('hour', bs.sale_datetime) AS sale_hour,
       date_part('minute',bs.sale_datetime) AS sale_minute,
       date_part('second', bs.sale_datetime) AS sale_second,
       date_part('millisecond', bs.sale_datetime) AS sale_millisecond,
       date_part('microsecond', bs.sale_datetime) AS sale_microsecond,
       bs.sale_date,
       bs.ticket_number,
       bs.article,
       bs.quantity
FROM assignment01.bakery_sales AS bs;


SELECT bs.sale_datetime,
       date_part('year', bs.sale_datetime) AS sale_year,
       extract('year' FROM bs.sale_datetime) AS sale_year_with_extract,
       date_part('month', bs.sale_datetime) AS sale_month,
       date_part('day', bs.sale_datetime) AS sale_day,
       date_part('hour', bs.sale_datetime) AS sale_hour,
       date_part('minute',bs.sale_datetime) AS sale_minute,
       date_part('second', bs.sale_datetime) AS sale_second,
       date_part('millisecond', bs.sale_datetime) AS sale_millisecond,
       date_part('microsecond', bs.sale_datetime) AS sale_microsecond,
       bs.sale_date,
       bs.ticket_number,
       bs.article,
       bs.quantity
FROM assignment01.bakery_sales AS bs;

SELECT CURRENT_DATE;
SELECT CURRENT_TIMESTAMP;

--UNIX TIME is another way for timestamp

SELECT CURRENT_DATE,
       date_part('year', CURRENT_DATE),
        date_part('month', CURRENT_DATE),
        date_part('day', CURRENT_DATE),
        date_part('dow', CURRENT_DATE),


-- CALCULATE Revenue by year and month
SELECT date_part('year', bs.sale_datetime) AS  sale_year,
       date_part('month', bs.sale_datetime) AS sale_month,
        SUM(bs.quantity*bs.unit_price) AS revenue
FROM assignment01.bakery_sales AS bs
GROUP BY sale_year, sale_month
ORDER BY sale_year, sale_month;

-- Calculate average revenue by year
-- State this table as 'Monthly _sales" temporaly.
-- Common table expression
WITH monthly_sales AS(
     SELECT date_part('year', bs.sale_datetime) AS  sale_year,
       date_part('month', bs.sale_datetime) AS sale_month,
        SUM(bs.quantity*bs.unit_price) AS revenue
    FROM assignment01.bakery_sales AS bs
    GROUP BY sale_year, sale_month
    ORDER BY sale_year, sale_month
)

--- then query from the temporary table
SELECT *
FROM monthly_sales;


WITH monthly_sales AS(
     SELECT date_part('year', bs.sale_datetime) AS  sale_year,
       date_part('month', bs.sale_datetime) AS sale_month,
        SUM(bs.quantity*bs.unit_price) AS revenue
    FROM assignment01.bakery_sales AS bs
    GROUP BY sale_year, sale_month
    ORDER BY sale_year, sale_month
)

--- then query from the temporary table
SELECT *
FROM monthly_sales
WHERE sale_year = 2021;

---- two query, step 1,setup a temporary table,  step 2: write query from the temparory  table.
WITH monthly_sales AS(
     SELECT date_part('year', bs.sale_datetime) AS  sale_year,
       date_part('month', bs.sale_datetime) AS sale_month,
        SUM(bs.quantity*bs.unit_price) AS revenue
    FROM assignment01.bakery_sales AS bs
    GROUP BY sale_year, sale_month
    ORDER BY sale_year, sale_month
)

--- then query from the temporary table
SELECT sale_year, AVG(revenue)
FROM monthly_sales
GROUP BY sale_year;






