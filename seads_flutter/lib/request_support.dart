import 'package:flutter/material.dart';
import 'api_service.dart';
import 'theme.dart';


class RequestSupportView extends StatefulWidget {
  const RequestSupportView({super.key});

  @override
  State<RequestSupportView> createState() => _RequestSupportViewState();
}

class _RequestSupportViewState extends State<RequestSupportView> {
  List<Map<String, dynamic>> supportRequests = [];
  String statusFilter = "All";
  String searchQuery = "";
  bool isLoading = true;

  final TextEditingController requestTypeController = TextEditingController();
  final TextEditingController messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchSupportRequests();
  }

  @override
  void dispose() {
    requestTypeController.dispose();
    messageController.dispose();
    super.dispose();
  }

  Future<void> fetchSupportRequests() async {
    setState(() => isLoading = true);
    final requests = await ApiService.fetchAllSupportRequests();
    setState(() {
      supportRequests = requests;
      isLoading = false;
    });
  }

  String displayStatus(String status) {
    switch (status.toUpperCase()) {
      case "PENDING":
        return "Pending";
      case "APPROVED":
        return "Approved";
      case "REJECTED":
        return "Rejected";
      default:
        return status;
    }
  }

  Color statusColor(String status) {
    switch (status.toUpperCase()) {
      case "PENDING":
        return Colors.orange;
      case "APPROVED":
        return Colors.green;
      case "REJECTED":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void showCreateRequestDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Create C.A Request"),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
        ),
        content: SingleChildScrollView(
          child: SizedBox(
            width: 350,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: requestTypeController,
                  decoration: AppTheme.getInputDecoration("Request Type"),
                ),
                const SizedBox(height: AppTheme.spacingMedium),
                TextField(
                  controller: messageController,
                  decoration: AppTheme.getInputDecoration("Message"),
                  maxLines: 4,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              if (requestTypeController.text.isEmpty ||
                  messageController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text("Please fill in all fields")),
                );
                return;
              }

              final success = await ApiService.createSupportRequest(
                1,
                requestTypeController.text,
                messageController.text,
              );

              final ctx = context;
              if (!mounted) return;

              if (success) {
                requestTypeController.clear();
                messageController.clear();
                Navigator.pop(ctx);
                await fetchSupportRequests();
                ScaffoldMessenger.of(ctx).showSnackBar(
                  const SnackBar(
                      content: Text("C.A request created successfully")),
                );
              } else {
                ScaffoldMessenger.of(ctx).showSnackBar(
                  const SnackBar(
                      content: Text("Failed to create C.A request")),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
            ),
            child: const Text("Submit"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredRequests = supportRequests.where((req) {
      final statusMatch = statusFilter == "All"
          ? true
          : displayStatus(req['status'] ?? "PENDING") == statusFilter;
      final searchMatch = (req['request_type'] ?? "")
          .toString()
          .toLowerCase()
          .contains(searchQuery.toLowerCase());
      return statusMatch && searchMatch;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PageHeader(
          title: "Request C.A",
          subtitle: "Manage employee leave and approval requests",
        ),

        const SizedBox(height: AppTheme.spacingLarge),

        /// Summary Cards
        Wrap(
          spacing: AppTheme.spacingLarge,
          runSpacing: AppTheme.spacingMedium,
          children: [
            SummaryCard(
              title: "Total Requests",
              value: supportRequests.length.toString(),
              icon: Icons.mail,
            ),
            SummaryCard(
              title: "Pending",
              value: supportRequests
                  .where((r) => r['status'] == "PENDING")
                  .length
                  .toString(),
              icon: Icons.hourglass_bottom,
              iconColor: AppTheme.statusOrange,
            ),
            SummaryCard(
              title: "Approved",
              value: supportRequests
                  .where((r) => r['status'] == "APPROVED")
                  .length
                  .toString(),
              icon: Icons.check_circle,
              iconColor: AppTheme.statusGreen,
            ),
            SummaryCard(
              title: "Rejected",
              value: supportRequests
                  .where((r) => r['status'] == "REJECTED")
                  .length
                  .toString(),
              icon: Icons.cancel,
              iconColor: AppTheme.statusRed,
            ),
          ],
        ),

        const SizedBox(height: AppTheme.spacingLarge),

        /// Filter and Search
        Wrap(
          spacing: AppTheme.spacingMedium,
          runSpacing: AppTheme.spacingMedium,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
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
                  DropdownMenuItem(value: "Pending", child: Text("Pending")),
                  DropdownMenuItem(value: "Approved", child: Text("Approved")),
                  DropdownMenuItem(value: "Rejected", child: Text("Rejected")),
                ],
                onChanged: (v) {
                  if (v != null) setState(() => statusFilter = v);
                },
              ),
            ),
            SizedBox(
              width: 280,
              child: TextField(
                decoration: AppTheme.getInputDecoration("Search requests").copyWith(
                  prefixIcon: const Icon(Icons.search),
                ),
                onChanged: (v) {
                  setState(() => searchQuery = v);
                },
              ),
            ),
          ],
        ),


        /// Requests List
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(AppTheme.paddingMedium),
            decoration: AppTheme.sectionDecoration(),
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredRequests.isEmpty
                    ? Center(
                        child: Text(
                          "No C.A requests found",
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      )
                    : ListView.builder(
                        itemCount: filteredRequests.length,
                        itemBuilder: (context, index) {
                          final req = filteredRequests[index];
                          final status =
                              displayStatus(req['status'] ?? "PENDING");
                          return Container(
                            margin: const EdgeInsets.only(
                              bottom: AppTheme.spacingMedium,
                            ),
                            padding: const EdgeInsets.all(AppTheme.paddingMedium),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(
                                AppTheme.borderRadiusMedium,
                              ),
                              border: Border.all(
                                color: Colors.grey.shade200,
                              ),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 24,
                                  backgroundColor: statusColor(
                                    req['status'] ?? "PENDING",
                                  ).withAlpha(26),
                                  child: Icon(
                                    req['status'] == "APPROVED"
                                        ? Icons.check
                                        : req['status'] == "REJECTED"
                                            ? Icons.close
                                            : Icons.schedule,
                                    color: statusColor(
                                      req['status'] ?? "PENDING",
                                    ),
                                  ),
                                ),
                                const SizedBox(width: AppTheme.spacingLarge),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        req['type'] ?? "C.A Request",
                                        style: AppTheme.subtitle,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "Employee: ${req['employeeName'] ?? 'N/A'}",
                                        style: AppTheme.bodySmall.copyWith(
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "Duration: ${req['duration']} days",
                                        style: AppTheme.bodySmall.copyWith(
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: AppTheme.spacingLarge),
                                StatusBadge(status: status),
                              ],
                            ),
                          );
                        },
                      ),
          ),
        ),
      ],
    );
  }
}