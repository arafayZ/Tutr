// Importing Flutter material design package
import 'package:flutter/material.dart';

// Importing different screens
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
        // Ensures white background for all popups/dialogs
        dialogTheme: const DialogThemeData(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
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
        '/profile': (context) => const ProfileScreen(),
        '/profile_creation': (context) => const ProfileCreationScreen(role: 'Tutor'),
        '/my_bids': (context) => const MyBidsScreen(),
        '/bid_details': (context) => const BidDetailsScreen(),
        '/edit_profile': (context) => const EditProfileScreen(),
        '/terms_conditions': (context) => const TermsConditionsScreen()
      },
    );
  }
}