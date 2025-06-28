--Tables AS follows
SELECT * FROM hotel_bookings;
SELECT * FROM cities;
SELECT * FROM hotels;
SELECT * FROM customers;


/* 
1. Top 5 customers booking most in their home city (where they live)
Question:
Find the top 5 customers who made the most number of bookings in the same city where they live.
Also, show the percentage of such bookings compared to their total bookings.

Hint:
Use JOIN between hotel_bookings, customers, hotels, and cities.
Use COUNT(), GROUP BY customer_id, and calculate percentage like:
(bookings_in_home_city * 100.0 / total_bookings)

Expected Output:
| customer_id | bookings_in_home_city | total_bookings | percent_in_home_city |
*/

WITH CTE AS (
SELECT 
hb.customer_id, 
COUNT( CASE WHEN h.city_id = cu.city_id THEN hb.booking_id END) same_city_booking,
COUNT(*) total_bookings
FROM hotel_bookings hb 
JOIN customers cu
ON hb.customer_id=cu.customer_id
JOIN hotels h
ON hb.hotel_id=h.id
GROUP BY hb.customer_id
)

SELECT TOP 5 *,ROUND((100.0*same_city_booking)/total_bookings,2) AS same_City_percentage
FROM CTE 
ORDER BY same_city_booking DESC, same_City_percentage DESC

-----------------------------------------------------------------------------------------------------------------------------
/*
2. Percent contribution by female customers (Revenue & Booking Count per hotel)
Question:
For each hotel, calculate:

% revenue from female customers

% of bookings done by female customers

Hint:
Use SUM(CASE WHEN gender = 'Female' THEN revenue END)
Divide by total hotel revenue and total hotel bookings.

Expected Output:
| hotel_id | percent_revenue_female | percent_bookings_female |
*/


WITH full_hotel AS(

			SELECT hotel_id, COUNT(*) AS total_bookings,
			SUM(per_night_rate*number_of_nights) AS total_revnue
			FROM hotel_bookings hb 
			JOIN customers cu 
			ON hb.customer_id=cu.customer_id
			GROUP BY hotel_id
			),
	female_hotels AS (
		SELECT hotel_id AS fhotel_id, COUNT(*) AS female_bookings,
					SUM(per_night_rate*number_of_nights) AS female_revenue
			FROM hotel_bookings hb 
		JOIN customers cu 
		ON hb.customer_id=cu.customer_id
		WHERE gender = 'F'
		GROUP BY hotel_id
		)


SELECT hotel_id,
ROUND((100.0*female_bookings)/total_bookings,2) AS female_booking_percentage,
ROUND((100.0*female_revenue)/total_revnue,2) AS female_revenue_percentage
FROM full_hotel f
LEFT JOIN female_hotels fe
ON f.hotel_id=fe.fhotel_id

-----------------------------------------------------------------------------------------------------------------------------


/*

3. Hotel-wise bookings from customers of different states
Question:
For each hotel, count how many bookings came from customers whose home state is different from the hotel’s city state.

Hint:
Join hotel_bookings, customers, hotels, and cities
Compare customer.state with hotel.state

Expected Output:
| hotel_id | bookings_from_other_states |

*/

SELECT hb.customer_id, COUNT(*) AS no_of_bookings FROM hotel_bookings hb
JOIN hotels h ON hb.hotel_id=h.id
JOIN cities c1 ON h.city_id=c1.id
JOIN customers cu ON cu.city_id = hb.customer_id
JOIN cities c2 ON c2.id = cu.city_id

WHERE c1.state != c2.state

GROUP BY hb.customer_id

-----------------------------------------------------------------------------------------------------------------------------

/*

4. Date when hotel had maximum occupancy (excluding checkout date)
Question:
For each hotel, find the date when the number of occupied rooms was the highest.
Ignore customers who were only checking out that day.

Hint:
Focus on stay date between check-in and check-out.
For each hotel and date, count distinct rooms occupied.

Expected Output:
| hotel_id | occupancy_date | occupied_rooms_count |
*/

