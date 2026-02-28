import 'package:flutter/material.dart';
import 'signup_screen.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),

              // 1. TUTR Logo Section
              Center(
                child: Column(
                  children: [
                    Image.asset(
                      'assets/images/logo_vertical.png',
                      height: 180, // Adjusted height for better balance
                      fit: BoxFit.contain,
                    ),
                  ],
                ),
              ),

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
              const SizedBox(height: 8),
              const Text(
                "Select whether you're here to learn or teach.",
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.black54,
                ),
              ),

              const SizedBox(height: 40),

              // 3. Tutor Selection Card
              _buildRoleCard(
                context,
                title: "TUTOR",
                subtitle: "Let's connect you with\neager students faster.",
                imagePath: 'assets/images/teacher_icon.png',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SignupScreen(role: "Tutor")),
                ),
              ),

              const SizedBox(height: 20),

              // 4. Student Selection Card
              _buildRoleCard(
                context,
                title: "STUDENT",
                subtitle: "Let's help you find the\nbest tutor faster.",
                imagePath: 'assets/images/student_icon.png',
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

  Widget _buildRoleCard(
      BuildContext context, {
        required String title,
        required String subtitle,
        required String imagePath,
        required VoidCallback onTap,
      }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: BoxDecoration(
          color: const Color(0xFFE0E0E0), // Original grey shade
          borderRadius: BorderRadius.circular(25),
        ),
        child: Row(
          children: [
            // Character Illustration
            SizedBox(
              width: 80,
              height: 80,
              child: Image.asset(
                imagePath,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const CircleAvatar(
                    backgroundColor: Colors.white54,
                    child: Icon(Icons.person, color: Colors.black, size: 40),
                  );
                },
              ),
            ),
            const SizedBox(width: 20),

            // Text Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
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
                      height: 1.2,
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