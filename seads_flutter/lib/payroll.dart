import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'api_service.dart';
import 'theme.dart';


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
        const PageHeader(
          title: "Payroll Overview",
          subtitle: "Manage and track employee salary disbursement",
        ),

        const SizedBox(height: AppTheme.spacingLarge),

        /// SUMMARY CARDS
        Wrap(
          spacing: AppTheme.spacingLarge,
          runSpacing: AppTheme.spacingMedium,
          children: [
            SummaryCard(
              title: "Total Paid",
              value: totalPaid.toString(),
              icon: Icons.people,
              iconColor: AppTheme.statusGreen,
            ),
            SummaryCard(
              title: "Pending Amount",
              value: currencyFormatter.format(pendingAmount),
              icon: Icons.hourglass_bottom,
              iconColor: AppTheme.statusOrange,
            ),
          ],
        ),

        const SizedBox(height: AppTheme.spacingLarge),

        /// FILTER CONTAINER
        Container(
          padding: const EdgeInsets.all(AppTheme.paddingMedium),
          decoration: AppTheme.sectionDecoration(),
          child: Wrap(
            spacing: AppTheme.spacingMedium,
            runSpacing: AppTheme.spacingMedium,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              /// From Date
              SizedBox(
                width: 160,
                child: TextField(
                  controller: TextEditingController(text: fromDate),
                  readOnly: true,
                  decoration: AppTheme.getInputDecoration("From"),
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
                width: 160,
                child: TextField(
                  controller: TextEditingController(text: toDate),
                  readOnly: true,
                  decoration: AppTheme.getInputDecoration("To"),
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
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.paddingLarge,
                    vertical: AppTheme.paddingMedium,
                  ),
                ),
                child: const Text("Apply"),
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
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.primaryColor,
                  side: const BorderSide(color: AppTheme.primaryColor),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.paddingLarge,
                    vertical: AppTheme.paddingMedium,
                  ),
                ),
                child: const Text("Reset"),
              ),
            ],
          ),
        ),

        const SizedBox(height: AppTheme.spacingMedium),

        /// SEARCH BAR + STATUS FILTER
        Wrap(
          spacing: AppTheme.spacingMedium,
          runSpacing: AppTheme.spacingMedium,
          children: [
            SizedBox(
              width: 300,
              child: TextField(
                decoration: AppTheme.getInputDecoration("Search Employee").copyWith(
                  prefixIcon: const Icon(Icons.search),
                ),
                onChanged: (v) {
                  setState(() => searchQuery = v);
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.paddingMedium,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
                border: Border.all(color: Colors.grey.shade300),
                boxShadow: AppTheme.cardShadow,
              ),
              child: DropdownButton<String>(
                value: statusFilter,
                underline: const SizedBox(),
                items: const [
                  DropdownMenuItem(value: "All", child: Text("All Status")),
                  DropdownMenuItem(value: "Paid", child: Text("Paid")),
                  DropdownMenuItem(value: "Unpaid", child: Text("Unpaid")),
                ],
                onChanged: (v) {
                  if (v != null) setState(() => statusFilter = v);
                },
              ),
            ),
          ],
        ),

        const SizedBox(height: AppTheme.spacingLarge),

        /// PAYROLL TABLE
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(AppTheme.paddingMedium),
            decoration: AppTheme.sectionDecoration(),
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingRowColor:
                          WidgetStateProperty.all(Colors.grey.shade100),
                      columnSpacing: AppTheme.spacingLarge,
                      horizontalMargin: AppTheme.paddingMedium,
                      columns: const [
                        DataColumn(label: Text("Name")),
                        DataColumn(label: Text("Period")),
                        DataColumn(label: Text("Salary")),
                        DataColumn(label: Text("Deduction")),
                        DataColumn(label: Text("Status")),
                      ],
                      rows: filteredPayrolls.map((p) {
                        final status = displayStatus(p['status'] ?? "Pending");
                        return DataRow(cells: [
                          DataCell(
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 16,
                                  backgroundColor: AppTheme.primaryColor.withAlpha(26),
                                  child: Icon(Icons.person, size: 16, color: AppTheme.primaryColor),
                                ),
                                const SizedBox(width: AppTheme.spacingMedium),
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

                                setState(() {
                                  p['status'] = newStatus;
                                });

                                try {
                                  await ApiService.updatePayrollStatus(
                                      p['id'], newStatus);
                                } catch (e) {
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              "Failed to update payroll status")),
                                    );
                                  }
                                }
                              },
                            ),
                          ),
                        ]);
                      }).toList(),
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}