--note creating a table for day wise booking data as it will be used in multiple questions
with cte as (
select hotel_id , customer_id 
,stay_start_date as start_date , DATEADD(day,number_of_nights-1,stay_start_date) as end_date
from hotel_bookings
)
, rcte as (
select hotel_id , customer_id, start_date as stay_date,end_date 
from cte
union all
select hotel_id , customer_id , DATEADD(day,1,stay_date) as stay_date, end_date
from rcte
where DATEADD(day,1,stay_date) <= end_date
)
select * into hotel_bookings_flatten from rcte

select * from hotel_bookings_flatten;

----------------------------------------------------------------------------------------------------------------------------------------
WITH CTE AS (

SELECT hotel_id, stay_date, COUNT(*) AS no_of_bookings,
RANK() OVER(PARTITION BY hotel_id ORDER BY COUNT(*) DESC) AS rn
FROM hotel_bookings_flatten
GROUP BY  hotel_id, stay_date)

SELECT * FROM CTE
WHERE rn = 1

-----------------------------------------------------------------------------------------------------------------------------
/*

5. Customers who booked hotels in at least 3 different states
Question:
Find customers who made bookings in hotels located across at least 3 different states.

Hint:
Use COUNT(DISTINCT hotel_state) with GROUP BY customer_id.

Expected Output:
| customer_id | number_of_states |

*/

SELECT hb.customer_id, COUNT( DISTINCT c.state) AS no_of_states FROM hotel_bookings hb
JOIN hotels h ON hb.hotel_id=h.id
JOIN cities c ON h.city_id=c.id
GROUP BY hb.customer_id
HAVING COUNT(DISTINCT c.state) >= 3

-----------------------------------------------------------------------------------------------------------------------------
/*
6. Hotel Occupancy Rate per month
Question:
For each hotel and each month, calculate the occupancy rate:
(Number of rooms booked / Total rooms available) * 100

Hint:
You’ll need total rooms available (likely from hotel data).
Group by hotel and month.

Expected Output:
| hotel_id | month | occupancy_rate |
*/

WITH CTE AS (
SELECT hb.hotel_id,
hb.stay_date,
COUNT(*) AS no_of_guests,
h.capacity
FROM hotel_bookings_flatten hb
JOIN hotels h ON hb.hotel_id=h.id
GROUP BY hb.hotel_id,hb.stay_date, h.capacity
)

SELECT hotel_id, MONTH(stay_date) AS mth, SUM(100.0*no_of_guests)/SUM(capacity) AS ocupancy_rate
FROM CTE
GROUP BY hotel_id, MONTH(stay_date)
ORDER BY hotel_id, mth

-----------------------------------------------------------------------------------------------------------------------------
/*

7. Dates when each hotel was fully occupied
Question:
Find the dates for each hotel when all rooms were occupied (100% occupancy).

Hint:
Filter where booked_rooms = total_rooms.

Expected Output:
| hotel_id | full_occupancy_date |
*/


WITH CTE AS (

SELECT hotel_id, stay_date, COUNT(*) AS no_of_bookings
FROM hotel_bookings_flatten
GROUP BY hotel_id, stay_date

)

SELECT c.hotel_id, no_of_bookings
FROM CTE c
JOIN hotels h 
ON c.hotel_id=h.id
WHERE no_of_bookings=capacity

-----------------------------------------------------------------------------------------------------------------------------
/*
8. Which booking channel gave highest sales for each hotel per month
Question:
For each hotel and each month, find which booking channel brought the highest total sales (revenue).

Hint:
Use GROUP BY hotel_id, month, booking_channel and RANK() or ROW_NUMBER() with PARTITION BY hotel_id, month ORDER BY revenue DESC.

Expected Output:
| hotel_id | month | top_booking_channel | total_sales |
*/
WITH CTE AS (
SELECT hotel_id, FORMAT(booking_date,'yyyy-MM') AS year_mth, booking_channel , 
SUM(number_of_nights*per_night_rate) AS total_revnue

FROM hotel_bookings
GROUP BY hotel_id, FORMAT(booking_date,'yyyy-MM'), booking_channel
)

