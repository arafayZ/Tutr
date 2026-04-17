import 'package:flutter/material.dart';

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
  // Original master list
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

  // List that will actually be displayed
  List<TopTutorData> filteredTutors = [];

  @override
  void initState() {
    super.initState();
    // Initialize with all data
    filteredTutors = allTutors;
  }

  // Search Logic
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
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                children: [
                  _circleIconButton(
                    icon: Icons.arrow_back,
                    onTap: () => Navigator.pop(context),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        "Top Tutor",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 45),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
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
                onChanged: (value) => _runFilter(value), // Trigger filtering
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
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
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
              padding: const EdgeInsets.all(20),
              physics: const BouncingScrollPhysics(),
              itemCount: filteredTutors.length,
              separatorBuilder: (context, index) => const SizedBox(height: 15),
              itemBuilder: (context, index) {
                return Container(
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
                        child: Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 15),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            filteredTutors[index].name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF000000),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            filteredTutors[index].expertise,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
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
    );
  }

  Widget _circleIconButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: const BoxDecoration(
          color: Colors.black,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}