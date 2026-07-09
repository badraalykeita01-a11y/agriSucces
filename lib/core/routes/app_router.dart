import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/auth_provider.dart';
import '../../screens/about/about_screen.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/auth/register_screen.dart';
import '../../screens/diagnosis/diagnosis_result_screen.dart';
import '../../screens/diagnosis/diagnosis_screen.dart';
import '../../screens/history/history_screen.dart';
import '../../screens/home/home_screen.dart';
import '../../screens/main/main_screen.dart';
import '../../screens/profile/profile_screen.dart';
import 'app_routes.dart';
import '../../screens/splash/splash_screen.dart';


final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

class AppRouter {
static final GoRouter router = GoRouter(
navigatorKey: rootNavigatorKey,
initialLocation: AppRoutes.splash,
routes: [
  GoRoute(
  path: AppRoutes.splash,
  builder: (context, state) => const SplashScreen(),
),
GoRoute(
path: AppRoutes.login,
builder: (context, state) => const LoginScreen(),
),
GoRoute(
path: AppRoutes.register,
builder: (context, state) => const RegisterScreen(),
),
ShellRoute(
builder: (context, state, child) {
return MainScreen(child: child);
},
routes: [
GoRoute(
path: AppRoutes.home,
builder: (context, state) => const HomeScreen(),
),
GoRoute(
path: AppRoutes.diagnosis,
builder: (context, state) => const DiagnosisScreen(),
),
GoRoute(
path: AppRoutes.history,
builder: (context, state) => const HistoryScreen(),
),
GoRoute(
path: AppRoutes.profile,
builder: (context, state) => const ProfileScreen(),
),
],
),
GoRoute(
path: AppRoutes.diagnosisResult,
builder: (context, state) {
final extra = state.extra as Map<String, dynamic>;

      return DiagnosisResultScreen(
        prediction: extra['prediction'],
        imageFile: extra['imageFile'],
      );
    },
  ),
  GoRoute(
    path: AppRoutes.about,
    builder: (context, state) => const AboutScreen(),
  ),
],
redirect: (context, state) {
  final container = ProviderScope.containerOf(context);
  final sessionState = container.read(authSessionProvider);

  final currentPath = state.matchedLocation;
  final isOnAuthPage =
      currentPath == AppRoutes.login || currentPath == AppRoutes.register;

  if (sessionState.isLoading) {
    return null;
  }

  final user = sessionState.valueOrNull;

  if (user == null && !isOnAuthPage) {
    return AppRoutes.login;
  }

  if (user != null && isOnAuthPage) {
    return AppRoutes.home;
  }

  return null;
},

);
}
