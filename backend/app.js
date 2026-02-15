function showDashboard() {
  document.getElementById("content").innerHTML = `
    <h1>Dashboard</h1>
    <button onclick="checkIn()">Employee Check-In</button>
  `;
}

function checkIn() {
  fetch("http://localhost:3000/attendance/checkin", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ employee_id: 1 })
  })
  .then(r => r.text())
  .then(alert);
}

function showLeave() {
  document.getElementById("content").innerHTML = `
    <h1>Leave Request</h1>
    <input id="date" type="date"><br><br>
    <input id="reason" placeholder="Reason"><br><br>
    <button onclick="submitLeave()">Submit</button>
  `;
}

function submitLeave() {
  fetch("http://localhost:3000/leave/request", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      employee_id: 1,
      date: date.value,
      reason: reason.value
    })
  }).then(() => alert("Leave Sent"));
}

function showPayroll() {
  fetch("http://localhost:3000/payroll")
    .then(r => r.json())
    .then(data => {
      document.getElementById("content").innerHTML =
        "<h1>Payroll</h1>" +
        data.map(e => `${e.name}: ₱${e.salary}`).join("<br>");
    });
}

showDashboard();
