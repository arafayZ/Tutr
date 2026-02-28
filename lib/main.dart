import 'package:flutter/material.dart';
import 'splash_screen.dart';
import 'login_screen.dart';
import 'role_selection_screen.dart';
import 'profile_creation_screen.dart';
import 'tutor_verification_screen.dart'; // Added this import
import 'tutor_dashboard.dart';
import 'student_dashboard.dart';

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
        useMaterial3: true,
      ),
      // The app starts at the Splash Screen
      home: const SplashScreen(),

      routes: {
        '/login': (context) => const LoginScreen(),
        '/role_selection': (context) => const RoleSelectionScreen(),

        // Named routes for dashboards
        '/tutor_dashboard': (context) => const TutorDashboard(),
        '/student_dashboard': (context) => const StudentDashboard(),

        // Verification screen route
        '/tutor_verification': (context) => const TutorVerificationScreen(),

        // Default profile creation route (Used mainly as a fallback)
        '/profile_creation': (context) => const ProfileCreationScreen(role: 'Tutor'),
      },
    );
  }
}