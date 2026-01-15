import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/auth/role_selection_screen.dart';
import '../../screens/citizen/citizen_home_screen.dart';
import '../../screens/citizen/report_complaint_screen.dart';
import '../../screens/citizen/complaint_detail_screen.dart';
import '../../screens/citizen/my_complaints_screen.dart';
import '../../screens/citizen/chatbot_screen.dart';
import '../../screens/official/official_home_screen.dart';
import '../../screens/official/task_detail_screen.dart';
import '../../screens/admin/admin_dashboard_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/role-selection',
    routes: [
      GoRoute(
        path: '/role-selection',
        builder: (context, state) => const RoleSelectionScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) {
          final role = state.extra as String?;
          return LoginScreen(role: role);
        },
      ),
      GoRoute(
        path: '/citizen-home',
        builder: (context, state) => const CitizenHomeScreen(),
      ),
      GoRoute(
        path: '/report-complaint',
        builder: (context, state) => const ReportComplaintScreen(),
      ),
      GoRoute(
        path: '/complaint-detail/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return ComplaintDetailScreen(complaintId: id);
        },
      ),
      GoRoute(
        path: '/my-complaints',
        builder: (context, state) => const MyComplaintsScreen(),
      ),
      GoRoute(
        path: '/chatbot',
        builder: (context, state) => const ChatbotScreen(),
      ),
      GoRoute(
        path: '/official-home',
        builder: (context, state) => const OfficialHomeScreen(),
      ),
      GoRoute(
        path: '/task-detail/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return TaskDetailScreen(complaintId: id);
        },
      ),
      GoRoute(
        path: '/admin-dashboard',
        builder: (context, state) => const AdminDashboardScreen(),
      ),
    ],
  );
}
