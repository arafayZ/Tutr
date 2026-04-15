import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/custom_bottom_nav.dart';
import '../widgets/custom_tab_header.dart';
import 'add_course_screen.dart';
import 'review_details_screen.dart';
import '../services/rating_service.dart';
import '../utils/status_bar_config.dart';
import '../config/api_config.dart';

class ReviewsScreen extends StatefulWidget {
  const ReviewsScreen({super.key});

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> with WidgetsBindingObserver {
  List<Map<String, dynamic>> _reviews = [];
  List<Map<String, dynamic>> _allReviews = [];
  Map<String, dynamic>? _ratingSummary;
  Map<String, bool> _selectedCategories = {};
  Map<String, bool> _selectedModes = {};
  bool _isLoading = true;
  double _averageRating = 0.0;
  int _totalRatings = 0;
  String _tutorName = "";
  int _tutorProfileId = 0;

  final List<String> _allCategories = [
    "Matric",
    "Intermediate",
    "O Level",
    "A Level",
    "Entrance Test"
  ];

  final List<String> _allModes = [
    "Online",
    "Student Home",
    "Tutor Home"
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    StatusBarConfig.setLightStatusBar();
    _loadData();
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

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      _tutorProfileId = prefs.getInt('profileId') ?? 0;

      _selectedCategories = {for (var cat in _allCategories) cat: false};
      _selectedModes = {for (var mode in _allModes) mode: false};

      await _loadRatingSummary();

      setState(() => _isLoading = false);

    } catch (e) {
      print('Error loading data: $e');
      setState(() => _isLoading = false);
      _showErrorDialog("Failed to load data: ${e.toString().replaceFirst('Exception: ', '')}");
    }
  }

  Future<void> _loadRatingSummary({String? category, String? teachingMode}) async {
    try {
      final summary = await RatingService.getTutorRatingSummaryWithFilters(
        _tutorProfileId,
        category: category,
        teachingMode: teachingMode,
      );

      if (mounted) {
        setState(() {
          _ratingSummary = summary;
          _averageRating = (summary['averageRating'] ?? 0.0).toDouble();
          _totalRatings = summary['totalRatings'] ?? 0;
          _tutorName = summary['tutorName'] ?? 'Tutor';

          final reviewsList = summary['reviews'] as List? ?? [];

          final mappedReviews = reviewsList.map((review) {
            String categoryDisplay = _mapBackendCategoryToDisplay(review['category']);
            String modeDisplay = _mapBackendModeToDisplay(review['teachingMode']);

            return {
              'reviewId': review['reviewId'],
              'studentName': review['studentName'] ?? 'Unknown',
              'studentImage': review['studentImage'],
              'rating': review['rating'] ?? 0,
              'review': review['review'] ?? '',
              'category': categoryDisplay,
              'teachingMode': modeDisplay,
              'courseSubject': review['courseSubject'] ?? 'Course',
              'createdAt': review['createdAt'],
            };
          }).toList();

          _allReviews = mappedReviews;
          _reviews = List.from(_allReviews);
        });
      }
    } catch (e) {
      print('Error loading rating summary: $e');
      if (mounted) {
        setState(() {
          _allReviews = [];
          _reviews = [];
          _averageRating = 0.0;
          _totalRatings = 0;
        });
      }
    }
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

  void _showFilterOptions() async {
    final result = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterBottomSheet(
        categories: _selectedCategories,
        modes: _selectedModes,
      ),
    );

    if (result != null) {
      setState(() {
        _selectedCategories = result['categories'];
        _selectedModes = result['modes'];
      });
      await _applyFilters();
    }
  }

