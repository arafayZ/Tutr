// Importing Flutter material design package
import 'package:flutter/material.dart';

// Importing different screens from signup folder
import 'signup/splash_screen.dart';
import 'signup/login_screen.dart';
import 'signup/role_selection_screen.dart';
import 'signup/profile_creation_screen.dart';
import 'signup/tutor_verification_screen.dart';

// Importing tutor and student dashboards
import 'tutor/tutor_dashboard.dart';
import 'student/student_dashboard.dart';

// --- NEW IMPORTS ---
// Replace 'your_project_name' with your actual package name or relative path
import 'tutor/my_bids_screen.dart';

// Main function where the app starts
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
        // Matches the background color used in your Bids screens
        scaffoldBackgroundColor: const Color(0xFFF8F9FB),

        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.black,
          primary: Colors.black,
          surface: Colors.white,
        ),

        // Global Dialog Theme to ensure white backgrounds per your requirement
        dialogTheme: const DialogThemeData(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white, // Prevents the purple tint in Material 3
        ),

        useMaterial3: true,
      ),

      home: const SplashScreen(),

      routes: {
        '/login': (context) => const LoginScreen(),
        '/role_selection': (context) => const RoleSelectionScreen(),
        '/tutor_dashboard': (context) => const TutorDashboard(),
        '/student_dashboard': (context) => const StudentDashboard(),
        '/tutor_verification': (context) => const TutorVerificationScreen(),
        '/profile_creation': (context) => const ProfileCreationScreen(role: 'Tutor'),

        // --- NEW ROUTES ---
        '/my_bids': (context) => const MyBidsScreen(),
        '/bid_details': (context) => const BidDetailsScreen(),
      },
    );
  }
}