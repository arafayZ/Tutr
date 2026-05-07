import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/connection_refresh_service.dart';
import 'course_details_screen.dart';
import 'tutor_profile_screen.dart';
import '../services/connection_service.dart';
import '../config/api_config.dart';

// --- COURSE COLORS (Same as other screens) ---
class CourseColors {
  static const List<Color> colors = [
    Color(0xFF1A1A2E), Color(0xFF16213E), Color(0xFF0F3460),
    Color(0xFF8B1E3F), Color(0xFF2C3E50), Color(0xFF1B4F72),
    Color(0xFF145A32), Color(0xFF7B2C3E), Color(0xFF4A235A),
    Color(0xFF1C2833), Color(0xFF6E2C00), Color(0xFF0B5345),
    Color(0xFF424949), Color(0xFF5D4037), Color(0xFF283747),
    Color(0xFF7E5109), Color(0xFF4A4A4A), Color(0xFF3E2723),
    Color(0xFF1A237E),
  ];

  static Color getCourseColor(int courseId) {
    return colors[courseId % colors.length];
  }
}

// Helper function to format text (remove underscores and capitalize)
String formatText(String text) {
  if (text.isEmpty) return '';
  String formatted = text.replaceAll('_', ' ');
  List<String> words = formatted.split(' ');
  for (int i = 0; i < words.length; i++) {
    if (words[i].isNotEmpty) {
      words[i] = words[i][0].toUpperCase() + words[i].substring(1).toLowerCase();
    }
  }
  return words.join(' ');
}

// Category Badge Colors Helper
Map<String, Color> getCategoryBadgeColors(String category) {
  switch (category.toUpperCase()) {
    case 'MATRIC':
      return {'bg': Colors.orange.shade100, 'text': Colors.orange.shade800};
    case 'INTERMEDIATE':
      return {'bg': Colors.teal.shade100, 'text': Colors.teal.shade800};
    case 'O_LEVEL':
      return {'bg': Colors.blue.shade100, 'text': Colors.blue.shade800};
    case 'A_LEVEL':
      return {'bg': Colors.green.shade100, 'text': Colors.green.shade800};
    case 'ENTRY_TEST':
      return {'bg': Colors.purple.shade100, 'text': Colors.purple.shade800};
    default:
      return {'bg': Colors.grey.shade100, 'text': Colors.grey.shade800};
  }
}

class BidDetailsScreen extends StatefulWidget {
  final int courseId;
  final int studentId;
  final VoidCallback? onRefresh;

  const BidDetailsScreen({
    super.key,
    required this.courseId,
    required this.studentId,
    this.onRefresh,
  });

  @override
  State<BidDetailsScreen> createState() => _BidDetailsScreenState();
}

class _BidDetailsScreenState extends State<BidDetailsScreen> {
  final TextEditingController _offerController = TextEditingController();
  String? _offerError;
  String? _offerHelperText;
  bool _isLoading = true;
  bool _isSubmitting = false;
  bool _isRefreshing = false;

  Map<String, dynamic> _bidData = {};
  int _connectionId = 0;

  @override
  void initState() {
    super.initState();
    _loadBidDetails();
  }

