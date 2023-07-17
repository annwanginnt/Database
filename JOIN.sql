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
SELECT cs.conversion_id,
       cs.fk_customer,
       cs.conversion_date,
       cs.conversion_type,
       LEAD(cs.conversion_date, 2) OVER(PARTITION BY cs.fk_customer ORDER BY cs.conversion_date) AS next_conversion
FROM fact_tables.conversions AS cs
ORDER BY cs.fk_customer, cs,conversion_date;

--- previouse version
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


