use cky1;
-- Find the data date range: 2014.01.10 - 2017.12.31
select max(t1.`Order Date`) as max_date,
      min(t1.`Order Date`) as min_date
from cky1.order_information t1;
/* Analysis of sales:
 * 
 * 1. Sales Year-on-Year
 * 2. Sales month-on-month in 2017
 * 3. Top sales regions, membership types, product types by year  
 */
-- Sales Year-on-Year
-- Indicator: Order quantity, sales amount, profit amount
select f2.order_number2 / f1.order_number1 as order_number_rate1 -- Number of orders from 2014 to 2015
,
      f3.order_number3 / f2.order_number2 as order_number_rate2 -- Number of orders from 2015 to 2016
,
      f4.order_number4 / f3.order_number3 as order_number_rate3 -- Number of orders from 2016 to 2017
,
      f2.sale_amount2 / f1.sale_amount1 as sales_amount_rate1 -- 2014 to 2015 Sales YoY
,
      f3.sale_amount3 / f2.sale_amount2 as sales_amount_rate2 -- 2015 to 2016 Sales YoY
,
      f4.sale_amount4 / f3.sale_amount3 as sales_amount_rate3 -- 2016 to 2017 Sales YoY
,
      f2.profit_amount2 / f1.profit_amount1 as profit_amount_rate1 -- 2014 to 2015 profit YoY
,
      f3.profit_amount3 / f2.profit_amount2 as profit_amount_rate2 -- 2015 to 2016 profit YoY
,
      f4.profit_amount4 / f3.profit_amount3 as profit_amount_rate3 -- 2016 to 2017 profit YoY
from (
            select year(t2.`Order Date`) as year1,
                  count(distinct t1.`Order ID`) as order_number1,
                  sum(t1.Sales) as sale_amount1,
                  sum(t1.Profit) as profit_amount1
            from cky1.orders t1
                  join cky1.order_information t2 on t1.`Order ID` = t2.`Order ID`
            where t2.`Order Date` between '2014-01-01' and '2014-12-31'
            group by year(t2.`Order Date`)
      ) f1
      join (
            select year(t2.`Order Date`) as year2,
                  count(distinct t1.`Order ID`) as order_number2,
                  sum(t1.Sales) as sale_amount2,
                  sum(t1.Profit) as profit_amount2
            from cky1.orders t1
                  join cky1.order_information t2 on t1.`Order ID` = t2.`Order ID`
            where t2.`Order Date` between '2015-01-01' and '2015-12-31'
            group by year(t2.`Order Date`)
      ) f2
      join (
            select year(t2.`Order Date`) as year3,
                  count(distinct t1.`Order ID`) as order_number3,
                  sum(t1.Sales) as sale_amount3,
                  sum(t1.Profit) as profit_amount3
            from cky1.orders t1
                  join cky1.order_information t2 on t1.`Order ID` = t2.`Order ID`
            where t2.`Order Date` between '2016-01-01' and '2016-12-31'
            group by year(t2.`Order Date`)
      ) f3
      join (
            select year(t2.`Order Date`) as year4,
                  count(distinct t1.`Order ID`) as order_number4,
                  sum(t1.Sales) as sale_amount4,
                  sum(t1.Profit) as profit_amount4
            from cky1.orders t1
                  join cky1.order_information t2 on t1.`Order ID` = t2.`Order ID`
            where t2.`Order Date` between '2017-01-01' and '2017-12-31'
            group by year(t2.`Order Date`)
      ) f4;
-- Sales month-on-month in 2017
-- Indicator: Order quantity, sales amount, profit amount
select t4.month1,
      t4.order_number,
      t5.order_number_last,
      t4.order_number / t5.order_number_last as order_number_rate,
      t4.sale_amount,
      t5.sale_amount_last,
      t4.sale_amount / t5.sale_amount_last as sale_amount_rate,
      t4.profit_amount,
      t5.profit_amount_last,
      t4.profit_amount / t5.profit_amount_last as profit_amount_rate
from (
            select month(t2.`Order Date`) as month1,
                  count(distinct t1.`Order ID`) as order_number,
                  sum(t1.Sales) as sale_amount,
                  sum(t1.Profit) as profit_amount
            from cky1.orders t1
                  join cky1.order_information t2 on t1.`Order ID` = t2.`Order ID`
            where t2.`Order Date` between '2017-02-01' and '2017-12-31'
            group by month(t2.`Order Date`)
      ) t4
      join (
            select month(t3.month_add1) as month_add1,
                  sum(t3.order_number) as order_number_last,
                  sum(t3.sale_amount) as sale_amount_last,
                  sum(t3.profit_amount) as profit_amount_last
            from (
                        select t2.`Order Date`,
                              date_add(t2.`Order Date`, interval 1 month) as month_add1,
                              count(distinct t1.`Order ID`) as order_number,
                              sum(t1.Sales) as sale_amount,
                              sum(t1.Profit) as profit_amount
                        from cky1.orders t1
                              join cky1.order_information t2 on t1.`Order ID` = t2.`Order ID`
                        where t2.`Order Date` between '2017-01-01' and '2017-11-30'
                        group by t2.`Order Date`,
                              date_add(t2.`Order Date`, interval 1 month)
                  ) t3
            group by month(t3.month_add1)
      ) t5 on t5.month_add1 = t4.month1;
-- Top sales region, membership type, product type by year 
-- Indicator: sales amount, order number, profit amount 
-- region
select t1.Region,
      year(t2.`Order Date`) as year,
      sum(t1.Sales) as sales_amount,
      sum(t1.Profit) as profit_amount,
      count(distinct t1.`Order ID`) as order_number
from cky1.orders t1
      join cky1.order_information t2 on t1.`Order ID` = t2.`Order ID`
group by t1.Region,
      year(t2.`Order Date`)
order by sum(t1.Sales) desc;
-- member type
select t1.Segment,
      year(t2.`Order Date`) as year,
      sum(t1.Sales) as sales_amount,
      sum(t1.Profit) as profit_amount,
      count(distinct t1.`Order ID`) as order_number
from cky1.orders t1
      join cky1.order_information t2 on t1.`Order ID` = t2.`Order ID`
group by t1.Segment,
      year(t2.`Order Date`)
order by sum(t1.Sales) desc;
-- product type
select t3.Category,
      year(t2.`Order Date`) as year,
      sum(t1.Sales) as sales_amount,
      sum(t1.Profit) as profit_amount,
      count(distinct t1.`Order ID`) as order_number
from cky1.orders t1
      join cky1.order_information t2 on t1.`Order ID` = t2.`Order ID`
      join cky1.Product_Information t3 on t1.`Product ID` = t3.`Product ID`
group by t3.Category,
      year(t2.`Order Date`)
having year = '2014'
order by sum(t1.Sales) desc;