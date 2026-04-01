// Import Flutter material UI library
import 'package:flutter/material.dart';

// Import custom bottom navigation widget
import '../widgets/custom_bottom_nav.dart';
import 'selected_course_category_screen.dart'; // Ensure filename casing matches your file
import 'add_course_screen.dart';

// Main screen where tutor selects course category
class CourseCategoryScreen extends StatelessWidget {
  // Constructor of the screen
  const CourseCategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      extendBody: true,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ---------------- HEADER SECTION ----------------
          Container(
            height: 120,
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, 2),
                )
              ],
            ),
            padding: const EdgeInsets.only(top: 50, left: 20),
            child: Align(
              alignment: Alignment.centerLeft,
              child: InkWell(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 40),

          // ---------------- TITLE SECTION ----------------
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Select Course Category",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  "Choose the academic level to view and manage your courses.",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // ---------------- CATEGORY GRID ----------------
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                children: const [
                  _CategoryCard(
                    label: "Metric",
                    imagePath: 'assets/images/metric_course.png',
                  ),
                  _CategoryCard(
                    label: "Intermediate",
                    imagePath: 'assets/images/inter_course.png',
                  ),
                  _CategoryCard(
                    label: "O & A Level",
                    imagePath: 'assets/images/oa_course.png',
                  ),
                  _CategoryCard(
                    label: "Entrance Test",
                    imagePath: 'assets/images/test_course.png',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),

      // ---------------- FLOATING ACTION BUTTON ----------------
      // ---------------- FLOATING ACTION BUTTON ----------------
      floatingActionButton: FloatingActionButton(
        // Updated: Navigation logic added here
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddCourseScreen(), // Ensure this screen is imported
            ),
          );
        },

        // Button color
        backgroundColor: Colors.black,

        // Circular shape
        shape: const CircleBorder(),

        // Plus icon inside button
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 35,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: const CustomBottomNav(currentIndex: -1),
    );
  }
}

// ---------------- CATEGORY CARD WIDGET ----------------

class _CategoryCard extends StatelessWidget {
  final String label;
  final String imagePath;

  const _CategoryCard({
    required this.label,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      // Fixed: Added missing comment slash and wrapped navigation
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                SelectedCourseCategoryScreen(categoryName: label),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              imagePath,
              height: 80,
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.school, // Changed to school icon to better fit education theme
                size: 80,
                color: Colors.black12,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}