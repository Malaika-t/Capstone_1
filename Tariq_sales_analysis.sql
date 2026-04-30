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
     DATE_FORMAT(ss.Transaction_Date, '%Y-%m') AS YearMonth,
     ROUND(SUM(ss.Sale_Amount),2) AS Monthly_Revenue
FROM store_sales ss
JOIN store_locations sl
  ON ss.Store_ID = sl.StoreId
WHERE sl.State = 'South Carolina'
GROUP BY ss.Store_ID, DATE_FORMAT(ss.Transaction_Date, '%Y-%m')
ORDER BY ss.Store_ID, YearMonth;

-- 3. Provide a comparison of total revenue for the specific sales territory and the region it belongs to.
WITH 
   South_Sale AS (
              SELECT sl.State,
					 ss.Sale_Amount
			  FROM store_sales ss 
              JOIN store_locations sl
                ON ss.Store_ID = sl.StoreId
			 WHERE sl.State IN ('South Carolina', 'Florida', 'Texas')
)
SELECT 
	    State AS Territory,
        'South' AS Region,
        ROUND(SUM(Sale_Amount),2) AS Total_Revenue
FROM South_Sale
GROUP BY State

UNION ALL 

SELECT 
	'South Region Total',
	'South',
	 ROUND(SUM(Sale_Amount),2) 
FROM South_Sale
ORDER BY Total_Revenue ASC;

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

-- My recommendation: 
-- Rank customers within each store by total spending and transaction count 
SELECT 
	 ss.Transaction_Date AS Transaction_Date,
	 sl.StoreId AS Store_ID,
     ic.Category AS product_Category,
     MONTH(ss.Transaction_Date) AS Sale_Month,
     ROUND(SUM(ss.Sale_Amount),2) AS Total_Spent,
     COUNT(*) AS Num_Transaction,
     ROUND(SUM(ss.Sale_Amount),2) AS Avg_Transaction,
     RANK() OVER (PARTITION BY sl.StoreId ORDER BY SUM(ss.Sale_Amount) DESC) AS Customer_Rank 	
FROM store_sales ss
JOIN store_locations sl
  ON ss.Store_ID = sl.StoreId
JOIN products p
  ON ss.Prod_Num = p.ProdNum
JOIN inventory_categories ic
  ON p.Categoryid = ic.Categoryid

WHERE sl.State = 'South Carolina'
GROUP BY sl.StoreId, ss.Transaction_Date, ic.Category
ORDER BY sl.StoreId, Customer_Rank; 

-- Based on the sales analysis and results, technology & accessories ranked# 1. 
-- Every top ranked transaction at store 852 is from technology & accessories with no other category appearing in the results.
-- Months September through December dominates, meaning it is the prime selling season.
-- Average transaction value is also high, it confirms that technology & accessories customers spent more per visit. 
-- For Next Quarter: Focus sales attention on Technology & Accessories at Store 852 Charleston specifically during September-December. This category consistently generates the highest revenue per transaction. 
-- Precriptive Analysis: Increasing inventory, running targeted promotions, and training staff on technology & accessories during these peak months will maximize revenue in the next quarter.
