/// Request model representing a Welfare Check-in Request
/// Status flow: DRAFT → SUBMITTED → UNDER_REVIEW → ASSIGNED → COMPLETED → VERIFIED/ESCALATED
class Request {
  final String id;
  final String residentId;
  final String? coordinatorId;
  final String? supportWorkerId;
  final String? reviewerId;
  final String title;
  final String description;
  final String status; // 'DRAFT', 'SUBMITTED', 'UNDER_REVIEW', 'ASSIGNED', 'COMPLETED', 'VERIFIED', 'ESCALATED'
  final String priority; // 'LOW', 'MEDIUM', 'HIGH', 'URGENT'
  final DateTime? deadline;
  final String? visitNotes;
  final String? escalationReason;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? submittedAt;
  final DateTime? assignedAt;
  final DateTime? completedAt;
  final DateTime? reviewedAt;

  Request({
    required this.id,
    required this.residentId,
    this.coordinatorId,
    this.supportWorkerId,
    this.reviewerId,
    required this.title,
    required this.description,
    required this.status,
    this.priority = 'MEDIUM',
    this.deadline,
    this.visitNotes,
    this.escalationReason,
    required this.createdAt,
    required this.updatedAt,
    this.submittedAt,
    this.assignedAt,
    this.completedAt,
    this.reviewedAt,
  });

  /// Create Request from database map
  factory Request.fromMap(Map<String, dynamic> map) {
    return Request(
      id: map['id'] as String,
      residentId: map['resident_id'] as String,
      coordinatorId: map['coordinator_id'] as String?,
      supportWorkerId: map['support_worker_id'] as String?,
      reviewerId: map['reviewer_id'] as String?,
      title: map['title'] as String,
      description: map['description'] as String,
      status: map['status'] as String,
      priority: map['priority'] as String? ?? 'MEDIUM',
      deadline: map['deadline'] != null
          ? DateTime.parse(map['deadline'] as String)
          : null,
      visitNotes: map['visit_notes'] as String?,
      escalationReason: map['escalation_reason'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
      submittedAt: map['submitted_at'] != null
          ? DateTime.parse(map['submitted_at'] as String)
          : null,
      assignedAt: map['assigned_at'] != null
          ? DateTime.parse(map['assigned_at'] as String)
          : null,
      completedAt: map['completed_at'] != null
          ? DateTime.parse(map['completed_at'] as String)
          : null,
      reviewedAt: map['reviewed_at'] != null
          ? DateTime.parse(map['reviewed_at'] as String)
          : null,
    );
  }

  /// Convert Request to map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'resident_id': residentId,
      'coordinator_id': coordinatorId,
      'support_worker_id': supportWorkerId,
      'reviewer_id': reviewerId,
      'title': title,
      'description': description,
      'status': status,
      'priority': priority,
      'deadline': deadline?.toIso8601String(),
      'visit_notes': visitNotes,
      'escalation_reason': escalationReason,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'submitted_at': submittedAt?.toIso8601String(),
      'assigned_at': assignedAt?.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'reviewed_at': reviewedAt?.toIso8601String(),
    };
  }

  /// Create a copy with modified fields
  Request copyWith({
    String? id,
    String? residentId,
    String? coordinatorId,
    String? supportWorkerId,
    String? reviewerId,
    String? title,
    String? description,
    String? status,
    String? priority,
    DateTime? deadline,
    String? visitNotes,
    String? escalationReason,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? submittedAt,
    DateTime? assignedAt,
    DateTime? completedAt,
    DateTime? reviewedAt,
  }) {
    return Request(
      id: id ?? this.id,
      residentId: residentId ?? this.residentId,
      coordinatorId: coordinatorId ?? this.coordinatorId,
      supportWorkerId: supportWorkerId ?? this.supportWorkerId,
      reviewerId: reviewerId ?? this.reviewerId,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      deadline: deadline ?? this.deadline,
      visitNotes: visitNotes ?? this.visitNotes,
      escalationReason: escalationReason ?? this.escalationReason,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      submittedAt: submittedAt ?? this.submittedAt,
      assignedAt: assignedAt ?? this.assignedAt,
      completedAt: completedAt ?? this.completedAt,
      reviewedAt: reviewedAt ?? this.reviewedAt,
    );
  }

  /// Check if request is overdue
  bool isOverdue() {
    if (deadline == null) return false;
    return DateTime.now().isAfter(deadline!);
  }

  /// Get days remaining until deadline
  int? daysUntilDeadline() {
    if (deadline == null) return null;
    return deadline!.difference(DateTime.now()).inDays;
  }

  /// Get hours remaining until deadline
  int? hoursUntilDeadline() {
    if (deadline == null) return null;
    return deadline!.difference(DateTime.now()).inHours;
  }

  @override
  String toString() =>
      'Request(id: $id, status: $status, priority: $priority)';
}
