import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'edit_course_screen.dart';
import '../services/course_service.dart';

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

class CourseDetailScreen extends StatefulWidget {
  final int courseId;
  final VoidCallback onCourseUpdated;

  const CourseDetailScreen({
    super.key,
    required this.courseId,
    required this.onCourseUpdated,
  });

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
  Map<String, dynamic>? currentCourse;
  bool _isLoading = true;
  bool _isToggling = false;
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;
  bool _isExpanded = false; // For read more functionality

  @override
  void initState() {
    super.initState();
    _loadCourseData();
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
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadCourseData() async {
    setState(() => _isLoading = true);

    try {
      final courseData = await CourseService.getTutorCourseDetail(widget.courseId);

      setState(() {
        currentCourse = courseData;
        _isLoading = false;
      });

    } catch (e) {
      print('Error loading course: $e');
      setState(() => _isLoading = false);
      _showErrorDialog("Error loading course: ${e.toString().replaceFirst('Exception: ', '')}");
    }
  }

  Future<void> _refreshCourseData() async {
    await _loadCourseData();
  }

  Future<void> _toggleAvailability() async {
    if (currentCourse == null) return;

    bool isCurrentlyAvailable = currentCourse!['isAvailable'] ?? true;

    bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          isCurrentlyAvailable ? "Make Unavailable?" : "Make Available?",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(
          isCurrentlyAvailable
              ? "This course will no longer be visible to students. Are you sure?"
              : "This course will become visible to students again. Are you sure?",
        ),
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              "Cancel",
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              isCurrentlyAvailable ? "Make Unavailable" : "Make Available",
              style: TextStyle(
                color: isCurrentlyAvailable ? Colors.red : Colors.green,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isToggling = true);

    try {
      await CourseService.toggleAvailability(widget.courseId);

      setState(() {
        currentCourse!['isAvailable'] = !isCurrentlyAvailable;
        _isToggling = false;
      });

      widget.onCourseUpdated();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Course is now ${!isCurrentlyAvailable ? 'available' : 'unavailable'}"),
          backgroundColor: !isCurrentlyAvailable ? Colors.green : Colors.orange,
          duration: const Duration(milliseconds: 1500),
          behavior: SnackBarBehavior.floating,
        ),
      );

    } catch (e) {
      setState(() => _isToggling = false);
      _showErrorDialog("Failed to update availability: ${e.toString().replaceFirst('Exception: ', '')}");
    }
  }

  Future<void> _deleteCourse() async {
    bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Course?", style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text("This action cannot be undone. All data associated with this course will be permanently deleted."),
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey, fontSize: 16)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              "Delete",
              style: TextStyle(color: Colors.red, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);

    try {
      await CourseService.deleteCourse(widget.courseId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Course deleted successfully"),
            backgroundColor: Colors.green,
            duration: Duration(milliseconds: 1500),
            behavior: SnackBarBehavior.floating,
          ),
        );

        widget.onCourseUpdated();
        Navigator.pop(context, true);
      }

    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorDialog("Failed to delete course: ${e.toString().replaceFirst('Exception: ', '')}");
    }
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
            child: const Text("OK", style: TextStyle(color: Colors.black, fontSize: 16)),
          ),
        ],
      ),
    );
  }

  int _timeToMinutes(String? timeStr) {
    if (timeStr == null || timeStr.isEmpty) return 0;

    try {
      String timeToParse = timeStr;
      bool isPM = false;

      if (timeStr.toUpperCase().contains('PM')) {
        isPM = true;
        timeToParse = timeStr.toUpperCase().replaceAll('PM', '').trim();
      } else if (timeStr.toUpperCase().contains('AM')) {
        timeToParse = timeStr.toUpperCase().replaceAll('AM', '').trim();
      }

      List<String> parts = timeToParse.split(':');
      if (parts.isEmpty) return 0;

      int hour = int.tryParse(parts[0]) ?? 0;
      int minute = parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0;

      if (isPM && hour != 12) {
        hour += 12;
      } else if (!isPM && hour == 12) {
        hour = 0;
      }

      return hour * 60 + minute;
    } catch (e) {
      return 0;
    }
  }

  String _formatTime(String? timeStr) {
    if (timeStr == null || timeStr.isEmpty) return "N/A";

    try {
      if (timeStr.toUpperCase().contains('AM') || timeStr.toUpperCase().contains('PM')) {
        return timeStr;
      }

      List<String> parts = timeStr.split(':');
      if (parts.isEmpty) return "N/A";

      int hour = int.tryParse(parts[0]) ?? 0;
      int minute = parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0;

      String period = hour >= 12 ? "PM" : "AM";
      int hour12 = hour % 12;
      if (hour12 == 0) hour12 = 12;

      String minuteStr = minute.toString().padLeft(2, '0');

      return "$hour12:$minuteStr $period";
    } catch (e) {
      return timeStr;
    }
  }

  String _calculateTotalHours(String? startTime, String? endTime) {
    if (startTime == null || endTime == null) return "N/A";
    if (startTime.isEmpty || endTime.isEmpty) return "N/A";

    try {
      int startMinutes = _timeToMinutes(startTime);
      int endMinutes = _timeToMinutes(endTime);

      int totalMinutes = endMinutes - startMinutes;

      if (totalMinutes <= 0) return "N/A";

      int hours = totalMinutes ~/ 60;
      int minutes = totalMinutes % 60;

      if (hours == 0) {
        return "$minutes minutes";
      } else if (minutes == 0) {
        return "$hours hour${hours > 1 ? 's' : ''}";
      } else {
        return "$hours hour${hours > 1 ? 's' : ''} $minutes min";
      }
    } catch (e) {
      return "N/A";
    }
  }

  IconData _getModeIcon(String? mode) {
    if (mode == null) return Icons.help_outline;

    final lowerMode = mode.toLowerCase().replaceAll('_', ' ');

    if (lowerMode.contains('online')) return Icons.wifi;
    if (lowerMode.contains('student home')) return Icons.home_rounded;
    if (lowerMode.contains('tutor home')) return Icons.home_work;
    return Icons.location_on_outlined;
  }

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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.black,
          elevation: 0,
          toolbarHeight: 0,
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Colors.black,
            statusBarIconBrightness: Brightness.light,
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (currentCourse == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.black,
          elevation: 0,
          toolbarHeight: 0,
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Colors.black,
            statusBarIconBrightness: Brightness.light,
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 60, color: Colors.grey),
              const SizedBox(height: 16),
              const Text("Course not found"),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                child: const Text("Go Back", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      );
    }

    final Color courseColor = CourseColors.getCourseColor(widget.courseId);
    final bool isAvailable = currentCourse!['isAvailable'] ?? true;
    final double bgHeight = MediaQuery.of(context).size.height * 0.4;
    final String startTime = _formatTime(currentCourse!['startTime']);
    final String endTime = _formatTime(currentCourse!['endTime']);
    final String totalHours = _calculateTotalHours(currentCourse!['startTime'], currentCourse!['endTime']);

    // Get about text and check if it needs read more
    final String aboutText = currentCourse!['about'] ?? "No description available.";
    final bool needsReadMore = aboutText.length > 100; // Adjust threshold as needed

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        toolbarHeight: 0,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.black,
          statusBarIconBrightness: Brightness.light,
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshCourseData,
        color: Colors.black,
        backgroundColor: Colors.white,
        child: NotificationListener<ScrollNotification>(
          onNotification: (scrollInfo) {
            if (!_isLoadingMore &&
                scrollInfo.metrics.pixels >= scrollInfo.metrics.maxScrollExtent - 100) {
              // You can add pagination logic here if needed
            }
            return false;
          },
          child: SingleChildScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      height: bgHeight,
                      width: double.infinity,
                      color: courseColor,
                      child: SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GestureDetector(
                                onTap: () => Navigator.pop(context),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                                  child: const Icon(Icons.arrow_back, color: Colors.black),
                                ),
                              ),
                              if (_isToggling)
                                const SizedBox(width: 40, height: 40, child: CircularProgressIndicator(strokeWidth: 2))
                              else
                                PopupMenuButton<String>(
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                  color: Colors.white,
                                  icon: const Icon(Icons.more_vert, color: Colors.white, size: 28),
                                  onSelected: (value) {
                                    if (value == 'toggle') {
                                      _toggleAvailability();
                                    }
                                  },
                                  itemBuilder: (context) => [
                                    PopupMenuItem(
                                      value: 'toggle',
                                      child: Row(
                                        children: [
                                          Icon(
                                            isAvailable ? Icons.visibility_off : Icons.visibility,
                                            color: isAvailable ? Colors.red : Colors.green,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 12),
                                          Text(
                                            isAvailable ? "Make Unavailable" : "Make Available",
                                            style: TextStyle(
                                              color: isAvailable ? Colors.red : Colors.green,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: bgHeight * 0.6),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 25),
                        padding: const EdgeInsets.all(25),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [const BoxShadow(color: Colors.black12, blurRadius: 20, offset: Offset(0, 10))],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    currentCourse!['subject'] ?? "Course Detail",
                                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Row(
                                  children: [
                                    const Icon(Icons.star, color: Colors.orange, size: 20),
                                    Text(" ${currentCourse!['averageRating'] ?? 0.0}", style: const TextStyle(fontWeight: FontWeight.bold)),
                                    const SizedBox(width: 4),
                                    Text("(${currentCourse!['totalRatings'] ?? 0})", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 15),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      const Icon(Icons.category, size: 18),
                                      const SizedBox(width: 5),
                                      Flexible(
                                        child: Text(
                                          currentCourse!['category'] ?? "N/A",
                                          style: const TextStyle(fontWeight: FontWeight.w500),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      const Icon(Icons.access_time, size: 18),
                                      const SizedBox(width: 5),
                                      Text(totalHours, style: const TextStyle(fontWeight: FontWeight.w500)),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  "Rs ${currentCourse!['price'] ?? 0}",
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
                                ),
                              ],
                            ),
                            const SizedBox(height: 25),
                            const Text("About", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 10),
                            // Read more functionality for About text
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _isExpanded ? aboutText : aboutText.length > 100 ? '${aboutText.substring(0, 100)}...' : aboutText,
                                  style: const TextStyle(color: Colors.grey, height: 1.5),
                                ),
                                if (aboutText.length > 100)
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _isExpanded = !_isExpanded;
                                      });
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: Text(
                                        _isExpanded ? "Read less" : "Read more",
                                        style: const TextStyle(
                                          color: Colors.blue,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(25),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("What You Provide", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 20),
                      _detail(Icons.menu_book, "${currentCourse!['classesPerMonth'] ?? 0} Classes per month"),
                      _detail(Icons.access_time, "$startTime - $endTime"),
                      _detail(Icons.calendar_month, "${currentCourse!['fromDay'] ?? 'Monday'} to ${currentCourse!['toDay'] ?? 'Friday'}"),
                      _detail(_getModeIcon(currentCourse!['teachingMode']), _formatMode(currentCourse!['teachingMode'])),
                      _detail(Icons.location_on, currentCourse!['location'] ?? "Location not specified"),
                      const SizedBox(height: 30),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _deleteCourse,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFE0E0E0),
                                foregroundColor: Colors.black,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(vertical: 18),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                              ),
                              child: const Text("Delete"),
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EditCourseScreen(courseId: widget.courseId),
                                  ),
                                );
                                if (result == true) {
                                  _loadCourseData();
                                  widget.onCourseUpdated();
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 18),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                              ),
                              child: const Text("Edit"),
                            ),
                          ),
                        ],
                      ),
                      if (!isAvailable)
                        Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade50,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.orange.shade200),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.visibility_off, color: Colors.orange.shade700),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    "This course is currently unavailable. Students cannot see or enroll in it.",
                                    style: TextStyle(color: Colors.orange.shade700, fontSize: 12),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      const SizedBox(height: 20),
                      if (_isLoadingMore)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Center(
                            child: SizedBox(
                              width: 30,
                              height: 30,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _detail(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(
        children: [
          Icon(icon, size: 24, color: Colors.black87),
          const SizedBox(width: 15),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 16))),
        ],
      ),
    );
  }
}