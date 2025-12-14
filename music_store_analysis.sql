/*
Project: Digital Music Store Analysis 
Database: Chinook (Simulated Music Store Data)
Author: [Your Name]
Tool Used: MySQL Workbench
Description: This project analyzes the music playlist database to help the business understand 
             customer purchasing behavior, sales trends, and inventory management.
*/

USE Chinook;

-- =======================================================
-- SECTION A: BASIC ANALYSIS (Easy)
-- =======================================================

-- 1. Who is the senior most employee based on job title?
SELECT * FROM Employee
ORDER BY levels DESC
LIMIT 1;

-- 2. Which countries have the most Invoices?
SELECT BillingCountry, COUNT(*) AS TotalInvoices
FROM Invoice
GROUP BY BillingCountry
ORDER BY TotalInvoices DESC;

-- 3. What are top 3 values of total invoice?
SELECT Total FROM Invoice
ORDER BY Total DESC
LIMIT 3;

-- =======================================================
-- SECTION B: INTERMEDIATE ANALYSIS (Joins & Aggregations)
-- =======================================================

-- 4. Which city has the best customers? 
-- (We would like to throw a promotional Music Festival in the city we made the most money)
SELECT BillingCity, SUM(Total) AS InvoiceTotal
FROM Invoice
GROUP BY BillingCity
ORDER BY InvoiceTotal DESC
LIMIT 1;

-- 5. Who is the best customer? (The customer who has spent the most money)
SELECT c.CustomerId, c.FirstName, c.LastName, SUM(i.Total) AS TotalSpent
FROM Customer c
JOIN Invoice i ON c.CustomerId = i.CustomerId
GROUP BY c.CustomerId
ORDER BY TotalSpent DESC
LIMIT 1;

-- 6. Return all the email, first name, last name, & Genre of all Rock Music listeners. 
-- Return your list ordered alphabetically by email starting with A
SELECT DISTINCT email, first_name, last_name
FROM customer
JOIN invoice ON customer.customer_id = invoice.customer_id
JOIN invoice_line ON invoice.invoice_id = invoice_line.invoice_id
WHERE track_id IN(
	SELECT track_id FROM track
	JOIN genre ON track.genre_id = genre.genre_id
	WHERE genre.name LIKE 'Rock'
)
ORDER BY email;

-- 7. Which artist has earned the most vs cost? (Joining 4 Tables)
-- Note: This solves the business problem of finding the most profitable artist.
SELECT ar.Name AS ArtistName, SUM(il.UnitPrice * il.Quantity) AS TotalSales
FROM InvoiceLine il
JOIN Track t ON il.TrackId = t.TrackId
JOIN Album al ON t.AlbumId = al.AlbumId
JOIN Artist ar ON al.ArtistId = ar.ArtistId
GROUP BY ar.Name
ORDER BY TotalSales DESC
LIMIT 5;

-- =======================================================
-- SECTION C: ADVANCED ANALYSIS (Subqueries, Self-Joins, Date Functions)
-- =======================================================

-- 8. Find all tracks that have a song length longer than the average song length. 
-- Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first.
SELECT Name, Milliseconds
FROM Track
WHERE Milliseconds > (
	SELECT AVG(Milliseconds) AS AvgTrackLength
	FROM Track )
ORDER BY Milliseconds DESC;

-- 9. Who is reporting to whom? (Self Join)
-- This shows the organizational hierarchy by joining the table to itself.
SELECT e1.LastName AS Employee, e2.LastName AS Manager
FROM Employee e1
JOIN Employee e2 ON e1.ReportsTo = e2.EmployeeId;

-- 10. Find how much money is spent by each customer on specific artists? 
-- Returns Customer Name, Artist Name and Total Spent
SELECT c.FirstName, c.LastName, ar.Name AS Artist, SUM(il.UnitPrice*il.Quantity) AS AmountSpent
FROM Customer c
JOIN Invoice i ON c.CustomerId = i.CustomerId
JOIN InvoiceLine il ON i.InvoiceId = il.InvoiceId
JOIN Track t ON il.TrackId = t.TrackId
JOIN Album alb ON t.AlbumId = alb.AlbumId
JOIN Artist ar ON alb.ArtistId = ar.ArtistId
GROUP BY c.CustomerId, c.FirstName, c.LastName, ar.Name
ORDER BY AmountSpent DESC;

-- 11. Which songs have never been sold? (Inventory / Dead Stock Analysis)
-- Using a LEFT JOIN to find tracks that exist in inventory but have no invoice records.
SELECT t.Name, t.Composer
FROM Track t
LEFT JOIN InvoiceLine il ON t.TrackId = il.TrackId
WHERE il.InvoiceLineId IS NULL;

-- 12. Yearly Sales Trend
-- Using Date Functions to extract Year and calculate total sales per year.
SELECT YEAR(InvoiceDate) AS Year, SUM(Total) AS TotalSales
FROM Invoice
GROUP BY YEAR(InvoiceDate)
ORDER BY Year ASC;