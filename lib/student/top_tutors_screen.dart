import 'package:flutter/material.dart';

class TopTutorData {
  final String name;
  final String expertise;

  TopTutorData({required this.name, required this.expertise});
}

class TopTutorsScreen extends StatelessWidget {
  const TopTutorsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<TopTutorData> tutors = [
      TopTutorData(name: "Ahmed Khan", expertise: "Physics Expert"),
      TopTutorData(name: "Sara Malik", expertise: "Math Enthusiast"),
      TopTutorData(name: "Ali Raza", expertise: "Chemistry Specialist"),
      TopTutorData(name: "Hassan Javed", expertise: "English Coach"),
      TopTutorData(name: "Ayesha Khan", expertise: "Science Mentor"),
      TopTutorData(name: "Omar Farooq", expertise: "Biology Expert"),
      TopTutorData(name: "Hassan Javed", expertise: "English Coach"),
      TopTutorData(name: "Ayesha Khan", expertise: "Science Mentor"),
      TopTutorData(name: "Omar Farooq", expertise: "Biology Expert"),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
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
                color: Colors.black.withOpacity(0.05),
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
                        ),
                      ),
                    ),
                  ),
                  _circleIconButton(
                    icon: Icons.search,
                    onTap: () {}, // Search logic
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        physics: const BouncingScrollPhysics(),
        itemCount: tutors.length,
        separatorBuilder: (context, index) => const Divider(height: 30, color: Color(0xFFF1F1F1)),
        itemBuilder: (context, index) {
          return Row(
            children: [
              const CircleAvatar(
                radius: 35,
                backgroundColor: Colors.black, // Placeholder as per image
                child: Icon(Icons.person, color: Colors.white, size: 30),
              ),
              const SizedBox(width: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tutors[index].name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A237E),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    tutors[index].expertise,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          );
        },
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