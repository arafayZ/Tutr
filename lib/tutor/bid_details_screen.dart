import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/custom_tab_header.dart';
import 'course_detail_screen.dart';
import 'student_profile_screen.dart';
import '../services/connection_service.dart';
import '../config/api_config.dart';
import '../utils/status_bar_config.dart';

// --- COURSE COLORS (Same as dashboard) ---
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

class BidDetailsScreen extends StatefulWidget {
  final String studentName;
  final bool isRequest;
  final Map<String, dynamic>? bidData;

  const BidDetailsScreen({
    super.key,
    required this.studentName,
    required this.isRequest,
    this.bidData,
  });

  @override
  State<BidDetailsScreen> createState() => _BidDetailsScreenState();
}

class _BidDetailsScreenState extends State<BidDetailsScreen> {
  String _selectedStatus = "";
  bool _isLoading = false;
  Map<String, dynamic>? _bidData;
  String? _studentImage;
  String? _courseName;
  int? _originalPrice;
  int? _studentOffer;
  int? _tutorOffer;
  int? _connectionId;
  int? _courseId;
  String? _studentId;

  @override
  void initState() {
    super.initState();
    StatusBarConfig.setLightStatusBar();
    _initializeData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _initializeData() {
    if (widget.bidData != null) {
      setState(() {
        _bidData = widget.bidData;
        _connectionId = _bidData?['id'];
        _courseId = _bidData?['courseId'];
        _studentId = _bidData?['studentId']?.toString();
        _studentImage = _bidData?['studentImage']?.toString();
        _courseName = _bidData?['courseName'] ?? 'Course';
        _originalPrice = _convertToInt(_bidData?['originalPrice']);
        _studentOffer = _convertToInt(_bidData?['studentBidPrice']);
        _tutorOffer = _convertToInt(_bidData?['tutorCounterOffer']);
      });
    }
  }

  int _convertToInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    return 0;
  }

