// Import the standard Flutter material library for UI widgets
import 'package:flutter/material.dart';
// Import the signup screen so we can move to it later
import 'signup_screen.dart';

// Creating a StatelessWidget because this screen doesn't change its own data
class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Setting the main background color to white
      backgroundColor: Colors.white,
      // SafeArea keeps the content away from the phone's notch and status bar
      body: SafeArea(
        child: Padding(
          // Adding 24 pixels of space on the left and right sides
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            // Aligning text and cards to the left (start)
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Adding some space at the very top
              const SizedBox(height: 40),

              // 1. TUTR Logo Section
              Center(
                child: Column(
                  children: [
                    // Displaying the app logo from the assets folder
                    Image.asset(
                      'assets/images/logo_vertical.png',
                      height: 180, // Size of the logo
                      fit: BoxFit.contain, // Ensures the logo fits inside the height
                    ),
                  ],
                ),
              ),

              // Adding space between the logo and the text
              const SizedBox(height: 50),

              // 2. Header Text
              const Text(
                "Continue as",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              // Small gap between the big title and small subtitle
              const SizedBox(height: 8),
              const Text(
                "Select whether you're here to learn or teach.",
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.black54, // A softer grey-black color
                ),
              ),

              // Gap before the cards start
              const SizedBox(height: 40),

              // 3. Tutor Selection Card
              _buildRoleCard(
                context,
                title: "TUTOR",
                subtitle: "Let's connect you with\neager students faster.",
                imagePath: 'assets/images/teacher_icon.png',
                // When tapped, go to SignupScreen and tell it the user is a "Tutor"
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SignupScreen(role: "Tutor")),
                ),
              ),

              // Gap between the two cards
              const SizedBox(height: 20),

              // 4. Student Selection Card
              _buildRoleCard(
                context,
                title: "STUDENT",
                subtitle: "Let's help you find the\nbest tutor faster.",
                imagePath: 'assets/images/student_icon.png',
                // When tapped, go to SignupScreen and tell it the user is a "Student"
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SignupScreen(role: "Student")),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // A helper function to build the clickable grey cards for Tutor/Student
  Widget _buildRoleCard(
      BuildContext context, {
        required String title,
        required String subtitle,
        required String imagePath,
        required VoidCallback onTap,
      }) {
    return GestureDetector(
      // Makes the entire card clickable
      onTap: onTap,
      child: Container(
        // Adding padding inside the card
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: BoxDecoration(
          color: const Color(0xFFE0E0E0), // The light grey background color
          borderRadius: BorderRadius.circular(25), // Rounded corners for the card
        ),
        child: Row(
          children: [
            // Character Illustration (Image on the left of the card)
            SizedBox(
              width: 80,
              height: 80,
              child: Image.asset(
                imagePath,
                fit: BoxFit.contain,
                // If the image file is missing, show a default person icon instead
                errorBuilder: (context, error, stackTrace) {
                  return const CircleAvatar(
                    backgroundColor: Colors.white54,
                    child: Icon(Icons.person, color: Colors.black, size: 40),
                  );
                },
              ),
            ),
            // Space between the image and the text
            const SizedBox(width: 20),

            // Text Content (Title and Subtitle)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min, // Takes up only the space it needs
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                      letterSpacing: 0.5,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black54,
                      height: 1.2, // Adjusts the space between lines of text
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}