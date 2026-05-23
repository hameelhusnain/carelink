import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/constants/app_constants.dart';
import 'providers/auth_provider.dart';
import 'providers/request_provider.dart';
import 'screens/auth/login_screen.dart';

/// CareLink - Welfare Check-in Management System
/// A mobile app for Northampton Council to manage non-emergency welfare check-ins
/// for vulnerable residents across multiple user roles.
///
/// Main entry point for the application with:
/// - Provider state management setup
/// - Theme configuration (Material 3)
/// - Route management and authentication
/// - Role-based navigation
void main() async {
  // Initialize Flutter binding
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize database (optional - can be done on first use)
  // final db = DatabaseHelper();
  // await db.database;

  runApp(
    /// Provider setup for state management
    MultiProvider(
      providers: [
        /// Authentication provider for managing user login/registration
        ChangeNotifierProvider(
          create: (context) => AuthProvider()..initializeAuth(),
        ),
        /// Request provider for managing welfare check requests
        ChangeNotifierProvider(
          create: (context) => RequestProvider(),
        ),
        // Additional providers can be added here as development progresses
        // - AuditLogProvider
        // - etc.
      ],
      child: const CareLinkApp(),
    ),
  );
}

/// Main CareLink Application Widget
class CareLinkApp extends StatelessWidget {
  const CareLinkApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CareLink',
      debugShowCheckedModeBanner: false,

      /// Theme configuration using Material 3
      theme: AppTheme.lightTheme(),
      darkTheme: AppTheme.darkTheme(),
      themeMode: ThemeMode.light,

      /// Home screen routing based on authentication state
      home: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          // If user is logged in, navigate to appropriate dashboard
          if (authProvider.isLoggedIn && authProvider.currentUser != null) {
            return _getHomeScreenByRole(authProvider.currentUser!.role);
          }
          // Otherwise show login screen
          return const LoginScreen();
        },
      ),

      /// Named routes for navigation
      routes: {
        '/login': (context) => const LoginScreen(),
        // Additional routes will be added as screens are developed
        // '/resident-home': (context) => const ResidentHomeScreen(),
        // '/coordinator-home': (context) => const CoordinatorHomeScreen(),
        // '/support-worker-home': (context) => const SupportWorkerHomeScreen(),
        // '/reviewer-home': (context) => const ReviewerHomeScreen(),
      },

      /// Handle navigation errors
      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(title: const Text('Error')),
            body: const Center(
              child: Text('Route not found'),
            ),
          ),
        );
      },
    );
  }

  /// Get the appropriate home screen based on user role
  Widget _getHomeScreenByRole(String role) {
    switch (role) {
      case UserRoles.resident:
        // TODO: Create and return ResidentHomeScreen
        return const _PlaceholderScreen(
          title: 'Resident Dashboard',
          role: 'Resident/Carer',
        );
      case UserRoles.coordinator:
        // TODO: Create and return CoordinatorHomeScreen
        return const _PlaceholderScreen(
          title: 'Coordinator Dashboard',
          role: 'Care Coordinator',
        );
      case UserRoles.supportWorker:
        // TODO: Create and return SupportWorkerHomeScreen
        return const _PlaceholderScreen(
          title: 'Support Worker Dashboard',
          role: 'Support Worker',
        );
      case UserRoles.reviewer:
        // TODO: Create and return ReviewerHomeScreen
        return const _PlaceholderScreen(
          title: 'Reviewer Dashboard',
          role: 'Safeguarding Reviewer',
        );
      default:
        return const _PlaceholderScreen(
          title: 'Unknown Role',
          role: 'Unknown',
        );
    }
  }
}

/// Temporary placeholder screen while role-specific dashboards are being built
class _PlaceholderScreen extends StatelessWidget {
  final String title;
  final String role;

  const _PlaceholderScreen({
    required this.title,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await Provider.of<AuthProvider>(context, listen: false)
                  .logout();
              if (context.mounted) {
                Navigator.of(context).pushReplacementNamed('/login');
              }
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.build_outlined,
              size: 64,
              color: AppColors.primary,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Welcome, $role!',
              style: AppTextStyles.headline3,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.md),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Text(
                'Dashboard screens are under development.\nCheck back soon for the full application.',
                style: AppTextStyles.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            Consumer<AuthProvider>(
              builder: (context, authProvider, _) {
                return ElevatedButton.icon(
                  icon: const Icon(Icons.logout),
                  label: const Text('Logout'),
                  onPressed: () async {
                    await authProvider.logout();
                    if (context.mounted) {
                      Navigator.of(context).pushReplacementNamed('/login');
                    }
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
