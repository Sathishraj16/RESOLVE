import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/complaint_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/complaint_card.dart';
import '../../models/complaint_model.dart';

enum SortOption {
  severity,
  dateCreated,
  eta,
}

class OfficialHomeScreen extends StatefulWidget {
  const OfficialHomeScreen({super.key});

  @override
  State<OfficialHomeScreen> createState() => _OfficialHomeScreenState();
}

class _OfficialHomeScreenState extends State<OfficialHomeScreen> {
  SortOption _currentSort = SortOption.dateCreated;

  List<Complaint> _sortComplaints(List<Complaint> complaints) {
    final sorted = List<Complaint>.from(complaints);
    
    switch (_currentSort) {
      case SortOption.severity:
        sorted.sort((a, b) {
          // Sort by priority (critical > high > medium > low)
          // Use AI severity as secondary sort if available
          final aPriorityValue = _getPriorityValue(a.priority);
          final bPriorityValue = _getPriorityValue(b.priority);
          
          if (aPriorityValue != bPriorityValue) {
            return bPriorityValue.compareTo(aPriorityValue);
          }
          
          // If priority is same, use AI severity as tiebreaker
          final aSeverity = a.aiSeverity ?? 0;
          final bSeverity = b.aiSeverity ?? 0;
          return bSeverity.compareTo(aSeverity);
        });
        break;
      case SortOption.dateCreated:
        sorted.sort((a, b) {
          // Sort by date in descending order (newest first)
          return b.createdAt.compareTo(a.createdAt);
        });
        break;
      case SortOption.eta:
        sorted.sort((a, b) {
          // Sort by ETA in descending order
          if (a.estimatedResolutionTime == null && b.estimatedResolutionTime == null) return 0;
          if (a.estimatedResolutionTime == null) return 1;
          if (b.estimatedResolutionTime == null) return -1;
          return b.estimatedResolutionTime!.compareTo(a.estimatedResolutionTime!);
        });
        break;
    }
    
    return sorted;
  }

  int _getPriorityValue(ComplaintPriority priority) {
    switch (priority) {
      case ComplaintPriority.critical:
        return 4;
      case ComplaintPriority.high:
        return 3;
      case ComplaintPriority.medium:
        return 2;
      case ComplaintPriority.low:
        return 1;
    }
  }

  String _getSortLabel(SortOption option) {
    switch (option) {
      case SortOption.severity:
        return 'Severity';
      case SortOption.dateCreated:
        return 'Date Created';
      case SortOption.eta:
        return 'ETA';
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).currentUser;
    final complaints = Provider.of<ComplaintProvider>(context).complaints;
    final sortedComplaints = _sortComplaints(complaints);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Welcome, ${user?.name ?? ''}'),
            Text(
              user?.designation ?? 'Field Officer',
              style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Provider.of<AuthProvider>(context, listen: false).logout();
              context.go('/role-selection');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Sort options bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                const Text(
                  'Sort by:',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: SortOption.values.map((option) {
                        final isSelected = _currentSort == option;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(_getSortLabel(option)),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                _currentSort = option;
                              });
                            },
                            selectedColor: AppTheme.primaryOrange,
                            checkmarkColor: Colors.white,
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : AppTheme.textPrimary,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Complaints list
          Expanded(
            child: sortedComplaints.isEmpty
                ? const Center(
                    child: Text('No complaints assigned'),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: sortedComplaints.length,
                    itemBuilder: (context, index) {
                      final complaint = sortedComplaints[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: ComplaintCard(
                          complaint: complaint,
                          onTap: () => context.push('/task-detail/${complaint.id}'),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
