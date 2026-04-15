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


  // ============ COURSE MAPPING ============

// Helper method to map display category to backend enum
  static String _mapCategoryToBackend(String? displayCategory) {
    if (displayCategory == null) return '';

    switch (displayCategory) {
      case "Matric":
      case "MATRIC":
        return "MATRIC";
      case "Intermediate":
      case "INTERMEDIATE":
        return "INTERMEDIATE";
      case "O Level":
      case "O_LEVEL":
        return "O_LEVEL";
      case "A Level":
      case "A_LEVEL":
        return "A_LEVEL";
      case "Entrance Test":
      case "ENTRY_TEST":
        return "ENTRY_TEST";
      default:
        return displayCategory.toUpperCase().replaceAll(' ', '_');
    }
  }

// Helper method to map backend enum to display category
  static String _mapCategoryToDisplay(String? backendCategory) {
    if (backendCategory == null) return '';

    switch (backendCategory) {
      case "MATRIC":
        return "Matric";
      case "INTERMEDIATE":
        return "Intermediate";
      case "O_LEVEL":
        return "O Level";
      case "A_LEVEL":
        return "A Level";
      case "ENTRY_TEST":
        return "Entrance Test";
      default:
        return backendCategory;
    }
  }

// Helper method to map display teaching mode to backend enum
  static String _mapTeachingModeToBackend(String? displayMode) {
    if (displayMode == null) return '';

    switch (displayMode) {
      case "Online":
      case "ONLINE":
        return "ONLINE";
      case "Student Home":
      case "STUDENT_HOME":
        return "STUDENT_HOME";
      case "Tutor Home":
      case "TUTOR_HOME":
        return "TUTOR_HOME";
      default:
        return displayMode.toUpperCase().replaceAll(' ', '_');
    }
  }

// Helper method to map backend enum to display teaching mode
  static String _mapTeachingModeToDisplay(String? backendMode) {
    if (backendMode == null) return '';

    switch (backendMode) {
      case "ONLINE":
        return "Online";
      case "STUDENT_HOME":
        return "Student Home";
      case "TUTOR_HOME":
        return "Tutor Home";
      default:
        return backendMode;
    }
  }

// Helper method to map day to backend format
  static String _mapDayToBackend(String? day) {
    if (day == null) return '';
    return day.toUpperCase();
  }

// Helper method to map backend day to display format
  static String _mapDayToDisplay(String? backendDay) {
    if (backendDay == null) return '';
    // Capitalize first letter, rest lowercase
    return backendDay.substring(0, 1).toUpperCase() +
        backendDay.substring(1).toLowerCase();
  }

// COURSE REQUEST MAPPING (Frontend → Backend)
  static Map<String, dynamic> mapCourseRequest(Map<String, dynamic> frontendData) {
    String? category = frontendData['category'];
    String? teachingMode = frontendData['teachingMode'];
    String? fromDay = frontendData['fromDay'];
    String? toDay = frontendData['toDay'];

    return {
      'tutorProfileId': frontendData['tutorProfileId'],
      'about': frontendData['about'],
      'subject': frontendData['subject'],
      'category': _mapCategoryToBackend(category),
      'teachingMode': _mapTeachingModeToBackend(teachingMode),
      'location': frontendData['location'],
      'fromDay': _mapDayToBackend(fromDay),
      'toDay': _mapDayToBackend(toDay),
      'startTime': frontendData['startTime'],
      'endTime': frontendData['endTime'],
      'classesPerMonth': frontendData['classesPerMonth'],
      'price': frontendData['price'],
    };
  }

// COURSE RESPONSE MAPPING (Backend → Frontend)
  static Map<String, dynamic> mapCourseResponse(Map<String, dynamic> backendResponse) {
    return {
      'id': backendResponse['id'],
      'tutorProfileId': backendResponse['tutorProfileId'],
      'tutorName': backendResponse['tutorName'],
      'about': backendResponse['about'],
      'subject': backendResponse['subject'],
      'category': _mapCategoryToDisplay(backendResponse['category']),
      'teachingMode': _mapTeachingModeToDisplay(backendResponse['teachingMode']),
      'location': backendResponse['location'],
      'startTime': backendResponse['startTime'],
      'endTime': backendResponse['endTime'],
      'fromDay': _mapDayToDisplay(backendResponse['fromDay']),
      'toDay': _mapDayToDisplay(backendResponse['toDay']),
      'classesPerMonth': backendResponse['classesPerMonth'],
      'price': backendResponse['price'],
      'isAvailable': backendResponse['isAvailable'],
      'averageRating': backendResponse['averageRating'] ?? 0.0,
    };
  }


  // ============ CONNECTION / BID MAPPING ============

// // Connection Response (Backend → Frontend)
//   static Map<String, dynamic> mapConnectionResponse(Map<String, dynamic> backend) {
//     return {
//       'connectionId': backend['connectionId'],
//       'courseId': backend['courseId'],
//       'subject': backend['subject'],
//       'studentId': backend['studentId'],
//       'studentName': backend['studentName'],
//       'studentImage': backend['studentImage'],
//       'studentCounterOffer': backend['studentCounterOffer'],
//       'tutorId': backend['tutorId'],
//       'tutorName': backend['tutorName'],
//       'tutorHeadline': backend['tutorHeadline'],
//       'status': backend['status'],
//       'originalPrice': backend['originalPrice'],
//       'studentBidPrice': backend['studentBidPrice'],
//       'tutorOffer': backend['tutorOffer'],
//       'agreedPrice': backend['agreedPrice'],
//       'requestedAt': backend['requestedAt'],
//     };
//   }
// In ApiMapper, update mapConnectionResponse to include studentCounterOffer
  static Map<String, dynamic> mapConnectionResponse(Map<String, dynamic> backend) {
    return {
      'connectionId': backend['connectionId'],
      'courseId': backend['courseId'],
      'subject': backend['subject'],
      'studentId': backend['studentId'],
      'studentName': backend['studentName'],
      'studentImage': backend['studentImage'],
      'studentCounterOffer': backend['studentCounterOffer'],
      'tutorCounterOffer': backend['tutorCounterOffer'],
      'tutorId': backend['tutorId'],
      'tutorName': backend['tutorName'],
      'tutorHeadline': backend['tutorHeadline'],
      'status': backend['status'],
      'originalPrice': backend['originalPrice'],
      'studentBidPrice': backend['studentCounterOffer'],
      'tutorOffer': backend['tutorCounterOffer'],
      'agreedPrice': backend['agreedPrice'],
      'requestedAt': backend['requestedAt'],
      'location': backend['location'],
      'phoneNumber': backend['phoneNumber'],
      'gender': backend['gender'],
      'studentEmail': backend['studentEmail'],
    };
  }
}