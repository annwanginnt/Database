SELECT *
FROM fact_tables.orders


---THIS IS WRONG,NEED ADD DISTINCT FUNCTION
SELECT
    o.order_id,
    SUM(o.order_number)
FROM fact_tables.orders AS o
GROUP BY o.order_id

SELECT
    o.order_number,
    o.order_item_id
FROM fact_tables.orders AS o
WHERE o.order_number = 430746720;

SELECT *
FROM fact_tables.orders AS o
WHERE o.order_number = 430746720;

---WHERE is only for primary column, HAVING is for aggregation
SELECT o.order_number,
       COUNT(DISTINCT  o.order_item_id) AS no_of_items
FROM fact_tables.orders AS o
GROUP BY o.order_number
HAVING COUNT(DISTINCT o.order_item_id) > 1
ORDER BY 2 DESC ;

SELECT *
FROM fact_tables.orders;

SELECT *
FROM fact_tables.conversions;


---- how many customers have more than one conversions
SELECT cs.fk_customer,
       COUNT(cs.conversion_id) AS no_of_conversions
FROM fact_tables.conversions AS cs
GROUP BY cs.fk_customer
HAVING COUNT(DISTINCT cs.conversion_id) > 1
ORDER BY 2 DESC;

SELECT cs.conversion_id,
       cs.fk_customer,
       cs.conversion_date,
       cs.conversion_type
FROM fact_tables.conversions AS cs
ORDER BY cs.fk_customer, cs,conversion_date


--LEAD help you look at the next conversion BY  PARTITION
SELECT cs.conversion_id,
       cs.fk_customer,
       cs.conversion_date,
       cs.conversion_type,
       LEAD(cs.conversion_date) OVER(PARTITION BY cs.fk_customer ORDER BY cs.conversion_date) AS next_conversion
FROM fact_tables.conversions AS cs
ORDER BY cs.fk_customer, cs,conversion_date;


---look at two version of next conversion, 1 and nothing is the same, only when you need more than 1, you need specify
--next version LEAD
SELECT cs.conversion_id,
       cs.fk_customer,
       cs.conversion_date,
       cs.conversion_type,
       LEAD(cs.conversion_date, 2) OVER(PARTITION BY cs.fk_customer ORDER BY cs.conversion_date) AS next_conversion
FROM fact_tables.conversions AS cs
ORDER BY cs.fk_customer, cs,conversion_date;

--- previouse version  LAG
SELECT cs.conversion_id,
       cs.fk_customer,
       cs.conversion_date,
       cs.conversion_type,
         LAG(cs.conversion_date) OVER(PARTITION BY cs.fk_customer ORDER BY cs.conversion_date) AS previous_conversion,
       LEAD(cs.conversion_date, 2) OVER(PARTITION BY cs.fk_customer ORDER BY cs.conversion_date) AS next_conversion
FROM fact_tables.conversions AS cs
ORDER BY cs.fk_customer, cs,conversion_date;

-- create a column, calculate the conversion number.

SELECT cs.conversion_id,
       cs.fk_customer,
       cs.conversion_date,
       cs.conversion_type,
       row_number() OVER( PARTITION BY cs.fk_customer ORDER BY cs.conversion_id) AS conversion_nubmer,
         LAG(cs.conversion_date) OVER(PARTITION BY cs.fk_customer ORDER BY cs.conversion_date) AS previous_conversion,
       LEAD(cs.conversion_date, 2) OVER(PARTITION BY cs.fk_customer ORDER BY cs.conversion_date) AS next_conversion
FROM fact_tables.conversions AS cs
ORDER BY cs.fk_customer, cs,conversion_date;


----Join tables
--INNER JOIN, using ON
--result does not have NULL
SELECT *
-- OR cs.*, cd.*
FROM fact_tables.conversions AS cs
INNER JOIN dimensions.customer_dimension AS cd
--which columns are used for joining
 ON cs.fk_customer = cd.sk_customer;

-- only include columns from conversion table
SELECT
    cs.*
FROM fact_tables.conversions AS cs
INNER JOIN dimensions.customer_dimension AS cd
--which columns are used for joining
 ON cs.fk_customer = cd.sk_customer;

-- include all columns from customer table
SELECT
    cd.*
