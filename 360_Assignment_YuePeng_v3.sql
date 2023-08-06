WITH conversions_with_customer_id AS(
    SELECT dc.customer_id AS customer_id,
           dc.first_name AS first_name,
           dc.last_name AS last_names,
           fc.conversion_id AS conversion_id,
           fc.conversion_date AS conversion_date,
           dd.year_week AS conversion_week,
           ROW_NUMBER() over (PARTITION BY dc.customer_id ORDER BY fc.conversion_date) AS recurrence,--conversion number
           fc.conversion_type AS conversion_type,
           fc.conversion_channel,
           LEAD(fc.conversion_date) OVER (PARTITION BY dc.customer_id ORDER BY fc.conversion_date) AS next_conversion_date,
           fc.order_number
    FROM fact_tables.conversions AS fc
        INNER JOIN dimensions.customer_dimension AS dc
            ON fc.fk_customer = dc.sk_customer
        LEFT JOIN dimensions.date_dimension AS dd
             ON dd.date = fc.conversion_date
), orders_with_customer_id AS (
    SELECT dc.customer_id,
           dc.first_name,
           dc.last_name,
           ROW_NUMBER() over (PARTITION BY dc.customer_id ORDER BY fo.order_date) order_recurrence,
           fo.order_date,
           dd.year_week AS delivery_week,
           dd.running_week AS delivery_week_number,
           LEAD(fo.order_date) OVER (PARTITION BY dc.customer_id ORDER BY fo.order_date) next_order,
           fo.order_number,
           dp.product_name AS product,
           fo.discount,
           fo.price_paid AS revenue
    FROM fact_tables.orders AS fo
        INNER JOIN dimensions.customer_dimension AS dc
            ON fo.fk_customer = dc.sk_customer
        INNER JOIN dimensions.product_dimension  AS dp
            ON fo.fk_product = dp.sk_product
        LEFT JOIN dimensions.date_dimension AS dd
            ON dd.date = fo.order_date
    WHERE DATE <= current_date
), orders AS ( --combining orders with conversions
    SELECT oi.*,
           ci.conversion_id,
           ci.conversion_date,
           ci.conversion_week,
           ci.next_conversion_date,
           ci.recurrence,
           ci.conversion_type,
           ci.conversion_channel
    FROM orders_with_customer_id AS oi
    LEFT JOIN LATERAL (
        SELECT conversion_id,
               conversion_date,
               conversion_week,
               next_conversion_date,
               recurrence,
               conversion_type,
               conversion_channel
        FROM conversions_with_customer_id AS ci
        WHERE ci.customer_id = oi.customer_id AND ci.conversion_date <= oi.order_date
        ORDER BY ci.conversion_date DESC
        LIMIT 1
    ) AS ci ON TRUE
), orders_with_date AS (
    SELECT o.*,
           COUNT(o.customer_id) OVER(PARTITION BY o.customer_id, o.delivery_week ORDER BY o.delivery_week ASC) AS had_delivery,
           dd.year_week AS next_conversion_week,
           FIRST_VALUE(o.order_date) OVER (PARTITION BY o.customer_id, o.conversion_type ORDER BY o.order_date ASC) AS first_order_date,
           FIRST_VALUE(o.order_number) OVER (PARTITION BY o.customer_id, o.conversion_type ORDER BY o.order_date ASC) AS first_order_id,
           FIRST_VALUE(o.product) OVER (PARTITION BY o.customer_id, o.conversion_type ORDER BY o.order_date ASC) AS first_order_product,
           FIRST_VALUE(o.revenue) OVER (PARTITION BY o.customer_id, o.conversion_type ORDER BY o.order_date ASC) AS first_order_total_paid,
           FIRST_VALUE(o.discount) OVER (PARTITION BY o.customer_id, o.conversion_type ORDER BY o.order_date ASC) AS first_order_discount,
           SUM(o.discount) OVER (PARTITION BY o.customer_id, o.delivery_week ORDER BY o.order_date ASC) AS week_discount,
           SUM(o.revenue) OVER (PARTITION BY o.customer_id, o.delivery_week ORDER BY o.order_date ASC) AS week_revenue,
           SUM(o.revenue) OVER (PARTITION BY o.customer_id, o.conversion_id ORDER BY o.order_date ASC) AS cumulative_revenue, --per customer per conversion
           SUM (o.revenue) OVER (PARTITION BY o.customer_id ORDER BY o.order_date) AS cumulative_revenue_lifetime -- per customer_life_time
    FROM orders AS o
        LEFT JOIN dimensions.date_dimension AS dd
            ON o.next_conversion_date = dd.date
)--final table
SELECT o.customer_id,
       o.first_name,
       o.last_name,
       o.conversion_id,
       o.conversion_type,
       o.conversion_channel,
       o.conversion_date,
       o.recurrence,
       o.conversion_week,
       o.next_conversion_date,
       o.next_conversion_week,
       o.first_order_id,
       o.first_order_product,
       o.first_order_date,
       dd.year_week AS first_order_week,
       o.first_order_total_paid,
       o.first_order_discount,
       o.order_number AS order_id,
       o.product,
       o.delivery_week,
       o.delivery_week_number,
       o.had_delivery,
       o.revenue,
       o.discount,
       o.week_revenue,
       o.week_discount,
       o.cumulative_revenue,
       o.cumulative_revenue_lifetime,
       SUM(o.had_delivery) OVER (PARTITION BY o.customer_id, o.conversion_id ORDER BY o.order_date ASC) AS loyalty,
       SUM (o.had_delivery) OVER (PARTITION BY o.customer_id ORDER BY o.order_date ASC) AS loyalty_lifetime
FROM orders_with_date AS o
LEFT JOIN dimensions.date_dimension AS dd
ON dd.date = o.first_order_date;