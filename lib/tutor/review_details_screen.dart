import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/course_service.dart';
import '../widgets/custom_tab_header.dart';
import 'course_detail_screen.dart';
import '../services/rating_service.dart';
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

class ReviewDetailsScreen extends StatefulWidget {
  final int reviewId;
  final String studentName;
  final String rating;
  final String review;
  final String? profilePic;
  final int? courseId;
  final String courseName;
  final String tutorName;
  final String? createdAt;

  const ReviewDetailsScreen({
    super.key,
    required this.reviewId,
    required this.studentName,
    required this.rating,
    required this.review,
    this.profilePic,
    this.courseId,
    required this.courseName,
    required this.tutorName,
    this.createdAt,
  });

  @override
  State<ReviewDetailsScreen> createState() => _ReviewDetailsScreenState();
}

class _ReviewDetailsScreenState extends State<ReviewDetailsScreen> with WidgetsBindingObserver {
  Map<String, dynamic>? _reviewDetail;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    StatusBarConfig.setLightStatusBar();
    _loadReviewDetail();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Ensure status bar is set when returning to this screen
    StatusBarConfig.setLightStatusBar();
  }

  Future<void> _loadReviewDetail() async {
    setState(() => _isLoading = true);

    try {
      final detail = await RatingService.getReviewDetail(widget.reviewId);

      setState(() {
        _reviewDetail = detail;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading review detail: $e');
      setState(() => _isLoading = false);
      _showErrorDialog(
          "Failed to load review details: ${e.toString().replaceFirst(
              'Exception: ', '')}");
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
            title: const Text("Error", style: TextStyle(fontWeight: FontWeight
                .bold)),
            content: Text(message),
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("OK", style: TextStyle(color: Colors.black)),
              ),
            ],
          ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return "Recently";
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays < 7) {
        if (difference.inDays == 0) return "Today";
        if (difference.inDays == 1) return "Yesterday";
        return "${difference.inDays} days ago";
      } else if (difference.inDays < 30) {
        final weeks = (difference.inDays / 7).floor();
        return "$weeks week${weeks > 1 ? 's' : ''} ago";
      } else {
        return "${date.day}/${date.month}/${date.year}";
      }
    } catch (e) {
      return "Recently";
    }
  }

  String _formatMode(String? mode) {
    if (mode == null) return "ONLINE";
    switch (mode.toUpperCase()) {
      case "ONLINE":
        return "ONLINE";
      case "STUDENT_HOME":
        return "STUDENT HOME";
      case "TUTOR_HOME":
        return "TUTOR HOME";
      default:
        return mode.toUpperCase();
    }
  }

  String _mapBackendCategoryToDisplay(String? backendCategory) {
    if (backendCategory == null) return "";
    switch (backendCategory.toUpperCase()) {
      case "MATRIC":
        return "Matric";
      case "INTERMEDIATE":
        return "Intermediate";
      case "O_LEVEL":
        return "O Level";
      case "A_LEVEL":
        return "A Level";
      case "ENTRY_TEST":
        return "Entrance Test";
      default:
        return backendCategory;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use data from API response directly
    final displayReviewId = _reviewDetail?['reviewId'] ?? widget.reviewId;
    final displayStudentName = _reviewDetail?['studentName'] ??
        widget.studentName;
    final displayRating = _reviewDetail?['rating']?.toString() ?? widget.rating;
    final displayReview = _reviewDetail?['review'] ?? widget.review;
    final displayProfilePic = _reviewDetail?['studentImage'] ??
        widget.profilePic;
    final displayCreatedAt = _reviewDetail?['createdAt'] ?? widget.createdAt;
    final displayCourseId = _reviewDetail?['courseId'] ?? widget.courseId;
    final displayCourseName = _reviewDetail?['subject'] ?? widget.courseName;
    final displayTutorName = _reviewDetail?['tutorName'] ?? widget.tutorName;
    final displayCoursePrice = _reviewDetail?['price'] ?? 0;
    final displayCourseCategory = _mapBackendCategoryToDisplay(
        _reviewDetail?['category']);
    final displayCourseRating = _reviewDetail?['averageRating'] ?? 4.0;
    final displayCourseMode = _formatMode(_reviewDetail?['teachingMode']);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: Column(
        children: [
          // Increased vertical length with padding (keeping text size 20)
          Container(
            padding: const EdgeInsets.only(top: 16, bottom: 8),
            child: const CustomTabHeader(
              title: Text(
                "Reviews",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCourseSummaryCard(
                    courseId: displayCourseId,
                    courseName: displayCourseName,
                    tutorName: displayTutorName,
                    price: displayCoursePrice,
                    category: displayCourseCategory,
                    rating: displayCourseRating,
                    mode: displayCourseMode,
                  ),
                  const SizedBox(height: 30),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 22,
                              backgroundColor: Colors.grey.shade300,
                              backgroundImage: displayProfilePic != null &&
                                  displayProfilePic.isNotEmpty
                                  ? NetworkImage(
                                  '${ApiConfig.baseUrl}$displayProfilePic')
                                  : null,
                              child: displayProfilePic == null ||
                                  displayProfilePic.isEmpty
                                  ? const Icon(
                                  Icons.person, color: Colors.grey, size: 20)
                                  : null,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                displayStudentName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEDF2FF),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: const Color(0xFF0961F5).withOpacity(
                                      0.2),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.star, color: Colors.orange,
                                      size: 14),
                                  const SizedBox(width: 4),
                                  Text(
                                    displayRating,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: Color(0xFF1A237E),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),
                        Text(
                          displayReview,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          _formatDate(displayCreatedAt),
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseSummaryCard({
    required int? courseId,
    required String courseName,
    required String tutorName,
    required dynamic price,
    required String category,
    required double rating,
    required String mode,
  }) {
    // Get course color based on course ID
    final Color courseColor = courseId != null
        ? CourseColors.getCourseColor(courseId)
        : const Color(0xFF8C1414); // Fallback color if no courseId

    return GestureDetector(
      onTap: () {
        if (courseId != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  CourseDetailScreen(
                    courseId: courseId,
                    onCourseUpdated: () {},
                  ),
            ),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
            ),
          ],
        ),
        child: Row(
          children: [
            // Colored container with app icon - using dynamic course color
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: courseColor, // Using dynamic course color
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Center(
                child: Image(
                  image: AssetImage('assets/icon/app_icon.png'),
                  width: 50,
                  height: 50,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tutorName,
                    style: const TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    courseName,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(
                          color: Colors.blue, fontWeight: FontWeight.bold),
                      children: [
                        TextSpan(text: "Rs $price ",
                            style: const TextStyle(fontSize: 14)),

                        TextSpan(
                          text: category,
                          style: TextStyle(color: Colors.grey,
                              fontSize: 12,
                              fontWeight: FontWeight.normal),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      Text(" ${rating.toStringAsFixed(1)}  |  ",
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(
                        mode,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueGrey[900],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}