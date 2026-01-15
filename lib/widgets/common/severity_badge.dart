import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class SeverityBadge extends StatelessWidget {
  final int severity;
  final bool showLabel;

  const SeverityBadge({
    super.key,
    required this.severity,
    this.showLabel = true,
  });

  Color _getSeverityColor() {
    switch (severity) {
      case 1:
        return Colors.blue;
      case 2:
        return Colors.green;
      case 3:
        return Colors.orange;
      case 4:
        return Colors.deepOrange;
      case 5:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getSeverityLabel() {
    switch (severity) {
      case 1:
        return 'Minor';
      case 2:
        return 'Moderate';
      case 3:
        return 'Significant';
      case 4:
        return 'Serious';
      case 5:
        return 'Critical';
      default:
        return 'Unknown';
    }
  }

  IconData _getSeverityIcon() {
    switch (severity) {
      case 1:
        return Icons.info_outline;
      case 2:
        return Icons.warning_amber_outlined;
      case 3:
        return Icons.error_outline;
      case 4:
        return Icons.priority_high;
      case 5:
        return Icons.emergency;
      default:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getSeverityColor();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_getSeverityIcon(), size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            showLabel ? _getSeverityLabel() : 'L$severity',
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

/// Large version for detail screens
class SeverityBadgeLarge extends StatelessWidget {
  final int severity;
  final String? reason;

  const SeverityBadgeLarge({
    super.key,
    required this.severity,
    this.reason,
  });

  Color _getSeverityColor() {
    switch (severity) {
      case 1:
        return Colors.blue;
      case 2:
        return Colors.green;
      case 3:
        return Colors.orange;
      case 4:
        return Colors.deepOrange;
      case 5:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getSeverityLabel() {
    switch (severity) {
      case 1:
        return 'Level 1 - Minor Issue';
      case 2:
        return 'Level 2 - Moderate Issue';
      case 3:
        return 'Level 3 - Significant Issue';
      case 4:
        return 'Level 4 - Serious Issue';
      case 5:
        return 'Level 5 - Critical Emergency';
      default:
        return 'Unknown Severity';
    }
  }

  IconData _getSeverityIcon() {
    switch (severity) {
      case 1:
        return Icons.info_outline;
      case 2:
        return Icons.warning_amber_outlined;
      case 3:
        return Icons.error_outline;
      case 4:
        return Icons.priority_high;
      case 5:
        return Icons.emergency;
      default:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getSeverityColor();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
                child: Icon(_getSeverityIcon(), size: 20, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'AI Severity Assessment',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _getSeverityLabel(),
                      style: TextStyle(
                        color: color,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (reason != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.lightbulb_outline, size: 16, color: Colors.grey[700]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      reason!,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[800],
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
