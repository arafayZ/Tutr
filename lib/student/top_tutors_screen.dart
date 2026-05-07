import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'tutor_profile_screen.dart';
import '../services/rating_service.dart';
import '../config/api_config.dart';

class TopTutorData {
  final String name;
  final String expertise;
  final int id;
  final double rating;
  final String location;
  final String subject;
  final int totalRatings;
  final String? imageUrl;

  TopTutorData({
    required this.name,
    required this.expertise,
    this.id = 0,
    this.rating = 4.8,
    this.location = "Online",
    this.subject = "",
    this.totalRatings = 0,
    this.imageUrl,
  });
}

class TopTutorsScreen extends StatefulWidget {
  const TopTutorsScreen({super.key});

  @override
  State<TopTutorsScreen> createState() => _TopTutorsScreenState();
}

class _TopTutorsScreenState extends State<TopTutorsScreen> {
  List<TopTutorData> allTutors = [];
  List<TopTutorData> filteredTutors = [];
  bool _isLoading = true;
  int _studentId = 0;

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
    await _loadTopTutors();
  }

  Future<void> _loadTopTutors() async {
    setState(() => _isLoading = true);

    try {
      final response = await RatingService.getTopTutors(_studentId);
      final List<TopTutorData> transformedTutors = _transformApiResponse(response);

      setState(() {
        allTutors = transformedTutors;
        filteredTutors = transformedTutors;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorDialog(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  List<TopTutorData> _transformApiResponse(List<dynamic> tutors) {
    return tutors.map((tutor) {
      // Get rating and total ratings
      double ratingValue = 0.0;
      if (tutor['averageRating'] is int) {
        ratingValue = (tutor['averageRating'] as int).toDouble();
      } else if (tutor['averageRating'] is double) {
        ratingValue = tutor['averageRating'] as double;
      } else if (tutor['averageRating'] is String) {
        ratingValue = double.tryParse(tutor['averageRating']) ?? 0.0;
      }

      int totalRatings = tutor['totalRatings'] ?? 0;

      // Get image URL
      String? imageUrl = tutor['tutorImage']?.toString();
      if (imageUrl != null && imageUrl.isNotEmpty) {
        imageUrl = '${ApiConfig.baseUrl}$imageUrl';
      }

      // Get subject from course subjects
      String subject = tutor['subject']?.toString() ?? '';
      String expertise = tutor['tutorHeadline']?.toString() ?? 'Expert Tutor';
      String location = tutor['tutorLocation']?.toString() ?? 'Online';
      String name = tutor['tutorName']?.toString() ?? 'Unknown Tutor';
      int tutorId = tutor['tutorId'] ?? 0;

      return TopTutorData(
        name: name,
        expertise: expertise,
        id: tutorId,
        rating: ratingValue,
        location: location,
        subject: subject,
        totalRatings: totalRatings,
        imageUrl: imageUrl,
      );
    }).toList();
  }

  void _runFilter(String enteredKeyword) {
    List<TopTutorData> results = [];
    if (enteredKeyword.isEmpty) {
      results = allTutors;
    } else {
      results = allTutors
          .where((tutor) =>
      tutor.name.toLowerCase().contains(enteredKeyword.toLowerCase()) ||
          tutor.expertise.toLowerCase().contains(enteredKeyword.toLowerCase()) ||
          tutor.subject.toLowerCase().contains(enteredKeyword.toLowerCase()))
          .toList();
    }

    setState(() {
      filteredTutors = results;
    });
  }

  void _navigateToTutorProfile(TopTutorData tutor) {
    final Map<String, dynamic> tutorData = {
      'id': tutor.id,
      'tutorId': tutor.id,
      'name': tutor.name,
      'tutorName': tutor.name,
      'sub': tutor.subject.isNotEmpty ? tutor.subject : tutor.expertise,
      'tutorHeadline': tutor.expertise,
      'rating': tutor.rating.toString(),
      'averageRating': tutor.rating,
      'location': tutor.location,
      'tutorLocation': tutor.location,
      'totalRatings': tutor.totalRatings,
      'tutorImage': tutor.imageUrl?.replaceFirst(ApiConfig.baseUrl, ''),
    };

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TutorProfileScreen(tutorData: tutorData),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                children: [
                  _circleIconButton(
                    icon: Icons.arrow_back,
                    onTap: () => Navigator.pop(context),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        "Top Tutor",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 45),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 25, 20, 10),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  )
                ],
              ),
              child: TextField(
                onChanged: (value) => _runFilter(value),
                cursorColor: Colors.black,
                decoration: InputDecoration(
                  hintText: "Search tutors...",
                  hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                  prefixIcon: const Icon(Icons.search, color: Colors.black54),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ),

          // Tutors List
          Expanded(
            child: _isLoading
                ? const Center(
              child: CircularProgressIndicator(color: Colors.black),
            )
                : filteredTutors.isEmpty
                ? const Center(
              child: Text(
                'No tutors found',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
                : ListView.separated(
              padding: const EdgeInsets.all(20),
              physics: const BouncingScrollPhysics(),
              itemCount: filteredTutors.length,
              separatorBuilder: (context, index) => const SizedBox(height: 15),
              itemBuilder: (context, index) {
                final tutor = filteredTutors[index];
                return GestureDetector(
                  onTap: () => _navigateToTutorProfile(tutor),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // CircleAvatar with image or fallback
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: Colors.grey[200],
                          backgroundImage: tutor.imageUrl != null && tutor.imageUrl!.isNotEmpty
                              ? NetworkImage(tutor.imageUrl!)
                              : null,
                          child: tutor.imageUrl == null || tutor.imageUrl!.isEmpty
                              ? const Icon(
                            Icons.person,
                            color: Colors.grey,
                            size: 28,
                          )
                              : null,
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                tutor.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF000000),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                tutor.expertise,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Rating and Total Ratings
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.star, color: Colors.orange, size: 12),
                                const SizedBox(width: 2),
                                Text(
                                  tutor.rating.toStringAsFixed(1),
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  "(${tutor.totalRatings})",
                                  style: const TextStyle(
                                    fontSize: 9,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.location_on, size: 10, color: Colors.grey),
                                const SizedBox(width: 2),
                                Text(
                                  tutor.location,
                                  style: const TextStyle(
                                    fontSize: 9,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.arrow_forward_ios,
                          size: 14,
                          color: Colors.grey,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _circleIconButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: const BoxDecoration(
          color: Colors.black,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}