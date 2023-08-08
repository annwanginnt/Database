
--MMAI5100 Database : Assignment 1-Basic SQL

SELECT *
FROM assignment01.bakery_sales;

--Q1: Identify the items with the highest and lowest(non-zero) unit price

SELECT MAX(unit_price) AS highest_price,
        MIN(unit_price) AS lowest_price
FROM assignment01.bakery_sales
WHERE unit_price > 0;

--Q2 Report the second most sold item from the bakery table. If there is no second most sold item, the query should report NULL.
SELECT
    bs.article,
    SUM(bs.quantity) AS sum_quantity
FROM assignment01.bakery_sales AS bs
GROUP BY bs.article
ORDER BY sum_quantity DESC
LIMIT 1 OFFSET 1;



--Q3 Report the top 3 most sold items for every month in 2022 including their monthly sales.

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
WHERE ranked_products.sale_year ='2022'
AND sale_rank <= 3;


--Q4 Report all the tickets with 5 or more articles in August 2022 including the number of articles in each ticket.

SELECT
    DATE_PART('year', bs.sale_date) AS sale_year,
    DATE_PART('month', bs.sale_date) AS sale_month,
    bs.quantity
FROM assignment01.bakery_sales AS bs
WHERE bs.quantity > 5
     AND DATE_PART('month', bs.sale_date) = 8
    AND DATE_PART('year', bs.sale_date) = 2022;

--Q5 Calculate the average sales per day in August 2022
SELECT
    DATE_PART('year', bs.sale_date) AS sale_year,
    DATE_PART('month', bs.sale_date) AS sale_month,
    date_part('day', bs.sale_date) AS sale_day,
    AVG(bs.unit_price * bs.quantity) AS avg_sales
FROM assignment01.bakery_sales AS bs
WHERE DATE_PART('month', bs.sale_date) = 8
GROUP BY sale_year, sale_month, sale_day;

--Q6 Identify the day of the week with more sales.
SELECT
    date_part('dow', bs.sale_date) AS dow,
    SUM(bs.unit_price * bs.quantity) AS sum_sales
FROM assignment01.bakery_sales AS bs
GROUP BY dow
ORDER BY sum_sales DESC ;

--Q7 What time of the day is the traditional Baguette more popular?
    -- 11:00 has the most traditional Baguette sale, following by 10:00 and 12:00.
SELECT
    date_part('hour', bs.sale_time) AS hours,
    bs.article,
    SUM(bs.quantity) AS sum_quantity
FROM assignment01.bakery_sales AS bs
WHERE bs.article = 'TRADITIONAL BAGUETTE'
GROUP BY date_part('hour', bs.sale_time), bs.article
ORDER BY sum_quantity DESC;

--Q8 Find the articles with the lowest sales in each month

SELECT
    date_part('month', bs.sale_date) AS month,
    bs.article,
    MIN(bs.unit_price * bs.quantity) AS min_sales
FROM assignment01.bakery_sales AS bs
GROUP BY date_part('month', bs.sale_date), bs.article
HAVING MIN(bs.unit_price * bs.quantity) > 0
ORDER BY month ASC , min_sales ASC;

--Q9 Calculate the % of sales for each item between 2022-01-01 and 2022-01-31
SELECT
    bs.article,
    ROUND(SUM(bs.unit_price * bs.quantity) / total_sales.total * 100 ,2) AS percentage_sales
FROM assignment01.bakery_sales AS bs
CROSS JOIN (
    SELECT SUM(bs.unit_price * bs.quantity) AS total
    FROM assignment01.bakery_sales AS bs
    WHERE bs.sale_date >= '2022-01-01' AND bs.sale_date <= '2022-01-31'
) AS total_sales
WHERE bs.sale_date >= '2022-01-01' AND bs.sale_date <= '2022-01-31'
GROUP BY bs.article, total_sales.total
ORDER BY percentage_sales DESC;

--Q10 Calculate the order rate for the Banette for every month during 2022

SELECT
    date_part('year', bs.sale_date) AS year,
    date_part('month', bs.sale_date) AS month,
    bs.article,
    SUM(bs.quantity) / total_quantity.total_quantity * 100 AS order_rate
FROM assignment01.bakery_sales AS bs
CROSS JOIN (
    SELECT date_part('month', sale_date) AS sale_month, SUM(quantity) AS total_quantity
    FROM assignment01.bakery_sales
    WHERE date_part('year', sale_date) = 2022
    GROUP BY sale_month
) AS total_quantity

WHERE date_part('year', bs.sale_date) = 2022
    AND date_part('month', bs.sale_date) = total_quantity.sale_month
    AND bs.article ='BANETTE'
GROUP BY year, month, bs.article, total_quantity.total_quantity
ORDER BY year, month;


SELECT
    date_part('year', bs.sale_date) AS year,
    date_part('month', bs.sale_date) AS month,
    bs.article,
    CAST(SUM(bs.quantity) AS decimal) / total_quantity.total_quantity * 100 AS order_rate
FROM assignment01.bakery_sales AS bs
CROSS JOIN (
    SELECT date_part('month', sale_date) AS sale_month, SUM(quantity) AS total_quantity
    FROM assignment01.bakery_sales
    WHERE date_part('year', sale_date) = 2022
    GROUP BY sale_month
) AS total_quantity
WHERE date_part('year', bs.sale_date) = 2022
    AND date_part('month', bs.sale_date) = total_quantity.sale_month
    AND bs.article = 'BANETTE'
GROUP BY year, month, bs.article, total_quantity.total_quantity
ORDER BY year, month;

--Q10 AVG revenue by day, in august of 2022
SELECT
    date_part('year',bs.sale_date) AS year,
    date_part('month',bs.sale_date) AS month,
    date_part('day', bs.sale_date) AS day,
    ROUND(AVG(bs.unit_price * bs.quantity),2) AS avg_revenue
FROM assignment01.bakery_sales AS bs
WHERE
    date_part('month',bs.sale_date) = 8 AND
    date_part('year',bs.sale_date) = 2022 AND
    bs.unit_price IS NOT NULL
GROUP BY 1,2,3
ORDER BY 1,2,3;
