import 'package:flutter/material.dart';

class TutorProfileScreen extends StatelessWidget {
  final Map<String, dynamic> tutorData;

  const TutorProfileScreen({super.key, required this.tutorData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileHeader(context),
            const SizedBox(height: 25),
            _buildStatsSection(),
            const SizedBox(height: 25),
            _buildMessageButton(),
            const SizedBox(height: 30),
            _buildInfoCard(),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 50, 20, 30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(35),
          bottomRight: Radius.circular(35),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
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
              ),
              const Text(
                "Tutor Profile",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 25),
          const CircleAvatar(
            radius: 55,
            backgroundColor: Color(0xFFF1F4F4),
            child: Icon(Icons.person, size: 50, color: Colors.black),
          ),
          const SizedBox(height: 15),
          Text(
            tutorData['name'] ?? "Tutor Name",
            style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black
            ),
          ),
          const SizedBox(height: 5),
          Text(
            tutorData['sub'] ?? tutorData['expertise'] ?? "Instructor",
            style: const TextStyle(
                fontSize: 15,
                color: Colors.grey,
                fontWeight: FontWeight.w500
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _StatItem(value: "5", label: "Courses"),
        _StatItem(value: "25", label: "Students"),
        _StatItem(value: "16", label: "Ratings"),
      ],
    );
  }

  Widget _buildMessageButton() {
    return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.black,
        minimumSize: const Size(220, 55),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        elevation: 5,
        shadowColor: Colors.black.withValues(alpha: 0.3),
      ),
      child: const Text(
          "Message",
          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF1F4F4),
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(25)),
                  ),
                  child: const Center(
                      child: Text("About", style: TextStyle(fontWeight: FontWeight.bold))
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  child: const Center(
                      child: Text("Courses", style: TextStyle(color: Colors.grey))
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
                _sectionTitle("Personal Details"),
                const SizedBox(height: 15),
                _infoTile(Icons.location_on_outlined, "Location", "Karachi, Pakistan"),
                _infoTile(Icons.calendar_today_outlined, "Date of birth", "15 Dec 2001"),
                _infoTile(Icons.male, "Gender", "Male"),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Divider(color: Color(0xFFF1F4F4)),
                ),
                _sectionTitle("Education"),
                const SizedBox(height: 15),
                _infoTile(Icons.school_outlined, "University", "KIET"),
                _infoTile(Icons.account_balance_outlined, "High School", "MPSS"),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Divider(color: Color(0xFFF1F4F4)),
                ),
                _sectionTitle("Experience"),
                const SizedBox(height: 15),
                _infoTile(Icons.work_outline, "Total", "2 Years Teaching"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
        title,
        style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.black
        )
    );
  }

  Widget _infoTile(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.black54),
          const SizedBox(width: 15),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(color: Colors.black, fontSize: 14),
                children: [
                  TextSpan(
                      text: "$label: ",
                      style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.grey)
                  ),
                  TextSpan(text: value),
                ],
              ),
            ),
          ),
        ],
      ),
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
        Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)
        ),
        Text(
            label,
            style: const TextStyle(color: Colors.grey, fontSize: 13)
        ),
      ],
    );
  }
}