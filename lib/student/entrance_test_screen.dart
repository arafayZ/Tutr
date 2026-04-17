import 'package:flutter/material.dart';
import 'shared_widgets.dart';

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
  String _activeBudget = ""; // Added this to fix the error

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

        // 3. Budget Check (Optional logic depending on how you parse the price string)
        // For now, we keep it simple so it doesn't break your list
        bool matchesBudget = _activeBudget.isEmpty || tutor['price'].contains(_activeBudget.split(' ')[1]);

        return matchesSearch && matchesMode;
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
          // Fixed the call to include required activeBudget and updated callback
          buildSharedSearchBar(
            context: context,
            onSearch: (val) {
              _currentSearchQuery = val;
              _applyAllFilters();
            },
            activeCategories: _activeCategories,
            activeModes: _activeModes,
            activeBudget: _activeBudget, // Added missing required parameter
            onApplyFilters: (newCats, newModes, newBudget) { // Added 3rd parameter
              setState(() {
                _activeCategories = newCats;
                _activeModes = newModes;
                _activeBudget = newBudget; // Update state with new selection
                _applyAllFilters();
              });
            },
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