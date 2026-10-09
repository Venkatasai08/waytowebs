import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:waytowebs_app/core/constants/app_constants.dart';
import 'package:waytowebs_app/core/theme/app_theme.dart';
import 'package:waytowebs_app/features/admin/presentation/screens/admin_dashboard_screen.dart';
import 'package:waytowebs_app/features/auth/domain/entities/user_entity.dart';
import 'package:waytowebs_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:waytowebs_app/features/auth/presentation/screens/login_screen.dart';
import 'package:waytowebs_app/features/customer/presentation/screens/customer_dashboard_screen.dart';
import 'package:waytowebs_app/features/dealer/presentation/screens/dealer_dashboard_screen.dart';
import 'package:waytowebs_app/features/plumber/presentation/screens/plumber_dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final sharedPreferences = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: const WayToWebsApp(),
    ),
  );
}

class WayToWebsApp extends ConsumerWidget {
  const WayToWebsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    Widget homeScreen;
    if (authState.user != null) {
      switch (authState.user!.role) {
        case UserRole.customer:
          homeScreen = const CustomerDashboardScreen();
          break;
        case UserRole.dealer:
          homeScreen = const DealerDashboardScreen();
          break;
        case UserRole.plumber:
          homeScreen = const PlumberDashboardScreen();
          break;
        case UserRole.admin:
          homeScreen = const AdminDashboardScreen();
          break;
      }
    } else {
      homeScreen = const LoginScreen();
    }

    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: homeScreen,
    );
  }
}
