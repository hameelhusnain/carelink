import 'package:flutter/foundation.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import '../core/database/database_helper.dart';
import '../models/user.dart';

/// AuthProvider handles all authentication and authorization logic
/// Uses ChangeNotifier for state management with Provider package
class AuthProvider extends ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  
  User? _currentUser;
  bool _isLoggedIn = false;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  User? get currentUser => _currentUser;
  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Check if user is authenticated
  bool get isAuthenticated => _currentUser != null;

  /// Get user's role
  String? get userRole => _currentUser?.role;

  /// Check if user is resident
  bool get isResident => _currentUser?.role == 'RESIDENT';

  /// Check if user is coordinator
  bool get isCoordinator => _currentUser?.role == 'COORDINATOR';

  /// Check if user is support worker
  bool get isSupportWorker => _currentUser?.role == 'SUPPORT_WORKER';

  /// Check if user is reviewer
  bool get isReviewer => _currentUser?.role == 'REVIEWER';

  /// Initialize auth state from stored data if available
  Future<void> initializeAuth() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      // In a real app, you might check SharedPreferences for stored session
      // For now, this is just initialization
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('Error initializing auth: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Login user with email and password
  Future<bool> login({required String email, required String password}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Validate input
      if (email.isEmpty || password.isEmpty) {
        _errorMessage = 'Email and password are required';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Get user from database
      final userMap = await _dbHelper.getUserByEmail(email);
      if (userMap == null) {
        _errorMessage = 'Invalid email or password';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Verify password
      final passwordHash = sha256.convert(password.codeUnits).toString();
      if (userMap['password_hash'] != passwordHash) {
        _errorMessage = 'Invalid email or password';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Check if user is active
      if (userMap['is_active'] != 1) {
        _errorMessage = 'Your account has been deactivated';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Login successful
      _currentUser = User.fromMap(userMap);
      _isLoggedIn = true;
      _errorMessage = null;
      _isLoading = false;
      notifyListeners();
      
      print('User logged in: ${_currentUser?.email} (${_currentUser?.role})');
      return true;
    } catch (e) {
      _errorMessage = 'Login failed: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Register a new user (primarily for residents/carers)
  Future<bool> register({
    required String email,
    required String password,
    required String confirmPassword,
    required String fullName,
    required String role,
    String? phoneNumber,
    String? address,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Validate input
      if (email.isEmpty ||
          password.isEmpty ||
          fullName.isEmpty ||
          confirmPassword.isEmpty) {
        _errorMessage = 'All fields are required';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Validate email format
      if (!_isValidEmail(email)) {
        _errorMessage = 'Invalid email format';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Validate password strength
      if (!_isStrongPassword(password)) {
        _errorMessage = 'Password must be at least 8 characters with uppercase, lowercase, number, and special character';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Check password confirmation
      if (password != confirmPassword) {
        _errorMessage = 'Passwords do not match';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Check if email already exists
      final existingUser = await _dbHelper.getUserByEmail(email);
      if (existingUser != null) {
        _errorMessage = 'Email already registered';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Hash password
      final passwordHash = sha256.convert(password.codeUnits).toString();
      final userId = const Uuid().v4();

      // Register user
      final success = await _dbHelper.insertUser(
        id: userId,
        email: email,
        passwordHash: passwordHash,
        fullName: fullName,
        role: role,
        phoneNumber: phoneNumber,
        address: address,
      );

      if (!success) {
        _errorMessage = 'Registration failed. Please try again.';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      _isLoading = false;
      notifyListeners();
      
      print('User registered: $email ($role)');
      return true;
    } catch (e) {
      _errorMessage = 'Registration failed: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Logout current user
  Future<void> logout() async {
    _currentUser = null;
    _isLoggedIn = false;
    _errorMessage = null;
    notifyListeners();
    print('User logged out');
  }

  /// Update user profile
  Future<bool> updateProfile({
    required String fullName,
    String? phoneNumber,
    String? address,
  }) async {
    if (_currentUser == null) {
      _errorMessage = 'No user logged in';
      return false;
    }

    try {
      final success = await _dbHelper.updateUser(
        userId: _currentUser!.id,
        fullName: fullName,
        phoneNumber: phoneNumber,
        address: address,
      );

      if (success) {
        _currentUser = _currentUser!.copyWith(
          fullName: fullName,
          phoneNumber: phoneNumber,
          address: address,
        );
        notifyListeners();
      }

      return success;
    } catch (e) {
      _errorMessage = 'Update failed: $e';
      return false;
    }
  }

  /// Get user by ID
  Future<User?> getUserById(String userId) async {
    try {
      final userMap = await _dbHelper.getUserById(userId);
      if (userMap != null) {
        return User.fromMap(userMap);
      }
      return null;
    } catch (e) {
      print('Error getting user by ID: $e');
      return null;
    }
  }

  /// Get users by role (for assignment, etc.)
  Future<List<User>> getUsersByRole(String role) async {
    try {
      final userMaps = await _dbHelper.getUsersByRole(role);
      return userMaps.map((map) => User.fromMap(map)).toList();
    } catch (e) {
      print('Error getting users by role: $e');
      return [];
    }
  }

  /// Check if email is valid
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  /// Check if password is strong enough
  /// Requirements: min 8 chars, uppercase, lowercase, number, special char
  bool _isStrongPassword(String password) {
    if (password.length < 8) return false;
    if (!password.contains(RegExp(r'[A-Z]'))) return false;
    if (!password.contains(RegExp(r'[a-z]'))) return false;
    if (!password.contains(RegExp(r'[0-9]'))) return false;
    if (!password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) return false;
    return true;
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
