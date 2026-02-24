DROP DATABASE IF EXISTS seads;
CREATE DATABASE seads;
USE seads;

-- ================= EMPLOYEES =================
CREATE TABLE employees (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100),
  email VARCHAR(100) UNIQUE,
  password VARCHAR(255),
  role ENUM('EMPLOYEE','ADMIN'),
  salary_per_day DECIMAL(10,2) DEFAULT 0
);

-- ================= ATTENDANCE =================
CREATE TABLE attendance (
  id INT AUTO_INCREMENT PRIMARY KEY,
  employee_id INT,
  date DATE,
  status ENUM('PRESENT','ABSENT','LEAVE'),
  FOREIGN KEY (employee_id) REFERENCES employees(id) ON DELETE CASCADE
);

-- ================= PAYROLL =================
CREATE TABLE payroll (
  id INT AUTO_INCREMENT PRIMARY KEY,
  employee_id INT,
  month VARCHAR(20),
  basic_salary DECIMAL(10,2) DEFAULT 0,
  tax_withheld DECIMAL(10,2) DEFAULT 0,
  net_pay DECIMAL(10,2) DEFAULT 0,
  status ENUM('Pending','Completed') DEFAULT 'Pending',
  FOREIGN KEY (employee_id) REFERENCES employees(id) ON DELETE CASCADE
);

-- ================= SUPPORT REQUESTS =================
CREATE TABLE support_requests (
  id INT AUTO_INCREMENT PRIMARY KEY,
  employee_id INT,
  request_type VARCHAR(50),
  message TEXT,
  status ENUM('PENDING','APPROVED','REJECTED') DEFAULT 'PENDING'
);

-- ================= SAMPLE DATA =================
INSERT INTO employees (name,email,password,role,salary_per_day) VALUES
('John Doe','john@test.com','1234','EMPLOYEE',500),
('Admin','admin@test.com','1234','ADMIN',1000);
