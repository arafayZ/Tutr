import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'onboarding_screen.dart';
import 'login_screen.dart';
import '../tutor/tutor_dashboard.dart';
import '../student/student_dashboard.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  void _navigateToNextScreen() async {
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;
    int? profileId = prefs.getInt('profileId');
    String? userRole = prefs.getString('role');
    bool isLoggedIn = profileId != null && profileId != 0;

    print('=== SPLASH SCREEN DEBUG ===');
    print('hasSeenOnboarding: $hasSeenOnboarding');
    print('profileId: $profileId');
    print('userRole: $userRole');
    print('isLoggedIn: $isLoggedIn');
    print('============================');

    if (!hasSeenOnboarding) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const OnboardingScreen()),
      );
    } else if (isLoggedIn) {
      if (userRole == 'STUDENT') {
        print('Navigating to Student Dashboard');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const StudentDashboard()),
        );
      } else if (userRole == 'TUTOR') {
        print('Navigating to Tutor Dashboard');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const TutorDashboard()),
        );
      } else {
        // If role is not set or unknown, go to login
        print(' Unknown role, going to login');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Image.asset(
          'assets/images/logo.png',
          width: 400,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}