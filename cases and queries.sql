-------------------------------------------------Public Search--------------------------------------------
--1.Search Flight Through Date
@app.route('/SearchFlightThroughDateAuth', methods=['GET', 'POST'])

SELECT *
FROM flight, airport
WHERE flight.departure_airport = airport.airport_name 
AND (departure_airport = 'PVG' OR airport_city = 'Shanghai')
AND datediff(flight.departure_date, '2021-05-20')=0
AND flight.flight_num in
	(SELECT flight.flight_num
	FROM flight, airport
	WHERE flight.arrival_airport = airport.airport_name
	AND (arrival_airport = 'JFK' OR airport_city = 'New York'))


--2.Search Flight Through Flight Number
@app.route('/SearchFlightThroughFlightNumberAuth', methods=['GET', 'POST'])

SELECT *
FROM flight
WHERE flight_num = 12100 
AND datediff(flight.departure_date, '2021-05-20')=0 
AND datediff(flight.arrival_date, '2021-05-21')=0

-------------------------------------------------Registration and Login--------------------------------------------
--Here we do not include an encoding function in the query, but it is executed in the main file app.py.
--1.Customer Registration
@app.route('/CustomerRegisterAuth', methods=['GET', 'POST'])

INSERT INTO customer 
VALUES('cw2982@nyu.edu', 'Gladys', '1234567890', '4', 'Century Anenue', 'Shanghai', 'China', '18019125317', '100000', 'China', '2000-09-30');

--2.Agent Registration
@app.route('/AgentRegisterAuth', methods=['GET', 'POST'])  

INSERT INTO booking_agent 
VALUES('1000@gmail.com', '666666', '999888');

--3.Staff Registration
@app.route('/AirlineStaffRegisterAuth', methods=['GET', 'POST'])

INSERT INTO staff 
VALUES('Rose','China Eastern', '88888888', 'Jisoo', 'Kim', '1996-09-09');


--4.Customer Login
@app.route('/CustomerLoginAuth', methods=['GET', 'POST'])

SELECT * FROM customer WHERE email = cw2982@nyu.edu and password = 1234567890;

--5.Agent Login
@app.route('/AgentLoginAuth', methods=['GET', 'POST'])

SELECT * FROM booking_agent WHERE email = 1000@gmail.com and password = 666666

--6.Staff Login
@app.route('/StaffLoginAuth', methods=['GET', 'POST'])

SELECT * FROM airline_staff WHERE username = Rose and password = 88888888

-------------------------------------------------Customer Use Cases--------------------------------------------
--1. View My Flights
@app.route('/CustomerViewMyFlights', methods=['GET', 'POST'])

--1) Show Upcoming Flights (By Default)

SELECT flight.airline_name, flight.flight_num, flight.departure_airport, flight.departure_date, flight.departure_time, flight.arrival_airport, flight.arrival_date, flight.arrival_time, flight.price, flight.status, flight.airplane_id
FROM flight, ticket, purchases, customer
WHERE status = 'upcoming' and flight.flight_num = ticket.flight_num and flight.airline_name = ticket.airline_name and purchases.ticket_id = ticket.ticket_id and purchases.customer_email = customer.email and customer.email = cw2982@nyu.edu;

--2)Search My Flights by Departure, Destination, and between the range of Departure Date and Arrival Date

SELECT flight.airline_name, flight.flight_num, flight.departure_airport, flight.departure_time, flight.arrival_airport, flight.arrival_time, flight.price, flight.status, flight.airplane_id
FROM purchases, ticket, flight, airport
WHERE  purchases.ticket_id = ticket.ticket_id AND ticket.airline_name = flight.airline_name AND ticket.flight_num = flight.flight_num AND flight.departure_airport = airport.airport_name
and purchases.customer_email = "cw2982@nyu.edu"AND flight.departure_time >= "2021-05-10" AND flight.arrival_time <= "2021-06-10" AND (flight.departure_airport = 'PVG' OR airport.airport_city = 'PVG')
AND (flight.airline_name, flight.flight_num, flight.departure_airport, flight.departure_time, flight.arrival_airport, flight.arrival_time, flight.price, flight.status, flight.airplane_id) IN
(select flight.airline_name, flight.flight_num, flight.departure_airport, flight.departure_time, flight.arrival_airport, flight.arrival_time, flight.price, flight.status, flight.airplane_id
from purchases, ticket, flight, airport
where  purchases.ticket_id = ticket.ticket_id AND ticket.airline_name = flight.airline_name AND ticket.flight_num = flight.flight_num AND flight.arrival_airport = airport.airport_name and
purchases.customer_email = "cw2982@nyu.edu" AND (flight.departure_time >=  "2021-05-10" AND flight.arrival_time <= "2021-06-10" )
AND (flight.arrival_airport = "JFK" OR airport.airport_city = "JFK"));


