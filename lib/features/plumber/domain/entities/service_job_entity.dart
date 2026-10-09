enum ServiceJobStatus {
  assigned,
  inProgress,
  completed,
  cancelled;

  String get displayName {
    switch (this) {
      case ServiceJobStatus.assigned:
        return 'Job Assigned';
      case ServiceJobStatus.inProgress:
        return 'Work In Progress';
      case ServiceJobStatus.completed:
        return 'Completed & Certified';
      case ServiceJobStatus.cancelled:
        return 'Cancelled';
    }
  }
}

class ServiceJobEntity {
  final String id;
  final String title;
  final String customerName;
  final String customerPhone;
  final String address;
  final String issueDescription;
  final ServiceJobStatus status;
  final DateTime scheduledDate;
  final double estimatedPayout;
  final List<String> requiredParts;
  final String? completionNotes;
  final DateTime? completedAt;

  const ServiceJobEntity({
    required this.id,
    required this.title,
    required this.customerName,
    required this.customerPhone,
    required this.address,
    required this.issueDescription,
    required this.status,
    required this.scheduledDate,
    required this.estimatedPayout,
    this.requiredParts = const [],
    this.completionNotes,
    this.completedAt,
  });

  ServiceJobEntity copyWith({
    String? id,
    String? title,
    String? customerName,
    String? customerPhone,
    String? address,
    String? issueDescription,
    ServiceJobStatus? status,
    DateTime? scheduledDate,
    double? estimatedPayout,
    List<String>? requiredParts,
    String? completionNotes,
    DateTime? completedAt,
  }) {
    return ServiceJobEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      address: address ?? this.address,
      issueDescription: issueDescription ?? this.issueDescription,
      status: status ?? this.status,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      estimatedPayout: estimatedPayout ?? this.estimatedPayout,
      requiredParts: requiredParts ?? this.requiredParts,
      completionNotes: completionNotes ?? this.completionNotes,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}
