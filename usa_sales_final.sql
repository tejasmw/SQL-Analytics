-- 1. Looking for overall profit or loss
SELECT sales_channel , ROUND(SUM(unit_price - unit_cost)) AS P_or_L
FROM sales_orders
GROUP BY sales_channel;

-- 2. Top 10 cheapest items
SELECT p.product_name, ROUND(SUM(o.unit_price)) AS Price
FROM sales_orders o 
JOIN products p
ON p.productid = o.productid
GROUP BY p.product_name
ORDER BY Price LIMIT 10; 

-- 3. Top 10 expensive items
SELECT p.product_name, ROUND(SUM(o.unit_price)) AS Price
FROM sales_orders o 
JOIN products p
ON p.productid = o.productid
GROUP BY p.product_name
ORDER BY Price DESC LIMIT 10;

-- 4. Products with the highest margin
SELECT DISTINCT p.product_name, ROUND(SUM(o.unit_cost)) AS Cost_Price, ROUND(SUM(o.unit_price)) AS Selling_Price , ROUND(SUM(o.unit_price - o.unit_cost)) AS Margin
FROM sales_orders o 
JOIN products p
ON p.productid = o.productid
GROUP BY p.product_name
ORDER BY Margin DESC ;

 -- 5. Regionwise Profit or Loss
 SELECT region, SUM(PorL) AS PL
FROM (
    SELECT r.region AS region, (o.unit_price - o.unit_cost) AS PorL
    FROM regions r
    JOIN store_locations l ON r.statecode = l.statecode
    JOIN sales_orders o ON l.storeid = o.storeid
) AS rgn
GROUP BY region;

-- 6. To check for statewise profit or loss
    WITH cte AS (
    SELECT l.state, SUM(SUM(o.unit_price - o.unit_cost)) OVER (PARTITION BY l.state) AS P_or_L
    FROM store_locations l
    JOIN sales_orders o ON l.storeid = o.storeid
    GROUP BY l.state
)
SELECT state,ROUND(P_or_L) AS P_or_L
FROM cte
ORDER BY P_or_L DESC;

-- 7. productwise sales across states
SELECT p.product_name, l.state,ROUND(SUM(o.order_quantity)) AS Total_Quantity, ROUND(SUM(SUM(o.order_quantity)) OVER (PARTITION BY l.state)) AS State_Quantity
FROM products p 
	INNER JOIN sales_orders o ON p.productid = o.productid
	INNER JOIN store_locations l ON o.storeid = l.storeid
GROUP BY p.product_name ,l.state
ORDER BY l.state ;

-- 8. correlation between median_income across the states and sales 
WITH cte AS 
(SELECT state,median_income,storeid
FROM store_locations
GROUP BY state, median_income, storeid
)
SELECT c.state,SUM(c.median_income) AS Median_Income,ROUND(SUM(o.unit_price)) AS Sales_Amount
FROM cte c
LEFT JOIN sales_orders o ON c.storeid = o.storeid
GROUP BY c.state;

-- 9. revenue generated by each sales team, grouped by region
SET sql_mode = '';
SELECT t.sales_team, t.region, ROUND(SUM(o.unit_price), 2) AS Team_Revenue , ROUND(SUM(SUM(o.unit_price)) OVER (PARTITION BY t.region), 2) AS Total_Revenue
FROM sales_team t
JOIN sales_orders o ON t.salesteamid = o.salesteamid
GROUP BY t.sales_team, t.region
ORDER BY Total_Revenue DESC;

-- 10. city wise sales 
select l.city_name, l.state, ROUND(SUM(o.unit_price)) AS revenue
from store_locations l
join sales_orders o
on l.storeid = o.storeid
group by l.city_name, l.state
order by revenue DESC;

-- 11. Revenue generated by every method of delivery
SELECT sales_channel as method, ROUND(SUM(unit_price - unit_cost)) AS Revenue
FROM sales_orders 
GROUP BY method
ORDER BY Revenue DESC;

-- 12. Top customers
select c.customer_names as customer, count(o.customerid) as times_ordered
from customers c
join sales_orders o
on c.customerid = o.customerid
group by customer
order by times_ordered DESC;

-- 13. average delivery time by each delivery method
SELECT sales_channel, ROUND(avg(diff)) AS days_taken_to_deliver
FROM (select ordernumber,sales_channel , DATEDIFF(deliverydate, orderdate) as diff from sales_orders ) AS dd
GROUP BY sales_channel;


