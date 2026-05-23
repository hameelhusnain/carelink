import 'package:flutter/material.dart';

/// App-wide constants and theme configuration
/// Using Material 3 design system

// ========== COLOR PALETTE ==========
class AppColors {
  // Primary colors
  static const Color primary = Color(0xFF0066CC); // Blue
  static const Color primaryLight = Color(0xFF4D94FF);
  static const Color primaryDark = Color(0xFF003399);

  // Secondary colors
  static const Color secondary = Color(0xFF26A69A); // Teal
  static const Color secondaryLight = Color(0xFF4DB8AA);
  static const Color secondaryDark = Color(0xFF1B7A6E);

  // Accent colors
  static const Color accent = Color(0xFFFFA500); // Orange
  static const Color accentLight = Color(0xFFFFB84D);
  static const Color accentDark = Color(0xFFCC8400);

  // Status colors
  static const Color success = Color(0xFF4CAF50); // Green
  static const Color warning = Color(0xFFFFC107); // Amber
  static const Color error = Color(0xFFF44336); // Red
  static const Color info = Color(0xFF2196F3); // Light Blue

  // Neutral colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color gray50 = Color(0xFFFAFAFA);
  static const Color gray100 = Color(0xFFF5F5F5);
  static const Color gray200 = Color(0xFFEEEEEE);
  static const Color gray300 = Color(0xFFE0E0E0);
  static const Color gray400 = Color(0xFFBDBDBD);
  static const Color gray500 = Color(0xFF9E9E9E);
  static const Color gray600 = Color(0xFF757575);
  static const Color gray700 = Color(0xFF616161);
  static const Color gray800 = Color(0xFF424242);
  static const Color gray900 = Color(0xFF212121);

  // Priority colors
  static const Color priorityLow = Color(0xFF81C784); // Green
  static const Color priorityMedium = Color(0xFFFFA726); // Orange
  static const Color priorityHigh = Color(0xFFEF5350); // Red
  static const Color priorityUrgent = Color(0xFF8B0000); // Dark Red
}

// ========== TEXT STYLES ==========
class AppTextStyles {
  static const TextStyle headline1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.gray900,
  );

  static const TextStyle headline2 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.gray900,
  );

  static const TextStyle headline3 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.gray900,
  );

  static const TextStyle subtitle1 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.gray800,
  );

  static const TextStyle subtitle2 = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.gray700,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.gray800,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.gray700,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.gray600,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.normal,
    color: AppColors.gray600,
  );

  static const TextStyle button = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.white,
  );
}

// ========== SPACING & SIZING ==========
class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
}

class AppSizing {
  static const double buttonHeight = 48.0;
  static const double inputHeight = 56.0;
  static const double cardRadius = 12.0;
  static const double buttonRadius = 8.0;
  static const double iconSize = 24.0;
  static const double iconSizeLarge = 32.0;
  static const double iconSizeSmall = 16.0;
}

// ========== USER ROLES ==========
class UserRoles {
  static const String resident = 'RESIDENT';
  static const String coordinator = 'COORDINATOR';
  static const String supportWorker = 'SUPPORT_WORKER';
  static const String reviewer = 'REVIEWER';

  static List<String> getAll() => [resident, coordinator, supportWorker, reviewer];

  static String getDisplayName(String role) {
    switch (role) {
      case resident:
        return 'Resident/Carer';
      case coordinator:
        return 'Care Coordinator';
      case supportWorker:
        return 'Support Worker';
      case reviewer:
        return 'Safeguarding Reviewer';
      default:
        return role;
    }
  }
}

// ========== REQUEST STATUS ==========
class RequestStatus {
  static const String draft = 'DRAFT';
  static const String submitted = 'SUBMITTED';
  static const String underReview = 'UNDER_REVIEW';
  static const String assigned = 'ASSIGNED';
  static const String completed = 'COMPLETED';
  static const String verified = 'VERIFIED';
  static const String escalated = 'ESCALATED';

  static List<String> getAll() =>
      [draft, submitted, underReview, assigned, completed, verified, escalated];

