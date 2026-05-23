import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

/// DatabaseHelper handles all SQLite database operations for CareLink.
/// This includes user management, request handling, and audit logging.
/// 
/// Note: On web platform, uses in-memory storage as fallback since
/// path_provider is not available on web.
class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;
  static bool _isWebPlatform = false;
  static final Map<String, List<Map<String, dynamic>>> _inMemoryData = {
    'users': [],
    'requests': [],
    'audit_logs': [],
  };

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  /// Get the database instance. Creates it if it doesn't exist.
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initializeDatabase();
    return _database!;
  }

  /// Initialize the database and create tables
  Future<Database> _initializeDatabase() async {
    try {
      final documentsDirectory = await getApplicationDocumentsDirectory();
      final path = join(documentsDirectory.path, 'carelink.db');
      return await openDatabase(
        path,
        version: 1,
        onCreate: _createTables,
      );
    } catch (e) {
      // Fallback for web platform where path_provider is not available
      print('Database initialization failed, using in-memory storage: $e');
      _isWebPlatform = true;
      return _getInMemoryDatabase();
    }
  }

  /// Create an in-memory database (fallback for web)
  Database _getInMemoryDatabase() {
    return InMemoryDatabase();
  }

  /// Create all database tables
  Future<void> _createTables(Database db, int version) async {
    // Users Table
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        email TEXT UNIQUE NOT NULL,
        password_hash TEXT NOT NULL,
        full_name TEXT NOT NULL,
        role TEXT NOT NULL,
        phone_number TEXT,
        address TEXT,
        is_active INTEGER DEFAULT 1,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Requests Table (Welfare Check Requests)
    await db.execute('''
      CREATE TABLE requests (
        id TEXT PRIMARY KEY,
        resident_id TEXT NOT NULL,
        coordinator_id TEXT,
        support_worker_id TEXT,
        reviewer_id TEXT,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        status TEXT NOT NULL,
        priority TEXT DEFAULT 'MEDIUM',
        deadline TEXT,
        visit_notes TEXT,
        escalation_reason TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        submitted_at TEXT,
        assigned_at TEXT,
        completed_at TEXT,
        reviewed_at TEXT,
        FOREIGN KEY (resident_id) REFERENCES users(id),
        FOREIGN KEY (coordinator_id) REFERENCES users(id),
        FOREIGN KEY (support_worker_id) REFERENCES users(id),
        FOREIGN KEY (reviewer_id) REFERENCES users(id)
      )
    ''');

    // Audit Log Table (tracks all actions with who did what and when)
    await db.execute('''
      CREATE TABLE audit_logs (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        action TEXT NOT NULL,
        table_name TEXT NOT NULL,
        record_id TEXT NOT NULL,
        old_value TEXT,
        new_value TEXT,
        timestamp TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users(id)
      )
    ''');

    // Create indexes for faster queries
    await db.execute(
        'CREATE INDEX idx_requests_resident_id ON requests(resident_id)');
    await db.execute(
        'CREATE INDEX idx_requests_status ON requests(status)');
    await db.execute(
        'CREATE INDEX idx_requests_support_worker_id ON requests(support_worker_id)');
    await db.execute(
        'CREATE INDEX idx_audit_logs_user_id ON audit_logs(user_id)');
    await db.execute(
        'CREATE INDEX idx_audit_logs_timestamp ON audit_logs(timestamp)');
  }

  // ========== USER OPERATIONS ==========

  /// Insert a new user
  Future<bool> insertUser({
    required String id,
    required String email,
    required String passwordHash,
    required String fullName,
    required String role,
    String? phoneNumber,
    String? address,
  }) async {
    try {
      final db = await database;
      final now = DateTime.now().toIso8601String();
      await db.insert('users', {
        'id': id,
        'email': email,
        'password_hash': passwordHash,
        'full_name': fullName,
        'role': role,
        'phone_number': phoneNumber,
        'address': address,
        'created_at': now,
        'updated_at': now,
      });
      return true;
    } catch (e) {
      print('Error inserting user: $e');
      return false;
    }
  }

  /// Get user by email
  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    try {
      final db = await database;
      final result =
          await db.query('users', where: 'email = ?', whereArgs: [email]);
      return result.isNotEmpty ? result.first : null;
    } catch (e) {
      print('Error getting user by email: $e');
      return null;
    }
  }

  /// Get user by ID
  Future<Map<String, dynamic>?> getUserById(String userId) async {
    try {
      final db = await database;
      final result =
          await db.query('users', where: 'id = ?', whereArgs: [userId]);
      return result.isNotEmpty ? result.first : null;
    } catch (e) {
      print('Error getting user by ID: $e');
      return null;
    }
  }

  /// Get all users with a specific role
  Future<List<Map<String, dynamic>>> getUsersByRole(String role) async {
    try {
      final db = await database;
      return await db.query('users',
          where: 'role = ? AND is_active = 1', whereArgs: [role]);
    } catch (e) {
      print('Error getting users by role: $e');
      return [];
    }
  }

  /// Update user
  Future<bool> updateUser({
    required String userId,
    String? fullName,
    String? phoneNumber,
    String? address,
    String? role,
  }) async {
    try {
      final db = await database;
      final now = DateTime.now().toIso8601String();
      final updates = <String, dynamic>{'updated_at': now};

      if (fullName != null) updates['full_name'] = fullName;
      if (phoneNumber != null) updates['phone_number'] = phoneNumber;
      if (address != null) updates['address'] = address;
      if (role != null) updates['role'] = role;

      await db.update('users', updates,
          where: 'id = ?', whereArgs: [userId]);
      return true;
    } catch (e) {
      print('Error updating user: $e');
      return false;
    }
  }

  // ========== REQUEST OPERATIONS ==========

  /// Insert a new request
  Future<bool> insertRequest({
    required String id,
    required String residentId,
    required String title,
    required String description,
    required String status,
    String? priority,
    String? deadline,
  }) async {
    try {
      final db = await database;
      final now = DateTime.now().toIso8601String();
      await db.insert('requests', {
        'id': id,
        'resident_id': residentId,
        'title': title,
        'description': description,
        'status': status,
        'priority': priority ?? 'MEDIUM',
        'deadline': deadline,
        'created_at': now,
        'updated_at': now,
      });
      return true;
    } catch (e) {
      print('Error inserting request: $e');
      return false;
    }
  }

  /// Get request by ID
  Future<Map<String, dynamic>?> getRequestById(String requestId) async {
    try {
      final db = await database;
      final result = await db.query('requests',
          where: 'id = ?', whereArgs: [requestId]);
      return result.isNotEmpty ? result.first : null;
    } catch (e) {
      print('Error getting request by ID: $e');
      return null;
    }
  }

  /// Get all requests for a resident
  Future<List<Map<String, dynamic>>> getResidentRequests(
      String residentId) async {
    try {
      final db = await database;
      return await db.query('requests',
          where: 'resident_id = ?',
          whereArgs: [residentId],
          orderBy: 'created_at DESC');
    } catch (e) {
      print('Error getting resident requests: $e');
      return [];
    }
  }

  /// Get all requests for coordinator (inbox)
  Future<List<Map<String, dynamic>>> getCoordinatorInbox(
      {String? status, String? priority}) async {
    try {
      final db = await database;
      String where = 'status != ?';
      List<dynamic> args = ['DRAFT'];

      if (status != null) {
        where += ' AND status = ?';
        args.add(status);
      }
      if (priority != null) {
        where += ' AND priority = ?';
        args.add(priority);
      }

      return await db.query('requests',
          where: where, whereArgs: args, orderBy: 'created_at DESC');
    } catch (e) {
      print('Error getting coordinator inbox: $e');
      return [];
    }
  }

  /// Get all requests assigned to a support worker
  Future<List<Map<String, dynamic>>> getSupportWorkerRequests(
      String supportWorkerId) async {
    try {
      final db = await database;
      return await db.query('requests',
          where: 'support_worker_id = ? AND status != ?',
          whereArgs: [supportWorkerId, 'VERIFIED'],
          orderBy: 'deadline ASC, priority ASC');
    } catch (e) {
      print('Error getting support worker requests: $e');
      return [];
    }
  }

  /// Get all requests pending review
  Future<List<Map<String, dynamic>>> getReviewQueue() async {
    try {
      final db = await database;
      return await db.query('requests',
          where: 'status = ?',
          whereArgs: ['COMPLETED'],
          orderBy: 'completed_at DESC');
    } catch (e) {
      print('Error getting review queue: $e');
      return [];
    }
  }

  /// Update request status and related fields
  Future<bool> updateRequestStatus({
    required String requestId,
    required String newStatus,
    String? coordinatorId,
    String? supportWorkerId,
    String? visitNotes,
    String? escalationReason,
    String? priority,
    String? deadline,
    String? reviewerId,
  }) async {
    try {
      final db = await database;
      final now = DateTime.now().toIso8601String();
      final updates = <String, dynamic>{
        'status': newStatus,
        'updated_at': now,
      };

      if (coordinatorId != null) updates['coordinator_id'] = coordinatorId;
      if (supportWorkerId != null) updates['support_worker_id'] = supportWorkerId;
      if (visitNotes != null) updates['visit_notes'] = visitNotes;
      if (escalationReason != null) updates['escalation_reason'] = escalationReason;
      if (priority != null) updates['priority'] = priority;
      if (deadline != null) updates['deadline'] = deadline;
      if (reviewerId != null) updates['reviewer_id'] = reviewerId;

      // Set timestamps based on status
      if (newStatus == 'SUBMITTED') updates['submitted_at'] = now;
      if (newStatus == 'ASSIGNED') updates['assigned_at'] = now;
      if (newStatus == 'COMPLETED') updates['completed_at'] = now;
      if (newStatus == 'VERIFIED' || newStatus == 'ESCALATED') {
        updates['reviewed_at'] = now;
      }

      await db.update('requests', updates,
          where: 'id = ?', whereArgs: [requestId]);
      return true;
    } catch (e) {
      print('Error updating request status: $e');
      return false;
    }
  }

  /// Delete request (soft delete - used for draft deletion)
  Future<bool> deleteRequest(String requestId) async {
    try {
      final db = await database;
      await db.delete('requests', where: 'id = ?', whereArgs: [requestId]);
      return true;
    } catch (e) {
      print('Error deleting request: $e');
      return false;
    }
  }

  // ========== AUDIT LOG OPERATIONS ==========

  /// Insert audit log entry
  Future<bool> insertAuditLog({
    required String id,
    required String userId,
    required String action,
    required String tableName,
    required String recordId,
    String? oldValue,
    String? newValue,
  }) async {
    try {
      final db = await database;
      final now = DateTime.now().toIso8601String();
      await db.insert('audit_logs', {
        'id': id,
        'user_id': userId,
        'action': action,
        'table_name': tableName,
        'record_id': recordId,
        'old_value': oldValue,
        'new_value': newValue,
        'timestamp': now,
      });
      return true;
    } catch (e) {
      print('Error inserting audit log: $e');
      return false;
    }
  }

  /// Get audit logs for a specific user
  Future<List<Map<String, dynamic>>> getUserAuditLogs(String userId,
      {int limit = 100}) async {
    try {
      final db = await database;
      return await db.query('audit_logs',
          where: 'user_id = ?',
          whereArgs: [userId],
          orderBy: 'timestamp DESC',
          limit: limit);
    } catch (e) {
      print('Error getting user audit logs: $e');
      return [];
    }
  }

  /// Get audit logs for a specific record
  Future<List<Map<String, dynamic>>> getRecordAuditLogs(
      String recordId, String tableName) async {
    try {
      final db = await database;
      return await db.query('audit_logs',
          where: 'record_id = ? AND table_name = ?',
          whereArgs: [recordId, tableName],
          orderBy: 'timestamp DESC');
    } catch (e) {
      print('Error getting record audit logs: $e');
      return [];
    }
  }

  /// Get all audit logs with pagination
  Future<List<Map<String, dynamic>>> getAllAuditLogs(
      {int limit = 100, int offset = 0}) async {
    try {
      final db = await database;
      return await db.query('audit_logs',
          orderBy: 'timestamp DESC',
          limit: limit,
          offset: offset);
    } catch (e) {
      print('Error getting all audit logs: $e');
      return [];
    }
  }

  // ========== BULK OPERATIONS ==========

  /// Bulk assign requests to support workers
  Future<bool> bulkAssignRequests({
    required List<String> requestIds,
    required String supportWorkerId,
    required String coordinatorId,
  }) async {
    try {
      final db = await database;
      final now = DateTime.now().toIso8601String();
      
      for (String requestId in requestIds) {
        await db.update(
          'requests',
          {
            'support_worker_id': supportWorkerId,
            'status': 'ASSIGNED',
            'assigned_at': now,
            'updated_at': now,
          },
          where: 'id = ?',
          whereArgs: [requestId],
        );
      }
      return true;
    } catch (e) {
      print('Error in bulk assign requests: $e');
      return false;
    }
  }

  /// Get requests statistics for dashboard
  Future<Map<String, dynamic>> getRequestStatistics() async {
    try {
      final db = await database;
      
      final draftCount = Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM requests WHERE status = ?',
              ['DRAFT'])) ?? 0;
      
      final submittedCount = Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM requests WHERE status = ?',
              ['SUBMITTED'])) ?? 0;
      
      final assignedCount = Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM requests WHERE status = ?',
              ['ASSIGNED'])) ?? 0;
      
      final completedCount = Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM requests WHERE status = ?',
              ['COMPLETED'])) ?? 0;

      return {
        'draft': draftCount,
        'submitted': submittedCount,
        'assigned': assignedCount,
        'completed': completedCount,
      };
    } catch (e) {
      print('Error getting request statistics: $e');
      return {};
    }
  }

  /// Clear all data (for testing/reset purposes)
  Future<void> clearAllData() async {
    try {
      final db = await database;
      await db.delete('audit_logs');
      await db.delete('requests');
      await db.delete('users');
    } catch (e) {
      print('Error clearing data: $e');
    }
  }
}

