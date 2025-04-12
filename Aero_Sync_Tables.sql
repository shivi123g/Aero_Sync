
CREATE DATABASE IF NOT EXISTS AeroSync;
USE AeroSync;

CREATE TABLE IF NOT EXISTS Users(
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50) NOT NULL,
    email VARCHAR(50) UNIQUE NOT NULL,
    password_hash VARCHAR(50) NOT NULL,
    age INT NOT NULL,
    gender VARCHAR(10) NOT NULL,
    role ENUM('ATC','Crew','Employee','Passenger') NOT NULL
);

CREATE TABLE IF NOT EXISTS Passengers(
    passenger_id INT PRIMARY KEY,
    passport_id VARCHAR(20) UNIQUE,
    frequent_flyer_miles INT,
    FOREIGN KEY (passenger_id) REFERENCES Users(user_id) ON DELETE CASCADE
);


CREATE TABLE IF NOT EXISTS Crew (
    crew_id INT NOT NULL,
    user_id INT NOT NULL,
    position ENUM('Pilot', 'Co-Pilot', 'Cabin Crew') NOT NULL,
    
    status ENUM('Active', 'On Leave', 'Retired') DEFAULT 'Active',
    FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE
);


CREATE TABLE IF NOT EXISTS ATC (
    admin_id INT PRIMARY KEY,
    FOREIGN KEY (admin_id) REFERENCES Users(user_id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS Airline (
    airline_id VARCHAR(4) PRIMARY KEY, -- 3 digit IATA + ICAO format
    name VARCHAR(30) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS Airport (
    airport_id VARCHAR(4) PRIMARY KEY,
    name VARCHAR(40) NOT NULL,
    city VARCHAR(20) NOT NULL,
    country VARCHAR(20) NOT NULL
);
CREATE TABLE IF NOT EXISTS Aircraft (
    aircraft_id VARCHAR(4) PRIMARY KEY,
    model VARCHAR(10) NOT NULL,
    capacity INT NOT NULL,
    airline_id VARCHAR(3) NOT NULL,
    FOREIGN KEY (airline_id) REFERENCES Airline(airline_id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS Flight (
    flight_id INT PRIMARY KEY AUTO_INCREMENT,

    airline_id VARCHAR(20) NOT NULL,
    aircraft_id VARCHAR(4) NOT NULL,

    flight_number VARCHAR(20) UNIQUE NOT NULL,

    departure_airport_id VARCHAR(4) NOT NULL,
    arrival_airport_id VARCHAR(4) NOT NULL,

    departure_time DATETIME NOT NULL,
    arrival_time DATETIME NOT NULL,
    
    CHECK (arrival_time > departure_time),
    status ENUM('Scheduled', 'On-Time','Arrived','Delayed', 'Completed', 'Cancelled') DEFAULT 'Scheduled',

    FOREIGN KEY (airline_id) REFERENCES Airline(airline_id) ON DELETE CASCADE,    
    FOREIGN KEY (departure_airport_id) REFERENCES Airport(airport_id) ON DELETE CASCADE,
    FOREIGN KEY (arrival_airport_id) REFERENCES Airport(airport_id) ON DELETE CASCADE,
    FOREIGN KEY (aircraft_id) REFERENCES Aircraft(aircraft_id) ON DELETE CASCADE
);


CREATE TABLE IF NOT EXISTS Bookings(
    booking_id INT PRIMARY KEY AUTO_INCREMENT,
    passenger_id INT NOT NULL,
    passenger_name VARCHAR(50) NOT NULL,
    flight_id INT NOT NULL,
    seat_number varchar(5) NOT NULL,
    booking_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    status ENUM('Confirmed', 'Cancelled', 'Pending') DEFAULT 'Confirmed',
    FOREIGN KEY (passenger_id) REFERENCES Passengers(passenger_id) ON DELETE CASCADE,
    FOREIGN KEY (flight_id) REFERENCES Flight(flight_id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS Seat(
    seat_id INT PRIMARY KEY AUTO_INCREMENT,
    booking_id INT NOT NULL UNIQUE,
    seat_number VARCHAR(10) NOT NULL,
    class ENUM('Economy', 'Business', 'First Class') NOT NULL,
    FOREIGN KEY (booking_id) REFERENCES Bookings(booking_id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS assigned_to(
    crew_assignment_id INT PRIMARY KEY AUTO_INCREMENT,
    flight_id INT NOT NULL,
    crew_id INT NOT NULL,
    role ENUM('Pilot', 'Co-Pilot', 'Cabin Crew') NOT NULL,
    assigned_date DATE NOT NULL,
    FOREIGN KEY (flight_id) REFERENCES Flight(flight_id) ON DELETE CASCADE,
    FOREIGN KEY (crew_id) REFERENCES Crew(crew_id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS Manages(
    admin_id INT NOT NULL,
    managed_entity ENUM('Users', 'Flights', 'Bookings') NOT NULL,
    PRIMARY KEY (admin_id, managed_entity),
    FOREIGN KEY (admin_id) REFERENCES ATC(admin_id) ON DELETE CASCADE
);
CREATE TABLE IF NOT EXISTS Employees(
    employee_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT UNIQUE NOT NULL,
    position VARCHAR(100),
    salary DECIMAL(10,2),
    hire_date DATE,
    experience_years INT CHECK (experience_years >= 0),
    department VARCHAR(100),
    FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS Payments(
    payment_id INT PRIMARY KEY AUTO_INCREMENT,
    booking_id INT NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    payment_method ENUM('Credit Card', 'Debit Card', 'Net Banking', 'UPI', 'Wallet') NOT NULL,
    status ENUM('Successful', 'Failed', 'Refunded') DEFAULT 'Successful',
    payment_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (booking_id) REFERENCES Bookings(booking_id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS Reviews(
    review_id INT PRIMARY KEY AUTO_INCREMENT,
    booking_id INT NOT NULL,
    rating INT NOT NULL,
    comment TEXT,
    review_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (booking_id) REFERENCES Bookings(booking_id) ON DELETE CASCADE
);


CREATE TABLE Booking_Audit (
    audit_id INT PRIMARY KEY AUTO_INCREMENT,
    booking_id INT,
    action ENUM('INSERT','UPDATE','DELETE'),
    old_status ENUM('Confirmed', 'Cancelled', 'Pending'),
    new_status ENUM('Confirmed', 'Cancelled', 'Pending'),
    changed_by VARCHAR(50),
    change_time DATETIME DEFAULT CURRENT_TIMESTAMP
);


DROP TRIGGER IF EXISTS check_passenger_limit;  
DELIMITER $$
CREATE TRIGGER check_passenger_limit
BEFORE INSERT ON Bookings
FOR EACH ROW
BEGIN
    DECLARE passenger_count INT;
    DECLARE max_allowed INT;

    -- Get current passenger count for the flight
    SELECT COUNT(*) INTO passenger_count FROM Bookings WHERE flight_id = NEW.flight_id;

    -- Get aircraft capacity for this flight
    SELECT a.capacity INTO max_allowed 
    FROM Flight f
    JOIN Aircraft a ON f.aircraft_id = a.aircraft_id
    WHERE f.flight_id = NEW.flight_id;

    -- Check if capacity exceeded
    IF passenger_count >= max_allowed THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: Maximum passenger limit reached for this flight.';
    END IF;
END $$

DELIMITER ;

CREATE INDEX idx_flight_number ON Flight(flight_number);
CREATE INDEX idx_user_email ON Users(email);

-- CREATE MATERIALIZED VIEW Daily_Flight_Schedule AS
-- SELECT 
--     f.flight_number, 
--     f.departure_airport_id, 
--     f.arrival_airport_id, 
--     DATE(f.departure_time) AS flight_date, 
--     f.status
-- FROM Flight f
-- ORDER BY flight_date, departure_time;

-- CREATE MATERIALIZED VIEW Airline_Revenue AS
-- SELECT 
--     f.airline_id, 
--     a.name AS airline_name,
--     SUM(p.amount) AS total_revenue
-- FROM Flight f
-- JOIN Airline a ON f.airline_id = a.airline_id
-- JOIN Bookings b ON f.flight_id = b.flight_id
-- JOIN Payments p ON b.booking_id = p.booking_id
-- GROUP BY f.airline_id, a.name;

-- CREATE MATERIALIZED VIEW Flight_Occupancy AS
-- SELECT 
--     f.flight_id, 
--     f.flight_number, 
--     COUNT(b.booking_id) AS total_booked_seats,
--     a.capacity,
--     ROUND((COUNT(b.booking_id) * 100.0 / a.capacity), 2) AS occupancy_rate
-- FROM Flight f
-- JOIN Aircraft a ON f.aircraft_id = a.aircraft_id
-- LEFT JOIN Bookings b ON f.flight_id = b.flight_id
-- GROUP BY f.flight_id, f.flight_number, a.capacity;
