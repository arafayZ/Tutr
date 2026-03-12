import 'package:flutter/material.dart';
// Using a relative import so you don't need to worry about the package name
import 'course_detail_screen.dart';

class UnavailableCoursesScreen extends StatefulWidget {
  const UnavailableCoursesScreen({super.key});

  @override
  State<UnavailableCoursesScreen> createState() => _UnavailableCoursesScreenState();
}

class _UnavailableCoursesScreenState extends State<UnavailableCoursesScreen> {
  final List<Map<String, dynamic>> _courses = [
    {"title": "Physics", "price": "2000 PKR", "rating": 4.2, "level": "Matric", "students": 23, "color": const Color(0xFF8C1414)},
    {"title": "Chemistry", "price": "2500 PKR", "rating": 4.5, "level": "Inter", "students": 45, "color": const Color(0xFF144D8C)},
    {"title": "Maths", "price": "1800 PKR", "rating": 4.8, "level": "Matric", "students": 12, "color": const Color(0xFF148C4E)},
  ];

  void _deleteCourse(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Delete Course?", style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text("Are you sure you want to remove this course from your unavailable list?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("CANCEL", style: TextStyle(color: Colors.black)),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _courses.removeAt(index);
              });
              Navigator.pop(context);
            },
            child: const Text("DELETE", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showAvailablePopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text("Make Yourself Available?", style: TextStyle(fontWeight: FontWeight.bold)),
          content: const Text("Are you sure you want to become available? New students will be able to book sessions."),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("CANCEL", style: TextStyle(color: Colors.black))),
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("CONFIRM", style: TextStyle(color: Colors.red))),
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
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08), // Fixed deprecated method
                      blurRadius: 15,
                      offset: const Offset(0, 8)
                  )
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
                  const Expanded(child: Center(child: Padding(padding: EdgeInsets.only(right: 40), child: Text("Unavailable Courses", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))))),
                ],
              ),
            ),
            Expanded(
              child: _courses.isEmpty
                  ? const Center(child: Text("No unavailable courses found."))
                  : ListView.builder(
                padding: const EdgeInsets.all(20),
                physics: const BouncingScrollPhysics(),
                itemCount: _courses.length,
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CourseDetailScreen(
                              course: _courses[index],
                              onAvailableTap: () => _showAvailablePopup(context)
                          ),
                        ),
                      );

                      if (result == "delete") {
                        _deleteCourse(index);
                      }
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
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05), // Fixed deprecated method
              blurRadius: 10,
              offset: const Offset(0, 5)
          )
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 110,
              decoration: BoxDecoration(color: course['color'], borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), bottomLeft: Radius.circular(20))),
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
                    Text(course['price'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)),
                    const Spacer(),
                    Row(
                      children: [
                        const Text("ONLINE", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.red)),
                        const Text(" | ", style: TextStyle(fontSize: 11)),
                        Text("${course['students']} Student", style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 12),
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