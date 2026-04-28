-- Sales Territory Analysis:

-- Territory:          South Carolina (In-Store)
-- Sales Manager:      Len Jensen
-- Region:             South
-- Regional Director:  Andy Gisselquist
-- Stores:             Charleston (Store 852), Greenville (Store 853)

USE sample_sales;

-- 1. What is total revenue overall for sales in the assigned territory, plus the start date and end date that tell you what period the data covers?
SELECT 
	ss.Store_ID,
	ROUND(SUM(ss.Sale_Amount),2) AS Total_Revenue,
    MIN(ss.Transaction_Date) AS Start_Date,
    MAX(ss.Transaction_Date) AS End_Date
FROM store_sales ss
JOIN store_locations sl
  ON ss.Store_ID = sl.StoreId
WHERE sl.State = 'South Carolina'
GROUP BY ss.Store_ID;

-- 2. What is the month by month revenue breakdown for the sales territory?
SELECT 
     ss.Store_ID,
     DATE_FORMAT(ss.Transaction_Date, '%Y-%m') AS Revenue_Month,
     ROUND(SUM(ss.Sale_Amount),2) AS Monthly_Revenue
FROM store_sales ss
JOIN store_locations sl
  ON ss.Store_ID = sl.StoreId
WHERE sl.State = 'South Carolina'
GROUP BY ss.Store_ID, DATE_FORMAT(ss.Transaction_Date, '%Y-%m')
ORDER BY ss.Store_ID, Revenue_Month;

-- 3. Provide a comparison of total revenue for the specific sales territory and the region it belongs to.
WITH 
   South_Sale AS (
              SELECT sl.State,
                     ss.Store_ID,
					 ss.Sale_Amount
			  FROM store_sales ss 
              JOIN store_locations sl
                ON ss.Store_ID = sl.StoreId
			 WHERE sl.State IN ('South Carolina', 'Florida', 'Texas')
)
SELECT 
	    State AS Territory,
        'South' AS Region,
        Store_ID,
        ROUND(SUM(Sale_Amount),2) AS Total_Revenue
FROM South_Sale
GROUP BY State, Store_ID  

UNION ALL 

SELECT 
	'South Region Total',
	'South',
	'All stores',
	 ROUND(SUM(Sale_Amount),2) 
FROM South_Sale;

-- 4. What is the number of transactions per month and average transaction size by product category for the sales territory?
SELECT 
     DATE_FORMAT(ss.Transaction_Date, '%Y-%m') AS Transaction_Month,
     ic.Category AS Product_category,
     Count(*) AS NUM_Transaction,
     ROUND(AVG(ss.Sale_Amount),2) AS Avg_Transaction,
     ROUND(SUM(ss.Sale_Amount),2) AS Monthly_Revenue
FROM store_sales ss
JOIN store_locations sl
  ON ss.Store_ID = sl.StoreId
JOIN products p
  ON ss.Prod_Num = p.ProdNum
JOIN inventory_categories ic
  ON p.Categoryid = ic.Categoryid
WHERE sl.State = 'South Carolina'
GROUP BY DATE_FORMAT(ss.Transaction_Date, '%Y-%m'), ic.Category
ORDER BY Transaction_Month, Monthly_Revenue DESC;

-- 5. Can you provide a ranking of in-store sales performance by each store in the sales territory, or a ranking of online sales performance by state within an online sales territory?
SELECT 
	 sl.StoreId AS Store_ID,
     sl.StoreLocation AS Store,
     ROUND(SUM(ss.Sale_Amount),2) AS Total_Revenue,
     COUNT(*) AS Num_Transaction,
     ROUND(AVG(ss.Sale_Amount),2) AS Avg_Transaction,
     RANK() OVER (ORDER BY SUM(ss.Sale_Amount) DESC) AS Revenue_Rank
FROM store_sales ss
JOIN store_locations sl
  ON ss.Store_ID = sl.StoreId
WHERE sl.State = 'South Carolina'
GROUP BY sl.StoreId, sl.storeLocation
ORDER BY Revenue_Rank;

-- 6. What is your recommendation for where to focus sales attention in the next quarter?

-- My recommendation: Total revenue and transaction count by product category in South Carolina
SELECT 
     ic.Category AS Product_Category,
     ROUND(SUM(ss.Sale_Amount),2) AS Total_Revenue,
     COUNT(*) AS Num_Transaction,
     ROUND(AVG(ss.Sale_Amount),2) AS Avg_Transaction
FROM store_sales ss
JOIN store_locations sl
  ON ss.Store_ID = sl.StoreId
JOIN products p
  ON ss.Prod_Num = p.ProdNum
JOIN inventory_categories ic
  ON p.Categoryid = ic.Categoryid
WHERE sl.State = 'South Carolina'
GROUP BY ic.Category
ORDER BY Total_Revenue DESC; 

-- Based on the analysis of South carolina territory sales data, the recommendation is to focus sales attention on Technology & Accessories in the next quarter.
-- Technology & Accessories generated the highest total revenue at $472,118.34 with 977 transactions and an avergae transaction size of $483.23 by far the highest avergae of all categories.
-- Textbooks ranked 2nd in total revenue at $103,238.99 but has a much lower avergae transaction of $175.58, means Technology drives more value per sale.
-- Greenville rank#1 store as it outperformed Charleston in total revenue ($337,002 vs 311,810).
-- Prioritize Technology & Accessories promotions and inventory in Greenville to maximize revenue next quarter.






    





