  Future<void> _loadBidDetails() async {
    if (_isRefreshing) return;

    setState(() => _isLoading = true);

    try {
      final response = await ConnectionService.getStudentBids(
          widget.studentId,
          widget.courseId
      );

      if (response.isNotEmpty) {
        setState(() {
          _bidData = response.first;
          _connectionId = _bidData['connectionId'] ?? 0;
          _isLoading = false;
          _isRefreshing = false;
        });
      } else {
        setState(() => _isLoading = false);
        _showErrorDialog('No bid found for this course');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _isRefreshing = false;
      });
      _showErrorDialog(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<void> _refreshData() async {
    if (_isRefreshing) return;

    setState(() => _isRefreshing = true);
    await _loadBidDetails();
  }

  String _formatCategory(String category) {
    if (category.isEmpty) return 'General';
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
        return formatText(category);
    }
  }

  String _formatTeachingMode(String mode) {
    if (mode.isEmpty) return 'Online';
    switch (mode.toUpperCase()) {
      case 'ONLINE':
        return 'Online';
      case 'STUDENT_HOME':
        return "Student's Home";
      case 'TUTOR_HOME':
        return "Tutor's Home";
      default:
        return formatText(mode);
    }
  }

  void _navigateToCourseDetail() {
    final courseData = {
      'id': _bidData['courseId'] ?? 0,
      'courseId': _bidData['courseId'] ?? 0,
      'tutorName': _bidData['tutorName'] ?? 'Tutor Name',
      'name': _bidData['tutorName'] ?? 'Tutor Name',
      'sub': _bidData['subject'] ?? 'Course',
      'title': _bidData['subject'] ?? 'Course',
      'category': _bidData['category'] ?? 'General',
      'price': '${_bidData['originalPrice']?.toStringAsFixed(0) ?? 0} PKR',
      'priceValue': _bidData['originalPrice']?.toDouble() ?? 0.0,
      'rating': _bidData['averageRating']?.toString() ?? '0.0',
      'totalRatings': _bidData['totalRatings'] ?? 0,
      'location': _bidData['location'] ?? 'Online',
      'teachingMode': _formatTeachingMode(_bidData['teachingMode'] ?? 'Online'),
      'tutorImage': _bidData['tutorImage'] ?? '',
      'tutorHeadline': _bidData['tutorHeadline'] ?? 'Expert Tutor',
    };
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CourseDetailsScreen(courseData: courseData),
      ),
    );
  }

  void _navigateToTutorProfile() {
    final tutorData = {
      'id': _bidData['tutorId'] ?? 0,
      'tutorId': _bidData['tutorId'] ?? 0,
      'name': _bidData['tutorName'] ?? 'Tutor Name',
      'tutorName': _bidData['tutorName'] ?? 'Tutor Name',
      'sub': _bidData['subject'] ?? 'Course',
      'tutorHeadline': _bidData['tutorHeadline'] ?? 'Expert Tutor',
      'rating': _bidData['averageRating']?.toString() ?? '0.0',
      'averageRating': _bidData['averageRating']?.toDouble() ?? 0.0,
      'location': _bidData['location'] ?? 'Online',
      'tutorLocation': _bidData['location'] ?? 'Online',
      'tutorImage': _bidData['tutorImage'] ?? '',
      'profilePictureUrl': _bidData['tutorImage'] ?? '',
    };
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TutorProfileScreen(tutorData: tutorData),
      ),
    );
  }

  Future<void> _cancelRequest() async {
    setState(() => _isSubmitting = true);

    try {
      await ConnectionService.studentCancelPending(_connectionId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Request cancelled successfully'),
            backgroundColor: Colors.transparent,
            duration: Duration(seconds: 2),
          ),
        );
        ConnectionRefreshService().notifyRefresh();
        widget.onRefresh?.call();
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', '')),
            backgroundColor: Colors.transparent,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  Future<void> _acceptOffer() async {
    setState(() => _isSubmitting = true);

    try {
      await ConnectionService.studentRespondToCounter(_connectionId, accept: true);

      if (mounted) {
        _showCongratulationsPopup();
      }
    } catch (e) {
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.transparent,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _rejectOffer() async {
    setState(() => _isSubmitting = true);

    try {
      await ConnectionService.studentRespondToCounter(_connectionId, accept: false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Offer rejected successfully'),
            backgroundColor: Colors.transparent,
            duration: Duration(seconds: 2),
          ),
        );
        ConnectionRefreshService().notifyRefresh();
        widget.onRefresh?.call();
        Navigator.pop(context, true);
      }
    } catch (e) {
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.transparent,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _sendCounterOffer(int offerAmount) async {
    setState(() => _isSubmitting = true);

    try {
      await ConnectionService.studentRespondToCounter(
        _connectionId,
        accept: false,
        newOffer: offerAmount.toDouble(),
      );

      if (mounted) {
        _showSuccessPopup();
      }
    } catch (e) {
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.transparent,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _showCancelConfirmationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text("Cancel Request", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
          content: const Text("Are you sure you want to cancel this request?", style: TextStyle(fontSize: 14)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("No", style: TextStyle(color: Colors.grey, fontSize: 16)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _cancelRequest();
              },
              child: const Text("Yes, Cancel", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ],
        );
      },
    );
  }

  void _showAcceptConfirmationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text("Accept Offer", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
          content: const Text("Are you sure you want to accept this offer?", style: TextStyle(fontSize: 14)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("No", style: TextStyle(color: Colors.grey, fontSize: 16)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _acceptOffer();
              },
              child: const Text("Yes, Accept", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ],
        );
      },
    );
  }

  void _showRejectConfirmationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text("Reject Offer", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
          content: const Text("Are you sure you want to reject this offer?", style: TextStyle(fontSize: 14)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("No", style: TextStyle(color: Colors.grey, fontSize: 16)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _rejectOffer();
              },
              child: const Text("Yes, Reject", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ],
        );
      },
    );
  }

  void _showCongratulationsPopup() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 80,
                  width: 80,
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 50),
                ),
                const SizedBox(height: 30),
                const Text("Congratulations!",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1A1C43))),
                const SizedBox(height: 15),
                const Text("You are now connected with the tutor!",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 14, height: 1.5)),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ConnectionRefreshService().notifyRefresh();
                    widget.onRefresh?.call();
                    Navigator.pop(context, true);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("OK", style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSuccessPopup() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 80,
                  width: 80,
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 50),
                ),
                const SizedBox(height: 30),
                const Text("Offer Sent!",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1A1C43))),
                const SizedBox(height: 15),
                const Text("Your counter offer has been sent to the tutor.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 14, height: 1.5)),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ConnectionRefreshService().notifyRefresh();
                    widget.onRefresh?.call();
                    Navigator.pop(context, true);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("OK", style: TextStyle(color: Colors.white)),
                ),
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

  void _showCounterOfferPopup() {
    final originalPrice = _bidData['originalPrice'] ?? 0;
    final studentBidPrice = _bidData['studentBidPrice'] ?? 0;
    final tutorOffer = _bidData['tutorOffer'];

    final int minOffer = studentBidPrice.toInt() + 1;
    final int maxOffer = (tutorOffer != null)
        ? tutorOffer.toInt() - 1
        : originalPrice.toInt() - 1;

    _offerController.clear();
    _offerError = null;
    _offerHelperText = null;

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
                updateError("Please enter a valid number", "Enter numeric value only");
                return;
              }
              if (amount < minOffer) {
                updateError("Minimum offer is $minOffer PKR", "Your offer must be at least $minOffer PKR");
                return;
              }
              if (amount > maxOffer) {
                updateError("Offer too high", "Offer must be less than $maxOffer PKR");
                return;
              }
              updateError(null, null);
            }

            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              backgroundColor: Colors.white,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Original Price",
                              style: TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w500)),
                          Text("${originalPrice.toStringAsFixed(0)} PKR",
                              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blue)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                      decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(12)),
                      child: Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(color: Colors.amber.shade100, borderRadius: BorderRadius.circular(8)),
                            child: const Center(child: Text("💰", style: TextStyle(fontSize: 16))),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Offer Range",
                                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey)),
                                const SizedBox(height: 2),
                                Text("Min: $minOffer PKR | Max: $maxOffer PKR",
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.black87)),
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
                        const Text("Enter Your Offer",
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: _offerError != null ? Colors.red : Colors.grey.shade300,
                                width: _offerError != null ? 1.5 : 1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), bottomLeft: Radius.circular(12)),
                                ),
                                child: const Text("PKR",
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87)),
                              ),
                              Expanded(
                                child: TextField(
                                  controller: _offerController,
                                  keyboardType: TextInputType.number,
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                                  onChanged: (value) => setDialogState(() => validateAmount(value)),
                                  decoration: const InputDecoration(
                                    hintText: "Enter amount",
                                    hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
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
                                Icon(Icons.info_outline, size: 12, color: Colors.blue.shade600),
                                const SizedBox(width: 4),
                                Expanded(child: Text(_offerHelperText!,
                                    style: TextStyle(fontSize: 11, color: Colors.blue.shade600))),
                              ],
                            ),
                          ),
                        if (_offerError != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8, left: 4),
                            child: Row(
                              children: [
                                Icon(Icons.error_outline, size: 12, color: Colors.red.shade600),
                                const SizedBox(width: 4),
                                Expanded(child: Text(_offerError!,
                                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Colors.red.shade600))),
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
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text("Cancel", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _offerError == null && _offerController.text.trim().isNotEmpty
                                ? () {
                              final offerAmount = int.tryParse(_offerController.text.trim());
                              if (offerAmount != null && offerAmount > 0) {
                                Navigator.pop(context);
                                _sendCounterOffer(offerAmount);
                              }
                            }
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text("Send Offer",
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
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

  @override
  Widget build(BuildContext context) {
    final status = _bidData['status'] ?? 'PENDING';
    final isPending = status == 'PENDING';
    final isNegotiating = status == 'NEGOTIATING';

    final courseName = _bidData['subject'] ?? 'Course';
    final originalPrice = _bidData['originalPrice'] ?? 0;
    final studentBidPrice = _bidData['studentBidPrice'] ?? 0;
    final tutorOfferPrice = _bidData['tutorOffer'] ?? 0;
    final courseId = _bidData['courseId'] ?? 0;
    final categoryRaw = _bidData['category'] ?? 'General';
    final categoryDisplay = _formatCategory(categoryRaw);
    final teachingModeRaw = _bidData['teachingMode'] ?? 'Online';
    final teachingModeDisplay = _formatTeachingMode(teachingModeRaw);
    final location = _bidData['location'] ?? 'Online';
    final rating = _bidData['averageRating']?.toDouble() ?? 4.2;

    final tutorName = _bidData['tutorName'] ?? 'Tutor Name';
    final tutorHeadline = _bidData['tutorHeadline'] ?? 'Expert Tutor';
    final tutorImage = _bidData['tutorImage']?.toString() ?? '';
    final tutorId = _bidData['tutorId'] ?? 0;

    final courseColor = CourseColors.getCourseColor(courseId);
    final badgeColors = getCategoryBadgeColors(categoryRaw);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        color: Colors.black,
        backgroundColor: Colors.white,
        child: Column(
          children: [
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 15, offset: Offset(0, 8))],
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: 45,
                            height: 45,
                            decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle),
                            child: const Icon(Icons.arrow_back, color: Colors.white, size: 22),
                          ),
                        ),
                      ),
                      const Text("Bid Details",
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black)),
                    ],
                  ),
                ),
              ),
            ),

            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: Colors.black))
                  : SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Column(
                  children: [
                    // Course Card
                    GestureDetector(
                      onTap: _navigateToCourseDetail,
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, spreadRadius: 2)],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(color: Colors.grey.shade100),
                              ),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Container(
                                      width: 80,
                                      height: 80,
                                      color: courseColor,
                                      child: const Center(
                                        child: Image(
                                          image: AssetImage('assets/icon/app_icon.png'),
                                          width: 45,
                                          height: 45,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(tutorName,
                                            style: const TextStyle(color: Colors.orange, fontSize: 12)),
                                        const SizedBox(height: 4),
                                        Text(courseName,
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                            overflow: TextOverflow.ellipsis),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Text('${originalPrice.toStringAsFixed(0)} PKR',
                                                style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 14)),
                                            const SizedBox(width: 8),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: badgeColors['bg'],
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              child: Text(categoryDisplay,
                                                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: badgeColors['text'])),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            const Icon(Icons.star, color: Colors.amber, size: 12),
                                            const SizedBox(width: 2),
                                            Text(rating.toStringAsFixed(1),
                                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                                            const SizedBox(width: 8),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: _getStatusColor(status).withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              child: Text(status,
                                                  style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: _getStatusColor(status))),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Tutor Card
                    GestureDetector(
                      onTap: tutorId != 0 ? _navigateToTutorProfile : null,
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, spreadRadius: 2)],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Tutor",
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black)),
                            const SizedBox(height: 10),
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: CircleAvatar(
                                radius: 25,
                                backgroundColor: Colors.grey[300],
                                backgroundImage: tutorImage.isNotEmpty
                                    ? NetworkImage('${ApiConfig.baseUrl}$tutorImage')
                                    : null,
                                child: tutorImage.isEmpty
                                    ? const Icon(Icons.person, color: Colors.grey, size: 30)
                                    : null,
                              ),
                              title: Text(tutorName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              subtitle: Text(tutorHeadline, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                              trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Course Details Card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, spreadRadius: 2)],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Course Details",
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black)),
                          const SizedBox(height: 15),
                          _buildInfoRow(Icons.menu_book, "20 Classes per month"),
                          _buildInfoRow(Icons.access_time, "6:00 P.M - 8:00 P.M"),
                          _buildInfoRow(Icons.calendar_month, "Monday to Friday"),
                          _buildInfoRow(
                            teachingModeDisplay == 'Online'
                                ? Icons.wifi
                                : (teachingModeDisplay == "Student's Home" ? Icons.home : Icons.location_city),
                            teachingModeDisplay,
                          ),
                          _buildInfoRow(Icons.location_on_outlined, location),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Pricing Card (Styled like other boxes)
                    if (!isPending) ...[
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, spreadRadius: 2)],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            RichText(
                              text: TextSpan(
                                style: const TextStyle(color: Colors.black),
                                children: [
                                  const TextSpan(text: "Your Offer: ", style: TextStyle(fontWeight: FontWeight.bold)),
                                  TextSpan(
                                    text: "${studentBidPrice.toStringAsFixed(0)} PKR",
                                    style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 18),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            RichText(
                              text: TextSpan(
                                style: const TextStyle(color: Colors.black),
                                children: [
                                  const TextSpan(text: "Tutor Offer: ", style: TextStyle(fontWeight: FontWeight.bold)),
                                  TextSpan(
                                    text: tutorOfferPrice > 0
                                        ? "${tutorOfferPrice.toStringAsFixed(0)} PKR"
                                        : "Not offered yet",
                                    style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 18),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: _getStatusColor(status).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                status,
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: _getStatusColor(status)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Bottom Buttons
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: _isSubmitting
                  ? const Center(child: CircularProgressIndicator(color: Colors.black))
                  : isPending
                  ? ElevatedButton(
                onPressed: _showCancelConfirmationDialog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('Cancel Request', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              )
                  : isNegotiating
                  ? Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _showCounterOfferPopup,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                      child: const Text('Counter Offer', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _showAcceptConfirmationDialog,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                      child: const Text('Accept Offer', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _showRejectConfirmationDialog,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                      child: const Text('Reject Offer', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
                ],
              )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[700]),
          const SizedBox(width: 15),
          Text(text, style: TextStyle(color: Colors.grey[800], fontSize: 14)),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return Colors.orange;
      case 'NEGOTIATING':
        return Colors.blue;
      case 'CONFIRMED':
        return Colors.green;
      case 'REJECTED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}