--2.Purchase Tickets
@app.route('/CustomerPurchaseTickets', methods=['GET', 'POST'])

--1)Get the Total Number of Seats
SELECT seats 
FROM flight, airplane 
WHERE flight.airline_name = 'China Eastern' and flight.flight_num = 12100 and flight.airplane_id = airplane.airplane_id;

--2)Total Seats Sold
SELECT COUNT(ticket_id),flight.flight_num 
FROM ticket,flight WHERE flight.airline_name = 'China Eastern' and flight.flight_num = 12100 and ticket.flight_num = flight.flight_num;

--3)Get New Ticket ID
SELECT MAX(ticket_id) + 1 
FROM ticket;

--4)Update Ticket Info
INSERT INTO ticket (ticket_id, airline_name, flight_num) VALUES (10001, 'China Eastern', 12100);

--5)Update Purchase Info
t = time.strftime("%Y-%m-%d %H:%M:%S", time.localtime())
INSERT INTO purchases (ticket_id, customer_email, booking_agent_id, purchase_date) 
VALUES (10001, "cw2982@nyu.edu",null, t);

--3.Search for Flights
@app.route('/CustomerSearchFlight', methods=['GET', 'POST'])

SELECT *
FROM flight, airport
WHERE flight.departure_airport = airport.airport_name and (departure_airport = "PVG" OR airport_city = "PVG") AND
datediff(flight.departure_time, "2021-05-20")=0
AND flight.flight_num in
(SELECT flight.flight_num 
FROM flight, airport
WHERE flight.arrival_airport = airport.airport_name and (arrival_airport = "JFK" OR airport_city = "JFK"));


--4.Track My Spending
@app.route('/CustomerTrackMySpending', methods=['GET', 'POST'])

--1)Total Money Spent Last Year

SELECT sum(flight.price)
FROM purchases, ticket, flight
WHERE purchases.ticket_id = ticket.ticket_id AND ticket.airline_name = flight.airline_name AND ticket.flight_num = flight.flight_num AND purchases.customer_email = "Customer@nyu.edu" AND purchase_date > date_sub(now(),INTERVAL 12 MONTH) AND purchase_date < now();

--2)Month Wise Money Spent in Last 6 Months

SELCT sum(flight.price), YEAR(purchase_date), MONTH(purchase_date)
FROM purchases, ticket, flight
WHERE purchases.ticket_id = ticket.ticket_id AND ticket.airline_name = flight.airline_name AND ticket.flight_num = flight.flight_num AND purchases.customer_email = "Customer@nyu.edu" AND purchase_date > date_sub(now(),INTERVAL 6 MONTH) AND purchase_date < now()
GROUP BY YEAR(purchase_date), MONTH(purchase_date)
ORDER BY YEAR(purchase_date), MONTH(purchase_date);

--3)Month Wise Money Spent within a Date Range

SELCT sum(flight.price), YEAR(purchase_date), MONTH(purchase_date)
FROM purchases, ticket, flight
WHERE purchases.ticket_id = ticket.ticket_id AND ticket.airline_name = flight.airline_name AND ticket.flight_num = flight.flight_num AND purchases.customer_email = "Customer@nyu.edu" AND purchase_date > "2021-01" AND purchase_date < "2021-06"
GROUP BY YEAR(purchase_date), MONTH(purchase_date)
ORDER BY YEAR(purchase_date), MONTH(purchase_date);



-------------------------------------------------Booking Agent Use Cases--------------------------------------------
--1.View My Flights
@app.route('/BookingAgentViewMyFlights', methods=['GET', 'POST'])

--1)Show Upcoming Flights

