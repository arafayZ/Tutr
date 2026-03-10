import 'package:flutter/material.dart';
import '../widgets/custom_bottom_nav.dart'; // Custom navigation bar widget
import '../widgets/custom_tab_header.dart'; // Custom header widget for the screen
import 'add_course_screen.dart'; // Navigation target for the FAB

class ReviewsScreen extends StatelessWidget {
  const ReviewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB), // Light grey/blue background for contrast
      // Extends the body under the BottomNavigationBar for a seamless look
      extendBody: true,
      body: Column(
        children: [
          // Screen Header: Displays the "Reviews" title
          const CustomTabHeader(
            title: Text(
              "Reviews",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),

          // Main content area for the scrollable list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(
                left: 20,
                right: 20,
                top: 15,
                bottom: 120, // High bottom padding ensures the last item isn't hidden by the FAB
              ),
              itemCount: 8, // Fixed count for UI testing/placeholder
              itemBuilder: (context, index) {
                // Returns the private helper widget defined below
                return const _ReviewBox();
              },
            ),
          ),
        ],
      ),

      // Floating Action Button (FAB) for adding a new course
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Standard push navigation to the AddCourseScreen
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddCourseScreen()),
          );
        },
        backgroundColor: Colors.black, // High contrast black button
        shape: const CircleBorder(), // Forces a perfectly circular shape
        elevation: 4, // Subtle shadow for depth
        child: const Icon(Icons.add, color: Colors.white, size: 32), // Add icon
      ),
      // Centers the FAB and docks it into the bottom navigation bar notch
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // Custom bottom navigation bar widget
      bottomNavigationBar: const CustomBottomNav(currentIndex: -1),
    );
  }
}

// Internal reusable widget for an individual review card
class _ReviewBox extends StatelessWidget {
  const _ReviewBox();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16), // Spacing between cards
      padding: const EdgeInsets.all(16), // Internal padding for content
      decoration: BoxDecoration(
        color: Colors.white, // Card background
        borderRadius: BorderRadius.circular(20), // Rounded corners
        boxShadow: [
          BoxShadow(
            // Modern syntax for transparency (replaces withOpacity)
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4), // Shadow positioned slightly below the card
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // Align text to the left
        children: [
          Row(
            children: [
              // User Avatar with a light blue background
              const CircleAvatar(
                radius: 22,
                backgroundColor: Color(0xFFEDF2FF),
                child: Icon(Icons.person, color: Color(0xFF0961F5)),
              ),
              const SizedBox(width: 12), // Gap between avatar and text
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
              // Star rating display aligned to the right of the row
              _buildStarRating(4),
            ],
          ),
          const SizedBox(height: 12), // Gap between header row and review text
          const Text(
            "This is where the review text from your database will be displayed. The box will expand automatically based on the length of the comment provided by the student.",
            style: TextStyle(
              fontSize: 13,
              color: Colors.black87,
              height: 1.4, // Increased line height for better readability
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to generate a 5-star rating widget
  Widget _buildStarRating(int rating) {
    return Row(
      children: List.generate(5, (index) {
        return Icon(
          Icons.star,
          size: 16,
          // Colors the star blue if the index is within the rating, otherwise grey
          color: index < rating ? const Color(0xFF0961F5) : Colors.grey[300],
        );
      }),
    );
  }
}