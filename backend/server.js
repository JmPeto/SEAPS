const express = require("express");
const bodyParser = require("body-parser");
const mysql = require("mysql2");
const cors = require("cors");

const app = express();
app.use(cors());
app.use(bodyParser.json());

// ================= DB CONNECTION =================
const db = mysql.createConnection({
  host: "localhost",
  user: "root",
  password: "",
  database: "seads",
});

db.connect((err) => {
  if (err) {
    console.error("DB connection error:", err);
    return;
  }
  console.log("Connected to MySQL database");
});

// ================= LOGIN =================
app.post("/login", (req, res) => {
  const { email, password } = req.body;
  const sql = "SELECT * FROM employees WHERE email = ? AND password = ?";
  db.query(sql, [email, password], (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    if (results.length === 0)
      return res.status(401).json({ success: false });
    res.json({ success: true, user: results[0] });
  });
});

// ================= EMPLOYEES =================
app.get("/employees/all", (req, res) => {
  db.query("SELECT * FROM employees", (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json(results);
  });
});

app.get("/employees/count", (req, res) => {
  db.query("SELECT COUNT(*) as count FROM employees", (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json(results[0]);
  });
});

app.post("/employees/add", (req, res) => {
  const { name, email, role, salary_per_day } = req.body;
  const sql =
    "INSERT INTO employees (name,email,role,salary_per_day) VALUES (?,?,?,?)";
  db.query(sql, [name, email, role, salary_per_day], (err, result) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json({ inserted: result.insertId });
  });
});

app.post("/employees/update", (req, res) => {
  const { id, name, email, role, salary_per_day } = req.body;
  const sql =
    "UPDATE employees SET name=?, email=?, role=?, salary_per_day=? WHERE id=?";
  db.query(sql, [name, email, role, salary_per_day, id], (err, result) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json({ updated: result.affectedRows });
  });
});

app.post("/employees/remove", (req, res) => {
  const { id } = req.body;
  db.query("DELETE FROM employees WHERE id=?", [id], (err, result) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json({ deleted: result.affectedRows });
  });
});

// ================= ATTENDANCE =================
app.post("/attendance/checkin", (req, res) => {
  const { employee_id } = req.body;
  const date = new Date().toISOString().split("T")[0];
  const sql =
    "INSERT INTO attendance (employee_id,date,status) VALUES (?,?,'PRESENT')";
  db.query(sql, [employee_id, date], (err, result) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json({ inserted: result.affectedRows });
  });
});

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

app.get("/attendance/present_count", (req, res) => {
  db.query(
    "SELECT COUNT(*) as count FROM attendance WHERE status='PRESENT'",
    (err, results) => {
      if (err) return res.status(500).json({ error: err.message });
      res.json(results[0]);
    }
  );
});

app.get("/attendance/absent_count", (req, res) => {
  db.query(
    "SELECT COUNT(*) as count FROM attendance WHERE status='ABSENT'",
    (err, results) => {
      if (err) return res.status(500).json({ error: err.message });
      res.json(results[0]);
    }
  );
});

// ================= PAYROLL =================
app.get("/payroll", (req, res) => {
  const month = req.query.month;
  let sql = `
    SELECT p.*, e.name
    FROM payroll p
    JOIN employees e ON p.employee_id = e.id
  `;
  if (month) {
    sql += " WHERE p.month = ?";
    db.query(sql, [month], (err, results) => {
      if (err) return res.status(500).json({ error: err.message });
      res.json(results);
    });
  } else {
    db.query(sql, (err, results) => {
      if (err) return res.status(500).json({ error: err.message });
      res.json(results);
    });
  }
});

app.post("/payroll/generate", (req, res) => {
  const { month } = req.body;

  db.query("SELECT id,salary_per_day FROM employees", (err, employees) => {
    if (err) return res.status(500).json({ error: err.message });

    const values = employees.map((emp) => [
      emp.id,
      month,
      emp.salary_per_day,
      0,
      emp.salary_per_day,
      "Pending",
    ]);

    db.query(
      "INSERT INTO payroll (employee_id,month,basic_salary,tax_withheld,net_pay,status) VALUES ?",
      [values],
      (err, result) => {
        if (err) return res.status(500).json({ error: err.message });
        res.json({ inserted: result.affectedRows });
      }
    );
  });
});

app.put("/payroll/update/:id", (req, res) => {
  const { id } = req.params;
  const { status } = req.body;

  db.query(
    "UPDATE payroll SET status=? WHERE id=?",
    [status, id],
    (err, result) => {
      if (err) return res.status(500).json({ error: err.message });
      res.json({ updated: result.affectedRows });
    }
  );
});

// ================= START SERVER =================
app.listen(3000, () => {
  console.log("Server running on http://localhost:3000");
});
