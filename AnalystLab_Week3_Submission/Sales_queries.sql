USE SalesDB;

-- 10. Top 10 Customers by Revenue
SELECT TOP 10
    CUSTOMERNAME,
    COUNTRY,
    COUNT(DISTINCT ORDERNUMBER) AS TotalOrders,
    ROUND(SUM(SALES), 2) AS TotalRevenue
FROM sales_data_sample
GROUP BY CUSTOMERNAME, COUNTRY
ORDER BY TotalRevenue DESC;


-- 11. Revenue by Product Line
SELECT 
    PRODUCTLINE,
    COUNT(DISTINCT ORDERNUMBER) AS TotalOrders,
    SUM(QUANTITYORDERED) AS TotalQuantity,
    ROUND(SUM(SALES), 2) AS TotalRevenue,
    ROUND(AVG(SALES), 2) AS AvgOrderValue
FROM sales_data_sample
GROUP BY PRODUCTLINE
ORDER BY TotalRevenue DESC;


-- 12. Revenue Trend by Year and Month
SELECT 
    YEAR_ID AS Year,
    MONTH_ID AS Month,
    COUNT(DISTINCT ORDERNUMBER) AS TotalOrders,
    ROUND(SUM(SALES), 2) AS MonthlyRevenue
FROM sales_data_sample
GROUP BY YEAR_ID, MONTH_ID
ORDER BY Year, Month;


-- 13. Revenue by Country and Deal Size
SELECT 
    COUNTRY,
    DEALSIZE,
    COUNT(DISTINCT ORDERNUMBER) AS TotalOrders,
    ROUND(SUM(SALES), 2) AS TotalRevenue
FROM sales_data_sample
GROUP BY COUNTRY, DEALSIZE
ORDER BY COUNTRY, TotalRevenue DESC;


-- 14. Running Total Revenue by Month (Window Function)
SELECT 
    YEAR_ID AS Year,
    MONTH_ID AS Month,
    ROUND(SUM(SALES), 2) AS MonthlyRevenue,
    ROUND(SUM(SUM(SALES)) OVER (
        PARTITION BY YEAR_ID 
        ORDER BY MONTH_ID
    ), 2) AS RunningTotal
FROM sales_data_sample
GROUP BY YEAR_ID, MONTH_ID
ORDER BY Year, Month;