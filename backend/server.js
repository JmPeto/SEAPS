const express = require("express");
const bodyParser = require("body-parser");
const mysql = require("mysql2");
const cors = require("cors");

const app = express();
app.use(cors());
app.use(bodyParser.json());

// ===== MySQL Connection =====
const db = mysql.createConnection({
  host: "localhost",
  user: "root",
  password: "",
  database: "payroll_system",
});

db.connect((err) => {
  if (err) {
    console.error("DB connection error:", err);
    return;
  }
  console.log("Connected to MySQL database");
});

// ===== LOGIN =====
app.post("/login", (req, res) => {
  const { email, password } = req.body;
  const sql = "SELECT * FROM employees WHERE email = ? AND password = ?";
  db.query(sql, [email, password], (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    if (results.length === 0) return res.status(401).json({ success: false });
    const user = results[0];
    res.json({ success: true, user, token: "dummy-token" });
  });
});

// ===== EMPLOYEES =====
const validRoles = ["ADMIN", "EMPLOYEE", "HR"];

// Add employee
app.post("/employees/add", (req, res) => {
  let { name, email, role, salary_per_day } = req.body;

  if (!validRoles.includes(role))
    return res.status(400).json({ error: "Invalid role" });

  salary_per_day = parseFloat(salary_per_day) || 0;

  const sql =
    "INSERT INTO employees (name, email, role, salary_per_day) VALUES (?, ?, ?, ?)";
  db.query(sql, [name, email, role, salary_per_day], (err, result) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json({ id: result.insertId });
  });
});

// Update employee
app.post("/employees/update", (req, res) => {
  let { id, name, email, role, salary_per_day } = req.body;

  if (!validRoles.includes(role))
    return res.status(400).json({ error: "Invalid role" });

  salary_per_day = parseFloat(salary_per_day) || 0;

  const sql =
    "UPDATE employees SET name = ?, email = ?, role = ?, salary_per_day = ? WHERE id = ?";
  db.query(sql, [name, email, role, salary_per_day, id], (err, result) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json({ updated: result.affectedRows });
  });
});

// Delete employee
app.post("/employees/remove", (req, res) => {
  const { id } = req.body;
  const sql = "DELETE FROM employees WHERE id = ?";
  db.query(sql, [id], (err, result) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json({ deleted: result.affectedRows });
  });
});

// Fetch all employees
app.get("/employees/all", (req, res) => {
  const sql = "SELECT * FROM employees";
  db.query(sql, (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json(
      results.map((e) => ({
        ...e,
        salary_per_day: e.salary_per_day || 0, // Ensure salary is never null
      }))
    );
  });
});

// Employee count
app.get("/employees/count", (req, res) => {
  const sql = "SELECT COUNT(*) as count FROM employees";
  db.query(sql, (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json(results[0]);
  });
});

// ===== ATTENDANCE =====
app.post("/attendance/checkin", (req, res) => {
  const { employee_id } = req.body;
  const date = new Date().toISOString().split("T")[0];
  const sql =
    "INSERT INTO attendance (employee_id, date, status) VALUES (?, ?, 'Present')";
  db.query(sql, [employee_id, date], (err, result) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json({ inserted: result.affectedRows });
  });
});

// Attendance list
app.get("/attendance", (req, res) => {
  const sql = `
    SELECT a.*, e.name 
    FROM attendance a 
    JOIN employees e ON a.employee_id = e.id
  `;
  db.query(sql, (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json(results);
  });
});

// Present count
app.get("/attendance/present_count", (req, res) => {
  const sql = "SELECT COUNT(*) as count FROM attendance WHERE status = 'Present'";
  db.query(sql, (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json(results[0]);
  });
});

// Absent count
app.get("/attendance/absent_count", (req, res) => {
  const sql = "SELECT COUNT(*) as count FROM attendance WHERE status = 'Absent'";
  db.query(sql, (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json(results[0]);
  });
});

// ===== PAYROLL =====
app.get("/payroll", (req, res) => {
  const month = req.query.month || "";

  const sql = `
    SELECT p.id, p.employee_id, e.name,
           COALESCE(p.basic_salary, e.salary_per_day, 0) AS basic_salary,
           COALESCE(p.tax_withheld, 0) AS tax_withheld,
           COALESCE(p.net_pay, e.salary_per_day, 0) AS net_pay,
           COALESCE(p.status, 'Pending') AS status,
           p.month
    FROM payroll p
    JOIN employees e ON p.employee_id = e.id
    ${month ? "WHERE p.month = ?" : ""}
  `;

  db.query(sql, month ? [month] : [], (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json(results);
  });
});

// Generate payroll
app.post("/payroll/generate", (req, res) => {
  const { month } = req.body;

  db.query("SELECT id, salary_per_day FROM employees", (err, employees) => {
    if (err) return res.status(500).json({ error: err.message });

    if (employees.length === 0)
      return res.json({ success: false, message: "No employees found" });

    // Create payroll records ensuring salary is not null
    const values = employees.map((emp) => [
      emp.id,
      month,
      emp.salary_per_day || 0,
      emp.salary_per_day || 0,
      "Pending",
      0,
    ]);

    const sql = `
      INSERT INTO payroll (employee_id, month, basic_salary, net_pay, status, tax_withheld)
      VALUES ?
    `;

    db.query(sql, [values], (err, result) => {
      if (err) return res.status(500).json({ error: err.message });
      res.json({ success: true, inserted: result.affectedRows });
    });
  });
});

// ================= FETCH REQUEST SUPPORT =================
app.get("/api/requests", (req, res) => {
  const type = req.query.type || "";
  const status = req.query.status || "";

  let sql = "SELECT * FROM support_requests WHERE 1=1";
  const params = [];

  if (type) {
    sql += " AND request_type = ?";
    params.push(type);
  }

  if (status && status !== "All Status") {
    sql += " AND status = ?";
    params.push(status);
  }

  db.query(sql, params, (err, result) => {
    if (err) return res.status(500).json(err);
    res.json(result);
  });
});

// ===== START SERVER =====
app.listen(3000, () => {
  console.log("Server running on http://localhost:3000");
});
