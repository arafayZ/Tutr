// Import Flutter material UI library
import 'package:flutter/material.dart';

// Import custom bottom navigation widget
import '../widgets/custom_bottom_nav.dart';

// Import the student details screen where category data will be sent
import 'student_details_screen.dart'; // Ensure this import matches your file structure
import 'add_course_screen.dart';

// Main screen where tutor selects student category
class StudentCategoryScreen extends StatelessWidget {

  // Constructor of the screen
  const StudentCategoryScreen({super.key});

  // Build method that creates the UI of this screen
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      // Background color of the whole screen
      backgroundColor: const Color(0xFFF8F9FB),

      // Allows body to extend behind the bottom navigation bar
      extendBody: true,

      // Main layout structure
      body: Column(

        // Align children to the left
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [

          // ---------------- HEADER SECTION ----------------
          Container(

            // Height of the header
            height: 120,

            // Make width full screen
            width: double.infinity,

            // Styling for header
            decoration: const BoxDecoration(
              color: Colors.white,

              // Rounded bottom corners
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),

              // Shadow effect under header
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, 2),
                )
              ],
            ),

            // Padding inside header
            padding: const EdgeInsets.only(top: 50, left: 20),

            child: Align(

              // Align back button to the left
              alignment: Alignment.centerLeft,

              child: InkWell(

                // When pressed, go back to previous screen
                onTap: () => Navigator.pop(context),

                child: Container(

                  // Padding inside the circular button
                  padding: const EdgeInsets.all(12),

                  // Circular black background
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                  ),

                  // Back arrow icon
                  child: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
          ),

          // Space between header and title
          const SizedBox(height: 40),

          // ---------------- TITLE SECTION ----------------
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 25),

            child: Column(

              // Align text to left
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [

                // Main title
                Text(
                  "Select Student Category",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),

                // Space between title and description
                SizedBox(height: 10),

                // Description text
                Text(
                  "Choose the academic level to view and manage your students.",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),

          // Space before category grid
          const SizedBox(height: 30),

          // ---------------- CATEGORY GRID ----------------
          Expanded(
            child: Padding(

              // Horizontal padding for grid
              padding: const EdgeInsets.symmetric(horizontal: 20),

              child: GridView.count(

                // Number of columns
                crossAxisCount: 2,

                // Horizontal spacing between cards
                crossAxisSpacing: 20,

                // Vertical spacing between cards
                mainAxisSpacing: 20,

                // Category cards
                children: const [

                  // Metric category card
                  _CategoryCard(
                    label: "Matric",
                    imagePath: 'assets/images/metric_boy.png',
                  ),

                  // Intermediate category card
                  _CategoryCard(
                    label: "Intermediate",
                    imagePath: 'assets/images/inter_boy.png',
                  ),

                  // O & A Level category card
                  _CategoryCard(
                    label: "O & A Level",
                    imagePath: 'assets/images/oa_boy.png',
                  ),

                  // Entrance Test category card
                  _CategoryCard(
                    label: "Entrance Test",
                    imagePath: 'assets/images/test_boy.png',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),

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

      // Position of floating button
      floatingActionButtonLocation:
      FloatingActionButtonLocation.centerDocked,

      // Custom bottom navigation bar
      bottomNavigationBar: const CustomBottomNav(currentIndex: -1),
    );
  }
}

// ---------------- CATEGORY CARD WIDGET ----------------

// Private widget used to display each category card
class _CategoryCard extends StatelessWidget {

  // Category name
  final String label;

  // Path of image shown in card
  final String imagePath;

  // Constructor requiring label and image
  const _CategoryCard({
    required this.label,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(

      // When card is tapped
      onTap: () {

        // Navigate to StudentDetailsScreen
        Navigator.push(
          context,
          MaterialPageRoute(

            // Send category name to next screen
            builder: (context) =>
                StudentDetailsScreen(categoryName: label),
          ),
        );
      },

      child: Container(

        // Card styling
        decoration: BoxDecoration(
          color: Colors.white,

          // Rounded corners
          borderRadius: BorderRadius.circular(20),

          // Shadow under card
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),

        // Card content
        child: Column(

          // Center content vertically
          mainAxisAlignment: MainAxisAlignment.center,

          children: [

            // Category image
            Image.asset(
              imagePath,
              height: 80,

              // If image fails to load show default icon
              errorBuilder: (context, error, stackTrace) =>
              const Icon(
                Icons.person,
                size: 80,
                color: Colors.black,
              ),
            ),

            // Space between image and text
            const SizedBox(height: 10),

            // Category name
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
