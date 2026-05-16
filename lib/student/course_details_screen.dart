import 'package:flutter/material.dart';
import 'package:my_first_app/student/write_review_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'tutor_profile_screen.dart';
import 'connection_screen.dart';
import 'reviews_screen.dart';
import '../services/course_service.dart';
import '../services/rating_service.dart';
import '../services/connection_service.dart';
import '../config/api_config.dart';

// --- COURSE COLORS (Same as other screens) ---
class CourseColors {
  static const List<Color> colors = [
    Color(0xFF1A1A2E), // Dark Navy
    Color(0xFF16213E), // Deep Navy
    Color(0xFF0F3460), // Dark Blue
    Color(0xFF8B1E3F), // Dark Crimson
    Color(0xFF2C3E50), // Dark Slate
    Color(0xFF1B4F72), // Deep Teal
    Color(0xFF145A32), // Dark Green
    Color(0xFF7B2C3E), // Deep Maroon
    Color(0xFF4A235A), // Dark Violet
    Color(0xFF1C2833), // Almost Black Blue
    Color(0xFF6E2C00), // Dark Orange-Brown
    Color(0xFF0B5345), // Dark Cyan-Green
    Color(0xFF424949), // Dark Gray
    Color(0xFF5D4037), // Dark Brown
    Color(0xFF283747), // Dark Steel Blue
    Color(0xFF7E5109), // Dark Gold
    Color(0xFF4A4A4A), // Dark Gray
    Color(0xFF3E2723), // Very Dark Brown
    Color(0xFF1A237E), // Deep Indigo
  ];

  static Color getCourseColor(int courseId) {
    return colors[courseId % colors.length];
  }
}

class CourseDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> courseData;

  const CourseDetailsScreen({super.key, required this.courseData});

  @override
  State<CourseDetailsScreen> createState() => _CourseDetailsScreenState();
}

class _CourseDetailsScreenState extends State<CourseDetailsScreen> {
  bool _isLoading = false;
  bool _isLoadingReviews = false;
  bool _isExpanded = false;
  final TextEditingController _offerController = TextEditingController();
  String? _offerError;
  String? _offerHelperText;

  int _studentId = 0;
  int _courseId = 0;

  // API Data
  Map<String, dynamic> _courseDetails = {};
  List<Map<String, dynamic>> _reviews = [];

  // Course Details
  String _subject = '';
  String _category = '';
  String _price = '';
  double _priceValue = 0.0;
  String _rating = '0.0';
  int _totalRatings = 0;
  String _location = '';
  String _teachingMode = '';
  String _about = '';
  int _classesPerMonth = 0;
  String _startTime = '';
  String _endTime = '';
  String _fromDay = '';
  String _toDay = '';
  String _tutorName = '';
  int _tutorId = 0;
  String _tutorImage = '';
  String _tutorHeadline = '';
  bool _isBlocked = false;

  // Connection Status
  String _connectionStatus = 'NONE';
  int? _connectionId;
  bool _isSendingRequest = false;
  bool _isSendingOffer = false;
  bool _isDisconnecting = false;
  String _statusMessage = '';

  @override
  void initState() {
    super.initState();
    _loadStudentId();
  }

  Future<void> _loadStudentId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _studentId = prefs.getInt('profileId') ?? 0;
      _courseId = widget.courseData['id'] ?? widget.courseData['courseId'] ?? 0;
      _tutorId =
          widget.courseData['tutorId'] ?? widget.courseData['tutor_id'] ?? 0;
      _tutorName =
          widget.courseData['tutorName'] ?? widget.courseData['name'] ??
              'Tutor Name';
      _tutorImage = widget.courseData['tutorImage'] ??
          widget.courseData['profilePictureUrl'] ?? '';
      _tutorHeadline = widget.courseData['tutorHeadline'] ?? 'Expert Tutor';

