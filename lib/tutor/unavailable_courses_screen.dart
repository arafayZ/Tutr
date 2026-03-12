import 'package:flutter/material.dart';

class UnavailableCoursesScreen extends StatelessWidget {
  const UnavailableCoursesScreen({super.key});

  final List<Map<String, dynamic>> _courses = const [
    {"title": "Physics", "price": "2000 PKR", "rating": 4.2, "level": "Matric", "students": 23, "color": Color(0xFF8C1414)},
    {"title": "Chemistry", "price": "2500 PKR", "rating": 4.5, "level": "Inter", "students": 45, "color": Color(0xFF144D8C)},
    {"title": "Maths", "price": "1800 PKR", "rating": 4.8, "level": "Matric", "students": 12, "color": Color(0xFF148C4E)},
  ];

  // --- REUSABLE POPUP DIALOG ---
  void _showAvailablePopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text(
            "Make Yourself Available?",
            style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E232C)),
          ),
          content: const Text(
            "Are you sure you want to become available? New students will be able to book sessions.",
            style: TextStyle(color: Color(0xFF6A707C), fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "CANCEL",
                style: TextStyle(color: Color(0xFF1E232C), fontWeight: FontWeight.bold),
              ),
            ),
            TextButton(
              onPressed: () {
                // Logic for availability update goes here
                Navigator.pop(context);
              },
              child: const Text(
                "CONFIRM",
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: SafeArea(
        child: Column(
          children: [
            // --- HEADER ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      height: 40, width: 40,
                      decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle),
                      child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                    ),
                  ),
                  const Expanded(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.only(right: 40),
                        child: Text("Unavailable Courses", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // --- LIST ---
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(20),
                physics: const BouncingScrollPhysics(),
                itemCount: _courses.length,
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CourseDetailScreen(course: _courses[index], onAvailableTap: () => _showAvailablePopup(context)),
                        ),
                      );
                    },
                    child: _buildCourseCard(context, _courses[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCourseCard(BuildContext context, Map<String, dynamic> course) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5)),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 110,
              decoration: BoxDecoration(
                color: course['color'],
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), bottomLeft: Radius.circular(20)),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(child: Text(course['title'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
                        Row(children: [const Icon(Icons.star, color: Colors.orange, size: 16), Text(" ${course['rating']}", style: const TextStyle(fontSize: 13, color: Colors.grey))]),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(course['price'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)),
                        const SizedBox(width: 8),
                        Text(course['level'], style: const TextStyle(fontSize: 14, color: Color(0xFFB8BCC2))),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Text("ONLINE", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.red)),
                        const Padding(padding: EdgeInsets.symmetric(horizontal: 4), child: Text("|", style: TextStyle(fontSize: 11))),
                        Text("${course['students']} Student", style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // --- CLICKABLE AVAILABLE BUTTON ---
                    Align(
                      alignment: Alignment.bottomRight,
                      child: InkWell(
                        onTap: () => _showAvailablePopup(context),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
                          decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(12)),
                          child: const Text("Available", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CourseDetailScreen extends StatelessWidget {
  final Map<String, dynamic> course;
  final VoidCallback onAvailableTap;

  const CourseDetailScreen({super.key, required this.course, required this.onAvailableTap});

  @override
  Widget build(BuildContext context) {
    final double bgHeight = MediaQuery.of(context).size.height * 0.4;
    final double cardTopOffset = bgHeight * 0.6;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  height: bgHeight,
                  width: double.infinity,
                  color: course['color'],
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                              child: const Icon(Icons.arrow_back, color: Colors.black),
                            ),
                          ),
                          // --- TRIGGER POPUP FROM DETAIL SCREEN ---
                          GestureDetector(
                            onTap: onAvailableTap,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
                              child: const Text("Available", style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: cardTopOffset),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 25),
                    padding: const EdgeInsets.all(25),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10))
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(course['title'], style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                            Row(children: [const Icon(Icons.star, color: Colors.orange, size: 20), Text(" ${course['rating']}", style: const TextStyle(fontWeight: FontWeight.bold))]),
                          ],
                        ),
                        const SizedBox(height: 15),
                        Row(
                          children: [
                            const Icon(Icons.grid_view_rounded, size: 18),
                            const SizedBox(width: 5),
                            Text(course['level'], style: const TextStyle(fontWeight: FontWeight.w500)),
                            const SizedBox(width: 15),
                            const Icon(Icons.access_time, size: 18),
                            const SizedBox(width: 5),
                            const Text("2 Hours", style: TextStyle(fontWeight: FontWeight.w500)),
                            const Spacer(),
                            Text(course['price'], style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue)),
                          ],
                        ),
                        const SizedBox(height: 25),
                        const Text("About", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        Text(
                          "Master ${course['title']} with step-by-step guidance! Learn concepts clearly, practice numericals, and gain confidence for exams.",
                          style: const TextStyle(color: Colors.grey, height: 1.5),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("What You Provide", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  _detail(Icons.menu_book, "20 Classes per month"),
                  _detail(Icons.access_time, "6:00 P.M - 8:00 P.M"),
                  _detail(Icons.calendar_month, "Monday to Friday"),
                  _detail(Icons.wifi, "Online"),
                  _detail(Icons.location_on, "Nazimabad, Karachi"),
                  const SizedBox(height: 30),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE0E0E0),
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          ),
                          child: const Text("Delete"),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          ),
                          child: const Text("Edit"),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: MediaQuery.of(context).padding.bottom + 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detail(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(
        children: [
          Icon(icon, size: 24),
          const SizedBox(width: 15),
          Text(text, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}