import 'package:flutter/material.dart';
import '../widgets/custom_bottom_nav.dart';
import 'my_students_list_screen.dart';

class StudentDetailsScreen extends StatefulWidget {
  final String categoryName;
  const StudentDetailsScreen({super.key, required this.categoryName});

  @override
  State<StudentDetailsScreen> createState() => _StudentDetailsScreenState();
}

class _StudentDetailsScreenState extends State<StudentDetailsScreen> {
  String _selectedMode = "Online";
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  // 1. Connections list for the next screen
  final List<Map<String, dynamic>> _allConnections = [
    {"name": "Asim Ali Khan"},
    {"name": "Ali Imran"},
    {"name": "Hiba Khan"},
    {"name": "Emaz Ali Khan"},
    {"name": "Bilal Raza"},
    {"name": "Abdul Rafay"},
    {"name": "Hiba Khan"},
    {"name": "Emaz Ali Khan"},
    {"name": "Bilal Raza"},
  ];

  final List<Map<String, dynamic>> _allStudents = [
    {"subject": "Physics", "price": "2000 PKR", "rating": 4.2, "students": 23, "mode": "Online", "category": "Metric"},
    {"subject": "Maths", "price": "2500 PKR", "rating": 4.5, "students": 15, "mode": "Student Home", "category": "Metric"},
    {"subject": "Biology", "price": "3000 PKR", "rating": 4.7, "students": 8, "mode": "Online", "category": "Intermediate"},
    {"subject": "English", "price": "1800 PKR", "rating": 4.0, "students": 10, "mode": "Tutor Home", "category": "Metric"},
  ];

  @override
  Widget build(BuildContext context) {
    // Logic to filter based on Category, Mode, and Search Text
    final filteredList = _allStudents.where((s) {
      final matchesCategory = s['category'] == widget.categoryName;
      final matchesMode = s['mode'] == _selectedMode;
      final matchesSearch = s['subject'].toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesMode && matchesSearch;
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),

          // --- 2. FUNCTIONAL SEARCH BAR (Placed below header) ---
          Padding(
            padding: const EdgeInsets.fromLTRB(25, 25, 25, 5),
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
                  hintText: "Search in ${widget.categoryName}...",
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
          ),

          // --- 3. MODE SLIDER ---
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
            child: Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
              ),
              child: Row(
                children: [
                  _buildTabButton("Online"),
                  _buildTabButton("Student Home"),
                  _buildTabButton("Tutor Home"),
                ],
              ),
            ),
          ),

          // --- 4. LIST ---
          Expanded(
            child: filteredList.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
              physics: const BouncingScrollPhysics(),
              itemCount: filteredList.length,
              itemBuilder: (context, index) => _buildStudentCard(filteredList[index]),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const CustomBottomNav(currentIndex: -1),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      height: 120, // Explicit height to match previous screen
      padding: const EdgeInsets.only(top: 50, left: 20, right: 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
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
                width: 45, height: 45,
                decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle),
                child: const Icon(Icons.arrow_back, color: Colors.white, size: 22),
              ),
            ),
          ),
          Text(widget.categoryName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/images/cancel.png', height: 160, width: 160, fit: BoxFit.contain),
          const SizedBox(height: 15),
          const Text("Nothing Here Yet", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black26)),
          const Text("No students found in this category.", style: TextStyle(fontSize: 14, color: Colors.black26)),
          const SizedBox(height: 100), // Account for Bottom Nav
        ],
      ),
    );
  }

  Widget _buildTabButton(String label) {
    bool isSelected = _selectedMode == label;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedMode = label),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.black : Colors.transparent,
            borderRadius: BorderRadius.circular(25),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStudentCard(Map<String, dynamic> data) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFAD1457), // The Tutr standard red
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(data['subject'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Row(children: [
                      const Icon(Icons.star, color: Colors.amber, size: 14),
                      Text(" ${data['rating']}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    ]),
                  ],
                ),
                Text("${data['price']}", style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 12)),
                const SizedBox(height: 4),
                Row(children: [
                  Text(data['mode'].toUpperCase(), style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 9)),
                  const Text(" | ", style: TextStyle(color: Colors.grey)),
                  Text("${data['students']} Students", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 9)),
                ]),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MyStudentsListScreen(connections: _allConnections),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      minimumSize: const Size(0, 28),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                    child: const Text("Student Details", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}