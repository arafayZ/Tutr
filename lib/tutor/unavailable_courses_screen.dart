import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'course_detail_screen.dart';
import '../services/course_service.dart';
import '../config/api_config.dart';

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

class UnavailableCoursesScreen extends StatefulWidget {
  const UnavailableCoursesScreen({super.key});

  @override
  State<UnavailableCoursesScreen> createState() => _UnavailableCoursesScreenState();
}

class _UnavailableCoursesScreenState extends State<UnavailableCoursesScreen> {
  List<Map<String, dynamic>> _courses = [];
  bool _isLoading = true;
  int _tutorProfileId = 0;

  @override
  void initState() {
    super.initState();
    _loadUnavailableCourses();
    // Set status bar to white text with black background
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.black,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    );
  }

  @override
  void dispose() {
    // DO NOT reset status bar here - let the dashboard handle it
    // Removing this prevents the status bar from changing when returning to dashboard
    super.dispose();
  }

  // Format mode to remove underscores and capitalize
  String _formatMode(String? mode) {
    if (mode == null || mode.isEmpty) return "Online";
    String formatted = mode.replaceAll('_', ' ');
    List<String> words = formatted.split(' ');
    for (int i = 0; i < words.length; i++) {
      if (words[i].isNotEmpty) {
        words[i] = words[i][0].toUpperCase() + words[i].substring(1).toLowerCase();
      }
    }
    return words.join(' ');
  }

  Future<void> _loadUnavailableCourses() async {
    setState(() => _isLoading = true);

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      _tutorProfileId = prefs.getInt('profileId') ?? 0;

      List<dynamic> courses = await CourseService.getTutorCourses(_tutorProfileId);

      List<Map<String, dynamic>> unavailableCourses = [];
      for (var course in courses) {
        if (course['isAvailable'] == false) {
          int courseId = course['id'];
          unavailableCourses.add({
            'id': courseId,
            'title': course['subject'] ?? 'Unknown',
            'price': course['price']?.toString() ?? '0',
            'rating': course['averageRating']?.toString() ?? '0.0',
            'level': course['category'] ?? 'N/A',
            'students': course['totalStudents'] ?? 0,
            'color': CourseColors.getCourseColor(courseId),
            'mode': _formatMode(course['teachingMode']),
            'location': course['location'] ?? 'N/A',
            'about': course['about'] ?? 'No description available',
            'startTime': course['startTime'],
            'endTime': course['endTime'],
            'fromDay': course['fromDay'],
            'toDay': course['toDay'],
            'classesPerMonth': course['classesPerMonth'],
            'isAvailable': course['isAvailable'],
          });
        }
      }

      setState(() {
        _courses = unavailableCourses;
        _isLoading = false;
      });

    } catch (e) {
      print('Error loading unavailable courses: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _makeAvailable(int courseId, int index) async {
    setState(() => _isLoading = true);

    try {
      await CourseService.toggleAvailability(courseId);

      setState(() {
        _courses.removeAt(index);
        _isLoading = false;
      });

      _showSuccessDialog();

    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorDialog("Failed to make course available: ${e.toString().replaceFirst('Exception: ', '')}");
    }
  }

  void _showAvailablePopup(BuildContext context, int index) {
    final course = _courses[index];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text(
            "Make Course Available?",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          content: Text(
            "Are you sure you want to make '${course['title']}' available? New students will be able to book this course.",
            style: const TextStyle(color: Colors.black87, fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "CANCEL",
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _makeAvailable(course['id'], index);
              },
              child: const Text(
                "CONFIRM",
                style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        Future.delayed(const Duration(seconds: 2), () {
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          }
        });

        return AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 20),
              Icon(Icons.check_circle, color: Colors.green, size: 60),
              SizedBox(height: 20),
              Text(
                "Success!",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                "Course is now available to students!",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text("Error", style: TextStyle(color: Colors.red)),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK", style: TextStyle(color: Colors.black)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        toolbarHeight: 0,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.black,
          statusBarIconBrightness: Brightness.light,
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _courses.isEmpty
                  ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildEmptyState(),
              )
                  : RefreshIndicator(
                onRefresh: _loadUnavailableCourses,
                color: Colors.black,
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  physics: const BouncingScrollPhysics(),
                  itemCount: _courses.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CourseDetailScreen(
                              courseId: _courses[index]['id'],
                              onCourseUpdated: () {
                                _loadUnavailableCourses();
                              },
                            ),
                          ),
                        );
                        if (result == true) {
                          _loadUnavailableCourses();
                        }
                      },
                      child: _buildCourseCard(context, _courses[index], index),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.do_not_disturb_on_rounded, size: 100, color: Color(0xFFBDBDBD)),
          const SizedBox(height: 25),
          const Text(
            "No Unavailable Courses",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: Color(0xFFBDBDBD)),
          ),
          const SizedBox(height: 12),
          const Text(
            "All your courses are currently active.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Color(0xFFBDBDBD), letterSpacing: 0.5),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              height: 40,
              width: 40,
              decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle),
              child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
            ),
          ),
          const Expanded(
            child: Center(
              child: Padding(
                padding: EdgeInsets.only(right: 40),
                child: Text(
                  "Unavailable Courses",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseCard(BuildContext context, Map<String, dynamic> course, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 85,
            height: 85,
            decoration: BoxDecoration(
              color: course['color'] ?? Colors.grey,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Center(
              child: Image.asset(
                'assets/icon/app_icon.png',
                width: 50,
                height: 50,
                color: Colors.white,
                errorBuilder: (context, error, stackTrace) {
                  return Text(
                    course['title']?.substring(0, 1).toUpperCase() ?? '?',
                    style: const TextStyle(fontSize: 30, color: Colors.white, fontWeight: FontWeight.bold),
                  );
                },
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
                        course['title'] ?? "Unknown",
                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        Text(
                          " ${course['rating'] ?? '0.0'}",
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey),
                        )
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  "Rs ${course['price'] ?? 0} | ${course['level'] ?? 'N/A'}",
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.blue),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Text(
                      course['mode']?.toUpperCase() ?? "ONLINE",
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.red),
                    ),
                    const Text(" | ", style: TextStyle(color: Colors.grey, fontSize: 10)),
                    Text("${course['students'] ?? 0} Students", style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () => _showAvailablePopup(context, index),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        "Make Available",
                        style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
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