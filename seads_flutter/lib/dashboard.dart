import 'package:flutter/material.dart';
import 'api_service.dart';
import 'theme.dart';


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
      color: AppTheme.backgroundColor,
      padding: const EdgeInsets.all(AppTheme.paddingXLarge),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// WELCOME TEXT
            Text(
              "Welcome, Admin!",
              style: AppTheme.headingMedium.copyWith(
                color: AppTheme.primaryColor,
              ),
            ),

            const SizedBox(height: AppTheme.spacingXLarge),

            /// PAGE HEADER
            const PageHeader(
              title: "Dashboard Overview",
              subtitle: "Monitor employee attendance and recent activities",
            ),

            const SizedBox(height: AppTheme.spacingXLarge),

            /// STAT CARDS
            Wrap(
              spacing: AppTheme.spacingXLarge,
              runSpacing: AppTheme.spacingXLarge,
              children: [
                SummaryCard(
                  title: "Total Employees",
                  value: employeeCount.toString(),
                  icon: Icons.people,
                  iconColor: AppTheme.primaryColor,
                ),
                SummaryCard(
                  title: "Pending C.A Requests",
                  value: presentCount.toString(),
                  icon: Icons.alarm,
                  iconColor: AppTheme.statusOrange,
                ),
              ],
            ),

            const SizedBox(height: AppTheme.spacingXLarge),

            /// RECENT ACTIVITY
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppTheme.paddingLarge),
              decoration: AppTheme.sectionDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Recent Activity",
                    style: AppTheme.headingSmall,
                  ),

                  const SizedBox(height: AppTheme.spacingSmall),

                  const Text(
                    "Latest employee actions and attendance logs",
                    style: AppTheme.subtitle,
                  ),

                  const SizedBox(height: AppTheme.spacingLarge),

                  isLoadingAttendance
                      ? const Center(child: CircularProgressIndicator())
                      : SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            headingRowColor:
                                WidgetStateProperty.all(Colors.grey.shade100),
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
                                          AppTheme.statusGreen.withAlpha(26),
                                    ),
                                  ),
                                  DataCell(Text(a['datetime'] ?? "")),
                                  DataCell(
                                    StatusBadge(
                                      status:
                                          a['status'] ?? "Completed",
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
