import 'package:flutter/material.dart';
import 'shared_widgets.dart';
import 'tutor_profile_screen.dart';
import 'course_details_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  bool isCourseSelected = true;
  String currentSearchQuery = "";

  List<String> activeCategories = [];
  List<String> activeModes = [];
  String activeBudget = "";
  String activeLocation = "";

  final List<Map<String, dynamic>> allTutors = [
    {"name": "Asim Ali Khan", "sub": "Chemistry Coach", "location": "Karachi", "price": "2000 PKR", "rating": "4.2", "color": Colors.red.shade900, "fav": false, "category": "Matric"},
    {"name": "Asim Furqan", "sub": "Biology Expert", "location": "Lahore", "price": "2500 PKR", "rating": "4.5", "color": Colors.green, "fav": false, "category": "Intermediate"},
    {"name": "Asim Ayoob", "sub": "Chemistry Specialist", "location": "Islamabad", "price": "2200 PKR", "rating": "4.0", "color": Colors.brown, "fav": false, "category": "Intermediate"},
    {"name": "Asim Khan", "sub": "Math Enthusiast", "location": "Karachi", "price": "1800 PKR", "rating": "4.1", "color": Colors.orange, "fav": false, "category": "Matric"},
    {"name": "Abdul Rafay", "sub": "CS Instructor", "location": "Lahore", "price": "2500 PKR", "rating": "4.9", "color": Colors.blueGrey, "fav": true, "category": "Intermediate"},
  ];

  final List<Map<String, dynamic>> allCourses = [
    {"name": "Hiba Khan", "sub": "Physics", "location": "Student Home", "price": "2500 PKR", "rating": "4.2", "color": Colors.pink.shade700, "fav": true, "category": "O Level"},
    {"name": "Rehan Sheikh", "sub": "Mobile Dev", "location": "Online", "price": "3000 PKR", "rating": "4.8", "color": Colors.blue.shade800, "fav": false, "category": "Entrance"},
  ];

  List<Map<String, dynamic>> _getFilteredResults() {
    final List<Map<String, dynamic>> targetList = isCourseSelected ? allCourses : allTutors;
    if (currentSearchQuery.isEmpty && activeLocation.isEmpty) return targetList;

    return targetList.where((item) {
      bool matchesSearch = currentSearchQuery.isEmpty ||
          item['name'].toString().toLowerCase().contains(currentSearchQuery.toLowerCase()) ||
          item['sub'].toString().toLowerCase().contains(currentSearchQuery.toLowerCase());
      bool matchesLocation = activeLocation.isEmpty ||
          item['location'].toString().toLowerCase().contains(activeLocation.toLowerCase());
      return matchesSearch && matchesLocation;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredList = _getFilteredResults();

    return Scaffold(
      resizeToAvoidBottomInset: false, // Fixes the 15px overflow by not resizing the view
      backgroundColor: Colors.white,
      appBar: buildSharedAppBar(context, "Search"),
      body: Column(
        children: [
          buildSharedSearchBar(
            context: context,
            onSearch: (val) => setState(() => currentSearchQuery = val),
            activeCategories: activeCategories,
            activeModes: activeModes,
            activeBudget: activeBudget,
            onApplyFilters: (newCats, newModes, newBudget, newLocation) {
              setState(() {
                activeCategories = newCats;
                activeModes = newModes;
                activeBudget = newBudget;
                activeLocation = newLocation;
              });
            },
            showCategories: true,
            showLocationFilter: true,
          ),
          const SizedBox(height: 10),
          _buildToggleSwitch(),
          if (currentSearchQuery.trim().isNotEmpty)
            _buildResultHeader(filteredList.length),
          Expanded(child: _buildResultsList(filteredList)),
        ],
      ),
    );
  }

  Widget _buildToggleSwitch() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Container(
        height: 55,
        decoration: BoxDecoration(
          color: const Color(0xFFF1F4F4),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          children: [
            _toggleButton("Courses", isCourseSelected, () => setState(() => isCourseSelected = true)),
            _toggleButton("Tutor", !isCourseSelected, () => setState(() => isCourseSelected = false)),
          ],
        ),
      ),
    );
  }

  Widget _toggleButton(String title, bool isActive, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: isActive ? Colors.black : Colors.transparent,
            borderRadius: BorderRadius.circular(25),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                  color: isActive ? Colors.white : Colors.black54,
                  fontWeight: FontWeight.bold,
                  fontSize: 15),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResultHeader(int count) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(25, 10, 25, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("Result for \"$currentSearchQuery\"", style: const TextStyle(fontWeight: FontWeight.bold)),
          Text("$count FOUND", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildResultsList(List<Map<String, dynamic>> results) {
    if (results.isEmpty) {
      // Wrapping in SingleChildScrollView ensures no overflow even if the state widget is tall
      return SingleChildScrollView(child: buildEmptyState());
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
      itemCount: results.length,
      itemBuilder: (context, i) {
        final t = results[i];
        return isCourseSelected ? _buildCourseCard(t) : _buildTutorListItem(t);
      },
    );
  }

  Widget _buildCourseCard(Map<String, dynamic> t) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => CourseDetailsScreen(courseData: {...t, "title": t['sub']}))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        height: 115,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            Container(
              width: 90,
              decoration: BoxDecoration(
                color: t['color'],
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(15), bottomLeft: Radius.circular(15)),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(t['name'], style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 11)),
                        Icon(t['fav'] ? Icons.favorite : Icons.favorite_border, color: t['fav'] ? Colors.red : Colors.black54, size: 18),
                      ],
                    ),
                    Text(t['sub'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    Row(
                      children: [
                        Text(t['price'], style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 15)),
                        const SizedBox(width: 8),
                        Text(t['category'] ?? "", style: const TextStyle(color: Colors.grey, fontSize: 11)),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.orange, size: 14),
                        Text(" ${t['rating']}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                        const Text("  |  ", style: TextStyle(color: Colors.grey)),
                        Text(t['location'].toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTutorListItem(Map<String, dynamic> t) {
    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(vertical: 8),
          leading: const CircleAvatar(
            radius: 30,
            backgroundColor: Colors.black,
          ),
          title: Text(
            t['name'],
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black),
          ),
          subtitle: Text(
            t['sub'],
            style: const TextStyle(color: Colors.grey, fontSize: 13),
          ),
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => TutorProfileScreen(tutorData: t))),
        ),
        const Divider(height: 1, color: Color(0xFFF1F4F4)),
      ],
    );
  }
}