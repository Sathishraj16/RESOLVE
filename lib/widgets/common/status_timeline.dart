import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../core/theme/app_theme.dart';
import '../../models/complaint_model.dart';

class StatusTimeline extends StatelessWidget {
  final List<StatusUpdate> statusHistory;

  const StatusTimeline({super.key, required this.statusHistory});

  Color _getStatusColor(ComplaintStatus status) {
    switch (status) {
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

  String _getStatusLabel(ComplaintStatus status) {
    switch (status) {
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

  IconData _getStatusIcon(ComplaintStatus status) {
    switch (status) {
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

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: statusHistory.length,
      itemBuilder: (context, index) {
        final update = statusHistory[index];
        final isLast = index == statusHistory.length - 1;
        final statusColor = _getStatusColor(update.status);

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Timeline indicator
              Column(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                      border: Border.all(color: statusColor, width: 2),
                    ),
                    child: Icon(
                      _getStatusIcon(update.status),
                      size: 20,
                      color: statusColor,
                    ),
                  ),
                  if (!isLast)
                    Expanded(
                      child: Container(
                        width: 2,
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        color: AppTheme.dividerColor,
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 16),
              // Content
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(bottom: isLast ? 0 : 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getStatusLabel(update.status),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: statusColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (update.note != null)
                        Text(
                          update.note!,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      const SizedBox(height: 4),
                      Text(
                        timeago.format(update.timestamp),
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      if (update.updatedBy != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.person_outline,
                              size: 14,
                              color: AppTheme.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              update.updatedBy!,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}