import 'package:flutter/material.dart';
import '../widgets/custom_bottom_nav.dart'; // Ensure this matches your project path

class StudentCategoryScreen extends StatelessWidget {
  const StudentCategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      extendBody: true,

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- 1. HEADER ---
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
                BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 2))
              ],
            ),
            padding: const EdgeInsets.only(top: 50, left: 20),
            child: Align(
              alignment: Alignment.centerLeft,
              child: InkWell(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle),
                  child: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
                ),
              ),
            ),
          ),

          const SizedBox(height: 40),

          // --- 2. TITLE SECTION ---
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Select Student Category",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
                ),
                SizedBox(height: 10),
                Text(
                  "Choose the academic level to view and manage your students.",
                  style: TextStyle(fontSize: 14, color: Colors.black54, height: 1.5),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // --- 3. CATEGORY GRID ---
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                // These work now because _CategoryCard is defined below with a const constructor
                children: const [
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

      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: Colors.black,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 35),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      bottomNavigationBar: const CustomBottomNav(),
    );
  }
}

// --- 4. CATEGORY CARD WIDGET ---
// This must be OUTSIDE the StudentCategoryScreen class brackets
class _CategoryCard extends StatelessWidget {
  final String label;
  final String imagePath;

  const _CategoryCard({
    required this.label,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            // Use withValues for modern Flutter versions (2026 standards)
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
            errorBuilder: (context, error, stackTrace) {
              return const Icon(Icons.person, size: 80, color: Color(0xFF000000));
            },
          ),
          const SizedBox(height: 10),
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