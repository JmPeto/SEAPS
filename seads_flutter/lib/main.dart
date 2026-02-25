
import 'package:flutter/material.dart';
import 'api_service.dart';
import 'dashboard.dart';
import 'attendance.dart';
import 'employees.dart';
import 'payroll.dart';
import 'request_support.dart';
import 'login.dart';
import 'employee_dashboard.dart';




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
      home: const LoginPage(),
      routes: {
        '/admin': (context) => DashboardPage(),
        '/employee': (context) => EmployeeDashboard(
          employeeName: "John Doe",
          employeeId: 1001,
        ),
      },
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
      if (!mounted) return;
      if (success) {
        await loadEmployees();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to delete employee")),
        );
      }
    } catch (e) {
      if (!mounted) return;
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

      case "Request C.A":
        return const RequestSupportView();

    case "Settings":
  return const SettingsView();
        

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
        _menuTile(Icons.question_mark, 'Request C.A',
            () => setState(() => currentView = "Request C.A")),
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

/* ================= SETTINGS VIEW ================= */
class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  final TextEditingController lateController =
      TextEditingController(text: "49");
  final TextEditingController absenceController =
      TextEditingController(text: "200");
  final TextEditingController overtimeController =
      TextEditingController(text: "25");

  TimeOfDay workStart = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay workEnd = const TimeOfDay(hour: 17, minute: 0);

  @override
  void dispose() {
    lateController.dispose();
    absenceController.dispose();
    overtimeController.dispose();
    super.dispose();
  }

  String formatTime(TimeOfDay time) {
    final now = DateTime.now();
    final dt = DateTime(
        now.year, now.month, now.day, time.hour, time.minute);
    return TimeOfDay.fromDateTime(dt).format(context);
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

            const Text(
              "Welcome, Admin!",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),

            const SizedBox(height: 25),

            /// ================= DEDUCTION CONFIGURATION =================
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  const Text(
                    "Deduction Configuration",
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 20),

                  Row(
                    children: [

                      /// Late Deduction
                      Expanded(
                        child: _settingsField(
                          label: "Late Deduction (per hour)",
                          controller: lateController,
                        ),
                      ),

                      const SizedBox(width: 16),

                      /// Absence Deduction
                      Expanded(
                        child: _settingsField(
                          label: "Absence Deduction (per day)",
                          controller: absenceController,
                        ),
                      ),

                      const SizedBox(width: 16),

                      /// Overtime Rate
                      Expanded(
                        child: _settingsField(
                          label: "Overtime Rate (per hour)",
                          controller: overtimeController,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text("Configuration Saved")),
                      );
                    },
                    icon: const Icon(Icons.save),
                    label: const Text("Save Configuration"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            /// ================= WORK SCHEDULE =================
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  const Text(
                    "Work Schedule Settings",
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 20),

                  Row(
                    children: [

                      /// Start Time
                      Expanded(
                        child: _timePickerField(
                          label: "Work Start Time",
                          time: workStart,
                          onTap: () async {
                            final picked = await showTimePicker(
                              context: context,
                              initialTime: workStart,
                            );
                            if (picked != null) {
                              setState(() => workStart = picked);
                            }
                          },
                        ),
                      ),

                      const SizedBox(width: 16),

                      /// End Time
                      Expanded(
                        child: _timePickerField(
                          label: "Work End Time",
                          time: workEnd,
                          onTap: () async {
                            final picked = await showTimePicker(
                              context: context,
                              initialTime: workEnd,
                            );
                            if (picked != null) {
                              setState(() => workEnd = picked);
                            }
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F0FE),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      "Current Schedule: ${formatTime(workStart)} - ${formatTime(workEnd)}",
                      style: const TextStyle(
                          fontWeight: FontWeight.w500),
                    ),
                  ),

                  const SizedBox(height: 20),

                  ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text("Schedule Saved")),
                      );
                    },
                    icon: const Icon(Icons.save),
                    label: const Text("Save Schedule"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
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

  Widget _settingsField({
    required String label,
    required TextEditingController controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            prefixText: "₱ ",
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _timePickerField({
    required String label,
    required TimeOfDay time,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.access_time),
                const SizedBox(width: 8),
                Text(formatTime(time)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
