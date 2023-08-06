
WITH conversion_table AS (
  SELECT
    cd.customer_id,
    cd.first_name,
    cd.last_name,
    cv.conversion_id,
    cv.conversion_date,
    cv.conversion_type
  FROM fact_tables.conversions as cv
  inner JOIN dimensions.customer_dimension as cd
    ON cv.fk_customer = cd.sk_customer
  LEFT JOIN dimensions.date_dimension as dd
    ON cv.fk_conversion_date = dd.sk_date
),

order_table AS (
  SELECT
    cd.customer_id,
    o.order_date,
    o.order_number,
    dd.running_week,
    dd.year_week as delivery_week,
    pd.product_name as product,
    o.price_paid,
    dd.running_week as delivery_wk_num,
    COUNT(dd.year_week) OVER(PARTITION BY o.order_number ORDER BY o.order_date) as had_delivered
  FROM fact_tables.orders as o
  INNER JOIN dimensions.customer_dimension as cd
    ON o.fk_customer = cd.sk_customer
  LEFT JOIN dimensions.product_dimension as pd
    ON o.fk_product = pd.sk_product
  LEFT JOIN dimensions.date_dimension as dd
    ON o.fk_order_date = dd.sk_date),

---order_conversion_date 下面的group by不是为了表格好看
--group by 是保证生成的新表没有duplicates.
--因为表里有aggregating function MAX,所以一旦group必须把前面的全部group by 起来，所以就只留customer_id and order_date.
order_conversion_dates AS (
  SELECT
    ot.customer_id,
    ot.order_date,
      MAX(ct.conversion_date) as max_conversion_date
    --min(ot.order_date) over(partition by ct.conversion_id) as first_order_date
  FROM order_table as ot
  LEFT JOIN conversion_table as ct
    ON ot.customer_id = ct.customer_id AND ot.order_date >= ct.conversion_date
    GROUP BY ot.customer_id, ot.order_date)

SELECT
  ot.customer_id,
  ct.conversion_id,
  ct.conversion_type,
  ocd.max_conversion_date,
 min(ot.order_date) over(partition by ct.conversion_id) as first_order_date,
  ct.first_name,
  ct.last_name,
  ot.order_number,
  ot.order_date,
  ot.delivery_week,
    ot.product,
   ot.delivery_wk_num,
   ot.had_delivered,
   sum(ot.price_paid) over(partition by ot.delivery_wk_num) as weekly_revenue,
    ot.price_paid as revenue,
    sum(ot.price_paid) over (partition by ot.customer_id,ct.conversion_id order by ot.order_date) as cumulative_revenue,
    sum(ot.price_paid) over(partition by ot.customer_id order by ot.order_date) as lifetime_cumulative_revenue,
    count(ot.had_delivered) over(partition by ot.customer_id, ct.conversion_id order by ot.order_date) as cumulative_orders,
    count(ot.had_delivered) over(partition by ot.customer_id order by ot.order_date) as lifetime_cumulative_orders
FROM order_table as ot
INNER JOIN order_conversion_dates as  ocd
  ON ot.customer_id = ocd.customer_id AND ot.order_date = ocd.order_date
INNER JOIN conversion_table as  ct
  ON ot.customer_id = ct.customer_id AND ocd.max_conversion_date = ct.conversion_date
ORDER BY ot.customer_id, ot.order_date;

