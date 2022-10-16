/* customer
 * 1. Customer growth rate
 * 2. RFM model
 */
-- Customer growth rate
-- table: orders, Product_Information, order_information 
-- indicator: customer number
-- dimention: date, product
set @category := 'Technology' -- Variables on product category
select t5.Category,
      t5.year,
      t5.customer_number,
      t6.customer_number_last,
      concat(
            round(
                  t5.customer_number / t6.customer_number_last - 1,
                  4
            ) * 100,
            '%'
      ) as growth_rate
from (
            select t2.Category,
                  year(t3.`Order Date`) as year,
                  count(t1.`Customer ID`) as customer_number
            from cky1.orders t1
                  join cky1.Product_Information t2 on t1.`Product ID` = t2.`Product ID`
                  join cky1.order_information t3 on t1.`Order ID` = t3.`Order ID`
            where t2.Category = @category
            group by t2.Category,
                  year(t3.`Order Date`)
      ) t5
      join (
            select t4.Category,
                  year(t4.year_add1) as year_add1,
                  count(t4.`Customer ID`) as customer_number_last
            from (
                        select t2.Category,
                              date_add(t3.`Order Date`, interval 1 year) as year_add1,
                              t1.`Customer ID`
                        from cky1.orders t1
                              join cky1.Product_Information t2 on t1.`Product ID` = t2.`Product ID`
                              join cky1.order_information t3 on t1.`Order ID` = t3.`Order ID`
                  ) t4
            where t4.Category = @category
            group by t4.Category,
                  year(t4.year_add1)
      ) t6 on t5.year = t6.year_add1
order by t5.Category,
      t5.year;
-- RFM model
-- Rough view of customer order frequency
select avg(t3.M),
      avg(t3.amount)
from (
            select t1.`Customer ID`,
                  count(distinct t1.`Order ID`) as order_number,
                  max(t2.`Order Date`),
                  datediff('2017-12-31', max(t2.`Order Date`)) as M,
                  sum(t1.sales) as amount
            from cky1.orders t1
                  join cky1.order_information t2 on t1.`Order ID` = t2.`Order ID`
            where t2.`Order Date` between '2016-01-01' and '2017-12-31'
            group by t1.`Customer ID`
      ) t3;
-- date: 2016.01.01 - 2017.12.31
-- Define R: Less than 90 days, 90-180 days, 180-360 days, more than 360 days 
-- Define F: 1, 2, 3, 4, more than 4
-- Define M: 100, 100-500, 500-1000, 1000-2000, more than 2000
select t3.`Customer ID`,
      RFM_R,
      RFM_M,
      RFM_F,
      case
            when RFM_R <= 90 then 'less than 90 days'
            when RFM_R <= 180
            and RFM_R > 90 then '90-180 days'
            when RFM_R > 180
            and RFM_R <= 360 then '180-360 days'
            when RFM_R > 360 then 'more than 360 days'
      end as RFM_R_type,
      case
            when RFM_F = 1 then '1 time'
            when RFM_F = 2 then '2 times'
            when RFM_F = 3 then '3 times'
            when RFM_F = 4 then '4 times'
            when RFM_F > 4 then 'more than 4 times'
      end as RFM_F_type,
      case
            when RFM_M <= 100 then 'Under 100 USD'
            when RFM_M <= 500
            and RFM_M > 100 then '100-500 USD'
            when RFM_M <= 1000
            and RFM_M > 500 then '500-1000USD'
            when RFM_M <= 3000
            and RFM_M > 1000 then '1000-3000USD'
            when RFM_M > 3000 then 'more than 3000 USD'
      end as RFM_M_type
from (
            select t1.`Customer ID`,
                  count(distinct t1.`Order ID`) as RFM_F,
                  max(t2.`Order Date`) as last_buytime,
                  datediff('2017-12-31', max(t2.`Order Date`)) as RFM_R,
                  sum(t1.sales) as RFM_M
            from cky1.orders t1
                  join cky1.order_information t2 on t1.`Order ID` = t2.`Order ID`
            where t2.`Order Date` between '2016-01-01' and '2017-12-31'
            group by t1.`Customer ID`
      ) t3;