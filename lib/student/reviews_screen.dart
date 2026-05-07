import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'write_review_screen.dart';
import '../services/rating_service.dart';
import '../config/api_config.dart';

class ReviewsScreen extends StatefulWidget {
  final Map<String, dynamic> courseData;

  const ReviewsScreen({super.key, required this.courseData});

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  List<Map<String, dynamic>> _reviews = [];
  bool _isLoading = true;
  double _averageRating = 0.0;
  int _totalRatings = 0;
  int _courseId = 0;

  @override
  void initState() {
    super.initState();
    _courseId = widget.courseData['id'] ?? widget.courseData['courseId'] ?? 0;
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    setState(() => _isLoading = true);

    try {
      final response = await RatingService.getCourseReviews(_courseId);
      if (!mounted) return;
      _processReviews(response);
    } catch (e) {
      print('Error loading reviews: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _processReviews(List<Map<String, dynamic>> reviews) {
    double totalRating = 0.0;

    _reviews = reviews.map((review) {
      double rating = (review['rating'] as num?)?.toDouble() ?? 0.0;
      totalRating += rating;

      String formattedDate = _formatDate(review['createdAt']?.toString() ?? '');
      String? studentImage = review['studentImage']?.toString();
      if (studentImage != null && studentImage.isNotEmpty) {
        studentImage = '${ApiConfig.baseUrl}$studentImage';
      }

      return {
        'studentName': review['studentName']?.toString() ?? 'Anonymous',
        'studentImage': studentImage,
        'rating': rating,
        'comment': review['review']?.toString() ?? review['comment']?.toString() ?? '',
        'createdAt': formattedDate,
      };
    }).toList();

    _totalRatings = _reviews.length;
    if (_totalRatings > 0) {
      _averageRating = totalRating / _totalRatings;
    }
  }

  String _formatDate(String dateStr) {
    if (dateStr.isEmpty) return '';
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays > 365) {
        return '${(difference.inDays / 365).floor()} year${(difference.inDays / 365).floor() > 1 ? 's' : ''} ago';
      } else if (difference.inDays > 30) {
        return '${(difference.inDays / 30).floor()} month${(difference.inDays / 30).floor() > 1 ? 's' : ''} ago';
      } else if (difference.inDays > 0) {
        return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return '';
    }
  }

  Future<void> _refreshData() async {
    await _loadReviews();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        color: Colors.black,
        backgroundColor: Colors.white,
        child: Column(
          children: [
            _buildHeader(context),
            // Add spacing between header and rating card
            const SizedBox(height: 16),
            // Smaller Rating Summary Section
            _buildRatingSummary(),
            const SizedBox(height: 20),
            // Scrollable Reviews Section (with bottom padding for button)
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: Colors.black))
                  : SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 80),
                child: Column(
                  children: [
                    _buildReviewList(),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            // Fixed Write a Review Button at Bottom
            _buildWriteReviewButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(35),
          bottomRight: Radius.circular(35),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: Colors.black,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
              ),
            ),
          ),
          const Text(
            "Reviews & Ratings",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingSummary() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Rating Number
          Column(
            children: [
              Text(
                _averageRating.toStringAsFixed(1),
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black),
              ),
              const SizedBox(height: 4),
              Text(
                "out of 5",
                style: TextStyle(fontSize: 10, color: Colors.grey[500]),
              ),
            ],
          ),
          // Stars
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return Icon(
                    index < _averageRating.floor() ? Icons.star :
                    (index < _averageRating.ceil() && _averageRating - index > 0 ? Icons.star_half : Icons.star_border),
                    color: Colors.orange,
                    size: 18,
                  );
                }),
              ),
              const SizedBox(height: 4),
              Text(
                "$_totalRatings ${_totalRatings == 1 ? 'rating' : 'ratings'}",
                style: TextStyle(fontSize: 11, color: Colors.grey[600]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReviewList() {
    if (_reviews.isEmpty) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.rate_review_outlined, size: 50, color: Colors.grey),
              SizedBox(height: 12),
              Text(
                "No Reviews Yet",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey),
              ),
              SizedBox(height: 6),
              Text(
                "Be the first to write a review",
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: _reviews.map((review) => _buildReviewCard(review)).toList(),
    );
  }

  Widget _buildReviewCard(Map<String, dynamic> data) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 3))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.grey[300],
                backgroundImage: data['studentImage'] != null && data['studentImage'].toString().isNotEmpty
                    ? NetworkImage(data['studentImage'])
                    : null,
                child: (data['studentImage'] == null || data['studentImage'].toString().isEmpty)
                    ? const Icon(Icons.person, color: Colors.white, size: 18)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  data['studentName'],
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blue),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.star, color: Colors.orange, size: 12),
                    const SizedBox(width: 3),
                    Text(
                      data['rating'].toStringAsFixed(1),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.black),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            data['comment'],
            style: const TextStyle(fontSize: 13, color: Colors.grey, height: 1.4),
          ),
          const SizedBox(height: 10),
          Text(
            data['createdAt'],
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _buildWriteReviewButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FB),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => WriteReviewScreen(courseData: widget.courseData),
            ),
          ).then((_) => _loadReviews());
        },
        child: Container(
          height: 50,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 8,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: const Center(
            child: Text(
              "Write a Review",
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}