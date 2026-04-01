import 'package:flutter/material.dart';
import 'edit_course_screen.dart';

class CourseDetailScreen extends StatefulWidget {
  final Map<String, dynamic> course;
  final VoidCallback onAvailableTap;
  final bool showAvailableBtn;
  final Function(Map<String, dynamic>) onDelete;

  const CourseDetailScreen({
    super.key,
    required this.course,
    required this.onAvailableTap,
    required this.onDelete,
    this.showAvailableBtn = true,
  });

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
  late Map<String, dynamic> currentCourse;

  @override
  void initState() {
    super.initState();
    currentCourse = Map.from(widget.course);
  }

  // Helper to handle the toggle and return data to the calling screen
  void _toggleAvailability(String newStatus) {
    setState(() {
      currentCourse['status'] = newStatus;
    });
    // This pops the screen and sends the updated course map back
    Navigator.pop(context, currentCourse);
    // Keep the callback for any specific logic in parent
    widget.onAvailableTap();
  }

  IconData _getModeIcon(String mode) {
    final lowerMode = mode.toLowerCase();
    if (lowerMode.contains('online')) return Icons.wifi;
    if (lowerMode.contains('home') || lowerMode.contains('physical')) return Icons.home_rounded;
    return Icons.location_on_outlined;
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Delete subject?", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              const Text("This action cannot be undone.", style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(onPressed: () => Navigator.pop(context), child: const Text("CANCEL", style: TextStyle(color: Colors.black))),
                  const SizedBox(width: 20),
                  TextButton(
                    onPressed: () {
                      widget.onDelete(currentCourse);
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                    child: const Text("DELETE", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double bgHeight = MediaQuery.of(context).size.height * 0.4;
    final bool isUnavailable = currentCourse['status'] == 'Unavailable';

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
                              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                              child: const Icon(Icons.arrow_back, color: Colors.black),
                            ),
                          ),
                          if (!isUnavailable)
                            Theme(
                              data: Theme.of(context).copyWith(cardColor: Colors.white),
                              child: PopupMenuButton<String>(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                icon: const Icon(Icons.more_vert, color: Colors.white, size: 28),
                                onSelected: (value) => _toggleAvailability('Unavailable'),
                                itemBuilder: (context) => [
                                  const PopupMenuItem(
                                    value: 'toggle',
                                    child: Text("Make Unavailable", style: TextStyle(fontWeight: FontWeight.w500)),
                                  ),
                                ],
                              ),
                            )
                          else
                            GestureDetector(
                              onTap: () => _toggleAvailability('Available'),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(15)
                                ),
                                child: const Text("Available", style: TextStyle(fontWeight: FontWeight.bold)),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                // --- Rest of your UI Content Card logic remains the same ---
                Padding(
                  padding: EdgeInsets.only(top: bgHeight * 0.6),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 25),
                    padding: const EdgeInsets.all(25),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [const BoxShadow(color: Colors.black12, blurRadius: 20, offset: Offset(0, 10))],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(currentCourse['title'] ?? "Course Detail", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                            Row(
                              children: [
                                const Icon(Icons.star, color: Colors.orange, size: 20),
                                Text(" ${currentCourse['rating']}", style: const TextStyle(fontWeight: FontWeight.bold))
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),
                        Row(
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  const Icon(Icons.grid_view_rounded, size: 18),
                                  const SizedBox(width: 5),
                                  Flexible(child: Text(currentCourse['level'] ?? "N/A", style: const TextStyle(fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis)),
                                  const SizedBox(width: 12),
                                  const Icon(Icons.access_time, size: 18),
                                  const SizedBox(width: 5),
                                  const Text("2 Hours", style: TextStyle(fontWeight: FontWeight.w500)),
                                ],
                              ),
                            ),
                            Text(currentCourse['price'] ?? "0 PKR", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)),
                          ],
                        ),
                        const SizedBox(height: 25),
                        const Text("About", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        Text(currentCourse['about'] ?? "Course details go here.", style: const TextStyle(color: Colors.grey, height: 1.5)),
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
                  _detail(_getModeIcon(currentCourse['mode'] ?? "Online"), currentCourse['mode'] ?? "Online"),
                  _detail(Icons.location_on, currentCourse['location'] ?? "Karachi, Pakistan"),
                  const SizedBox(height: 30),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _showDeleteConfirmation(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE0E0E0),
                            foregroundColor: Colors.black,
                            elevation: 0,
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
                            final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => EditCourseScreen(course: currentCourse)));
                            if (result != null && result is Map<String, dynamic>) {
                              setState(() => currentCourse = result);
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
          Icon(icon, size: 24, color: Colors.black87),
          const SizedBox(width: 15),
          Text(text, style: const TextStyle(fontSize: 16))
        ],
      ),
    );
  }
}