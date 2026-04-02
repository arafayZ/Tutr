import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import '../utils/api_mapper.dart';
import 'package:http_parser/http_parser.dart';

class ApiService {
  static bool get useRealApi => ApiConfig.useRealApi;

  // ============ HELPER METHODS ============

  static String _cleanErrorMessage(String message) {
    String cleaned = message
        .replaceFirst('Exception: ', '')
        .replaceAll('"', '')
        .replaceAll('{', '')
        .replaceAll('}', '')
        .replaceAll('[', '')
        .replaceAll(']', '')
        .replaceAll('\\', '')
        .replaceAll('^', '')
        .replaceFirst('error:', '')
        .replaceFirst('Error:', '')
        .replaceAll(RegExp(r'^[0-9]+'), '')
        .trim();

    // Remove any remaining special characters at start
    cleaned = cleaned.replaceFirst(RegExp(r'^[^A-Za-z]+'), '');

    // Handle age error messages - remove "Tutor" or "Student" words
    if (cleaned.contains('must be at least')) {
      // Find the position of 'must be at least' and keep from there
      int mustIndex = cleaned.indexOf('must be at least');
      if (mustIndex != -1) {
        cleaned = cleaned.substring(mustIndex);
      }
    }

    // Handle other errors
    else if (cleaned.contains('Invalid email')) {
      cleaned = 'Invalid email or password';
    } else if (cleaned.contains('Email already exists')) {
      cleaned = 'Email already exists';
    } else if (cleaned.contains('User not found')) {
      cleaned = 'User not found';
    } else if (cleaned.contains('Date of birth cannot be in the future')) {
      cleaned = 'Date of birth cannot be in the future';
    } else if (cleaned.contains('Date of birth is required')) {
      cleaned = 'Date of birth is required';
    } else if (cleaned.contains('Only Gmail') || cleaned.contains('Yahoo')) {
      cleaned = 'Only Gmail and Yahoo email addresses are allowed';
    }

    // Final cleanup - remove any remaining special characters
    cleaned = cleaned.replaceAll(RegExp(r'[^a-zA-Z0-9\s\.]'), '').trim();

    return cleaned.isEmpty ? 'Something went wrong' : cleaned;
  }

  static Future<Map<String, String>> _getHeaders() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // ============ AUTHENTICATION APIS ============

