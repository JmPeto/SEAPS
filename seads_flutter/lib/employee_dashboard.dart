import 'package:flutter/material.dart';
import 'theme.dart';

class EmployeeDashboard extends StatefulWidget {
  final String employeeName;
  final int employeeId;

  const EmployeeDashboard({
    super.key,
    required this.employeeName,
    required this.employeeId,
  });

  @override
  State<EmployeeDashboard> createState() => _EmployeeDashboardState();
}

class _EmployeeDashboardState extends State<EmployeeDashboard> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("SEAPS - Employee"),
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Navigator.of(context).pushReplacementNamed('/'),
          ),
        ],
      ),
      body: IndexedStack(
        index: currentIndex,
        children: [
          const EmployeeAttendanceView(),
          EmployeeCaRequestView(employeeId: widget.employeeId),
          EmployeeProfileView(
            employeeName: widget.employeeName,
            employeeId: widget.employeeId,
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) => setState(() => currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: "Attendance",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: "C.A Request",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}

/* ================= ATTENDANCE VIEW ================= */
class EmployeeAttendanceView extends StatefulWidget {
  const EmployeeAttendanceView({super.key});

  @override
  State<EmployeeAttendanceView> createState() =>
      _EmployeeAttendanceViewState();
}

class _EmployeeAttendanceViewState extends State<EmployeeAttendanceView> {
  late DateTime weekStart;
  List<Map<String, dynamic>> weekAttendance = [];
  bool isPayrollReleased = true; // Mock: can be toggled

  @override
  void initState() {
    super.initState();
    _initializeWeek();
    _loadWeekAttendance();
  }

  void _initializeWeek() {
    final now = DateTime.now();
    weekStart = now.subtract(Duration(days: now.weekday - 1));
  }

  void _loadWeekAttendance() {
    // Mock data - replace with API call
    weekAttendance = [
      {
        "day": "Monday",
        "date": "Feb 24",
        "timeIn": "08:30 AM",
        "timeOut": "05:15 PM",
        "status": "Present",
        "hours": 8.75
      },
      {
        "day": "Tuesday",
        "date": "Feb 25",
        "timeIn": "08:15 AM",
        "timeOut": "05:30 PM",
        "status": "Present",
        "hours": 9.25
      },
      {
        "day": "Wednesday",
        "date": "Feb 26",
        "timeIn": "-",
        "timeOut": "-",
        "status": "Holiday",
        "hours": 0
      },
      {
        "day": "Thursday",
        "date": "Feb 27",
        "timeIn": "09:00 AM",
        "timeOut": "05:00 PM",
        "status": "Late",
        "hours": 8.0
      },
      {
        "day": "Friday",
        "date": "Feb 28",
        "timeIn": "08:45 AM",
        "timeOut": "04:45 PM",
        "status": "Present",
        "hours": 8.0
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    if (!isPayrollReleased) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.paddingXLarge),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.lock,
                size: 80,
                color: AppTheme.primaryColor.withOpacity(0.5),
              ),
              const SizedBox(height: AppTheme.spacingLarge),
              const Text(
                "Attendance Details Locked",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: AppTheme.spacingMedium),
              Text(
                "Attendance details are available after payroll is released",
                textAlign: TextAlign.center,
                style: AppTheme.subtitle,
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.paddingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Week Summary
          Container(
            padding: const EdgeInsets.all(AppTheme.paddingLarge),
            decoration: AppTheme.sectionDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Weekly Summary",
                  style: AppTheme.headingSmall,
                ),
                const SizedBox(height: AppTheme.spacingMedium),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _summaryItem("Total Hours", "41.75h", AppTheme.primaryColor),
                    _summaryItem("Days Present", "4", AppTheme.statusGreen),
                    _summaryItem("Late", "1", AppTheme.statusOrange),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: AppTheme.spacingLarge),

          /// Daily Details
          const Text(
            "Daily Attendance",
            style: AppTheme.headingSmall,
          ),
          const SizedBox(height: AppTheme.spacingMedium),
          ...weekAttendance.map((attendance) {
            return _attendanceCard(attendance);
          }),
        ],
      ),
    );
  }

  Widget _summaryItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: AppTheme.spacingSmall),
        Text(
          label,
          style: AppTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _attendanceCard(Map<String, dynamic> data) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingMedium),
      padding: const EdgeInsets.all(AppTheme.paddingMedium),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data['day'],
                    style: AppTheme.bodyLarge,
                  ),
                  Text(
                    data['date'],
                    style: AppTheme.bodySmall,
                  ),
                ],
              ),
              StatusBadge(status: data['status']),
            ],
          ),
          const SizedBox(height: AppTheme.spacingMedium),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Time In", style: AppTheme.bodySmall),
                  Text(data['timeIn'], style: AppTheme.bodyLarge),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Time Out", style: AppTheme.bodySmall),
                  Text(data['timeOut'], style: AppTheme.bodyLarge),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Hours", style: AppTheme.bodySmall),
                  Text(
                    "${data['hours']}h",
                    style: AppTheme.bodyLarge,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/* ================= C.A REQUEST VIEW ================= */
class EmployeeCaRequestView extends StatefulWidget {
  final int employeeId;

  const EmployeeCaRequestView({super.key, required this.employeeId});

  @override
  State<EmployeeCaRequestView> createState() => _EmployeeCaRequestViewState();
}

class _EmployeeCaRequestViewState extends State<EmployeeCaRequestView> {
  List<Map<String, dynamic>> caRequests = [];
  bool isLoading = false;

  final reasonController = TextEditingController();
  DateTime? selectedDate;
  int selectedDays = 1;

  @override
  void initState() {
    super.initState();
    _loadCaRequests();
  }

  void _loadCaRequests() {
    // Mock data
    caRequests = [
      {
        "date": "Feb 15, 2026",
        "days": 2,
        "status": "APPROVED",
        "reason": "Personal leave"
      },
      {
        "date": "Jan 20, 2026",
        "days": 1,
        "status": "APPROVED",
        "reason": "Medical appointment"
      },
      {
        "date": "Jan 10, 2026",
        "days": 3,
        "status": "PENDING",
        "reason": "Family events"
      },
    ];
  }

  void _submitRequest() {
    if (selectedDate == null || reasonController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all fields")),
      );
      return;
    }

    setState(() => isLoading = true);

    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      setState(() => isLoading = false);

      caRequests.insert(0, {
        "date": "${selectedDate!.month}/${selectedDate!.day}, ${selectedDate!.year}",
        "days": selectedDays,
        "status": "PENDING",
        "reason": reasonController.text,
      });

      reasonController.clear();
      selectedDate = null;
      selectedDays = 1;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("C.A request submitted successfully")),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.paddingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// New Request Form
          Container(
            padding: const EdgeInsets.all(AppTheme.paddingLarge),
            decoration: AppTheme.sectionDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Request Leave",
                  style: AppTheme.headingSmall,
                ),
                const SizedBox(height: AppTheme.spacingLarge),

                /// Date Picker
                GestureDetector(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate ?? DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 90)),
                    );
                    if (picked != null) {
                      setState(() => selectedDate = picked);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(AppTheme.paddingMedium),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius:
                          BorderRadius.circular(AppTheme.borderRadiusMedium),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Start Date", style: AppTheme.bodySmall),
                            Text(
                              selectedDate == null
                                  ? "Select date"
                                  : "${selectedDate!.month}/${selectedDate!.day}/${selectedDate!.year}",
                              style: AppTheme.bodyLarge,
                            ),
                          ],
                        ),
                        const Icon(Icons.calendar_today),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: AppTheme.spacingLarge),

                /// Days Selection
                Text("Number of Days", style: AppTheme.bodySmall),
                const SizedBox(height: AppTheme.spacingSmall),
                Row(
                  children: [
                    Expanded(
                      child: Slider(
                        value: selectedDays.toDouble(),
                        min: 1,
                        max: 7,
                        divisions: 6,
                        label: "$selectedDays days",
                        onChanged: (value) {
                          setState(() => selectedDays = value.toInt());
                        },
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.paddingMedium,
                        vertical: AppTheme.paddingSmall,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.2),
                        borderRadius:
                            BorderRadius.circular(AppTheme.borderRadiusMedium),
                      ),
                      child: Text(
                        "$selectedDays days",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppTheme.spacingLarge),

                /// Reason
                TextField(
                  controller: reasonController,
                  decoration: AppTheme.getInputDecoration("Reason for leave"),
                  maxLines: 3,
                ),

                const SizedBox(height: AppTheme.spacingLarge),

                /// Submit Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _submitRequest,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        vertical: AppTheme.paddingLarge,
                      ),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              valueColor: AlwaysStoppedAnimation(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Text("Submit Request"),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppTheme.spacingXLarge),

          /// Request History
          const Text(
            "Request History",
            style: AppTheme.headingSmall,
          ),
          const SizedBox(height: AppTheme.spacingMedium),
          ...caRequests.map((request) {
            return _requestCard(request);
          }),
        ],
      ),
    );
  }

  Widget _requestCard(Map<String, dynamic> request) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingMedium),
      padding: const EdgeInsets.all(AppTheme.paddingMedium),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
            ),
            child: Icon(
              Icons.calendar_month,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(width: AppTheme.spacingLarge),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${request['days']} day(s) leave",
                  style: AppTheme.bodyLarge,
                ),
                Text(
                  request['reason'],
                  style: AppTheme.subtitle,
                ),
                const SizedBox(height: AppTheme.spacingSmall),
                Text(
                  request['date'],
                  style: AppTheme.bodySmall,
                ),
              ],
            ),
          ),
          StatusBadge(status: request['status']),
        ],
      ),
    );
  }

  @override
  void dispose() {
    reasonController.dispose();
    super.dispose();
  }
}

