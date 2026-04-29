import 'package:flutter/material.dart';
import 'package:my_first_app/tutor/connection_screen.dart';
import 'tutor_profile_screen.dart';
import 'search_screen.dart';
import 'student_dashboard.dart';
import 'profile_screen.dart';
import '../widgets/student_bottom_nav.dart';
import 'favourites_screen.dart';

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
    TopTutorData(name: "Anzala Abid", expertise: "English Specialist"),
    TopTutorData(name: "Emaz Ali", expertise: "Tech Mentor"),
    TopTutorData(name: "Rafay Zahid", expertise: "CS Instructor"),
  ];

  List<TopTutorData> filteredTutors = [];
  int _selectedIndex = 1; // Search/Discovery tab

  @override
  void initState() {
    super.initState();
    filteredTutors = allTutors;
  }

  void _runFilter(String enteredKeyword) {
    List<TopTutorData> results = [];
    if (enteredKeyword.isEmpty) {
      results = allTutors;
    } else {
      results = allTutors
          .where((tutor) =>
      tutor.name.toLowerCase().contains(enteredKeyword.toLowerCase()) ||
          tutor.expertise.toLowerCase().contains(enteredKeyword.toLowerCase()))
          .toList();
    }
    setState(() {
      filteredTutors = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      extendBody: true,
      body: Column(
        children: [
          _buildWhiteHeader(context),
          // --- Functional Search Bar ---
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 25, 20, 10),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  )
                ],
              ),
              child: TextField(
                onChanged: (value) => _runFilter(value),
                cursorColor: Colors.black,
                decoration: InputDecoration(
                  hintText: "Search tutors...",
                  hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                  prefixIcon: const Icon(Icons.search, color: Colors.black54),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ),
          // --- Tutors List ---
          Expanded(
            child: filteredTutors.isNotEmpty
                ? ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 120),
              physics: const BouncingScrollPhysics(),
              itemCount: filteredTutors.length,
              separatorBuilder: (context, index) => const SizedBox(height: 15),
              itemBuilder: (context, index) {
                return _buildTutorCard(filteredTutors[index]);
              },
            )
                : const Center(
              child: Text(
                'No tutors found',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: StudentBottomNav(
        currentIndex: _selectedIndex,
        onTap: (index) {
          if (index == _selectedIndex) return;

          setState(() {
            _selectedIndex = index;
          });

          // Navigation Logic
          switch (index) {
            case 0:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const StudentDashboard()),
              );
              break;
            case 1:
              // Navigator.pushReplacement(
              //   context,
              //   MaterialPageRoute(builder: (context) => const ConnectionScreen()),
              // );
              break;
            case 2:
            // Navigator.pushReplacement(
            //   context,
            //   MaterialPageRoute(builder: (context) => const InboxScreen()),
            // );
              break;
            case 3:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const FavouritesScreen()),
              );
              break;
            case 4:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
              break;
          }
        },
      ),
    );
  }

  Widget _buildWhiteHeader(BuildContext context) {
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
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 15,
            offset: const Offset(0, 8),
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
              decoration: const BoxDecoration(
                color: Colors.black,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
            ),
          ),
          const Text(
            "Top Tutor",
            style: TextStyle(
              color: Color(0xFF1A1C43),
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SearchScreen()),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.search, color: Colors.black87, size: 22),
            ),
          ),
        ],
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
              tutorData: {
                'name': tutor.name,
                'sub': tutor.expertise,
              },
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
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    tutor.expertise,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
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
}