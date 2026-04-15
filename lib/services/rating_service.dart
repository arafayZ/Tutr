import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class RatingService {
  static bool get useRealApi => ApiConfig.useRealApi;

  static String _cleanErrorMessage(String message) {
    String cleaned = message
        .replaceFirst('Exception: ', '')
        .replaceAll('"', '')
        .replaceAll('{', '')
        .replaceAll('}', '')
        .replaceAll('[', '')
        .replaceAll(']', '')
        .replaceAll('\\', '')
        .trim();
    return cleaned.isEmpty ? 'Something went wrong' : cleaned;
  }


  // ============ GET TOP RATED COURSES FOR TUTOR ============
  static Future<List<dynamic>> getTopRatedCourses(int tutorId, {int limit = 5}) async {
    if (useRealApi) {
      try {
        final response = await http.get(
          Uri.parse('${ApiConfig.getFullUrl(ApiConfig.getTopRatedCourses)}/$tutorId/top-courses?limit=$limit'),
          headers: {'Content-Type': 'application/json'},
        ).timeout(const Duration(seconds: 15));

        print(' Top Courses Response Status: ${response.statusCode}');
        print(' Top Courses Response Body: ${response.body}');

        if (response.statusCode == 200) {
          return json.decode(response.body);
        } else {
          throw Exception('Failed to load top courses');
        }
      } catch (e) {
        throw Exception(_cleanErrorMessage(e.toString()));
      }
    } else {
      // Mock data for testing
      await Future.delayed(const Duration(seconds: 1));
      return [
        {
          'courseId': 1,
          'subject': 'Mathematics',
          'category': 'INTERMEDIATE',
          'teachingMode': 'ONLINE',
          'price': 5000.0,
          'averageRating': 4.8,
          'tutorName': 'John Doe',
          'rank': 1
        },
        {
          'courseId': 2,
          'subject': 'Physics',
          'category': 'A_LEVEL',
          'teachingMode': 'STUDENT_HOME',
          'price': 6000.0,
          'averageRating': 4.5,
          'tutorName': 'John Doe',
          'rank': 2
        },
      ];
    }
  }

  // ============ GET TUTOR RATING SUMMARY ============
  static Future<Map<String, dynamic>> getTutorRatingSummary(int tutorProfileId) async {
    if (useRealApi) {
      try {
        final response = await http.get(
          Uri.parse('${ApiConfig.getFullUrl(ApiConfig.getTutorRatingSummary)}/$tutorProfileId/summary'),
          headers: {'Content-Type': 'application/json'},
        ).timeout(const Duration(seconds: 15));

        print('📥 Rating Summary Response Status: ${response.statusCode}');
        print('📥 Rating Summary Response Body: ${response.body}');

        if (response.statusCode == 200) {
          return json.decode(response.body);
        } else {
          throw Exception('Failed to fetch rating summary');
        }
      } catch (e) {
        throw Exception(_cleanErrorMessage(e.toString()));
      }
    } else {
      await Future.delayed(const Duration(seconds: 1));
      return {
        'averageRating': 3.8,
        'totalRatings': 5,
        'ratingDistribution': {'1': 0, '2': 0, '3': 1, '4': 4, '5': 0},
        'tutorName': 'Emaz Ali Khan',
        'reviews': [
          {
            'reviewId': 5,
            'studentName': 'Ayesha Asif',
            'studentImage': null,
            'rating': 4,
            'review': 'Good course, well structured',
            'category': 'MATRIC',
            'teachingMode': 'STUDENT_HOME',
            'courseSubject': 'Biology',
            'createdAt': DateTime.now().toIso8601String(),
          }
        ],
      };
    }
  }

// ============ GET TUTOR FILTER OPTIONS ============
  static Future<Map<String, dynamic>> getTutorFilterOptions(int tutorProfileId) async {
    if (useRealApi) {
      try {
        final response = await http.get(
          Uri.parse('${ApiConfig.getFullUrl(ApiConfig.getTutorFilterOptions)}/$tutorProfileId/filter-options'),
          headers: {'Content-Type': 'application/json'},
        ).timeout(const Duration(seconds: 15));

        print(' Filter Options Response Status: ${response.statusCode}');
        print(' Filter Options Response Body: ${response.body}');

        if (response.statusCode == 200) {
          return json.decode(response.body);
        } else {
          throw Exception('Failed to fetch filter options');
        }
      } catch (e) {
        throw Exception(_cleanErrorMessage(e.toString()));
      }
    } else {
      await Future.delayed(const Duration(seconds: 1));
      return {
        'categories': ['Matric', 'Intermediate', 'O Level', 'A Level', 'Entrance Test'],
        'teachingModes': ['Online', 'Student Home', 'Tutor Home'],
      };
    }
  }

// ============ GET REVIEW DETAIL ============
  static Future<Map<String, dynamic>> getReviewDetail(int reviewId) async {
    if (useRealApi) {
      try {
        final response = await http.get(
          Uri.parse('${ApiConfig.getFullUrl(ApiConfig.getReviewDetail)}/$reviewId'),
          headers: {'Content-Type': 'application/json'},
        ).timeout(const Duration(seconds: 15));

        print('📥 Review Detail Response Status: ${response.statusCode}');
        print('📥 Review Detail Response Body: ${response.body}');

        if (response.statusCode == 200) {
          return json.decode(response.body);
        } else {
          throw Exception('Failed to fetch review detail');
        }
      } catch (e) {
        throw Exception(_cleanErrorMessage(e.toString()));
      }
    } else {
      await Future.delayed(const Duration(seconds: 1));
      return {
        'reviewId': 1,
        'studentId': 1,
        'studentName': 'Sumaika Asif',
        'studentImage': '/uploads/student-profile-images/user_6_student_20260318_143626_4428b688-4424-4c3e-9c52-49817e66da9a.png',
        'rating': 4,
        'review': 'Good course, well structured',
        'courseId': 1,
        'subject': 'Chemistry',
        'tutorName': 'Emaz Ali Khan',
        'price': 4000.0,
        'category': 'MATRIC',
        'teachingMode': 'STUDENT_HOME',
        'averageRating': 4.0,
        'createdAt': '2026-03-19T01:47:42.213588',
      };
    }
  }

  // ============ GET TUTOR RATING SUMMARY WITH FILTERS ============
  static Future<Map<String, dynamic>> getTutorRatingSummaryWithFilters(
      int tutorProfileId, {
        String? category,
        String? teachingMode,
      }) async {
    if (useRealApi) {
      try {
        // Build URL with query parameters
        String url = '${ApiConfig.getFullUrl(ApiConfig.getTutorRatingSummary)}/$tutorProfileId/summary';
        List<String> queryParams = [];

        if (category != null && category.isNotEmpty) {
          queryParams.add('category=$category');
        }
        if (teachingMode != null && teachingMode.isNotEmpty) {
          queryParams.add('teachingMode=$teachingMode');
        }

        if (queryParams.isNotEmpty) {
          url += '?${queryParams.join('&')}';
        }

        print('📥 Rating Summary URL: $url');

        final response = await http.get(
          Uri.parse(url),
          headers: {'Content-Type': 'application/json'},
        ).timeout(const Duration(seconds: 15));

        print('📥 Rating Summary Response Status: ${response.statusCode}');
        print('📥 Rating Summary Response Body: ${response.body}');

        if (response.statusCode == 200) {
          return json.decode(response.body);
        } else {
          // Return empty data instead of throwing error
          return {
            'averageRating': 0.0,
            'totalRatings': 0,
            'ratingDistribution': {'1': 0, '2': 0, '3': 0, '4': 0, '5': 0},
            'tutorName': '',
            'reviews': [],
          };
        }
      } catch (e) {
        print('Error in getTutorRatingSummaryWithFilters: $e');
        // Return empty data instead of throwing error
        return {
          'averageRating': 0.0,
          'totalRatings': 0,
          'ratingDistribution': {'1': 0, '2': 0, '3': 0, '4': 0, '5': 0},
          'tutorName': '',
          'reviews': [],
        };
      }
    } else {
      await Future.delayed(const Duration(seconds: 1));
      return {
        'averageRating': 4.0,
        'totalRatings': 5,
        'ratingDistribution': {'1': 0, '2': 0, '3': 1, '4': 4, '5': 0},
        'tutorName': 'Emaz Ali Khan',
        'reviews': [
          {
            'reviewId': 1,
            'studentName': 'Sumaika Asif',
            'studentImage': null,
            'rating': 4,
            'review': 'Good course, well structured',
            'category': category ?? 'MATRIC',
            'teachingMode': teachingMode ?? 'STUDENT_HOME',
            'courseSubject': 'Chemistry',
            'createdAt': DateTime.now().toIso8601String(),
          }
        ],
      };
    }
  }

}