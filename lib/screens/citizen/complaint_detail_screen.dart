import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../core/theme/app_theme.dart';
import '../../providers/complaint_provider.dart';
import '../../models/complaint_model.dart';
import '../../widgets/common/status_timeline.dart';
import '../../widgets/common/priority_badge.dart';
import '../../widgets/common/severity_badge.dart';

class ComplaintDetailScreen extends StatelessWidget {
  final String complaintId;

  const ComplaintDetailScreen({super.key, required this.complaintId});

  String _getAssignedDepartment(ComplaintCategory category) {
    switch (category) {
      case ComplaintCategory.roadDamage:
        return 'Public Works Department';
      case ComplaintCategory.streetlight:
        return 'Electricity Department';
      case ComplaintCategory.drainage:
        return 'Water & Sewage Department';
      case ComplaintCategory.garbageCollection:
        return 'Sanitation Department';
      case ComplaintCategory.trafficSignal:
        return 'Traffic Police';
      case ComplaintCategory.illegalParking:
        return 'Traffic Police';
      case ComplaintCategory.waterSupply:
        return 'Water Supply Department';
      case ComplaintCategory.publicProperty:
        return 'Municipal Corporation';
      case ComplaintCategory.other:
        return 'General Administration';
    }
  }

  double _getProgressPercentage(ComplaintStatus status) {
    switch (status) {
      case ComplaintStatus.submitted:
        return 0.2;
      case ComplaintStatus.received:
        return 0.4;
      case ComplaintStatus.verified:
        return 0.5;
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

  @override
  Widget build(BuildContext context) {
    final complaint = Provider.of<ComplaintProvider>(context).getComplaintById(complaintId);

    if (complaint == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Complaint Not Found')),
        body: const Center(child: Text('Complaint not found')),
      );
    }

    final department = _getAssignedDepartment(complaint.category);
    final progressPercentage = _getProgressPercentage(complaint.status);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Track Complaint'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image
            if (complaint.imageUrls.isNotEmpty)
              Container(
                height: 250,
                color: Colors.grey[200],
                child: Center(
                  child: Icon(Icons.image, size: 80, color: Colors.grey[400]),
                ),
              ),
            
            // Swiggy-style Progress Tracker
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          complaint.title,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      PriorityBadge(priority: complaint.priority),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'ID: #${complaint.id.length > 8 ? complaint.id.substring(0, 8).toUpperCase() : complaint.id.toUpperCase()}',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Progress Bar
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: progressPercentage,
                            backgroundColor: Colors.grey[200],
                            valueColor: AlwaysStoppedAnimation<Color>(
                              complaint.status == ComplaintStatus.resolved
                                  ? AppTheme.successColor
                                  : AppTheme.primaryOrange,
                            ),
                            minHeight: 8,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${(progressPercentage * 100).toInt()}%',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppTheme.primaryOrange,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getStatusMessage(complaint.status),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 8),
            
            // AI Severity Badge (if available)
            if (complaint.aiSeverity != null)
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(20.0),
                child: SeverityBadgeLarge(
                  severity: complaint.aiSeverity!,
                  reason: complaint.aiSeverityReason,
                ),
              ),
            
            const SizedBox(height: 8),
            
            // Step-by-Step Tracking (Swiggy Style)
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tracking Progress',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  _buildTrackingStep(
                    context,
                    'Complaint Registered',
                    'Your complaint has been received',
                    Icons.check_circle,
                    isCompleted: true,
                    isActive: complaint.status == ComplaintStatus.submitted,
                    time: timeago.format(complaint.createdAt),
                  ),
                  
                  _buildTrackingStep(
                    context,
                    'Verified',
                    'Complaint verified by admin',
                    Icons.verified,
                    isCompleted: complaint.status.index >= ComplaintStatus.verified.index,
                    isActive: complaint.status == ComplaintStatus.verified,
                    time: complaint.status.index >= ComplaintStatus.verified.index 
                        ? 'Verified' : 'Pending',
                  ),
                  
                  _buildTrackingStep(
                    context,
                    'Assigned to $department',
                    'Department will start working on this',
                    Icons.assignment_ind,
                    isCompleted: complaint.status.index >= ComplaintStatus.assigned.index,
                    isActive: complaint.status == ComplaintStatus.assigned,
                    time: complaint.status.index >= ComplaintStatus.assigned.index 
                        ? 'Assigned' : 'Pending',
                  ),
                  
                  _buildTrackingStep(
                    context,
                    'Work in Progress',
                    'Team is working to resolve the issue',
                    Icons.engineering,
                    isCompleted: complaint.status.index >= ComplaintStatus.inProgress.index,
                    isActive: complaint.status == ComplaintStatus.inProgress,
                    time: complaint.status.index >= ComplaintStatus.inProgress.index 
                        ? 'In Progress' : 'Not Started',
                  ),
                  
                  _buildTrackingStep(
                    context,
                    'Resolved',
                    'Issue has been resolved successfully',
                    Icons.check_circle_outline,
                    isCompleted: complaint.status == ComplaintStatus.resolved,
                    isActive: complaint.status == ComplaintStatus.resolved,
                    time: complaint.status == ComplaintStatus.resolved 
                        ? 'Completed' : 'Pending',
                    isLast: true,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Details Section
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    complaint.description,
                    style: const TextStyle(fontSize: 15, height: 1.5),
                  ),
                  const SizedBox(height: 24),
                  
                  const Text(
                    'Location',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: AppTheme.primaryOrange, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          complaint.address,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildTrackingStep(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    {
      required bool isCompleted,
      required bool isActive,
      required String time,
      bool isLast = false,
    }
  ) {
    final Color iconColor = isCompleted 
        ? AppTheme.successColor 
        : isActive 
            ? AppTheme.primaryOrange 
            : Colors.grey[400]!;
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isCompleted || isActive 
                    ? iconColor.withOpacity(0.1) 
                    : Colors.grey[100],
                shape: BoxShape.circle,
                border: Border.all(
                  color: iconColor,
                  width: 2,
                ),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 20,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 60,
                color: isCompleted ? AppTheme.successColor : Colors.grey[300],
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
                    color: isCompleted || isActive ? Colors.black : Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _getStatusMessage(ComplaintStatus status) {
    switch (status) {
      case ComplaintStatus.submitted:
        return 'Complaint submitted successfully';
      case ComplaintStatus.received:
        return 'Under review by our team';
      case ComplaintStatus.verified:
        return 'Complaint verified. Assigning to department...';
      case ComplaintStatus.assigned:
        return 'Assigned to department. Work will start soon';
      case ComplaintStatus.inProgress:
        return 'Team is actively working on your complaint';
      case ComplaintStatus.resolved:
        return 'Issue resolved successfully! Thank you for reporting.';
      case ComplaintStatus.rejected:
        return 'Complaint was rejected. Please contact support for details.';
    }
  }
}
