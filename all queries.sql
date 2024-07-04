SELECT * FROM employee
ORDER BY levels DESC
LIMIT 1;







--Q1.Who is senior most employee?
SELECT first_name,last_name,title,hire_date
FROM employee
GROUP BY first_name,last_name,title,hire_date
ORDER BY hire_date
LIMIT 1;

--Q2.Which countries have the most invoices ?
SELECT billing_country,
COUNT(*) AS total_invoices
FROM invoice
GROUP BY billing_country
ORDER BY COUNT(*) DESC;

--Q3.What are top three values of total invoices ?
SELECT invoice_id,total
FROM invoice
ORDER BY total DESC
LIMIT 3;

--Q4.Return city of total invoice for promo ?
SELECT billing_city,
SUM(total) AS money_made
FROM invoice
GROUP BY billing_city
ORDER by SUM(total) DESC
LIMIT 3;

--Q5.Who is best customer ?, Who has spent most money.
SELECT inv.customer_id,
		first_name,
		last_name,
		SUM(total) AS total_spent
FROM invoice AS inv
	INNER JOIN customer AS cust
	ON inv.customer_id = cust.customer_id
GROUP BY inv.customer_id,first_name,last_name
ORDER by SUM(total) DESC
LIMIT 1;

--Q6. email, firat_name,last_name for genre Rock ?
SELECT DISTINCT email,TRIM(first_name) AS first_name,
TRIM(last_name) AS last_name
FROM customer
INNER JOIN invoice
ON customer.customer_id = invoice.customer_id
	INNER JOIN invoice_line
	ON invoice_line.invoice_id = invoice.invoice_id
WHERE track_id IN(
		SELECT track_id FROM track
		INNER JOIN genre
		ON track.genre_id = genre.genre_id
		WHERE genre.name LIKE 'Rock')
ORDER BY email;
	
	
--Q7
SELECT artist.artist_id,
artist.name AS Artist_name,
COUNT(track_id) AS total_tracks
FROM artist
	INNER JOIN album
	ON artist.artist_id = album.artist_id
	INNER JOIN track
	ON album.album_id = track.album_id
	WHERE track_id IN(
	SELECT track_id FROM track
	INNER JOIN genre
	ON track.genre_id = genre.genre_id
	WHERE genre.name LIKE 'Rock')
GROUP BY artist.artist_id,artist.name
ORDER BY COUNT(track_id) DESC
LIMIT 10;
	


--Q8. return song with length more than avg.length
SELECT name,milliseconds FROM track
	WHERE track.milliseconds >
	(SELECT AVG(milliseconds) AS avg_length FROM track)
	ORDER BY milliseconds DESC;
	
	
	
--Q9	
SELECT CONCAT(TRIM(first_name),' ',TRIM(last_name)) AS customer_name,
artist.name AS Artist_name,
SUM(inl.unit_price*inl.quantity) AS total_spent FROM customer
	INNER JOIN invoice
	ON customer.customer_id = invoice.customer_id
	INNER JOIN invoice_line AS inl
	ON inl.invoice_id = invoice.invoice_id
	INNER JOIN track
	ON inl.track_id = track.track_id
	INNER JOIN album
	ON track.album_id = album.album_id
	INNER JOIN artist
	ON album.artist_id = artist.artist_id
GROUP BY first_name,last_name,artist.name
ORDER BY customer_name,total_spent DESC

---Q10
WITH country_genre_cnt
AS
(SELECT billing_country AS country,
 genre,COUNT(iv.total), 
 DENSE_RANK() OVER
	 (PARTITION BY billing_country
	  	ORDER BY COUNT(iv.total) DESC)
FROM invoice AS iv
	INNER JOIN invoice_line
	USING(invoice_id)
	INNER JOIN track AS tr
	USING(track_id)
	INNER JOIN genre
	USING(genre_id)
GROUP BY country,genre
ORDER BY country , count DESC)
	SELECT country,genre
	FROM country_genre_cnt
	WHERE dense_rank <= 1
	
--Q11
WITH country_cust_most_spent
 AS
(SELECT billing_country AS country,
	first_name,last_name,
	SUM(total) AS spent,
	DENSE_RANK() OVER (PARTITION BY billing_country
				 ORDER BY SUM(total) DESC)
	FROM invoice as iv
	INNER JOIN customer AS cm
	USING(customer_id)
	GROUP BY billing_country,first_name,last_name )
SELECT country,
CONCAT(TRIM(first_name),' ',TRIM(last_name)) AS customer_name,
spent
FROM country_cust_most_spent
WHERE dense_rank <= 1;
	