/// In-memory mock database implementation for web platform testing
/// Provides basic Database interface methods without file system access
class InMemoryDatabase implements Database {
  final Map<String, List<Map<String, dynamic>>> _tables = {
    'users': [],
    'requests': [],
    'audit_logs': [],
  };

  @override
  Future<List<Map<String, dynamic>>> query(
    String table, {
    bool? distinct,
    List<String>? columns,
    String? where,
    List<dynamic>? whereArgs,
    String? groupBy,
    String? having,
    String? orderBy,
    int? limit,
    int? offset,
  }) async {
    List<Map<String, dynamic>> results = _tables[table] ?? [];
    
    // Apply where clause
    if (where != null && whereArgs != null) {
      results = results.where((row) {
        return _evaluateWhere(where, row, whereArgs);
      }).toList();
    }
    
    // Apply limit and offset
    if (offset != null) results = results.skip(offset).toList();
    if (limit != null) results = results.take(limit).toList();
    
    return results;
  }

  @override
  Future<int> insert(String table, Map<String, dynamic> values, {String? nullColumnHack, ConflictAlgorithm? conflictAlgorithm}) async {
    _tables[table]!.add(values);
    return _tables[table]!.length;
  }

  @override
  Future<int> update(String table, Map<String, dynamic> values, {String? where, List<dynamic>? whereArgs, ConflictAlgorithm? conflictAlgorithm}) async {
    int count = 0;
    final tableData = _tables[table] ?? [];
    for (int i = 0; i < tableData.length; i++) {
      if (where == null || _evaluateWhere(where, tableData[i], whereArgs ?? [])) {
        tableData[i].addAll(values);
        count++;
      }
    }
    return count;
  }

