import 'dart:async';
import 'package:flutter/material.dart';
import '../widgets/custom_bottom_nav.dart';
import '../widgets/custom_tab_header.dart';
import 'add_course_screen.dart';
import 'student_profile_screen.dart';

class ReviewsScreen extends StatefulWidget {
  const ReviewsScreen({super.key});

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  // Master list with metadata for filtering
  final List<Map<String, String>> allReviews = [
    {"name": "Ali Khan", "rating": "4.0", "review": "Great tutor! Helped me understand Physics concepts clearly.", "category": "Matric", "mode": "Online"},
    {"name": "Sara Ahmed", "rating": "4.8", "review": "Excellent teaching! My problem-solving skills have improved a lot.", "category": "Intermediate", "mode": "Student's Home"},
    {"name": "Bilal Raza", "rating": "4.6", "review": "Interactive and clear lessons.", "category": "O Level", "mode": "Tutor's Place"},
    {"name": "Hamza Sheikh", "rating": "4.5", "review": "Very patient and explains difficult topics simply.", "category": "Matric", "mode": "Online"},
    {"name": "Dua Fatima", "rating": "4.9", "review": "The best tutor I've found so far for Mathematics!", "category": "A Level", "mode": "Student's Home"},
  ];

  // List that changes based on filters
  List<Map<String, String>> filteredReviews = [];

  @override
  void initState() {
    super.initState();
    filteredReviews = allReviews; // Initial state: show all
  }

  void _showFilterOptions() async {
    // Wait for the result from the BottomSheet
    final Map<String, dynamic>? result = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const FilterBottomSheet(),
    );

    if (result != null) {
      Map<String, bool> selectedCats = result['categories'];
      Map<String, bool> selectedModes = result['modes'];

      setState(() {
        filteredReviews = allReviews.where((review) {
          // If no filters are selected in a group, treat as "show all"
          bool noCatSelected = !selectedCats.values.contains(true);
          bool noModeSelected = !selectedModes.values.contains(true);

          bool matchesCategory = noCatSelected || selectedCats[review["category"]] == true;
          bool matchesMode = noModeSelected || selectedModes[review["mode"]] == true;

          return matchesCategory && matchesMode;
        }).toList();
      });
    }
  }

  void _navigateToProfile(String name) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StudentProfileScreen(
          student: StudentDetails(
            id: "STU-001",
            name: name,
            profilePic: 'assets/images/user.png',
            location: "Nazimabad, Karachi",
            dob: "10 Oct 2004",
            gender: "Male",
            college: "Govt. Degree College",
            school: "Happy Palace",
            phone: "+92 300 1234567",
            email: "student@example.com",
          ),
          onDisconnect: (id) => debugPrint("Disconnected: $id"),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      extendBody: true,
      body: Column(
        children: [
          const CustomTabHeader(
            title: Text("Reviews & Ratings", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(0, 10, 0, 150),
              physics: const BouncingScrollPhysics(),
              itemCount: filteredReviews.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) return _buildRatingSummary();
                final review = filteredReviews[index - 1];

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: _ReviewBox(
                    name: review["name"]!,
                    rating: review["rating"]!,
                    review: review["review"]!,
                    onNameTap: () => _navigateToProfile(review["name"]!),
                    onBoxTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ReviewDetailsScreen(
                            name: review["name"]!,
                            rating: review["rating"]!,
                            review: review["review"]!,
                            onNameTap: () => _navigateToProfile(review["name"]!),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AddCourseScreen())),
        backgroundColor: Colors.black,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 32),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: const SafeArea(child: CustomBottomNav(currentIndex: -1)),
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
            child: Text(count, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold), textAlign: TextAlign.right),
          ),
        ],
      ),
    );
  }
}

class _ReviewBox extends StatelessWidget {
  final String name;
  final String rating;
  final String review;
  final VoidCallback? onNameTap;
  final VoidCallback? onBoxTap;

  const _ReviewBox({required this.name, required this.rating, required this.review, this.onNameTap, this.onBoxTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onBoxTap,
      child: Container(
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
                InkWell(
                  onTap: onNameTap,
                  borderRadius: BorderRadius.circular(10),
                  child: Row(
                    children: [
                      const CircleAvatar(radius: 22, backgroundColor: Colors.black, child: Icon(Icons.person, color: Colors.white, size: 20)),
                      const SizedBox(width: 12),
                      Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                ),
                const Spacer(),
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
      ),
    );
  }
}

class ReviewDetailsScreen extends StatelessWidget {
  final String name;
  final String rating;
  final String review;
  final VoidCallback onNameTap;

  const ReviewDetailsScreen({super.key, required this.name, required this.rating, required this.review, required this.onNameTap});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: Column(
        children: [
          const CustomTabHeader(title: Text("Reviews", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
              child: Column(
                children: [
                  _buildCourseHeaderCard(),
                  const SizedBox(height: 25),
                  _ReviewBox(name: name, rating: rating, review: review, onNameTap: onNameTap),
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
            width: 90, height: 90,
            decoration: BoxDecoration(color: const Color(0xFF8C1414), borderRadius: BorderRadius.circular(15)),
            child: const Icon(Icons.menu_book, color: Colors.white, size: 35),
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
                    Text(" 4.2  |  ONLINE", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10)),
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

class FilterBottomSheet extends StatefulWidget {
  const FilterBottomSheet({super.key});
  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  // Current state of checkboxes
  Map<String, bool> categories = {"Matric": false, "Intermediate": false, "O Level": false, "A Level": false, "Entrance Test": false};
  Map<String, bool> modes = {"Online": false, "Student's Home": false, "Tutor's Place": false};

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CircleAvatar(backgroundColor: Colors.black, child: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context))),
                const Text("Filter", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                TextButton(onPressed: () => setState(() { categories.updateAll((k, v) => false); modes.updateAll((k, v) => false); }), child: const Text("Clear", style: TextStyle(color: Colors.grey))),
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
                  ...categories.keys.map((k) => _buildCheck(k, categories[k]!, (v) => setState(() => categories[k] = v!))),
                  const SizedBox(height: 30),
                  const Text("Teaching Mode:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 15),
                  ...modes.keys.map((k) => _buildCheck(k, modes[k]!, (v) => setState(() => modes[k] = v!))),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(25),
              child: SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: () {
                    // Send the data back to the parent screen
                    Navigator.pop(context, {
                      "categories": categories,
                      "modes": modes,
                    });
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.black, shape: const StadiumBorder()),
                  child: const Text("Apply", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildCheck(String t, bool v, Function(bool?) onChange) {
    return ListTile(
      onTap: () => onChange(!v),
      contentPadding: EdgeInsets.zero,
      leading: Container(width: 24, height: 24, decoration: BoxDecoration(color: v ? Colors.black : const Color(0xFFE8F1FF), borderRadius: BorderRadius.circular(6)), child: v ? const Icon(Icons.check, color: Colors.white, size: 16) : null),
      title: Text(t, style: const TextStyle(fontSize: 16)),
    );
  }
}