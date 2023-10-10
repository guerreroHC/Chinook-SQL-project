/***************************************************************
		Q1: How many songs were sold by each Artist/Band
***************************************************************/

SELECT artist.Name,COUNT(DISTINCT(InvoiceLine.TrackId)) AS Songs_sold
FROM InvoiceLine
JOIN Track
ON InvoiceLine.TrackId = Track.TrackId
JOIN Album
ON Track.AlbumId = Album.AlbumId
JOIN Artist
ON Album.ArtistId = Artist.ArtistId
GROUP BY artist.Name	
ORDER BY Songs_sold DESC

/***************************************
		Q2: Total sales by genre
***************************************/

CREATE VIEW Total_sales AS (
	SELECT SUM(UnitPrice * Quantity) AS Sales
	FROM InvoiceLine
)

SELECT Genre.Name, SUM(InvoiceLine.UnitPrice * InvoiceLine.Quantity) AS Sales, 
CONCAT(ROUND(CAST((SUM(InvoiceLine.UnitPrice * InvoiceLine.Quantity)/(SELECT * FROM Total_sales)*100) as float),2), '%') AS Porcentage
FROM InvoiceLine
JOIN Track
ON InvoiceLine.TrackId = Track.TrackId
JOIN Genre
ON Track.GenreId = Genre.GenreId
GROUP BY Genre.Name
ORDER BY Sales DESC

/*****************************************************
		Q3: Most popular genre of each country
*****************************************************/

CREATE VIEW purchases_per_genre AS (
	SELECT customer.Country, genre.Name, COUNT(*) AS purchases
	FROM InvoiceLine
	JOIN Invoice ON InvoiceLine.InvoiceId = Invoice.InvoiceId
	JOIN Customer ON Invoice.CustomerId = Customer.CustomerId
	JOIN Track ON InvoiceLine.TrackId = Track.TrackId 
	JOIN Genre ON Track.GenreId = Genre.GenreId
	GROUP BY Genre.Name, Customer.Country
)

CREATE VIEW max_purchases_per_country AS (
	SELECT MAX(purchases) AS max_purchases, country
	FROM purchases_per_genre
	GROUP BY country
)
----The actual table----
SELECT ppg.Country, ppg.Name as Genre, ppg.purchases as Numb_of_purchases
FROM purchases_per_genre ppg
JOIN max_purchases_per_country mppg on ppg.Country = mppg.Country
WHERE ppg.purchases = mppg.max_purchases
ORDER BY ppg.Country

/********************************************************************************
		Q3.2 Most popular genre of an introduced country using a function
********************************************************************************/

CREATE FUNCTION Most_pupular_genre_of_a_country (@country VARCHAR(50))
RETURNS TABLE
RETURN
SELECT ppg.Name AS Genre, ppg.purchases AS Numb_of_purchases
FROM purchases_per_genre ppg
JOIN max_purchases_per_country mppg ON ppg.Country = mppg.Country
WHERE ppg.purchases = mppg.max_purchases and ppg.Country = @country

----Example----
SELECT * FROM Most_pupular_genre_of_a_country('Australia')

/**********************************************************
		Q4 Who is the best costumer of each country
**********************************************************/

CREATE VIEW purchases_per_customer AS (
	SELECT CONCAT(Customer.FirstName, ' ', Customer.Lastname) AS Full_Name, Customer.Country, SUM(Invoice.Total) AS Total
	FROM Customer
	JOIN Invoice ON Customer.CustomerId = Invoice.CustomerId
	GROUP BY CONCAT(Customer.FirstName, ' ', Customer.Lastname), Customer.Country
)

CREATE VIEW max_purchases_per_customer_country AS (
	SELECT MAX(Total) AS max_total, Country
	FROM purchases_per_customer
	GROUP BY country
)
----The actual table----
SELECT ppc.Country, ppc.Full_Name, ppc.Total 
FROM purchases_per_customer ppc
JOIN max_purchases_per_customer_country mppc on ppc.Country = mppc.Country
WHERE ppc.Total = mppc.max_total
ORDER BY ppc.Country
