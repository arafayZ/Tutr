// Import Flutter material design widgets
import 'package:flutter/material.dart';
// Import a custom tab header widget from your project
import '../widgets/custom_tab_header.dart';

// --- DATA MODELS ---
// Course data model
class CourseData {
  final String tutorName, subject, grade, price, rating, mode; // Basic course info
  final Color color; // Color to represent course visually

  CourseData({
    required this.tutorName,
    required this.subject,
    required this.grade,
    required this.price,
    required this.rating,
    required this.mode,
    required this.color
  });
}

// Student data model
class StudentData {
  final String name; // Student's name
  StudentData({required this.name});
}

// Main Search screen widget
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

// State class for SearchScreen
class _SearchScreenState extends State<SearchScreen> {
  bool isSearchingCourses = true; // Flag: true = courses, false = students
  String searchQuery = ""; // Current text in search box

  // Sample courses list
  final List<CourseData> _allCourses = [
    CourseData(tutorName: "Asim Ali Khan", subject: "Physics", grade: "Matric", price: "2000", rating: "4.2", mode: "Online", color: Colors.red.shade900),
    CourseData(tutorName: "Ali Imran", subject: "Physics", grade: "Intermediate", price: "2200", rating: "4.0", mode: "Tutor Home", color: Colors.brown),
    CourseData(tutorName: "Hiba Khan", subject: "Physics", grade: "O Level", price: "2500", rating: "4.3", mode: "Student Home", color: Colors.pink.shade900),
  ];

  // Sample students list
  final List<StudentData> _allStudents = [
    StudentData(name: "Asim Ali Khan"),
    StudentData(name: "Asim Furqan"),
    StudentData(name: "Asim Ayoob"),
  ];

  // Filtered results based on search query
  List<dynamic> get _filteredResults {
    if (isSearchingCourses) {
      return _allCourses
          .where((c) => c.subject.toLowerCase().contains(searchQuery.toLowerCase()))
          .toList();
    } else {
      return _allStudents
          .where((s) => s.name.toLowerCase().contains(searchQuery.toLowerCase()))
          .toList();
    }
  }

  // Shows the filter bottom sheet
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
    final results = _filteredResults; // Current results based on search/filter

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB), // Page background
      body: Column(
        children: [
          const CustomTabHeader(
            title: Text(
              "Search",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          // Search bar and filter button row
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 40, 20, 20),
            child: Row(
              children: [
                // Search box
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                    ),
                    child: TextField(
                      onChanged: (val) => setState(() => searchQuery = val), // Updates search query
                      decoration: const InputDecoration(
                        hintText: "Search here...",
                        prefixIcon: Icon(Icons.search, color: Colors.grey),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 15),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                // Filter button
                GestureDetector(
                  onTap: _showFilterOptions,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: const Icon(Icons.tune, color: Colors.black, size: 24),
                  ),
                ),
              ],
            ),
          ),
          // Tabs for Courses / Students
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30)),
              child: Row(
                children: [
                  _buildTabButton("Courses", isSearchingCourses, () => setState(() => isSearchingCourses = true)),
                  _buildTabButton("Students", !isSearchingCourses, () => setState(() => isSearchingCourses = false)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Results info row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                RichText(
                  text: TextSpan(
                    style: const TextStyle(color: Colors.black, fontSize: 14),
                    children: [
                      const TextSpan(text: "Result for "),
                      TextSpan(
                          text: "\"${searchQuery.isEmpty ? "All" : searchQuery}\"",
                          style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)
                      ),
                    ],
                  ),
                ),
                Text("${results.length} FOUNDS", style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 12)),
              ],
            ),
          ),
          // Display filtered results
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: results.length,
              itemBuilder: (context, index) {
                final item = results[index];
                if (isSearchingCourses && item is CourseData) {
                  return _buildCourseItem(item); // Build course tile
                } else if (!isSearchingCourses && item is StudentData) {
                  return _buildStudentItem(item); // Build student tile
                }
                return const SizedBox.shrink(); // Fallback empty widget
              },
            ),
          ),
        ],
      ),
    );
  }

  // Helper to build a tab button (Courses / Students)
  Widget _buildTabButton(String label, bool isActive, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
              color: isActive ? Colors.black : Colors.transparent,
              borderRadius: BorderRadius.circular(30)
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
                color: isActive ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold
            ),
          ),
        ),
      ),
    );
  }

  // Build course item UI
  Widget _buildCourseItem(CourseData course) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Row(
        children: [
          // Color box representing course
          Container(width: 80, height: 80, decoration: BoxDecoration(color: course.color, borderRadius: BorderRadius.circular(15))),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(course.tutorName, style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 12)),
                Text(course.subject, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text("${course.price} PKR | ${course.grade}", style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 16),
                    Text(" ${course.rating}  |  ", style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(course.mode.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  // Build student item UI
  Widget _buildStudentItem(StudentData student) {
    return ListTile(
      leading: const CircleAvatar(backgroundColor: Colors.black, radius: 25, child: Icon(Icons.person, color: Colors.white)),
      title: Text(student.name, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }
}

// --- FILTER BOTTOM SHEET ---
// Stateful widget for filtering options
class FilterBottomSheet extends StatefulWidget {
  const FilterBottomSheet({super.key});

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  // Category filters with default selection
  Map<String, bool> categories = {
    "Matric": false,
    "Intermediate": true,
    "O Level": false,
    "A Level": false,
    "Entrance Test": false,
  };

  // Teaching mode filters with default selection
  Map<String, bool> teachingModes = {
    "Online": false,
    "Student's Home": true,
    "Tutor's Place": true,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85, // Covers 85% of screen
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)), // Rounded top
      ),
      child: Column(
        children: [
          // Header row with back button, title, clear button
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
                      categories.updateAll((k, v) => false); // Clear all
                      teachingModes.updateAll((k, v) => false); // Clear all
                    });
                  },
                  child: const Text("Clear", style: TextStyle(color: Colors.grey, fontSize: 16)),
                )
              ],
            ),
          ),
          // Filter options scroll
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  const Text("Categories:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black)),
                  const SizedBox(height: 15),
                  // Render each category checkbox
                  ...categories.keys.map((key) => _buildCustomCheckbox(key, categories[key]!, (val) {
                    setState(() => categories[key] = val!);
                  })),
                  const SizedBox(height: 30),
                  const Text("Teaching Mode:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black)),
                  const SizedBox(height: 15),
                  // Render each teaching mode checkbox
                  ...teachingModes.keys.map((key) => _buildCustomCheckbox(key, teachingModes[key]!, (val) {
                    setState(() => teachingModes[key] = val!);
                  })),
                ],
              ),
            ),
          ),
          // Apply button at bottom
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(25, 10, 25, 10),
              child: SizedBox(
                width: double.infinity,
                height: 65,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context), // Close sheet
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(35)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Spacer(flex: 2),
                      const Text("Apply", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                        child: const Icon(Icons.arrow_forward, color: Colors.black, size: 22),
                      )
                    ],
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  // Custom checkbox widget
  Widget _buildCustomCheckbox(String title, bool value, Function(bool?) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => onChanged(!value), // Toggle checkbox on tap
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: value ? Colors.black : const Color(0xFFE8F1FF),
                borderRadius: BorderRadius.circular(6),
                border: value ? null : Border.all(color: Colors.grey.shade300, width: 1),
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