import 'package:flutter/material.dart';
import '../widgets/custom_bottom_nav.dart';
import 'add_course_screen.dart';
import 'chat_details_screen.dart';
import 'student_profile_screen.dart';

class ConnectionScreen extends StatefulWidget {
  final String studentName;

  const ConnectionScreen({super.key, required this.studentName});

  @override
  State<ConnectionScreen> createState() => _ConnectionScreenState();
}

class _ConnectionScreenState extends State<ConnectionScreen> {
  // Master list with IDs to satisfy StudentDetails requirements
  final List<Map<String, dynamic>> _allConnections = [
    {"id": "1", "name": "Asim Ali Khan", "activeBtn": ""},
    {"id": "2", "name": "Ali Imran", "activeBtn": ""},
    {"id": "3", "name": "Hiba Khan", "activeBtn": ""},
    {"id": "4", "name": "Emaz Ali Khan", "activeBtn": ""},
    {"id": "5", "name": "Bilal Raza", "activeBtn": ""},
    {"id": "6", "name": "Abdul Rafay", "activeBtn": ""},
  ];

  List<Map<String, dynamic>> _filteredConnections = [];
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    // Logic to add student from previous screen if they don't exist
    bool alreadyExists = _allConnections.any(
            (element) => element["name"].toString().toLowerCase() == widget.studentName.toLowerCase()
    );

    if (!alreadyExists && widget.studentName != "Student" && widget.studentName.isNotEmpty) {
      _allConnections.insert(0, {
        "id": DateTime.now().millisecondsSinceEpoch.toString(),
        "name": widget.studentName,
        "activeBtn": ""
      });
    }
    _filteredConnections = List.from(_allConnections);
  }

  void _filterConnections(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredConnections = List.from(_allConnections);
      } else {
        _filteredConnections = _allConnections
            .where((connection) =>
            connection["name"]!.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  void _navigateToProfile(Map<String, dynamic> person) {
    final studentData = StudentDetails(
      id: person["id"] ?? "0",
      name: person["name"],
      profilePic: "assets/images/user.png",
      location: "Karachi, Pakistan",
      dob: "01-Jan-2005",
      gender: "Male",
      college: "KIET",
      school: "Karachi Public School",
      phone: "+92 300 1234567",
      email: "${person["name"].toString().toLowerCase().replaceAll(" ", "")}@email.com",
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StudentProfileScreen(
          student: studentData,
          onDisconnect: (id) {
            setState(() {
              _allConnections.removeWhere((element) => element["id"] == id);
              _filterConnections(_searchQuery);
            });
          },
        ),
      ),
    );
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
              child: _filteredConnections.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 120),
                itemCount: _filteredConnections.length,
                itemBuilder: (context, index) => _buildConnectionItem(_filteredConnections[index]),
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
                const CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.black,
                  child: Icon(Icons.person, color: Colors.white, size: 30),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Text(
                    person["name"]!,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _buildActionButton(person, "Disconnect"),
              const SizedBox(width: 8),
              _buildActionButton(person, "Message"),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildActionButton(Map<String, dynamic> person, String label) {
    bool isActive = person["activeBtn"] == label;
    return SizedBox(
      height: 32,
      child: ElevatedButton(
        onPressed: () {
          setState(() => person["activeBtn"] = label);
          if (label == "Disconnect") {
            _showConfirmationDialog(person);
          } else if (label == "Message") {
            Navigator.push(context, MaterialPageRoute(builder: (context) => ChatDetailsScreen(userName: person["name"])));
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: isActive ? Colors.black : const Color(0xFFE0E0E0),
          foregroundColor: isActive ? Colors.white : Colors.black,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
      ),
    );
  }

  void _showConfirmationDialog(Map<String, dynamic> person) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text("Disconnect?", style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text("Remove ${person['name']} from your connections?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              setState(() {
                _allConnections.removeWhere((e) => e["id"] == person["id"]);
                _filterConnections(_searchQuery);
              });
              Navigator.pop(context);
            },
            child: const Text("Disconnect", style: TextStyle(color: Colors.red)),
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
          Icon(Icons.person_search, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 10),
          const Text("No connections found", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}