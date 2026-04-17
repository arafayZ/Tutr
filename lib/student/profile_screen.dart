import 'package:flutter/material.dart';
import '../tutor/terms_conditions_screen.dart';
import 'edit_profile_screen.dart';
import '../tutor/security_screen.dart';
import 'block_tutor_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: Column(
        children: [
          const SizedBox(height: 60),
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.85,
              padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  )
                ],
              ),
              child: Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.black, width: 2),
                        ),
                        child: const CircleAvatar(
                          radius: 50,
                          backgroundImage: AssetImage('assets/images/rafay.jpeg'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    "Abdul Rafay",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  const Text(
                    "abdulrafay@gmail.com",
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 30),

                  _buildProfileOption(Icons.person_outline, "Edit Profile", () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const EditProfileScreen()),
                    );
                  }),

                  _buildProfileOption(Icons.security_outlined, "Security", () {
                    Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SecurityScreen()),
                  );}),

                  _buildProfileOption(Icons.verified_user_outlined, "Terms & Conditions", () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TermsConditionsScreen(),
                      ),
                    );
                  }),

                  _buildProfileOption(Icons.remove_circle_outline, "Block tutor", () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const BlockTutorScreen(),
                      ),
                    );
                  }),

                  // UPDATED: Logout Logic
                  _buildProfileOption(Icons.power_settings_new_rounded, "Logout", () {
                    _showLogoutDialog(context);
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Logout Confirmation Dialog ---
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Logout"),
          content: const Text("Are you sure you want to logout?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                // Navigates to Login and removes all previous screens from the stack
                Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
              },
              child: const Text("Logout", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildProfileOption(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: Colors.black87, size: 22),
      title: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black87),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black),
    );
  }
}