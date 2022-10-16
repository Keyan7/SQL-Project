/* Analysis of the reasons for returns：
 *
 * 1. discount
 * 2. Date
 * 3. product type
 */
-- Discount(contigency table test)
-- returned order number, discount order numbe, total order number
select sum(t3.returned1) as returned_number,
      sum(t3.discount1) as discount_number,
      count(t3.`Order ID`) as total_number
from (
            select if(t2.Returned = 'Yes', 1, 0) as returned1,
                  if(t1.Discount = 0, 0, 1) as discount1,
                  t1.`Order ID`
            from cky1.orders t1
                  left join cky1.Return_Orders t2 on t1.`Order ID` = t2.`Order ID`
      ) t3;
-- returned and discount order number
select count(t3.`Order ID`)
from (
            select if(t2.Returned = 'Yes', 1, 0) as returned1,
                  if(t1.Discount = 0, 0, 1) as discount1,
                  t1.`Order ID`
            from cky1.orders t1
                  left join cky1.Return_Orders t2 on t1.`Order ID` = t2.`Order ID`
      ) t3
where t3.returned1 = 1
      and t3.discount1 = 1;
-- No returned and no discount order number
select count(t3.`Order ID`)
from (
            select if(t2.Returned = 'Yes', 1, 0) as returned1,
                  if(t1.Discount = 0, 0, 1) as discount1,
                  t1.`Order ID`
            from cky1.orders t1
                  left join cky1.Return_Orders t2 on t1.`Order ID` = t2.`Order ID`
      ) t3
where t3.returned1 = 0
      and t3.discount1 = 0;
-- 2. date
select sum(t4.returned1) as returned_number,
      date_format(t4.`Order Date`, '%Y-%m') as date1
from (
            select if(t2.Returned = 'Yes', 1, 0) as returned1,
                  t3.`Order Date`,
                  t1.`Order ID`
            from cky1.orders t1
                  left join cky1.Return_Orders t2 on t1.`Order ID` = t2.`Order ID`
                  join cky1.order_information t3 on t1.`Order ID` = t3.`Order ID`
      ) t4
where t4.returned1 = 1
group by date_format(t4.`Order Date`, '%Y-%m')
order by sum(t4.returned1) desc;
select sum(t4.returned1) as returned_number,
      month(t4.`Order Date`) as date1
from (
            select if(t2.Returned = 'Yes', 1, 0) as returned1,
                  t3.`Order Date`,
                  t1.`Order ID`
            from cky1.orders t1
                  left join cky1.Return_Orders t2 on t1.`Order ID` = t2.`Order ID`
                  join cky1.order_information t3 on t1.`Order ID` = t3.`Order ID`
      ) t4
where t4.returned1 = 1
group by month(t4.`Order Date`)
order by sum(t4.returned1) desc;
-- 3. product type
select sum(t4.returned1) as returned_number,
      t4.Category
from (
            select if(t2.Returned = 'Yes', 1, 0) as returned1,
                  t3.Category,
                  t1.`Order ID`
            from cky1.orders t1
                  left join cky1.Return_Orders t2 on t1.`Order ID` = t2.`Order ID`
                  join cky1.Product_Information t3 on t1.`Product ID` = t3.`Product ID`
      ) t4
where t4.returned1 = 1
group by t4.Category
order by sum(t4.returned1) desc;