  static Future<Map<String, dynamic>> login(String email, String password) async {
    if (useRealApi) {
      try {
        final response = await http.post(
          Uri.parse(ApiConfig.getFullUrl(ApiConfig.login)),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'email': email, 'password': password}),
        ).timeout(const Duration(seconds: 15));

        if (response.statusCode == 200) {
          final backendData = json.decode(response.body);
          final mappedData = ApiMapper.mapLoginResponse(backendData);
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setInt('userId', mappedData['id']);
          await prefs.setInt('profileId', mappedData['profileId'] ?? 0);
          await prefs.setString('userRole', mappedData['role']);
          await prefs.setInt('registrationStep', mappedData['registrationStep'] ?? 1);
          return mappedData;
        } else {
          final errorData = json.decode(response.body);
          throw Exception(_cleanErrorMessage(errorData['error'] ?? 'Login failed'));
        }
      } catch (e) {
        throw Exception(_cleanErrorMessage(e.toString()));
      }
    } else {
      await Future.delayed(const Duration(seconds: 1));
      if (email.isEmpty || password.isEmpty) {
        throw Exception('Please enter email and password');
      }
      if (email.contains('tutor')) {
        return {
          'id': 1,
          'profileId': 1,
          'email': email,
          'role': 'TUTOR',
          'accountStatus': 'ACTIVE',
          'registrationStep': 4,
          'message': 'Login successful',
          'redirectUrl': '/tutor/dashboard',
        };
      } else {
        return {
          'id': 2,
          'profileId': 1,
          'email': email,
          'role': 'STUDENT',
          'accountStatus': 'ACTIVE',
          'registrationStep': 2,
          'message': 'Login successful',
          'redirectUrl': '/student/dashboard',
        };
      }
    }
  }

  // ============ REGISTER ============
  static Future<Map<String, dynamic>> register(String email, String password, String role) async {
    if (useRealApi) {
      try {
        final requestBody = ApiMapper.mapRegisterRequest(email, password, role);
        final response = await http.post(
          Uri.parse(ApiConfig.getFullUrl(ApiConfig.register)),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(requestBody),
        ).timeout(const Duration(seconds: 15));

        if (response.statusCode == 200) {
          final backendData = json.decode(response.body);
          return ApiMapper.mapRegisterResponse(backendData);
        } else {
          final errorData = json.decode(response.body);
          throw Exception(_cleanErrorMessage(errorData['error'] ?? 'Registration failed'));
        }
      } catch (e) {
        throw Exception(_cleanErrorMessage(e.toString()));
      }
    } else {
      await Future.delayed(const Duration(seconds: 1));
      return {
        'id': role == 'Tutor' ? 1 : 2,
        'email': email,
        'role': role.toUpperCase(),
        'accountStatus': role == 'Tutor' ? 'PENDING' : 'ACTIVE',
        'registrationStep': 1,
      };
    }
  }

  // ============ TUTOR PROFILE APIS ============

  static Future<Map<String, dynamic>> createTutorProfile(Map<String, dynamic> data) async {
    if (useRealApi) {
      try {
        final requestBody = ApiMapper.mapTutorProfileRequest(data);
        final response = await http.post(
          Uri.parse(ApiConfig.getFullUrl(ApiConfig.tutorProfile)),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(requestBody),
        );

        if (response.statusCode == 200) {
          final backendData = json.decode(response.body);
          return ApiMapper.mapTutorProfileResponse(backendData);
        } else {
          final errorData = json.decode(response.body);
          throw Exception(_cleanErrorMessage(errorData['error'] ?? 'Failed to create profile'));
        }
      } catch (e) {
        throw Exception(_cleanErrorMessage(e.toString()));
      }
    } else {
      await Future.delayed(const Duration(seconds: 1));
      return {
        'id': 1,
        'user': {'id': data['userId']},
        'firstName': data['firstName'],
        'lastName': data['lastName'],
        'profilePictureUrl': null,
      };
    }
  }

  // ============ IMAGE UPLOAD ============

  static Future<Map<String, dynamic>> uploadTutorImage(int profileId, String imagePath) async {
    if (useRealApi) {
      try {
        File imageFile = File(imagePath);
        if (!await imageFile.exists()) {
          throw Exception('Image file not found');
        }

        String extension = imagePath.split('.').last.toLowerCase();
        String contentType = extension == 'png' ? 'image/png' : 'image/jpeg';

        var request = http.MultipartRequest(
          'POST',
          Uri.parse(ApiConfig.getFullUrl(ApiConfig.uploadTutorImage)),
        );
        request.fields['tutorProfileId'] = profileId.toString();

        var multipartFile = await http.MultipartFile.fromPath(
          'profileImage',
          imagePath,
          contentType: MediaType.parse(contentType),
        );
        request.files.add(multipartFile);

        var response = await request.send();
        var responseData = await response.stream.bytesToString();

        if (response.statusCode == 200) {
          return json.decode(responseData);
        } else {
          throw Exception('Failed to upload image');
        }
      } catch (e) {
        throw Exception(_cleanErrorMessage(e.toString()));
      }
    } else {
      await Future.delayed(const Duration(seconds: 1));
      return {'profilePictureUrl': '/uploads/mock-image.jpg'};
    }
  }

  // ============ DOCUMENT UPLOAD ============

  static Future<Map<String, dynamic>> uploadDocuments(int userId, File cnicFile, File certificateFile) async {
    if (useRealApi) {
      try {
        var request = http.MultipartRequest(
          'POST',
          Uri.parse(ApiConfig.getFullUrl(ApiConfig.uploadDocuments)),
        );
        request.fields['userId'] = userId.toString();
        request.files.add(await http.MultipartFile.fromPath('cnicImage', cnicFile.path));
        request.files.add(await http.MultipartFile.fromPath('certificateImage', certificateFile.path));

        var response = await request.send();
        var responseData = await response.stream.bytesToString();

        if (response.statusCode == 200) {
          return json.decode(responseData);
        } else {
          throw Exception('Failed to upload documents');
        }
      } catch (e) {
        throw Exception(_cleanErrorMessage(e.toString()));
      }
    } else {
      await Future.delayed(const Duration(seconds: 2));
      return {
        'id': 1,
        'verificationStatus': 'PENDING',
        'message': 'Documents uploaded successfully'
      };
    }
  }

  // ============ STUDENT PROFILE APIS ============

  static Future<Map<String, dynamic>> createStudentProfile(Map<String, dynamic> data) async {
    if (useRealApi) {
      try {
        final response = await http.post(
          Uri.parse(ApiConfig.getFullUrl(ApiConfig.studentProfile)),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(data),
        );

        if (response.statusCode == 200) {
          return json.decode(response.body);
        } else {
          final errorData = json.decode(response.body);
          String errorMessage = errorData['error'] ?? 'Failed to create student profile';
          // Clean the error message
          errorMessage = _cleanErrorMessage(errorMessage);
          throw Exception(errorMessage);
        }
      } catch (e) {
        throw Exception(_cleanErrorMessage(e.toString()));
      }
    } else {
      await Future.delayed(const Duration(seconds: 1));
      return {'id': 1};
    }
  }

  static Future<Map<String, dynamic>> uploadStudentImage(int profileId, String imagePath) async {
    if (useRealApi) {
      try {
        var request = http.MultipartRequest(
          'POST',
          Uri.parse(ApiConfig.getFullUrl(ApiConfig.uploadStudentImage)),
        );
        request.fields['studentProfileId'] = profileId.toString();
        request.files.add(await http.MultipartFile.fromPath('profileImage', imagePath));

        var response = await request.send();
        var responseData = await response.stream.bytesToString();

        if (response.statusCode == 200) {
          return json.decode(responseData);
        } else {
          throw Exception('Failed to upload student image');
        }
      } catch (e) {
        throw Exception(_cleanErrorMessage(e.toString()));
      }
    } else {
      await Future.delayed(const Duration(seconds: 1));
      return {'profilePictureUrl': '/uploads/mock-student-image.jpg'};
    }
  }

  // ============ LOGOUT ============

  static Future<void> logout() async {
    if (useRealApi) {
      try {
        await http.post(
          Uri.parse(ApiConfig.getFullUrl(ApiConfig.logout)),
          headers: await _getHeaders(),
        );
      } finally {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.clear();
      }
    } else {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    }
  }
}