  static String getDisplayName(String status) {
    switch (status) {
      case draft:
        return 'Draft';
      case submitted:
        return 'Submitted';
      case underReview:
        return 'Under Review';
      case assigned:
        return 'Assigned';
      case completed:
        return 'Completed';
      case verified:
        return 'Verified';
      case escalated:
        return 'Escalated';
      default:
        return status;
    }
  }

  static Color getStatusColor(String status) {
    switch (status) {
      case draft:
        return AppColors.gray400;
      case submitted:
        return AppColors.info;
      case underReview:
        return AppColors.warning;
      case assigned:
        return AppColors.accent;
      case completed:
        return AppColors.success;
      case verified:
        return AppColors.success;
      case escalated:
        return AppColors.error;
      default:
        return AppColors.gray400;
    }
  }
}

// ========== PRIORITY LEVELS ==========
class PriorityLevels {
  static const String low = 'LOW';
  static const String medium = 'MEDIUM';
  static const String high = 'HIGH';
  static const String urgent = 'URGENT';

  static List<String> getAll() => [low, medium, high, urgent];

  static String getDisplayName(String priority) {
    switch (priority) {
      case low:
        return 'Low';
      case medium:
        return 'Medium';
      case high:
        return 'High';
      case urgent:
        return 'Urgent';
      default:
        return priority;
    }
  }

  static Color getPriorityColor(String priority) {
    switch (priority) {
      case low:
        return AppColors.priorityLow;
      case medium:
        return AppColors.priorityMedium;
      case high:
        return AppColors.priorityHigh;
      case urgent:
        return AppColors.priorityUrgent;
      default:
        return AppColors.gray400;
    }
  }

  static int getPriorityValue(String priority) {
    switch (priority) {
      case low:
        return 1;
      case medium:
        return 2;
      case high:
        return 3;
      case urgent:
        return 4;
      default:
        return 0;
    }
  }
}

// ========== APP THEME ==========
class AppTheme {
  static ThemeData lightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColors.primary,
      colorScheme: ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.white,
        error: AppColors.error,
      ),
      scaffoldBackgroundColor: AppColors.gray50,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: 2,
        centerTitle: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizing.buttonRadius),
          ),
          elevation: 2,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizing.buttonRadius),
          ),
          side: const BorderSide(color: AppColors.primary),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizing.buttonRadius),
          borderSide: const BorderSide(color: AppColors.gray300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizing.buttonRadius),
          borderSide: const BorderSide(color: AppColors.gray300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizing.buttonRadius),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.white,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizing.cardRadius),
        ),
      ),
    );
  }

  static ThemeData darkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: AppColors.primaryLight,
      colorScheme: ColorScheme.dark(
        primary: AppColors.primaryLight,
        secondary: AppColors.secondaryLight,
        surface: AppColors.gray900,
        error: AppColors.error,
      ),
      scaffoldBackgroundColor: AppColors.gray900,
    );
  }
}

// ========== VALIDATION RULES ==========
class ValidationRules {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(value)) {
      return 'Invalid email format';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain uppercase letter';
    }
    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Password must contain lowercase letter';
    }
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain number';
    }
    if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'Password must contain special character';
    }
    return null;
  }

  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }
    if (value.length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }

  static String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    if (!RegExp(r'^[0-9+\-\s()]{10,}$').hasMatch(value)) {
      return 'Invalid phone number';
    }
    return null;
  }

  static String? validateAddress(String? value) {
    if (value == null || value.isEmpty) {
      return 'Address is required';
    }
    if (value.length < 5) {
      return 'Address must be at least 5 characters';
    }
    return null;
  }
}

// ========== API ROUTES (for future use) ==========
class ApiRoutes {
  static const String baseUrl = 'https://api.carelink.local';
  static const String login = '$baseUrl/auth/login';
  static const String register = '$baseUrl/auth/register';
  static const String requests = '$baseUrl/requests';
  static const String users = '$baseUrl/users';
}
