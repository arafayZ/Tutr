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
// New imports for the category and details logic
import 'tutor/student_category_screen.dart';
import 'tutor/student_details_screen.dart';

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

        return null;
      },

      routes: {
        '/login': (context) => const LoginScreen(),
        '/role_selection': (context) => const RoleSelectionScreen(),
        '/tutor_dashboard': (context) => const TutorDashboard(),
        '/student_dashboard': (context) => const StudentDashboard(),
        '/tutor_verification': (context) => const TutorVerificationScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/inbox': (context) => const InboxScreen(),
        '/profile_creation': (context) => const ProfileCreationScreen(role: 'Tutor'),
        '/my_bids': (context) => const MyBidsScreen(),
        '/student_category': (context) => const StudentCategoryScreen(),
        '/edit_profile': (context) => const EditProfileScreen(),
        '/terms_conditions': (context) => const TermsConditionsScreen(),
        '/chat_details': (context) => const ChatDetailsScreen(userName: 'User'),
        '/security': (context) => const SecurityScreen(),
        '/unavailable_courses': (context) => const UnavailableCoursesScreen(),
      },
    );
  }
}