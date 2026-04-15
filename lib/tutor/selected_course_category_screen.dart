import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/custom_bottom_nav.dart';
import 'course_detail_screen.dart';
import 'add_course_screen.dart';
import '../services/course_service.dart';
import '../config/api_config.dart';

// Add the CourseColors class (same as dashboard)
class CourseColors {
  static const List<Color> colors = [
    Color(0xFF1A1A2E), // Dark Navy
    Color(0xFF16213E), // Deep Navy
    Color(0xFF0F3460), // Dark Blue
    Color(0xFF8B1E3F), // Dark Crimson
    Color(0xFF2C3E50), // Dark Slate
    Color(0xFF1B4F72), // Deep Teal
    Color(0xFF145A32), // Dark Green
    Color(0xFF7B2C3E), // Deep Maroon
    Color(0xFF4A235A), // Dark Violet
    Color(0xFF1C2833), // Almost Black Blue
    Color(0xFF6E2C00), // Dark Orange-Brown
    Color(0xFF0B5345), // Dark Cyan-Green
    Color(0xFF424949), // Dark Gray
    Color(0xFF5D4037), // Dark Brown
    Color(0xFF283747), // Dark Steel Blue
    Color(0xFF7E5109), // Dark Gold
    Color(0xFF4A4A4A), // Dark Gray
    Color(0xFF3E2723), // Very Dark Brown
    Color(0xFF1A237E), // Deep Indigo
  ];

  static Color getCourseColor(int courseId) {
    return colors[courseId % colors.length];
  }
}

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
  bool _isLoading = true;
  List<Map<String, dynamic>> _courses = [];

  // Map backend mode to display mode for filtering
  String _mapBackendModeToFilter(String? backendMode) {
    if (backendMode == null) return "Online";
    switch (backendMode.toUpperCase()) {
      case "ONLINE": return "Online";
      case "STUDENT_HOME": return "Student Home";
      case "TUTOR_HOME": return "Tutor Home";
      default: return "Online";
    }
  }

  // Map backend category to display category
  String _mapBackendCategoryToDisplay(String? backendCategory) {
    if (backendCategory == null) return "";
    switch (backendCategory.toUpperCase()) {
      case "MATRIC": return "Matric";
      case "INTERMEDIATE": return "Intermediate";
      case "O_LEVEL": return "O Level";
      case "A_LEVEL": return "A Level";
      case "ENTRY_TEST": return "Entrance Test";
      default: return backendCategory;
    }
  }

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  Future<void> _loadCourses() async {
    setState(() => _isLoading = true);

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int tutorProfileId = prefs.getInt('profileId') ?? 0;

      // Get course cards with totalStudents
      List<dynamic> courses =
      await CourseService.getTutorCourseCards(tutorProfileId);

      // Filter only available courses
      List<dynamic> availableCourses = courses
          .where((course) => course['isAvailable'] == true)
          .toList();

      List<Map<String, dynamic>> filteredCourses = [];

      for (var course in availableCourses) {
        String displayCategory =
        _mapBackendCategoryToDisplay(course['category']);


        bool shouldAdd = false;

        //  FIX: O/A Level special case
        if (widget.categoryName == "O/A Level" || widget.categoryName == "O & A Level") {
          shouldAdd =
              displayCategory == "O Level" ||
                  displayCategory == "A Level";
        } else {
          shouldAdd = displayCategory == widget.categoryName;
        }

        if (shouldAdd) {
          filteredCourses.add({
            'id': course['courseId'] ?? course['id'],
            'subject': course['subject'] ?? '',
            'price': "Rs ${course['price'] ?? 0}",
            'rating': (course['averageRating'] ?? 0.0).toString(),
            'students': course['totalStudents'] ?? 0,
            'mode': _mapBackendModeToFilter(course['teachingMode']),
            'category': displayCategory,
            'tutorName': course['tutorName'] ?? 'Tutor',
            'location': course['location'] ?? 'Location not specified',
            'about': course['about'] ?? 'No description available.',
            'isAvailable': course['isAvailable'] ?? true,
          });
        }
      }

      setState(() {
        _courses = filteredCourses;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading courses: $e');
      setState(() => _isLoading = false);
      _showErrorDialog(
        "Failed to load courses: ${e.toString().replaceFirst('Exception: ', '')}",
      );
    }
  }

  Future<void> _refreshCourses() async {
    await _loadCourses();
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Error", style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text(message),
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK", style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredList = _courses.where((course) {
      final matchesMode = course['mode'] == _selectedMode;
      final matchesSearch = course['subject'].toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesMode && matchesSearch;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      extendBody: true,
      resizeToAvoidBottomInset: true,
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddCourseScreen()),
          );
          if (result == true) {
            _loadCourses();
          }
        },
        backgroundColor: Colors.black,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 35),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: RefreshIndicator(
        onRefresh: _refreshCourses,
        color: Colors.black,
        child: Column(
          children: [
            _buildHeader(context),
            const SizedBox(height: 20),
            _buildSearchBar(),
            _buildModeSlider(),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : filteredList.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                itemCount: filteredList.length,
                itemBuilder: (context, index) => _buildCourseCard(filteredList[index]),
              ),
            ),
          ],
        ),
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
            hintText: "Search courses...",
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
            color: isSelected ? Colors.black : Colors.transparent,
            borderRadius: BorderRadius.circular(25),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cancel_outlined, size: 100, color: Colors.black12),
            const SizedBox(height: 10),
            const Text(
              "Nothing Here Yet",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black26),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              "No courses available in this category.",
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.normal, color: Colors.black26),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildCourseCard(Map<String, dynamic> data) {
    // Get the course color based on course ID
    final Color courseColor = CourseColors.getCourseColor(data['id']);

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: Row(
        children: [
          // Colored container with app icon - using dynamic course color
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: courseColor, // Using dynamic course color
              borderRadius: BorderRadius.circular(15),
            ),
            child: Center(
              child: Image.asset(
                'assets/icon/app_icon.png',
                width: 40,
                height: 40,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        data['subject'],
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 14),
                        Text(" ${data['rating']}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(data['price'], style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 12)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(data['mode'].toUpperCase(), style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 9)),
                    const Text(" | ", style: TextStyle(color: Colors.grey)),
                    Expanded(
                      child: Text(
                        "${data['students']} Student${data['students'] != 1 ? 's' : ''}",
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 9),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CourseDetailScreen(
                            courseId: data['id'],
                            onCourseUpdated: () {
                              _loadCourses();
                            },
                          ),
                        ),
                      );
                      if (result == true) {
                        _loadCourses();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      minimumSize: const Size(0, 28),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                    ),
                    child: const Text("Details", style: TextStyle(color: Colors.white, fontSize: 10)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}