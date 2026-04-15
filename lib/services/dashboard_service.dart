import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class DashboardService {
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

  // ============ TUTOR DASHBOARD ============
  static Future<Map<String, dynamic>> getTutorDashboard(int tutorId) async {
    if (useRealApi) {
      try {
        final response = await http.get(
          Uri.parse(ApiConfig.getFullUrl('${ApiConfig.tutorDashboard}/$tutorId')),
          headers: {'Content-Type': 'application/json'},
        ).timeout(const Duration(seconds: 15));

        print(' Dashboard Response Status: ${response.statusCode}');
        print(' Dashboard Response Body: ${response.body}');

        if (response.statusCode == 200) {
          return json.decode(response.body);
        } else {
          throw Exception('Failed to load dashboard');
        }
      } catch (e) {
        throw Exception(_cleanErrorMessage(e.toString()));
      }
    } else {
      // Mock data for testing
      await Future.delayed(const Duration(seconds: 1));
      return {
        'tutorId': tutorId,
        'tutorName': 'John Doe',
        'tutorImage': null,
        'totalActiveStudents': 15,
        'totalActiveCourses': 5,
        'topCourses': [
          {
            'courseId': 1,
            'subject': 'Mathematics',
            'averageRating': 4.8,
            'totalStudents': 8,
            'rank': 1
          },
          {
            'courseId': 2,
            'subject': 'Physics',
            'averageRating': 4.5,
            'totalStudents': 5,
            'rank': 2
          },
        ],
      };
    }
  }

  // ============ STUDENT DASHBOARD ============
  static Future<Map<String, dynamic>> getStudentDashboard(int studentId) async {
    if (useRealApi) {
      try {
        final response = await http.get(
          Uri.parse(ApiConfig.getFullUrl('${ApiConfig.studentDashboard}/$studentId')),
          headers: {'Content-Type': 'application/json'},
        ).timeout(const Duration(seconds: 15));

        print('📥 Student Dashboard Response Status: ${response.statusCode}');
        print('📥 Student Dashboard Response Body: ${response.body}');

        if (response.statusCode == 200) {
          return json.decode(response.body);
        } else {
          throw Exception('Failed to load student dashboard');
        }
      } catch (e) {
        throw Exception(_cleanErrorMessage(e.toString()));
      }
    } else {
      // Mock data for testing
      await Future.delayed(const Duration(seconds: 1));
      return {
        'studentId': studentId,
        'studentName': 'Jane Smith',
        'studentImage': null,
        'topTutors': [
          {
            'tutorId': 1,
            'tutorName': 'Dr. Ahmed Khan',
            'tutorImage': null,
            'tutorHeadline': 'Mathematics Expert',
            'averageRating': 4.9,
            'totalRatings': 45,
            'rank': 1
          },
          {
            'tutorId': 2,
            'tutorName': 'Prof. Fatima Ali',
            'tutorImage': null,
            'tutorHeadline': 'Physics Specialist',
            'averageRating': 4.8,
            'totalRatings': 32,
            'rank': 2
          },
        ],
        'recommendedCourses': [
          {
            'courseId': 1,
            'subject': 'Mathematics',
            'category': 'INTERMEDIATE',
            'teachingMode': 'ONLINE',
            'price': 5000.0,
            'averageRating': 4.8,
            'totalRatings': 25,
            'tutorName': 'Dr. Ahmed Khan',
            'tutorId': 1,
            'rank': 1
          },
        ],
      };
    }
  }

}