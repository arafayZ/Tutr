// Import Flutter's material design widgets
import 'package:flutter/material.dart';
// Import custom bottom navigation widget
import '../widgets/custom_bottom_nav.dart';
// Import the Add Course screen to navigate when FAB is pressed
import 'add_course_screen.dart';

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
    // Display a dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.white, // Dialog background color
          surfaceTintColor: Colors.white, // For Material3
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), // Rounded edges
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min, // Wrap content vertically
              children: [
                // Circular icon for logout warning
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1), // Light red background
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.logout, color: Colors.red, size: 40),
                ),
                const SizedBox(height: 20), // Spacer

                // Dialog title
                const Text(
                  "Logout",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),

                // Dialog description
                const Text(
                  "Are you sure you want to logout from your account?",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, color: Colors.grey),
                ),
                const SizedBox(height: 30),

                // Buttons row: Cancel and Logout
                Row(
                  children: [
                    // Cancel button
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context), // Close dialog
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.grey),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text("Cancel", style: TextStyle(color: Colors.black)),
                      ),
                    ),
                    const SizedBox(width: 12), // Spacer between buttons

                    // Logout button
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          // Navigate to login screen and remove all previous routes
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
      backgroundColor: const Color(0xFFF8F9FB), // Screen background color
      extendBody: true, // Extend body for floating button overlap

      // -----------------------------
      // FLOATING ACTION BUTTON (Add Course)
      // -----------------------------
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to Add Course Screen
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddCourseScreen()),
          );
        },
        backgroundColor: Colors.black, // Button color
        shape: const CircleBorder(), // Circular shape
        child: const Icon(Icons.add, color: Colors.white, size: 35), // Icon
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // -----------------------------
      // BODY
      // -----------------------------
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(), // Smooth scrolling with bounce
        child: Column(
          children: [
            const SizedBox(height: 80), // Top spacing

            // -----------------------------
            // PROFILE CARD WITH AVATAR
            // -----------------------------
            Center(
              child: Stack(
                clipBehavior: Clip.none, // Allow avatar to overflow
                alignment: Alignment.topCenter,
                children: [
                  // Card container with details and options
                  Container(
                    width: MediaQuery.of(context).size.width * 0.85, // 85% width
                    margin: const EdgeInsets.only(top: 60), // Push down to make space for avatar
                    padding: const EdgeInsets.fromLTRB(20, 75, 20, 30),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05), // Subtle shadow
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // User name
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

                        // User email
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
                            // Navigate to edit profile screen with arguments
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
                        _buildProfileOption(Icons.shield_outlined, "Security", onTap: () {}),
                        _buildProfileOption(
                          Icons.description_outlined,
                          "Terms & Conditions",
                          onTap: () {
                            Navigator.pushNamed(context, '/terms_conditions');
                          },
                        ),
                        _buildProfileOption(Icons.remove_circle_outline, "Unavailable Courses", onTap: () {}),

                        // Logout option
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
                    top: 0, // Avatar at the top of the card
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.black, width: 2), // Border around avatar
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

            // -----------------------------
            // SAFE SPACE AT THE BOTTOM
            // -----------------------------
            const SizedBox(height: 150), // Prevent bottom nav overlap
          ],
        ),
      ),

      // -----------------------------
      // BOTTOM NAVIGATION
      // -----------------------------
      bottomNavigationBar: const CustomBottomNav(currentIndex: 3), // Highlight profile tab
    );
  }

  // ==============================
  // WIDGET BUILDER: PROFILE OPTIONS
  // ==============================
  Widget _buildProfileOption(IconData icon, String label, {required VoidCallback onTap}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap, // Action when tapped
        borderRadius: BorderRadius.circular(10), // Ripple shape
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8),
          child: Row(
            children: [
              Icon(icon, size: 24, color: Colors.black87), // Option icon
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
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black), // Forward arrow
            ],
          ),
        ),
      ),
    );
  }
}