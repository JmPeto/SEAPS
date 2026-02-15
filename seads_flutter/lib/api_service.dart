import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "http://localhost:3000";

  /* ===== CHECK-IN ===== */
  static Future<bool> checkIn(int employeeId) async {
    final res = await http.post(
      Uri.parse("$baseUrl/attendance/checkin"),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({"employee_id": employeeId}),
    );
    return res.statusCode == 200;
  }

  /* ===== FETCH EMPLOYEES ===== */
  static Future<List<Map<String, dynamic>>> fetchAllEmployees() async {
    final res = await http.get(Uri.parse("$baseUrl/employees/all"));

    if (res.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(res.body));
    }
    return [];
  }

  /* ===== ADD EMPLOYEE ===== */
  static Future<bool> addEmployee(
      String name, String email, String role, double salary) async {
    final res = await http.post(
      Uri.parse("$baseUrl/employees/add"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "name": name,
        "email": email,
        "role": role,
        "salary_per_day": salary
      }),
    );
    return res.statusCode == 200;
  }

  /* ===== DELETE EMPLOYEE ===== */
  static Future<bool> deleteEmployee(int id) async {
    final res = await http.post(
      Uri.parse("$baseUrl/employees/remove"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"id": id}),
    );
    return res.statusCode == 200;
  }

  /* ===== UPDATE EMPLOYEE ===== */
  static Future<bool> updateEmployee(
      int id, String name, String email, String role, double salary) async {
    final res = await http.post(
      Uri.parse("$baseUrl/employees/update"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "id": id,
        "name": name,
        "email": email,
        "role": role,
        "salary_per_day": salary
      }),
    );
    return res.statusCode == 200;
  }

  /* ===== DASHBOARD COUNTS ===== */
  static Future<int> fetchEmployeeCount() async {
    final res = await http.get(Uri.parse("$baseUrl/employees/count"));
    if (res.statusCode == 200) {
      return jsonDecode(res.body)['count'] ?? 0;
    }
    return 0;
  }

  static Future<int> fetchPresentCount() async {
    final res = await http.get(Uri.parse("$baseUrl/attendance/present_count"));
    if (res.statusCode == 200) {
      return jsonDecode(res.body)['count'] ?? 0;
    }
    return 0;
  }

  static Future<int> fetchAbsentCount() async {
    final res = await http.get(Uri.parse("$baseUrl/attendance/absent_count"));
    if (res.statusCode == 200) {
      return jsonDecode(res.body)['count'] ?? 0;
    }
    return 0;
  }

  /* ===== LEAVE REQUEST ===== */
  static Future<bool> submitLeave(
      int employeeId, String date, String reason) async {
    final res = await http.post(
      Uri.parse("$baseUrl/leave/request"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "employee_id": employeeId,
        "date": date,
        "reason": reason
      }),
    );
    return res.statusCode == 200;
  }

  /* ===== PAYROLL ===== */

  // FETCH PAYROLL FROM DATABASE
  static Future<List<Map<String, dynamic>>> fetchAllPayroll(
      [String month = ""]) async {
    final res = await http.get(
      Uri.parse("$baseUrl/payroll/all?month=$month"),
    );

    if (res.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(res.body));
    }

    return [];
  }

  // GENERATE PAYROLL IN BACKEND (NOT FLUTTER)
  static Future<bool> generatePayroll(String month) async {
    final res = await http.post(
      Uri.parse("$baseUrl/payroll/generate"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"month": month}),
    );

    return res.statusCode == 200;
  }

  // UPDATE PAYROLL STATUS
  static Future<bool> updatePayrollStatus(
      int payrollId, String status) async {
    final res = await http.put(
      Uri.parse("$baseUrl/payroll/update/$payrollId"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "status": status,
      }),
    );

    return res.statusCode == 200;
  }

  /* ===== ATTENDANCE ===== */

  static Future<List<Map<String, dynamic>>> fetchAttendance() async {
    final response =
        await http.get(Uri.parse("$baseUrl/api/attendance"));

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    }

    return [];
  }

  static Future<void> timeIn(int employeeId) async {
    await http.post(
      Uri.parse("$baseUrl/api/attendance/time-in"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"employee_id": employeeId}),
    );
  }

  static Future<void> timeOut(int attendanceId) async {
    await http.put(
      Uri.parse("$baseUrl/api/attendance/time-out/$attendanceId"),
    );
  }

  /* ===== LOGIN ===== */
  static Future<Map<String, dynamic>?> login(
      String email, String password) async {
    final res = await http.post(
      Uri.parse("$baseUrl/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": email,
        "password": password
      }),
    );

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    }

    return null;
  }
}