SELECT flight.airline_name, flight.flight_num, flight.departure_airport, flight.departure_time, flight.arrival_airport, flight.arrival_time, flight.price, flight.status, flight.airplane_id
FROM flight, ticket, purchases, booking_agent
WHERE status = "upcoming" and flight.flight_num = ticket.flight_num and flight.airline_name = ticket.airline_name and purchases.ticket_id = ticket.ticket_id and purchases.booking_agent_id = booking_agent.booking_agent_id and booking_agent.email = "1000@gmail.com"

--2)Specify Range of Dates, Destination and Departure

SELECT flight.airline_name, flight.flight_num, flight.departure_airport, flight.departure_time, flight.arrival_airport, flight.arrival_time, flight.price, flight.status, flight.airplane_id, purchases.customer_email
FROM purchases, ticket, flight, airport, booking_agent
WHERE booking_agent.booking_agent_id = purchases.booking_agent_id AND purchases.ticket_id = ticket.ticket_id AND ticket.airline_name = flight.airline_name AND ticket.flight_num = flight.flight_num AND flight.departure_airport = airport.airport_name and booking_agent.email = "Booking@agent.com" AND (flight.departure_time >= "2021-05-10" AND flight.arrival_time <= "2021-06-10") AND (flight.departure_airport = "PVG" OR airport.airport_city = "PVG" )
AND (flight.airline_name, flight.flight_num, flight.departure_airport, flight.departure_time, flight.arrival_airport, flight.arrival_time, flight.price, flight.status, flight.airplane_id, purchases.customer_email) IN
(SELECT flight.airline_name, flight.flight_num, flight.departure_airport, flight.departure_time, flight.arrival_airport, flight.arrival_time, flight.price, flight.status, flight.airplane_id, purchases.customer_email
FROM purchases, ticket, flight, airport, booking_agent
WHERE booking_agent.booking_agent_id = purchases.booking_agent_id AND  purchases.ticket_id = ticket.ticket_id AND ticket.airline_name = flight.airline_name AND ticket.flight_num = flight.flight_num AND flight.arrival_airport = airport.airport_name and booking_agent.email = "1000@gmail.com"  AND (flight.departure_time >= "2020-05-10" AND flight.arrival_time <= "2021-06-10")  AND (flight.arrival_airport = "JFK" OR airport.airport_city = "JFK"));

--2.Purchase Tickets
@app.route('/BookingAgentPurchaseTickets', methods=['GET', 'POST'])

--1)Get the Total Number of Seats
SELECT seats 
FROM flight, airplane 
WHERE flight.airline_name = 'China Eastern' and flight.flight_num = 12100 and flight.airplane_id = airplane.airplane_id;

--2)Total Seats Sold
SELECT COUNT(ticket_id),flight.flight_num 
FROM ticket, flight WHERE flight.airline_name = 'China Eastern' and flight.flight_num = 12100 and ticket.flight_num = flight.flight_num;

--3)Get New Ticket ID
SELECT MAX(ticket_id) + 1 
FROM ticket;

--4)Update Ticket Info
INSERT INTO ticket (ticket_id, airline_name, flight_num) VALUES (10001, 'China Eastern', 12100);

--5)Update Purchase Info
t = time.strftime("%Y-%m-%d %H:%M:%S", time.localtime())
INSERT INTO purchases (ticket_id, customer_email, booking_agent_id, purchase_date) 
VALUES (10001, "cw2982@nyu.edu", 1000@gmail.com, t);

--3.Search for Flights
@app.route('/BookingAgentSearchFlight', methods=['GET', 'POST'])

SELECT *
FROM flight, airport
WHERE flight.departure_airport = airport.airport_name and (departure_airport = "PVG" OR airport_city = "PVG") AND
datediff(flight.departure_time, "2021-05-20")=0
AND flight.flight_num in
(SELECT flight.flight_num 
FROM flight, airport
WHERE flight.arrival_airport = airport.airport_name and (arrival_airport = "JFK" OR airport_city = "JFK"));

--4.View My Commission
@app.route('/BookingAgentViewMyCommission', methods=['GET', 'POST'])

SELECT sum(price * 0.1), avg(price * 0.1), count(*)
FROM flight, ticket, purchases, booking_agent
WHERE booking_agent.booking_agent_id = purchases.booking_agent_id AND purchases.ticket_id = ticket.ticket_id AND ticket.airline_name = flight.airline_name AND ticket.flight_num = flight.flight_num AND booking_agent.email = "1000@gmail.com" 
	AND purchase_date <= now() and purchase_date >= date_sub(now(),INTERVAL 1 MONTH);

