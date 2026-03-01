// Import the Flutter material library for the UI and Scaffold
import 'package:flutter/material.dart';
// Import the next screen (Onboarding) to navigate to it after the timer
import 'onboarding_screen.dart';

// Creating a StatefulWidget because we need to start a timer as soon as the screen loads
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  // initState is a special function that runs exactly once when the screen is first created
  @override
  void initState() {
    super.initState();
    // Start the countdown to move to the next screen
    _navigateToOnboarding();
  }

  // The logic to wait 3 seconds and then switch screens
  void _navigateToOnboarding() async {
    // Tell the app to pause here for 3 seconds
    await Future.delayed(const Duration(seconds: 3));

    // Safety check: if the user closed the app during those 3 seconds, don't do anything
    if (!mounted) return;

    // Move to the OnboardingScreen and "Replace" this screen so the user can't go back to the splash
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const OnboardingScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Setting the splash screen background to solid black
      backgroundColor: Colors.black,
      body: Center(
        // Placing the logo image exactly in the middle of the screen
        child: Image.asset(
          'assets/images/logo.png', // The path to your logo file
          width: 500, // Setting the width of the logo
          fit: BoxFit.contain, // Ensures the whole logo fits inside the width
        ),
      ),
    );
  }
}