FROM fact_tables.conversions AS cs
INNER JOIN dimensions.customer_dimension AS cd
--which columns are used for joining
 ON cs.fk_customer = cd.sk_customer;

SELECT
    cs.conversion_id,
    cd.customer_id,
    cd.first_name,
    cd.last_name,
     row_number() OVER( PARTITION BY cs.fk_customer ORDER BY cs.conversion_id) AS conversion_nubmer,
    cs.conversion_date,
    cs.conversion_type
FROM fact_tables.conversions AS cs
INNER JOIN dimensions.customer_dimension AS cd
--which columns are used for joining
 ON cs.fk_customer = cd.sk_customer
ORDER BY cd.customer_id, cs.conversion_date;

SELECT
     cd.first_name,
    cd.last_name,
     row_number() OVER( PARTITION BY cs.fk_customer ORDER BY cs.conversion_id) AS conversion_nubmer,
    cs.conversion_date,
    cs.conversion_type
FROM fact_tables.conversions AS cs
INNER JOIN dimensions.customer_dimension AS cd
--which columns are used for joining
 ON cs.fk_customer = cd.sk_customer
ORDER BY cd.customer_id, cs.conversion_date;


-- LEFT JOIN, is the most popular used.
SELECT cd.first_name,
        cd.last_name,
        cs.conversion_date,
        cs.conversion_type
FROM fact_tables.conversions AS cs
LEFT OUTER JOIN dimensions.customer_dimension AS cd
    ON cs.fk_customer = cd.sk_customer;

--RIGHT JOIN, right join  right out join are the same.
SELECT cd.first_name,
        cd.last_name,
        cs.conversion_date,
        cs.conversion_id,
        cs.conversion_type
FROM fact_tables.conversions AS cs
RIGHT JOIN dimensions.customer_dimension AS cd
    ON cs.fk_customer = cd.sk_customer
ORDER BY cd.customer_id, cs.conversion_date;


SELECT cd.first_name,
        cd.last_name,
        cs.conversion_date,
        cs.conversion_id,
        cs.conversion_type
FROM fact_tables.conversions AS cs
RIGHT JOIN dimensions.customer_dimension AS cd
    ON cs.fk_customer = cd.sk_customer
ORDER BY cd.customer_id, cs.conversion_date;


SELECT cd.first_name,
        cd.last_name,
        cs.conversion_date,
        cs.conversion_type,
          row_number() OVER( PARTITION BY cs.fk_customer ORDER BY cs.conversion_id) AS conversion_nubmer,
         LAG(cs.conversion_date) OVER(PARTITION BY cs.fk_customer ORDER BY cs.conversion_date) AS previous_conversion,
       LEAD(cs.conversion_date, 2) OVER(PARTITION BY cs.fk_customer ORDER BY cs.conversion_date) AS next_conversion
FROM fact_tables.conversions AS cs
LEFT OUTER JOIN dimensions.customer_dimension AS cd
    ON cs.fk_customer = cd.sk_customer;

---OUTER is not necessary.
SELECT cd.first_name,
        cd.last_name,
        cs.conversion_date,
        cs.conversion_type,
        pd.product_name,
        row_number() OVER( PARTITION BY cs.fk_customer ORDER BY cs.conversion_id) AS conversion_nubmer,
        LAG(cs.conversion_date) OVER(PARTITION BY cs.fk_customer ORDER BY cs.conversion_date) AS previous_conversion,
        LEAD(cs.conversion_date, 2) OVER(PARTITION BY cs.fk_customer ORDER BY cs.conversion_date) AS next_conversion,
       pd.*
FROM fact_tables.conversions AS cs
LEFT OUTER JOIN dimensions.customer_dimension AS cd
    ON cs.fk_customer = cd.sk_customer
LEFT JOIN dimensions.product_dimension AS pd
    ON cs.fk_product = pd.sk_product
ORDER BY cd.customer_id, cs.conversion_date;


SELECT cd.first_name,
        cd.last_name,
        cs.conversion_date,
        cs.conversion_type,
        pd.product_name,
        dd.year_quarter
      FROM fact_tables.conversions AS cs
LEFT OUTER JOIN dimensions.customer_dimension AS cd
    ON cs.fk_customer = cd.sk_customer
LEFT JOIN dimensions.product_dimension AS pd
    ON cs.fk_product = pd.sk_product