--5.View Top Customers
@app.route('/BookingAgentViewTopCustomers', methods = ["GET", "POST"])

--1)By Number of Tickets

SELECT customer_email, count(ticket_id) AS count
FROM purchases, booking_agent
WHERE purchase_date >= date_sub(now(),INTERVAL 6 MONTH) and booking_agent.booking_agent_id = purchases.booking_agent_id and booking_agent.email = "1000@gmail.com"
group by customer_email 
ORDER BY count DESC
limit 5;

--2)By Amount of Commissions

SELECT customer_email, sum(price*0.1) as sum
FROM purchases, ticket, flight, booking_agent
WHERE purchase_date >= date_sub(now(),INTERVAL 12 MONTH) and purchases.ticket_id = ticket.ticket_id and ticket.airline_name=flight.airline_name and ticket.flight_num = flight.flight_num
	and booking_agent.booking_agent_id = purchases.booking_agent_id and booking_agent.email = "1000@gmail.com"
group by customer_email
ORDER BY sum DESC
limit 5;
-------------------------------------------------Staff Use Cases--------------------------------------------

--1.View My Flights

--1)Show Upcoming Flights within 30 days (By Default)
@app.route('/StaffViewMyFlights', methods=['GET', 'POST'])

SELECT *
FROM flight
WHERE airline_name = "Jet Blue" and status = "upcoming" and departure_time <=  date_add(now(),INTERVAL 30 DAY);


--2)Specify Range of Dates, Destination and Departure
@app.route('/StaffViewMyFlights_search', methods = ['GET', 'POST'])

SELECT flight.airline_name, flight.flight_num, flight.departure_airport, flight.departure_time, flight.arrival_airport, flight.arrival_time, flight.price, flight.status, flight.airplane_id
FROM flight, airport
WHERE flight.airline_name = "China Eastern" AND flight.departure_airport = airport.airport_name AND (flight.departure_airport = "PVG" OR airport.airport_city = "PVG")  AND flight.departure_time >= "2021-05-01"
AND flight.arrival_time <='2021-06-01'
AND (flight.airline_name, flight.flight_num, flight.departure_airport, flight.departure_time, flight.arrival_airport, flight.arrival_time, flight.price, flight.status, flight.airplane_id) IN
(select flight.airline_name, flight.flight_num, flight.departure_airport, flight.departure_time, flight.arrival_airport, flight.arrival_time, flight.price, flight.status, flight.airplane_id
FROM flight, airport
WHERE flight.airline_name = "China Eastern" AND flight.arrival_airport = airport.airport_name  AND (flight.arrival_airport = "JFK" OR airport.airport_city = "JFK") AND flight.departure_time >= "2021-05-01"
AND flight.arrival_time <='2021-06-01');


--3)View Customers of a Particular Flights
@app.route('/StaffViewMyFlights_flightNumber', methods =['GET', 'POST'])

SELECT purchases.customer_email, customer.name
FROM flight, ticket, purchases, customer
WHERE flight.flight_num = ticket.flight_num and flight.airline_name = "China Eastern" and flight.airline_name = ticket.airline_name 
	and purchases.ticket_id = ticket.ticket_id and flight.flight_num = 12100 and customer.email = purchases.customer_email;

--2.Create New Flights
@app.route('/StaffCreateNewFlights', methods=['GET', 'POST'])

INSERT INTO flight VALUES('28210310', 'American', '2021-03-10 18:30:00', '2021-03-11 11:00:00', '4000.00', 'delayed', '6364', 'PVG', 'JFK');

--3.Change Flights Status
@app.route('/StaffChangeStatusofFlights', methods=['GET', 'POST'])

UPDATE flight
SET status = "delayed"
WHERE flight_num = 12100 and airline_name = "China Eastern";

--4.Add Airline in the System
@app.route('/StaffAddAirplane', methods = ['GET','POST'])

INSERT INTO airplane VALUES ("China Eastern", 12345, 200);

--5.Add New Airport in the System
@app.route('/StaffAddNewAirport', methods=['GET', 'POST'])

INSERT INTO airport VALUES ("PEK","Beijing");

--6.View All the Booking Agents
@app.route('/StaffViewBookingAgent', methods = ['GET','POST'])

--1)By Number of Tickets

