import 'package:flutter/material.dart';
import 'tutor_profile_screen.dart';

class TopTutorData {
  final String name;
  final String expertise;

  TopTutorData({required this.name, required this.expertise});
}

class TopTutorsScreen extends StatefulWidget {
  const TopTutorsScreen({super.key});

  @override
  State<TopTutorsScreen> createState() => _TopTutorsScreenState();
}

class _TopTutorsScreenState extends State<TopTutorsScreen> {
  final List<TopTutorData> allTutors = [
    TopTutorData(name: "Ahmed Khan", expertise: "Physics Expert"),
    TopTutorData(name: "Sara Malik", expertise: "Math Enthusiast"),
    TopTutorData(name: "Ali Raza", expertise: "Chemistry Specialist"),
    TopTutorData(name: "Hassan Javed", expertise: "English Coach"),
    TopTutorData(name: "Ayesha Khan", expertise: "Science Mentor"),
    TopTutorData(name: "Omar Farooq", expertise: "Biology Expert"),
  ];

  List<TopTutorData> filteredTutors = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    filteredTutors = allTutors;
  }

  void _filterTutors(String query) {
    setState(() {
      filteredTutors = allTutors
          .where((tutor) =>
      tutor.name.toLowerCase().contains(query.toLowerCase()) ||
          tutor.expertise.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      extendBody: true,
      body: Column(
        children: [
          _buildHeader(context), // Header with navigation
          _buildSearchBar(),     // Independent search bar after header
          Expanded(
            child: filteredTutors.isEmpty
                ? _buildEmptyState()
                : ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 120),
              physics: const BouncingScrollPhysics(),
              itemCount: filteredTutors.length,
              separatorBuilder: (context, index) => const SizedBox(height: 15),
              itemBuilder: (context, index) => _buildTutorCard(filteredTutors[index]),
            ),
          ),
        ],
      ),
    );
  }

  // 1. The Header (Navigation only)
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(35),
          bottomRight: Radius.circular(35),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle),
              child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
            ),
          ),
          const Text(
            "Top Tutor",
            style: TextStyle(
              color: Color(0xFF1A1C43),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 40), // Spacing placeholder
        ],
      ),
    );
  }

  // 2. The Search Bar (Positioned after the header)
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: TextField(
          controller: _searchController,
          onChanged: _filterTutors,
          decoration: const InputDecoration(
            icon: Icon(Icons.search, color: Colors.grey, size: 20),
            hintText: "Search tutor here...",
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ),
      ),
    );
  }

  Widget _buildTutorCard(TopTutorData tutor) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TutorProfileScreen(
              tutorData: {'name': tutor.name, 'sub': tutor.expertise},
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 28,
              backgroundColor: Colors.black,
              child: Icon(Icons.person, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tutor.name,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    tutor.expertise,
                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.black12),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 60, color: Colors.grey),
          SizedBox(height: 10),
          Text(
            "No tutors found for this search",
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ],
      ),
    );
  }
}