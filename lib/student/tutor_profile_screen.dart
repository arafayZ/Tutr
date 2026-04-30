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
    {
      "title": "Physics",
      "price": "2000 PKR",
      "level": "Matric",
      "color": Colors.red.shade900,
      "isLiked": false,
      "mode": "Online"
    },
    {
      "title": "English",
      "price": "2200 PKR",
      "level": "Intermediate",
      "color": Colors.red.shade400,
      "isLiked": false,
      "mode": "Online"
    },
    {
      "title": "Mathematics",
      "price": "2500 PKR",
      "level": "O Level",
      "color": Colors.purple.shade700,
      "isLiked": true,
      "mode": "Student Home"
    },
  ];

  // --- DIALOGS SECTION ---

  void _showBlockDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text(
            "Are you sure you want to block this user?",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A1C43)),
          ),
          content: const Text(
            "You won't receive messages or offers from them.",
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("CANCEL", style: TextStyle(color: Color(0xFF1A1C43), fontWeight: FontWeight.bold)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _showSuccessPopup(context, "Tutor Blocked Successfully", "This tutor will no longer appear in your searches.", true);
              },
              child: const Text("BLOCK", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  void _showReportDialog(BuildContext context) {
    selectedReportReason = null;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Text(
                "Report Tutor",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A1C43)),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Tell us what happened. Our team\nwill review it.",
                      style: TextStyle(fontSize: 13, color: Colors.grey)),
                  const SizedBox(height: 15),
                  _buildReportOption(setDialogState, "Spam or Fake Account"),
                  _buildReportOption(setDialogState, "Inappropriate Messages"),
                  _buildReportOption(setDialogState, "Harassment"),
                  _buildReportOption(setDialogState, "Wrong Information"),
                  _buildReportOption(setDialogState, "Payment Issues"),
                  _buildReportOption(setDialogState, "Other"),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("CANCEL", style: TextStyle(color: Color(0xFF1A1C43), fontWeight: FontWeight.bold)),
                ),
                TextButton(
                  onPressed: selectedReportReason == null
                      ? null
                      : () {
                    Navigator.pop(context);
                    _showSuccessPopup(
                        context,
                        "Report Submitted",
                        "Thank you for letting us know. We will review this profile shortly.",
                        true
                    );
                  },
                  child: Text(
                    "REPORT",
                    style: TextStyle(
                      color: selectedReportReason == null ? Colors.grey : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildReportOption(StateSetter setDialogState, String title) {
    return InkWell(
      onTap: () => setDialogState(() => selectedReportReason = title),
      child: Row(
        children: [
          Radio<String>(
            value: title,
            groupValue: selectedReportReason,
            activeColor: const Color(0xFF1A1C43),
            onChanged: (value) => setDialogState(() => selectedReportReason = value),
          ),
          Text(title, style: const TextStyle(fontSize: 14, color: Color(0xFF1A1C43))),
        ],
      ),
    );
  }

  void _showSuccessPopup(BuildContext context, String title, String subtitle, bool shouldExitProfile) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              const Icon(Icons.check_circle, color: Colors.green, size: 60),
              const SizedBox(height: 20),
              Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A1C43))),
              const SizedBox(height: 10),
              Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, color: Colors.grey)),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    if (shouldExitProfile) Navigator.pop(context);
                  },
                  child: const Text("OK", style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // --- BUILD METHODS ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: Column(
        children: [
          _buildConsistentHeader(context),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  _buildTopActions(),
                  _buildProfileIdentity(),
                  const SizedBox(height: 25),
                  _buildStatsSection(),
                  const SizedBox(height: 25),
                  _buildMessageButton(),
                  const SizedBox(height: 30),
                  _buildInfoCard(),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConsistentHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(35), bottomRight: Radius.circular(35)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 15, offset: const Offset(0, 4))],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle),
                child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
              ),
            ),
          ),
          const Text("Tutor Profile", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A1C43))),
        ],
      ),
    );
  }

  Widget _buildTopActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onSelected: (value) {
              if (value == 'Block') _showBlockDialog(context);
              if (value == 'Report') _showReportDialog(context);
            },
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'Block', child: Row(children: [Icon(Icons.block, color: Colors.red, size: 20), SizedBox(width: 10), Text('Block')])),
              const PopupMenuItem(value: 'Report', child: Row(children: [Icon(Icons.report_problem_outlined, color: Colors.orange, size: 20), SizedBox(width: 10), Text('Report')])),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfileIdentity() {
    return Column(
      children: [
        const CircleAvatar(radius: 55, backgroundColor: Colors.black, child: Icon(Icons.person, size: 50, color: Colors.white)),
        const SizedBox(height: 15),
        Text(widget.tutorData['name'] ?? "Asim Ali Khan", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1A1C43))),
        Text(widget.tutorData['sub'] ?? "CS Student", style: const TextStyle(fontSize: 14, color: Colors.grey)),
      ],
    );
  }

  Widget _buildStatsSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _StatItem(value: widget.tutorData['courses'] ?? "26", label: "Courses"),
        _StatItem(value: widget.tutorData['students'] ?? "15800", label: "Students"),
        _StatItem(value: widget.tutorData['ratings'] ?? "8750", label: "Ratings"),
      ],
    );
  }

  Widget _buildMessageButton() {
    return Container(
      width: 220,
      height: 55,
      decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 5))]),
      child: const Center(child: Text("Message", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold))),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(25), border: Border.all(color: Colors.grey.shade200)),
      child: Column(
        children: [
          Row(
            children: [
              _buildMainTab("About", showAbout, () => setState(() => showAbout = true)),
              _buildMainTab("Courses", !showAbout, () => setState(() => showAbout = false)),
            ],
          ),
          Padding(padding: const EdgeInsets.all(20), child: showAbout ? _buildAboutContent() : _buildCoursesContent()),
        ],
      ),
    );
  }

  Widget _buildMainTab(String title, bool isActive, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 15),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFFD1D5DB) : const Color(0xFFE5E7EB),
            borderRadius: BorderRadius.only(
              topLeft: title == "About" ? const Radius.circular(25) : Radius.zero,
              topRight: title == "Courses" ? const Radius.circular(25) : Radius.zero,
            ),
          ),
          child: Center(child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1A1C43)))),
        ),
      ),
    );
  }

  Widget _buildAboutContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Personal Details", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1A1C43))),
        const SizedBox(height: 15),
        _buildAboutRow(Icons.location_on_outlined, "Location", "Nazimabad"),
        _buildAboutRow(Icons.calendar_month_outlined, "Date of birth", "15 December 2001"),
        _buildAboutRow(Icons.wc_outlined, "Gender", "Male"),
        const SizedBox(height: 25),
        const Text("Education", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1A1C43))),
        const SizedBox(height: 15),
        _buildAboutRow(Icons.school_outlined, "University", "KIET"),
        _buildAboutRow(Icons.account_balance_outlined, "High School", "Private"),
      ],
    );
  }

  Widget _buildAboutRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          Icon(icon, size: 24, color: Colors.black),
          const SizedBox(width: 15),
          RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 14, color: Colors.black),
              children: [
                TextSpan(text: "$label: ", style: const TextStyle(fontWeight: FontWeight.bold)),
                TextSpan(text: value, style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoursesContent() {
    final filteredCourses = allCourses.where((c) => c['mode'] == selectedMode).toList();
    return Column(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(children: [_buildModeChip("Online"), const SizedBox(width: 10), _buildModeChip("Student Home"), const SizedBox(width: 10), _buildModeChip("Tutor Home")]),
        ),
        const SizedBox(height: 25),
        if (filteredCourses.isEmpty) _buildEmptyStateView() else Column(children: filteredCourses.map((c) => _buildCourseCard(c['title'], c['price'], c['level'], c['color'], c['isLiked'])).toList()),
      ],
    );
  }

  Widget _buildModeChip(String title) {
    bool isSelected = selectedMode == title;
    return GestureDetector(
      onTap: () => setState(() => selectedMode = title),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(color: isSelected ? Colors.black : const Color(0xFFE5E7EB), borderRadius: BorderRadius.circular(20)),
        child: Text(title, style: TextStyle(color: isSelected ? Colors.white : Colors.black, fontWeight: FontWeight.bold, fontSize: 12)),
      ),
    );
  }

  Widget _buildEmptyStateView() {
    return Column(
      children: [
        const SizedBox(height: 30),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: const Color(0xFFD1D5DB), width: 8)),
          child: const Icon(Icons.close, size: 80, color: Color(0xFFD1D5DB)),
        ),
        const SizedBox(height: 20),
        const Text("Mode Not Offered", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF9CA3AF))),
      ],
    );
  }

  Widget _buildCourseCard(String title, String price, String level, Color color, bool isLiked) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CourseDetailsScreen(
              courseData: {
                'sub': title,
                'price': price,
                'category': level,
                'color': color,
              },
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey.shade100)),
        child: Row(
          children: [
            Container(width: 80, height: 80, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(15))),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Asif Ali Khan", style: TextStyle(color: Colors.orange, fontSize: 10, fontWeight: FontWeight.bold)),
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  Text(price, style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 14)),
                ],
              ),
            ),
            Icon(isLiked ? Icons.favorite : Icons.favorite_border, color: isLiked ? Colors.red : Colors.black, size: 20),
          ],
        ),
      ),
    );
  }
}

// THIS CLASS MUST BE OUTSIDE THE STATE CLASS
class _StatItem extends StatelessWidget {
  final String value, label;
  const _StatItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF1A1C43))),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }
}