class PayrollModule {
  // Currency formatter for Philippine Peso
  static final NumberFormat phpFormatter = NumberFormat.currency(locale: 'en_PH', symbol: '₱');

  // Compute work hours from attendance data
  // attendanceData: List of maps from attendance.dart
  static Map<String, double> computeWorkHours(List<Map<String, dynamic>> attendanceData) {
    Map<String, double> employeeHours = {};

    for (var record in attendanceData) {
      String employeeId = record['employee_id'] ?? '';
      double hours = double.tryParse(record['total_hours']?.toString() ?? '0') ?? 0.0;

      if (employeeId.isNotEmpty) {
        employeeHours[employeeId] = (employeeHours[employeeId] ?? 0) + hours;
      }
    }

    return employeeHours;
  }

  // Compute work days (assuming 8 hours per day)
  static Map<String, double> computeWorkDays(List<Map<String, dynamic>> attendanceData) {
    Map<String, double> employeeDays = {};

    for (var record in attendanceData) {
      String employeeId = record['employee_id'] ?? '';
      double hours = double.tryParse(record['total_hours']?.toString() ?? '0') ?? 0.0;
      double days = hours / 8.0; // Assuming 8 hours per day

      if (employeeId.isNotEmpty) {
        employeeDays[employeeId] = (employeeDays[employeeId] ?? 0) + days;
      }
    }

    return employeeDays;
  }

  // Placeholder for SSS deduction
  static double computeSSSDeduction(double monthlySalary) {
    // Placeholder formula: 8% of salary
    return monthlySalary * 0.08;
  }

  // Placeholder for Philhealth deduction
  
  static double computePhilhealthDeduction(double monthlySalary) {
    // Placeholder of salary
    
    return monthlySalary * 0.02;
  }

  // Total deductions placeholder
  static double computeTotalDeductions(double monthlySalary) {
    double sss = computeSSSDeduction(monthlySalary);
    double philhealth = computePhilhealthDeduction(monthlySalary);
    // Add other deductions here, like Pag-IBIG, tax, etc.
    return sss + philhealth;
  }

  // Net salary computation
  static double computeNetSalary(double grossSalary) {
    double deductions = computeTotalDeductions(grossSalary);
    return grossSalary - deductions;
  }

  // Format amount in PHP
  static String formatPHP(double amount) {
    return phpFormatter.format(amount);
  }

  // Example integration function
  // This can be called from attendance or dashboard
  // salaries: Map of employee_id to monthly salary
  static Map<String, dynamic> generatePayrollReport(
      List<Map<String, dynamic>> attendanceData, Map<String, double> salaries) {
    Map<String, double> workHours = computeWorkHours(attendanceData);
    Map<String, double> workDays = computeWorkDays(attendanceData);

    Map<String, dynamic> report = {};

    for (var employeeId in salaries.keys) {
      double salary = salaries[employeeId] ?? 0.0;
      double hours = workHours[employeeId] ?? 0.0;
      double days = workDays[employeeId] ?? 0.0;
      double netSalary = computeNetSalary(salary);

      report[employeeId] = {
        'workHours': hours,
        'workDays': days,
        'grossSalary': salary,
        'netSalary': netSalary,
        'deductions': computeTotalDeductions(salary),
        'formattedNetSalary': formatPHP(netSalary),
      };
    }

    return report;
  }
}
