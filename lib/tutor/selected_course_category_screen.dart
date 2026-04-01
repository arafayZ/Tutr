import 'package:flutter/material.dart';
import '../widgets/custom_bottom_nav.dart'; // Ensure this path is correct
import 'course_detail_screen.dart';
import 'add_course_screen.dart';

class SelectedCourseCategoryScreen extends StatefulWidget {
  final String categoryName;
  const SelectedCourseCategoryScreen({super.key, required this.categoryName});

  @override
  State<SelectedCourseCategoryScreen> createState() => _SelectedCourseCategoryScreenState();
}

class _SelectedCourseCategoryScreenState extends State<SelectedCourseCategoryScreen> {
  String _selectedMode = "Online";
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  List<Map<String, dynamic>> _allStudents = [
    {"subject": "Physics", "price": "2000 PKR", "rating": "4.2", "students": 23, "mode": "Online", "category": "Metric"},
    {"subject": "Maths", "price": "2500 PKR", "rating": "4.5", "students": 15, "mode": "Student Home", "category": "Metric"},
    {"subject": "Biology", "price": "3000 PKR", "rating": "4.7", "students": 8, "mode": "Online", "category": "Intermediate"},
    {"subject": "English", "price": "1800 PKR", "rating": "4.0", "students": 10, "mode": "Tutor Home", "category": "Metric"},
  ];

  // Update this in SelectedCourseCategoryScreen
  void _deleteCourse(Map<String, dynamic> course) {
    setState(() {
      // This finds the exact original object and removes it
      _allStudents.remove(course);
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredList = _allStudents.where((s) {
      final matchesCategory = s['category'] == widget.categoryName;
      final matchesMode = s['mode'] == _selectedMode;
      final matchesSearch = s['subject'].toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesMode && matchesSearch;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      extendBody: true,
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
      body: Column(
        children: [
          _buildHeader(context),
          const SizedBox(height: 20),
          _buildSearchBar(),
          _buildModeSlider(),
          Expanded(
            child: filteredList.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 140),
              itemCount: filteredList.length,
              itemBuilder: (context, index) => _buildStudentCard(filteredList[index]),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const CustomBottomNav(currentIndex: -1),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: InkWell(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 45,
                height: 45,
                decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle),
                child: const Icon(Icons.arrow_back, color: Colors.white, size: 22),
              ),
            ),
          ),
          Text(widget.categoryName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (value) => setState(() => _searchQuery = value),
          decoration: const InputDecoration(
            hintText: "Search students...",
            hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
            prefixIcon: Icon(Icons.search, color: Colors.black54),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 15),
          ),
        ),
      ),
    );
  }

  Widget _buildModeSlider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
        ),
        child: Row(
          children: [
            _buildTabButton("Online"),
            _buildTabButton("Student Home"),
            _buildTabButton("Tutor Home"),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(String label) {
    bool isSelected = _selectedMode == label;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedMode = label),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
              color: isSelected ? Colors.black : Colors.transparent, borderRadius: BorderRadius.circular(25)),
          alignment: Alignment.center,
          child: Text(label,
              style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black, fontWeight: FontWeight.bold, fontSize: 12)),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.cancel_outlined, size: 100, color: Colors.black12),
          SizedBox(height: 10),
          Text("Nothing Here Yet", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black26)),
          Text("You haven’t added any items yet.", style: TextStyle(fontSize: 15, fontWeight: FontWeight.normal, color: Colors.black26)),
          SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildStudentCard(Map<String, dynamic> data) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)]),
      child: Row(
        children: [
          Container(
              width: 80, height: 80, decoration: BoxDecoration(color: Colors.red[900], borderRadius: BorderRadius.circular(15))),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text(data['subject'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Row(children: [
                    const Icon(Icons.star, color: Colors.amber, size: 14),
                    Text(" ${data['rating']}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12))
                  ]),
                ]),
                Text("${data['price']} ${widget.categoryName}",
                    style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 12)),
                const SizedBox(height: 4),
                Row(children: [
                  Text(data['mode'].toUpperCase(),
                      style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 9)),
                  const Text(" | ", style: TextStyle(color: Colors.grey)),
                  Text("${data['students']} Student", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 9)),
                ]),
                // Locate this inside your _buildStudentCard widget
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () async { // 1. Added async here
                      final Map<String, dynamic> courseData = {
                        "title": data['subject'],
                        "rating": data['rating'],
                        "level": widget.categoryName,
                        "price": data['price'],
                        "students": data['students'],
                        "mode": data['mode'],
                        "color": Colors.red[900],
                        "about": "Master ${data['subject']} with expert guidance in ${data['mode']} mode.",
                        "tutorName": "Abdul Rafay",
                        "location": "Nazimabad, Karachi",
                      };

                      // 2. Await the navigation
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CourseDetailScreen(
                            course: courseData,
                            onDelete: (item) => _deleteCourse(data),
                            onAvailableTap: () {},
                            showAvailableBtn: false,
                          ),
                        ),
                      );

                      // 3. This runs AFTER the Detail screen is popped.
                      // It forces the list to rebuild with the updated _allStudents data.
                      setState(() {});
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      minimumSize: const Size(0, 28),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                    ),
                    child: const Text("Details", style: TextStyle(color: Colors.white, fontSize: 10)),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}