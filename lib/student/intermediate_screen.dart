import 'package:flutter/material.dart';
import 'shared_widgets.dart';

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
      "name": "Abdul Rafay", // Updated to your preferred name
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
  String _activeBudget = ""; // Added to fix compilation error

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

        // 3. Check Budget (Simple contains check for now)
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
          // Updated with the required activeBudget and 3-parameter callback
          buildSharedSearchBar(
            context: context,
            onSearch: (val) {
              _currentSearchQuery = val;
              _applyAllFilters();
            },
            activeCategories: _activeCategories,
            activeModes: _activeModes,
            activeBudget: _activeBudget, // Added missing parameter
            onApplyFilters: (newCats, newModes, newBudget, newLocation) { // Added 3rd parameter
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