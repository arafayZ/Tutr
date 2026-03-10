// Import Flutter material design package
import 'package:flutter/material.dart';
// Import custom tab header widget from your project
import '../widgets/custom_tab_header.dart';

// Stateless widget for Terms & Conditions screen
class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Background color matches other screens like Reviews
      backgroundColor: const Color(0xFFF8F9FB),

      // Allows content to extend behind potential bottom navigation
      extendBody: true,

      body: Column(
        children: [
          // Header using your reusable CustomTabHeader widget
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

          // Main content area scrollable
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(
                left: 24,
                right: 24,
                top: 20,
                bottom: 40, // Extra padding at bottom for comfortable scroll
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, // Align text left
                children: [
                  // Section 1 title
                  _buildSectionTitle("Condition & Attending"),
                  // Section 1 body text
                  _buildContentText(
                    "By signing up, you confirm that you are at least 18 years old and that all the information you provide is accurate and up-to-date. Both students and tutors agree to communicate respectfully and follow all guidelines provided within the app. Tutors are responsible for the correctness of their course details, schedules, and availability.",
                  ),

                  const SizedBox(height: 32), // Space between sections

                  // Section 2 title
                  _buildSectionTitle("Terms & Use"),
                  // Section 2 body text
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

  // Helper widget to create section headings consistently
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0), // Space below heading
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

  // Helper widget to create body text consistently
  Widget _buildContentText(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        color: Colors.black,
        height: 1.6, // Line height for readability
      ),
    );
  }
}