// Import the Flutter material design package
import 'package:flutter/material.dart';

// --- DATA MODELS ---
// Define a CourseData class to represent course information for search results
class CourseData {
  // Properties of a course
  final String tutorName, subject, grade, price, rating, mode;
  final Color color; // Background color for the course placeholder image

  // Constructor with all required parameters
  CourseData({required this.tutorName, required this.subject, required this.grade, required this.price, required this.rating, required this.mode, required this.color});
}

// Define a StudentData class to represent student information for search results
class StudentData {
  final String name; // Student's name

  // Constructor with required name parameter
  StudentData({required this.name});
}

// Stateful widget for the search screen
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

// State class for SearchScreen
class _SearchScreenState extends State<SearchScreen> {
  // Boolean to track which tab is selected (true = Courses, false = Students)
  bool isSearchingCourses = true;
  // Current search query entered by user
  String searchQuery = "";

  // Mock Data for courses
  final List<CourseData> _allCourses = [
    CourseData(tutorName: "Asim Ali Khan", subject: "Physics", grade: "Matric", price: "2000", rating: "4.2", mode: "Online", color: Colors.red.shade900),
    CourseData(tutorName: "Ali Imran", subject: "Physics", grade: "Intermediate", price: "2200", rating: "4.0", mode: "Tutor Home", color: Colors.brown),
    CourseData(tutorName: "Hiba Khan", subject: "Physics", grade: "O Level", price: "2500", rating: "4.3", mode: "Student Home", color: Colors.pink.shade900),
  ];

  // Mock Data for students
  final List<StudentData> _allStudents = [
    StudentData(name: "Asim Ali Khan"),
    StudentData(name: "Asim Furqan"),
    StudentData(name: "Asim Ayoob"),
  ];

  // Getter that returns filtered results based on current search query and selected tab
  List<dynamic> get _filteredResults {
    if (isSearchingCourses) {
      // Filter courses by subject (case-insensitive)
      return _allCourses.where((c) => c.subject.toLowerCase().contains(searchQuery.toLowerCase())).toList();
    } else {
      // Filter students by name (case-insensitive)
      return _allStudents.where((s) => s.name.toLowerCase().contains(searchQuery.toLowerCase())).toList();
    }
  }

  // --- SHOW FILTER BOTTOM SHEET ---
  // Method to display filter options in a bottom sheet
  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Allows the bottom sheet to take full height
      backgroundColor: Colors.transparent, // Transparent background to see the sheet's rounded corners
      builder: (context) => const FilterBottomSheet(), // Build the filter sheet widget
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get filtered results using the getter
    final results = _filteredResults;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB), // Light background color
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0, // Remove shadow
        centerTitle: true,
        // Custom back button with black circle background
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: Colors.black,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 18),
              onPressed: () => Navigator.pop(context), // Navigate back
            ),
          ),
        ),
        title: const Text("Search", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          // Search bar and filter button row
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                // Search text field
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
                    ),
                    child: TextField(
                      onChanged: (val) => setState(() => searchQuery = val), // Update search query on change
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
                // --- FILTER BUTTON ---
                GestureDetector(
                  onTap: _showFilterOptions, // Show filter bottom sheet when tapped
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

          // Tabs for switching between Courses and Students
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

          // Header showing search query and result count
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
                      TextSpan(text: "\"${searchQuery.isEmpty ? "All" : searchQuery}\"", style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                Text("${results.length} FOUNDS", style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 12)),
              ],
            ),
          ),

          // List of search results
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: results.length,
              itemBuilder: (context, index) {
                final item = results[index];
                // Display different item types based on current tab
                return isSearchingCourses ? _buildCourseItem(item as CourseData) : _buildStudentItem(item as StudentData);
              },
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to build tab buttons
  Widget _buildTabButton(String label, bool isActive, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap, // Switch tab when tapped
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
              color: isActive ? Colors.black : Colors.transparent, // Active tab has black background
              borderRadius: BorderRadius.circular(30)
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
                color: isActive ? Colors.white : Colors.black, // Active tab has white text
                fontWeight: FontWeight.bold
            ),
          ),
        ),
      ),
    );
  }

  // Build a course item widget for the list
  Widget _buildCourseItem(CourseData course) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
      ),
      child: Row(
        children: [
          // Colored placeholder for course image
          Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                  color: course.color,
                  borderRadius: BorderRadius.circular(15)
              )
          ),
          const SizedBox(width: 15),
          // Course details
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

  // Build a student item widget for the list
  Widget _buildStudentItem(StudentData student) {
    return ListTile(
      leading: const CircleAvatar(
          backgroundColor: Colors.black,
          radius: 25,
          child: Icon(Icons.person, color: Colors.white)
      ),
      title: Text(student.name, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }
}

// --- 2. FILTER BOTTOM SHEET WIDGET (Based on your UI) ---
// Stateful widget for the filter options bottom sheet
class FilterBottomSheet extends StatefulWidget {
  const FilterBottomSheet({super.key});

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

// State class for FilterBottomSheet
class _FilterBottomSheetState extends State<FilterBottomSheet> {
  // State for Checkboxes - Categories filter
  Map<String, bool> categories = {
    "Matric": false,
    "Intermediate": true, // Pre-selected
    "O Level": false,
    "A Level": false,
    "Entrance Test": false,
  };

  // State for Checkboxes - Teaching modes filter
  Map<String, bool> modes = {
    "Online": false,
    "Student's Home": true, // Pre-selected
    "Tutor's Place": true, // Pre-selected
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      // Height set to 85% of screen height
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)), // Rounded top corners
      ),
      child: Column(
        children: [
          // Header Row with back button, title, and clear button
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Back button to close bottom sheet
                CircleAvatar(
                  backgroundColor: Colors.black,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                const Text("Filter", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                // Clear button to reset all filters
                TextButton(
                  onPressed: () => setState(() {
                    // Set all categories to false
                    categories.updateAll((k, v) => false);
                    // Set all modes to false
                    modes.updateAll((k, v) => false);
                  }),
                  child: const Text("Clear", style: TextStyle(color: Colors.grey)),
                )
              ],
            ),
          ),

          // Scrollable filter options
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Categories section header
                  const Text(
                      "Categories:",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF1A237E))
                  ),
                  const SizedBox(height: 10),
                  // Dynamically generate checkboxes for each category
                  ...categories.keys.map((key) => _buildCheckbox(
                      key,
                      categories[key]!,
                          (val) => setState(() => categories[key] = val!)
                  )),

                  const SizedBox(height: 30),

                  // Teaching Mode section header
                  const Text(
                      "Teaching Mode:",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF1A237E))
                  ),
                  const SizedBox(height: 10),
                  // Dynamically generate checkboxes for each mode
                  ...modes.keys.map((key) => _buildCheckbox(
                      key,
                      modes[key]!,
                          (val) => setState(() => modes[key] = val!)
                  )),
                ],
              ),
            ),
          ),

          // Apply Button at the bottom
          Padding(
            padding: const EdgeInsets.all(25),
            child: SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context), // Close bottom sheet when applied
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(35)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(flex: 2), // Flexible spacing
                    const Text("Apply", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    const Spacer(), // Flexible spacing
                    // Circular arrow icon inside the button
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                      child: const Icon(Icons.arrow_forward, color: Colors.black, size: 20),
                    )
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  // Helper method to build a checkbox with label
  Widget _buildCheckbox(String title, bool value, Function(bool?) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        children: [
          Checkbox(
            value: value,
            activeColor: Colors.black, // Black color when checked
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            onChanged: onChanged, // Callback when checkbox is toggled
          ),
          Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}