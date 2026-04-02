import 'dart:convert';

class ApiMapper {
  // Login Response: Backend → Frontend
  static Map<String, dynamic> mapLoginResponse(Map<String, dynamic> backend) {
    return {
      'id': backend['id'],
      'profileId': backend['profileId'],
      'email': backend['email'],
      'role': backend['role'],
      'accountStatus': backend['accountStatus'],
      'registrationStep': backend['registrationStep'],
      'message': backend['message'],
      'redirectUrl': backend['redirectUrl'],
    };
  }

  // Register Request: Frontend → Backend
  static Map<String, dynamic> mapRegisterRequest(String email, String password, String role) {
    return {
      'email': email,
      'password': password,
      'role': role.toUpperCase(),  // "Tutor" → "TUTOR"
    };
  }

  // Register Response: Backend → Frontend
  static Map<String, dynamic> mapRegisterResponse(Map<String, dynamic> backend) {
    return {
      'id': backend['id'],
      'email': backend['email'],
      'role': backend['role'],
      'accountStatus': backend['accountStatus'],
      'registrationStep': backend['registrationStep'],
    };
  }

  // ============ TUTOR PROFILE MAPPING ============
  static Map<String, dynamic> mapTutorProfileRequest(Map<String, dynamic> frontendData) {
    return {
      'userId': frontendData['userId'],
      'firstName': frontendData['firstName'],
      'lastName': frontendData['lastName'],
      'phoneNumber': frontendData['phoneNumber'],
      'headline': frontendData['headline'] ?? '',
      'gender': frontendData['gender'],
      'dateOfBirth': frontendData['dateOfBirth'],
      'location': frontendData['location'],
      'universityName': frontendData['universityName'],
      'collegeName': frontendData['collegeName'],
      'workExperience': frontendData['workExperience'] ?? '',
    };
  }

  static Map<String, dynamic> mapTutorProfileResponse(Map<String, dynamic> backendResponse) {
    return {
      'id': backendResponse['id'],
      'userId': backendResponse['user']['id'],
      'firstName': backendResponse['firstName'],
      'lastName': backendResponse['lastName'],
      'phoneNumber': backendResponse['phoneNumber'],
      'headline': backendResponse['headline'],
      'profilePictureUrl': backendResponse['profilePictureUrl'],
      'gender': backendResponse['gender'],
      'dateOfBirth': backendResponse['dateOfBirth'],
      'location': backendResponse['location'],
      'universityName': backendResponse['universityName'],
      'collegeName': backendResponse['collegeName'],
      'workExperience': backendResponse['workExperience'],
    };
  }

}