  Future<void> _acceptBid() async {
    setState(() => _isLoading = true);

    try {
      await ConnectionService.tutorRespond(
        _connectionId!,
        accept: true,
      );

      if (mounted) {
        setState(() => _isLoading = false);
        _showSuccessPopup();
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorDialog("Failed to accept: ${e.toString().replaceFirst('Exception: ', '')}");
    }
  }

  Future<void> _rejectBid() async {
    setState(() => _isLoading = true);

    try {
      await ConnectionService.tutorRespond(
        _connectionId!,
        accept: false,
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
          _selectedStatus = "Rejected";
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Offer rejected successfully"),
            backgroundColor: Colors.orange,
            duration: Duration(milliseconds: 1500),
          ),
        );

        Future.delayed(const Duration(milliseconds: 1500), () {
          if (mounted) {
            Navigator.pop(context, true);
          }
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorDialog("Failed to reject: ${e.toString().replaceFirst('Exception: ', '')}");
    }
  }

  Future<void> _sendCounterOffer(int amount) async {
    setState(() => _isLoading = true);

    try {
      await ConnectionService.tutorRespond(
        _connectionId!,
        accept: false,
        counterOffer: amount,
      );

      if (mounted) {
        setState(() => _isLoading = false);
        _showCounterSuccessPopup();
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorDialog("Failed to send counter offer: ${e.toString().replaceFirst('Exception: ', '')}");
    }
  }

  void _showSuccessPopup() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("🎉", style: TextStyle(fontSize: 50)),
              const SizedBox(height: 15),
              const Text("Congratulations", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              Text(
                "You're now connected with ${widget.studentName}.",
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),
              const SizedBox(height: 20),
              const CircularProgressIndicator(color: Colors.black, strokeWidth: 2),
            ],
          ),
        ),
      ),
    );

    Timer(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pop(context);
        Navigator.pushReplacementNamed(context, '/connection', arguments: widget.studentName);
      }
    });
  }

  void _showCounterSuccessPopup() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        child: const Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 60),
              SizedBox(height: 15),
              Text("Offer Sent!", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              Text(
                "Your counter offer has been sent to the student.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );

    Timer(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pop(context);
        Navigator.pop(context, true);
      }
    });
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Error", style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text(message),
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK", style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  void _showCounterOfferPopup() {
    final TextEditingController _amountController = TextEditingController();
    String? _errorMessage;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        child: StatefulBuilder(
          builder: (context, setDialogState) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("Student Offer", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text(
                    "${_studentOffer ?? 0} PKR",
                    style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _amountController,
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      hintText: "Enter Counter Offer",
                      errorText: _errorMessage,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                    ),
                    onChanged: (value) {
                      if (_errorMessage != null) {
                        setDialogState(() => _errorMessage = null);
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Cancel"),
                        ),
                      ),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            final String input = _amountController.text.trim();
                            final int? amount = int.tryParse(input);

                            if (input.isEmpty) {
                              setDialogState(() => _errorMessage = "Enter an amount");
                            } else if (amount == null) {
                              setDialogState(() => _errorMessage = "Enter numbers only");
                            } else if (amount > 50000) {
                              setDialogState(() => _errorMessage = "Maximum limit: 50,000 PKR");
                            } else if (amount <= 0) {
                              setDialogState(() => _errorMessage = "Enter a valid amount");
                            } else {
                              Navigator.pop(context);
                              _sendCounterOffer(amount);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            shape: const StadiumBorder(),
                          ),
                          child: const Text("Send", style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final yourOfferPrice = _tutorOffer ?? 0;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: Column(
        children: [
          // Header with Back Button and Shadow
          Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 15,
                  offset: Offset(0, 8),
                ),
              ],
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
                          decoration: const BoxDecoration(
                            color: Colors.black,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                      ),
                    ),
                    const Text(
                      "Details",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _CourseHeaderCard(
                    courseId: _courseId ?? 0,
                    courseName: _courseName ?? 'Course',
                    originalPrice: _originalPrice ?? 0,
                  ),
                  const SizedBox(height: 25),
                  const Text("Student",
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 16)),
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => StudentProfileScreen(
                            student: StudentDetails(
                              id: _studentId ?? "0",
                              connectionId: _connectionId?.toString() ?? "0",
                              name: widget.studentName,
                              profilePic: _studentImage ?? '',
                              location: _bidData?['location'] ?? "Not specified",
                              dob: "Not specified",
                              gender: _bidData?['gender'] ?? "Not specified",
                              college: "Not specified",
                              school: "Not specified",
                              phone: _bidData?['phoneNumber'] ?? "Not available",
                              email: _bidData?['email'] ?? "Not available",
                            ),
                            onDisconnect: (String id) => debugPrint("Disconnected: $id"),
                          ),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(15),
                    child: _StudentTile(
                      name: widget.studentName,
                      imageUrl: _studentImage,
                    ),
                  ),
                  const SizedBox(height: 30),
                  // Show different price sections based on request type
                  if (widget.isRequest) ...[
                    // For Requests - DO NOT show any price
                    const SizedBox.shrink(),
                  ] else ...[
                    // For My Bids - show both offers
                    _PriceRow(
                      label: "Your Offer:",
                      price: "$yourOfferPrice PKR",
                      color: Colors.red,
                    ),
                    const SizedBox(height: 15),
                    _PriceRow(
                      label: "Student Offer:",
                      price: "${_studentOffer ?? 0} PKR",
                      color: Colors.red,
                    ),
                  ],
                ],
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_selectedStatus != "Rejected") ...[
                    _ActionButton(
                      label: widget.isRequest ? "Accept Request" : "Accept Offer",
                      color: Colors.black,
                      onTap: _acceptBid,
                      isLoading: _isLoading,
                    ),
                    if (!widget.isRequest)
                      _ActionButton(
                        label: "Counter Offer",
                        color: const Color(0xFFE0E0E0),
                        textColor: Colors.black,
                        onTap: _showCounterOfferPopup,
                        isLoading: _isLoading,
                      ),
                    _ActionButton(
                      label: widget.isRequest ? "Reject Request" : "Reject Offer",
                      color: const Color(0xFFE0E0E0),
                      textColor: Colors.black,
                      onTap: () async {
                        final res = await showDialog<bool>(
                          context: context,
                          builder: (context) => Dialog(
                            backgroundColor: Colors.white,
                            surfaceTintColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                            child: const Padding(
                              padding: EdgeInsets.all(24),
                              child: _RejectPopup(),
                            ),
                          ),
                        );
                        if (res == true) {
                          _rejectBid();
                        }
                      },
                      isLoading: _isLoading,
                    ),
                  ] else ...[
                    const _RejectedStatusBox(),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- COURSE CARD with Dynamic Color ---
class _CourseHeaderCard extends StatelessWidget {
  final int courseId;
  final String courseName;
  final int originalPrice;

  const _CourseHeaderCard({
    required this.courseId,
    required this.courseName,
    required this.originalPrice,
  });

  @override
  Widget build(BuildContext context) {
    final Color courseColor = CourseColors.getCourseColor(courseId);

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CourseDetailScreen(
              courseId: courseId,
              onCourseUpdated: () {},
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
        ),
        child: Row(
          children: [
            // Colored container with app icon - using dynamic course color
            Container(
              width: 85,
              height: 85,
              decoration: BoxDecoration(
                color: courseColor, // Using dynamic course color
                borderRadius: BorderRadius.circular(15),
              ),
              child: Center(
                child: Image.asset(
                  'assets/icon/app_icon.png',
                  width: 40,
                  height: 40,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Tutor", style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 12)),
                  Text(courseName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  Text("$originalPrice PKR", style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                  const Row(children: [
                    Icon(Icons.star, color: Colors.amber, size: 14),
                    Text(" 4.2 | ONLINE", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold))
                  ]),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

// --- STUDENT TILE ---
class _StudentTile extends StatelessWidget {
  final String name;
  final String? imageUrl;

  const _StudentTile({required this.name, this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 5)],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: Colors.grey.shade300,
            backgroundImage: imageUrl != null && imageUrl!.isNotEmpty
                ? NetworkImage('${ApiConfig.baseUrl}$imageUrl')
                : null,
            child: imageUrl == null || imageUrl!.isEmpty
                ? const Icon(Icons.person, color: Colors.grey, size: 25)
                : null,
          ),
          const SizedBox(width: 15),
          Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black)),
        ],
      ),
    );
  }
}

// --- PRICE ROW ---
class _PriceRow extends StatelessWidget {
  final String label;
  final String price;
  final Color color;

  const _PriceRow({required this.label, required this.price, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
        Text(price, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }
}

// --- ACTION BUTTON ---
class _ActionButton extends StatelessWidget {
  final String label;
  final Color color;
  final Color textColor;
  final VoidCallback onTap;
  final bool isLoading;

  const _ActionButton({
    required this.label,
    required this.color,
    this.textColor = Colors.white,
    required this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: SizedBox(
        width: double.infinity,
        height: 60,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          ),
          onPressed: isLoading ? null : onTap,
          child: isLoading
              ? const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
          )
              : Text(label, style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 16)),
        ),
      ),
    );
  }
}

// --- REJECT POPUP ---
class _RejectPopup extends StatelessWidget {
  const _RejectPopup();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text("Are you sure?", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        const SizedBox(height: 25),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("CANCEL")),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("REJECT", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            ),
          ],
        )
      ],
    );
  }
}

// --- REJECTED STATUS BOX ---
class _RejectedStatusBox extends StatelessWidget {
  const _RejectedStatusBox();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.cancel_outlined, color: Colors.red),
          SizedBox(width: 10),
          Text("Offer Rejected", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}