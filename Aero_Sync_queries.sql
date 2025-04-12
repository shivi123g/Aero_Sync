
CREATE DATABASE IF NOT EXISTS AeroSync;
SELECT AeroSync;

CREATE TABLE IF NOT EXISTS User (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(20) NOT NULL,
    email VARCHAR(20) UNIQUE NOT NULL,
    password_hash VARCHAR(20) NOT NULL,
    role ENUM('ATC','Crew','Employee','Passenger') NOT NULL
);

CREATE TABLE IF NOT EXISTS Passenger(
    passenger_id INT PRIMARY KEY,
    passport_id VARCHAR(20) UNIQUE,
    frequent_flyer_num VARCHAR(20) UNIQUE,
    FOREIGN KEY (passenger_id) REFERENCES User(user_id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS Crew(
    crew_id INT PRIMARY KEY,
    position ENUM('Pilot','Co-Pilot','Cabin Crew') NOT NULL,
    FOREIGN KEY (crew_id) REFERENCES User(user_id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS ATC (
    admin_id INT PRIMARY KEY,
    FOREIGN KEY (admin_id) REFERENCES User(user_id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS Airline (
    airline_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(10) NOT NULL UNIQUE,
    code VARCHAR(10) UNIQUE NOT NULL
);

CREATE TABLE IF NOT EXISTS Airport (
    airport_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(40) NOT NULL,
    code VARCHAR(10) UNIQUE NOT NULL,
    city VARCHAR(20) NOT NULL,
    country VARCHAR(20) NOT NULL
);
CREATE TABLE IF NOT EXISTS Aircraft (
    aircraft_id INT PRIMARY KEY AUTO_INCREMENT,
    model VARCHAR(10) NOT NULL,
    capacity INT NOT NULL,
    airline VARCHAR(50) NOT NULL
);

CREATE TABLE IF NOT EXISTS Flight (
    flight_id INT PRIMARY KEY AUTO_INCREMENT,
    airline_id INT NOT NULL,
    flight_number VARCHAR(20) UNIQUE NOT NULL,
    departure_airport_id INT NOT NULL,
    arrival_airport_id INT NOT NULL,
    departure_time DATETIME NOT NULL,
    arrival_time DATETIME NOT NULL,
    aircraft_id INT NOT NULL,
    status ENUM('Scheduled', 'On-Time','Arrived','Delayed', 'Completed', 'Cancelled') DEFAULT 'Scheduled',
    FOREIGN KEY (airline_id) REFERENCES Airline(airline_id) ON DELETE CASCADE,
    FOREIGN KEY (departure_airport_id) REFERENCES Airport(airport_id) ON DELETE CASCADE,
    FOREIGN KEY (arrival_airport_id) REFERENCES Airport(airport_id) ON DELETE CASCADE,
    FOREIGN KEY (aircraft_id) REFERENCES Aircraft(aircraft_id) ON DELETE CASCADE
);



CREATE TABLE IF NOT EXISTS Booking (
    booking_id INT PRIMARY KEY AUTO_INCREMENT,
    passenger_id INT NOT NULL,
    flight_id INT NOT NULL,
    seat_number varchar(5) NOT NULL,
    booking_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    status ENUM('Confirmed', 'Cancelled', 'Pending') DEFAULT 'Confirmed',
    FOREIGN KEY (passenger_id) REFERENCES Passenger(passenger_id) ON DELETE CASCADE,
    FOREIGN KEY (flight_id) REFERENCES Flight(flight_id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS Seat (
    seat_id INT PRIMARY KEY AUTO_INCREMENT,
    booking_id INT NOT NULL UNIQUE,
    seat_number VARCHAR(10) NOT NULL,
    class ENUM('Economy', 'Business', 'First Class') NOT NULL,
    FOREIGN KEY (booking_id) REFERENCES Booking(booking_id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS assigned_to (
    crew_assignment_id INT PRIMARY KEY AUTO_INCREMENT,
    flight_id INT NOT NULL,
    crew_id INT NOT NULL,
    role ENUM('Pilot', 'Co-Pilot', 'Cabin Crew') NOT NULL,
    FOREIGN KEY (flight_id) REFERENCES Flight(flight_id) ON DELETE CASCADE,
    FOREIGN KEY (crew_id) REFERENCES Crew(crew_id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS Manages(
    admin_id INT NOT NULL,
    managed_entity ENUM('Users', 'Flights', 'Bookings') NOT NULL,
    PRIMARY KEY (admin_id, managed_entity),
    FOREIGN KEY (admin_id) REFERENCES ATC(admin_id) ON DELETE CASCADE
);
CREATE TABLE IF NOT EXISTS Employees (
    employee_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT UNIQUE NOT NULL,
    position VARCHAR(100),
    salary DECIMAL(10,2),
    hire_date DATE,
    department VARCHAR(100),
    FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS Payments (
    payment_id INT PRIMARY KEY AUTO_INCREMENT,
    booking_id INT NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    payment_method ENUM('Credit Card', 'Debit Card', 'Net Banking', 'UPI', 'Wallet') NOT NULL,
    status ENUM('Successful', 'Failed', 'Refunded') DEFAULT 'Successful',
    payment_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (booking_id) REFERENCES Bookings(booking_id) ON DELETE CASCADE
);
DROP TRIGGER IF EXISTS check_passenger_limit;  
DELIMITER $$
CREATE TRIGGER check_passenger_limit
BEFORE INSERT ON Booking
FOR EACH ROW
BEGIN
    DECLARE passenger_count INT;
    DECLARE max_allowed INT;

    -- Get current passenger count for the flight
    SELECT COUNT(*) INTO passenger_count FROM Booking WHERE flight_id = NEW.flight_id;

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
