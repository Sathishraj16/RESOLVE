import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/complaint_provider.dart';
import '../../models/complaint_model.dart';
import '../../widgets/common/priority_badge.dart';

class TaskDetailScreen extends StatelessWidget {
  final String complaintId;

  const TaskDetailScreen({super.key, required this.complaintId});

  @override
  Widget build(BuildContext context) {
    final complaint = Provider.of<ComplaintProvider>(context).getComplaintById(complaintId);

    if (complaint == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Task Not Found')),
        body: const Center(child: Text('Task not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Task Details')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            complaint.title,
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ),
                        PriorityBadge(priority: complaint.priority),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(complaint.description),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 16),
                        const SizedBox(width: 4),
                        Expanded(child: Text(complaint.address)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Provider.of<ComplaintProvider>(context, listen: false)
                      .updateComplaintStatus(complaint.id, ComplaintStatus.resolved, 'Work completed');
                  Navigator.pop(context);
                },
                child: const Text('Mark as Resolved'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