SELECT * FROM (SELECT *,ROW_NUMBER() OVER(PARTITION BY hotel_id ORDER BY total_revnue DESC) AS rn
FROM CTE) S
WHERE rn = 1
-----------------------------------------------------------------------------------------------------------------------------
/*

9. Percent share of bookings by each booking channel
Question:
Find the percentage share of bookings done via each booking channel overall.

Hint:
COUNT() by channel divided by total booking count.

Expected Output:
| booking_channel | percent_share |
*/

SELECT booking_channel, COUNT(*) AS total_bookings,
ROUND(COUNT(*)*100.0/SUM(COUNT(*)) OVER(),2) AS percentage_share
FROM hotel_bookings
GROUP BY booking_channel
ORDER BY percentage_share DESC

-----------------------------------------------------------------------------------------------------------------------------
/*
10. Total revenue generated by Millennials and Gen Z for each hotel
Question:
For each hotel, find total revenue generated by:

Millennials (born 1980–1996)

Gen Z (born after 1996)

Hint:
Use YEAR(GETDATE()) - YEAR(dob) for age calculation if no direct age field.
Or calculate based on DOB ranges.

Expected Output:
| hotel_id | millennial_revenue | gen_z_revenue |
*/

SELECT 
hotel_id, 
SUM(CASE WHEN DATEPART(YEAR,dob) BETWEEN 1980 AND 1996 THEN number_of_nights*per_night_rate END) AS millenial_revnue,
SUM(CASE WHEN DATEPART(YEAR,dob) > 1996 THEN number_of_nights*per_night_rate END) AS Gen_Z_Revenue
FROM hotel_bookings hb
JOIN customers cu ON hb.customer_id=cu.customer_id
GROUP BY hotel_id
-----------------------------------------------------------------------------------------------------------------------------
/*
Average stay duration per hotel
Question:
For each hotel, calculate the average stay duration (number of days between check-in and check-out).

Hint:
Use DATEDIFF(day, check_in, check_out)

Expected Output:
| hotel_id | average_stay_duration |
*/

SELECT hotel_id, AVG(number_of_nights) AS avg_days FROM hotel_bookings
GROUP BY hotel_id

-----------------------------------------------------------------------------------------------------------------------------
/*
12. Average days customers book in advance (lead time)
Question:
For each hotel, find average number of days customers booked in advance (difference between booking date and check-in date).

Hint:
DATEDIFF(day, booking_date, check_in_date)

Expected Output:
| hotel_id | average_lead_time_days |
*/

SELECT hotel_id, AVG(DATEDIFF(DAY, booking_date, stay_start_date)) AS avg_advance_bookings
FROM hotel_bookings
GROUP BY hotel_id
-----------------------------------------------------------------------------------------------------------------------------

/*
13. Customers who never booked at all
Question:
Find customers who have never made any hotel booking.

Hint:
Use LEFT JOIN customers with hotel_bookings and filter WHERE booking_id IS NULL.

Expected Output:
| customer_id | customer_name |
*/

SELECT cu.customer_id FROM customers cu
LEFT JOIN hotel_bookings hb
ON cu.customer_id= hb.customer_id
WHERE hb.customer_id IS NULL

-----------------------------------------------------------------------------------------------------------------------------
/*
14. Customers who stayed in at least 3 distinct hotels in the same month
Question:
Find customers who stayed in at least 3 different hotels in the same calendar month.
Display customer name, month, and number of hotels booked.

Hint:
Use COUNT(DISTINCT hotel_id) grouped by customer_id, month.

Expected Output:
| customer_id | customer_name | month | distinct_hotels_count |

*/ 


SELECT customer_id, MONTH(stay_date) AS mth, COUNT(DISTINCT hotel_id) AS distinct_hotels_count 
FROM hotel_bookings_flatten
GROUP BY customer_id, MONTH(stay_date)
HAVING COUNT(DISTINCT hotel_id)>=3
ORDER BY distinct_hotels_count DESC


-----------------------------------------------------------------------------------------------------------------------------