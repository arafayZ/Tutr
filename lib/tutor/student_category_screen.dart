// Import Flutter material design widgets
import 'package:flutter/material.dart';
// Import custom bottom navigation bar from your project
import '../widgets/custom_bottom_nav.dart';

// Stateless widget for selecting student categories
class StudentCategoryScreen extends StatelessWidget {
  const StudentCategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB), // Background color
      extendBody: true, // Extends body behind bottom navigation

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- 1. HEADER ---
          Container(
            height: 120, // Header height
            width: double.infinity, // Full width
            decoration: const BoxDecoration(
              color: Colors.white, // Header background
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ), // Rounded bottom corners
              boxShadow: [
                BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 2))
              ], // Shadow for header
            ),
            padding: const EdgeInsets.only(top: 50, left: 20), // Padding inside header
            child: Align(
              alignment: Alignment.centerLeft, // Align back button left
              child: InkWell(
                onTap: () => Navigator.pop(context), // Go back on tap
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle),
                  child: const Icon(Icons.arrow_back, color: Colors.white, size: 24), // Back icon
                ),
              ),
            ),
          ),

          const SizedBox(height: 40), // Spacing below header

          // --- 2. TITLE SECTION ---
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Main title
                Text(
                  "Select Student Category",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
                ),
                SizedBox(height: 10),
                // Subtitle/description
                Text(
                  "Choose the academic level to view and manage your students.",
                  style: TextStyle(fontSize: 14, color: Colors.black54, height: 1.5),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30), // Spacing before grid

          // --- 3. CATEGORY GRID ---
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GridView.count(
                crossAxisCount: 2, // Two columns
                crossAxisSpacing: 20, // Horizontal spacing
                mainAxisSpacing: 20, // Vertical spacing
                children: const [
                  // Category cards
                  _CategoryCard(label: "Metric", imagePath: 'assets/images/metric_boy.png'),
                  _CategoryCard(label: "Intermediate", imagePath: 'assets/images/inter_boy.png'),
                  _CategoryCard(label: "O & A Level", imagePath: 'assets/images/oa_boy.png'),
                  _CategoryCard(label: "Entrance Test", imagePath: 'assets/images/test_boy.png'),
                ],
              ),
            ),
          ),
        ],
      ),

      // Floating action button for adding a new student
      floatingActionButton: FloatingActionButton(
        onPressed: () {}, // Add student action
        backgroundColor: Colors.black,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 35),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked, // Centered at bottom

      // Bottom navigation bar
      bottomNavigationBar: const CustomBottomNav(currentIndex: -1), // Custom nav with inactive index
    );
  }
}

// --- 4. CATEGORY CARD WIDGET ---
// Widget for each category card in grid
class _CategoryCard extends StatelessWidget {
  final String label; // Category name
  final String imagePath; // Image path for category

  const _CategoryCard({
    required this.label,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white, // Card background
        borderRadius: BorderRadius.circular(20), // Rounded corners
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05), // Shadow for card
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center, // Center content vertically
        children: [
          // Category image
          Image.asset(
            imagePath,
            height: 80,
            errorBuilder: (context, error, stackTrace) {
              // Show default icon if image fails to load
              return const Icon(Icons.person, size: 80, color: Color(0xFF000000));
            },
          ),
          const SizedBox(height: 10),
          // Category label text
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Color(0xFF000000),
            ),
          ),
        ],
      ),
    );
  }
}