  Future<void> _applyFilters() async {
    setState(() => _isLoading = true);

    final selectedCats = _selectedCategories.entries.where((e) => e.value).map((e) => e.key).toList();
    final selectedModesList = _selectedModes.entries.where((e) => e.value).map((e) => e.key).toList();

    try {
      if (selectedCats.isEmpty && selectedModesList.isEmpty) {
        await _loadRatingSummary();
      }
      else {
        List<Map<String, dynamic>> combinedReviews = [];

        if (selectedCats.isNotEmpty) {
          for (var cat in selectedCats) {
            final categoryBackend = _mapDisplayCategoryToBackend(cat);
            final summary = await RatingService.getTutorRatingSummaryWithFilters(
              _tutorProfileId,
              category: categoryBackend,
            );
            final reviewsList = summary['reviews'] as List? ?? [];
            for (var review in reviewsList) {
              combinedReviews.add(Map<String, dynamic>.from(review));
            }
          }
        }

        if (selectedModesList.isNotEmpty) {
          for (var mode in selectedModesList) {
            final modeBackend = _mapDisplayModeToBackend(mode);
            final summary = await RatingService.getTutorRatingSummaryWithFilters(
              _tutorProfileId,
              teachingMode: modeBackend,
            );
            final reviewsList = summary['reviews'] as List? ?? [];
            for (var review in reviewsList) {
              combinedReviews.add(Map<String, dynamic>.from(review));
            }
          }
        }

        final uniqueReviews = <int, Map<String, dynamic>>{};
        for (var review in combinedReviews) {
          uniqueReviews[review['reviewId']] = review;
        }

        final mappedReviews = uniqueReviews.values.map((review) {
          String categoryDisplay = _mapBackendCategoryToDisplay(review['category']);
          String modeDisplay = _mapBackendModeToDisplay(review['teachingMode']);

          return {
            'reviewId': review['reviewId'],
            'studentName': review['studentName'] ?? 'Unknown',
            'studentImage': review['studentImage'],
            'rating': review['rating'] ?? 0,
            'review': review['review'] ?? '',
            'category': categoryDisplay,
            'teachingMode': modeDisplay,
            'courseSubject': review['courseSubject'] ?? 'Course',
            'createdAt': review['createdAt'],
          };
        }).toList();

        Map<int, int> distribution = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
        double sum = 0;

        for (var review in mappedReviews) {
          int rating = review['rating'];
          distribution[rating] = (distribution[rating] ?? 0) + 1;
          sum += rating;
        }

        final averageRating = mappedReviews.isNotEmpty ? sum / mappedReviews.length : 0.0;
        final totalRatings = mappedReviews.length;

        if (mounted) {
          setState(() {
            _reviews = mappedReviews;
            _averageRating = averageRating;
            _totalRatings = totalRatings;
            _ratingSummary = {
              'averageRating': averageRating,
              'totalRatings': totalRatings,
              'ratingDistribution': {
                "1": distribution[1],
                "2": distribution[2],
                "3": distribution[3],
                "4": distribution[4],
                "5": distribution[5],
              },
              'reviews': mappedReviews,
              'tutorName': _tutorName,
            };
          });
        }
      }
    } catch (e) {
      print('Error applying filters: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _clearFilters() async {
    setState(() {
      _selectedCategories.updateAll((k, v) => false);
      _selectedModes.updateAll((k, v) => false);
      _isLoading = true;
    });
    await _loadRatingSummary();
    if (mounted) {
      setState(() => _isLoading = false);
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
            child: const Text("OK", style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  Future<void> _refreshData() async {
    setState(() => _isLoading = true);
    if (_selectedCategories.values.contains(true) || _selectedModes.values.contains(true)) {
      await _applyFilters();
    } else {
      await _loadRatingSummary();
    }
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasFilterSelected = _selectedCategories.values.contains(true) || _selectedModes.values.contains(true);
    final hasNoResults = !_isLoading && _reviews.isEmpty && hasFilterSelected;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      extendBody: true,
      body: RefreshIndicator(
        onRefresh: _refreshData,
        color: Colors.black,
        child: Column(
          children: [
            // Increased vertical length with padding (keeping text size 20)
            Container(
              padding: const EdgeInsets.only(top: 16, bottom: 8),
              child: const CustomTabHeader(
                title: Text("Reviews & Ratings", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : hasNoResults
                  ? _buildNoResultsMessage()
                  : ListView.builder(
                padding: const EdgeInsets.fromLTRB(0, 10, 0, 150),
                physics: const BouncingScrollPhysics(),
                itemCount: _reviews.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) return _buildRatingSummary();
                  final review = _reviews[index - 1];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: _ReviewBox(
                      reviewId: review['reviewId'],
                      studentName: review['studentName'],
                      rating: review['rating'].toString(),
                      review: review['review'],
                      studentImage: review['studentImage'],
                      courseName: review['courseSubject'],
                      createdAt: review['createdAt'],
                      onBoxTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ReviewDetailsScreen(
                              reviewId: review['reviewId'],
                              studentName: review['studentName'],
                              rating: review['rating'].toString(),
                              review: review['review'],
                              profilePic: review['studentImage'],
                              courseId: null,
                              courseName: review['courseSubject'],
                              tutorName: _tutorName,
                              createdAt: review['createdAt'],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AddCourseScreen())),
        backgroundColor: Colors.black,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 32),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: const SafeArea(child: CustomBottomNav(currentIndex: -1)),
    );
  }

  Widget _buildNoResultsMessage() {
    String filterMessage = "";
    final selectedCats = _selectedCategories.entries.where((e) => e.value).map((e) => e.key).toList();
    final selectedModesList = _selectedModes.entries.where((e) => e.value).map((e) => e.key).toList();

    if (selectedCats.isNotEmpty) {
      filterMessage = "Category: ${selectedCats.join(', ')}";
    }
    if (selectedModesList.isNotEmpty) {
      if (filterMessage.isNotEmpty) filterMessage += " • ";
      filterMessage += "Mode: ${selectedModesList.join(', ')}";
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.rate_review_outlined, size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            const Text(
              "No Reviews Found",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            if (filterMessage.isNotEmpty)
              Text(
                filterMessage,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade400,
                ),
                textAlign: TextAlign.center,
              ),
            const SizedBox(height: 8),
            const Text(
              "Try changing your filter selections",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _clearFilters,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("Clear Filters", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingSummary() {
    if (_totalRatings == 0 && !_isLoading) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: _showFilterOptions,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 15),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.black.withOpacity(0.5)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.tune, size: 22),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(40),
              child: Column(
                children: [
                  Icon(Icons.star_border, size: 60, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    "No ratings yet",
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade400),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Be the first to rate this tutor",
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade400),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    final distribution = _ratingSummary?['ratingDistribution'] ?? {};

    int count5 = (distribution["5"] ?? 0).toInt();
    int count4 = (distribution["4"] ?? 0).toInt();
    int count3 = (distribution["3"] ?? 0).toInt();
    int count2 = (distribution["2"] ?? 0).toInt();
    int count1 = (distribution["1"] ?? 0).toInt();

    double percent5 = _totalRatings > 0 ? count5 / _totalRatings : 0;
    double percent4 = _totalRatings > 0 ? count4 / _totalRatings : 0;
    double percent3 = _totalRatings > 0 ? count3 / _totalRatings : 0;
    double percent2 = _totalRatings > 0 ? count2 / _totalRatings : 0;
    double percent1 = _totalRatings > 0 ? count1 / _totalRatings : 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: _showFilterOptions,
              child: Container(
                margin: const EdgeInsets.only(bottom: 15),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.black.withOpacity(0.5)),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.tune, size: 22),
              ),
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Text(
                    _averageRating.toStringAsFixed(1),
                    style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, height: 1.1),
                  ),
                  Text(
                    "$_totalRatings Ratings",
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  children: [
                    _buildStaggeredRow(5, percent5, count5.toString()),
                    _buildStaggeredRow(4, percent4, count4.toString()),
                    _buildStaggeredRow(3, percent3, count3.toString()),
                    _buildStaggeredRow(2, percent2, count2.toString()),
                    _buildStaggeredRow(1, percent1, count1.toString()),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStaggeredRow(int starCount, double progress, String count) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: List.generate(5, (index) {
                return Icon(
                  Icons.star,
                  size: 14,
                  color: (index >= (5 - starCount)) ? Colors.orange : Colors.transparent,
                );
              }),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: progress.isNaN ? 0 : progress.clamp(0.0, 1.0),
                backgroundColor: Colors.grey[200],
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.red),
                minHeight: 5,
              ),
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 30,
            child: Text(
              count,
              style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewBox extends StatelessWidget {
  final int reviewId;
  final String studentName;
  final String rating;
  final String review;
  final String? studentImage;
  final String courseName;
  final String? createdAt;
  final VoidCallback? onBoxTap;

  const _ReviewBox({
    required this.reviewId,
    required this.studentName,
    required this.rating,
    required this.review,
    this.studentImage,
    required this.courseName,
    this.createdAt,
    this.onBoxTap,
  });

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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onBoxTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: Colors.grey.shade300,
                  backgroundImage: studentImage != null && studentImage!.isNotEmpty
                      ? NetworkImage('${ApiConfig.baseUrl}$studentImage')
                      : null,
                  child: studentImage == null || studentImage!.isEmpty
                      ? const Icon(Icons.person, color: Colors.grey, size: 20)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    studentName,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEDF2FF),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF0961F5).withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.star, color: Colors.orange, size: 14),
                      const SizedBox(width: 4),
                      Text(rating, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              courseName,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            Text(
              review,
              style: const TextStyle(fontSize: 13, color: Colors.black87, height: 1.5),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 15),
            Text(
              _formatDate(createdAt),
              style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class FilterBottomSheet extends StatefulWidget {
  final Map<String, bool> categories;
  final Map<String, bool> modes;

  const FilterBottomSheet({
    super.key,
    required this.categories,
    required this.modes,
  });

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late Map<String, bool> _categories;
  late Map<String, bool> _modes;

  @override
  void initState() {
    super.initState();
    _categories = Map.from(widget.categories);
    _modes = Map.from(widget.modes);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CircleAvatar(backgroundColor: Colors.black, child: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context))),
                const Text("Filter", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _categories.updateAll((k, v) => false);
                      _modes.updateAll((k, v) => false);
                    });
                  },
                  child: const Text("Clear", style: TextStyle(color: Colors.grey)),
                ),
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
                  ..._categories.keys.map((k) => _buildCheck(k, _categories[k]!, (v) => setState(() => _categories[k] = v!))),
                  const SizedBox(height: 30),
                  const Text("Teaching Mode:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 15),
                  ..._modes.keys.map((k) => _buildCheck(k, _modes[k]!, (v) => setState(() => _modes[k] = v!))),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(25),
              child: SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context, {
                      "categories": _categories,
                      "modes": _modes,
                    });
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.black, shape: const StadiumBorder()),
                  child: const Text("Apply", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildCheck(String t, bool v, Function(bool?) onChange) {
    return ListTile(
      onTap: () => onChange(!v),
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 24, height: 24,
        decoration: BoxDecoration(
          color: v ? Colors.black : const Color(0xFFE8F1FF),
          borderRadius: BorderRadius.circular(6),
        ),
        child: v ? const Icon(Icons.check, color: Colors.white, size: 16) : null,
      ),
      title: Text(t, style: const TextStyle(fontSize: 16)),
    );
  }
}