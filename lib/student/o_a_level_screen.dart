import 'package:flutter/material.dart';
import 'shared_widgets.dart';

class OALevelScreen extends StatefulWidget {
  const OALevelScreen({super.key});

  @override
  State<OALevelScreen> createState() => _OALevelScreenState();
}

class _OALevelScreenState extends State<OALevelScreen> {
  // Master data list
  final List<Map<String, dynamic>> allTutors = [
    {
      "name": "Hiba Khan",
      "subject": "Urdu",
      "price": "2500 PKR",
      "rating": "4.2",
      "location": "Student's Home",
      "color": Colors.pink.shade800,
      "fav": true
    },
    {
      "name": "Zain Ahmed",
      "subject": "Economics",
      "price": "3000 PKR",
      "rating": "4.7",
      "location": "Online",
      "color": Colors.indigo,
      "fav": false
    },
  ];

  List<Map<String, dynamic>> filteredTutors = [];

  // --- Filter State ---
  String _currentSearchQuery = "";
  List<String> _activeCategories = [];
  List<String> _activeModes = [];
  String _activeBudget = ""; // Added to fix the build error

  @override
  void initState() {
    super.initState();
    filteredTutors = List.from(allTutors);
  }

  // --- CORE FILTERING LOGIC ---
  void _applyAllFilters() {
    setState(() {
      filteredTutors = allTutors.where((tutor) {
        // 1. Check Search Query
        bool matchesSearch = tutor['name'].toLowerCase().contains(_currentSearchQuery.toLowerCase()) ||
            tutor['subject'].toLowerCase().contains(_currentSearchQuery.toLowerCase());

        // 2. Check Teaching Mode
        bool matchesMode = _activeModes.isEmpty || _activeModes.contains(tutor['location']);

        // 3. Check Budget logic
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
      appBar: buildSharedAppBar(context, "O & A Level"),
      body: Column(
        children: [
          // Updated call with activeBudget and the correct 3-parameter callback
          buildSharedSearchBar(
            context: context,
            onSearch: (val) {
              _currentSearchQuery = val;
              _applyAllFilters();
            },
            activeCategories: _activeCategories,
            activeModes: _activeModes,
            activeBudget: _activeBudget, // Added required parameter
            onApplyFilters: (newCats, newModes, newBudget,newLocation) { // Added 3rd parameter
              setState(() {
                _activeCategories = newCats;
                _activeModes = newModes;
                _activeBudget = newBudget; // Update state
                _applyAllFilters();
              });
            },
            showCategories: false,
            showLocationFilter: false,
          ),

          Expanded(
            child: filteredTutors.isEmpty
                ? buildEmptyState()
                : buildTutorList(filteredTutors, _toggleFav),
          ),
        ],
      ),
    );
  }
}