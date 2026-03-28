import 'package:flutter/material.dart';
import '../widgets/custom_bottom_nav.dart';
import 'chat_details_screen.dart';
import 'student_profile_screen.dart';

class MyStudentsListScreen extends StatefulWidget {
  final List<Map<String, dynamic>> connections;

  const MyStudentsListScreen({super.key, required this.connections});

  @override
  State<MyStudentsListScreen> createState() => _MyStudentsListScreenState();
}

class _MyStudentsListScreenState extends State<MyStudentsListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  late List<Map<String, dynamic>> myStudentList;

  @override
  void initState() {
    super.initState();
    // Initialize the local list with the data passed from the widget
    myStudentList = List.from(widget.connections);
  }

  // Logic to remove student from list
  void _removeStudent(String studentId) {
    setState(() {
      myStudentList.removeWhere((student) => student['id'].toString() == studentId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredConnections = myStudentList.where((student) {
      final name = student['name']?.toString().toLowerCase() ?? "";
      return name.contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      extendBody: true,
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: Colors.black,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 35),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: Column(
        children: [
          _buildHeader(context),

          // --- SEARCH BAR ---
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 25, 20, 10),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (value) => setState(() => _searchQuery = value),
                decoration: InputDecoration(
                  hintText: "Search your students...",
                  hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                  prefixIcon: const Icon(Icons.search, color: Colors.black),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ),
          ),

          // --- STUDENT LIST ---
          Expanded(
            child: filteredConnections.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 140),
              physics: const BouncingScrollPhysics(),
              itemCount: filteredConnections.length,
              itemBuilder: (context, index) {
                return _buildPersonTile(context, filteredConnections[index]);
              },
            ),
          ),
        ],
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
            bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 2))
        ],
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
                decoration: const BoxDecoration(
                    color: Colors.black, shape: BoxShape.circle),
                child: const Icon(Icons.arrow_back, color: Colors.white, size: 22),
              ),
            ),
          ),
          const Text("My Students",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black)),
        ],
      ),
    );
  }

  Widget _buildPersonTile(BuildContext context, Map<String, dynamic> student) {
    final String name = student['name'] ?? "Unknown Student";
    final String id = student['id']?.toString() ?? name;

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
          const CircleAvatar(
            radius: 25,
            backgroundColor: Color(0xFF1A1A1A),
            child: Icon(Icons.person, color: Colors.white, size: 20),
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
                        id: id,
                        name: name,
                        profilePic: 'assets/images/rafay.jpeg',
                        location: student['location'] ?? "Nazimabad, Karachi",
                        dob: "15 December 2001",
                        gender: "Male",
                        college: "KIET",
                        school: "KIET",
                        phone: "03452589651",
                        email: "asim@gmail.com",
                      ),
                      onDisconnect: (studentId) => _removeStudent(studentId),
                    ),
                  ),
                );
              },
              child: Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
          ElevatedButton(
            onPressed: () => _showStudentDetailsPopup(context, student),
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

  void _showStudentDetailsPopup(BuildContext context, Map<String, dynamic> student) {
    final String name = student['name'] ?? "Unknown Student";
    final String id = student['id']?.toString() ?? "";

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
                    const CircleAvatar(
                      radius: 35,
                      backgroundColor: Colors.black,
                      child: Icon(Icons.person, color: Colors.white, size: 30),
                    ),
                    const SizedBox(width: 15),
                    Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
                  ],
                ),
                const SizedBox(height: 15),
                const Divider(color: Color(0xFFF0F0F0)),
                const SizedBox(height: 15),
                _buildInfoRow(Icons.location_on_outlined, student['location'] ?? "Nazimabad, Karachi"),
                _buildInfoRow(Icons.phone_android_outlined, "03452589651"),
                _buildInfoRow(Icons.person_outline, "Male"),
                const SizedBox(height: 25),
                Row(
                  children: [
                    const Icon(Icons.payments_outlined, color: Colors.grey, size: 28),
                    const SizedBox(width: 12),
                    const Text("1500 PKR",
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1F9CFF))),
                    const SizedBox(width: 10),
                    const Text("2000 PKR",
                        style: TextStyle(fontSize: 14, color: Colors.grey, decoration: TextDecoration.lineThrough)),
                  ],
                ),
                const SizedBox(height: 30),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context); // Close Popup
                          _removeStudent(id); // Remove from list
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
                          Navigator.push(context, MaterialPageRoute(builder: (context) => ChatDetailsScreen(userName: name)));
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
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey, size: 22),
          const SizedBox(width: 15),
          Text(text, style: const TextStyle(fontSize: 15, color: Colors.grey, fontWeight: FontWeight.w500)),
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
          const Text("No Students Found", style: TextStyle(fontSize: 18, color: Colors.black26, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}