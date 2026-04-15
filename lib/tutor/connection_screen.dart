import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/custom_bottom_nav.dart';
import 'add_course_screen.dart';
import 'chat_details_screen.dart';
import 'student_profile_screen.dart';
import '../services/connection_service.dart';
import '../config/api_config.dart';
import '../utils/status_bar_config.dart';

class ConnectionScreen extends StatefulWidget {
  final String studentName;

  const ConnectionScreen({super.key, required this.studentName});

  @override
  State<ConnectionScreen> createState() => _ConnectionScreenState();
}

class _ConnectionScreenState extends State<ConnectionScreen> {
  List<Map<String, dynamic>> _connections = [];
  List<Map<String, dynamic>> _filteredConnections = [];
  String _searchQuery = "";
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    StatusBarConfig.setLightStatusBar();
    _loadConnections();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadConnections() async {
    if (!mounted) return;

    setState(() => _isLoading = true);

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int tutorProfileId = prefs.getInt('profileId') ?? 0;

      // Get ONLY confirmed tutor connections from API
      List<Map<String, dynamic>> connections = await ConnectionService.getTutorConfirmedConnections(tutorProfileId);

      // Group connections by studentId (each student appears only once)
      Map<String, Map<String, dynamic>> groupedStudents = {};

      for (var conn in connections) {
        String studentId = conn['studentId'].toString();

        if (groupedStudents.containsKey(studentId)) {
          // Student already exists, add course to their list
          groupedStudents[studentId]!['courses'].add({
            'courseId': conn['courseId'],
            'courseName': conn['subject'],
            'connectionId': conn['connectionId'],
          });
        } else {
          // New student, create entry with courses list
          groupedStudents[studentId] = {
            'studentId': studentId,
            'name': conn['studentName'] ?? 'Unknown Student',
            'studentImage': conn['studentImage'],
            'location': conn['location'],
            'phone': conn['phoneNumber'],
            'gender': conn['gender'],
            'email': conn['studentEmail'],
            'agreedPrice': conn['agreedPrice'],
            'originalPrice': conn['originalPrice'],
            'status': conn['status'],
            'courses': [{
              'courseId': conn['courseId'],
              'courseName': conn['subject'],
              'connectionId': conn['connectionId'],
            }],
          };
        }
      }

      // Convert grouped map to list for display
      List<Map<String, dynamic>> formattedConnections = [];
      for (var entry in groupedStudents.values) {
        formattedConnections.add({
          'studentId': entry['studentId'],
          'name': entry['name'],
          'studentImage': entry['studentImage'],
          'location': entry['location'],
          'phone': entry['phone'],
          'gender': entry['gender'],
          'email': entry['email'],
          'agreedPrice': entry['agreedPrice'],
          'originalPrice': entry['originalPrice'],
          'status': entry['status'],
          'courses': entry['courses'],
          'courseCount': entry['courses'].length,
        });
      }

      if (mounted) {
        setState(() {
          _connections = formattedConnections;
          _filteredConnections = List.from(formattedConnections);
          _isLoading = false;
        });
      }

    } catch (e) {
      print('Error loading connections: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        _showErrorDialog("Failed to load connections: ${e.toString().replaceFirst('Exception: ', '')}");
      }
    }
  }

  void _filterConnections(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredConnections = List.from(_connections);
      } else {
        _filteredConnections = _connections
            .where((connection) =>
            connection["name"]!.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  void _navigateToProfile(Map<String, dynamic> person) {
    // Use the first connectionId from courses for profile (or pass all)
    final firstConnectionId = person['courses'].isNotEmpty
        ? person['courses'][0]['connectionId'].toString()
        : "0";

    final studentData = StudentDetails(
      id: person["studentId"] ?? "0",
      connectionId: firstConnectionId,
      name: person["name"],
      profilePic: person["studentImage"] ?? '',
      location: person["location"] ?? "Karachi, Pakistan",
      dob: "Not specified",
      gender: person["gender"] ?? "Not specified",
      college: "Not specified",
      school: "Not specified",
      phone: person["phone"] ?? "Not available",
      email: person["email"] ?? "Not available",
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StudentProfileScreen(
          student: studentData,
          onDisconnect: (id) async {
            await _loadConnections();
          },
        ),
      ),
    );
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

  Future<void> _disconnectStudent(String studentName, List<Map<String, dynamic>> courses) async {
    // Show dialog asking which course to disconnect from
    if (courses.length == 1) {
      // Single course, disconnect directly
      await _confirmAndDisconnect(studentName, courses[0]['connectionId']);
    } else {
      // Multiple courses, show selection dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Disconnect $studentName"),
          content: const Text("Select which course to disconnect from:"),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          actions: [
            ...courses.map((course) => TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await _confirmAndDisconnect(studentName, course['connectionId']);
              },
              child: Text(course['courseName']),
            )),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _confirmAndDisconnect(String studentName, int connectionId) async {
    bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Disconnect Student", style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text("Are you sure you want to disconnect $studentName from this course? This action cannot be undone."),
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
      await _loadConnections();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("$studentName disconnected successfully"),
          backgroundColor: Colors.green,
          duration: const Duration(milliseconds: 1500),
          behavior: SnackBarBehavior.floating,
        ),
      );

    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorDialog("Failed to disconnect: ${e.toString().replaceFirst('Exception: ', '')}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      extendBody: true,
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AddCourseScreen())),
        backgroundColor: Colors.black,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 35),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildSearchBar(),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredConnections.isEmpty
                  ? _buildEmptyState()
                  : RefreshIndicator(
                onRefresh: _loadConnections,
                color: Colors.black,
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 120),
                  itemCount: _filteredConnections.length,
                  itemBuilder: (context, index) => _buildConnectionItem(_filteredConnections[index]),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNav(currentIndex: 1),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 15, offset: const Offset(0, 8)),
        ],
      ),
      child: const Center(
        child: Text("Connections", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
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
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: TextField(
          onChanged: _filterConnections,
          cursorColor: Colors.black,
          decoration: const InputDecoration(
            hintText: "Search connections...",
            prefixIcon: Icon(Icons.search, color: Colors.black),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 15),
          ),
        ),
      ),
    );
  }

  Widget _buildConnectionItem(Map<String, dynamic> person) {
    final String? studentImage = person['studentImage']?.toString();
    final String name = person['name'] ?? 'Unknown';
    final List<Map<String, dynamic>> courses = List<Map<String, dynamic>>.from(person['courses']);
    final int courseCount = person['courseCount'] ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => _navigateToProfile(person),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.grey.shade300,
                  backgroundImage: studentImage != null && studentImage.isNotEmpty
                      ? NetworkImage('${ApiConfig.baseUrl}$studentImage')
                      : null,
                  child: studentImage == null || studentImage.isEmpty
                      ? const Icon(Icons.person, color: Colors.black, size: 30)
                      : null,
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: courses.map((course) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              course['courseName'],
                              style: const TextStyle(fontSize: 11, color: Colors.grey),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _buildActionButton(person, "Disconnect", name, courses),
              const SizedBox(width: 8),
              _buildActionButton(person, "Message", name, courses),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildActionButton(Map<String, dynamic> person, String label, String name, List<Map<String, dynamic>> courses) {
    return SizedBox(
      height: 32,
      child: ElevatedButton(
        onPressed: () {
          if (label == "Disconnect") {
            _disconnectStudent(name, courses);
          } else if (label == "Message") {
            Navigator.push(context, MaterialPageRoute(builder: (context) => ChatDetailsScreen(userName: name)));
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.people_outline,
              size: 60,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            "No Confirmed Connections",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            "When students confirm enrollment in your courses,\nthey will appear here.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}