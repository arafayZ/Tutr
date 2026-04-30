import 'package:flutter/material.dart';
import 'shared_widgets.dart';
import 'course_details_screen.dart'; // Import the details screen

class EntranceTestScreen extends StatefulWidget {
  const EntranceTestScreen({super.key});

  @override
  State<EntranceTestScreen> createState() => _EntranceTestScreenState();
}

class _EntranceTestScreenState extends State<EntranceTestScreen> {
  // Master data list
  final List<Map<String, dynamic>> allTutors = [
    {
      "name": "Emaz Ali",
      "subject": "Tech Mentor",
      "price": "4500 PKR",
      "rating": "4.9",
      "location": "Tutor's Place",
      "color": Colors.green.shade800,
      "fav": true
    },
    {
      "name": "Dr. Aqil Burney",
      "subject": "Mathematics",
      "price": "5000 PKR",
      "rating": "5.0",
      "location": "Online",
      "color": Colors.blue.shade900,
      "fav": false
    },
  ];

  List<Map<String, dynamic>> filteredTutors = [];

  // --- Filter State ---
  String _currentSearchQuery = "";
  List<String> _activeCategories = [];
  List<String> _activeModes = [];
  String _activeBudget = "";

  @override
  void initState() {
    super.initState();
    filteredTutors = List.from(allTutors);
  }

  // --- CORE FILTERING LOGIC ---
  void _applyAllFilters() {
    setState(() {
      filteredTutors = allTutors.where((tutor) {
        // 1. Search Check
        bool matchesSearch = tutor['name'].toLowerCase().contains(_currentSearchQuery.toLowerCase()) ||
            tutor['subject'].toLowerCase().contains(_currentSearchQuery.toLowerCase());

        // 2. Mode Check
        bool matchesMode = _activeModes.isEmpty || _activeModes.contains(tutor['location']);

        // 3. Budget Check (Simple check based on your list data)
        bool matchesBudget = _activeBudget.isEmpty || tutor['price'].contains(_activeBudget.split(' ')[0]);

        return matchesSearch && matchesMode && matchesBudget;
      }).toList();
    });
  }

  void _toggleFav(int index) {
    setState(() {
      filteredTutors[index]['fav'] = !filteredTutors[index]['fav'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: buildSharedAppBar(context, "Entrance Test"),
      body: Column(
        children: [
          buildSharedSearchBar(
            context: context,
            onSearch: (val) {
              _currentSearchQuery = val;
              _applyAllFilters();
            },
            activeCategories: _activeCategories,
            activeModes: _activeModes,
            activeBudget: _activeBudget,
            onApplyFilters: (newCats, newModes, newBudget, newLocation) {
              setState(() {
                _activeCategories = newCats;
                _activeModes = newModes;
                _activeBudget = newBudget;
                _applyAllFilters();
              });
            },
            showCategories: false,
            showLocationFilter: false,
          ),

          Expanded(
            child: filteredTutors.isEmpty
                ? buildEmptyState()
                : buildTutorList(
              filteredTutors,
              _toggleFav,
              onCardTap: (tutor) {
                // Navigate to full details screen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CourseDetailsScreen(
                      courseData: {
                        ...tutor,
                        "title": tutor['subject'], // Maps 'subject' to 'title'
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}