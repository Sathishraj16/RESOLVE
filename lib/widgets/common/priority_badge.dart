import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../models/complaint_model.dart';

class PriorityBadge extends StatelessWidget {
  final ComplaintPriority priority;

  const PriorityBadge({super.key, required this.priority});

  Color _getColor() {
    switch (priority) {
      case ComplaintPriority.low:
        return AppTheme.lowPriority;
      case ComplaintPriority.medium:
        return AppTheme.mediumPriority;
      case ComplaintPriority.high:
        return AppTheme.highPriority;
      case ComplaintPriority.critical:
        return AppTheme.criticalPriority;
    }
  }

  String _getText() {
    switch (priority) {
      case ComplaintPriority.low:
        return 'Low';
      case ComplaintPriority.medium:
        return 'Medium';
      case ComplaintPriority.high:
        return 'High';
      case ComplaintPriority.critical:
        return 'Critical';
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColor();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        _getText(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}