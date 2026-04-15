import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import '../utils/api_mapper.dart';

class CourseService {
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

    String lowerMsg = cleaned.toLowerCase();

    // Student enrolled validation - Match exact backend message
    if (lowerMsg.contains('students are connected') ||
        lowerMsg.contains('cannot delete course: students are connected')) {
      return 'Cannot delete course. Students are enrolled in it.';
    }

    if (lowerMsg.contains('students are connected to this course')) {
      return 'Cannot delete course. Students are enrolled in it.';
    }

    // FromDay/ToDay validation
    if (lowerMsg.contains('fromday') && lowerMsg.contains('today')) {
      return 'From day must come before to day';
    }

    // Time validation
    if ((lowerMsg.contains('start time') && lowerMsg.contains('end time')) ||
        (lowerMsg.contains('starttime') && lowerMsg.contains('endtime'))) {
      return 'Start time must be before end time';
    }

    // Format error
    if (lowerMsg.contains('format')) {
      if (lowerMsg.contains('day')) return 'From day must come before to day';
      if (lowerMsg.contains('time')) return 'Start time must be before end time';
      return 'Please check your input and try again';
    }

    // Required fields
    if (lowerMsg.contains('price')) return 'Invalid price value';
    if (lowerMsg.contains('subject')) return 'Subject is required';
    if (lowerMsg.contains('category')) return 'Category is required';
    if (lowerMsg.contains('teaching mode')) return 'Teaching mode is required';
    if (lowerMsg.contains('location')) return 'Location is required';
    if (lowerMsg.contains('classes')) return 'Number of classes is required';

    if (cleaned.isEmpty || RegExp(r'^[0-9\s]+$').hasMatch(cleaned)) {
      return 'Something went wrong';
    }

