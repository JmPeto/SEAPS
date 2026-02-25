import 'package:flutter/material.dart';
import 'api_service.dart';
import 'theme.dart';


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
        const PageHeader(
          title: "Employees",
          subtitle: "Manage and view employee information",
        ),

        const SizedBox(height: AppTheme.spacingLarge),

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

        const SizedBox(height: AppTheme.spacingMedium),

        /// -------------------- CONTROLS ROW (Add/Search/Clear) --------------------
        Wrap(
          spacing: AppTheme.spacingMedium,
          runSpacing: AppTheme.spacingMedium,
          children: [
            ElevatedButton.icon(
              onPressed: widget.onAdd,
              icon: const Icon(Icons.add),
              label: const Text("New Employee"),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.paddingLarge,
                  vertical: AppTheme.paddingMedium,
                ),
              ),
            ),
            SizedBox(
              width: 250,
              child: TextField(
                controller: searchController,
                onChanged: widget.onSearch,
                decoration: AppTheme.getInputDecoration("Search Employee").copyWith(
                  prefixIcon: const Icon(Icons.search),
                ),
              ),
            ),
            OutlinedButton(
              onPressed: () {
                searchController.clear();
                widget.onSearch("");
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.primaryColor,
                side: const BorderSide(color: AppTheme.primaryColor),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.paddingLarge,
                  vertical: AppTheme.paddingMedium,
                ),
              ),
              child: const Text("Clear"),
            ),
          ],
        ),

        const SizedBox(height: AppTheme.spacingLarge),

        /// -------------------- EMPLOYEES TABLE --------------------
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(AppTheme.paddingMedium),
            decoration: AppTheme.sectionDecoration(),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: MediaQuery.of(context).size.width - AppTheme.paddingXLarge * 2,
                child: DataTable(
                  columnSpacing: AppTheme.spacingLarge,
                  horizontalMargin: AppTheme.paddingMedium,
                  headingRowColor: WidgetStateProperty.all(Colors.grey.shade100),
                  columns: const [
                    DataColumn(label: Text("ID")),
                    DataColumn(label: Text("Name")),
                    DataColumn(label: Text("Email")),
                    DataColumn(label: Text("Role")),
                    DataColumn(label: Text("Salary/Day")),
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
                              color: AppTheme.primaryColor,
                              onPressed: () => widget.onEdit(e),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, size: 18),
                              color: AppTheme.statusRed,
                              onPressed: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                    title: const Text("Confirm Delete"),
                                    content: Text("Are you sure you want to delete ${e['name']}?"),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context, false),
                                        child: const Text("Cancel"),
                                      ),
                                      TextButton(
                                        onPressed: () => Navigator.pop(context, true),
                                        child: const Text("Delete", style: TextStyle(color: AppTheme.statusRed)),
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

    if (!mounted) return;
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
      ),
      content: Form(
        key: _formKey,
        child: SizedBox(
          width: 350,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: AppTheme.getInputDecoration("Name"),
              ),
              const SizedBox(height: AppTheme.spacingMedium),
              TextField(
                controller: emailController,
                decoration: AppTheme.getInputDecoration("Email"),
              ),
              const SizedBox(height: AppTheme.spacingMedium),
              DropdownButtonFormField<String>(
                initialValue: selectedRole,
                items: roles
                    .map((role) =>
                        DropdownMenuItem(value: role, child: Text(role)))
                    .toList(),
                onChanged: (v) => setState(() => selectedRole = v!),
                decoration: AppTheme.getInputDecoration("Role"),
              ),
              const SizedBox(height: AppTheme.spacingMedium),
              TextField(
                controller: salaryController,
                decoration: AppTheme.getInputDecoration("Salary per Day"),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: AppTheme.spacingLarge),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: AppTheme.paddingMedium,
                    ),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        )
                      : const Text("Add Employee"),
                ),
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

    if (!mounted) return;
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
      ),
      content: Form(
        key: _formKey,
        child: SizedBox(
          width: 350,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: AppTheme.getInputDecoration("Name"),
              ),
              const SizedBox(height: AppTheme.spacingMedium),
              TextField(
                controller: emailController,
                decoration: AppTheme.getInputDecoration("Email"),
              ),
              const SizedBox(height: AppTheme.spacingMedium),
              DropdownButtonFormField<String>(
                initialValue: selectedRole,
                items: roles
                    .map((role) =>
                        DropdownMenuItem(value: role, child: Text(role)))
                    .toList(),
                onChanged: (v) => setState(() => selectedRole = v!),
                decoration: AppTheme.getInputDecoration("Role"),
              ),
              const SizedBox(height: AppTheme.spacingMedium),
              TextField(
                controller: salaryController,
                decoration: AppTheme.getInputDecoration("Salary per Day"),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: AppTheme.spacingLarge),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: AppTheme.paddingMedium,
                    ),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        )
                      : const Text("Update Employee"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
