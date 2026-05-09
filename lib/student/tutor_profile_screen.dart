import 'package:flutter/material.dart';
import 'course_details_screen.dart';

class TutorProfileScreen extends StatefulWidget {
  final Map<String, dynamic> tutorData;

  const TutorProfileScreen({super.key, required this.tutorData});

  @override
  State<TutorProfileScreen> createState() => _TutorProfileScreenState();
}

class _TutorProfileScreenState extends State<TutorProfileScreen> {
  bool showAbout = true;
  String selectedMode = "Online";
  String? selectedReportReason;

  final List<Map<String, dynamic>> allCourses = [
    {"title": "Physics", "price": "2000 PKR", "level": "Matric", "color": Colors.red.shade900, "isLiked": false, "mode": "Online"},
    {"title": "English", "price": "2200 PKR", "level": "Intermediate", "color": Colors.red.shade400, "isLiked": false, "mode": "Online"},
    {"title": "Mathematics", "price": "2500 PKR", "level": "O Level", "color": Colors.purple.shade700, "isLiked": true, "mode": "Student Home"},
  ];

  // --- POPUP DIALOGS ---
  void _showBlockDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text("Block user?", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A1C43))),
          content: const Text("You won't receive messages or offers from them."),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("CANCEL", style: TextStyle(color: Colors.grey))),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close confirm dialog
                _showSuccessPopup(context, "Tutor Blocked", "This tutor will no longer appear in your searches.", true);
              },
              child: const Text("BLOCK", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  void _showSuccessPopup(BuildContext context, String title, String subtitle, bool shouldExitProfile) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        // Auto-close timer for 2 seconds
        Future.delayed(const Duration(seconds: 2), () {
          if (Navigator.canPop(context)) {
            Navigator.pop(context); // Close popup
            if (shouldExitProfile) Navigator.pop(context); // Go back to connections list
          }
        });

        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 60),
              const SizedBox(height: 20),
              Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey)),
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
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.block, color: Colors.red),
            onPressed: () => _showBlockDialog(context),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildProfileIdentity(),
            const SizedBox(height: 20),
            _buildStatsSection(),
            const SizedBox(height: 20),
            _buildToggleTabs(),
            const SizedBox(height: 10),
            showAbout ? _buildAboutContent() : _buildCoursesContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileIdentity() {
    return Column(
      children: [
        const CircleAvatar(radius: 50, backgroundColor: Colors.black),
        const SizedBox(height: 15),
        Text(widget.tutorData['name'] ?? "Tutor Name",
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1A1C43))),
        Text(widget.tutorData['subject'] ?? "Expertise",
            style: const TextStyle(fontSize: 16, color: Colors.grey)),
      ],
    );
  }

  Widget _buildStatsSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _StatItem(value: widget.tutorData['rating'] ?? "0.0", label: "Rating"),
        const _StatItem(value: "150+", label: "Reviews"),
        _StatItem(value: widget.tutorData['level'] ?? "Expert", label: "Level"),
      ],
    );
  }

  Widget _buildToggleTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Row(
        children: [
          Expanded(child: _buildMainTab("About", showAbout, () => setState(() => showAbout = true))),
          const SizedBox(width: 15),
          Expanded(child: _buildMainTab("Courses", !showAbout, () => setState(() => showAbout = false))),
        ],
      ),
    );
  }

  Widget _buildMainTab(String title, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? Colors.black : Colors.white,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: isActive ? Colors.black : Colors.grey.shade300),
        ),
        child: Center(
          child: Text(title, style: TextStyle(color: isActive ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _buildAboutContent() {
    return Padding(
      padding: const EdgeInsets.all(25.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Bio", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          const Text(
            "Experienced tutor specializing in high-level education with a focus on student growth and conceptual clarity.",
            style: TextStyle(color: Colors.grey, height: 1.5),
          ),
          const SizedBox(height: 20),
          _buildAboutRow(Icons.location_on, "Location", "Karachi, Pakistan"),
          _buildAboutRow(Icons.language, "Language", "English, Urdu"),
        ],
      ),
    );
  }

  Widget _buildAboutRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue, size: 20),
          const SizedBox(width: 15),
          Text("$title: ", style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildCoursesContent() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 25),
      itemCount: allCourses.length,
      itemBuilder: (context, index) {
        final course = allCourses[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: ListTile(
            title: Text(course['title'], style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(course['level']),
            trailing: Text(course['price'], style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
          ),
        );
      },
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value, label;
  const _StatItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A1C43))),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}