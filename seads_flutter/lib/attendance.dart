import 'package:flutter/material.dart';
import 'api_service.dart';
import 'theme.dart';


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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
      color: AppTheme.backgroundColor,
      padding: const EdgeInsets.all(AppTheme.paddingXLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// PAGE HEADER
          const PageHeader(
            title: "Attendance Monitoring",
            subtitle: "Track and manage employee attendance records",
          ),

          const SizedBox(height: AppTheme.spacingLarge),

          /// FILTER CONTAINER
          Container(
            padding: const EdgeInsets.all(AppTheme.paddingMedium),
            decoration: AppTheme.sectionDecoration(),
            child: Wrap(
              spacing: AppTheme.spacingLarge,
              runSpacing: AppTheme.spacingMedium,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                /// DATE PICKER
                SizedBox(
                  width: 200,
                  child: TextField(
                    readOnly: true,
                    controller: dateController..text = selectedDate,
                    decoration: AppTheme.getInputDecoration("Date"),
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

                /// STATUS DROPDOWN
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.paddingMedium,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: DropdownButton<String>(
                    value: statusFilter,
                    underline: const SizedBox(),
                    items: const [
                      DropdownMenuItem(value: "All", child: Text("All Status")),
                      DropdownMenuItem(value: "Present", child: Text("Present")),
                      DropdownMenuItem(value: "Late", child: Text("Late")),
                      DropdownMenuItem(value: "Absent", child: Text("Absent")),
                    ],
                    onChanged: (v) {
                      if (v != null) setState(() => statusFilter = v);
                    },
                  ),
                ),

                const Spacer(),

                ElevatedButton.icon(
                  onPressed: loadAttendance,
                  icon: const Icon(Icons.refresh),
                  label: const Text("Refresh"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.paddingLarge,
                      vertical: AppTheme.paddingMedium,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppTheme.spacingLarge),

          /// TABLE
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(AppTheme.paddingMedium),
              decoration: AppTheme.sectionDecoration(),
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
                                  WidgetStateProperty.all(Colors.grey.shade100),
                              columnSpacing: AppTheme.spacingLarge,
                              horizontalMargin: AppTheme.paddingMedium,
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
                                    StatusBadge(status: status),
                                  ),
                                  DataCell(
                                    ElevatedButton(
                                      onPressed: () => showDetails(a),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppTheme.primaryColor,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: AppTheme.paddingMedium,
                                          vertical: AppTheme.paddingSmall,
                                        ),
                                      ),
                                      child: const Text("Details"),
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
