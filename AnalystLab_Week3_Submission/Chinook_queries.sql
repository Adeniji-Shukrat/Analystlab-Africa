USE Chinook_AutoIncrement;

SELECT name 
FROM sys.tables;

USE SalesDB;

SELECT TOP 5 *
FROM sales_data_sample;

USE Chinook_AutoIncrement;

SELECT 'Customer' AS TableName, COUNT(*) AS TotalRows FROM Customer
UNION ALL
SELECT 'Invoice', COUNT(*) FROM Invoice
UNION ALL
SELECT 'InvoiceLine', COUNT(*) FROM InvoiceLine
UNION ALL
SELECT 'Track', COUNT(*) FROM Track
UNION ALL
SELECT 'Artist', COUNT(*) FROM Artist;


-- 1. Top 10 Customers by Total Purchases
SELECT TOP 10
    c.FirstName + ' ' + c.LastName AS CustomerName,
    c.Country,
    COUNT(i.InvoiceId) AS TotalOrders,
    ROUND(SUM(i.Total), 2) AS TotalSpent
FROM Customer c
INNER JOIN Invoice i ON c.CustomerId = i.CustomerId
GROUP BY c.FirstName, c.LastName, c.Country
ORDER BY TotalSpent DESC;

-- 2. Revenue by Country
SELECT 
    c.Country,
    COUNT(DISTINCT c.CustomerId) AS TotalCustomers,
    COUNT(i.InvoiceId) AS TotalOrders,
    ROUND(SUM(i.Total), 2) AS TotalRevenue
FROM Customer c
INNER JOIN Invoice i ON c.CustomerId = i.CustomerId
GROUP BY c.Country
ORDER BY TotalRevenue DESC;

-- 3. Monthly Revenue Trend
SELECT 
    YEAR(i.InvoiceDate) AS Year,
    MONTH(i.InvoiceDate) AS Month,
    COUNT(i.InvoiceId) AS TotalOrders,
    ROUND(SUM(i.Total), 2) AS MonthlyRevenues
FROM Invoice i
GROUP BY YEAR(i.InvoiceDate), MONTH(i.InvoiceDate)
ORDER BY Year, Month;

-- 4. Top 10 Best-Selling Tracks by Revenue
SELECT TOP 10
    t.Name AS TrackName,
    ar.Name AS ArtistName,
    g.Name AS Genre,
    SUM(il.Quantity) AS TotalQuantitySold,
    ROUND(SUM(il.UnitPrice * il.Quantity), 2) AS TotalRevenue
FROM InvoiceLine il
INNER JOIN Track t ON il.TrackId = t.TrackId
INNER JOIN Album al ON t.AlbumId = al.AlbumId
INNER JOIN Artist ar ON al.ArtistId = ar.ArtistId
INNER JOIN Genre g ON t.GenreId = g.GenreId
GROUP BY t.Name, ar.Name, g.Name
ORDER BY TotalRevenue DESC;

-- 5. Genres with More Than 100 Tracks
SELECT 
    g.Name AS Genre,
    COUNT(t.TrackId) AS TotalTracks,
    ROUND(AVG(t.Milliseconds) / 60000.0, 2) AS AvgDurationMinutes
FROM Track t
INNER JOIN Genre g ON t.GenreId = g.GenreId
GROUP BY g.Name
HAVING COUNT(t.TrackId) > 100
ORDER BY TotalTracks DESC;


-- 6. Customers Who Have Never Made a Purchase (LEFT JOIN)
SELECT 
    c.CustomerId,
    c.FirstName + ' ' + c.LastName AS CustomerName,
    c.Country,
    c.Email
FROM Customer c
LEFT JOIN Invoice i ON c.CustomerId = i.CustomerId
WHERE i.InvoiceId IS NULL;


-- 7. Tracks That Have Never Been Purchased (Subquery)
SELECT 
    t.Name AS TrackName,
    ar.Name AS ArtistName,
    g.Name AS Genre
FROM Track t
INNER JOIN Album al ON t.AlbumId = al.AlbumId
INNER JOIN Artist ar ON al.ArtistId = ar.ArtistId
INNER JOIN Genre g ON t.GenreId = g.GenreId
WHERE t.TrackId NOT IN (
    SELECT DISTINCT TrackId 
    FROM InvoiceLine
);


-- 8. Customer Revenue Ranking Using Window Functions
SELECT 
    c.FirstName + ' ' + c.LastName AS CustomerName,
    c.Country,
    ROUND(SUM(i.Total), 2) AS TotalSpent,
    RANK() OVER (ORDER BY SUM(i.Total) DESC) AS GlobalRank,
    RANK() OVER (PARTITION BY c.Country ORDER BY SUM(i.Total) DESC) AS CountryRank
FROM Customer c
INNER JOIN Invoice i ON c.CustomerId = i.CustomerId
GROUP BY c.FirstName, c.LastName, c.Country
ORDER BY GlobalRank;


-- 9. Top Customer Per Country Using ROW_NUMBER
WITH RankedCustomers AS (
    SELECT 
        c.FirstName + ' ' + c.LastName AS CustomerName,
        c.Country,
        ROUND(SUM(i.Total), 2) AS TotalSpent,
        ROW_NUMBER() OVER (PARTITION BY c.Country ORDER BY SUM(i.Total) DESC) AS RowNum
    FROM Customer c
    INNER JOIN Invoice i ON c.CustomerId = i.CustomerId
    GROUP BY c.FirstName, c.LastName, c.Country
)
SELECT CustomerName, Country, TotalSpent
FROM RankedCustomers
WHERE RowNum = 1
ORDER BY TotalSpent DESC;