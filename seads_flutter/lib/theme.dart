import 'package:flutter/material.dart';

class AppTheme {
  // Colors
  static const Color primaryColor = Colors.deepPurple;
  static const Color backgroundColor = Color(0xFFF4F6FA);
  static const Color cardColor = Colors.white;
  static const Color textPrimary = Colors.black87;
  static const Color textSecondary = Colors.grey;
  
  // Status colors
  static const Color statusGreen = Colors.green;
  static const Color statusOrange = Colors.orange;
  static const Color statusRed = Colors.red;
  
  // Spacing
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingXLarge = 32.0;
  
  static const double spacingSmall = 8.0;
  static const double spacingMedium = 12.0;
  static const double spacingLarge = 16.0;
  static const double spacingXLarge = 24.0;
  
  // Border radius
  static const double borderRadiusMedium = 12.0;
  static const double borderRadiusLarge = 16.0;
  static const double borderRadiusXLarge = 20.0;
  
  // Typography
  static const TextStyle headingLarge = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: textPrimary,
  );
  
  static const TextStyle headingMedium = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: textPrimary,
  );
  
  static const TextStyle headingSmall = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: textPrimary,
  );
  
  static const TextStyle subtitle = TextStyle(
    fontSize: 14,
    color: textSecondary,
  );
  
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    color: textPrimary,
  );
  
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    color: textPrimary,
  );
  
  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    color: textSecondary,
  );
  
  // Shadow
  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Color(0x0A000000),
      blurRadius: 12,
      spreadRadius: 0,
    ),
  ];
  
  // Input decoration
  static InputDecoration getInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadiusMedium),
        borderSide: const BorderSide(color: Colors.grey),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadiusMedium),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadiusMedium),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      filled: true,
      fillColor: Colors.grey.shade50,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: paddingMedium,
        vertical: paddingMedium,
      ),
    );
  }
  
  // Card decoration
  static BoxDecoration cardDecoration() {
    return BoxDecoration(
      color: cardColor,
      borderRadius: BorderRadius.circular(borderRadiusLarge),
      boxShadow: cardShadow,
    );
  }
  
  // Container decoration for sections
  static BoxDecoration sectionDecoration() {
    return BoxDecoration(
      color: cardColor,
      borderRadius: BorderRadius.circular(borderRadiusLarge),
      boxShadow: cardShadow,
    );
  }
}

// Status badge widget
class StatusBadge extends StatelessWidget {
  final String status;
  final Color? backgroundColor;
  final Color? textColor;
  
  const StatusBadge({
    super.key,
    required this.status,
    this.backgroundColor,
    this.textColor,
  });
  
  Color _getBackgroundColor(String status) {
    switch (status.toLowerCase()) {
      case 'present':
        return AppTheme.statusGreen.withAlpha(26);
      case 'late':
        return AppTheme.statusOrange.withAlpha(26);
      case 'absent':
        return AppTheme.statusRed.withAlpha(26);
      case 'paid':
      case 'approved':
        return AppTheme.statusGreen.withAlpha(26);
      case 'unpaid':
      case 'pending':
        return AppTheme.statusOrange.withAlpha(26);
      case 'rejected':
        return AppTheme.statusRed.withAlpha(26);
      default:
        return Colors.grey.withAlpha(26);
    }
  }
  
  Color _getTextColor(String status) {
    switch (status.toLowerCase()) {
      case 'present':
        return AppTheme.statusGreen;
      case 'late':
        return AppTheme.statusOrange;
      case 'absent':
        return AppTheme.statusRed;
      case 'paid':
      case 'approved':
        return AppTheme.statusGreen;
      case 'unpaid':
      case 'pending':
        return AppTheme.statusOrange;
      case 'rejected':
        return AppTheme.statusRed;
      default:
        return Colors.grey;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.paddingMedium,
        vertical: AppTheme.paddingSmall,
      ),
      decoration: BoxDecoration(
        color: backgroundColor ?? _getBackgroundColor(status),
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusXLarge),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: textColor ?? _getTextColor(status),
          fontWeight: FontWeight.w500,
          fontSize: 13,
        ),
      ),
    );
  }
}

// Summary card widget
class SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color? iconColor;
  final Color? backgroundColor;
  
  const SummaryCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.iconColor,
    this.backgroundColor,
  });
  
  @override
  Widget build(BuildContext context) {
    final Color finalIconColor = iconColor ?? AppTheme.primaryColor;
    
    return Container(
      width: 280,
      padding: const EdgeInsets.all(AppTheme.paddingLarge),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: finalIconColor.withAlpha(38),
            child: Icon(icon, color: finalIconColor, size: 28),
          ),
          const SizedBox(width: AppTheme.spacingLarge),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTheme.subtitle),
                const SizedBox(height: AppTheme.spacingSmall),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Page header widget
class PageHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  
  const PageHeader({
    super.key,
    required this.title,
    this.subtitle,
  });
  
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTheme.headingLarge),
        if (subtitle != null) ...[
          const SizedBox(height: AppTheme.spacingSmall),
          Text(subtitle!, style: AppTheme.subtitle),
        ],
      ],
    );
  }
}
