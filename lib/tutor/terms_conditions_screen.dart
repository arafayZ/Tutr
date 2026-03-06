import 'package:flutter/material.dart';
// Ensure this path matches your project structure
import '../widgets/custom_tab_header.dart';

class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Matching the background color from your Reviews screen
      backgroundColor: const Color(0xFFF8F9FB),

      // Setting to true allows content to flow correctly if you add a bottom bar later
      extendBody: true,

      body: Column(
        children: [
          // Header using the same CustomTabHeader logic as Reviews screen
          const CustomTabHeader(
            title: Text(
              "Terms & Conditions",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),

          // Content Area
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(
                left: 24,
                right: 24,
                top: 20,
                bottom: 40,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle("Condition & Attending"),
                  _buildContentText(
                    "By signing up, you confirm that you are at least 18 years old and that all the information you provide is accurate and up-to-date. Both students and tutors agree to communicate respectfully and follow all guidelines provided within the app. Tutors are responsible for the correctness of their course details, schedules, and availability.",
                  ),

                  const SizedBox(height: 32),

                  _buildSectionTitle("Terms & Use"),
                  _buildContentText(
                    "All payments and fees made through the app are final. The platform is not responsible for any content or interactions shared between users. By creating an account, you acknowledge and accept these terms and conditions.",
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper for Section Headings
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }

  // Helper for Body Text
  Widget _buildContentText(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        color: Colors.black,
        height: 1.6, // Increased line height for better readability
      ),
    );
  }
}