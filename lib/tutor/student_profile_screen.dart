import 'package:flutter/material.dart';
import 'chat_details_screen.dart';

class StudentDetails {
  final String id;
  final String name, profilePic, location, dob, gender, college, school, phone, email;

  StudentDetails({
    required this.id,
    required this.name,
    required this.profilePic,
    required this.location,
    required this.dob,
    required this.gender,
    required this.college,
    required this.school,
    required this.phone,
    required this.email,
  });
}

class StudentProfileScreen extends StatefulWidget {
  final StudentDetails student;
  final Function(String) onDisconnect;

  const StudentProfileScreen({super.key, required this.student, required this.onDisconnect});

  @override
  State<StudentProfileScreen> createState() => _StudentProfileScreenState();
}

class _StudentProfileScreenState extends State<StudentProfileScreen> {
  String? activeBtn;

  void _showDisconnectDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          title: const Text("Disconnect", style: TextStyle(fontWeight: FontWeight.bold)),
          content: Text("Are you sure you want to disconnect from ${widget.student.name}?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel", style: TextStyle(color: Colors.black54)),
            ),
            TextButton(
              onPressed: () {
                widget.onDisconnect(widget.student.id);
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text("Disconnect", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
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
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 40),
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.topCenter,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 80, 20, 0),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.fromLTRB(25, 85, 25, 25),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              )
                            ],
                          ),
                          child: Column(
                            children: [
                              Text(widget.student.name,
                                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 20),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      setState(() => activeBtn = "message");
                                      Navigator.push(context, MaterialPageRoute(
                                          builder: (context) => ChatDetailsScreen(userName: widget.student.name)));
                                    },
                                    child: _buildAdaptiveButton(label: "Message", id: "message"),
                                  ),
                                  const SizedBox(width: 12),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() => activeBtn = "disconnect");
                                      _showDisconnectDialog();
                                    },
                                    child: _buildAdaptiveButton(label: "Disconnect", id: "disconnect"),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 40),

                              _buildSectionHeader("Personal Details"),
                              _buildDetailRow(Icons.location_on_outlined, "Location", widget.student.location),
                              _buildDetailRow(Icons.calendar_month_outlined, "Date Of Birth", widget.student.dob),
                              _buildDetailRow(Icons.person_outline, "Gender", widget.student.gender),

                              const SizedBox(height: 35),
                              _buildSectionHeader("Education"),
                              _buildDetailRow(Icons.school_outlined, "College", widget.student.college),
                              _buildDetailRow(Icons.business_outlined, "School", widget.student.school),

                              const SizedBox(height: 35),
                              _buildSectionHeader("Contact Info"),
                              _buildDetailRow(Icons.phone_android_outlined, "Phone", widget.student.phone),
                              _buildDetailRow(Icons.mail_outline, "Email", widget.student.email),

                              const SizedBox(height: 10),
                            ],
                          ),
                        ),
                      ),
                      Positioned(top: 15, child: _buildAvatar(65, widget.student.profilePic)),
                    ],
                  ),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      height: 120,
      padding: const EdgeInsets.only(top: 50, left: 20, right: 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 2),
          )
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: InkWell(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 45,
                height: 45,
                decoration: const BoxDecoration(
                  color: Colors.black,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back, color: Colors.white, size: 22),
              ),
            ),
          ),
          const Text(
            "Student Profile",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdaptiveButton({required String label, required String id}) {
    bool isSelected = activeBtn == id;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
      decoration: BoxDecoration(
        color: isSelected ? Colors.black : Colors.white,
        border: isSelected ? null : Border.all(color: Colors.black12),
        borderRadius: BorderRadius.circular(30),
        boxShadow: isSelected
            ? [BoxShadow(color: Colors.black26, blurRadius: 8, offset: const Offset(0, 4))]
            : null,
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.black87,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildAvatar(double radius, String imgPath) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle),
      child: CircleAvatar(
        radius: radius,
        backgroundColor: Colors.white,
        backgroundImage: AssetImage(imgPath),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(
          title.toUpperCase(),
          style: const TextStyle(
            color: Colors.black45,
            fontSize: 11,
            letterSpacing: 1.2,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 22, color: Colors.black),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Label is now Black and Bold
                Text(label,
                    style: const TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.bold
                    )
                ),
                const SizedBox(height: 1),
                // Answer is now Grey
                Text(value,
                    style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        color: Colors.grey
                    )
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}