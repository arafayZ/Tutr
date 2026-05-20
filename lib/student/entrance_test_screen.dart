import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'shared_widgets.dart';
import '../services/course_service.dart';
import 'course_details_screen.dart'; // Add this import

// --- COURSE COLORS (Same as tutor dashboard) ---
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

class EntranceTestScreen extends StatefulWidget {
  const EntranceTestScreen({super.key});

  @override
  State<EntranceTestScreen> createState() => _EntranceTestScreenState();
}

class _EntranceTestScreenState extends State<EntranceTestScreen> {
  List<Map<String, dynamic>> allTutors = [];
  List<Map<String, dynamic>> filteredTutors = [];
  String currentSearchQuery = "";
  List<String> activeModes = [];
  String activeBudget = "";
  String activeLocation = "";
  bool _isLoading = true;
  int _studentId = 0;

  static const String _category = "ENTRY_TEST";

  @override
  void initState() {
    super.initState();
    _loadStudentId();
  }

  Future<void> _loadStudentId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _studentId = prefs.getInt('profileId') ?? 0;
    });
    await _loadTutors();
  }

  Future<void> _loadTutors() async {
    setState(() => _isLoading = true);

    try {
      Map<String, String> params = {
        'category': _category,
        'studentId': _studentId.toString(),
      };

      final response = await CourseService.searchCourses(params);

      final List<Map<String, dynamic>> transformedTutors = _transformApiResponse(response);

      setState(() {
        allTutors = transformedTutors;
        _applyFilters();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorDialog(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  List<Map<String, dynamic>> _transformApiResponse(List<dynamic> courses) {
    return courses.map((course) {
      double priceValue = 0.0;
      if (course['price'] is int) {
        priceValue = (course['price'] as int).toDouble();
      } else if (course['price'] is double) {
        priceValue = course['price'] as double;
      } else if (course['price'] is String) {
        priceValue = double.tryParse(course['price']) ?? 0.0;
      }

      double ratingValue = 0.0;
      if (course['averageRating'] is int) {
        ratingValue = (course['averageRating'] as int).toDouble();
      } else if (course['averageRating'] is double) {
        ratingValue = course['averageRating'] as double;
      } else if (course['averageRating'] is String) {
        ratingValue = double.tryParse(course['averageRating']) ?? 0.0;
      }

      String teachingModeText = 'Online';
      String teachingMode = course['teachingMode']?.toString() ?? '';
      if (teachingMode == 'ONLINE') {
        teachingModeText = 'Online';
      } else if (teachingMode == 'STUDENT_HOME') {
        teachingModeText = "Student's Home";
      } else if (teachingMode == 'TUTOR_HOME') {
        teachingModeText = "Tutor's Home";
      }

      String tutorLocation = course['location']?.toString() ?? '';
      String categoryDisplay = 'Entry Test';
      int courseId = course['courseId'] ?? course['id'] ?? 0;

      return {
        'name': course['tutorName']?.toString() ?? 'Unknown Tutor',
        'subject': course['subject']?.toString() ?? course['courseName']?.toString() ?? 'General',
        'priceValue': priceValue,
        'priceText': '${priceValue.toStringAsFixed(0)} PKR',
        'rating': ratingValue.toStringAsFixed(1),
        'averageRating': ratingValue,
        'teachingMode': teachingModeText,
        'rawTeachingMode': course['teachingMode']?.toString() ?? 'ONLINE',
        'tutorLocation': tutorLocation,
        'location': tutorLocation,
        'category': categoryDisplay,
        'color': CourseColors.getCourseColor(courseId),
        'fav': course['isFavorited'] == true,
        'courseId': courseId,
        'tutorId': course['tutorId'] ?? 0,
        'profilePictureUrl': course['tutorImage']?.toString(),
        'about': course['about']?.toString() ?? 'Master concepts with step-by-step guidance! Learn clearly and gain confidence for exams.',
        'classesPerMonth': course['classesPerMonth'] ?? 20,
        'startTime': course['startTime'] ?? '6:00 PM',
        'endTime': course['endTime'] ?? '8:00 PM',
        'fromDay': course['fromDay'] ?? 'Monday',
        'toDay': course['toDay'] ?? 'Friday',
        'totalRatings': course['totalRatings'] ?? 0,
        'tutorName': course['tutorName']?.toString() ?? 'Unknown Tutor',
      };
    }).toList();
  }

  void _applyFilters() {
    setState(() {
      filteredTutors = allTutors.where((tutor) {
        // Search filter
        bool matchesSearch = currentSearchQuery.isEmpty ||
            tutor['name'].toLowerCase().contains(currentSearchQuery.toLowerCase()) ||
            tutor['subject'].toLowerCase().contains(currentSearchQuery.toLowerCase());

        // Teaching mode filter
        bool matchesMode = activeModes.isEmpty;
        if (!matchesMode) {
          for (String mode in activeModes) {
            if (tutor['teachingMode'] == mode) {
              matchesMode = true;
              break;
            }
          }
        }

        bool matchesBudget = activeBudget.isEmpty || _isPriceInRange(tutor['priceValue'], activeBudget);

        // Location filter
        bool matchesLocation = activeLocation.isEmpty ||
            tutor['tutorLocation'].toLowerCase().contains(activeLocation.toLowerCase());

        return matchesSearch && matchesMode && matchesBudget && matchesLocation;
      }).toList();
    });
  }

  bool _isPriceInRange(double price, String budgetRange) {
    if (budgetRange.contains('-')) {
      final parts = budgetRange.split('-');
      if (parts.length == 2) {
        final min = int.tryParse(parts[0]) ?? 0;
        final max = int.tryParse(parts[1]) ?? 0;
        return price >= min && price <= max;
      }
    } else if (budgetRange == "Under 1,000 PKR") {
      return price < 1000;
    } else if (budgetRange == "Above 5,000 PKR") {
      return price > 5000;
    }
    return true;
  }

  void _toggleFavorite(int index) async {
    final tutor = filteredTutors[index];
    final int courseId = tutor['courseId'];
    final String tutorName = tutor['name'];
    final bool isCurrentlyFav = tutor['fav'];

    setState(() {
      filteredTutors[index]['fav'] = !isCurrentlyFav;
      final allIndex = allTutors.indexWhere((t) => t['courseId'] == courseId);
      if (allIndex != -1) {
        allTutors[allIndex]['fav'] = !isCurrentlyFav;
      }
    });

    try {
      if (!isCurrentlyFav) {
        await CourseService.addToFavorites(_studentId, courseId);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$tutorName added to favorites'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        await CourseService.removeFromFavorites(_studentId, courseId);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$tutorName removed from favorites'),
            backgroundColor: Colors.grey,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      setState(() {
        filteredTutors[index]['fav'] = isCurrentlyFav;
        final allIndex = allTutors.indexWhere((t) => t['courseId'] == courseId);
        if (allIndex != -1) {
          allTutors[allIndex]['fav'] = isCurrentlyFav;
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update favorites'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _navigateToCourseDetail(Map<String, dynamic> course) {
    // Prepare course data for CourseDetailsScreen
    final Map<String, dynamic> courseData = {
      'id': course['courseId'],
      'courseId': course['courseId'],
      'tutorName': course['name'],
      'name': course['name'],
      'sub': course['subject'],
      'title': course['subject'],
      'category': course['category'],
      'price': course['priceText'],
      'rating': course['averageRating'].toString(),
      'totalRatings': course['totalRatings'].toString(),
      'location': course['location'],
      'teachingMode': course['rawTeachingMode'],
      'about': course['about'],
      'classesPerMonth': course['classesPerMonth'],
      'startTime': course['startTime'],
      'endTime': course['endTime'],
      'fromDay': course['fromDay'],
      'toDay': course['toDay'],
      'isFavorited': course['fav'],
      'tutorImage': course['profilePictureUrl'],
    };

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CourseDetailsScreen(courseData: courseData),
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        content: Text(message, textAlign: TextAlign.center),
        actions: [
          Center(
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  void _clearAllFilters() {
    setState(() {
      activeModes = [];
      activeBudget = '';
      activeLocation = '';
      currentSearchQuery = '';
    });
    _applyFilters();
  }

  @override
  Widget build(BuildContext context) {
    final hasActiveFilters = activeModes.isNotEmpty || activeBudget.isNotEmpty || activeLocation.isNotEmpty || currentSearchQuery.isNotEmpty;
    final hasNoCourses = !_isLoading && allTutors.isEmpty;
    final hasNoResults = !_isLoading && filteredTutors.isEmpty && !hasNoCourses;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: buildSharedAppBar(context, "Entrance Test"),
      body: Column(
        children: [
          buildSharedSearchBar(
            context: context,
            onSearch: (val) {
              currentSearchQuery = val;
              _applyFilters();
            },
            activeCategories: const [],
            activeModes: activeModes,
            activeBudget: activeBudget,
            activeLocation: activeLocation,
            onApplyFilters: (newCats, newModes, newBudget, newLocation) {
              setState(() {
                activeModes = List.from(newModes);

                activeBudget = newBudget;

                activeLocation = newLocation;

                _applyFilters();
              });
            },
            showCategories: false,
            showLocationFilter: true,
          ),
          Expanded(
            child: _isLoading
                ? const Center(
              child: CircularProgressIndicator(color: Colors.black),
            )
                : hasNoCourses
                ? _buildNoCoursesState()
                : hasNoResults
                ? _buildNoResultsState(hasActiveFilters)
                : _buildTutorList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTutorList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      physics: const BouncingScrollPhysics(),
      itemCount: filteredTutors.length,
      itemBuilder: (context, index) {
        final tutor = filteredTutors[index];

        return GestureDetector(
          onTap: () => _navigateToCourseDetail(tutor),
          child: Container(
            margin: const EdgeInsets.only(bottom: 15),
            height: 130,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 85,
                  decoration: BoxDecoration(
                    color: tutor['color'],
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(15),
                      bottomLeft: Radius.circular(15),
                    ),
                  ),
                  child: Center(
                    child: Image.asset(
                      'assets/icon/app_icon.png',
                      height: 45,
                      width: 45,
                      color: Colors.white,
                      errorBuilder: (context, error, stackTrace) {
                        return Text(
                          tutor['name'][0].toUpperCase(),
                          style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                tutor['name'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: Colors.black87,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => _toggleFavorite(index),
                              child: Icon(
                                tutor['fav'] == true ? Icons.favorite : Icons.favorite_border,
                                color: tutor['fav'] == true ? Colors.red : Colors.grey,
                                size: 20,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.purple.shade100,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            tutor['category'],
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.purple.shade800,
                            ),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          tutor['subject'],
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.black54,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          tutor['priceText'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            const Icon(Icons.star, color: Colors.orange, size: 12),
                            const SizedBox(width: 2),
                            Text(
                              tutor['rating'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Icon(
                              tutor['teachingMode'] == 'Online'
                                  ? Icons.wifi
                                  : (tutor['teachingMode'] == "Student's Home"
                                  ? Icons.home
                                  : Icons.location_city),
                              size: 10,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 2),
                            Flexible(
                              child: Text(
                                tutor['teachingMode'],
                                style: const TextStyle(
                                  fontSize: 9,
                                  color: Colors.grey,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (tutor['tutorLocation'].toString().isNotEmpty) ...[
                              const SizedBox(width: 4),
                              const Icon(Icons.location_on, size: 10, color: Colors.grey),
                              const SizedBox(width: 2),
                              Flexible(
                                child: Text(
                                  tutor['tutorLocation'],
                                  style: const TextStyle(
                                    fontSize: 9,
                                    color: Colors.grey,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNoCoursesState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.school_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No Courses Found',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'No tutors available for Entrance Test category yet',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResultsState(bool hasActiveFilters) {
    if (!hasActiveFilters) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No tutors found',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your search',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.filter_alt_off,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No results found',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your filters',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _clearAllFilters,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('Clear Filters'),
          ),
        ],
      ),
    );
  }
}