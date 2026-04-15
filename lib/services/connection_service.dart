import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import '../utils/api_mapper.dart';

class ConnectionService {
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

  // Get all tutor connections (students)
  static Future<List<Map<String, dynamic>>> getTutorConnections(int tutorProfileId) async {
    if (useRealApi) {
      try {
        final response = await http.get(
          Uri.parse('${ApiConfig.getFullUrl(ApiConfig.getTutorConnections)}/$tutorProfileId'),
          headers: {'Content-Type': 'application/json'},
        ).timeout(const Duration(seconds: 15));

        if (response.statusCode == 200) {
          List<dynamic> connections = json.decode(response.body);
          // Map each connection using ApiMapper
          return connections.map((conn) => ApiMapper.mapConnectionResponse(conn)).toList();
        } else {
          throw Exception('Failed to fetch tutor connections');
        }
      } catch (e) {
        throw Exception(_cleanErrorMessage(e.toString()));
      }
    } else {
      await Future.delayed(const Duration(seconds: 1));
      return [
        {
          'connectionId': 1,
          'courseId': 1,
          'subject': 'Mathematics',
          'studentId': 1,
          'studentName': 'Asim Ali Khan',
          'studentImage': null,
          'tutorId': 1,
          'tutorName': 'Emaz Ali Khan',
          'tutorHeadline': 'Experienced Tutor',
          'status': 'ACTIVE',
          'originalPrice': 2000,
          'studentBidPrice': 1500,
          'tutorOffer': null,
          'agreedPrice': 1500,
          'requestedAt': '2026-04-01T10:00:00',
        },
      ];
    }
  }

  // Get single student details by connectionId
  static Future<Map<String, dynamic>> getStudentDetail(int connectionId) async {
    if (useRealApi) {
      try {
        final response = await http.get(
          Uri.parse('${ApiConfig.getFullUrl(ApiConfig.studentDetail)}/$connectionId'),
          headers: {'Content-Type': 'application/json'},
        ).timeout(const Duration(seconds: 15));

        if (response.statusCode == 200) {
          Map<String, dynamic> data = json.decode(response.body);

          // Convert double to int for price fields
          if (data['agreedPrice'] is double) {
            data['agreedPrice'] = (data['agreedPrice'] as double).toInt();
          }
          if (data['originalPrice'] is double) {
            data['originalPrice'] = (data['originalPrice'] as double).toInt();
          }

          return data;
        } else {
          throw Exception('Failed to fetch student details');
        }
      } catch (e) {
        throw Exception(_cleanErrorMessage(e.toString()));
      }
    } else {
      // Mock data
      await Future.delayed(const Duration(seconds: 1));
      return {
        'studentId': 1,
        'studentName': 'Asim Ali Khan',
        'profileImageUrl': null,
        'location': 'Karachi',
        'phoneNumber': '03451234567',
        'gender': 'Male',
        'studentEmail': 'asim@gmail.com',
        'agreedPrice': 1500,
        'originalPrice': 2000,
        'status': 'CONFIRMED',
        'connectionId': connectionId,
      };
    }
  }

  // Get tutor pending requests
  static Future<List<Map<String, dynamic>>> getPendingRequests(int tutorProfileId) async {
    if (useRealApi) {
      try {
        final response = await http.get(
          Uri.parse('${ApiConfig.getFullUrl(ApiConfig.getPendingRequests)}/$tutorProfileId/pending'),
          headers: {'Content-Type': 'application/json'},
        ).timeout(const Duration(seconds: 15));

        if (response.statusCode == 200) {
          List<dynamic> requests = json.decode(response.body);
          return requests.map((req) => ApiMapper.mapConnectionResponse(req)).toList();
        } else {
          throw Exception('Failed to fetch pending requests');
        }
      } catch (e) {
        throw Exception(_cleanErrorMessage(e.toString()));
      }
    } else {
      await Future.delayed(const Duration(seconds: 1));
      return [];
    }
  }


  // Get negotiations (bids where tutor has made counter offers)
  static Future<List<Map<String, dynamic>>> getNegotiations(int tutorProfileId) async {
    if (useRealApi) {
      try {
        final response = await http.get(
          Uri.parse('${ApiConfig.getFullUrl(ApiConfig.getNegotiations)}/$tutorProfileId/negotiations'),
          headers: {'Content-Type': 'application/json'},
        ).timeout(const Duration(seconds: 15));

        if (response.statusCode == 200) {
          List<dynamic> negotiations = json.decode(response.body);
          return negotiations.map((neg) => ApiMapper.mapConnectionResponse(neg)).toList();
        } else {
          throw Exception('Failed to fetch negotiations');
        }
      } catch (e) {
        throw Exception(_cleanErrorMessage(e.toString()));
      }
    } else {
      await Future.delayed(const Duration(seconds: 1));
      return [
        {
          'connectionId': 2,
          'courseId': 1,
          'subject': 'Mathematics',
          'studentId': 2,
          'studentName': 'Bilal Raza',
          'studentImage': null,
          'originalPrice': 2000,
          'studentBidPrice': 1800,
          'tutorOffer': 1900,
          'status': 'NEGOTIATING',
        },
      ];
    }
  }

