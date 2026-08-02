# Comprehensive Airline Delay & Operations Analytics Dataset

## Executive Overview
This relational database project provides an end-to-end operational and analytical platform for monitoring airline delays, flight status distributions, passenger bookings, and weather impacts. It consists of **12 normalized tables** with **5,000 core flight records**, making it perfectly optimized for SQL practice, Power BI data modeling, and enterprise portfolio showcases.

---

## Data Architecture & Entity Relationship (ER) Diagram

```
[ Countries ] <--- (1:N) --- [ Cities ] <--- (1:N) --- [ Airports ]
     ^                                                      ^
     | (1:N)                                                | (1:N Departure/Arrival)
[ Airlines ] <--- (1:N) --- [ Aircraft ]                    |
     ^                                                      |
     +---------------------- (1:N) -------------------+     |
                                                      |     |
                                                      v     v
[ Passengers ] <--- (1:N) --- [ Bookings ] <--- (1:N) --- [ Flights ] ---> (N:1) ---> [ Routes ]
                                                              |
                                                              +---> (1:1) ---> [ Weather ]
                                                              +---> (1:1) ---> [ Delay Reasons ]
```

### Star Schema Design for Power BI
* **Fact Table:** `Flights` (measures: `departure_delay_min`, `arrival_delay_min`) & `Bookings` (measures: `ticket_price`).
* **Dimension Tables:** `Dim_Airlines`, `Dim_Airports`, `Dim_Passengers`, `Dim_Aircraft`, `Dim_Routes`, `Dim_Weather`, `Dim_Date`.

---

## Data Dictionary

| Table Name | Column Name | Data Type | Key Type | Description |
|---|---|---|---|---|
| **Countries** | country_id | INT | PK | Unique Country Identifier |
| | country_name | VARCHAR(100) | None | Full Name of Country |
| | iso_code | VARCHAR(10) | None | 2-Letter ISO Country Code |
| | continent | VARCHAR(50) | None | Geographic Continent |
| **Cities** | city_id | INT | PK | Unique City Identifier |
| | city_name | VARCHAR(100) | None | City Name |
| | country_id | INT | FK | References Countries(country_id) |
| **Airports** | airport_id | INT | PK | Unique Airport Identifier |
| | airport_name | VARCHAR(150) | None | Official Name |
| | iata_code | VARCHAR(10) | None | 3-Letter IATA Code |
| | icao_code | VARCHAR(10) | None | 4-Letter ICAO Code |
| | city_id | INT | FK | References Cities(city_id) |
| **Airlines** | airline_id | INT | PK | Unique Airline Identifier |
| | airline_name | VARCHAR(100) | None | Carrier Commercial Name |
| | iata_code | VARCHAR(10) | None | 2-Letter IATA Code |
| | icao_code | VARCHAR(10) | None | 3-Letter ICAO Code |
| | country_id | INT | FK | References Countries(country_id) |
| **Aircraft** | aircraft_id | INT | PK | Unique Aircraft Fleet ID |
| | model | VARCHAR(100) | None | Aircraft Model |
| | manufacturer | VARCHAR(50) | None | Manufacturer (Boeing, Airbus) |
| | capacity | INT | None | Total Seating Capacity |
| | tail_number | VARCHAR(20) | None | Registration Tail Number |
| | airline_id | INT | FK | References Airlines(airline_id) |
| **Routes** | route_id | INT | PK | Unique Route Identifier |
| | departure_airport_id | INT | FK | Departure Airport |
| | arrival_airport_id | INT | FK | Arrival Airport |
| | distance_km | INT | None | Flight Distance in Kilometers |
| | estimated_duration_min | INT | None | Scheduled Flight Duration |
| **Flights** | flight_id | INT | PK | Unique Flight Identifier |
| | flight_number | VARCHAR(20) | None | Operational Flight Number |
| | airline_id | INT | FK | Operating Airline |
| | aircraft_id | INT | FK | Assigned Aircraft |
| | route_id | INT | FK | Route Identifier |
| | scheduled_departure | TIMESTAMP | None | Scheduled Departure Timestamp |
| | actual_departure | TIMESTAMP | None | Actual Departure Timestamp |
| | scheduled_arrival | TIMESTAMP | None | Scheduled Arrival Timestamp |
| | actual_arrival | TIMESTAMP | None | Actual Arrival Timestamp |
| | flight_status | VARCHAR(20) | None | Status (On Time, Delayed, etc.) |
| | departure_delay_min | INT | None | Delay in Minutes |
| | arrival_delay_min | INT | None | Arrival Delay in Minutes |
| **Passengers** | passenger_id | INT | PK | Unique Passenger ID |
| | passenger_name | VARCHAR(100) | None | Full Name |
| | gender | VARCHAR(20) | None | Gender |
| | age | INT | None | Age |
| | nationality | VARCHAR(50) | None | Nationality |
| | email | VARCHAR(100) | None | Email Contact |
| | passport_number | VARCHAR(50) | None | Passport Identifier |
| **Bookings** | booking_id | INT | PK | Unique Booking ID |
| | flight_id | INT | FK | References Flights(flight_id) |
| | passenger_id | INT | FK | References Passengers(passenger_id) |
| | booking_date | DATE | None | Date of Booking |
| | ticket_price | NUMERIC(10,2)| None | Ticket Fare |
| | booking_class | VARCHAR(30) | None | Cabin Class |
| | payment_method | VARCHAR(30) | None | Payment Instrument |
| | seat_number | VARCHAR(10) | None | Seat Allocation |
| **Weather** | weather_id | INT | PK | Unique Weather Record ID |
| | flight_id | INT | FK | References Flights(flight_id) |
| | weather_condition | VARCHAR(30) | None | Condition (Clear, Rain, Fog) |
| | temperature_c | NUMERIC(4,1) | None | Temp in Celsius |
| | wind_speed_kmh | NUMERIC(5,1) | None | Wind Speed |
| | visibility_km | NUMERIC(4,1) | None | Visibility Distance |
| **Delay_Reasons**| delay_id | INT | PK | Unique Delay Record ID |
| | flight_id | INT | FK | References Flights(flight_id) |
| | delay_reason | VARCHAR(50) | None | Primary Cause |
| | delay_minutes | INT | None | Duration of Delay |
| **Flight_Status** | status_id | INT | PK | Status ID |
| | status_name | VARCHAR(20) | None | Status Name |
| | description | TEXT | None | Description |

