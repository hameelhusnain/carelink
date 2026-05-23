import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../core/database/database_helper.dart';
import '../models/request.dart';
import '../core/constants/app_constants.dart';

/// RequestProvider manages all welfare check request operations
/// Handles CRUD operations, status transitions, filtering, and business logic
class RequestProvider extends ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  List<Request> _requests = [];
  Request? _currentRequest;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<Request> get requests => _requests;
  Request? get currentRequest => _currentRequest;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Get requests for resident (by userId)
  Future<bool> getResidentRequests(String residentId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final requestMaps = await _dbHelper.getResidentRequests(residentId);
      _requests = requestMaps.map((map) => Request.fromMap(map)).toList();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to load requests: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Get coordinator inbox with optional filters
  Future<bool> getCoordinatorInbox({String? status, String? priority}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final requestMaps =
          await _dbHelper.getCoordinatorInbox(status: status, priority: priority);
      _requests = requestMaps.map((map) => Request.fromMap(map)).toList();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to load inbox: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Get requests assigned to support worker
  Future<bool> getSupportWorkerRequests(String supportWorkerId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final requestMaps =
          await _dbHelper.getSupportWorkerRequests(supportWorkerId);
      _requests = requestMaps.map((map) => Request.fromMap(map)).toList();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to load requests: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Get review queue for reviewer
  Future<bool> getReviewQueue() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final requestMaps = await _dbHelper.getReviewQueue();
      _requests = requestMaps.map((map) => Request.fromMap(map)).toList();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to load review queue: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Get single request by ID
  Future<bool> getRequestById(String requestId) async {
    try {
      final requestMap = await _dbHelper.getRequestById(requestId);
      if (requestMap != null) {
        _currentRequest = Request.fromMap(requestMap);
        notifyListeners();
        return true;
      }
      _errorMessage = 'Request not found';
      return false;
    } catch (e) {
      _errorMessage = 'Failed to load request: $e';
      return false;
    }
  }

  /// Create new request (resident)
  Future<String?> createRequest({
    required String residentId,
    required String title,
    required String description,
    String priority = 'MEDIUM',
    DateTime? deadline,
  }) async {
    try {
      final requestId = const Uuid().v4();

      final success = await _dbHelper.insertRequest(
        id: requestId,
        residentId: residentId,
        title: title,
        description: description,
        status: RequestStatus.draft,
        priority: priority,
        deadline: deadline?.toIso8601String(),
      );

      if (success) {
        // Create audit log
        await _logAuditEntry(
          userId: residentId,
          action: 'CREATE',
          tableName: 'requests',
          recordId: requestId,
          newValue: 'Request created: $title',
        );
        return requestId;
      }
      return null;
    } catch (e) {
      _errorMessage = 'Failed to create request: $e';
      return null;
    }
  }

  /// Update request
  Future<bool> updateRequest({
    required String requestId,
    String? title,
    String? description,
  }) async {
    try {
      final request = await _dbHelper.getRequestById(requestId);
      if (request == null) {
        _errorMessage = 'Request not found';
        return false;
      }

      // For now, update basic fields via status method
      // Can be extended for specific field updates
      _errorMessage = 'Update method to be implemented';
      return false;
    } catch (e) {
      _errorMessage = 'Failed to update request: $e';
      return false;
    }
  }

  /// Submit request (Resident -> Coordinator)
  Future<bool> submitRequest({
    required String requestId,
    required String userId,
  }) async {
    try {
      final success = await _dbHelper.updateRequestStatus(
        requestId: requestId,
        newStatus: RequestStatus.submitted,
      );

      if (success) {
        await _logAuditEntry(
          userId: userId,
          action: 'SUBMIT',
          tableName: 'requests',
          recordId: requestId,
          newValue: 'Request submitted for review',
        );
        await getRequestById(requestId);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = 'Failed to submit request: $e';
      return false;
    }
  }

  /// Assign request to support worker (Coordinator)
  Future<bool> assignRequest({
    required String requestId,
    required String supportWorkerId,
    required String coordinatorId,
    String? priority,
    DateTime? deadline,
  }) async {
    try {
      final success = await _dbHelper.updateRequestStatus(
        requestId: requestId,
        newStatus: RequestStatus.assigned,
        coordinatorId: coordinatorId,
        supportWorkerId: supportWorkerId,
        priority: priority,
        deadline: deadline?.toIso8601String(),
      );

      if (success) {
        await _logAuditEntry(
          userId: coordinatorId,
          action: 'ASSIGN',
          tableName: 'requests',
          recordId: requestId,
          newValue: 'Assigned to support worker: $supportWorkerId',
        );
        await getRequestById(requestId);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = 'Failed to assign request: $e';
      return false;
    }
  }

  /// Bulk assign requests to support worker
  Future<bool> bulkAssignRequests({
    required List<String> requestIds,
    required String supportWorkerId,
    required String coordinatorId,
  }) async {
    try {
      final success = await _dbHelper.bulkAssignRequests(
        requestIds: requestIds,
        supportWorkerId: supportWorkerId,
        coordinatorId: coordinatorId,
      );

      if (success) {
        for (String requestId in requestIds) {
          await _logAuditEntry(
            userId: coordinatorId,
            action: 'ASSIGN',
            tableName: 'requests',
            recordId: requestId,
            newValue: 'Bulk assigned to: $supportWorkerId',
          );
        }
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = 'Failed to bulk assign requests: $e';
      return false;
    }
  }

  /// Complete visit (Support Worker)
  Future<bool> completeVisit({
    required String requestId,
    required String supportWorkerId,
    required String visitNotes,
  }) async {
    try {
      final success = await _dbHelper.updateRequestStatus(
        requestId: requestId,
        newStatus: RequestStatus.completed,
        visitNotes: visitNotes,
      );

      if (success) {
        await _logAuditEntry(
          userId: supportWorkerId,
          action: 'COMPLETE',
          tableName: 'requests',
          recordId: requestId,
          newValue: 'Visit completed. Notes: $visitNotes',
        );
        await getRequestById(requestId);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = 'Failed to complete visit: $e';
      return false;
    }
  }

  /// Verify request (Reviewer)
  Future<bool> verifyRequest({
    required String requestId,
    required String reviewerId,
  }) async {
    try {
      final success = await _dbHelper.updateRequestStatus(
        requestId: requestId,
        newStatus: RequestStatus.verified,
        reviewerId: reviewerId,
      );

      if (success) {
        await _logAuditEntry(
          userId: reviewerId,
          action: 'VERIFY',
          tableName: 'requests',
          recordId: requestId,
          newValue: 'Request verified',
        );
        await getRequestById(requestId);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = 'Failed to verify request: $e';
      return false;
    }
  }

  /// Escalate request (Reviewer)
  Future<bool> escalateRequest({
    required String requestId,
    required String reviewerId,
    required String escalationReason,
  }) async {
    try {
      final success = await _dbHelper.updateRequestStatus(
        requestId: requestId,
        newStatus: RequestStatus.escalated,
        reviewerId: reviewerId,
        escalationReason: escalationReason,
      );

      if (success) {
        await _logAuditEntry(
          userId: reviewerId,
          action: 'ESCALATE',
          tableName: 'requests',
          recordId: requestId,
          newValue: 'Request escalated. Reason: $escalationReason',
        );
        await getRequestById(requestId);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = 'Failed to escalate request: $e';
      return false;
    }
  }

  /// Delete request (soft delete - for drafts only)
  Future<bool> deleteRequest({
    required String requestId,
    required String userId,
  }) async {
    try {
      final success = await _dbHelper.deleteRequest(requestId);

      if (success) {
        await _logAuditEntry(
          userId: userId,
          action: 'DELETE',
          tableName: 'requests',
          recordId: requestId,
          newValue: 'Draft request deleted',
        );
        _requests.removeWhere((r) => r.id == requestId);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = 'Failed to delete request: $e';
      return false;
    }
  }

  /// Get request statistics for dashboard
  Future<Map<String, dynamic>> getRequestStatistics() async {
    try {
      return await _dbHelper.getRequestStatistics();
    } catch (e) {
      print('Error getting statistics: $e');
      return {};
    }
  }

  /// Filter requests by status
  List<Request> filterByStatus(String status) {
    return _requests.where((r) => r.status == status).toList();
  }

  /// Filter requests by priority
  List<Request> filterByPriority(String priority) {
    return _requests.where((r) => r.priority == priority).toList();
  }

  /// Get overdue requests
  List<Request> getOverdueRequests() {
    return _requests.where((r) => r.isOverdue()).toList();
  }

  /// Sort requests by deadline
  List<Request> sortByDeadline() {
    final sorted = List<Request>.from(_requests);
    sorted.sort((a, b) {
      if (a.deadline == null && b.deadline == null) return 0;
      if (a.deadline == null) return 1;
      if (b.deadline == null) return -1;
      return a.deadline!.compareTo(b.deadline!);
    });
    return sorted;
  }

  /// Log audit entry
  Future<void> _logAuditEntry({
    required String userId,
    required String action,
    required String tableName,
    required String recordId,
    String? oldValue,
    String? newValue,
  }) async {
    try {
      await _dbHelper.insertAuditLog(
        id: const Uuid().v4(),
        userId: userId,
        action: action,
        tableName: tableName,
        recordId: recordId,
        oldValue: oldValue,
        newValue: newValue,
      );
    } catch (e) {
      print('Error logging audit entry: $e');
    }
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
