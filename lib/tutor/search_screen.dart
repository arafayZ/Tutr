import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/custom_tab_header.dart';
import 'course_detail_screen.dart';
import 'student_profile_screen.dart';
import '../services/course_service.dart';
import '../services/connection_service.dart';
import '../config/api_config.dart';
import '../utils/status_bar_config.dart';

// --- COURSE COLORS (Same as dashboard) ---
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

// --- DATA MODELS ---
class CourseData {
  final int id;
  final String tutorName;
  final String subject;
  final String grade;
  final String price;
  final String rating;
  final String mode;
  final Color color;

  CourseData({
    required this.id,
    required this.tutorName,
    required this.subject,
    required this.grade,
    required this.price,
    required this.rating,
    required this.mode,
    required this.color,
  });
}

class StudentData {
  final String studentId;
  final String name;
  final String? profilePic;
  final String? location;
  final String? phone;
  final String? email;
  final String connectionId;
  final List<Map<String, dynamic>> courses;
  final String? category;
  final String? teachingMode;

  StudentData({
    required this.studentId,
    required this.name,
    this.profilePic,
    this.location,
    this.phone,
    this.email,
    required this.connectionId,
    this.courses = const [],
    this.category,
    this.teachingMode,
  });
}

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  bool isSearchingCourses = true;
  String searchQuery = "";
  bool _isLoading = true;

  Map<String, bool> selectedCategories = {
    "Matric": false,
    "Intermediate": false,
    "O Level": false,
    "A Level": false,
    "Entrance Test": false,
  };

  Map<String, bool> selectedModes = {
    "Online": false,
    "Student Home": false,
    "Tutor Home": false,
  };

  List<CourseData> _allCourses = [];
  List<StudentData> _allStudents = [];
  List<StudentData> _filteredStudents = [];
  int _tutorProfileId = 0;

  @override
  void initState() {
    super.initState();
    StatusBarConfig.setLightStatusBar();
    _loadData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    _tutorProfileId = prefs.getInt('profileId') ?? 0;

    await Future.wait([
      _loadCourses(),
      _loadAllStudents(),
    ]);
    setState(() => _isLoading = false);
  }

  Future<void> _loadCourses() async {
    try {
      List<dynamic> courses = await CourseService.getTutorCourseCards(_tutorProfileId);

      setState(() {
        _allCourses = courses.map((course) {
          int courseId = course['courseId'] ?? course['id'];
          return CourseData(
            id: courseId,
            tutorName: course['tutorName'] ?? 'Tutor',
            subject: course['subject'] ?? 'Course',
            grade: _mapBackendCategoryToDisplay(course['category']),
            price: course['price']?.toString() ?? '0',
            rating: (course['averageRating'] ?? 0.0).toString(),
            mode: _mapBackendModeToDisplay(course['teachingMode']),
            color: CourseColors.getCourseColor(courseId), // Using dynamic color
          );
        }).toList();
      });
    } catch (e) {
      print('Error loading courses: $e');
    }
  }

  Future<void> _loadAllStudents() async {
    try {
      List<Map<String, dynamic>> connections = await ConnectionService.getTutorConfirmedConnections(_tutorProfileId);

      // Group connections by studentId (each student appears only once)
      Map<String, Map<String, dynamic>> groupedStudents = {};

      for (var conn in connections) {
        String studentId = conn['studentId'].toString();

        if (groupedStudents.containsKey(studentId)) {
          // Student already exists, add course to their list
          groupedStudents[studentId]!['courses'].add({
            'courseName': conn['courseName'] ?? conn['subject'] ?? 'Course',
            'agreedPrice': conn['agreedPrice'] ?? 0,
            'originalPrice': conn['originalPrice'] ?? 0,
            'connectionId': conn['connectionId'],
          });
        } else {
          // New student, create entry with courses list
          groupedStudents[studentId] = {
            'studentId': studentId,
            'name': conn['studentName'] ?? 'Unknown Student',
            'profilePic': conn['studentImage'],
            'location': conn['location'],
            'phone': conn['phoneNumber'],
            'email': conn['studentEmail'],
            'category': conn['category'],
            'teachingMode': conn['teachingMode'],
            'courses': [{
              'courseName': conn['courseName'] ?? conn['subject'] ?? 'Course',
              'agreedPrice': conn['agreedPrice'] ?? 0,
              'originalPrice': conn['originalPrice'] ?? 0,
              'connectionId': conn['connectionId'],
            }],
          };
        }
      }

      // Convert grouped map to list
      List<StudentData> groupedList = [];
      for (var entry in groupedStudents.values) {
        groupedList.add(StudentData(
          studentId: entry['studentId'],
          name: entry['name'],
          profilePic: entry['profilePic'],
          location: entry['location'],
          phone: entry['phone'],
          email: entry['email'],
          connectionId: entry['courses'].isNotEmpty ? entry['courses'][0]['connectionId'].toString() : "0",
          courses: entry['courses'],
          category: entry['category'],
          teachingMode: entry['teachingMode'],
        ));
      }

      setState(() {
        _allStudents = groupedList;
        _filteredStudents = List.from(_allStudents);
      });
    } catch (e) {
      print('Error loading students: $e');
    }
  }

  Future<void> _filterStudents() async {
    setState(() => _isLoading = true);

    final selectedCats = selectedCategories.entries.where((e) => e.value).map((e) => e.key).toList();
    final selectedModesList = selectedModes.entries.where((e) => e.value).map((e) => e.key).toList();

    try {
      if (selectedCats.isEmpty && selectedModesList.isEmpty) {
        // No filters - show all students
        setState(() {
          _filteredStudents = List.from(_allStudents);
          _isLoading = false;
        });
        return;
      }

      // Get filtered connection IDs from API
      String? categoryBackend;
      String? modeBackend;

      if (selectedCats.isNotEmpty) {
        categoryBackend = _mapDisplayCategoryToBackend(selectedCats.first);
      }
      if (selectedModesList.isNotEmpty) {
        modeBackend = _mapDisplayModeToBackend(selectedModesList.first);
      }

      List<Map<String, dynamic>> filteredConnections = await ConnectionService.filterStudents(
        _tutorProfileId,
        category: categoryBackend,
        teachingMode: modeBackend,
      );

      // Get filtered student IDs
      Set<String> filteredStudentIds = {};
      for (var conn in filteredConnections) {
        filteredStudentIds.add(conn['studentId'].toString());
      }

      // Filter from _allStudents (preserving all course data)
      List<StudentData> filteredList = _allStudents.where((student) =>
          filteredStudentIds.contains(student.studentId)
      ).toList();

      setState(() {
        _filteredStudents = filteredList;
        _isLoading = false;
      });

    } catch (e) {
      print('Error filtering students: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _searchStudents(String query) async {
    if (query.isEmpty) {
      await _filterStudents();
      return;
    }

    // Filter from _allStudents based on name search
    setState(() {
      _filteredStudents = _allStudents.where((s) =>
          s.name.toLowerCase().contains(query.toLowerCase())
      ).toList();
    });
  }

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

  String _mapBackendModeToDisplay(String? backendMode) {
    if (backendMode == null) return "Online";
    switch (backendMode.toUpperCase()) {
      case "ONLINE": return "Online";
      case "STUDENT_HOME": return "Student Home";
      case "TUTOR_HOME": return "Tutor Home";
      default: return backendMode;
    }
  }

  String _mapDisplayCategoryToBackend(String displayCategory) {
    switch (displayCategory) {
      case "Matric": return "MATRIC";
      case "Intermediate": return "INTERMEDIATE";
      case "O Level": return "O_LEVEL";
      case "A Level": return "A_LEVEL";
      case "Entrance Test": return "ENTRY_TEST";
      default: return displayCategory.toUpperCase();
    }
  }

  String _mapDisplayModeToBackend(String displayMode) {
    switch (displayMode) {
      case "Online": return "ONLINE";
      case "Student Home": return "STUDENT_HOME";
      case "Tutor Home": return "TUTOR_HOME";
      default: return displayMode.toUpperCase();
    }
  }

  List<CourseData> get _filteredCourses {
    return _allCourses.where((c) {
      bool matchesSearch = c.subject.toLowerCase().contains(searchQuery.toLowerCase()) ||
          c.tutorName.toLowerCase().contains(searchQuery.toLowerCase());
      bool noCategoryFilter = !selectedCategories.values.contains(true);
      bool matchesCategory = noCategoryFilter || selectedCategories[c.grade] == true;
      bool noModeFilter = !selectedModes.values.contains(true);
      bool matchesMode = noModeFilter || selectedModes[c.mode] == true;
      return matchesSearch && matchesCategory && matchesMode;
    }).toList();
  }

  List<StudentData> get _filteredStudentList {
    if (searchQuery.isEmpty) return _filteredStudents;
    return _filteredStudents.where((s) => s.name.toLowerCase().contains(searchQuery.toLowerCase())).toList();
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterBottomSheet(
        initialCategories: selectedCategories,
        initialModes: selectedModes,
        onApply: (newCats, newModes) async {
          setState(() {
            selectedCategories = newCats;
            selectedModes = newModes;
          });
          await _filterStudents();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final courses = _filteredCourses;
    final students = _filteredStudentList;
    final resultsCount = isSearchingCourses ? courses.length : students.length;
    final hasNoResults = !_isLoading && resultsCount == 0;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: Column(
        children: [
          Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 15,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 45,
                          height: 45,
                          decoration: const BoxDecoration(
                            color: Colors.black,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                      ),
                    ),
                    const Text(
                      "Search",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 30, 20, 20),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
                    ),
                    child: TextField(
                      onChanged: (val) {
                        setState(() {
                          searchQuery = val;
                        });
                        if (!isSearchingCourses) {
                          _searchStudents(val);
                        }
                      },
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30)),
              child: Row(
                children: [
                  _buildTabButton("Courses", isSearchingCourses, () => setState(() => isSearchingCourses = true)),
                  _buildTabButton("Students", !isSearchingCourses, () {
                    setState(() {
                      isSearchingCourses = false;
                      if (searchQuery.isNotEmpty) {
                        _searchStudents(searchQuery);
                      } else {
                        _filterStudents();
                      }
                    });
                  }),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
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
                        style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                Text("$resultsCount FOUND", style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 12)),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : hasNoResults
                ? _buildNoResultsMessage()
                : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: resultsCount,
              itemBuilder: (context, index) {
                if (isSearchingCourses) {
                  return _buildCourseItem(courses[index]);
                } else {
                  return _buildStudentItem(students[index]);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResultsMessage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isSearchingCourses ? Icons.search_off : Icons.person_search,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            isSearchingCourses ? "No Courses Found" : "No Students Found",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isSearchingCourses
                ? "Try adjusting your search or filter criteria"
                : "No students match your search or filter criteria",
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade400,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              setState(() {
                searchQuery = "";
                selectedCategories.updateAll((k, v) => false);
                selectedModes.updateAll((k, v) => false);
                if (isSearchingCourses) {
                  // Refresh courses
                } else {
                  _filterStudents();
                }
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text("Clear Filters", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String label, bool isActive, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? Colors.black : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(color: isActive ? Colors.white : Colors.black, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _buildCourseItem(CourseData course) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CourseDetailScreen(
              courseId: course.id,
              onCourseUpdated: () {},
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
        ),
        child: Row(
          children: [
            // Colored container with app icon - using dynamic course color
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: course.color, // Using dynamic course color
                borderRadius: BorderRadius.circular(15),
              ),
              child: Center(
                child: Image.asset(
                  'assets/icon/app_icon.png',
                  width: 45,
                  height: 45,
                  color: Colors.white,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.school, color: Colors.white, size: 40);
                  },
                ),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course.tutorName,
                    style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                  Text(
                    course.subject,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Row(
                    children: [
                      Text(
                        "Rs ${course.price}",
                        style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          course.grade,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        course.rating,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          course.mode.toUpperCase(),
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildStudentItem(StudentData student) {
    final int courseCount = student.courses.length;
    final String courseNames = student.courses
        .map((c) => c['courseName']?.toString() ?? 'Course')
        .join(', ');

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 5)],
      ),
      child: ListTile(
        onTap: () {
          final details = StudentDetails(
            id: student.studentId,
            connectionId: student.connectionId,
            name: student.name,
            profilePic: student.profilePic ?? '',
            location: student.location ?? "Not specified",
            dob: "Not specified",
            gender: "Not specified",
            college: "Not specified",
            school: "Not specified",
            phone: student.phone ?? "Not available",
            email: student.email ?? "Not available",
          );
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => StudentProfileScreen(
                student: details,
                onDisconnect: (id) {},
              ),
            ),
          );
        },
        leading: CircleAvatar(
          radius: 25,
          backgroundColor: Colors.grey.shade300,
          backgroundImage: student.profilePic != null && student.profilePic!.isNotEmpty
              ? NetworkImage('${ApiConfig.baseUrl}${student.profilePic}')
              : null,
          child: student.profilePic == null || student.profilePic!.isEmpty
              ? const Icon(Icons.person, color: Colors.grey, size: 25)
              : null,
        ),
        title: Text(
          student.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              "$courseCount course${courseCount != 1 ? 's' : ''}",
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 2),
            Text(
              courseNames,
              style: const TextStyle(fontSize: 11, color: Colors.grey),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
      ),
    );
  }
}

// --- FILTER BOTTOM SHEET ---
class FilterBottomSheet extends StatefulWidget {
  final Map<String, bool> initialCategories;
  final Map<String, bool> initialModes;
  final Function(Map<String, bool>, Map<String, bool>) onApply;

  const FilterBottomSheet({
    super.key,
    required this.initialCategories,
    required this.initialModes,
    required this.onApply,
  });

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late Map<String, bool> categories;
  late Map<String, bool> teachingModes;

  @override
  void initState() {
    super.initState();
    categories = Map.from(widget.initialCategories);
    teachingModes = Map.from(widget.initialModes);
  }

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
                  onPressed: () {
                    widget.onApply(categories, teachingModes);
                    Navigator.pop(context);
                  },
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