import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import 'shared_widgets.dart';
import 'tutor_profile_screen.dart';
import 'course_details_screen.dart';
import '../services/course_service.dart';

// --- COURSE COLORS (Same as other screens) ---
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

// Category Badge Colors Helper
Map<String, Color> getCategoryBadgeColors(String category) {
  switch (category.toUpperCase()) {
    case 'MATRIC':
      return {'bg': Colors.orange.shade100, 'text': Colors.orange.shade800};
    case 'INTERMEDIATE':
      return {'bg': Colors.teal.shade100, 'text': Colors.teal.shade800};
    case 'O_LEVEL':
      return {'bg': Colors.blue.shade100, 'text': Colors.blue.shade800};
    case 'A_LEVEL':
      return {'bg': Colors.green.shade100, 'text': Colors.green.shade800};
    case 'ENTRY_TEST':
      return {'bg': Colors.purple.shade100, 'text': Colors.purple.shade800};
    default:
      return {'bg': Colors.grey.shade100, 'text': Colors.grey.shade800};
  }
}

// Teaching Mode Icon Helper
IconData getTeachingModeIcon(String mode) {
  switch (mode.toLowerCase()) {
    case 'online':
      return Icons.wifi;
    case 'student_home':
    case "student's home":
      return Icons.home;
    case 'tutor_home':
    case "tutor's home":
      return Icons.location_city;
    default:
      return Icons.school;
  }
}

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  bool isCourseSelected = true;
  String currentSearchQuery = "";

  List<String> activeCategories = [];
  List<String> activeModes = [];
  String activeBudget = "";
  String activeLocation = "";

  // API Data
  List<Map<String, dynamic>> allCourses = [];
  List<Map<String, dynamic>> allTutors = [];
  List<Map<String, dynamic>> filteredCourses = [];
  List<Map<String, dynamic>> filteredTutors = [];

  bool _isLoading = true;
  int _studentId = 0;
  String tutorSearchQuery = ""; // Separate search query for tutors

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
    await _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      await Future.wait([
        _loadCourses(),
        _loadTutors(),
      ]);
    } catch (e) {
      if (mounted) {
        _showErrorDialog(e.toString().replaceFirst('Exception: ', ''));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadCourses() async {
    try {
      final response = await CourseService.getAvailableCoursesForStudent(_studentId);

      if (!mounted) return;

      final transformedCourses = _transformCoursesResponse(response);
      setState(() {
        allCourses = transformedCourses;
        filteredCourses = List.from(transformedCourses);
      });
    } catch (e) {
      print('Error loading courses: $e');
      setState(() {
        allCourses = [];
        filteredCourses = [];
      });
    }
  }

  Future<void> _loadTutors() async {
    try {
      final response = await CourseService.getAllTutors(_studentId);

      if (!mounted) return;

      final transformedTutors = _transformTutorsResponse(response);
      setState(() {
        allTutors = transformedTutors;
        filteredTutors = List.from(transformedTutors);
      });
    } catch (e) {
      print('Error loading tutors: $e');
      setState(() {
        allTutors = [];
        filteredTutors = [];
      });
    }
  }

  List<Map<String, dynamic>> _transformCoursesResponse(List<dynamic> courses) {
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

      String courseLocation = course['location']?.toString() ?? '';

      return {
        'id': course['courseId'] ?? course['id'] ?? 0,
        'name': course['tutorName']?.toString() ?? 'Unknown Tutor',
        'sub': course['subject']?.toString() ?? course['courseName']?.toString() ?? 'General',
        'price': '${priceValue.toStringAsFixed(0)} PKR',
        'priceValue': priceValue,
        'rating': ratingValue.toStringAsFixed(1),
        'ratingValue': ratingValue,
        'location': courseLocation,
        'teachingMode': teachingModeText,
        'category': course['category']?.toString() ?? '',
        'fav': course['isFavorited'] == true,
        'tutorId': course['tutorId'] ?? 0,
        'tutorImage': course['tutorImage']?.toString(),
      };
    }).toList();
  }

  List<Map<String, dynamic>> _transformTutorsResponse(List<dynamic> tutors) {
    return tutors.map((tutor) {
      return {
        'id': tutor['tutorId'] ?? 0,
        'name': tutor['tutorName']?.toString() ?? 'Unknown Tutor',
        'sub': tutor['tutorHeadline']?.toString() ?? 'Tutor',
        'rating': tutor['averageRating']?.toString() ?? '0.0',
        'ratingValue': (tutor['averageRating'] as num?)?.toDouble() ?? 0.0,
        'location': tutor['tutorLocation']?.toString() ?? '',
        'image': tutor['tutorImage']?.toString(),
        'color': CourseColors.getCourseColor(tutor['tutorId'] ?? 0),
      };
    }).toList();
  }

  // Filter tutors by search query
  void _filterTutors(String query) {
    setState(() {
      tutorSearchQuery = query;
      if (query.isEmpty) {
        filteredTutors = List.from(allTutors);
      } else {
        filteredTutors = allTutors.where((tutor) {
          return tutor['name'].toLowerCase().contains(query.toLowerCase()) ||
              tutor['sub'].toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  List<Map<String, dynamic>> _getFilteredResults() {
    if (isCourseSelected) {
      return filteredCourses;
    } else {
      return filteredTutors;
    }
  }

  void _applyCourseFilters() {
    setState(() {
      filteredCourses = allCourses.where((course) {
        bool matchesSearch = currentSearchQuery.isEmpty ||
            course['name'].toLowerCase().contains(currentSearchQuery.toLowerCase()) ||
            course['sub'].toLowerCase().contains(currentSearchQuery.toLowerCase());

        bool matchesLocation = activeLocation.isEmpty ||
            course['location'].toLowerCase().contains(activeLocation.toLowerCase());

        bool matchesCategory = activeCategories.isEmpty ||
            activeCategories.any((cat) =>
            course['category'].toUpperCase().contains(cat.toUpperCase()) ||
                cat.toUpperCase().contains(course['category'].toUpperCase()));

        bool matchesBudget = activeBudget.isEmpty || _isPriceInRange(course['priceValue'], activeBudget);

        return matchesSearch && matchesLocation && matchesCategory && matchesBudget;
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
    } else if (budgetRange == "Under 1000") {
      return price < 1000;
    } else if (budgetRange == "1000-2000") {
      return price >= 1000 && price <= 2000;
    } else if (budgetRange == "2000-3000") {
      return price >= 2000 && price <= 3000;
    } else if (budgetRange == "3000-5000") {
      return price >= 3000 && price <= 5000;
    } else if (budgetRange == "Above 5000") {
      return price > 5000;
    }
    return true;
  }

  void _clearAllFilters() {
    setState(() {
      activeCategories = [];
      activeModes = [];
      activeBudget = "";
      activeLocation = "";
      currentSearchQuery = "";
      filteredCourses = List.from(allCourses);
    });
  }

  bool get _hasActiveFilters {
    return activeCategories.isNotEmpty ||
        activeModes.isNotEmpty ||
        activeBudget.isNotEmpty ||
        activeLocation.isNotEmpty ||
        currentSearchQuery.isNotEmpty;
  }

  void _toggleFavorite(int index) async {
    final item = filteredCourses[index];
    final int courseId = item['id'];
    final String itemName = item['name'];
    final bool isCurrentlyFav = item['fav'] == true;

    setState(() {
      filteredCourses[index]['fav'] = !isCurrentlyFav;
      final allIndex = allCourses.indexWhere((c) => c['id'] == courseId);
      if (allIndex != -1) {
        allCourses[allIndex]['fav'] = !isCurrentlyFav;
      }
    });

    try {
      if (!isCurrentlyFav) {
        await CourseService.addToFavorites(_studentId, courseId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$itemName added to favorites'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } else {
        await CourseService.removeFromFavorites(_studentId, courseId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$itemName removed from favorites'),
              backgroundColor: Colors.grey,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        filteredCourses[index]['fav'] = isCurrentlyFav;
        final allIndex = allCourses.indexWhere((c) => c['id'] == courseId);
        if (allIndex != -1) {
          allCourses[allIndex]['fav'] = isCurrentlyFav;
        }
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update favorites'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
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

  @override
  Widget build(BuildContext context) {
    final filteredList = _getFilteredResults();
    final hasNoResults = filteredList.isEmpty && !_isLoading;

    final showClearFilters = isCourseSelected && hasNoResults && _hasActiveFilters;

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      appBar: buildSharedAppBar(context, "Search"),
      body: Column(
        children: [
          if (isCourseSelected)
            buildSharedSearchBar(
              context: context,
              onSearch: (val) {
                setState(() {
                  currentSearchQuery = val;
                  _applyCourseFilters();
                });
              },
              activeCategories: activeCategories,
              activeModes: activeModes,
              activeBudget: activeBudget,
              activeLocation: activeLocation,
              onApplyFilters: (newCats, newModes, newBudget, newLocation) {
                setState(() {
                  activeCategories = newCats;
                  activeModes = newModes;
                  activeBudget = newBudget;
                  activeLocation = newLocation;
                  _applyCourseFilters();
                });
              },
              showCategories: true,
              showLocationFilter: true,
            )
          else
            _buildTutorSearchBar(),

          const SizedBox(height: 10),
          _buildToggleSwitch(),

          if (isCourseSelected && currentSearchQuery.trim().isNotEmpty && !showClearFilters && !_isLoading)
            _buildResultHeader(filteredList.length),

          Expanded(
            child: _isLoading
                ? const Center(
              child: CircularProgressIndicator(color: Colors.black),
            )
                : showClearFilters
                ? _buildNoResultsWithClearButton()
                : filteredList.isEmpty
                ? buildEmptyState()
                : _buildResultsList(filteredList),
          ),
        ],
      ),
    );
  }

  Widget _buildTutorSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 25, 20, 10),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, 8),
            )
          ],
        ),
        child: TextField(
          onChanged: (val) {
            _filterTutors(val);
          },
          decoration: InputDecoration(
            hintText: "Search tutor...",
            prefixIcon: const Icon(Icons.search, color: Colors.black54),
            suffixIcon: tutorSearchQuery.isNotEmpty
                ? IconButton(
              icon: const Icon(Icons.clear, color: Colors.grey),
              onPressed: () {
                _filterTutors('');
              },
            )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 20),
          ),
        ),
      ),
    );
  }

  Widget _buildNoResultsWithClearButton() {
    return Center(
      child: SingleChildScrollView(
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
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleSwitch() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Container(
        height: 55,
        decoration: BoxDecoration(
          color: const Color(0xFFF1F4F4),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          children: [
            _toggleButton("Courses", isCourseSelected, () {
              setState(() {
                isCourseSelected = true;
                _applyCourseFilters();
              });
            }),
            _toggleButton("Tutor", !isCourseSelected, () {
              setState(() {
                isCourseSelected = false;
              });
            }),
          ],
        ),
      ),
    );
  }

  Widget _toggleButton(String title, bool isActive, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: isActive ? Colors.black : Colors.transparent,
            borderRadius: BorderRadius.circular(25),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                color: isActive ? Colors.white : Colors.black54,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResultHeader(int count) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(25, 20, 25, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: RichText(
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                style: const TextStyle(color: Colors.black, fontSize: 14),
                children: [
                  const TextSpan(text: "Result for "),
                  TextSpan(
                    text: '"$currentSearchQuery"',
                    style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          Text(
            "$count FOUND",
            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsList(List<Map<String, dynamic>> results) {
    return SafeArea(
      top: false,
      child: ListView.builder(
        itemCount: results.length,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, i) {
          final item = results[i];
          return isCourseSelected
              ? _buildCourseCard(item, i)
              : _buildTutorListItem(item);
        },
      ),
    );
  }

  Widget _buildCourseCard(Map<String, dynamic> course, int index) {
    final int courseId = course['id'];
    final Color courseColor = CourseColors.getCourseColor(courseId);
    final badgeColors = getCategoryBadgeColors(course['category']);
    final teachingMode = course['teachingMode'] ?? 'Online';
    final teachingIcon = getTeachingModeIcon(teachingMode);
    final location = course['location'] ?? '';

    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CourseDetailsScreen(
              courseData: {
                ...course,
                "title": course['sub'],
                "tutorName": course['name'],
                "teachingMode": teachingMode,
                "about": "This is an excellent ${course['sub']} course taught by ${course['name']}. Perfect for students looking to excel in this subject.",
                "totalStudents": 45,
                "totalRatings": 28,
                "classesPerMonth": 8,
                "duration": "2 hours",
                "schedule": "Mon, Wed, Fri",
              },
            ),
          ),
        );
        if (result == true) {
          _loadData();
        }
      },
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
                color: courseColor,
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
                      course['name'][0].toUpperCase(),
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
                        Text(
                          course['name'],
                          style: const TextStyle(
                            color: Colors.orange,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => _toggleFavorite(index),
                          child: Icon(
                            (course['fav'] == true) ? Icons.favorite : Icons.favorite_border,
                            color: (course['fav'] == true) ? Colors.red : Colors.grey,
                            size: 18,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: badgeColors['bg'],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        course['category'],
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: badgeColors['text'],
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      course['sub'],
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      course['price'],
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.orange, size: 12),
                        const SizedBox(width: 2),
                        Text(
                          course['rating'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Icon(
                          teachingIcon,
                          size: 10,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 2),
                        Flexible(
                          child: Text(
                            teachingMode,
                            style: const TextStyle(
                              fontSize: 9,
                              color: Colors.grey,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (location.isNotEmpty) ...[
                          const SizedBox(width: 6),
                          Icon(
                            Icons.location_on,
                            size: 10,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 2),
                          Flexible(
                            child: Text(
                              location,
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
  }

  Widget _buildTutorListItem(Map<String, dynamic> tutor) {
    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(vertical: 8),
          leading: CircleAvatar(
            radius: 30,
            backgroundColor: tutor['color'] ?? Colors.black,
            backgroundImage: tutor['image'] != null && tutor['image'].toString().isNotEmpty
                ? NetworkImage('${ApiConfig.baseUrl}${tutor['image']}')
                : null,
            child: tutor['image'] == null || tutor['image'].toString().isEmpty
                ? const Icon(Icons.person, color: Colors.white)
                : null,
          ),
          title: Text(
            tutor['name'],
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.black,
            ),
          ),
          subtitle: Text(
            tutor['sub'],
            style: const TextStyle(color: Colors.grey, fontSize: 13),
          ),
          trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.black),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TutorProfileScreen(tutorData: tutor),
              ),
            );
          },
        ),
        const Divider(height: 1, color: Color(0xFFF1F4F4)),
      ],
    );
  }
}