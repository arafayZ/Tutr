import 'package:flutter/material.dart';
import 'shared_widgets.dart';
import 'tutor_profile_screen.dart'; // Ensure this file exists in your project

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

  // Tutor Data
  final List<Map<String, dynamic>> allTutors = [
    {"name": "Asim Ali Khan", "sub": "Chemistry Coach", "location": "Karachi"},
    {"name": "Asim Furqan", "sub": "Biology Expert", "location": "Lahore"},
    {"name": "Asim Ayoob", "sub": "Chemistry Specialist", "location": "Islamabad"},
    {"name": "Asim Khan", "sub": "Math Enthusiast", "location": "Karachi"},
    {"name": "Abdul Rafay", "sub": "CS Instructor", "location": "Lahore"},
  ];

  // Course Data
  final List<Map<String, dynamic>> allCourses = [
    {"name": "Advanced Flutter UI", "sub": "Mobile Development", "location": "Online"},
    {"name": "Organic Chemistry 101", "sub": "Science", "location": "Karachi"},
    {"name": "Calculus & Algebra", "sub": "Mathematics", "location": "Lahore"},
    {"name": "Python for Data Science", "sub": "Programming", "location": "Islamabad"},
  ];

  List<Map<String, dynamic>> _getFilteredResults() {
    final List<Map<String, dynamic>> targetList = isCourseSelected ? allCourses : allTutors;

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
      backgroundColor: Colors.white,
      appBar: buildSharedAppBar(context, "Search"),
      body: Column(
        children: [
          buildSharedSearchBar(
            context: context,
            onSearch: (val) {
              setState(() => currentSearchQuery = val);
            },
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
      padding: const EdgeInsets.fromLTRB(25, 20, 25, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: RichText(
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                style: const TextStyle(color: Colors.black, fontSize: 14),
                children: [
                  const TextSpan(text: "Result for "),
                  TextSpan(
                      text: '"$currentSearchQuery"',
                      style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)
                  ),
                ],
              ),
            ),
          ),
          Text("$count FOUND",
              style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildResultsList(List<Map<String, dynamic>> results) {
    if (results.isEmpty) {
      return buildEmptyState();
    }

    return SafeArea(
      top: false,
      child: ListView.builder(
        itemCount: results.length,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, i) {
          final item = results[i];
          IconData leadingIcon = isCourseSelected ? Icons.book_rounded : Icons.person;

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
              leading: CircleAvatar(
                radius: 28,
                backgroundColor: const Color(0xFFF1F4F4),
                child: Icon(leadingIcon, color: Colors.black),
              ),
              title: Text(item['name'],
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item['sub'],
                      style: const TextStyle(color: Colors.grey, fontSize: 13)),
                  if (item['location'] != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Row(
                        children: [
                          const Icon(Icons.location_on, size: 12, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(item['location'],
                              style: const TextStyle(color: Colors.grey, fontSize: 11)),
                        ],
                      ),
                    ),
                ],
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.black),
              onTap: () {
                // Navigates to Profile ONLY if in Tutor mode
                if (!isCourseSelected) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TutorProfileScreen(tutorData: item),
                    ),
                  );
                } else {
                  // You can add navigation to a CourseDetailsScreen here later
                  debugPrint("Course selected: ${item['name']}");
                }
              },
            ),
          );
        },
      ),
    );
  }
}