  // Tutor respond to connection request (Accept/Reject/Counter)
  static Future<Map<String, dynamic>> tutorRespond(
      int connectionId, {
        required bool accept,
        int? counterOffer,
      }) async {
    if (useRealApi) {
      try {
        String url = '${ApiConfig.getFullUrl(ApiConfig.tutorRespond)}/$connectionId/tutor-respond?accept=$accept';
        if (counterOffer != null) {
          url += '&counterOffer=$counterOffer';
        }

        final response = await http.post(
          Uri.parse(url),
          headers: {'Content-Type': 'application/json'},
        ).timeout(const Duration(seconds: 15));

        if (response.statusCode == 200) {
          return json.decode(response.body);
        } else {
          final errorData = json.decode(response.body);
          throw Exception(errorData['error'] ?? 'Failed to respond');
        }
      } catch (e) {
        throw Exception(_cleanErrorMessage(e.toString()));
      }
    } else {
      await Future.delayed(const Duration(seconds: 1));
      return {};
    }
  }

  // Search students by name
  static Future<List<Map<String, dynamic>>> searchStudents(int tutorProfileId, String query) async {
    if (useRealApi) {
      try {
        final response = await http.get(
          Uri.parse('${ApiConfig.getFullUrl(ApiConfig.searchStudents)}/$tutorProfileId/search?query=$query'),
          headers: {'Content-Type': 'application/json'},
        ).timeout(const Duration(seconds: 15));

        if (response.statusCode == 200) {
          List<dynamic> students = json.decode(response.body);
          return students.map((s) => ApiMapper.mapConnectionResponse(s)).toList();
        } else {
          throw Exception('Failed to search students');
        }
      } catch (e) {
        throw Exception(_cleanErrorMessage(e.toString()));
      }
    } else {
      await Future.delayed(const Duration(seconds: 1));
      return [
        {
          'studentId': 1,
          'studentName': 'Asim Ali Khan',
          'studentImage': null,
          'location': 'Karachi',
          'phoneNumber': '03451234567',
          'studentEmail': 'asim@gmail.com',
        },
      ];
    }
  }

  // Filter students by category and/or teaching mode
  static Future<List<Map<String, dynamic>>> filterStudents(
      int tutorProfileId, {
        String? category,
        String? teachingMode,
      }) async {
    if (useRealApi) {
      try {
        // Build URL with query parameters
        String url = '${ApiConfig.getFullUrl(ApiConfig.filterStudents)}/$tutorProfileId/students/filter';
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

        print('📥 Filter Students URL: $url');

        final response = await http.get(
          Uri.parse(url),
          headers: {'Content-Type': 'application/json'},
        ).timeout(const Duration(seconds: 15));

        if (response.statusCode == 200) {
          List<dynamic> students = json.decode(response.body);
          return students.map((s) => ApiMapper.mapConnectionResponse(s)).toList();
        } else {
          throw Exception('Failed to filter students');
        }
      } catch (e) {
        throw Exception(_cleanErrorMessage(e.toString()));
      }
    } else {
      await Future.delayed(const Duration(seconds: 1));
      return [
        {
          'studentId': 1,
          'studentName': 'Asim Ali Khan',
          'studentImage': null,
          'location': 'Karachi',
          'phoneNumber': '03451234567',
          'studentEmail': 'asim@gmail.com',
          'category': category,
          'teachingMode': teachingMode,
        },
      ];
    }
  }


