enum ComplaintStatus {
  submitted,
  received,
  verified,
  assigned,
  inProgress,
  resolved,
  rejected,
}

enum ComplaintPriority {
  low,
  medium,
  high,
  critical,
}

enum ComplaintCategory {
  streetlight,
  roadDamage,
  drainage,
  garbageCollection,
  trafficSignal,
  illegalParking,
  waterSupply,
  publicProperty,
  other,
}

class Complaint {
  final String id;
  final String userId;
  final String title;
  final String description;
  final ComplaintCategory category;
  final ComplaintPriority priority;
  final ComplaintStatus status;
  final List<String> imageUrls;
  final String? audioUrl;
  final double latitude;
  final double longitude;
  final String address;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? assignedOfficialId;
  final String? assignedDepartment;
  final DateTime? estimatedResolutionTime;
  final String? resolutionNote;
  final List<String>? afterImages;
  final List<StatusUpdate> statusHistory;
  final int? upvotes;
  
  // AI-powered fields
  final int? aiSeverity; // 1-5 severity level from AI
  final String? aiSeverityReason; // Explanation for severity rating
  final bool? photoVerified; // Whether AI verified photo matches category

  Complaint({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.category,
    required this.priority,
    required this.status,
    required this.imageUrls,
    this.audioUrl,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.createdAt,
    this.updatedAt,
    this.assignedOfficialId,
    this.assignedDepartment,
    this.estimatedResolutionTime,
    this.resolutionNote,
    this.afterImages,
    required this.statusHistory,
    this.upvotes,
    this.aiSeverity,
    this.aiSeverityReason,
    this.photoVerified,
  });

  factory Complaint.fromJson(Map<String, dynamic> json) {
    return Complaint(
      id: json['id'],
      userId: json['userId'],
      title: json['title'],
      description: json['description'],
      category: ComplaintCategory.values.firstWhere(
        (e) => e.toString() == 'ComplaintCategory.${json['category']}',
      ),
      priority: ComplaintPriority.values.firstWhere(
        (e) => e.toString() == 'ComplaintPriority.${json['priority']}',
      ),
      status: ComplaintStatus.values.firstWhere(
        (e) => e.toString() == 'ComplaintStatus.${json['status']}',
      ),
      imageUrls: List<String>.from(json['imageUrls']),
      audioUrl: json['audioUrl'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      address: json['address'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      assignedOfficialId: json['assignedOfficialId'],
      assignedDepartment: json['assignedDepartment'],
      estimatedResolutionTime: json['estimatedResolutionTime'] != null
          ? DateTime.parse(json['estimatedResolutionTime'])
          : null,
      resolutionNote: json['resolutionNote'],
      afterImages: json['afterImages'] != null ? List<String>.from(json['afterImages']) : null,
      statusHistory: (json['statusHistory'] as List)
          .map((e) => StatusUpdate.fromJson(e))
          .toList(),
      upvotes: json['upvotes'],
      aiSeverity: json['aiSeverity'],
      aiSeverityReason: json['aiSeverityReason'],
      photoVerified: json['photoVerified'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'description': description,
      'category': category.toString().split('.').last,
      'priority': priority.toString().split('.').last,
      'status': status.toString().split('.').last,
      'imageUrls': imageUrls,
      'audioUrl': audioUrl,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'assignedOfficialId': assignedOfficialId,
      'assignedDepartment': assignedDepartment,
      'estimatedResolutionTime': estimatedResolutionTime?.toIso8601String(),
      'resolutionNote': resolutionNote,
      'afterImages': afterImages,
      'statusHistory': statusHistory.map((e) => e.toJson()).toList(),
      'upvotes': upvotes,
      'aiSeverity': aiSeverity,
      'aiSeverityReason': aiSeverityReason,
      'photoVerified': photoVerified,
    };
  }
}

class StatusUpdate {
  final ComplaintStatus status;
  final DateTime timestamp;
  final String? note;
  final String? updatedBy;

  StatusUpdate({
    required this.status,
    required this.timestamp,
    this.note,
    this.updatedBy,
  });

  factory StatusUpdate.fromJson(Map<String, dynamic> json) {
    return StatusUpdate(
      status: ComplaintStatus.values.firstWhere(
        (e) => e.toString() == 'ComplaintStatus.${json['status']}',
      ),
      timestamp: DateTime.parse(json['timestamp']),
      note: json['note'],
      updatedBy: json['updatedBy'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status.toString().split('.').last,
      'timestamp': timestamp.toIso8601String(),
      'note': note,
      'updatedBy': updatedBy,
    };
  }
}
