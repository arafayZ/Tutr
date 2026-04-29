import 'package:flutter/material.dart';
import 'shared_widgets.dart';

class MatricScreen extends StatefulWidget {
  const MatricScreen({super.key});

  @override
  State<MatricScreen> createState() => _MatricScreenState();
}

class _MatricScreenState extends State<MatricScreen> {
  final List<Map<String, dynamic>> allTutors = [
    {"name": "Asif Ali Khan", "subject": "Physics", "price": "2000 PKR", "rating": "4.2", "location": "Online", "color": Colors.red.shade900, "fav": false},
    {"name": "Sumaika Asif", "subject": "Biology", "price": "1800 PKR", "rating": "4.5", "location": "Student's Home", "color": Colors.teal, "fav": true},
    {"name": "Muhammad Ali Imran", "subject": "Maths", "price": "2500 PKR", "rating": "4.8", "location": "Tutor's Place", "color": Colors.blue.shade900, "fav": false},
  ];

  List<Map<String, dynamic>> filteredTutors = [];
  String currentSearchQuery = "";
  List<String> activeModes = [];
  String activeBudget = "";

  @override
  void initState() {
    super.initState();
    filteredTutors = List.from(allTutors);
  }

  void _applyFilters() {
    setState(() {
      filteredTutors = allTutors.where((tutor) {
        bool matchesSearch = tutor['name'].toLowerCase().contains(currentSearchQuery.toLowerCase()) ||
            tutor['subject'].toLowerCase().contains(currentSearchQuery.toLowerCase());
        bool matchesMode = activeModes.isEmpty || activeModes.contains(tutor['location']);
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
          buildSharedSearchBar(
            context: context,
            onSearch: (val) {
              currentSearchQuery = val;
              _applyFilters();
            },
            activeCategories: const [],
            activeModes: activeModes,
            activeBudget: activeBudget,
            onApplyFilters: (newCats, newModes, newBudget, newLocation) {
              setState(() {
                activeModes = newModes;
                activeBudget = newBudget;
                _applyFilters();
              });
            },
            showCategories: false,
            showLocationFilter: false,
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