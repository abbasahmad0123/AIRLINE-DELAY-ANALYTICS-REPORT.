-- =========================================================
-- AIRLINE RELATIONAL DATABASE SCHEMA & COPY SCRIPTS
-- Compatible with PostgreSQL
-- =========================================================

DROP TABLE IF EXISTS delay_reasons CASCADE;
DROP TABLE IF EXISTS weather CASCADE;
DROP TABLE IF EXISTS bookings CASCADE;
DROP TABLE IF EXISTS passengers CASCADE;
DROP TABLE IF EXISTS flights CASCADE;
DROP TABLE IF EXISTS routes CASCADE;
DROP TABLE IF EXISTS aircraft CASCADE;
DROP TABLE IF EXISTS airlines CASCADE;
DROP TABLE IF EXISTS airports CASCADE;
DROP TABLE IF EXISTS cities CASCADE;
DROP TABLE IF EXISTS countries CASCADE;
DROP TABLE IF EXISTS flight_status CASCADE;

CREATE TABLE countries (
    country_id INT PRIMARY KEY,
    country_name VARCHAR(100) NOT NULL,
    iso_code VARCHAR(10) NOT NULL,
    continent VARCHAR(50) NOT NULL
);

CREATE TABLE cities (
    city_id INT PRIMARY KEY,
    city_name VARCHAR(100) NOT NULL,
    country_id INT REFERENCES countries(country_id) ON DELETE CASCADE
);

CREATE TABLE airports (
    airport_id INT PRIMARY KEY,
    airport_name VARCHAR(150) NOT NULL,
    iata_code VARCHAR(10) NOT NULL,
    icao_code VARCHAR(10) NOT NULL,
    city_id INT REFERENCES cities(city_id) ON DELETE CASCADE
);

CREATE TABLE airlines (
    airline_id INT PRIMARY KEY,
    airline_name VARCHAR(100) NOT NULL,
    iata_code VARCHAR(10) NOT NULL,
    icao_code VARCHAR(10) NOT NULL,
    country_id INT REFERENCES countries(country_id) ON DELETE CASCADE
);

CREATE TABLE aircraft (
    aircraft_id INT PRIMARY KEY,
    model VARCHAR(100) NOT NULL,
    manufacturer VARCHAR(50) NOT NULL,
    capacity INT NOT NULL,
    tail_number VARCHAR(20) NOT NULL,
    airline_id INT REFERENCES airlines(airline_id) ON DELETE CASCADE
);

CREATE TABLE routes (
    route_id INT PRIMARY KEY,
    departure_airport_id INT REFERENCES airports(airport_id),
    arrival_airport_id INT REFERENCES airports(airport_id),
    distance_km INT NOT NULL,
    estimated_duration_min INT NOT NULL
);

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

CREATE TABLE passengers (
    passenger_id INT PRIMARY KEY,
    passenger_name VARCHAR(100) NOT NULL,
    gender VARCHAR(20),
    age INT,
    nationality VARCHAR(50),
    email VARCHAR(100),
    passport_number VARCHAR(50)
);

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

CREATE TABLE weather (
    weather_id INT PRIMARY KEY,
    flight_id INT REFERENCES flights(flight_id),
    weather_condition VARCHAR(30) NOT NULL,
    temperature_c NUMERIC(4,1),
    wind_speed_kmh NUMERIC(5,1),
    visibility_km NUMERIC(4,1)
);

CREATE TABLE delay_reasons (
    delay_id INT PRIMARY KEY,
    flight_id INT REFERENCES flights(flight_id),
    delay_reason VARCHAR(50) NOT NULL,
    delay_minutes INT DEFAULT 0
);

CREATE TABLE flight_status (
    status_id INT PRIMARY KEY,
    status_name VARCHAR(20) NOT NULL,
    description TEXT
);

-- =========================================================
-- INDEXES FOR PERFORMANCE OPTIMIZATION
-- =========================================================
CREATE INDEX idx_flights_airline ON flights(airline_id);
CREATE INDEX idx_flights_status ON flights(flight_status);
CREATE INDEX idx_flights_sched_dep ON flights(scheduled_departure);
CREATE INDEX idx_bookings_flight ON bookings(flight_id);
CREATE INDEX idx_bookings_passenger ON bookings(passenger_id);
CREATE INDEX idx_delay_flight ON delay_reasons(flight_id);
CREATE INDEX idx_weather_flight ON weather(flight_id);

-- =========================================================
-- COPY COMMANDS FOR CSV IMPORT
-- =========================================================
\copy countries FROM 'countries.csv' WITH (FORMAT csv, HEADER true);
\copy cities FROM 'cities.csv' WITH (FORMAT csv, HEADER true);
\copy airports FROM 'airports.csv' WITH (FORMAT csv, HEADER true);
\copy airlines FROM 'airlines.csv' WITH (FORMAT csv, HEADER true);
\copy aircraft FROM 'aircraft.csv' WITH (FORMAT csv, HEADER true);
\copy routes FROM 'routes.csv' WITH (FORMAT csv, HEADER true);
\copy flights FROM 'flights.csv' WITH (FORMAT csv, HEADER true);
\copy passengers FROM 'passengers.csv' WITH (FORMAT csv, HEADER true);
\copy bookings FROM 'bookings.csv' WITH (FORMAT csv, HEADER true);
\copy weather FROM 'weather.csv' WITH (FORMAT csv, HEADER true);
\copy delay_reasons FROM 'delay_reasons.csv' WITH (FORMAT csv, HEADER true);
\copy flight_status FROM 'flight_status.csv' WITH (FORMAT csv, HEADER true);