---

## Power BI DAX Measures & Calculated Columns

### Key DAX Measures
```dax
// 1. Total Flights
Total Flights = COUNT(Flights[flight_id])

// 2. Total Delayed Flights
Total Delayed Flights = CALCULATE(COUNT(Flights[flight_id]), Flights[flight_status] = "Delayed")

// 3. Delay Percentage
Delay Percentage = DIVIDE([Total Delayed Flights], [Total Flights], 0) * 100

// 4. Average Departure Delay (Minutes)
Avg Departure Delay = AVERAGE(Flights[departure_delay_min])

// 5. Total Revenue
Total Revenue = SUM(Bookings[ticket_price])

// 6. Average Ticket Price
Avg Ticket Price = AVERAGE(Bookings[ticket_price])

// 7. On-Time Performance Rate (%)
OnTime Rate = DIVIDE(CALCULATE(COUNT(Flights[flight_id]), Flights[flight_status] = "On Time"), [Total Flights], 0) * 100
```

### Key Calculated Columns
```dax
// Flight Distance Category
Distance Category = 
IF(Routes[distance_km] < 1000, "Short Haul",
    IF(Routes[distance_km] <= 4000, "Medium Haul", "Long Haul")
)

// Delay Severity
Delay Severity = 
SWITCH(
    TRUE(),
    Flights[departure_delay_min] <= 0, "On Time / Early",
    Flights[departure_delay_min] <= 30, "Minor Delay (<30 min)",
    Flights[departure_delay_min] <= 90, "Moderate Delay (30-90 min)",
    "Severe Delay (>90 min)"
)
```

---

## 50+ SQL Practice Queries (Sample Excerpt)

```sql
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
```

---

## 30 Power BI Interview Questions (Sample Excerpt)
1. **What is the difference between Star Schema and Snowflake Schema, and which one is applied here?**
   * *Answer:* Star schema has denormalized dimension tables directly linked to a central fact table. In this dataset, connecting `Flights` directly to `Airlines`, `Airports`, and `Date` creates a optimized Star Schema for performance.
2. **How do you handle bidirectional relationships in Power BI data models?**
   * *Answer:* Avoid bidirectional relationships whenever possible due to ambiguity. Use single-direction filters and enforce context propagation through explicit DAX functions like `CROSSFILTER`.
3. **What is the difference between `SUM()` and `SUMX()` in DAX?**
   * *Answer:* `SUM()` is an aggregator that sums a single column. `SUMX()` is an iterator function that evaluates an expression row-by-row before calculating the total sum.

---

## 30 SQL Interview Questions (Sample Excerpt)
1. **What is the difference between `WHERE` and `HAVING` clauses?**
   * *Answer:* `WHERE` filters rows before grouping/aggregation occurs. `HAVING` filters grouped summary rows after `GROUP BY` is applied.
2. **How do you rank airlines by delay frequency using Window Functions?**
   * *Answer:* `SELECT airline_id, COUNT(*), DENSE_RANK() OVER (ORDER BY COUNT(*) DESC) FROM flights WHERE flight_status = 'Delayed' GROUP BY airline_id;`
3. **Explain the impact of indexing foreign keys in PostgreSQL.**
   * *Answer:* Indexing foreign keys improves join operations and speeds up cascade deletions and updates by avoiding full table scans.

---
