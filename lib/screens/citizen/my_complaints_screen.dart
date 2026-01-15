import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/complaint_provider.dart';
import '../../widgets/common/complaint_card.dart';
import 'package:go_router/go_router.dart';

class MyComplaintsScreen extends StatelessWidget {
  const MyComplaintsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ComplaintProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Complaints'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: provider.complaints.length,
        itemBuilder: (context, index) {
          final complaint = provider.complaints[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: ComplaintCard(
              complaint: complaint,
              onTap: () => context.push('/complaint-detail/${complaint.id}'),
            ),
          );
        },
      ),
    );
  }
}
