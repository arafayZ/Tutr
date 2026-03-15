import 'package:flutter/material.dart';
import 'course_detail_screen.dart';

class UnavailableCoursesScreen extends StatefulWidget {
  const UnavailableCoursesScreen({super.key});

  @override
  State<UnavailableCoursesScreen> createState() => _UnavailableCoursesScreenState();
}

class _UnavailableCoursesScreenState extends State<UnavailableCoursesScreen> {
  final List<Map<String, dynamic>> _courses = [
    {
      "title": "Physics",
      "price": "2000 PKR",
      "rating": "4.2",
      "level": "Matric",
      "students": 23,
      "color": const Color(0xFF8C1414),
      "mode": "Online",
      "location": "Nazimabad, Karachi",
      "about": "Advanced Physics concepts for Matric students."
    },
    {
      "title": "Chemistry",
      "price": "2500 PKR",
      "rating": "4.5",
      "level": "Inter",
      "students": 45,
      "color": const Color(0xFF144D8C),
      "mode": "Online",
      "location": "Gulshan, Karachi",
      "about": "Organic and Inorganic chemistry deep dive."
    },
    {
      "title": "Maths",
      "price": "1800 PKR",
      "rating": "4.8",
      "level": "Matric",
      "students": 12,
      "color": const Color(0xFF148C4E),
      "mode": "Online",
      "location": "DHA, Karachi",
      "about": "Algebra and Geometry simplified."
    },
  ];

  void _showAvailablePopup(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text(
            "Make Yourself Available?",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          content: const Text(
            "Are you sure you want to become available? New students will be able to book sessions.",
            style: TextStyle(color: Colors.black87, fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "CANCEL",
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  _courses.removeAt(index);
                });
                _showSuccessDialog(context);
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

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        Future.delayed(const Duration(seconds: 5), () {
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          }
        });

        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 20),
              Icon(Icons.check_circle, color: Colors.green, size: 60),
              SizedBox(height: 20),
              Text(
                "Success!",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                "Course marked as Available!",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              SizedBox(height: 30),
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                strokeWidth: 3,
              ),
              SizedBox(height: 10),
            ],
          ),
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
            _buildHeader(context),
            Expanded(
              child: _courses.isEmpty
                  ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildEmptyState(),
              )
                  : ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                physics: const BouncingScrollPhysics(),
                itemCount: _courses.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CourseDetailScreen(
                            course: _courses[index],
                            onAvailableTap: () => _showAvailablePopup(context, index),
                            onDelete: (courseToDelete) {
                              setState(() {
                                _courses.removeAt(index);
                              });
                            },
                            showAvailableBtn: true,
                          ),
                        ),
                      );
                      setState(() {});
                    },
                    child: _buildCourseCard(context, _courses[index], index),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/cancel.png',
            width: 180,
            height: 180,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 25),
          const Text(
            "No Unavailable Courses",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Color(0xFFBDBDBD),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            "All your courses are currently active or haven't been added.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFFBDBDBD),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
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
          )
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              height: 40,
              width: 40,
              decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle),
              child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
            ),
          ),
          const Expanded(
            child: Center(
              child: Padding(
                padding: EdgeInsets.only(right: 40),
                child: Text(
                  "Unavailable Courses",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseCard(BuildContext context, Map<String, dynamic> course, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 85,
            height: 85,
            decoration: BoxDecoration(
              color: course['color'] ?? Colors.grey,
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      course['title'] ?? "Unknown",
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        Text(
                          " ${course['rating'] ?? '0.0'}",
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey),
                        )
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  "${course['price'] ?? ''} ${course['level'] ?? ''}",
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.blue),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    const Text("ONLINE", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.red)),
                    const Text(" | ", style: TextStyle(color: Colors.grey, fontSize: 10)),
                    Text("${course['students'] ?? 0} Student", style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                  ],
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () => _showAvailablePopup(context, index),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        "Available",
                        style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}