LEFT JOIN dimensions.date_dimension AS dd
    ON cs.fk_conversion_date = dd.sk_date
ORDER BY cd.customer_id, cs.conversion_date;

----July 11,2023 in class
--When join has conditions
SELECT *
FROM fact_tables.conversions AS cs
INNER JOIN dimensions.customer_dimension AS cd
    ON cs.fk_customer > cd.sk_customer;

SELECT *
FROM fact_tables.conversions AS cs
LEFT JOIN dimensions.customer_dimension AS cd
    ON cs.fk_customer > cd.sk_customer;

SELECT cs.conversion_id,
        cs.fk_customer,
        cs.conversion_date,
        cd.first_name,
        cd.last_name
FROM fact_tables.conversions AS cs
CROSS JOIN dimensions.customer_dimension AS cd

--Another way to accomplish same result with CROSS JOIN

SELECT cs.conversion_id,
        cs.fk_customer,
        pd.product_name,
        cs.conversion_date,
        cd.first_name,
            cd.last_name
FROM fact_tables.conversions AS cs,
     dimensions.customer_dimension as cd,
    dimensions.product_dimension as pd;


---- stacking results from multiple queries
---UNION and UNION all
--first query
SELECT cs.conversion_id,
       cs.conversion_date,
       cs.fk_customer,
       cs.conversion_channel
FROM fact_tables.conversions AS cs
WHERE conversion_channel = 'Social Media'
--using UNION
UNION
--second query
SELECT cs.conversion_id,
       cs.conversion_date,
       cs.fk_customer,
       cs.conversion_channel
FROM fact_tables.conversions AS cs
WHERE conversion_channel = 'Direct Mail CRM';



---UNION need exactly columns' name , orders , length and datatype
SELECT cs.conversion_channel
FROM fact_tables.conversions AS cs
WHERE conversion_channel = 'Social Media'
--using UNION
UNION---only keep the unique()
--second query
SELECT cs.conversion_channel
FROM fact_tables.conversions AS cs
WHERE conversion_channel = 'Direct Mail CRM';

SELECT cs.conversion_channel
FROM fact_tables.conversions AS cs
WHERE conversion_channel = 'Social Media'
--using UNION
UNION ALL---Bring all records vs UNION only keep the unique records
--second query
SELECT cs.conversion_channel
FROM fact_tables.conversions AS cs
WHERE conversion_channel = 'Direct Mail CRM';


SELECT cs.fk_customer
FROM fact_tables.conversions AS cs
--using UNION
UNION ALL---Bring all records vs UNION only keep the unique records
--second query
SELECT cs.fk_customer
FROM fact_tables.conversions AS cs;

SELECT cs.fk_customer
FROM fact_tables.conversions AS cs
--using UNION
UNION
--second query
SELECT cs.fk_customer
FROM fact_tables.conversions AS cs;


SELECT CAST(cs.fk_customer AS TEXT)
FROM fact_tables.conversions AS cs
--using UNION
UNION ALL---Bring all records vs UNION only keep the unique records
--second query
SELECT CAST(cs.fk_customer AS TEXT)
FROM fact_tables.conversions AS cs;

--SELECT name
--FROM MBAN
--UNION
--SELECT name
--FROM MMAI

--OR ---BUT try to avoid using DISTINCT
--SELECT DISTINCT NAME
--FROM MBAN
--UNION ALL
--SELECT DISTINCT name
--FROM MMAI

SELECT CURRENT_DATE;

---July 18-- Assignment

---- historical data for MARGE conversion_id 1111. 所有的消费记录
SELECT cd.first_name,
       cd.last_name,
       o.fk_order_date,
       dd.year_week AS delivery_week,
       o.order_number,
       --o.unit_price,
       --o.discount,
       o.price_paid
FROM fact_tables.orders AS o
LEFT JOIN dimensions.customer_dimension AS cd
        ON o.fk_customer = cd.sk_customer
LEFT JOIN dimensions.date_dimension AS dd
ON o.fk_order_date = dd.sk_date
WHERE cd.customer_id = 111;

--What is loyalty 每个订单算一分= cumulative orders

--add column first_delviery_week (2019_W1) for conversion ID 1111

