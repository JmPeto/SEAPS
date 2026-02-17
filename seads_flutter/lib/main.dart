import 'package:flutter/material.dart';
import 'api_service.dart';
import 'package:intl/intl.dart';



void main() {
  runApp(const MyApp());
}

/* ================= APP ================= */
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SEAPS',
      theme: ThemeData(useMaterial3: true),
      home: const DashboardPage(),
    );
  }
}

/* ================= DASHBOARD ================= */
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String currentView = "Dashboard";
  List<Map<String, dynamic>> employees = [];
  String searchQuery = "";

  /* ================= LOAD EMPLOYEES ================= */
  Future<void> loadEmployees() async {
    final data = await ApiService.fetchAllEmployees();
    setState(() {
      employees = data;
      currentView = "Employees";
    });
  }

  /* ================= DELETE EMPLOYEE ================= */
  Future<void> deleteEmployee(int id) async {
    try {
      final success = await ApiService.deleteEmployee(id);
      if (success) {
        await loadEmployees();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to delete employee")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  /* ================= ADD / EDIT ================= */
  void addEmployee() {
    showDialog(
      context: context,
      builder: (_) => AddEmployeeForm(onSuccess: loadEmployees),
    );
  }

  void editEmployee(Map<String, dynamic> employee) {
    showDialog(
      context: context,
      builder: (_) =>
          EditEmployeeForm(employee: employee, onSuccess: loadEmployees),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 900;

        return Scaffold(
          appBar: isDesktop
              ? null
              : AppBar(
                  title: const Text("SEAPS",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
          drawer: isDesktop ? null : _drawerMenu(),
          backgroundColor: const Color.fromARGB(255, 255, 255, 255),
          body: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isDesktop) _sideBar(),
              Expanded(child: _contentArea()),
            ],
          ),
        );
      },
    );
  }

  /* ================= CONTENT ================= */
Widget _contentArea() {
  return _buildView();
}


  Widget _buildView() {
    switch (currentView) {
      case "Dashboard":
        return const DashboardView();

      case "Employees":
        return EmployeesView(
          employees: employees
              .where((e) => (e['name'] ?? '')
                  .toString()
                  .toLowerCase()
                  .contains(searchQuery))
              .toList(),
          onSearch: (v) => setState(() => searchQuery = v.toLowerCase()),
          onRefresh: loadEmployees,
          onAdd: addEmployee,
          onEdit: editEmployee,
          onDelete: deleteEmployee,
        );

      case "Payroll":
  return const PayrollView();

      case "Attendance":
        return const AttendanceView();

      case "Request Support":
        return const PlaceholderPage(title: "Request Support");

      case "Settings":
        return const PlaceholderPage(title: "Settings");
        

      default:
        return const DashboardView();
    }
  }

  /* ================= SIDEBAR ================= */
  Widget _sideBar() {
    return Container(
      width: 230,
decoration: const BoxDecoration(
  gradient: LinearGradient(
    colors: [
      Color(0xFF7F00FF),
      Color(0xFFE100FF),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  ),
),

      child: _menuItems(),
    );
  }

  Widget _drawerMenu() {
    return Drawer(child: _sideBar());
  }

  Widget _menuItems() {
    return Column(
      children: [
        const SizedBox(height: 40),
        const Text(
          'SEAPS',
          style: TextStyle(
              color: Color.fromARGB(255, 255, 255, 255), fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 30),
        _menuTile(Icons.dashboard, 'Dashboard',
            () => setState(() => currentView = "Dashboard")),
         _menuTile(Icons.calendar_month_outlined, 'Attendance',
            () => setState(() => currentView = "Attendance")),
        _menuTile(Icons.people, 'Employees', loadEmployees),
        _menuTile(Icons.payments, 'Payroll Overview',
            () => setState(() => currentView = "Payroll")),
        _menuTile(Icons.question_mark, 'Request Support',
            () => setState(() => currentView = "Request Support")),
        _menuTile(Icons.person, 'Settings',
            () => setState(() => currentView = "Settings")),
      ],
    );
  }

  Widget _menuTile(IconData icon, String title, VoidCallback onTap) {
    return Builder(
      builder: (context) {
        return ListTile(
          leading: Icon(icon, color: const Color.fromARGB(255, 255, 255, 255)),
          title: Text(title, style: const TextStyle(color: Colors.white)),
          onTap: () {
            if (Scaffold.of(context).isDrawerOpen) {
              Navigator.pop(context);
            }
            onTap();
          },
        );
      },
    );
  }
}

/* ================= PLACEHOLDER PAGE ================= */
class PlaceholderPage extends StatelessWidget {
  final String title;
  const PlaceholderPage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
                  const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          const Text("Content coming soon...",
              style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}

/* ================= DASHBOARD VIEW ================= */
class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  int employeeCount = 0;
  int presentCount = 0;
  int absentCount = 0;

  List<Map<String, dynamic>> attendanceList = [];
  bool isLoadingAttendance = true;

  @override
  void initState() {
    super.initState();
    fetchCounts();
    fetchAttendance();
  }

  void fetchCounts() async {
    employeeCount = await ApiService.fetchEmployeeCount();
    presentCount = await ApiService.fetchPresentCount();
    absentCount = await ApiService.fetchAbsentCount();
    setState(() {});
  }

  void fetchAttendance() async {
    try {
      attendanceList = await ApiService.fetchAttendance();
    } finally {
      isLoadingAttendance = false;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFFF4F6FA),
      padding: const EdgeInsets.fromLTRB(35, 20, 32, 20),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// WELCOME TEXT
            const Text(
              "Welcome, Admin!",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),

            const SizedBox(height: 45),

            /// TITLE
            const Text(
              "Dashboard Overview",
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            const Text(
              "Monitor employee attendance and recent activities",
              style: TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 28),

            /// STAT CARDS
            Wrap(
              spacing: 24,
              runSpacing: 24,
              children: [

                DashboardCard(
                  title: "Total Employees",
                  value: employeeCount.toString(),
                  icon: Icons.people,
                  color: const Color(0xFFEDE7F6),
                  iconColor: Colors.deepPurple,
                ),

                DashboardCard(
                  title: "Present Today",
                  value: presentCount.toString(),
                  icon: Icons.check_circle,
                  color: const Color(0xFFE8F5E9),
                  iconColor: Colors.green,
                ),

                DashboardCard(
                  title: "Absent Today",
                  value: absentCount.toString(),
                  icon: Icons.cancel,
                  color: const Color(0xFFFFEBEE),
                  iconColor: Colors.red,
                ),
              ],
            ),

            const SizedBox(height: 40),

            /// RECENT ACTIVITY
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  const Text(
                    "Recent Activity",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 4),

                  const Text(
                    "Latest employee actions and attendance logs",
                    style: TextStyle(color: Colors.grey),
                  ),

                  const SizedBox(height: 20),

                  isLoadingAttendance
                      ? const Center(child: CircularProgressIndicator())
                      : SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            headingRowColor:
                                MaterialStateProperty.all(const Color(0xFFF5F5F5)),
                            columns: const [
                              DataColumn(label: Text("Employee Name")),
                              DataColumn(label: Text("Action Type")),
                              DataColumn(label: Text("Date & Time")),
                              DataColumn(label: Text("Status")),
                            ],
                            rows: attendanceList.map((a) {
                              return DataRow(
                                cells: [
                                  DataCell(Text(a['name'] ?? "")),
                                  DataCell(
                                    Chip(
                                      label: Text(a['type'] ?? "Time In"),
                                      backgroundColor:
                                          Colors.green.shade100,
                                    ),
                                  ),
                                  DataCell(Text(a['datetime'] ?? "")),
                                  DataCell(
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: Colors.green.shade100,
                                        borderRadius:
                                            BorderRadius.circular(20),
                                      ),
                                      child: const Text(
                                        "Completed",
                                        style: TextStyle(
                                            color: Colors.green,
                                            fontWeight: FontWeight.w500),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* ================= DASHBOARD CARD ================= */
class DashboardCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final Color iconColor;

  const DashboardCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: iconColor.withOpacity(0.15),
            child: Icon(icon, color: iconColor, size: 28),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 6),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/* ================= ATTENDANCE VIEW ================= */
class AttendanceView extends StatefulWidget {
  const AttendanceView({super.key});

  @override
  State<AttendanceView> createState() => _AttendanceViewState();
}

class _AttendanceViewState extends State<AttendanceView> {
  List<Map<String, dynamic>> attendanceList = [];
  bool isLoading = true;

  String selectedDate = "";
  String statusFilter = "All";

  final TextEditingController dateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadAttendance();
  }

  @override
  void dispose() {
    dateController.dispose();
    super.dispose();
  }

  Future<void> loadAttendance() async {
    setState(() => isLoading = true);
    final data = await ApiService.fetchAttendance();
    setState(() {
      attendanceList = data;
      isLoading = false;
    });
  }

  /// Status color badge
  Color statusColor(String status) {
    switch (status) {
      case "Present":
        return Colors.green.shade100;
      case "Late":
        return Colors.orange.shade100;
      case "Absent":
        return Colors.red.shade100;
      default:
        return Colors.grey.shade200;
    }
  }

  Color statusTextColor(String status) {
    switch (status) {
      case "Present":
        return Colors.green;
      case "Late":
        return Colors.orange;
      case "Absent":
        return Colors.red;
      default:
        return Colors.black;
    }
  }

  void showDetails(Map<String, dynamic> a) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Activity Details"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Employee Name: ${a['name'] ?? ""}"),
            const SizedBox(height: 6),
            Text("Time In: ${a['time_in'] ?? "-"}"),
            Text("Time Out: ${a['time_out'] ?? "-"}"),
            Text("Total Hours: ${a['total_hours'] ?? "-"}"),
            Text("Status: ${a['status'] ?? "-"}"),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Apply filters
    final filtered = attendanceList.where((a) {
      final dateMatch = selectedDate.isEmpty
          ? true
          : (a['date'] ?? "").toString().startsWith(selectedDate);

      final statusMatch = statusFilter == "All"
          ? true
          : (a['status'] ?? "") == statusFilter;

      return dateMatch && statusMatch;
    }).toList();

    return Container(
      width: double.infinity,
      color: const Color(0xFFF4F6FA),
      padding: const EdgeInsets.fromLTRB(35, 20, 32, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// TITLE
          const Text(
            "Attendance Monitoring",
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          const Text(
            "Track and manage employee attendance records",
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 20),

          /// FILTER CONTAINER
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                /// DATE PICKER
                SizedBox(
                  width: 200,
                  child: TextField(
                    readOnly: true,
                    controller: dateController..text = selectedDate,
                    decoration: InputDecoration(
                      labelText: "Date",
                      prefixIcon: const Icon(Icons.calendar_today),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );

                      if (picked != null) {
                        setState(() {
                          selectedDate =
                              picked.toIso8601String().split('T')[0];
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(width: 16),

                /// STATUS DROPDOWN
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButton<String>(
                    value: statusFilter,
                    underline: const SizedBox(),
                    items: const [
                      DropdownMenuItem(
                          value: "All", child: Text("All Status")),
                      DropdownMenuItem(
                          value: "Present", child: Text("Present")),
                      DropdownMenuItem(value: "Late", child: Text("Late")),
                      DropdownMenuItem(value: "Absent", child: Text("Absent")),
                    ],
                    onChanged: (v) {
                      if (v != null) setState(() => statusFilter = v);
                    },
                  ),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: loadAttendance,
                  child: const Text("Refresh"),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          /// TABLE
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : LayoutBuilder(
                      builder: (context, constraints) {
                        return SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minWidth: constraints.maxWidth,
                            ),
                            child: DataTable(
                              headingRowColor:
                                  MaterialStateProperty.all(const Color(0xFFF5F5F5)),
                              columnSpacing: 20,
                              columns: const [
                                DataColumn(label: Text("Employee Name")),
                                DataColumn(label: Text("Employee ID")),
                                DataColumn(label: Text("Time In")),
                                DataColumn(label: Text("Time Out")),
                                DataColumn(label: Text("Total Hours")),
                                DataColumn(label: Text("Status")),
                                DataColumn(label: Text("Actions")),
                              ],
                              rows: filtered.map((a) {
                                final status = a['status'] ?? "Present";
                                return DataRow(cells: [
                                  DataCell(Text(a['name'] ?? "")),
                                  DataCell(Text(a['employee_id'] ?? "")),
                                  DataCell(Text(a['time_in'] ?? "-")),
                                  DataCell(Text(a['time_out'] ?? "-")),
                                  DataCell(Text(a['total_hours'] ?? "-")),
                                  DataCell(
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: statusColor(status),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        status,
                                        style: TextStyle(
                                          color: statusTextColor(status),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    ElevatedButton(
                                      onPressed: () => showDetails(a),
                                      child: const Text("View Details"),
                                    ),
                                  ),
                                ]);
                              }).toList(),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}


/// -------------------- EMPLOYEES VIEW --------------------
class EmployeesView extends StatefulWidget {
  final List<Map<String, dynamic>> employees;
  final Function(String) onSearch;
  final VoidCallback onRefresh;
  final VoidCallback onAdd;
  final Function(Map<String, dynamic>) onEdit;
  final Function(int) onDelete;

  const EmployeesView({
    super.key,
    required this.employees,
    required this.onSearch,
    required this.onRefresh,
    required this.onAdd,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<EmployeesView> createState() => _EmployeesViewState();
}

class _EmployeesViewState extends State<EmployeesView> {
  String selectedTab = "All";
  final TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final filteredEmployees = widget.employees.where((e) {
      if (selectedTab.toLowerCase() == "all") return true;
      final role = (e['role'] ?? '').toString().trim().toLowerCase();
      return role == selectedTab.toLowerCase();
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Employees",
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),

        /// -------------------- ROLE TABS --------------------
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _roleTab("All"),
              _roleTab("Admin"),
              _roleTab("HR"),
              _roleTab("Employee"),
            ],
          ),
        ),
        const SizedBox(height: 12),

        /// -------------------- CONTROLS ROW (Add/Search/Clear) --------------------
        Wrap(
          spacing: 12,
          children: [
            ElevatedButton(
              onPressed: widget.onAdd,
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 252, 252, 252), // blue background
                  foregroundColor: const Color.fromARGB(255, 6, 6, 6)),
              child: const Text("+ New Employee"),
            ),
SizedBox(
  width: 250,
  child: TextFormField(
    controller: searchController,
    onChanged: widget.onSearch,
    decoration: InputDecoration(
      labelText: "Search Employee", 
      prefixIcon: const Icon(Icons.search),
      filled: true,
      fillColor: Colors.grey[200],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
    ),
  ),
),
            OutlinedButton(
              onPressed: () {
                searchController.clear();
                widget.onSearch("");
              },
              style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.grey[200],
                  foregroundColor: Colors.black),
              child: const Text("Clear"),
            ),
          ],
        ),
        const SizedBox(height: 16),

        /// -------------------- EMPLOYEES TABLE --------------------
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                child: DataTable(
                  columnSpacing: 24,
                  horizontalMargin: 16,
                  headingRowColor:
                      MaterialStateProperty.all(const Color(0xFFF5F5F5)),
                  columns: const [
                    DataColumn(label: Text("ID")),
                    DataColumn(label: Text("Name")),
                    DataColumn(label: Text("Email")),
                    DataColumn(label: Text("Role")),
                    DataColumn(label: Text("Salary / Day")),
                    DataColumn(label: Text("Actions")),
                  ],
                  rows: filteredEmployees.map((e) {
                    return DataRow(
                      cells: [
                        DataCell(Text("${e['id']}")),
                        DataCell(Text("${e['name']}")),
                        DataCell(Text("${e['email']}")),
                        DataCell(Text("${e['role']}")),
                        DataCell(Text("₱${e['salary_per_day']}")),
                        DataCell(Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, size: 18),
                              color: Colors.blue,
                              onPressed: () => widget.onEdit(e),
                            ),
                            IconButton(
  icon: const Icon(Icons.delete, size: 18),
  color: Colors.red,
  onPressed: () async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Confirm Delete"),
        content: Text("Are you sure you want to delete ${e['name']}?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      widget.onDelete(e['id']);
    }
  },
),
                          ],
                        )),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

Widget _roleTab(String label) {
  final isActive = selectedTab.toLowerCase() == label.toLowerCase();
  return Padding(
    padding: const EdgeInsets.only(right: 8),
    child: InkWell(
      onTap: () => setState(() => selectedTab = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? Colors.blue : Colors.white, // active = blue, inactive = white
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.blue), // keep border blue
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.black, // active = white text, inactive = black text
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    ),
  );
}
}

/* ================= ADD EMPLOYEE FORM ================= */
class AddEmployeeForm extends StatefulWidget {
  final VoidCallback onSuccess;
  const AddEmployeeForm({super.key, required this.onSuccess});

  @override
  State<AddEmployeeForm> createState() => _AddEmployeeFormState();
}

class _AddEmployeeFormState extends State<AddEmployeeForm> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final salaryController = TextEditingController();
  String selectedRole = "EMPLOYEE"; // default role

  bool isLoading = false;

  final List<String> roles = ["ADMIN", "EMPLOYEE",];

  void submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    final success = await ApiService.addEmployee(
      nameController.text,
      emailController.text,
      selectedRole,
      double.tryParse(salaryController.text) ?? 0,
    );

    setState(() => isLoading = false);

    if (success) {
      widget.onSuccess();
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Failed to add employee")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Add Employee"),
      content: Form(
        key: _formKey,
        child: SizedBox(
          width: 300,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Name"),
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(labelText: "Email"),
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              DropdownButtonFormField<String>(
                value: selectedRole,
                items: roles
                    .map((role) =>
                        DropdownMenuItem(value: role, child: Text(role)))
                    .toList(),
                onChanged: (v) => setState(() => selectedRole = v!),
                decoration: const InputDecoration(labelText: "Role"),
              ),
              TextFormField(
                controller: salaryController,
                decoration:
                    const InputDecoration(labelText: "Salary per Day"),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: isLoading ? null : submit,
                child: isLoading
                    ? const CircularProgressIndicator()
                    : const Text("Add Employee"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/* ================= EDIT EMPLOYEE FORM ================= */
class EditEmployeeForm extends StatefulWidget {
  final Map<String, dynamic> employee;
  final VoidCallback onSuccess;

  const EditEmployeeForm(
      {super.key, required this.employee, required this.onSuccess});

  @override
  State<EditEmployeeForm> createState() => _EditEmployeeFormState();
}

class _EditEmployeeFormState extends State<EditEmployeeForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController salaryController;
  late String selectedRole;
  bool isLoading = false;

  final List<String> roles = ["ADMIN", "EMPLOYEE",];

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.employee['name'] ?? "");
    emailController = TextEditingController(text: widget.employee['email'] ?? "");
    salaryController = TextEditingController(
        text: "${widget.employee['salary_per_day'] ?? 0}");
    selectedRole = widget.employee['role'] ?? "EMPLOYEE";
  }

  void submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    final success = await ApiService.updateEmployee(
      widget.employee['id'],
      nameController.text,
      emailController.text,
      selectedRole,
      double.tryParse(salaryController.text) ?? 0,
    );

    setState(() => isLoading = false);

    if (success) {
      widget.onSuccess();
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Failed to update employee")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Edit Employee"),
      content: Form(
        key: _formKey,
        child: SizedBox(
          width: 300,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Name"),
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(labelText: "Email"),
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              DropdownButtonFormField<String>(
                value: selectedRole,
                items: roles
                    .map((role) =>
                        DropdownMenuItem(value: role, child: Text(role)))
                    .toList(),
                onChanged: (v) => setState(() => selectedRole = v!),
                decoration: const InputDecoration(labelText: "Role"),
              ),
              TextFormField(
                controller: salaryController,
                decoration:
                    const InputDecoration(labelText: "Salary per Day"),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: isLoading ? null : submit,
                child: isLoading
                    ? const CircularProgressIndicator()
                    : const Text("Update Employee"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/* ================= PAYROLL VIEW================= */
class PayrollView extends StatefulWidget {
  const PayrollView({super.key});

  @override
  State<PayrollView> createState() => _PayrollViewState();
}

class _PayrollViewState extends State<PayrollView> {
  String statusFilter = "All";
  String searchQuery = "";
  bool isLoading = true;
  List<Map<String, dynamic>> payrolls = [];
  String fromDate = "";
  String toDate = "";

  final NumberFormat currencyFormatter =
      NumberFormat.currency(locale: 'en_PH', symbol: '₱');

  @override
  void initState() {
    super.initState();
    fetchPayroll();
  }

  Future<void> fetchPayroll() async {
    setState(() => isLoading = true);
    final allPayrolls = await ApiService.fetchAllPayroll("");

    // Filter by fromDate/toDate only
    payrolls = allPayrolls.where((p) {
      final payDate = DateTime.tryParse(p['pay_date'] ?? "") ?? DateTime.now();
      final from = fromDate.isNotEmpty ? DateTime.parse(fromDate) : null;
      final to = toDate.isNotEmpty ? DateTime.parse(toDate) : null;

      if (from != null && payDate.isBefore(from)) return false;
      if (to != null && payDate.isAfter(to)) return false;
      return true;
    }).toList();

    setState(() => isLoading = false);
  }

  /// Map backend status to display text
  String displayStatus(String status) {
    switch (status) {
      case "Completed":
        return "Paid";
      case "Pending":
        return "Unpaid";
      default:
        return status;
    }
  }

  /// Map display text back to backend status
  String backendStatus(String display) {
    switch (display) {
      case "Paid":
        return "Completed";
      case "Unpaid":
        return "Pending";
      default:
        return display;
    }
  }

  int get totalPaid =>
      payrolls.where((p) => p['status'] == "Completed").length;

  double get pendingAmount =>
      payrolls
          .where((p) => p['status'] == "Pending")
          .fold(0.0, (sum, p) => sum + (p['net_pay'] ?? 0));

  @override
  Widget build(BuildContext context) {
    // Filter payrolls by status and search query
    final filteredPayrolls = payrolls.where((p) {
      final statusMatch = statusFilter == "All"
          ? true
          : displayStatus(p['status'] ?? "Pending") == statusFilter;
      final searchMatch =
          p['name'].toString().toLowerCase().contains(searchQuery.toLowerCase());
      return statusMatch && searchMatch;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Payroll Overview",
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),

        /// SUMMARY CARDS + FILTER CONTAINER RESPONSIVE
        LayoutBuilder(builder: (context, constraints) {
          // ignore: unused_local_variable
          final isWide = constraints.maxWidth > 700;
          return Wrap(
            alignment: WrapAlignment.start,
            spacing: 16,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _summaryCard(
                title: "Total Employees Paid",
                value: totalPaid.toString(),
                icon: Icons.people,
              ),
              _summaryCard(
                title: "Pending Payroll",
                value: currencyFormatter.format(pendingAmount),
                icon: Icons.hourglass_bottom,
              ),

              /// WHITE CONTAINER with From, To, Apply, Refresh
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Wrap(
                  spacing: 12,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    /// From Date
                    SizedBox(
                      width: 150,
                      child: TextField(
                        controller: TextEditingController(text: fromDate),
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: "From (YYYY-MM-DD)",
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8)),
                          filled: true,
                          fillColor: Colors.grey[200],
                        ),
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: fromDate.isNotEmpty
                                ? DateTime.parse(fromDate)
                                : DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) {
                            setState(() => fromDate =
                                picked.toIso8601String().split('T')[0]);
                          }
                        },
                      ),
                    ),

                    /// To Date
                    SizedBox(
                      width: 150,
                      child: TextField(
                        controller: TextEditingController(text: toDate),
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: "To (YYYY-MM-DD)",
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8)),
                          filled: true,
                          fillColor: Colors.grey[200],
                        ),
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: toDate.isNotEmpty
                                ? DateTime.parse(toDate)
                                : DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) {
                            setState(() => toDate =
                                picked.toIso8601String().split('T')[0]);
                          }
                        },
                      ),
                    ),

                    /// Apply Button
                    ElevatedButton(
                      onPressed: fetchPayroll,
                      child: const Text("Apply"),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(
                              color: const Color.fromARGB(255, 0, 0, 0),
                              width: 1),
                        ),
                      ),
                    ),

                    /// Refresh Button
                    OutlinedButton(
                      onPressed: () {
                        setState(() {
                          fromDate = "";
                          toDate = "";
                          searchQuery = "";
                          statusFilter = "All";
                        });
                        fetchPayroll();
                      },
                      child: const Text("Refresh"),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                            color: const Color.fromARGB(255, 0, 0, 0),
                            width: 1),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }),

        const SizedBox(height: 12),

        /// SEARCH BAR + STATUS
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4),
          child: LayoutBuilder(builder: (context, constraints) {
            final isWide = constraints.maxWidth > 600;
            return isWide
                ? Row(
                    children: [
                      SizedBox(
                        width: 300,
                        child: TextField(
                          decoration: InputDecoration(
                            labelText: "Search Employee",
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8)),
                            filled: true,
                            fillColor: Colors.grey[200],
                            prefixIcon: const Icon(Icons.search),
                          ),
                          onChanged: (v) {
                            setState(() => searchQuery = v);
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade400),
                        ),
                        child: DropdownButton<String>(
                          value: statusFilter,
                          underline: const SizedBox(),
                          items: const [
                            DropdownMenuItem(value: "All", child: Text("Status")),
                            DropdownMenuItem(value: "Paid", child: Text("Paid")),
                            DropdownMenuItem(value: "Unpaid", child: Text("Unpaid")),
                          ],
                          onChanged: (v) {
                            if (v != null) setState(() => statusFilter = v);
                          },
                        ),
                      ),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 300,
                        child: TextField(
                          decoration: InputDecoration(
                            labelText: "Search Employee",
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8)),
                            filled: true,
                            fillColor: Colors.grey[200],
                            prefixIcon: const Icon(Icons.search),
                          ),
                          onChanged: (v) {
                            setState(() => searchQuery = v);
                          },
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade400),
                        ),
                        child: DropdownButton<String>(
                          value: statusFilter,
                          underline: const SizedBox(),
                          items: const [
                            DropdownMenuItem(value: "All", child: Text("Status")),
                            DropdownMenuItem(value: "Paid", child: Text("Paid")),
                            DropdownMenuItem(value: "Unpaid", child: Text("Unpaid")),
                          ],
                          onChanged: (v) {
                            if (v != null) setState(() => statusFilter = v);
                          },
                        ),
                      ),
                    ],
                  );
          }),
        ),

        const SizedBox(height: 12),

        /// PAYROLL TABLE
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView(
                    children: [
                      DataTable(
                        headingRowColor:
                            MaterialStateProperty.all(const Color(0xFFF5F5F5)),
                        columns: const [
                          DataColumn(label: Text("Employee Name")),
                          DataColumn(label: Text("Pay Period")),
                          DataColumn(label: Text("Salary / Month")),
                          DataColumn(label: Text("Deduction")),
                          DataColumn(label: Text("Status")),
                        ],
                        rows: filteredPayrolls.map((p) {
                          final status = displayStatus(p['status'] ?? "Pending");
                          return DataRow(cells: [
                            DataCell(
                              Row(
                                children: [
                                  const CircleAvatar(radius: 14),
                                  const SizedBox(width: 8),
                                  Text(p['name'] ?? ""),
                                ],
                              ),
                            ),
                            const DataCell(Text("01/01/26 - 02/02/26")),
                            DataCell(Text(currencyFormatter
                                .format(p['basic_salary'] ?? 0))),
                            DataCell(Text(currencyFormatter
                                .format(p['tax_withheld'] ?? 0))),
                            DataCell(
                              DropdownButton<String>(
                                value: status,
                                items: const [
                                  DropdownMenuItem(
                                      value: "Paid", child: Text("Paid")),
                                  DropdownMenuItem(
                                      value: "Unpaid", child: Text("Unpaid")),
                                ],
                                onChanged: (v) async {
                                  if (v == null) return;
                                  final newStatus = backendStatus(v);

                                  // Only update if user manually changes
                                  setState(() {
                                    p['status'] = newStatus;
                                  });

                                  // TODO: Call API to update the status in backend
                                },
                              ),
                            ),
                          ]);
                        }).toList(),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _summaryCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
      width: 250,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.blue[100],
            child: Icon(icon, color: Colors.blue),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 4),
              Text(
                value,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

