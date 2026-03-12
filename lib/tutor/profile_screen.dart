// Import Flutter's material design widgets
import 'package:flutter/material.dart';
// Import custom bottom navigation widget
import '../widgets/custom_bottom_nav.dart';
// Import the Add Course screen to navigate when FAB is pressed
import 'add_course_screen.dart';
// Import the Security screen
import 'security_screen.dart';
// --- NEW IMPORT ---
import 'unavailable_courses_screen.dart';

// ==============================
// 1. PROFILE SCREEN (Stateful)
// ==============================
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

// ==============================
// 2. STATE CLASS
// ==============================
class _ProfileScreenState extends State<ProfileScreen> {
  // User's name
  final String userName = "Abdul Rafay";
  // User's email
  final String userEmail = "rafay123@gmail.com";
  // User's profile image URL (null means default image will be used)
  final String? profileImageUrl = null;

  // ==============================
  // LOGOUT POPUP DIALOG FUNCTION
  // ==============================
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.logout, color: Colors.red, size: 40),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Logout",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                const Text(
                  "Are you sure you want to logout from your account?",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, color: Colors.grey),
                ),
                const SizedBox(height: 30),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.grey),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text("Cancel", style: TextStyle(color: Colors.black)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            '/login',
                                (route) => false,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text("Logout", style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ==============================
  // BUILD METHOD
  // ==============================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      extendBody: true,

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddCourseScreen()),
          );
        },
        backgroundColor: Colors.black,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 35),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            const SizedBox(height: 80),

            // -----------------------------
            // PROFILE CARD WITH AVATAR
            // -----------------------------
            Center(
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.topCenter,
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width * 0.85,
                    margin: const EdgeInsets.only(top: 60),
                    padding: const EdgeInsets.fromLTRB(20, 75, 20, 30),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          userName,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          userEmail,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 35),

                        // -----------------------------
                        // PROFILE OPTIONS
                        // -----------------------------
                        _buildProfileOption(
                          Icons.person_outline,
                          "Edit Profile",
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              '/edit_profile',
                              arguments: {
                                'name': userName,
                                'email': userEmail,
                              },
                            );
                          },
                        ),
                        _buildProfileOption(
                          Icons.shield_outlined,
                          "Security",
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const SecurityScreen()),
                            );
                          },
                        ),
                        _buildProfileOption(
                          Icons.description_outlined,
                          "Terms & Conditions",
                          onTap: () {
                            Navigator.pushNamed(context, '/terms_conditions');
                          },
                        ),
                        // --- UPDATED UNAVAILABLE COURSES NAVIGATION ---
                        _buildProfileOption(
                          Icons.remove_circle_outline,
                          "Unavailable Courses",
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const UnavailableCoursesScreen()),
                            );
                          },
                        ),

                        _buildProfileOption(
                          Icons.logout,
                          "Logout",
                          onTap: () => _showLogoutDialog(context),
                        ),
                      ],
                    ),
                  ),

                  // -----------------------------
                  // PROFILE AVATAR
                  // -----------------------------
                  Positioned(
                    top: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.black, width: 2),
                      ),
                      child: CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.grey[200],
                        backgroundImage: profileImageUrl != null
                            ? NetworkImage(profileImageUrl!)
                            : const AssetImage('assets/images/rafay.jpeg') as ImageProvider,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 150),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNav(currentIndex: 3),
    );
  }

  Widget _buildProfileOption(IconData icon, String label, {required VoidCallback onTap}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8),
          child: Row(
            children: [
              Icon(icon, size: 24, color: Colors.black87),
              const SizedBox(width: 15),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black),
            ],
          ),
        ),
      ),
    );
  }
}