import 'package:flutter/material.dart';
import 'shared_widgets.dart';

class MatricScreen extends StatefulWidget {
  const MatricScreen({super.key});

  @override
  State<MatricScreen> createState() => _MatricScreenState();
}

class _MatricScreenState extends State<MatricScreen> {
  // Master data list with updated names from your team records
  final List<Map<String, dynamic>> allTutors = [
    {"name": "Asif Ali Khan", "subject": "Physics", "price": "2000 PKR", "rating": "4.2", "location": "Online", "color": Colors.red.shade900, "fav": false},
    {"name": "Sumaika Asif", "subject": "Biology", "price": "1800 PKR", "rating": "4.5", "location": "Student's Home", "color": Colors.teal, "fav": true},
    {"name": "Muhammad Ali Imran", "subject": "Maths", "price": "2500 PKR", "rating": "4.8", "location": "Tutor's Place", "color": Colors.blue.shade900, "fav": false},
  ];

  List<Map<String, dynamic>> filteredTutors = [];

  // --- Filter State ---
  String currentSearchQuery = "";
  List<String> activeCategories = [];
  List<String> activeModes = [];
  String activeBudget = ""; // Added to fix the missing parameter error

  @override
  void initState() {
    super.initState();
    filteredTutors = List.from(allTutors);
  }

  // --- CORE FILTERING LOGIC ---
  void _applyFilters() {
    setState(() {
      filteredTutors = allTutors.where((tutor) {
        // 1. Check Search Query
        bool matchesSearch = tutor['name'].toLowerCase().contains(currentSearchQuery.toLowerCase()) ||
            tutor['subject'].toLowerCase().contains(currentSearchQuery.toLowerCase());

        // 2. Check Teaching Mode
        bool matchesMode = activeModes.isEmpty || activeModes.contains(tutor['location']);

        // 3. Check Budget
        bool matchesBudget = activeBudget.isEmpty || tutor['price'].contains(activeBudget.split(' ')[0]);

        return matchesSearch && matchesMode && matchesBudget;
      }).toList();
    });
  }

  void _toggleFavorite(int index) {
    setState(() {
      filteredTutors[index]['fav'] = !filteredTutors[index]['fav'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: buildSharedAppBar(context, "Matric"),
      body: Column(
        children: [
          // Updated call with activeBudget and the correct 3-parameter callback
          buildSharedSearchBar(
            context: context,
            onSearch: (val) {
              currentSearchQuery = val;
              _applyFilters();
            },
            activeCategories: activeCategories,
            activeModes: activeModes,
            activeBudget: activeBudget, // Added required parameter
            onApplyFilters: (newCats, newModes, newBudget) { // Added 3rd parameter
              setState(() {
                activeCategories = newCats;
                activeModes = newModes;
                activeBudget = newBudget; // Update budget state
                _applyFilters();
              });
            },
          ),
          Expanded(
            child: filteredTutors.isEmpty
                ? buildEmptyState()
                : buildTutorList(filteredTutors, _toggleFavorite),
          ),
        ],
      ),
    );
  }
}