CREATE DATABASE seads;
USE seads;

CREATE TABLE employees (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100),
  email VARCHAR(100),
  role ENUM('EMPLOYEE','HR','ADMIN'),
  salary_per_day DECIMAL(10,2)
);

CREATE TABLE attendance (
  id INT AUTO_INCREMENT PRIMARY KEY,
  employee_id INT,
  date DATE,
  status ENUM('PRESENT','ABSENT','LEAVE')
);

CREATE TABLE leave_requests (
  id INT AUTO_INCREMENT PRIMARY KEY,
  employee_id INT,
  date DATE,
  reason TEXT,
  status ENUM('PENDING','APPROVED','REJECTED')
);

CREATE TABLE correction_requests (
  id INT AUTO_INCREMENT PRIMARY KEY,
  attendance_id INT,
  reason TEXT,
  status ENUM('PENDING','APPROVED','REJECTED')
);

CREATE TABLE profile_requests (
  id INT AUTO_INCREMENT PRIMARY KEY,
  employee_id INT,
  new_email VARCHAR(100),
  status ENUM('PENDING','APPROVED','REJECTED')
);

INSERT INTO employees VALUES
(1,'John Doe','john@test.com','EMPLOYEE',500),
(2,'HR Manager','hr@test.com','HR',800),
(3,'Admin','admin@test.com','ADMIN',1000);

