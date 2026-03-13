import 'package:flutter/material.dart';
import '../widgets/custom_bottom_nav.dart';
import 'add_course_screen.dart';
import 'chat_details_screen.dart';

class ConnectionScreen extends StatefulWidget {
  // 1. Define the parameter to receive the name from the bid popup
  final String studentName;

  const ConnectionScreen({super.key, required this.studentName});

  @override
  State<ConnectionScreen> createState() => _ConnectionScreenState();
}

class _ConnectionScreenState extends State<ConnectionScreen> {
  // Master list of connections
  final List<Map<String, dynamic>> _allConnections = [
    {"name": "Asim Ali Khan", "activeBtn": ""},
    {"name": "Ali Imran", "activeBtn": ""},
    {"name": "Hiba Khan", "activeBtn": ""},
    {"name": "Emaz Ali Khan", "activeBtn": ""},
    {"name": "Bilal Raza", "activeBtn": ""},
    {"name": "Abdul Rafay", "activeBtn": ""},
  ];

  List<Map<String, dynamic>> _filteredConnections = [];
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();

    // 2. Logic to add the newly connected student if they aren't already in the list
    bool alreadyExists = _allConnections.any(
            (element) => element["name"].toString().toLowerCase() == widget.studentName.toLowerCase()
    );

    if (!alreadyExists && widget.studentName != "Student") {
      _allConnections.insert(0, {"name": widget.studentName, "activeBtn": ""});
    }

    _filteredConnections = _allConnections;
  }

  void _filterConnections(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredConnections = _allConnections;
      } else {
        _filteredConnections = _allConnections
            .where((connection) =>
            connection["name"]!.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
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
      body: SafeArea(
        child: Column(
          children: [
            // --- HEADER ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  "Connections",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
            ),

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
                    )
                  ],
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
            ),

            // --- LIST ---
            Expanded(
              child: _filteredConnections.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 120),
                itemCount: _filteredConnections.length,
                itemBuilder: (context, index) {
                  return _buildConnectionItem(_filteredConnections[index]);
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNav(currentIndex: 1),
    );
  }

  Widget _buildConnectionItem(Map<String, dynamic> person) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
          setState(() {
            person["activeBtn"] = label;
          });

          if (label == "Disconnect") {
            _showConfirmationDialog(person);
          } else if (label == "Message") {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatDetailsScreen(userName: person["name"]),
              ),
            );
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
                _allConnections.removeWhere((e) => e["name"] == person["name"]);
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