--Now look at 消费大渡口区 since reactivated (another conversion ID)
   --- Reset the loyal to 1.
    --Partition by conversion, to reset the rank of the count.
    --cum_orders_lifetime (cumulative loyalty)  for KPI purpose.
    --- cumulative revenue  and cumulative revenue _ lifetime.

all revenue for March before 3-26

SELECT cd.first_name,
       cd.last_name,
       o.fk_order_date,
       dd.year_week AS delivery_week,
       o.order_number,
       cd.customer_id,
             --o.unit_price,
       --o.discount,
       SUM(o.price_paid) OVER( ORDER BY o.fk_order_date) AS cumulative_revenue
FROM fact_tables.orders AS o
LEFT JOIN dimensions.customer_dimension AS cd
        ON o.fk_customer = cd.sk_customer
LEFT JOIN dimensions.date_dimension AS dd
ON o.fk_order_date = dd.sk_date
LEFT JOIN fact_tables.conversions AS c
ON c.order_number = o.order_number
WHERE c.conversion_id = 1111;


SELECT cd.first_name,
       cd.last_name,
       o.fk_order_date,
       dd.year_week AS delivery_week,
       o.order_number,
       cd.customer_id,
             --o.unit_price,
       --o.discount,
       SUM(o.price_paid) OVER( ORDER BY o.fk_order_date) AS cumulative_revenue
FROM fact_tables.orders AS o
LEFT JOIN dimensions.customer_dimension AS cd
        ON o.fk_customer = cd.sk_customer
LEFT JOIN dimensions.date_dimension AS dd
ON o.fk_order_date = dd.sk_date
WHERE cd.customer_id = 111
    AND o.order_date BETWEEN '2019-01-03' AND '2020-03-25';


SELECT
        cd.customer_id,
        cd.first_name,
        cd.last_name,
        ROW()
        SUM(o.price_paid)
FROM fact_tables.orders AS o
LEFT JOIN dimensions.customer_dimension AS cd
ON o.fk_customer = cd.sk_customer
WHERE cd.customer_id = 111
    AND o.order_date BETWEEN '2019-01-03' AND '2020-03-25'
GROUP BY  1,2,3;

SELECT
        cd.customer_id,
        cd.first_name,
        cd.last_name,
        SUM(o.price_paid)
FROM fact_tables.orders AS o
LEFT JOIN dimensions.customer_dimension AS cd
ON o.fk_customer = cd.sk_customer
WHERE cd.customer_id = 111
    AND o.order_date >='2020-03-26'
GROUP BY  1,2,3;

---from 2019 wk13 to wk 2023-w29 total 17213.79 cumulative lifetime
-- add a column order number/ product

SELECT cd.first_name,
       cd.last_name,
       o.fk_order_date,
       dd.year_week AS delivery_week,
       o.order_number,
       pd.product_name,
       --o.unit_price,
       --o.discount,
       o.price_paid
FROM fact_tables.orders AS o
LEFT JOIN dimensions.customer_dimension AS cd
        ON o.fk_customer = cd.sk_customer
LEFT JOIN dimensions.date_dimension AS dd
ON o.fk_order_date = dd.sk_date
LEFT JOIN dimensionS.product_dimension as pd
ON o.fk_product = pd.sk_product
WHERE cd.customer_id = 111;

