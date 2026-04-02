class ApiConfig {
  // ============ SET THIS TO CONTROL API MODE ============
  static const bool useRealApi = false;  // true = real backend, false = dummy data
  // ============ BASE URL ============
  // Change this when switching environments
  static const String baseUrl = 'http://192.168.100.10:8080'; // Android Emulator
  // static const String baseUrl = 'http://localhost:8080'; // iOS Simulator
  // static const String baseUrl = 'http://192.168.1.100:8080'; // Physical Device

  // ============ AUTHENTICATION APIS ============
  static const String login = '/api/auth/login';
  static const String logout = '/api/auth/logout';
  static const String register = '/api/register/role';
  static const String changePassword = '/api/password/change';

  // ============ PROFILE APIS ============
  static const String tutorProfile = '/api/register/tutor/profile';
  static const String studentProfile = '/api/register/student/profile';
  static const String editTutorProfile = '/api/register/tutor/profile/edit';
  static const String editStudentProfile = '/api/register/student/profile/edit';
  static const String uploadTutorImage = '/api/profile-image/upload';
  static const String uploadStudentImage = '/api/student-image/upload';
  static const String uploadDocuments = '/api/documents/upload';

  // ============ COURSE APIS ============
  static const String createCourse = '/api/courses';
  static const String updateCourse = '/api/courses';  // + /{courseId}
  static const String deleteCourse = '/api/courses';  // + /{courseId}
  static const String toggleAvailability = '/api/courses'; // + /{courseId}/toggle-availability
  static const String getTutorCourses = '/api/courses/tutor'; // + /{tutorProfileId}
  static const String getTutorCourseCards = '/api/courses/tutor'; // + /{tutorProfileId}/cards
  static const String getTutorCourseDetail = '/api/courses/tutor/detail'; // + /{courseId}
  static const String getAvailableCourses = '/api/courses/available';
  static const String searchCourses = '/api/courses/search';
  static const String getCourseForStudent = '/api/courses'; // + /{courseId}/student

  // ============ TUTOR DASHBOARD APIS ============
  static const String tutorDashboard = '/api/tutor/dashboard'; // + /{tutorId}
  static const String tutorStudents = '/api/tutor/students'; // + /{tutorId}
  static const String studentDetail = '/api/tutor/students/detail'; // + /{connectionId}
  static const String searchStudents = '/api/tutor/students'; // + /{tutorId}/search
  static const String filterStudents = '/api/tutor/students/tutor'; // + /{tutorId}/students/filter

  // ============ STUDENT DASHBOARD APIS ============
  static const String studentDashboard = '/api/student/dashboard'; // + /{studentId}
  static const String topTutors = '/api/student/top-tutors';
  static const String tutorProfileView = '/api/student/tutor'; // + /{studentId}/{tutorId}/profile

  // ============ FAVORITE APIS ============
  static const String addFavorite = '/api/student/favorites'; // + /{studentId}/add/{courseId}
  static const String removeFavorite = '/api/student/favorites'; // + /{studentId}/remove/{courseId}
  static const String getFavorites = '/api/student/favorites'; // + /{studentId}
  static const String checkFavorite = '/api/student/favorites'; // + /{studentId}/check/{courseId}

  // ============ RATING APIS ============
  static const String submitRating = '/api/student/ratings/submit';
  static const String updateRating = '/api/student/ratings'; // + /{ratingId}
  static const String getCourseReviews = '/api/student/ratings/course'; // + /{courseId}/reviews
  static const String getTutorRatingSummary = '/api/tutor/ratings'; // + /{tutorId}/summary
  static const String getTutorFilterOptions = '/api/tutor/ratings'; // + /{tutorId}/filter-options
  static const String getTopCourses = '/api/tutor/ratings'; // + /{tutorId}/top-courses
  static const String getReviewDetail = '/api/tutor/ratings/review'; // + /{reviewId}

  // ============ CONNECTION APIS ============
  static const String requestConnection = '/api/connections/request';
  static const String tutorRespond = '/api/connections'; // + /{connectionId}/tutor-respond
  static const String studentRespond = '/api/connections'; // + /{connectionId}/student-respond
  static const String disconnect = '/api/connections'; // + /{connectionId}/disconnect
  static const String studentCancel = '/api/connections'; // + /{connectionId}/student-cancel
  static const String getStudentConnections = '/api/connections/student'; // + /{studentId}
  static const String getTutorConnections = '/api/connections/tutor'; // + /{tutorId}
  static const String getPendingRequests = '/api/connections/tutor'; // + /{tutorId}/pending
  static const String getNegotiations = '/api/connections/tutor'; // + /{tutorId}/negotiations
  static const String getTutorBids = '/api/connections/tutor'; // + /{tutorId}/bids-with-cards
  static const String getStudentBids = '/api/connections/student'; // + /{studentId}/bids-with-details

  // ============ BLOCK/REPORT APIS ============
  static const String blockTutor = '/api/student/block'; // + /{studentId}/block/{tutorId}
  static const String unblockTutor = '/api/student/block'; // + /{studentId}/unblock/{tutorId}
  static const String getBlockedList = '/api/student/block'; // + /{studentId}/list
  static const String checkBlocked = '/api/student/block'; // + /{studentId}/check/{tutorId}
  static const String reportTutor = '/api/student/block/report';
  static const String getMyReports = '/api/student/block'; // + /{studentId}/reports

  // ============ HELPER METHODS ============
  static String getFullUrl(String endpoint) {
    return '$baseUrl$endpoint';
  }

  static String getFullUrlWithParams(String endpoint, Map<String, String> params) {
    String url = '$baseUrl$endpoint';
    if (params.isNotEmpty) {
      url += '?' + params.entries.map((e) => '${e.key}=${e.value}').join('&');
    }
    return url;
  }
}