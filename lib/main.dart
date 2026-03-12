// Importing Flutter material design package
import 'package:flutter/material.dart';
// This imports the core Flutter Material UI components, like Scaffold, Text, Buttons, etc.

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
// These imports bring in all the screens of the app so they can be used in routing.

// The main function is the entry point of the Flutter app
void main() {
  runApp(const TutrApp());
  // runApp launches the app and inflates the widget tree starting from TutrApp
}

// The root widget of the app
class TutrApp extends StatelessWidget {
  const TutrApp({super.key}); // Constructor with key for widget tree identification

  @override
  Widget build(BuildContext context) {
    // The build method describes the UI structure of this widget
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Removes the debug banner in the top-right corner
      title: 'TUTR', // Title of the app, used by Android/iOS for app switcher
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF8F9FB),
        // Sets the default background color for all Scaffold widgets
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.black,
          primary: Colors.black,
          surface: Colors.white,
        ),
        // Sets primary colors and surface colors using a seed color
        dialogTheme: const DialogThemeData(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
        ),
        // Ensures dialogs/popups have a white background instead of default
        useMaterial3: true, // Enables Material Design 3 styling for modern look
      ),
      home: const SplashScreen(),
      // Initial screen shown when app starts, here it's the SplashScreen
      routes: {
        '/login': (context) => const LoginScreen(),
        '/role_selection': (context) => const RoleSelectionScreen(),
        '/tutor_dashboard': (context) => const TutorDashboard(),
        '/student_dashboard': (context) => const StudentDashboard(),
        '/tutor_verification': (context) => const TutorVerificationScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/connection': (context) => const ConnectionScreen(),
        '/inbox': (context) => const InboxScreen(),
        '/profile_creation': (context) =>
        const ProfileCreationScreen(role: 'Tutor'),
        '/my_bids': (context) => const MyBidsScreen(),
        '/bid_details': (context) => const BidDetailsScreen(),
        '/edit_profile': (context) => const EditProfileScreen(),
        '/terms_conditions': (context) => const TermsConditionsScreen(),
        '/chat_details': (context) => const ChatDetailsScreen(userName: 'User'),
        '/security': (context) => const SecurityScreen(),
        '/unavailable_courses': (context) => const UnavailableCoursesScreen(),
      },
      // Defines named routes for navigation throughout the app.
      // Each key is a string route, and value is a function returning the screen widget.
    );
  }
}