    return cleaned;
  }
  // ============ CREATE COURSE ============
  static Future<Map<String, dynamic>> createCourse(Map<String, dynamic> courseData) async {
    if (useRealApi) {
      try {
        // Map to backend format
        final requestBody = ApiMapper.mapCourseRequest(courseData);

        final response = await http.post(
          Uri.parse(ApiConfig.getFullUrl(ApiConfig.createCourse)),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(requestBody),
        ).timeout(const Duration(seconds: 15));

        if (response.statusCode == 200) {
          final backendData = json.decode(response.body);
          // Map back to frontend format
          return ApiMapper.mapCourseResponse(backendData);
        } else {
          final errorData = json.decode(response.body);
          String errorMsg = errorData['error'] ?? 'Failed to create course';
          String finalMsg = _cleanErrorMessage(errorMsg);
          throw Exception(finalMsg);
        }
      } catch (e) {
        String finalMsg = _cleanErrorMessage(e.toString());
        throw Exception(finalMsg);
      }
    } else {
      // Mock data
      await Future.delayed(const Duration(seconds: 1));
      return {
        'id': DateTime.now().millisecondsSinceEpoch,
        'subject': courseData['subject'],
        'category': courseData['category'],
        'teachingMode': courseData['teachingMode'],
        'price': courseData['price'],
        'isAvailable': true,
      };
    }
  }

  // ============ UPDATE COURSE ============
  static Future<Map<String, dynamic>> updateCourse(int courseId, Map<String, dynamic> courseData) async {
    if (useRealApi) {
      try {
        // Map to backend format
        final requestBody = ApiMapper.mapCourseRequest(courseData);

        final response = await http.put(
          Uri.parse('${ApiConfig.getFullUrl(ApiConfig.updateCourse)}/$courseId'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(requestBody),
        ).timeout(const Duration(seconds: 15));

        if (response.statusCode == 200) {
          final backendData = json.decode(response.body);
          return ApiMapper.mapCourseResponse(backendData);
        } else {
          final errorData = json.decode(response.body);
          String errorMsg = errorData['error'] ?? 'Failed to update course';
          String finalMsg = _cleanErrorMessage(errorMsg);
          throw Exception(finalMsg);
        }
      } catch (e) {
        String finalMsg = _cleanErrorMessage(e.toString());
        throw Exception(finalMsg);
      }
    } else {
      await Future.delayed(const Duration(seconds: 1));
      return {'id': courseId, ...courseData};
    }
  }

  // ============ DELETE COURSE ============
  static Future<void> deleteCourse(int courseId) async {
    if (useRealApi) {
      try {
        print('📤 Deleting course: $courseId');

        final response = await http.delete(
          Uri.parse('${ApiConfig.getFullUrl(ApiConfig.deleteCourse)}/$courseId'),
          headers: {'Content-Type': 'application/json'},
        ).timeout(const Duration(seconds: 15));

        print('📥 Delete Course Response: ${response.statusCode}');

        if (response.statusCode != 200) {
          final errorData = json.decode(response.body);
          String errorMsg = errorData['error'] ?? 'Failed to delete course';
          String finalMsg = _cleanErrorMessage(errorMsg);
          throw Exception(finalMsg);
        }
      } catch (e) {
        String finalMsg = _cleanErrorMessage(e.toString());
        throw Exception(finalMsg);
      }
    } else {
      await Future.delayed(const Duration(seconds: 1));
    }
  }

  // ============ TOGGLE AVAILABILITY ============
  static Future<String> toggleAvailability(int courseId) async {
    if (useRealApi) {
      try {
        print('📤 Toggling availability for course: $courseId');

        final response = await http.put(
          Uri.parse('${ApiConfig.getFullUrl(ApiConfig.toggleAvailability)}/$courseId/toggle-availability'),
          headers: {'Content-Type': 'application/json'},
        ).timeout(const Duration(seconds: 15));

        print('📥 Toggle Availability Response: ${response.statusCode}');
        print('📥 Response body: ${response.body}');

        if (response.statusCode == 200) {
          return response.body;
        } else {
          final errorData = json.decode(response.body);
          String errorMsg = errorData['error'] ?? 'Failed to toggle availability';
          String finalMsg = _cleanErrorMessage(errorMsg);
          throw Exception(finalMsg);
        }
      } catch (e) {
        String finalMsg = _cleanErrorMessage(e.toString());
        throw Exception(finalMsg);
      }
    } else {
      await Future.delayed(const Duration(seconds: 1));
      return 'Course is now unavailable';
    }
  }

  // ============ GET TUTOR COURSES ============
  static Future<List<dynamic>> getTutorCourses(int tutorProfileId) async {
    if (useRealApi) {
      try {
        final response = await http.get(
          Uri.parse('${ApiConfig.getFullUrl(ApiConfig.getTutorCourses)}/$tutorProfileId'),
          headers: {'Content-Type': 'application/json'},
        ).timeout(const Duration(seconds: 15));

        if (response.statusCode == 200) {
          return json.decode(response.body);
        } else {
          throw Exception('Failed to fetch courses');
        }
      } catch (e) {
        String finalMsg = _cleanErrorMessage(e.toString());
        throw Exception(finalMsg);
      }
    } else {
      await Future.delayed(const Duration(seconds: 1));
      return [
        {'id': 1, 'subject': 'Mathematics', 'price': 5000, 'isAvailable': true, 'averageRating': 4.8},
        {'id': 2, 'subject': 'Physics', 'price': 6000, 'isAvailable': false, 'averageRating': 4.5},
      ];
    }
  }

  // ============ GET SINGLE COURSE DETAILS ============
  static Future<Map<String, dynamic>> getTutorCourseDetail(int courseId) async {
    if (useRealApi) {
      try {
        print('📤 Fetching course details for ID: $courseId');

        final response = await http.get(
          Uri.parse('${ApiConfig.getFullUrl(ApiConfig.getTutorCourseDetail)}/$courseId'),
          headers: {'Content-Type': 'application/json'},
        ).timeout(const Duration(seconds: 15));

        print('📥 Course Details Response: ${response.statusCode}');
        print('📥 Response body: ${response.body}');

        if (response.statusCode == 200) {
          final backendData = json.decode(response.body);
          print('✅ Course details fetched successfully');
          return backendData;
        } else if (response.statusCode == 404) {
          throw Exception('Course not found');
        } else {
          final errorData = json.decode(response.body);
          String errorMsg = errorData['error'] ?? 'Failed to fetch course details';
          String finalMsg = _cleanErrorMessage(errorMsg);
          throw Exception(finalMsg);
        }
      } catch (e) {
        print('❌ Error fetching course details: $e');
        String finalMsg = _cleanErrorMessage(e.toString());
        throw Exception(finalMsg);
      }
    } else {
      // Mock data for testing
      await Future.delayed(const Duration(seconds: 1));
      return {
        'id': courseId,
        'subject': 'Mathematics',
        'category': 'Matric',
        'teachingMode': 'Online',
        'price': 5000,
        'isAvailable': true,
        'averageRating': 4.8,
        'totalRatings': 12,
        'about': 'This is a sample course description.',
        'classesPerMonth': 8,
        'startTime': '14:00:00',
        'endTime': '16:00:00',
        'fromDay': 'Monday',
        'toDay': 'Friday',
        'location': 'Online',
      };
    }
  }

  // ============ GET AVAILABLE COURSES (for students) ============
  static Future<List<dynamic>> getAvailableCourses() async {
    if (useRealApi) {
      try {
        final response = await http.get(
          Uri.parse(ApiConfig.getFullUrl(ApiConfig.getAvailableCourses)),
          headers: {'Content-Type': 'application/json'},
        ).timeout(const Duration(seconds: 15));

        if (response.statusCode == 200) {
          List<dynamic> courses = json.decode(response.body);
          // The response is directly a list of courses
          return courses;
        } else {
          throw Exception('Failed to fetch available courses');
        }
      } catch (e) {
        throw Exception(_cleanErrorMessage(e.toString()));
      }
    } else {
      await Future.delayed(const Duration(seconds: 1));
      return [
        {
          'courseId': 1,
          'subject': 'Mathematics',
          'price': 5000,
          'category': 'MATRIC',
          'teachingMode': 'ONLINE',
          'averageRating': 4.8,
          'totalStudents': 23,
          'tutorName': 'John Doe',
          'location': 'Karachi',
          'about': 'Math course',
          'isAvailable': true
        },
      ];
    }
  }

  // ============ GET TUTOR COURSE CARDS (with totalStudents) ============
  static Future<List<dynamic>> getTutorCourseCards(int tutorProfileId) async {
    if (useRealApi) {
      try {
        final response = await http.get(
          Uri.parse('${ApiConfig.getFullUrl(ApiConfig.getTutorCourseCards)}/$tutorProfileId/cards'),
          headers: {'Content-Type': 'application/json'},
        ).timeout(const Duration(seconds: 15));

        if (response.statusCode == 200) {
          return json.decode(response.body);
        } else {
          throw Exception('Failed to fetch tutor course cards');
        }
      } catch (e) {
        throw Exception(_cleanErrorMessage(e.toString()));
      }
    } else {
      await Future.delayed(const Duration(seconds: 1));
      return [
        {
          'id': 1,
          'courseId': 1,
          'subject': 'Mathematics',
          'price': 5000,
          'category': 'MATRIC',
          'teachingMode': 'ONLINE',
          'averageRating': 4.8,
          'totalStudents': 23,
          'tutorName': 'John Doe',
          'location': 'Karachi',
          'isAvailable': true,
        },
      ];
    }
  }
}