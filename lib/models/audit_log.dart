/// AuditLog model for tracking all system actions
/// Records who did what, when, and provides old/new values for changes
class AuditLog {
  final String id;
  final String userId;
  final String action; // 'CREATE', 'UPDATE', 'DELETE', 'SUBMIT', 'ASSIGN', 'COMPLETE', 'VERIFY', 'ESCALATE'
  final String tableName; // 'users', 'requests', etc.
  final String recordId; // ID of the record that was modified
  final String? oldValue; // JSON string of old values
  final String? newValue; // JSON string of new values
  final DateTime timestamp;

  AuditLog({
    required this.id,
    required this.userId,
    required this.action,
    required this.tableName,
    required this.recordId,
    this.oldValue,
    this.newValue,
    required this.timestamp,
  });

  /// Create AuditLog from database map
  factory AuditLog.fromMap(Map<String, dynamic> map) {
    return AuditLog(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      action: map['action'] as String,
      tableName: map['table_name'] as String,
      recordId: map['record_id'] as String,
      oldValue: map['old_value'] as String?,
      newValue: map['new_value'] as String?,
      timestamp: DateTime.parse(map['timestamp'] as String),
    );
  }

  /// Convert AuditLog to map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'action': action,
      'table_name': tableName,
      'record_id': recordId,
      'old_value': oldValue,
      'new_value': newValue,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  /// Create a human-readable description of the audit log entry
  String getDescription() {
    switch (action) {
      case 'CREATE':
        return 'Created $tableName';
      case 'UPDATE':
        return 'Updated $tableName';
      case 'DELETE':
        return 'Deleted $tableName';
      case 'SUBMIT':
        return 'Submitted request';
      case 'ASSIGN':
        return 'Assigned to support worker';
      case 'COMPLETE':
        return 'Marked visit as completed';
      case 'VERIFY':
        return 'Verified request';
      case 'ESCALATE':
        return 'Escalated request';
      default:
        return action;
    }
  }

  @override
  String toString() =>
      'AuditLog(id: $id, action: $action, user: $userId, timestamp: $timestamp)';
}
