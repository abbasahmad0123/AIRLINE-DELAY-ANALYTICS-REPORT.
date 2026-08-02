--1-countries table
CREATE TABLE countries (
    country_id INT PRIMARY KEY,
    country_name VARCHAR(100) NOT NULL,
    iso_code VARCHAR(10) NOT NULL,
    continent VARCHAR(50) NOT NULL
);

COPY countries
FROM 'E:\Airline Delay Analysis\countries.csv'
DELIMITER ','
CSV HEADER;
select * from countries;
--2-cities table
CREATE TABLE cities (
    city_id INT PRIMARY KEY,
    city_name VARCHAR(100) NOT NULL,
    country_id INT REFERENCES countries(country_id) ON DELETE CASCADE
);
COPY cities
FROM 'E:\Airline Delay Analysis\cities.csv'
DELIMITER ','
CSV HEADER;
select * from cities;
--3-airports table
CREATE TABLE airports (
    airport_id INT PRIMARY KEY,
    airport_name VARCHAR(150) NOT NULL,
    iata_code VARCHAR(10) NOT NULL,
    icao_code VARCHAR(10) NOT NULL,
    city_id INT REFERENCES cities(city_id) ON DELETE CASCADE
);
COPY airports
FROM 'E:\Airline Delay Analysis\airports.csv'
DELIMITER ','
CSV HEADER;
select * from airports;
--3-airlines table
CREATE TABLE airlines (
    airline_id INT PRIMARY KEY,
    airline_name VARCHAR(100) NOT NULL,
    iata_code VARCHAR(10) NOT NULL,
    icao_code VARCHAR(10) NOT NULL,
    country_id INT REFERENCES countries(country_id) ON DELETE CASCADE
);
COPY airlines
FROM 'E:\Airline Delay Analysis\airlines.csv'
DELIMITER ','
CSV HEADER;
select * from airlines;
--4-aircraft table
CREATE TABLE aircraft (
    aircraft_id INT PRIMARY KEY,
    model VARCHAR(100) NOT NULL,
    manufacturer VARCHAR(50) NOT NULL,
    capacity INT NOT NULL,
    tail_number VARCHAR(20) NOT NULL,
    airline_id INT REFERENCES airlines(airline_id) ON DELETE CASCADE
);

COPY aircraft 
FROM 'E:\Airline Delay Analysis\aircraft.csv' 
DELIMITER ',' 
CSV HEADER;
select * from aircraft;
--5-routes table
CREATE TABLE routes (
    route_id INT PRIMARY KEY,
    departure_airport_id INT REFERENCES airports(airport_id),
    arrival_airport_id INT REFERENCES airports(airport_id),
    distance_km INT NOT NULL,
    estimated_duration_min INT NOT NULL
);
COPY routes 
FROM 'E:\Airline Delay Analysis\routes.csv' 
DELIMITER ',' 
CSV HEADER;
select * from routes;
--6-flights table
CREATE TABLE flights (
    flight_id INT PRIMARY KEY,
    flight_number VARCHAR(20) NOT NULL,
    airline_id INT REFERENCES airlines(airline_id),
    aircraft_id INT REFERENCES aircraft(aircraft_id),
    route_id INT REFERENCES routes(route_id),
    scheduled_departure TIMESTAMP NOT NULL,
    actual_departure TIMESTAMP,
    scheduled_arrival TIMESTAMP NOT NULL,
    actual_arrival TIMESTAMP,
    flight_status VARCHAR(20) NOT NULL,
    departure_delay_min INT DEFAULT 0,
    arrival_delay_min INT DEFAULT 0
);
COPY flights 
FROM 'E:\Airline Delay Analysis\flights.csv' 
DELIMITER ',' 
CSV HEADER;
select * from flights;
--7-passengers table
CREATE TABLE passengers (
    passenger_id INT PRIMARY KEY,
    passenger_name VARCHAR(100) NOT NULL,
    gender VARCHAR(20),
    age INT,
    nationality VARCHAR(50),
    email VARCHAR(100),
    passport_number VARCHAR(50)
);
COPY passengers 
FROM 'E:\Airline Delay Analysis\passengers.csv' 
DELIMITER ',' 
CSV HEADER;
select * from passengers;
--8-bookings table
CREATE TABLE bookings (
    booking_id INT PRIMARY KEY,
    flight_id INT REFERENCES flights(flight_id),
    passenger_id INT REFERENCES passengers(passenger_id),
    booking_date DATE NOT NULL,
    ticket_price NUMERIC(10, 2) NOT NULL,
    booking_class VARCHAR(30) NOT NULL,
    payment_method VARCHAR(30),
    seat_number VARCHAR(10)
);
COPY bookings 
FROM 'E:\Airline Delay Analysis\bookings.csv' 
DELIMITER ',' 
CSV HEADER;
select * from bookings;
--9-weather table
CREATE TABLE weather (
    weather_id INT PRIMARY KEY,
    flight_id INT REFERENCES flights(flight_id),
    weather_condition VARCHAR(30) NOT NULL,
    temperature_c NUMERIC(4,1),
    wind_speed_kmh NUMERIC(5,1),
    visibility_km NUMERIC(4,1)
);
COPY weather 
FROM 'E:\Airline Delay Analysis\weather.csv' 
DELIMITER ',' 
CSV HEADER;
select * from weather;
--10-delay_reasons table
CREATE TABLE delay_reasons (
    delay_id INT PRIMARY KEY,
    flight_id INT REFERENCES flights(flight_id),
    delay_reason VARCHAR(50) NOT NULL,
    delay_minutes INT DEFAULT 0
);
COPY delay_reasons 
FROM 'E:\Airline Delay Analysis\delay_reasons.csv' 
DELIMITER ',' 
CSV HEADER;
select * from delay_reasons;
--11-flight_status table
CREATE TABLE flight_status (
    status_id INT PRIMARY KEY,
    status_name VARCHAR(20) NOT NULL,
    description TEXT
);
COPY flight_status 
FROM 'E:\Airline Delay Analysis\flight_status.csv' 
DELIMITER ',' 
CSV HEADER;
select * from flight_status;

-- Query 1: Total Flights by Airline
SELECT a.airline_name, COUNT(f.flight_id) AS total_flights
FROM flights f
JOIN airlines a ON f.airline_id = a.airline_id
GROUP BY a.airline_name
ORDER BY total_flights DESC;

-- Query 2: Top 10 Delayed Airlines
SELECT a.airline_name, COUNT(f.flight_id) AS delayed_flights, AVG(f.departure_delay_min) AS avg_delay
FROM flights f
JOIN airlines a ON f.airline_id = a.airline_id
WHERE f.flight_status = 'Delayed'
GROUP BY a.airline_name
ORDER BY delayed_flights DESC
LIMIT 10;

-- Query 3: Delay Impact by Weather Condition
SELECT w.weather_condition, COUNT(f.flight_id) as flight_count, AVG(f.departure_delay_min) as avg_delay
FROM flights f
JOIN weather w ON f.flight_id = w.flight_id
GROUP BY w.weather_condition
ORDER BY avg_delay DESC;

-- Query 4: Total Revenue by Cabin Class
SELECT booking_class, SUM(ticket_price) AS total_revenue
FROM bookings
GROUP BY booking_class
ORDER BY total_revenue DESC;

-- Query 5: Monthly Flight Trend Analysis
SELECT DATE_TRUNC('month', scheduled_departure) AS flight_month, COUNT(*) AS total_flights
FROM flights
GROUP BY flight_month
ORDER BY flight_month;