  // Get only confirmed tutor connections (students)
  static Future<List<Map<String, dynamic>>> getTutorConfirmedConnections(int tutorProfileId) async {
    if (useRealApi) {
      try {
        final response = await http.get(
          Uri.parse('${ApiConfig.getFullUrl(ApiConfig.getTutorConfirmedConnections)}/$tutorProfileId/confirmed'),
          headers: {'Content-Type': 'application/json'},
        ).timeout(const Duration(seconds: 15));

        if (response.statusCode == 200) {
          List<dynamic> connections = json.decode(response.body);
          return connections.map((conn) => ApiMapper.mapConnectionResponse(conn)).toList();
        } else {
          throw Exception('Failed to fetch confirmed connections');
        }
      } catch (e) {
        throw Exception(_cleanErrorMessage(e.toString()));
      }
    } else {
      await Future.delayed(const Duration(seconds: 1));
      return [
        {
          'connectionId': 1,
          'courseId': 1,
          'subject': 'Mathematics',
          'studentId': 1,
          'studentName': 'Asim Ali Khan',
          'studentImage': null,
          'tutorId': 1,
          'tutorName': 'Emaz Ali Khan',
          'status': 'CONFIRMED',
          'agreedPrice': 1500,
          'originalPrice': 2000,
          'location': 'Karachi',
          'phoneNumber': '03451234567',
          'gender': 'Male',
          'studentEmail': 'asim@gmail.com',
        },
      ];
    }
  }

  // Get tutor bids
  static Future<List<Map<String, dynamic>>> getTutorBids(int tutorProfileId) async {
    if (useRealApi) {
      try {
        final response = await http.get(
          Uri.parse('${ApiConfig.getFullUrl(ApiConfig.getTutorBids)}/$tutorProfileId/bids-with-cards'),
          headers: {'Content-Type': 'application/json'},
        ).timeout(const Duration(seconds: 15));

        if (response.statusCode == 200) {
          List<dynamic> bids = json.decode(response.body);
          return bids.map((bid) => ApiMapper.mapConnectionResponse(bid)).toList();
        } else {
          throw Exception('Failed to fetch tutor bids');
        }
      } catch (e) {
        throw Exception(_cleanErrorMessage(e.toString()));
      }
    } else {
      await Future.delayed(const Duration(seconds: 1));
      return [];
    }
  }

  // // Tutor respond to connection request (Accept/Reject/Counter)
  // static Future<Map<String, dynamic>> tutorRespond(int connectionId, String action, {int? counterOffer}) async {
  //   if (useRealApi) {
  //     try {
  //       Map<String, dynamic> requestBody = {
  //         'action': action, // 'ACCEPT', 'REJECT', 'COUNTER'
  //       };
  //       if (counterOffer != null) {
  //         requestBody['counterOffer'] = counterOffer;
  //       }
  //
  //       final response = await http.put(
  //         Uri.parse('${ApiConfig.getFullUrl(ApiConfig.tutorRespond)}/$connectionId/tutor-respond'),
  //         headers: {'Content-Type': 'application/json'},
  //         body: json.encode(requestBody),
  //       ).timeout(const Duration(seconds: 15));
  //
  //       if (response.statusCode == 200) {
  //         return ApiMapper.mapConnectionResponse(json.decode(response.body));
  //       } else {
  //         final errorData = json.decode(response.body);
  //         throw Exception(errorData['error'] ?? 'Failed to respond');
  //       }
  //     } catch (e) {
  //       throw Exception(_cleanErrorMessage(e.toString()));
  //     }
  //   } else {
  //     await Future.delayed(const Duration(seconds: 1));
  //     return {};
  //   }
  // }

  // Disconnect a student
  static Future<void> disconnect(int connectionId, {String disconnectedBy = "TUTOR"}) async {
    if (useRealApi) {
      try {
        final response = await http.post(
          Uri.parse('${ApiConfig.getFullUrl(ApiConfig.disconnect)}/$connectionId/disconnect?disconnectedBy=$disconnectedBy'),
          headers: {'Content-Type': 'application/json'},
        ).timeout(const Duration(seconds: 15));

        if (response.statusCode == 200) {
          return;
        } else {
          final errorData = json.decode(response.body);
          throw Exception(errorData['error'] ?? 'Failed to disconnect');
        }
      } catch (e) {
        throw Exception(_cleanErrorMessage(e.toString()));
      }
    } else {
      await Future.delayed(const Duration(seconds: 1));
    }
  }


  // Student cancel connection
  static Future<void> studentCancel(int connectionId) async {
    if (useRealApi) {
      try {
        final response = await http.put(
          Uri.parse('${ApiConfig.getFullUrl(ApiConfig.studentCancel)}/$connectionId/student-cancel'),
          headers: {'Content-Type': 'application/json'},
        ).timeout(const Duration(seconds: 15));

        if (response.statusCode != 200) {
          final errorData = json.decode(response.body);
          throw Exception(errorData['error'] ?? 'Failed to cancel');
        }
      } catch (e) {
        throw Exception(_cleanErrorMessage(e.toString()));
      }
    } else {
      await Future.delayed(const Duration(seconds: 1));
    }
  }
}