SELECT booking_agent.email, purchases.booking_agent_id, count(purchases.ticket_id) AS count
FROM purchases, ticket, booking_agent
WHERE ticket.airline_name  = "China Eastern" AND booking_agent.booking_agent_id = purchases.booking_agent_id AND purchases.ticket_id = ticket.ticket_id and purchases.purchase_date >= date_sub(now(),INTERVAL 1 MONTH) and purchases.booking_agent_id is not null
GROUP BY booking_agent.email
ORDER BY count DESC
limit 5; 

--2)By Amount of Commissions

select booking_agent.email, purchases.booking_agent_id, sum(flight.price * 0.1) as commission
FROM purchases, ticket, flight, booking_agent
WHERE booking_agent.booking_agent_id = purchases.booking_agent_id AND flight.airline_name  = "Jet Blue" AND ticket.airline_name = flight.airline_name AND ticket.flight_num = flight.flight_num  AND purchases.ticket_id = ticket.ticket_id and purchases.purchase_date >= date_sub(now(),INTERVAL 12 MONTH) and purchases.booking_agent_id is not null 
GROUP BY booking_agent.email
ORDER BY commission DESC
limit 5;

--7.View Frequent Customers
@app.route('/StaffViewFrequentCustomers', methods = ['GET','POST'])

--1)Most Frequent Customer in Last Year

SELECT customer.email, customer.name, count(purchases.ticket_id) as count
FROM purchases, ticket, customer
WHERE ticket.airline_name = "China Eastern" AND purchases.ticket_id = ticket.ticket_id and customer.email = purchases.customer_email and purchases.purchase_date >= date_sub(now(),INTERVAL 12 MONTH)
GROUP BY customer.email
ORDER BY count DESC
limit 1;

--2)List of Flights the Customer Has Taken on That Flight

SELECT flight.flight_num, flight.departure_airport, flight.departure_time, flight.arrival_airport, flight.arrival_time, flight.price, flight.status, flight.airplane_id
FROM purchases, ticket, flight
WHERE purchases.ticket_id = ticket.ticket_id AND flight.flight_num = ticket.flight_num AND flight.airline_name = ticket.airline_name AND flight.airline_name = "China Eastern" AND purchases.customer_email = "cw2982@nyu.edu";

--8.View Reports
@app.route('/StaffReports', methods = ['GET','POST'])

SELECT count(purchases.ticket_id),YEAR(purchase_date),MONTH(purchase_date)
FROM purchases, flight, ticket
WHERE purchases.ticket_id = ticket.ticket_id AND ticket.airline_name = flight.airline_name and ticket.flight_num = flight.flight_num and flight.airline_name = "China Eastern" and purchase_date >= "2021-01-01" and purchase_date <= "2022-01-01"
GROUP BY YEAR(purchase_date),MONTH(purchase_date);


--9.Comparison of Avenue Earned
@app.route('/StaffComparisonOfRevenueEarned', methods = ['GET','POST'])

--1)Indirect Sales

SELECT sum(flight.price)
FROM purchases, ticket, flight
WHERE flight.airline_name  = "China Eastern" AND ticket.airline_name = flight.airline_name AND ticket.flight_num = flight.flight_num  AND 
purchases.ticket_id = ticket.ticket_id and purchases.purchase_date >= date_sub(now(),INTERVAL 12 MONTH) AND purchases.booking_agent_id is not null ;

--2)Direct Sales

SELECT sum(flight.price)
FROM purchases, ticket, flight
WHERE flight.airline_name  = "China Eastern" AND ticket.airline_name = flight.airline_name AND ticket.flight_num = flight.flight_num  AND 
purchases.ticket_id = ticket.ticket_id and purchases.purchase_date >= date_sub(now(),INTERVAL 12 MONTH) AND purchases.booking_agent_id is null ;

--10.View Top Destinations
@app.route('/StaffViewTopDestinations', methods = ['GET','POST'])

SELECT airport.airport_city, count(ticket.ticket_id) as count 
FROM purchases, ticket, flight, airport
WHERE flight.airline_name  = "China Eastern" AND ticket.airline_name = flight.airline_name AND ticket.flight_num = flight.flight_num AND flight.arrival_airport = airport.airport_name AND 
purchases.ticket_id = ticket.ticket_id AND purchase_date >= date_sub(now(),INTERVAL 12 MONTH)
GROUP BY airport.airport_city
ORDER BY count DESC
limit 5;

