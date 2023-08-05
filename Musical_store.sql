Create Database Music_Store;
Use Music_Store;
SELECT * FROM artist;
SELECT * FROM customer;
SELECT * FROM employee;
SELECT * FROM genre;
SELECT * FROM invoice;
SELECT * FROM Invoice_line;
SELECT * FROM media_type;
SELECT * FROM Track;
SELECT * FROM album2;
# q1. Who is the Senior most Empployee
SELECT * FROM employee order by levels ASC;
# if I want to limit the Rows
SELECT * FROM employee order by Levels ASC LIMIT 1;
#q2 Which countries have the most invoices
SELECT COUNT(*), Billing_country FROM Invoice
GROUP BY Billing_country ORDER BY Billing_country ASC; 
# q3 what are top 3  total values from invoice
SELECT total FROM invoice ORDER BY total DESC Limit 3;
/* Q5: Who is the best customer? The customer who has spent the most money will be declared the best customer. 
Write a query that returns the person who has spent the most money.*/
SELECT billing_city , SUM(total) from invoice GROUP BY billing_city ORDER BY SUM(total) DESC;
/* Q1: Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
Return your list ordered alphabetically by email starting with A. */
SELECT c.first_name,c.last_name,i.customer_id, SUM(total) from invoice i JOIN Customer c ON(i.customer_id=c.customer_id) GROUP BY c.first_name,c.last_name,i.customer_id ORDER BY SUM(total) DESC LIMIT 3;

/* Q1: Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
Return your list ordered alphabetically by email starting with A. */
SELECT distinct email,first_name,last_name,Genre.name FROM customer c JOIN Invoice i ON (c.customer_id=i.customer_id) JOIN Invoice_line l ON
(i.Invoice_Id=l.Invoice_Id) JOIN Track T ON (l.Track_Id=T.Track_Id) JOIN Genre ON(T.Genre_Id=Genre.Genre_Id) WHERE Genre.name LIKE "Rock" ORDER BY email;

 /*Let's invite the artists who have written the most rock music in our dataset. 
Write a query that returns the Artist name and total track count of the top 10 rock bands.*/

SELECT A.name, Al.Artist_id, g.name,Count(Al.Artist_id) as Number_of_Songs FROM Artist A  JOIN Album2 Al ON (A.Artist_id=Al.Artist_id) Join Track T ON(Al.Album_id=T.Album_id)  JOIN Genre G ON (T.genre_id=G.genre_id) Where G.name ="Rock" GROUP BY A.name, Al.Artist_id Order By Al.Artist_id DESC LIMIT 10;
 /* Q3: Return all the track names that have a song length longer than the average song length. 
Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first. */
SELECT name, milliseconds FROM Track WHERE milliseconds>(SELECT Avg(milliseconds) AS Avg_track_length FROM Track) Order by milliseconds DESC;
/* Q1: Find how much amount spent by each customer on artists? Write a query to return customer name, artist name and total spent */
# areeba
SELECT c.last_name,artists.name, sum(l.unit_price*l.quantity) AS Total FROM customer c JOIN Invoice i ON( c.customer_Id=i.customer_id) JOIN invoce_line l ON
(i.invoice_Id=l.invoce_Id) JOIN Track ON(l.Track_Id=Track.Track_Id) JOIN Album2 ON (Track.Album_Id=Album2.Album_Id) JOIN Artist ON (Album2.Artist_Id=Artist.Artist_Id);
#chat GPt

WITH best_selling_artist AS (
    SELECT
        artist.artist_id AS artist_id,
        artist.name AS artist_name,
        SUM(invoice_line.unit_price * invoice_line.quantity) AS total_sales
    FROM
        invoice_line
    JOIN
        track ON track.track_id = invoice_line.track_id
    JOIN
        album2 ON album2.album_id = track.album_id
    JOIN
        artist ON artist.artist_id = album2.artist_id
    GROUP BY 1,2
    ORDER BY 3 DESC
    LIMIT 4
)
SELECT * FROM best_selling_artist;

/* Q2: We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre 
with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where 
the maximum number of purchases is shared return all Genres. important */

With Highest_purchase AS( SELECT G.Name, c.country, COUNT(l.quantity) AS purchase,ROW_Number()
 Over(Partition BY c.country ORDER By(l.quantity) DESC) AS Rows_number
 FROM invoice i Join invoice_line l ON
(i.invoice_id=l.invoice_id)Join Customer c ON(c.customer_id=i.customer_id) 
Join Track T ON(l.track_id=T.Track_id) 
JOIN Genre G ON(G.Genre_id=T.genre_id) GROUP By 1,2 ORDER By 3 ASC)
 SELECT * FROM Highest_purchase Where Rows_number<=1;
 
 WITH Highest_purchase AS (
    SELECT G.Name, c.country, COUNT(l.quantity) AS purchase,
           ROW_NUMBER() OVER(PARTITION BY c.country ORDER BY Count(l.quantity) DESC) AS Rows_number
    FROM invoice i
    JOIN invoice_line l ON i.invoice_id = l.invoice_id
    JOIN Customer c ON c.customer_id = i.customer_id
    JOIN Track T ON l.track_id = T.Track_id
    JOIN Genre G ON G.Genre_id = T.genre_id
    GROUP BY 1, 2 ORDER BY 1 ASC,1  DESC
)
SELECT * FROM Highest_purchase WHERE Rows_number <= 1;

/*Write a query that determines the customer that has spent the most on music for each country. 
Write a query that returns the country along with the top customer and how much they spent. 
For countries where the top amount spent is shared, provide all customers who spent this amount. */

WITH RECURSIVE Customer_with_country AS (
    SELECT customer.customer_id,
           first_name,
           last_name,
           billing_country,
           SUM(total) AS total_spending
    FROM Invoice
    JOIN Customer ON customer.Customer_id = invoice.customer_id
    GROUP BY 1, 2, 3, 4
),
Country_max_spending AS (
    SELECT billing_country, MAX(total_spending) AS max_spending
    FROM Customer_with_country
    GROUP BY billing_country
)
SELECT cc.billing_country,
       cc.total_spending,
       cc.first_name,
       cc.last_name,
       cc.customer_id
FROM Customer_with_country cc
JOIN Country_max_spending ms ON cc.billing_country = ms.billing_country
WHERE cc.total_spending = ms.max_spending
ORDER BY 1;


