// App Router using go_router

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/auth/auth_provider.dart';
import '../features/dashboard/dashboard_screen.dart';
import '../features/challenges/challenge_list_screen.dart';
import '../features/challenges/challenge_detail_screen.dart';
import '../features/leaderboard/leaderboard_screen.dart';
import '../features/profile/profile_screen.dart';
import '../features/intel/intel_vault_screen.dart';
import '../features/intel/intel_article_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/signup_screen.dart';
import '../features/community/community_screen.dart';
import '../features/notifications/notifications_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  // Use a notifier so GoRouter rebuilds when auth state changes
  final notifier = _AuthNotifier();

  final router = GoRouter(
    initialLocation: '/',
    refreshListenable: notifier,
    redirect: (context, state) {
      final authState = ref.read(authStateProvider);

      // While loading, don't redirect — wait for auth to resolve
      if (authState.isLoading) return null;

      final isLoggedIn = authState.hasValue && authState.value != null;
      final isAuthRoute = state.matchedLocation == '/login' ||
          state.matchedLocation == '/signup';

      if (!isLoggedIn && !isAuthRoute) return '/login';
      if (isLoggedIn && isAuthRoute) return '/';
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/challenges',
        builder: (context, state) => const ChallengeListScreen(),
      ),
      GoRoute(
        path: '/challenges/:id',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return ChallengeDetailScreen(challengeId: id);
        },
      ),
      GoRoute(
        path: '/leaderboard',
        builder: (context, state) => const LeaderboardScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/intel',
        builder: (context, state) => const IntelVaultScreen(),
      ),
      GoRoute(
        path: '/intel/:id',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return IntelArticleScreen(articleId: id);
        },
      ),
      GoRoute(
        path: '/community',
        builder: (context, state) => const CommunityScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.error}'),
      ),
    ),
  );

  // Listen to auth state changes and notify router to re-evaluate redirect
  ref.listen(authStateProvider, (_, __) => notifier.notify());

  return router;
});

/// A simple ChangeNotifier that lets GoRouter listen to auth state changes.
class _AuthNotifier extends ChangeNotifier {
  _AuthNotifier();

  void notify() => notifyListeners();
}
