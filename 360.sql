
WITH
conversions_with_customer_id AS (
SELECT CustomerDimensionTable.customer_id,
       CustomerDimensionTable.sk_customer,
       CustomerDimensionTable.first_name,
       CustomerDimensionTable.last_name,
       ConversionTable.conversion_type,
       row_number() over (PARTITION BY CustomerDimensionTable.customer_id ORDER BY ConversionTable.conversion_date)
           as recurrence,
       ConversionTable.conversion_date,
       LEAD(ConversionTable.conversion_date) OVER (PARTITION BY CustomerDimensionTable.customer_id ORDER BY ConversionTable.conversion_date)
           as next_conversion,
       ConversionTable.order_number as firstOrderId,
       ConversionTable.conversion_channel
        FROM fact_tables.conversions
                AS ConversionTable
        INNER JOIN dimensions.customer_dimension
                AS CustomerDimensionTable
                ON ConversionTable.fk_customer = CustomerDimensionTable.sk_customer
),
orders_with_customer_id AS (
    SELECT CustomerDimensionTable.customer_id,
       CustomerDimensionTable.first_name,
       CustomerDimensionTable.last_name,
       row_number() over (PARTITION BY CustomerDimensionTable.customer_id ORDER BY OrderTable.order_date)
           as order_recurrence,
       OrderTable.order_date,
       LEAD(OrderTable.order_date) OVER (PARTITION BY CustomerDimensionTable.customer_id ORDER BY OrderTable.order_date)
           as next_order,
       OrderTable.order_number as firstOrderId,
       ProductTable.product_name,
       OrderTable.price_paid,
       OrderTable.order_id,
       OrderTable.fk_product,
       OrderTable.discount
        FROM fact_tables.orders AS OrderTable
        INNER JOIN dimensions.customer_dimension AS CustomerDimensionTable
                ON OrderTable.fk_customer = CustomerDimensionTable.sk_customer
        INNER JOIN dimensions.product_dimension  AS ProductTable
                ON OrderTable.fk_product = ProductTable.sk_product
),

conversions_with_first_orders AS (
SELECT cs.*,
       o.order_date as firstOrderDate,
       o.product_name as firstProduct_name,
       o.price_paid as firstOrderPrice_paid,
       o.order_id,
       o.discount as firstOrderDiscount
FROM conversions_with_customer_id AS cs
LEFT JOIN orders_with_customer_id AS o
  ON cs.firstOrderId = o.firstOrderId
LEFT JOIN dimensions.product_dimension AS product
    ON o.fk_product = product.sk_product
),

conversions_with_first_orders_date AS (
SELECT cs.*,
       OrderDate.year_week as conversionWeek
FROM conversions_with_first_orders AS cs
LEFT JOIN dimensions.date_dimension AS OrderDate
  ON cs.firstOrderDate = OrderDate.date
),
next_conversionDateToWeek AS (
SELECT cs.*,
       DateTable.year_week as nextConversionWeek
FROM conversions_with_first_orders_date AS cs
LEFT JOIN dimensions.date_dimension AS DateTable
  ON cs.next_conversion = DateTable.date
),

weekTable as (select DISTINCT year_week as Delivery_week
              from dimensions.date_dimension),

delivery_week_table as (SELECT *
                   FROM next_conversionDateToWeek AS cs_fo
                            LEFT JOIN weekTable
                                      ON (cast(weekTable.Delivery_week as text) >= cast(conversionWeek as text) AND
                                          cast(weekTable.Delivery_week as text) < cast(nextConversionWeek as text))
                                          or (cast(weekTable.Delivery_week as text) >= cast(conversionWeek as text) AND
                                              nextConversionWeek is null)
                   order by customer_id DESC, conversion_date, Delivery_week asc),


--- create column for orders during the conversion period and attach all order rows to that period
ordersTable as (select order_id, order_number,order_date, year_week as order_week ,fk_customer,product_name,order_item_id,unit_price,discount,
                       price_paid
                from fact_tables.orders as os
                 JOIN dimensions.product_dimension
                      on product_dimension.sk_product = os.fk_product
                JOIN dimensions.date_dimension
                    on date_dimension.date = os.order_date
                order by order_date),
-- attach order table to the delivery week table to associate order id, name to the corresponding customer within conversion week
orderTableUpdate as (
        SELECT *
                  FROM delivery_week_table
                  LEFT JOIN ordersTable
                     ON
                         (
                                     delivery_week_table.sk_customer = ordersTable.fk_customer
                                 and
                                     delivery_week_table.Delivery_week = ordersTable.order_week
                                 and (
                                             (cast(delivery_week_table.Delivery_week as text) >=
                                              cast(conversionWeek as text) AND
                                              cast(delivery_week_table.Delivery_week as text) <
                                              cast(nextConversionWeek as text))
                                             or (cast(delivery_week_table.Delivery_week as text) >=
                                                 cast(conversionWeek as text) AND
                                                 nextConversionWeek is null)
                                         )
                             )
        ),
    revenue_hasOrder_Update as (
                    select *,
                    CASE
                       when price_paid is null
                           then 0
                       else price_paid
                    END as revenue,
                    CASE
                       when order_date is null
                           then 0
                       else 1
                    END as has_order
                    from orderTableUpdate
                  )

      SELECT *,
             sum(revenue) over (partition by customer_id, order_week order by Delivery_week) as week_revenue,
             sum(discount) over (partition by customer_id, order_week order by Delivery_week) as week_discounts,
             sum(revenue) over (partition by customer_id order by Delivery_week) as cumulative_revenue,
             sum(has_order) over (partition by customer_id order by Delivery_week) as loyalty
      from revenue_hasOrder_Update
      order by customer_id desc, Delivery_week asc, revenue asc