/* ================= PROFILE VIEW ================= */
class EmployeeProfileView extends StatelessWidget {
  final String employeeName;
  final int employeeId;

  const EmployeeProfileView({
    super.key,
    required this.employeeName,
    required this.employeeId,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.paddingLarge),
      child: Column(
        children: [
          /// Profile Header
          Container(
            padding: const EdgeInsets.all(AppTheme.paddingLarge),
            decoration: AppTheme.sectionDecoration(),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: AppTheme.primaryColor.withOpacity(0.2),
                  child: Icon(
                    Icons.person,
                    size: 60,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(height: AppTheme.spacingLarge),
                Text(
                  employeeName,
                  style: AppTheme.headingMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppTheme.spacingSmall),
                Text(
                  "Employee #$employeeId",
                  style: AppTheme.subtitle,
                ),
              ],
            ),
          ),

          const SizedBox(height: AppTheme.spacingXLarge),

          /// Profile Details
          Container(
            padding: const EdgeInsets.all(AppTheme.paddingLarge),
            decoration: AppTheme.sectionDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Profile Information",
                  style: AppTheme.headingSmall,
                ),
                const SizedBox(height: AppTheme.spacingLarge),
                _infoRow("Email", "employee$employeeId@seaps.com"),
                _infoRow("Department", "Operations"),
                _infoRow("Position", "Staff"),
                _infoRow("Joined", "January 15, 2024"),
              ],
            ),
          ),

          const SizedBox(height: AppTheme.spacingXLarge),

          /// Logout Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => Navigator.of(context).pushReplacementNamed('/'),
              icon: const Icon(Icons.logout),
              label: const Text("Logout"),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.statusRed,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  vertical: AppTheme.paddingMedium,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacingMedium),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTheme.bodySmall),
          Text(
            value,
            style: AppTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}
