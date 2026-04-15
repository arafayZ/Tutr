import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/custom_bottom_nav.dart';
import 'chat_details_screen.dart';
import 'student_profile_screen.dart';
import 'add_course_screen.dart';
import '../services/connection_service.dart';
import '../config/api_config.dart';

class MyStudentsListScreen extends StatefulWidget {
  final int courseId;
  final String courseName;

  const MyStudentsListScreen({
    super.key,
    required this.courseId,
    required this.courseName,
  });

  @override
  State<MyStudentsListScreen> createState() => _MyStudentsListScreenState();
}

class _MyStudentsListScreenState extends State<MyStudentsListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  List<Map<String, dynamic>> _students = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    setState(() => _isLoading = true);

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int tutorProfileId = prefs.getInt('profileId') ?? 0;

      List<Map<String, dynamic>> allConnections = await ConnectionService.getTutorConnections(tutorProfileId);

      List<Map<String, dynamic>> filteredConnections = allConnections.where((student) {
        final bool matchesCourse = student['courseId'] == widget.courseId;
        final bool isConfirmed = student['status']?.toString().toUpperCase() == 'CONFIRMED';
        return matchesCourse && isConfirmed;
      }).toList();

      setState(() {
        _students = filteredConnections;
        _isLoading = false;
      });

    } catch (e) {
      print('Error loading students: $e');
      setState(() => _isLoading = false);
      _showErrorDialog("Failed to load students: ${e.toString().replaceFirst('Exception: ', '')}");
    }
  }

  Future<void> _refreshStudents() async {
    await _loadStudents();
  }

  Future<void> _disconnectStudent(int connectionId, String studentName) async {
    bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Disconnect Student", style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text("Are you sure you want to disconnect $studentName from ${widget.courseName}? This action cannot be undone."),
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Disconnect", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);

    try {
      await ConnectionService.disconnect(connectionId, disconnectedBy: "TUTOR");

      setState(() {
        _students.removeWhere((student) => student['connectionId'] == connectionId);
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("$studentName disconnected from ${widget.courseName}"),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );

    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorDialog("Failed to disconnect: ${e.toString().replaceFirst('Exception: ', '')}");
    }
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredStudents = _students.where((student) {
      final name = student['studentName']?.toString().toLowerCase() ?? "";
      return name.contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      extendBody: true,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddCourseScreen()),
          );
        },
        backgroundColor: Colors.black,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 35),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: RefreshIndicator(
        onRefresh: _refreshStudents,
        color: Colors.black,
        child: Column(
          children: [
            _buildHeader(context),
            _buildSearchBar(),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : filteredStudents.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 140),
                physics: const BouncingScrollPhysics(),
                itemCount: filteredStudents.length,
                itemBuilder: (context, index) {
                  return _buildStudentTile(context, filteredStudents[index]);
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNav(currentIndex: -1),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      height: 120,
      padding: const EdgeInsets.only(top: 50, left: 20, right: 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 2))],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: InkWell(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 45,
                height: 45,
                decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle),
                child: const Icon(Icons.arrow_back, color: Colors.white, size: 22),
              ),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "My Students",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
              ),
              const SizedBox(height: 4),
              Text(
                widget.courseName,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 25, 20, 10),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (value) => setState(() => _searchQuery = value),
          decoration: InputDecoration(
            hintText: "Search students in ${widget.courseName}...",
            hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
            prefixIcon: const Icon(Icons.search, color: Colors.black),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 15),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
              icon: const Icon(Icons.clear, size: 20),
              onPressed: () {
                _searchController.clear();
                setState(() => _searchQuery = "");
              },
            )
                : null,
          ),
        ),
      ),
    );
  }

  Widget _buildStudentTile(BuildContext context, Map<String, dynamic> student) {
    final String name = student['studentName']?.toString() ?? "Unknown Student";
    final int connectionId = student['connectionId'] ?? 0;
    final String? studentImage = student['studentImage']?.toString();
    final String studentId = student['studentId']?.toString() ?? "";
    final String location = student['location']?.toString() ?? "Not specified";
    final String phone = student['phoneNumber']?.toString() ?? "Not available";
    final String gender = student['gender']?.toString() ?? "Not specified";
    final String email = student['email']?.toString() ?? "Not available";

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8)],
      ),
      padding: const EdgeInsets.all(15),
      child: Row(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: const Color(0xFF1A1A1A),
            backgroundImage: studentImage != null && studentImage.isNotEmpty
                ? NetworkImage('${ApiConfig.baseUrl}$studentImage')
                : null,
            child: studentImage == null || studentImage.isEmpty
                ? const Icon(Icons.person, color: Colors.white, size: 20)
                : null,
          ),
          const SizedBox(width: 15),
          Expanded(
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StudentProfileScreen(
                      student: StudentDetails(
                        id: studentId,
                        connectionId: connectionId.toString(),
                        name: name,
                        profilePic: studentImage ?? '',
                        location: location,
                        dob: "Not specified",
                        gender: gender,
                        college: "Not specified",
                        school: "Not specified",
                        phone: phone,
                        email: email,
                      ),
                      onDisconnect: (studentId) => _disconnectStudent(connectionId, name),
                    ),
                  ),
                );
              },
              child: Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
          ElevatedButton(
            onPressed: () => _showStudentDetailsPopup(context, student, connectionId),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              minimumSize: const Size(70, 32),
            ),
            child: const Text("Details", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<void> _showStudentDetailsPopup(BuildContext context, Map<String, dynamic> student, int connectionId) async {
    final String name = student['studentName']?.toString() ?? "Unknown Student";

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: Colors.black),
                  SizedBox(height: 16),
                  Text("Loading student details..."),
                ],
              ),
            ),
          ),
        );
      },
    );

    try {
      // Fetch fresh student details from API
      final studentDetail = await ConnectionService.getStudentDetail(connectionId);

      // Close loading dialog
      Navigator.pop(context);

      // Extract data from API response
      final String fullName = studentDetail['studentName'] ?? name;
      final String location = studentDetail['location']?.toString() ?? "Not specified";
      final String phone = studentDetail['phoneNumber']?.toString() ?? "Not available";
      final String gender = studentDetail['gender']?.toString() ?? "Not specified";
      final String? studentImage = studentDetail['studentImage']?.toString();

      // Handle double to int conversion for prices
      final int agreedPrice = (studentDetail['agreedPrice'] is double)
          ? (studentDetail['agreedPrice'] as double).toInt()
          : (studentDetail['agreedPrice'] ?? 0);

      final int originalPrice = (studentDetail['originalPrice'] is double)
          ? (studentDetail['originalPrice'] as double).toInt()
          : (studentDetail['originalPrice'] ?? 0);

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Student Details",
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black)),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 35,
                        backgroundColor: Colors.grey.shade300,
                        backgroundImage: studentImage != null && studentImage.isNotEmpty
                            ? NetworkImage('${ApiConfig.baseUrl}$studentImage')
                            : null,
                        child: studentImage == null || studentImage.isEmpty
                            ? const Icon(Icons.person, color: Colors.grey, size: 30)
                            : null,
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Text(
                          fullName,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  const Divider(color: Color(0xFFF0F0F0)),
                  const SizedBox(height: 15),
                  _buildInfoRow(Icons.location_on_outlined, location),
                  _buildInfoRow(Icons.phone_android_outlined, phone),
                  _buildInfoRow(Icons.person_outline, gender),
                  const SizedBox(height: 25),
                  Row(
                    children: [
                      const Icon(Icons.payments_outlined, color: Colors.grey, size: 28),
                      const SizedBox(width: 12),
                      Text("$agreedPrice PKR",
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1F9CFF))),
                      if (originalPrice > 0 && originalPrice != agreedPrice) ...[
                        const SizedBox(width: 10),
                        Text("$originalPrice PKR",
                            style: const TextStyle(fontSize: 14, color: Colors.grey, decoration: TextDecoration.lineThrough)),
                      ],
                    ],
                  ),
                  const SizedBox(height: 30),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _disconnectStudent(connectionId, fullName);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE0E0E0),
                            foregroundColor: Colors.black,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text("Disconnect", style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.push(context, MaterialPageRoute(builder: (context) => ChatDetailsScreen(userName: fullName)));
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text("Message", style: TextStyle(fontWeight: FontWeight.bold)),
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

    } catch (e) {
      Navigator.pop(context);
      _showErrorDialog("Failed to load student details: ${e.toString().replaceFirst('Exception: ', '')}");
    }
  }
  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey, size: 22),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.person_off_outlined, size: 100, color: Colors.black12),
          const SizedBox(height: 15),
          const Text(
            "No Students Found",
            style: TextStyle(fontSize: 18, color: Colors.black26, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            "When students enroll in your courses, they will appear here.",
            style: TextStyle(fontSize: 14, color: Colors.black26),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}