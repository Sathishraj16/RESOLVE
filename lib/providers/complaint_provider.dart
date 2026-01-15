import 'package:flutter/material.dart';
import '../models/complaint_model.dart';
import 'package:uuid/uuid.dart';

class ComplaintProvider extends ChangeNotifier {
  List<Complaint> _complaints = [];
  bool _isLoading = false;
  final _uuid = const Uuid();

  List<Complaint> get complaints => _complaints;
  bool get isLoading => _isLoading;

  List<Complaint> get myComplaints => _complaints;

  ComplaintProvider() {
    // _loadMockData(); // Disabled to ensure empty state for new users
  }

  void _loadMockData() {
    _complaints = [
      Complaint(
        id: '1',
        userId: '1',
        title: 'Pothole on Main Road',
        description: 'Large pothole causing traffic issues',
        category: ComplaintCategory.roadDamage,
        priority: ComplaintPriority.high,
        status: ComplaintStatus.inProgress,
        imageUrls: ['https://via.placeholder.com/400'],
        latitude: 12.9716,
        longitude: 77.5946,
        address: 'MG Road, Bangalore',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 5)),
        assignedDepartment: 'Public Works',
        assignedOfficialId: '2',
        estimatedResolutionTime: DateTime.now().add(const Duration(days: 3)),
        statusHistory: [
          StatusUpdate(
            status: ComplaintStatus.submitted,
            timestamp: DateTime.now().subtract(const Duration(days: 2, hours: 1)),
            note: 'Complaint submitted',
          ),
          StatusUpdate(
            status: ComplaintStatus.received,
            timestamp: DateTime.now().subtract(const Duration(days: 2)),
            note: 'Complaint received',
          ),
          StatusUpdate(
            status: ComplaintStatus.verified,
            timestamp: DateTime.now().subtract(const Duration(days: 1)),
            note: 'Issue verified by system',
          ),
          StatusUpdate(
            status: ComplaintStatus.assigned,
            timestamp: DateTime.now().subtract(const Duration(hours: 12)),
            note: 'Assigned to field officer',
            updatedBy: 'Admin Kumar',
          ),
          StatusUpdate(
            status: ComplaintStatus.inProgress,
            timestamp: DateTime.now().subtract(const Duration(hours: 5)),
            note: 'Work in progress',
            updatedBy: 'Officer Smith',
          ),
        ],
        upvotes: 23,
      ),
      Complaint(
        id: '2',
        userId: '1',
        title: 'Street Light Not Working',
        description: 'Street light near park has been off for 3 days',
        category: ComplaintCategory.streetlight,
        priority: ComplaintPriority.medium,
        status: ComplaintStatus.assigned,
        imageUrls: ['https://via.placeholder.com/400'],
        latitude: 12.9352,
        longitude: 77.6245,
        address: 'Koramangala, Bangalore',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 3)),
        assignedDepartment: 'Electricity Board',
        estimatedResolutionTime: DateTime.now().add(const Duration(days: 2)),
        statusHistory: [
          StatusUpdate(
            status: ComplaintStatus.submitted,
            timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 1)),
            note: 'Complaint submitted',
          ),
          StatusUpdate(
            status: ComplaintStatus.received,
            timestamp: DateTime.now().subtract(const Duration(days: 1)),
            note: 'Complaint received',
          ),
          StatusUpdate(
            status: ComplaintStatus.verified,
            timestamp: DateTime.now().subtract(const Duration(hours: 8)),
            note: 'Issue verified',
          ),
          StatusUpdate(
            status: ComplaintStatus.assigned,
            timestamp: DateTime.now().subtract(const Duration(hours: 3)),
            note: 'Assigned to electrician',
          ),
        ],
        upvotes: 8,
      ),
      Complaint(
        id: '3',
        userId: '1',
        title: 'Garbage Not Collected',
        description: 'Garbage overflowing for the past week',
        category: ComplaintCategory.garbageCollection,
        priority: ComplaintPriority.critical,
        status: ComplaintStatus.verified,
        imageUrls: ['https://via.placeholder.com/400'],
        latitude: 12.9698,
        longitude: 77.7499,
        address: 'Whitefield, Bangalore',
        createdAt: DateTime.now().subtract(const Duration(hours: 8)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
        statusHistory: [
          StatusUpdate(
            status: ComplaintStatus.submitted,
            timestamp: DateTime.now().subtract(const Duration(hours: 9)),
            note: 'Complaint submitted',
          ),
          StatusUpdate(
            status: ComplaintStatus.received,
            timestamp: DateTime.now().subtract(const Duration(hours: 8)),
            note: 'Complaint received',
          ),
          StatusUpdate(
            status: ComplaintStatus.verified,
            timestamp: DateTime.now().subtract(const Duration(hours: 2)),
            note: 'Marked as critical priority',
          ),
        ],
        upvotes: 45,
      ),
    ];
    notifyListeners();
  }

  Future<bool> submitComplaint(Complaint complaint) async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 2));
      _complaints.insert(0, complaint);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Complaint? getComplaintById(String id) {
    try {
      return _complaints.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }

  List<Complaint> getComplaintsByStatus(ComplaintStatus status) {
    return _complaints.where((c) => c.status == status).toList();
  }

  Future<void> updateComplaintStatus(
    String complaintId,
    ComplaintStatus newStatus,
    String note,
  ) async {
    final index = _complaints.indexWhere((c) => c.id == complaintId);
    if (index != -1) {
      final complaint = _complaints[index];
      final updatedHistory = List<StatusUpdate>.from(complaint.statusHistory)
        ..add(StatusUpdate(
          status: newStatus,
          timestamp: DateTime.now(),
          note: note,
        ));

      _complaints[index] = Complaint(
        id: complaint.id,
        userId: complaint.userId,
        title: complaint.title,
        description: complaint.description,
        category: complaint.category,
        priority: complaint.priority,
        status: newStatus,
        imageUrls: complaint.imageUrls,
        audioUrl: complaint.audioUrl,
        latitude: complaint.latitude,
        longitude: complaint.longitude,
        address: complaint.address,
        createdAt: complaint.createdAt,
        updatedAt: DateTime.now(),
        assignedOfficialId: complaint.assignedOfficialId,
        assignedDepartment: complaint.assignedDepartment,
        estimatedResolutionTime: complaint.estimatedResolutionTime,
        resolutionNote: complaint.resolutionNote,
        afterImages: complaint.afterImages,
        statusHistory: updatedHistory,
        upvotes: complaint.upvotes,
      );
      notifyListeners();
    }
  }

  Future<void> refreshComplaints() async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(seconds: 1));
    _loadMockData();
    _isLoading = false;
    notifyListeners();
  }
}
