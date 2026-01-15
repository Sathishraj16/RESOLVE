import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../core/theme/app_theme.dart';
import '../../models/complaint_model.dart';
import 'priority_badge.dart';
import 'severity_badge.dart';

class ComplaintCard extends StatelessWidget {
  final Complaint complaint;
  final VoidCallback onTap;

  const ComplaintCard({
    super.key,
    required this.complaint,
    required this.onTap,
  });

  Color _getStatusColor() {
    switch (complaint.status) {
      case ComplaintStatus.submitted:
        return AppTheme.receivedStatus;
      case ComplaintStatus.received:
        return AppTheme.receivedStatus;
      case ComplaintStatus.verified:
        return AppTheme.verifiedStatus;
      case ComplaintStatus.assigned:
        return AppTheme.assignedStatus;
      case ComplaintStatus.inProgress:
        return AppTheme.inProgressStatus;
      case ComplaintStatus.resolved:
        return AppTheme.resolvedStatus;
      case ComplaintStatus.rejected:
        return AppTheme.errorColor;
    }
  }

  String _getStatusText() {
    switch (complaint.status) {
      case ComplaintStatus.submitted:
        return 'Submitted';
      case ComplaintStatus.received:
        return 'Received';
      case ComplaintStatus.verified:
        return 'Verified';
      case ComplaintStatus.assigned:
        return 'Assigned';
      case ComplaintStatus.inProgress:
        return 'In Progress';
      case ComplaintStatus.resolved:
        return 'Resolved';
      case ComplaintStatus.rejected:
        return 'Rejected';
    }
  }

  IconData _getCategoryIcon() {
    switch (complaint.category) {
      case ComplaintCategory.streetlight:
        return Icons.lightbulb;
      case ComplaintCategory.roadDamage:
        return Icons.construction;
      case ComplaintCategory.drainage:
        return Icons.water_drop;
      case ComplaintCategory.garbageCollection:
        return Icons.delete;
      case ComplaintCategory.trafficSignal:
        return Icons.traffic;
      case ComplaintCategory.illegalParking:
        return Icons.local_parking;
      case ComplaintCategory.waterSupply:
        return Icons.water;
      case ComplaintCategory.publicProperty:
        return Icons.business;
      case ComplaintCategory.other:
        return Icons.report_problem;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor();

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  // Category Icon
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.lightOrange,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getCategoryIcon(),
                      color: AppTheme.primaryOrange,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Title and ID
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          complaint.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '#${complaint.id.toUpperCase()}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Priority and Severity Badges
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      PriorityBadge(priority: complaint.priority),
                      if (complaint.aiSeverity != null) ...[
                        const SizedBox(height: 6),
                        SeverityBadge(severity: complaint.aiSeverity!, showLabel: false),
                      ],
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Status Progress Bar (Swiggy-style)
              Container(
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.dividerColor,
                  borderRadius: BorderRadius.circular(2),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: _getProgressFactor(),
                  child: Container(
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Status Row
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: statusColor.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getStatusIcon(),
                          size: 14,
                          color: statusColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _getStatusText(),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: statusColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  // Time ago
                  Text(
                    timeago.format(complaint.createdAt),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Location
              Row(
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    size: 16,
                    color: AppTheme.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      complaint.address,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              // ETA (if available)
              if (complaint.estimatedResolutionTime != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppTheme.lightOrange,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.schedule,
                        size: 16,
                        color: AppTheme.darkOrange,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'ETA: ${_formatETA(complaint.estimatedResolutionTime!)}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.darkOrange,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  IconData _getStatusIcon() {
    switch (complaint.status) {
      case ComplaintStatus.submitted:
        return Icons.send;
      case ComplaintStatus.received:
        return Icons.inbox;
      case ComplaintStatus.verified:
        return Icons.verified;
      case ComplaintStatus.assigned:
        return Icons.person;
      case ComplaintStatus.inProgress:
        return Icons.construction;
      case ComplaintStatus.resolved:
        return Icons.check_circle;
      case ComplaintStatus.rejected:
        return Icons.cancel;
    }
  }

  double _getProgressFactor() {
    switch (complaint.status) {
      case ComplaintStatus.submitted:
        return 0.1;
      case ComplaintStatus.received:
        return 0.2;
      case ComplaintStatus.verified:
        return 0.4;
      case ComplaintStatus.assigned:
        return 0.6;
      case ComplaintStatus.inProgress:
        return 0.8;
      case ComplaintStatus.resolved:
        return 1.0;
      case ComplaintStatus.rejected:
        return 0.0;
    }
  }

  String _formatETA(DateTime eta) {
    final now = DateTime.now();
    final difference = eta.difference(now);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''}';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''}';
    } else {
      return 'Soon';
    }
  }
}