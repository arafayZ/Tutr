import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/course_service.dart';
import '../services/favorite_refresh_service.dart';
import 'course_details_screen.dart';
import '../config/api_config.dart';

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

class FavouritesScreen extends StatefulWidget {
  const FavouritesScreen({super.key});

  @override
  State<FavouritesScreen> createState() => _FavouritesScreenState();
}

class _FavouritesScreenState extends State<FavouritesScreen> with WidgetsBindingObserver {
  List<Map<String, dynamic>> _favourites = [];
  bool _isLoading = true;
  int _studentId = 0;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadStudentId();

    // Listen for refresh events from other screens
    FavoriteRefreshService().onRefreshFavorites.listen((_) {
      if (mounted) {
        _refreshData();
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // Refresh when app comes back to foreground
    if (state == AppLifecycleState.resumed) {
      _refreshData();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh when screen becomes visible (returns from other screens)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isLoading && !_isRefreshing && mounted) {
        _refreshData();
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _loadStudentId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _studentId = prefs.getInt('profileId') ?? 0;
      });
    }
    await _loadFavourites();
  }

  Future<void> _loadFavourites() async {
    if (!mounted) return;

    setState(() => _isLoading = true);

    try {
      final response = await CourseService.getFavorites(_studentId);

      if (!mounted) return;

      final List<Map<String, dynamic>> transformedFavourites = _transformApiResponse(response);

      setState(() {
        _favourites = transformedFavourites;
        _isLoading = false;
        _isRefreshing = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _isRefreshing = false;
      });
      _showErrorDialog(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  List<Map<String, dynamic>> _transformApiResponse(List<dynamic> favorites) {
    return favorites.map((favorite) {
      // Parse price
      String priceText = '';
      double priceValue = 0.0;
      if (favorite['price'] != null) {
        if (favorite['price'] is int) {
          priceValue = (favorite['price'] as int).toDouble();
        } else if (favorite['price'] is double) {
          priceValue = favorite['price'] as double;
        } else if (favorite['price'] is String) {
          priceValue = double.tryParse(favorite['price']) ?? 0.0;
        }
        priceText = '${priceValue.toStringAsFixed(0)} PKR';
      }

      // Parse rating
      String ratingText = '0.0';
      double ratingValue = 0.0;
      if (favorite['averageRating'] != null) {
        if (favorite['averageRating'] is int) {
          ratingValue = (favorite['averageRating'] as int).toDouble();
        } else if (favorite['averageRating'] is double) {
          ratingValue = favorite['averageRating'] as double;
        } else if (favorite['averageRating'] is String) {
          ratingValue = double.tryParse(favorite['averageRating']) ?? 0.0;
        }
        ratingText = ratingValue.toStringAsFixed(1);
      }

      // Get category display name
      String category = favorite['category']?.toString() ?? '';
      String categoryDisplay = _getCategoryDisplayName(category);

      // Get teaching mode display text
      String teachingModeText = 'Online';
      String teachingMode = favorite['teachingMode']?.toString() ?? '';
      if (teachingMode == 'ONLINE') {
        teachingModeText = 'Online';
      } else if (teachingMode == 'STUDENT_HOME') {
        teachingModeText = "Student's Home";
      } else if (teachingMode == 'TUTOR_HOME') {
        teachingModeText = "Tutor's Home";
      } else if (teachingMode == 'TUTOR_PLACE') {
        teachingModeText = "Tutor's Place";
      }

      // Get tutor location from API
      String tutorLocation = favorite['location']?.toString() ?? '';

      // Get course ID for color
      int courseId = favorite['courseId'] ?? favorite['id'] ?? 0;

      // Get original price value
      double originalPrice = favorite['price'] is double ? favorite['price'] : priceValue;

      return {
        'name': favorite['tutorName']?.toString() ?? 'Unknown Tutor',
        'subject': favorite['subject']?.toString() ?? favorite['courseName']?.toString() ?? 'General',
        'price': priceText,
        'priceValue': priceValue,
        'level': categoryDisplay,
        'rating': ratingText,
        'mode': teachingModeText,
        'tutorLocation': tutorLocation,
        'color': CourseColors.getCourseColor(courseId),
        'courseId': courseId,
        'tutorId': favorite['tutorId'] ?? 0,
        'profilePictureUrl': favorite['tutorImage']?.toString(),
        'categoryType': category,
        'originalPrice': originalPrice,
      };
    }).toList();
  }

  String _getCategoryDisplayName(String category) {
    switch (category.toUpperCase()) {
      case 'MATRIC':
        return 'Matric';
      case 'INTERMEDIATE':
        return 'Intermediate';
      case 'O_LEVEL':
        return 'O Level';
      case 'A_LEVEL':
        return 'A Level';
      case 'ENTRY_TEST':
        return 'Entrance Test';
      default:
        return category;
    }
  }

  (Color bgColor, Color textColor) _getCategoryBadgeColors(String category) {
    switch (category.toUpperCase()) {
      case 'MATRIC':
        return (Colors.orange.shade100, Colors.orange.shade800);
      case 'INTERMEDIATE':
        return (Colors.teal.shade100, Colors.teal.shade800);
      case 'O_LEVEL':
        return (Colors.blue.shade100, Colors.blue.shade800);
      case 'A_LEVEL':
        return (Colors.green.shade100, Colors.green.shade800);
      case 'ENTRY_TEST':
        return (Colors.purple.shade100, Colors.purple.shade800);
      default:
        return (Colors.grey.shade100, Colors.grey.shade800);
    }
  }

  void _navigateToCourseDetail(Map<String, dynamic> favourite) {
    final Map<String, dynamic> courseData = {
      'id': favourite['courseId'],
      'courseId': favourite['courseId'],
      'tutorName': favourite['name'],
      'name': favourite['name'],
      'sub': favourite['subject'],
      'title': favourite['subject'],
      'category': favourite['level'],
      'price': favourite['price'],
      'rating': favourite['rating'],
      'totalRatings': '28',
      'location': favourite['tutorLocation'],
      'teachingMode': favourite['mode'],
      'about': 'Master ${favourite['subject']} concepts with step-by-step guidance!',
      'classesPerMonth': 20,
      'startTime': '6:00 PM',
      'endTime': '8:00 PM',
      'fromDay': 'Monday',
      'toDay': 'Friday',
      'isFavorited': true,
      'tutorImage': favourite['profilePictureUrl'],
      'priceValue': favourite['priceValue'],
    };

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CourseDetailsScreen(courseData: courseData),
      ),
    );
  }

  Future<void> _removeFromFavourites(int index, String name, int courseId) async {
    try {
      await CourseService.removeFromFavorites(_studentId, courseId);

      if (mounted) {
        setState(() {
          _favourites.removeAt(index);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$name removed from favourites'),
            backgroundColor: Colors.grey,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );

        // Notify other screens to refresh their favorite status
        FavoriteRefreshService().notifyRefresh();
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog(e.toString().replaceFirst('Exception: ', ''));
      }
    }
  }

  void _showErrorDialog(String message) {
    if (!mounted) return;
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

  Future<void> _refreshData() async {
    if (_isRefreshing) return;
    setState(() => _isRefreshing = true);
    await _loadFavourites();
  }

  // Public method to refresh data (called from dashboard)
  Future<void> refreshData() async {
    await _refreshData();
  }

  @override
  Widget build(BuildContext context) {
    final double bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        color: Colors.black,
        backgroundColor: Colors.white,
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _isLoading
                  ? const Center(
                child: CircularProgressIndicator(color: Colors.black),
              )
                  : _favourites.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                physics: const BouncingScrollPhysics(),
                itemCount: _favourites.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () => _navigateToCourseDetail(_favourites[index]),
                    child: _buildFavouriteCard(_favourites[index], index),
                  );
                },
              ),
            ),
            SizedBox(height: bottomPadding > 0 ? bottomPadding : 30),
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
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.favorite_border,
              size: 50,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            "No Favourites Yet",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Tap the heart icon on course card\nto add them to favourites",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 25),
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
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: const Center(
        child: Text(
          "Favourites",
          style: TextStyle(
            color: Colors.black,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildFavouriteCard(Map<String, dynamic> data, int index) {
    final category = data['categoryType'] ?? '';
    final badgeColors = _getCategoryBadgeColors(category);

    return Container(
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
              color: data['color'],
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
                    data['name'][0].toUpperCase(),
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
                          data['name'],
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
                        onTap: () => _removeFromFavourites(index, data['name'], data['courseId']),
                        child: const Icon(
                          Icons.favorite,
                          color: Colors.red,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: badgeColors.$1,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      data['level'],
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: badgeColors.$2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    data['subject'],
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black54,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    data['price'],
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
                        data['rating'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Icon(
                        data['mode'] == 'Online'
                            ? Icons.wifi
                            : (data['mode'] == "Student's Home"
                            ? Icons.home
                            : Icons.location_city),
                        size: 10,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 2),
                      Flexible(
                        child: Text(
                          data['mode'],
                          style: const TextStyle(
                            fontSize: 9,
                            color: Colors.grey,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (data['tutorLocation'].toString().isNotEmpty) ...[
                        const SizedBox(width: 4),
                        const Icon(Icons.location_on, size: 10, color: Colors.grey),
                        const SizedBox(width: 2),
                        Flexible(
                          child: Text(
                            data['tutorLocation'],
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
    );
  }
}