--CAC, how much money to cost to get new customer
--Retention, how long customer stay with us and how much we get from them.
--add column ' had-delivery'
-- 5W order rate ( how many time customer order in 5 wks  = sum of had_delivery.
--delivery week = 5,  what is happening on wk 5.  after that, you have time series by wk, you can breakdown by region, product etc...
--

SELECT
    cd.customer_id,
    cd.first_name,
    cd.last_name,
    cs.conversion_type,
    cs.conversion_date
FROM fact_tables.conversions AS cs
LEFT JOIN dimensions.customer_dimension AS cd
ON cs.fk_customer = cd.sk_customer
WHERE cs.conversion_type ='activation';

SELECT *
FROM fact_tables.conversions AS cs
WHERE cs.conversion_type ='reactivation'

----simplify your workflow
-- intermedia caculation then put together the table at the end , conversion information, then join the order from the right.
--define clear variables, then join after that.
--do not try to do evefrything in a single query.
WITH activation AS (SELECT cd.customer_id,
                           cd.first_name,
                           cd.last_name,
                           cs.conversion_type,
                           cs.conversion_date
                    FROM fact_tables.conversions AS cs
                             INNER JOIN dimensions.customer_dimension AS cd --- USE INNER JOIN make sure no NULL
                                        ON cs.fk_customer = cd.sk_customer
                    WHERE cs.conversion_type = 'activation'),
    reactivation AS (SELECT cd.customer_id,
                            cd.first_name,
                            cd.last_name,
                            cs.conversion_type,
                            cs.conversion_date
                        FROM fact_tables.conversions AS cs
                        LEFT JOIN dimensions.customer_dimension AS cd
                        ON cs.fk_customer = cd.sk_customer
                        WHERE cs.conversion_type = 'reactivation')
SELECT *
FROM activation
UNION ALL
SELECT *
FROM reactivation;


--Have all customer information
--Recurrence # of conversion
WITH conversionss_with_customer_id AS(
    SELECT cs.conversion_id,
           cd.customer_id,
                            cd.first_name,
                            cd.last_name,
                            cs.conversion_type,
                            row_number() over (partition by CD.customer_id ORDER BY cs.conversion_date) Recurrence,
                            cs.conversion_date,
                            LEAD(cs.conversion_date) OVER(PARTITION BY cd.customer_id ORDER BY cs.conversion_date) next_conversion,
                            cs.order_number
    FROM fact_tables.conversions AS cs
    INNER JOIN dimensions.customer_dimension AS cd --- USE INNER JOIN make sure no NULL
    ON cs.fk_customer = cd.sk_customer
    ),
    orders_with_customer_id AS (
    SELECT
           cd.customer_id,
                            cd.first_name,
                            cd.last_name,
                            o.price_paid,
                           row_number() over (partition by CD.customer_id ORDER BY o.order_date) Recurrence,
                            o.order_date,

                            LEAD(o.order_date) OVER(PARTITION BY cd.customer_id ORDER BY o.order_date) next_order,
                            o.order_number,
    pd.product_name
    FROM fact_tables.orders AS o
    INNER JOIN dimensions.customer_dimension AS cd --- USE INNER JOIN make sure no NULL
    ON o.fk_customer = cd.sk_customer
    INNER JOIN dimensions.product_dimension AS pd
    ON fact_tables.orders.fk_product = dimensions.product_dimension.sk_product
    ),
    conversions_with_first_orders AS (
SELECT
    cs.*,
    o.order_date,
    o.product_name,
    o.price_paid
    FROM conversionss_with_customer_id AS cs
    LEFT JOIN orders_with_customer_id AS o
    )

SELECT *
FROM conversionss_with_customer_id ;



--from professor
WITH conversions_with_customer_id AS (
SELECT cd.customer_id,
       cd.first_name,
       cd.last_name,
       cs.conversion_type,
       row_number() over (PARTITION BY cd.customer_id ORDER BY cs.conversion_date) recurrence,
       cs.conversion_date,
       LEAD(cs.conversion_date) OVER (PARTITION BY cd.customer_id ORDER BY cs.conversion_date) next_conversion,
       cs.order_number
FROM fact_tables.conversions AS cs
INNER JOIN dimensions.customer_dimension AS cd
  ON cs.fk_customer = cd.sk_customer
), orders_with_customer_id AS (
SELECT cd.customer_id,
       cd.first_name,
       cd.last_name,
       row_number() over (PARTITION BY cd.customer_id ORDER BY o.order_date) order_recurrence,
       o.order_date,
       LEAD(o.order_date) OVER (PARTITION BY cd.customer_id ORDER BY o.order_date) next_order,
       o.order_number,
       pd.product_name,
       o.price_paid
FROM fact_tables.orders AS o
INNER JOIN dimensions.customer_dimension AS cd
  ON o.fk_customer = cd.sk_customer
INNER JOIN dimensions.product_dimension  AS pd
  ON o.fk_product = pd.sk_product
), conversions_with_first_orders AS (
SELECT cs.*,
       o.order_date,
       o.product_name,
       o.price_paid
FROM conversions_with_customer_id AS cs
LEFT JOIN orders_with_customer_id AS o
  ON cs.order_number = o.order_number
)
SELECT *
FROM conversions_with_first_orders AS cs_fo;


---July 25