  @override
  Future<int> delete(String table, {String? where, List<dynamic>? whereArgs}) async {
    final tableData = _tables[table] ?? [];
    int initialCount = tableData.length;
    _tables[table] = tableData.where((row) {
      if (where == null) return false;
      return !_evaluateWhere(where, row, whereArgs ?? []);
    }).toList();
    return initialCount - _tables[table]!.length;
  }

  @override
  Future<List<Map<String, dynamic>>> rawQuery(String sql, [List<dynamic>? arguments]) async {
    print('Raw query on in-memory DB: $sql');
    return [];
  }

  @override
  Future<T?> transaction<T>(Future<T> Function(Transaction txn) action, {bool? exclusive}) async {
    return await action(this as Transaction);
  }

  @override
  Future<int> execute(String sql, [List<dynamic>? arguments]) async {
    return 0;
  }

  @override
  Future<void> close() async {}

  @override
  Future<T> batch<T>(Future<T> Function(Batch batch) updates) async {
    return await updates(this as Batch);
  }

  bool _evaluateWhere(String where, Map<String, dynamic> row, List<dynamic> whereArgs) {
    // Simple where clause evaluation
    // This is a basic implementation - for more complex cases, would need SQL parser
    if (where.contains('=')) {
      final parts = where.split('=');
      final column = parts[0].trim();
      if (whereArgs.isNotEmpty) {
        return row[column] == whereArgs[0];
      }
    }
    return true;
  }

  // Unimplemented Database methods
  @override
  int getVersion() => 1;

  @override
  Future<void> setVersion(int version) async {}

  @override
  bool isOpen() => true;

  @override
  String get path => 'in-memory';

  @override
  Future<List<Map<String, Object?>>> rawQueryCursor(String sql, [List<dynamic>? arguments]) async => [];

  @override
  Future<int> rawDelete(String sql, [List<dynamic>? arguments]) async => 0;

  @override
  Future<int> rawUpdate(String sql, [List<dynamic>? arguments]) async => 0;

  @override
  Future<void> applyUpdates(List<SqlCommand> updates) async {}

  @override
  Future<List<SqlCommand>> getUpdates() async => [];
}
