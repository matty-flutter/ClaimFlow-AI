import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:claimflow_ai/pages/dashboard_page.dart';
import 'package:claimflow_ai/pages/claim_detail_page.dart';
import 'package:claimflow_ai/pages/all_claims_page.dart';
import 'package:claimflow_ai/pages/claims_analytics_page.dart';
import 'package:claimflow_ai/pages/high_risk_page.dart';
import 'package:claimflow_ai/pages/pending_review_page.dart';

/// GoRouter configuration for app navigation
///
/// This uses go_router for declarative routing, which provides:
/// - Type-safe navigation
/// - Deep linking support (web URLs, app links)
/// - Easy route parameters
/// - Navigation guards and redirects
///
/// To add a new route:
/// 1. Add a route constant to AppRoutes below
/// 2. Add a GoRoute to the routes list
/// 3. Navigate using context.go() or context.push()
/// 4. Use context.pop() to go back.
class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.home,
    routes: [
      GoRoute(
        path: AppRoutes.home,
        name: 'home',
        pageBuilder: (context, state) => const NoTransitionPage(
          child: DashboardPage(),
        ),
      ),
      GoRoute(
        path: '/claim/:id',
        name: 'claimDetail',
        pageBuilder: (context, state) {
          final id = state.pathParameters['id']!;
          return NoTransitionPage(
            child: ClaimDetailPage(claimId: id),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.allClaims,
        name: 'allClaims',
        pageBuilder: (context, state) => const NoTransitionPage(
          child: AllClaimsPage(),
        ),
      ),
      GoRoute(
        path: AppRoutes.analytics,
        name: 'analytics',
        pageBuilder: (context, state) => const NoTransitionPage(
          child: ClaimsAnalyticsPage(),
        ),
      ),
      GoRoute(
        path: AppRoutes.highRisk,
        name: 'highRisk',
        pageBuilder: (context, state) => const NoTransitionPage(
          child: HighRiskPage(),
        ),
      ),
      GoRoute(
        path: AppRoutes.pendingReview,
        name: 'pendingReview',
        pageBuilder: (context, state) => const NoTransitionPage(
          child: PendingReviewPage(),
        ),
      ),
    ],
  );
}

/// Route path constants
/// Use these instead of hard-coding route strings
class AppRoutes {
  static const String home = '/';
  static const String allClaims = '/all-claims';
  static const String analytics = '/analytics';
  static const String highRisk = '/high-risk';
  static const String pendingReview = '/pending-review';
}
