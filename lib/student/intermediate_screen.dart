import 'package:flutter/material.dart';
import 'shared_widgets.dart';
import 'course_details_screen.dart'; // Ensure this is imported

class IntermediateScreen extends StatefulWidget {
  const IntermediateScreen({super.key});

  @override
  State<IntermediateScreen> createState() => _IntermediateScreenState();
}

class _IntermediateScreenState extends State<IntermediateScreen> {
  // Master data list
  final List<Map<String, dynamic>> allTutors = [
    {
      "name": "Ali Imran",
      "subject": "English",
      "price": "2200 PKR",
      "rating": "4.0",
      "location": "Tutor's Place",
      "color": Colors.brown,
      "fav": false
    },
    {
      "name": "Abdul Rafay",
      "subject": "CS Instructor",
      "price": "2500 PKR",
      "rating": "4.9",
      "location": "Online",
      "color": Colors.blueGrey,
      "fav": true
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
        bool matchesSearch = tutor['name'].toLowerCase().contains(_currentSearchQuery.toLowerCase()) ||
            tutor['subject'].toLowerCase().contains(_currentSearchQuery.toLowerCase());

        bool matchesMode = _activeModes.isEmpty || _activeModes.contains(tutor['location']);

        bool matchesBudget = _activeBudget.isEmpty || tutor['price'].contains(_activeBudget.split(' ')[0].replaceAll(',', ''));

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
      appBar: buildSharedAppBar(context, "Intermediate"),
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
                // Trigger navigation to Details Screen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CourseDetailsScreen(
                      courseData: {
                        ...tutor,
                        "title": tutor['subject'], // Maps 'subject' to 'title' for the details header
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