      _connectionId = null;
      _connectionStatus = 'NONE';
      _statusMessage = '';
      _isSendingRequest = false;
      _isSendingOffer = false;
      _isBlocked = false;
    });

    await Future.wait([
      _loadCourseDetails(),
      _loadCourseReviews(),
    ]);
  }

  Future<void> _loadCourseDetails() async {
    setState(() => _isLoading = true);

    try {
      final response = await CourseService.getCourseForStudent(
          _courseId, _studentId);

      if (!mounted) return;
      _processCourseDetails(response);
    } catch (e) {
      if (mounted) {
        _showErrorDialog(e.toString().replaceFirst('Exception: ', ''));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _processCourseDetails(Map<String, dynamic> course) {
    _courseDetails = course;
    _subject = course['subject']?.toString() ?? widget.courseData['sub'] ??
        'Course Title';
    _category = _formatCategory(
        course['category']?.toString() ?? widget.courseData['category'] ??
            'General');

    if (course['price'] is int) {
      _priceValue = (course['price'] as int).toDouble();
    } else if (course['price'] is double) {
      _priceValue = course['price'] as double;
    } else if (course['price'] is String) {
      _priceValue = double.tryParse(course['price']) ?? 0.0;
    }
    _price = '${_priceValue.toStringAsFixed(0)} PKR';

    _rating =
        course['averageRating']?.toString() ?? widget.courseData['rating'] ??
            '0.0';
    _totalRatings = course['totalRatings'] ?? 0;
    _location =
        course['location']?.toString() ?? widget.courseData['location'] ??
            'Online';
    _teachingMode = _formatTeachingMode(course['teachingMode']?.toString() ??
        widget.courseData['teachingMode'] ?? 'Online');
    _about = course['about']?.toString() ?? widget.courseData['about'] ??
        'Master concepts with step-by-step guidance!';
    _classesPerMonth = course['classesPerMonth'] ?? 8;
    _startTime = course['startTime']?.toString() ?? '6:00 PM';
    _endTime = course['endTime']?.toString() ?? '8:00 PM';
    _fromDay = _formatDay(course['fromDay']?.toString() ?? 'Monday');
    _toDay = _formatDay(course['toDay']?.toString() ?? 'Friday');
    _tutorName =
        course['tutorName']?.toString() ?? widget.courseData['tutorName'] ??
            'Tutor Name';
    _tutorId = course['tutorId'] ?? widget.courseData['tutorId'] ?? 0;
    _tutorImage = course['tutorImage']?.toString() ?? '';
    _tutorHeadline = course['tutorHeadline']?.toString() ?? 'Expert Tutor';
    _isBlocked = course['isBlocked'] == true;

    setState(() {
      if (course['connectionStatus'] != null && course['connectionStatus']
          .toString()
          .isNotEmpty) {
        _connectionStatus = course['connectionStatus'].toString();
        _connectionId = course['connectionId'];
      } else {
        _connectionStatus = 'NONE';
        _connectionId = null;
      }
      _updateStatusMessage();
    });
  }

  Future<void> _loadCourseReviews() async {
    setState(() => _isLoadingReviews = true);

    try {
      final response = await RatingService.getCourseReviews(_courseId);
      if (!mounted) return;
      _processReviews(response);
    } catch (e) {
      // Reviews are not critical
    } finally {
      if (mounted) {
        setState(() => _isLoadingReviews = false);
      }
    }
  }

  void _processReviews(List<dynamic> reviews) {
    _reviews = reviews.map((review) {
      return {
        'studentName': review['studentName']?.toString() ?? 'Anonymous',
        'studentImage': review['studentImage']?.toString() ?? '',
        'comment': review['review']?.toString() ??
            review['comment']?.toString() ?? '',
        'rating': (review['rating'] as num?)?.toDouble() ?? 0.0,
        'createdAt': review['createdAt']?.toString() ?? '',
      };
    }).toList();
  }

  void _updateStatusMessage() {
    if (_isBlocked) {
      _statusMessage =
      'You have blocked this tutor. Please unblock to send request or offer.';
      return;
    }

    switch (_connectionStatus) {
      case 'PENDING':
        _statusMessage = 'Request pending - Waiting for tutor response';
        break;
      case 'NEGOTIATING':
        _statusMessage = 'Offer sent - Waiting for tutor response';
        break;
      case 'CONFIRMED':
        _statusMessage = 'Connected - You are now connected with this tutor';
        break;
      case 'CANCELLED':
        _statusMessage = 'Request cancelled - You can send a new request';
        break;
      case 'DISCONNECTED':
        _statusMessage = 'Disconnected - You can send a new request';
        break;
      case 'REJECTED':
        _statusMessage = 'Offer rejected. You can send a new request or offer.';
        break;
      default:
        _statusMessage = '';
    }
  }

  bool get _isConnectButtonEnabled {
    // If tutor is blocked, buttons are disabled
    if (_isBlocked) return false;

    return (_connectionStatus == 'NONE' ||
        _connectionStatus == 'CANCELLED' ||
        _connectionStatus == 'DISCONNECTED' ||
        _connectionStatus == 'REJECTED') &&
        !_isSendingRequest &&
        !_isSendingOffer;
  }

  bool get _isOfferButtonEnabled {
    // If tutor is blocked, buttons are disabled
    if (_isBlocked) return false;

    return (_connectionStatus == 'NONE' ||
        _connectionStatus == 'CANCELLED' ||
        _connectionStatus == 'DISCONNECTED' ||
        _connectionStatus == 'REJECTED') &&
        !_isSendingRequest &&
        !_isSendingOffer;
  }

  bool get _showCancelButton {
    return _connectionStatus == 'PENDING' && !_isBlocked;
  }

  bool get _showDisconnectButton {
    return _connectionStatus == 'CONFIRMED' && !_isBlocked;
  }

  String get _connectButtonText {
    if (_isBlocked) return 'Tutor Blocked';

    switch (_connectionStatus) {
      case 'PENDING':
        return 'Request Pending';
      case 'NEGOTIATING':
        return 'Offer Sent';
      case 'CONFIRMED':
        return 'Connected';
      case 'CANCELLED':
        return 'Connect Request';
      case 'DISCONNECTED':
        return 'Connect Request';
      case 'REJECTED':
        return 'Connect Request';
      default:
        return 'Connect Request';
    }
  }

  void _navigateToConnectionScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const ConnectionScreen(),
      ),
    );
  }

  Future<void> _sendConnectionRequest() async {
    setState(() {
      _isSendingRequest = true;
    });

    _showLoadingPopup("Sending connection request...");

    try {
      final result = await ConnectionService.requestConnection(
        courseId: _courseId,
        studentId: _studentId,
      );

      setState(() {
        _connectionStatus = result['status'];
        _connectionId = result['connectionId'];
        _updateStatusMessage();
        _isSendingRequest = false;
      });

      Navigator.pop(context);
      _showSuccessPopup("Request Sent",
          "Your connection request has been sent to the tutor.");

      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          _navigateToConnectionScreen();
        }
      });
    } catch (e) {
      Navigator.pop(context);
      setState(() {
        _isSendingRequest = false;
      });
      _showErrorDialog(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<void> _sendOffer() async {
    final String offerText = _offerController.text.trim();

    if (offerText.isEmpty) {
      setState(() {
        _offerError = "Please enter an amount";
        _offerHelperText = "Amount cannot be empty";
      });
      return;
    }

    final int? offerAmount = int.tryParse(offerText);

    if (offerAmount == null) {
      setState(() {
        _offerError = "Please enter a valid number";
        _offerHelperText = "Enter numeric value only";
      });
      return;
    }

    if (offerAmount < 100) {
      setState(() {
        _offerError = "Minimum offer is 100 PKR";
        _offerHelperText = "Your offer must be at least 100 PKR";
      });
      return;
    }

    if (offerAmount >= _priceValue) {
      setState(() {
        _offerError = "Offer too high";
        _offerHelperText =
        "Offer must be less than ${_priceValue.toStringAsFixed(0)} PKR";
      });
      return;
    }

    setState(() {
      _offerError = null;
      _offerHelperText = null;
      _isSendingOffer = true;
    });

    Navigator.pop(context);

    setState(() {
      _statusMessage = "Sending your offer...";
    });

    try {
      final result = await ConnectionService.requestConnectionWithOffer(
        courseId: _courseId,
        studentId: _studentId,
        suggestedPrice: offerAmount.toDouble(),
      );

      setState(() {
        _connectionStatus = result['status'];
        _connectionId = result['connectionId'];
        _updateStatusMessage();
        _isSendingOffer = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Offer sent successfully!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          _navigateToConnectionScreen();
        }
      });
    } catch (e) {
      setState(() {
        _isSendingOffer = false;
        _updateStatusMessage();
      });
      _showErrorDialog(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<void> _cancelRequest() async {
    if (_connectionId == null) return;

    setState(() {
      _isSendingRequest = true;
    });

    try {
      await ConnectionService.studentCancelPending(_connectionId!);

      await _loadCourseDetails();
      await _loadCourseReviews();

      setState(() {
        _connectionStatus = 'NONE';
        _connectionId = null;
        _updateStatusMessage();
        _isSendingRequest = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Request cancelled successfully'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      setState(() {
        _isSendingRequest = false;
      });
      String errorMsg = e.toString();
      if (errorMsg.startsWith('Exception: ')) {
        errorMsg = errorMsg.substring(11);
      }
      _showErrorDialog(errorMsg);
    }
  }

  Future<void> _disconnect() async {
    if (_connectionId == null) return;

    setState(() {
      _isDisconnecting = true;
    });

    try {
      await ConnectionService.studentDisconnect(
          _connectionId!, disconnectedBy: "STUDENT");

      await _loadCourseDetails();
      await _loadCourseReviews();

      setState(() {
        _connectionStatus = 'DISCONNECTED';
        _connectionId = null;
        _updateStatusMessage();
        _isDisconnecting = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Disconnected successfully'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      setState(() {
        _isDisconnecting = false;
      });
      String errorMsg = e.toString();
      if (errorMsg.startsWith('Exception: ')) {
        errorMsg = errorMsg.substring(11);
      }
      _showErrorDialog(errorMsg);
    }
  }

  void _showCancelConfirmationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20)),
          title: const Text(
            "Cancel Request",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.black),
          ),
          content: const Text(
            "Are you sure you want to cancel this request?",
            style: TextStyle(fontSize: 14, color: Colors.black87),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "No",
                style: TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _cancelRequest();
              },
              child: const Text(
                "Yes, Cancel",
                style: TextStyle(color: Colors.red, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showDisconnectConfirmationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20)),
          title: const Text(
            "Disconnect",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.black),
          ),
          content: const Text(
            "Are you sure you want to disconnect from this tutor? You will lose access to this connection.",
            style: TextStyle(fontSize: 14, color: Colors.black87),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "No",
                style: TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _disconnect();
              },
              child: const Text(
                "Yes, Disconnect",
                style: TextStyle(color: Colors.red, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  void _navigateToReviewScreen() {
    final Map<String, dynamic> courseData = {
      'id': _courseId,
      'subject': _subject,
      'tutorName': _tutorName,
      'rating': _rating,
      'totalRatings': _totalRatings,
    };

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReviewsScreen(courseData: courseData),
      ),
    );
  }

  String _formatText(String? text, {bool capitalizeWords = true}) {
    if (text == null || text.isEmpty) return '';
    String formatted = text.replaceAll('_', ' ');
    if (formatted.toLowerCase() == 'o level') return 'O Level';
    if (formatted.toLowerCase() == 'a level') return 'A Level';
    if (formatted.toLowerCase() == 'student home') return "Student's Home";
    if (formatted.toLowerCase() == 'tutor home') return "Tutor's Home";
    if (formatted.toLowerCase() == 'entrance test') return 'Entrance Test';

    if (capitalizeWords) {
      List<String> words = formatted.split(' ');
      for (int i = 0; i < words.length; i++) {
        if (words[i].isNotEmpty) {
          words[i] =
              words[i][0].toUpperCase() + words[i].substring(1).toLowerCase();
        }
      }
      return words.join(' ');
    }
    return formatted;
  }

  String _formatCategory(String? category) {
    if (category == null || category.isEmpty) return 'General';
    switch (category.toUpperCase()) {
      case 'MATRIC':
        return 'Matric';
      case 'INTERMEDIATE':
        return 'Intermediate';
      case 'O_LEVEL':
        return 'O Level';
      case 'A_LEVEL':
        return 'A Level';
      case 'ENTRY_TEST':
        return 'Entrance Test';
      default:
        return _formatText(category);
    }
  }

  String _formatTeachingMode(String? mode) {
    if (mode == null || mode.isEmpty) return 'Online';
    switch (mode.toUpperCase()) {
      case 'ONLINE':
        return 'Online';
      case 'STUDENT_HOME':
        return "Student's Home";
      case 'TUTOR_HOME':
        return "Tutor's Home";
      default:
        return _formatText(mode);
    }
  }

  String _formatDay(String? day) {
    if (day == null || day.isEmpty) return '';
    return _formatText(day);
  }

  void _navigateToTutorProfile() {
    if (_tutorId == 0) {
      _showErrorDialog('Tutor information not available');
      return;
    }

    final Map<String, dynamic> tutorData = {
      'id': _tutorId,
      'tutorId': _tutorId,
      'name': _tutorName,
      'tutorName': _tutorName,
      'sub': _subject,
      'tutorHeadline': _tutorHeadline,
      'rating': _rating,
      'averageRating': double.tryParse(_rating) ?? 0.0,
      'location': _location,
      'tutorLocation': _location,
      'tutorImage': _tutorImage,
      'profilePictureUrl': _tutorImage,
    };

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TutorProfileScreen(tutorData: tutorData),
      ),
    );
  }

  void _showConfirmationPopup() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30)),
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 80,
                  width: 80,
                  decoration: const BoxDecoration(
                      color: Colors.orange, shape: BoxShape.circle),
                  child: const Icon(
                      Icons.question_mark, color: Colors.white, size: 45),
                ),
                const SizedBox(height: 20),
                const Text("Confirm Request", style: TextStyle(fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1C43))),
                const SizedBox(height: 15),
                const Text(
                    "Are you sure you want to send a connection request to this tutor?",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.grey, fontSize: 14, height: 1.5)),
                const SizedBox(height: 25),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE5E7EB),
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25))),
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Cancel", style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25))),
                        onPressed: () {
                          Navigator.pop(context);
                          _sendConnectionRequest();
                        },
                        child: const Text("Send Request", style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSendOfferDialog(BuildContext context) {
    _offerController.clear();
    _offerError = null;
    _offerHelperText = null;

    final int maxOffer = _priceValue.toInt() - 1;
    final int minOffer = 100;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            void updateError(String? error, String? helper) {
              setDialogState(() {
                _offerError = error;
                _offerHelperText = helper;
              });
            }

            void validateAmount(String value) {
              final String text = value.trim();
              if (text.isEmpty) {
                updateError("Please enter an amount", "Amount cannot be empty");
                return;
              }
              final int? amount = int.tryParse(text);
              if (amount == null) {
                updateError(
                    "Please enter a valid number", "Enter numeric value only");
                return;
              }
              if (amount < minOffer) {
                updateError("Minimum offer is $minOffer PKR",
                    "Your offer must be at least $minOffer PKR");
                return;
              }
              if (amount > maxOffer) {
                updateError("Offer too high",
                    "Offer must be less than ${_priceValue.toStringAsFixed(
                        0)} PKR");
                return;
              }
              updateError(null, null);
            }

            return Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24)),
              backgroundColor: Colors.white,
              child: Container(
                width: MediaQuery
                    .of(context)
                    .size
                    .width * 0.9,
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Current Price", style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                              fontWeight: FontWeight.w500)),
                          Text(_price, style: const TextStyle(fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 12),
                      decoration: BoxDecoration(color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12)),
                      child: Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                                color: Colors.amber.shade100,
                                borderRadius: BorderRadius.circular(8)),
                            child: const Center(child: Text(
                                "💰", style: TextStyle(fontSize: 16))),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Offer Range", style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey)),
                                const SizedBox(height: 2),
                                Text(
                                    "Min: $minOffer PKR | Max: ${maxOffer} PKR",
                                    style: const TextStyle(fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black87)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Enter Your Offer", style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87)),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: _offerError != null ? Colors.red : Colors
                                    .grey.shade300,
                                width: _offerError != null ? 1.5 : 1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 14),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(12),
                                      bottomLeft: Radius.circular(12)),
                                ),
                                child: const Text("PKR", style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87)),
                              ),
                              Expanded(
                                child: TextField(
                                  controller: _offerController,
                                  keyboardType: TextInputType.number,
                                  style: const TextStyle(fontSize: 16,
                                      fontWeight: FontWeight.w500),
                                  onChanged: (value) =>
                                      setDialogState(() =>
                                          validateAmount(value)),
                                  decoration: const InputDecoration(
                                    hintText: "Enter amount",
                                    hintStyle: TextStyle(
                                        color: Colors.grey, fontSize: 14),
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 14),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (_offerHelperText != null && _offerError == null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8, left: 4),
                            child: Row(
                              children: [
                                Icon(Icons.info_outline, size: 12,
                                    color: Colors.blue.shade600),
                                const SizedBox(width: 4),
                                Expanded(child: Text(_offerHelperText!,
                                    style: TextStyle(fontSize: 11,
                                        color: Colors.blue.shade600))),
                              ],
                            ),
                          ),
                        if (_offerError != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8, left: 4),
                            child: Row(
                              children: [
                                Icon(Icons.error_outline, size: 12,
                                    color: Colors.red.shade600),
                                const SizedBox(width: 4),
                                Expanded(child: Text(_offerError!,
                                    style: TextStyle(fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.red.shade600))),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.grey.shade700,
                              side: BorderSide(color: Colors.grey.shade300),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text("Cancel", style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w600)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _offerError == null &&
                                _offerController.text
                                    .trim()
                                    .isNotEmpty
                                ? () {
                              final offerAmount = int.tryParse(
                                  _offerController.text.trim());
                              if (offerAmount != null && offerAmount > 0) {
                                Navigator.pop(context);
                                _sendOffer();
                              }
                            }
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text("Send Offer", style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showLoadingPopup(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30)),
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(
                    color: Colors.black, strokeWidth: 3),
                const SizedBox(height: 20),
                Text(message, style: const TextStyle(
                    fontSize: 16, color: Colors.black87)),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSuccessPopup(String title, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        Future.delayed(const Duration(seconds: 2), () {
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          }
        });
        return Dialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30)),
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 100,
                  width: 100,
                  decoration: const BoxDecoration(
                      color: Color(0xFF22AD19), shape: BoxShape.circle),
                  child: const Icon(Icons.check, color: Colors.white, size: 60),
                ),
                const SizedBox(height: 30),
                Text(title, style: const TextStyle(fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1C43))),
                const SizedBox(height: 15),
                Text(message, textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: Colors.grey, fontSize: 14, height: 1.5)),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15)),
            content: Text(message, textAlign: TextAlign.center),
            actions: [
              Center(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("OK", style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
    );
  }

  Color get _courseColor {
    return CourseColors.getCourseColor(_courseId);
  }

  IconData _getTeachingModeIcon(String mode) {
    final String lowerMode = mode.toLowerCase();
    if (lowerMode.contains('online')) return Icons.wifi;
    if (lowerMode.contains('student')) return Icons.home;
    if (lowerMode.contains('tutor')) return Icons.location_city;
    return Icons.school;
  }

  String _formatTime(String? timeStr) {
    if (timeStr == null || timeStr.isEmpty) return "N/A";
    try {
      if (timeStr.toUpperCase().contains('AM') ||
          timeStr.toUpperCase().contains('PM')) {
        return timeStr;
      }
      List<String> parts = timeStr.split(':');
      if (parts.isEmpty) return "N/A";
      int hour = int.tryParse(parts[0]) ?? 0;
      int minute = parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0;
      String period = hour >= 12 ? "PM" : "AM";
      int hour12 = hour % 12;
      if (hour12 == 0) hour12 = 12;
      String minuteStr = minute.toString().padLeft(2, '0');
      return "$hour12:$minuteStr $period";
    } catch (e) {
      return timeStr;
    }
  }

  int _parseHour(String time) {
    try {
      String cleanTime = time.toUpperCase().replaceAll('AM', '').replaceAll(
          'PM', '').trim();
      List<String> parts = cleanTime.split(':');
      return int.parse(parts[0]);
    } catch (e) {
      return 0;
    }
  }

  int _parseMinute(String time) {
    try {
      String cleanTime = time.toUpperCase().replaceAll('AM', '').replaceAll(
          'PM', '').trim();
      List<String> parts = cleanTime.split(':');
      if (parts.length > 1) {
        return int.parse(parts[1]);
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }

  String _calculateTotalHours(String startTime, String endTime) {
    try {
      int startHour = _parseHour(startTime);
      int startMinute = _parseMinute(startTime);
      int endHour = _parseHour(endTime);
      int endMinute = _parseMinute(endTime);

      bool startIsPM = startTime.toUpperCase().contains('PM');
      bool endIsPM = endTime.toUpperCase().contains('PM');

      if (startIsPM && startHour != 12) startHour += 12;
      if (!startIsPM && startHour == 12) startHour = 0;
      if (endIsPM && endHour != 12) endHour += 12;
      if (!endIsPM && endHour == 12) endHour = 0;

      int startTotalMinutes = startHour * 60 + startMinute;
      int endTotalMinutes = endHour * 60 + endMinute;
      int totalMinutes = endTotalMinutes - startTotalMinutes;

      if (totalMinutes <= 0) return "N/A";

      int hours = totalMinutes ~/ 60;
      int minutes = totalMinutes % 60;

      if (hours == 0) {
        return "$minutes min";
      } else if (minutes == 0) {
        return "$hours hr";
      } else {
        return "$hours hr $minutes min";
      }
    } catch (e) {
      return "N/A";
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '';
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays > 365) {
        return '${(difference.inDays / 365).floor()} year${(difference.inDays /
            365).floor() > 1 ? 's' : ''} ago';
      } else if (difference.inDays > 30) {
        return '${(difference.inDays / 30).floor()} month${(difference.inDays /
            30).floor() > 1 ? 's' : ''} ago';
      } else if (difference.inDays > 0) {
        return '${difference.inDays} day${difference.inDays > 1
            ? 's'
            : ''} ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} hour${difference.inHours > 1
            ? 's'
            : ''} ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} minute${difference.inMinutes > 1
            ? 's'
            : ''} ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final double bgHeight = MediaQuery
        .of(context)
        .size
        .height * 0.35;
    final double bottomPadding = MediaQuery
        .of(context)
        .padding
        .bottom;

    final String totalHours = _calculateTotalHours(_startTime, _endTime);
    final teachingIcon = _getTeachingModeIcon(_teachingMode);

    return Scaffold(
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        onRefresh: () async {
          await _loadCourseDetails();
          await _loadCourseReviews();
        },
        color: Colors.black,
        backgroundColor: Colors.white,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    height: bgHeight,
                    width: double.infinity,
                    color: _courseColor,
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle),
                                child: const Icon(
                                    Icons.arrow_back, color: Colors.black),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: bgHeight * 0.5),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 25),
                      padding: const EdgeInsets.all(25),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: const [BoxShadow(color: Colors.black12,
                            blurRadius: 20,
                            offset: Offset(0, 10))
                        ],
                      ),
                      child: _isLoading
                          ? const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 40),
                          child: CircularProgressIndicator(color: Colors.black),
                        ),
                      )
                          : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(_subject, style: const TextStyle(
                                    fontSize: 22, fontWeight: FontWeight.bold),
                                    overflow: TextOverflow.ellipsis),
                              ),
                              const SizedBox(width: 10),
                              Row(
                                children: [
                                  const Icon(Icons.star, color: Colors.orange,
                                      size: 20),
                                  Text(" $_rating", style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                                  const SizedBox(width: 4),
                                  Text("($_totalRatings)",
                                      style: const TextStyle(
                                          fontSize: 12, color: Colors.grey)),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    const Icon(Icons.category, size: 18),
                                    const SizedBox(width: 5),
                                    Flexible(child: Text(_category,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w500),
                                        overflow: TextOverflow.ellipsis)),
                                    const SizedBox(width: 12),
                                    const Icon(Icons.access_time, size: 18),
                                    const SizedBox(width: 5),
                                    Text(totalHours, style: const TextStyle(
                                        fontWeight: FontWeight.w500)),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(_price, style: const TextStyle(fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green)),
                            ],
                          ),
                          const SizedBox(height: 25),
                          const Text("About", style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _isExpanded ? _about : (_about.length > 100
                                    ? '${_about.substring(0, 100)}...'
                                    : _about),
                                style: const TextStyle(
                                    color: Colors.grey, height: 1.5),
                              ),
                              if (_about.length > 100)
                                GestureDetector(
                                  onTap: () =>
                                      setState(() =>
                                      _isExpanded = !_isExpanded),
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text(
                                        _isExpanded ? "Read less" : "Read more",
                                        style: const TextStyle(
                                            color: Colors.blue,
                                            fontWeight: FontWeight.w500,
                                            fontSize: 14)),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Tutor", style: TextStyle(fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black)),
                    const SizedBox(height: 15),
                    GestureDetector(
                      onTap: _navigateToTutorProfile,
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 25,
                            backgroundColor: Colors.black,
                            backgroundImage: _tutorImage.isNotEmpty
                                ? NetworkImage('${ApiConfig.baseUrl}$_tutorImage')
                                : null,
                            child: _tutorImage.isEmpty
                                ? const Icon(Icons.person, color: Colors.white)
                                : null,
                          ),
                          const SizedBox(width: 15),
                          Expanded(  //  Wrap Column with Expanded to take available space
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _tutorName,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.black
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),  // ✅ Small spacing between name and headline
                                Text(
                                  _tutorHeadline.isNotEmpty ? _tutorHeadline : "Expert Tutor",
                                  style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),  //  Small spacing before arrow
                          const Icon(
                              Icons.arrow_forward_ios,
                              size: 14,
                              color: Colors.grey
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    const Text("What You'll Get", style: TextStyle(fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black)),
                    const SizedBox(height: 20),
                    _detail(
                        Icons.menu_book, "$_classesPerMonth Classes per month"),
                    _detail(Icons.access_time,
                        "${_formatTime(_startTime)} - ${_formatTime(
                            _endTime)}"),
                    _detail(Icons.calendar_month, "$_fromDay to $_toDay"),
                    _detail(teachingIcon, _teachingMode),
                    _detail(Icons.location_on, _location),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Reviews", style: TextStyle(fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black)),
                        if (_reviews.isNotEmpty)
                          TextButton(
                            onPressed: _navigateToReviewScreen,
                            child: const Text("SEE ALL", style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                                fontSize: 12)),
                          ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    _buildReviewsList(),
                    const SizedBox(height: 30),

                    // Cancel Button (for PENDING status)
                    if (_showCancelButton)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 15),
                        child: ElevatedButton(
                          onPressed: _showCancelConfirmationDialog,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            minimumSize: const Size(double.infinity, 50),
                          ),
                          child: const Text("Cancel Request", style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ),

                    // Disconnect Button (for CONFIRMED status)
                    if (_showDisconnectButton)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 15),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _isDisconnecting
                                ? null
                                : _showDisconnectConfirmationDialog,
                            icon: _isDisconnecting
                                ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                                : const Icon(
                                Icons.link_off, size: 18, color: Colors.white),
                            label: Text(
                              _isDisconnecting
                                  ? "Disconnecting..."
                                  : "Disconnect",
                              style: const TextStyle(fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              minimumSize: const Size(double.infinity, 50),
                            ),
                          ),
                        ),
                      ),

                    // Connection Status Message
                    if (_statusMessage.isNotEmpty)
                      Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: _connectionStatus == 'CONFIRMED'
                              ? Colors.green.withOpacity(0.1)
                              : (_isBlocked
                              ? Colors.red.withOpacity(0.1)
                              : (_connectionStatus == 'PENDING' ||
                              _connectionStatus == 'NEGOTIATING'
                              ? Colors.orange.withOpacity(0.1)
                              : Colors.grey.withOpacity(0.1))),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _connectionStatus == 'CONFIRMED'
                                ? Colors.green.withOpacity(0.3)
                                : (_isBlocked
                                ? Colors.red.withOpacity(0.3)
                                : (_connectionStatus == 'PENDING' ||
                                _connectionStatus == 'NEGOTIATING'
                                ? Colors.orange.withOpacity(0.3)
                                : Colors.grey.withOpacity(0.3))),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _connectionStatus == 'CONFIRMED'
                                  ? Icons.check_circle
                                  : (_isBlocked
                                  ? Icons.block
                                  : (_connectionStatus == 'PENDING'
                                  ? Icons.hourglass_empty
                                  : (_connectionStatus == 'NEGOTIATING'
                                  ? Icons.send
                                  : Icons.info))),
                              size: 20,
                              color: _connectionStatus == 'CONFIRMED'
                                  ? Colors.green
                                  : (_isBlocked
                                  ? Colors.red
                                  : (_connectionStatus == 'PENDING' ||
                                  _connectionStatus == 'NEGOTIATING'
                                  ? Colors.orange
                                  : Colors.grey)),
                            ),
                            const SizedBox(width: 10),
                            Expanded(child: Text(_statusMessage,
                                style: TextStyle(fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: _connectionStatus == 'CONFIRMED'
                                        ? Colors.green
                                        : (_isBlocked
                                        ? Colors.red
                                        : (_connectionStatus == 'PENDING' ||
                                        _connectionStatus == 'NEGOTIATING'
                                        ? Colors.orange
                                        : Colors.grey))))),
                          ],
                        ),
                      ),

                    const SizedBox(height: 5),

                    // Buttons Row
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: _isConnectButtonEnabled
                                    ? Colors.black
                                    : Colors.grey,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 16),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12))),
                            onPressed: _isConnectButtonEnabled
                                ? _showConfirmationPopup
                                : null,
                            child: Text(_isSendingRequest
                                ? "Sending..."
                                : _connectButtonText, style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: _isOfferButtonEnabled ? Colors
                                    .black : Colors.grey,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 16),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12))),
                            onPressed: _isOfferButtonEnabled ? () =>
                                _showSendOfferDialog(context) : null,
                            child: Text(
                                _isSendingOffer ? "Sending..." : "Send Offer",
                                style: const TextStyle(color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14)),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                        height: bottomPadding > 0 ? bottomPadding + 10 : 30),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detail(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon, size: 22, color: Colors.black87),
          const SizedBox(width: 15),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 15))),
        ],
      ),
    );
  }

  Widget _buildReviewsList() {
    if (_isLoadingReviews) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: CircularProgressIndicator(color: Colors.black),
        ),
      );
    }

    if (_reviews.isEmpty) {
      return GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  WriteReviewScreen(
                    courseData: {
                      'id': _courseId,
                      'sub': _subject,
                      'tutorName': _tutorName,
                      'title': _subject,
                      'category': _category,
                      'price': _price,
                      'tutorImage': _tutorImage,
                      'tutorId': _tutorId,
                    },
                  ),
            ),
          ).then((_) {
            _loadCourseReviews();
          });
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.rate_review_outlined,
                  size: 48,
                  color: Colors.grey.shade400,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "No Reviews Yet",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Be the first to review this course",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade500,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.edit_note, size: 16, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      "Write a Review",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Return existing reviews
    final reviewWidgets = <Widget>[];
    for (var review in _reviews.take(2)) {
      reviewWidgets.add(
        _buildReviewItem(
          review['studentName'],
          review['comment'],
          _formatDate(review['createdAt']),
          review['rating']?.toDouble() ?? 0.0,
          review['studentImage'] ?? '',
        ),
      );
    }
    return Column(children: reviewWidgets);
  }

// Add this method inside your class
  Widget _buildReviewItem(String name, String comment, String timeAgo,
      double rating, String studentImage) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.grey,
                backgroundImage: studentImage.isNotEmpty
                    ? NetworkImage('${ApiConfig.baseUrl}$studentImage')
                    : null,
                child: studentImage.isEmpty
                    ? const Icon(Icons.person, color: Colors.white, size: 20)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: Color(0xFF1A1C43)),
                ),
              ),
              const Icon(Icons.star, color: Colors.orange, size: 14),
              const SizedBox(width: 4),
              Text(
                rating.toStringAsFixed(1),
                style: const TextStyle(
                    fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 52),
            child: Text(
              comment,
              style: const TextStyle(color: Colors.black87, fontSize: 13),
            ),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 52),
            child: Text(
              timeAgo,
              style: const TextStyle(color: Colors.grey,
                  fontSize: 11,
                  fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}