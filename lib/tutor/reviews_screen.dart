import 'package:flutter/material.dart';
import '../widgets/custom_bottom_nav.dart';
import '../widgets/custom_tab_header.dart';
import 'add_course_screen.dart'; // Import ensures the FAB can navigate here

class ReviewsScreen extends StatelessWidget {
  const ReviewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      // Setting to true allows the list content to scroll behind the notched bottom bar
      extendBody: true,
      body: Column(
        children: [
          // Header using the cleaned CustomTabHeader widget
          const CustomTabHeader(
            title: Text(
              "Reviews",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(
                left: 20,
                right: 20,
                top: 15,
                bottom: 120, // Extra bottom padding so the last review clears the FAB
              ),
              itemCount: 8, // Placeholder count
              itemBuilder: (context, index) {
                return const _ReviewBox();
              },
            ),
          ),
        ],
      ),

      // --- UPDATED FLOATING ACTION BUTTON ---
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigates directly to the Add Course Screen
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddCourseScreen()),
          );
        },
        backgroundColor: Colors.black, // Consistent black color for all screens
        shape: const CircleBorder(),
        elevation: 4,
        child: const Icon(Icons.add, color: Colors.white, size: 32),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      bottomNavigationBar: const CustomBottomNav(currentIndex: -1),
    );
  }
}

// Reusable Review Card Component
class _ReviewBox extends StatelessWidget {
  const _ReviewBox();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            // Modern syntax to avoid 'withOpacity' deprecation
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 22,
                backgroundColor: Color(0xFFEDF2FF),
                child: Icon(Icons.person, color: Color(0xFF0961F5)),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Student Name",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      "24 Oct 2025",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              _buildStarRating(4), // Example 4-star rating
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            "This is where the review text from your database will be displayed. The box will expand automatically based on the length of the comment provided by the student.",
            style: TextStyle(
              fontSize: 13,
              color: Colors.black87,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  // Helper to draw stars based on rating value
  Widget _buildStarRating(int rating) {
    return Row(
      children: List.generate(5, (index) {
        return Icon(
          Icons.star,
          size: 16,
          color: index < rating ? const Color(0xFF0961F5) : Colors.grey[300],
        );
      }),
    );
  }
}