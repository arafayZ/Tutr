// Import Flutter material design package
import 'package:flutter/material.dart';

// Importing different TUTOR screens
import 'signup/splash_screen.dart';
import 'signup/login_screen.dart';
import 'signup/role_selection_screen.dart';
import 'signup/profile_creation_screen.dart';
import 'signup/tutor_verification_screen.dart';
import 'tutor/tutor_dashboard.dart';
import 'student/student_dashboard.dart';
import 'tutor/my_bids_screen.dart';
import 'tutor/profile_screen.dart';
import 'tutor/edit_profile_screen.dart';
import 'tutor/terms_conditions_screen.dart';
import 'tutor/connection_screen.dart';
import 'tutor/inbox_screen.dart';
import 'tutor/chat_details_screen.dart';
import 'tutor/security_screen.dart';
import 'tutor/unavailable_courses_screen.dart';
import 'tutor/notifications_screen.dart';
import 'tutor/student_category_screen.dart';
import 'tutor/student_details_screen.dart';
import 'tutor/course_category_screen.dart';

// NEW IMPORTS for Student Management
import 'tutor/my_students_list_screen.dart';
import 'tutor/student_profile_screen.dart';

void main() {
  runApp(const TutrApp());
}

class TutrApp extends StatelessWidget {
  const TutrApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TUTR',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF8F9FB),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.black,
          primary: Colors.black,
          surface: Colors.white,
        ),
        dialogTheme: const DialogThemeData(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          titleTextStyle: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
          contentTextStyle: TextStyle(color: Colors.black87, fontSize: 16),
        ),
        useMaterial3: true,
      ),
      home: const SplashScreen(),

      onGenerateRoute: (settings) {
        // Handle the Connection Screen route
        if (settings.name == '/connection') {
          final String studentName = settings.arguments as String? ?? "Student";
          return MaterialPageRoute(
            builder: (context) => ConnectionScreen(studentName: studentName),
          );
        }

        // Handle the Student Details route (Metric, Inter, etc.)
        if (settings.name == '/student_details') {
          final String category = settings.arguments as String? ?? "Metric";
          return MaterialPageRoute(
            builder: (context) => StudentDetailsScreen(categoryName: category),
          );
        }

        // Handle My Students List (Passing the connection data)
        if (settings.name == '/my_students_list') {
          final List<Map<String, dynamic>> connections =
              settings.arguments as List<Map<String, dynamic>>? ?? [];
          return MaterialPageRoute(
            builder: (context) => MyStudentsListScreen(connections: connections),
          );
        }

        // Handle Student Profile (Passing the StudentDetails object)
        if (settings.name == '/student_profile_details') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => StudentProfileScreen(
              student: args['student'] as StudentDetails,
              onDisconnect: args['onDisconnect'] as Function(String),
            ),
          );
        }

        return null;
      },

      routes: {
        '/login': (context) => const LoginScreen(),
        '/role_selection': (context) => const RoleSelectionScreen(),
        '/tutor_dashboard': (context) => const TutorDashboard(),
        '/student_dashboard': (context) => const StudentDashboard(),
        // FIXED: Added arguments for tutor_verification
        '/tutor_verification': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
          return TutorVerificationScreen(userId: args?['userId'] ?? 0);
        },
        '/profile': (context) => const ProfileScreen(),
        '/inbox': (context) => const InboxScreen(),
        // FIXED: Added arguments for profile_creation
        '/profile_creation': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return ProfileCreationScreen(
            role: args['role'],
            userId: args['userId'],
          );
        },
        '/my_bids': (context) => const MyBidsScreen(),
        '/student_category': (context) => const StudentCategoryScreen(),
        '/course_category': (context) => const CourseCategoryScreen(),
        '/edit_profile': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return EditProfileScreen(profileId: args['profileId']);
        },
        '/terms_conditions': (context) => const TermsConditionsScreen(),
        '/chat_details': (context) => const ChatDetailsScreen(userName: 'User'),
        '/security': (context) => const SecurityScreen(),
        '/unavailable_courses': (context) => const UnavailableCoursesScreen(),
        '/notifications': (context) => const NotificationsScreen(),
      },
    );
  }
}