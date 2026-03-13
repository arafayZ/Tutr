import 'package:flutter/material.dart';
import '../widgets/custom_bottom_nav.dart';
import '../widgets/custom_tab_header.dart';
import 'add_course_screen.dart';

class ReviewsScreen extends StatefulWidget {
  const ReviewsScreen({super.key});

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const FilterBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> reviews = [
      {"name": "Ali Khan", "rating": "4", "review": "Great tutor! Helped me understand Physics concepts clearly."},
      {"name": "Sara Ahmed", "rating": "4.8", "review": "Excellent teaching! My problem-solving skills have improved a lot."},
      {"name": "Bilal Raza", "rating": "4.6", "review": "Interactive and clear lessons. I feel more confident in my exams now."},
      {"name": "Hamza Sheikh", "rating": "4.5", "review": "Very patient and explains difficult topics simply."},
      {"name": "Dua Fatima", "rating": "4.9", "review": "The best tutor I've found so far for Mathematics!"},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      extendBody: true,
      body: Column(
        children: [
          const CustomTabHeader(
            title: Text(
              "Reviews & Ratings",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 10, bottom: 130),
              itemCount: reviews.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _buildRatingSummary();
                }
                final review = reviews[index - 1];

                return Padding(
                  // Added consistent horizontal gap here
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ReviewDetailsScreen(
                            name: review["name"]!,
                            rating: review["rating"]!,
                            review: review["review"]!,
                          ),
                        ),
                      );
                    },
                    child: _ReviewBox(
                      name: review["name"]!,
                      rating: review["rating"]!,
                      review: review["review"]!,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AddCourseScreen()),
        ),
        backgroundColor: Colors.black,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 32),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: const SafeArea(
        child: CustomBottomNav(currentIndex: -1),
      ),
    );
  }

  Widget _buildRatingSummary() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: _showFilterOptions,
              child: Container(
                margin: const EdgeInsets.only(bottom: 15),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.black.withOpacity(0.5)),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.tune, size: 22),
              ),
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Column(
                children: [
                  Text("4.8", style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, height: 1.1)),
                  Text("25 Ratings", style: TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  children: [
                    _buildStaggeredRow(5, 0.8, "12"),
                    _buildStaggeredRow(4, 0.6, "6"),
                    _buildStaggeredRow(3, 0.4, "4"),
                    _buildStaggeredRow(2, 0.1, "1"),
                    _buildStaggeredRow(1, 0.0, "0"),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStaggeredRow(int starCount, double progress, String count) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: List.generate(5, (index) {
                return Icon(
                  Icons.star,
                  size: 14,
                  color: (index >= (5 - starCount)) ? Colors.orange : Colors.transparent,
                );
              }),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey[200],
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.red),
                minHeight: 5,
              ),
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 20,
            child: Text(
              count,
              style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}

class ReviewDetailsScreen extends StatelessWidget {
  final String name;
  final String rating;
  final String review;

  const ReviewDetailsScreen({
    super.key,
    required this.name,
    required this.rating,
    required this.review,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: Column(
        children: [
          const CustomTabHeader(
            title: Text(
              "Reviews",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                children: [
                  _buildCourseHeaderCard(),
                  const SizedBox(height: 25),
                  // Box already has internal padding, so no extra horizontal padding needed here
                  _ReviewBox(name: name, rating: rating, review: review),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Row(
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: Colors.red.shade900,
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          const SizedBox(width: 15),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Asim Ali Khan", style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 12)),
                Text("Physics", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                Text("2000 PKR  Matric", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    Icon(Icons.star, color: Colors.amber, size: 16),
                    Text(" 4.2  |  ", style: TextStyle(fontWeight: FontWeight.bold)),
                    Text("ONLINE", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _ReviewBox extends StatelessWidget {
  final String name;
  final String rating;
  final String review;

  const _ReviewBox({required this.name, required this.rating, required this.review});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(radius: 22, backgroundColor: Colors.black),
              const SizedBox(width: 12),
              Expanded(child: Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFEDF2FF),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF0961F5).withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.star, color: Colors.orange, size: 14),
                    const SizedBox(width: 4),
                    Text(rating, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(review, style: const TextStyle(fontSize: 13, color: Colors.black87, height: 1.5)),
          const SizedBox(height: 15),
          const Text("2 Weeks Ago", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12)),
        ],
      ),
    );
  }
}

class FilterBottomSheet extends StatefulWidget {
  const FilterBottomSheet({super.key});

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  Map<String, bool> categories = {
    "Matric": false,
    "Intermediate": true,
    "O Level": false,
    "A Level": false,
    "Entrance Test": false,
  };

  Map<String, bool> teachingModes = {
    "Online": false,
    "Student's Home": true,
    "Tutor's Place": true,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CircleAvatar(
                  backgroundColor: Colors.black,
                  radius: 20,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                const Text("Filter", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                TextButton(
                  onPressed: () {
                    setState(() {
                      categories.updateAll((k, v) => false);
                      teachingModes.updateAll((k, v) => false);
                    });
                  },
                  child: const Text("Clear", style: TextStyle(color: Colors.grey, fontSize: 16)),
                )
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Categories:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 15),
                  ...categories.keys.map((key) => _buildCustomCheckbox(key, categories[key]!, (val) {
                    setState(() => categories[key] = val!);
                  })),
                  const SizedBox(height: 30),
                  const Text("Teaching Mode:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 15),
                  ...teachingModes.keys.map((key) => _buildCustomCheckbox(key, teachingModes[key]!, (val) {
                    setState(() => teachingModes[key] = val!);
                  })),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(25),
              child: SizedBox(
                width: double.infinity,
                height: 65,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(35)),
                  ),
                  child: const Text("Apply", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildCustomCheckbox(String title, bool value, Function(bool?) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => onChanged(!value),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: value ? Colors.black : const Color(0xFFE8F1FF),
                borderRadius: BorderRadius.circular(6),
                border: value ? null : Border.all(color: Colors.grey.shade300),
              ),
              child: value ? const Icon(Icons.check, color: Colors.white, size: 18) : null,
            ),
            const SizedBox(width: 15),
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}