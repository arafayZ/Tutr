import 'package:flutter/material.dart';
import 'shared_widgets.dart';

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

  final List<Map<String, dynamic>> allTutors = [
    {"name": "Asim Ali Khan", "sub": "Chemistry Coach", "img": Colors.black},
    {"name": "Asim Furqan", "sub": "Biology Expert", "img": Colors.black},
    {"name": "Asim Ayoob", "sub": "Chemistry Specialist", "img": Colors.black},
    {"name": "Asim Khan", "sub": "Math Enthusiast", "img": Colors.black},
    {"name": "Asim", "sub": "Biology Tutor", "img": Colors.black},
    {"name": "Abdul Rafay", "sub": "CS Instructor", "img": Colors.black},
  ];

  List<Map<String, dynamic>> _getFilteredResults() {
    if (currentSearchQuery.trim().isEmpty) {
      return allTutors;
    }

    return allTutors.where((tutor) {
      final name = tutor['name'].toString().toLowerCase();
      final subject = tutor['sub'].toString().toLowerCase();
      final query = currentSearchQuery.toLowerCase();
      return name.contains(query) || subject.contains(query);
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
              setState(() {
                currentSearchQuery = val;
              });
            },
            activeCategories: activeCategories,
            activeModes: activeModes,
            activeBudget: activeBudget,
            onApplyFilters: (newCats, newModes, newBudget) {
              setState(() {
                activeCategories = newCats;
                activeModes = newModes;
                activeBudget = newBudget;
              });
            },
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
                      style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)
                  ),
                ],
              ),
            ),
          ),
          Text("$count FOUND",
              style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildResultsList(List<Map<String, dynamic>> results) {
    if (results.isEmpty) {
      return buildEmptyState();
    }

    // --- ADDED SAFEAREA BOTTOM ---
    return SafeArea(
      top: false, // Don't add padding at the top, we have an AppBar
      child: ListView.builder(
        itemCount: results.length,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, i) {
          final item = results[i];
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              leading: CircleAvatar(
                radius: 28,
                backgroundColor: Colors.grey.shade200,
                child: const Icon(Icons.person, color: Colors.grey),
              ),
              title: Text(item['name'],
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              subtitle: Text(item['sub'],
                  style: const TextStyle(color: Colors.grey, fontSize: 13)),
              trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.black26),
              onTap: () {
                // Navigate to Tutor Profile
              },
            ),
          );
        },
      ),
    );
  }
}