import 'package:flutter/material.dart';
import 'edit_course_screen.dart';

class CourseDetailScreen extends StatefulWidget {
  final Map<String, dynamic> course;
  final VoidCallback onAvailableTap;
  // Logic: Control visibility based on which screen calls this
  final bool showAvailableBtn;

  const CourseDetailScreen({
    super.key,
    required this.course,
    required this.onAvailableTap,
    this.showAvailableBtn = true, // Default to true
  });

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
  late Map<String, dynamic> currentCourse;

  @override
  void initState() {
    super.initState();
    currentCourse = widget.course;
  }

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
                  // Added fallback color to prevent crash if 'color' is null
                  color: currentCourse['color'] ?? Colors.red[900],
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
                              decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle
                              ),
                              child: const Icon(Icons.arrow_back, color: Colors.black),
                            ),
                          ),

                          // --- CONDITIONAL AVAILABLE BUTTON ---
                          if (widget.showAvailableBtn)
                            GestureDetector(
                              onTap: widget.onAvailableTap,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(15)
                                ),
                                child: const Text(
                                    "Available",
                                    style: TextStyle(fontWeight: FontWeight.bold)
                                ),
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
                        BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 10)
                        )
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                                currentCourse['title'] ?? "Course Detail",
                                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)
                            ),
                            Row(
                              children: [
                                const Icon(Icons.star, color: Colors.orange, size: 20),
                                Text(
                                    " ${currentCourse['rating']}",
                                    style: const TextStyle(fontWeight: FontWeight.bold)
                                )
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),
                        Row(
                          children: [
                            const Icon(Icons.grid_view_rounded, size: 18),
                            const SizedBox(width: 5),
                            Text(
                                currentCourse['level'] ?? "N/A",
                                style: const TextStyle(fontWeight: FontWeight.w500)
                            ),
                            const SizedBox(width: 15),
                            const Icon(Icons.access_time, size: 18),
                            const SizedBox(width: 5),
                            const Text("2 Hours", style: TextStyle(fontWeight: FontWeight.w500)),
                            const Spacer(),
                            Text(
                                currentCourse['price'] ?? "0 PKR",
                                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue)
                            ),
                          ],
                        ),
                        const SizedBox(height: 25),
                        const Text("About", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        Text(
                            currentCourse['about'] ?? "Master ${currentCourse['title']} with step-by-step guidance!",
                            style: const TextStyle(color: Colors.grey, height: 1.5)
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
                  _detail(Icons.menu_book, "${currentCourse['students'] ?? 0} Classes per month"),
                  _detail(Icons.access_time, "6:00 P.M - 8:00 P.M"),
                  _detail(Icons.calendar_month, "Monday to Friday"),
                  _detail(Icons.wifi, currentCourse['mode'] ?? "Online"),
                  _detail(Icons.location_on, currentCourse['location'] ?? "Nazimabad, Karachi"),
                  const SizedBox(height: 30),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context, "delete"),
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
                          onPressed: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditCourseScreen(course: currentCourse),
                              ),
                            );

                            if (result != null && result is Map<String, dynamic>) {
                              setState(() {
                                currentCourse = result;
                              });
                            }
                          },
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
          Text(text, style: const TextStyle(fontSize: 16))
        ],
      ),
    );
  }
}