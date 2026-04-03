// Import Flutter's material design widgets
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
// Import custom bottom navigation widget
import '../widgets/custom_bottom_nav.dart';
// Import the Add Course screen to navigate when FAB is pressed
import 'add_course_screen.dart';
// Import the Security screen
import 'security_screen.dart';
// Import Unavailable Courses screen
import 'unavailable_courses_screen.dart';
import 'edit_profile_screen.dart';
import '../services/auth_service.dart';
import '../config/api_config.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String userName = "";
  String userEmail = "";
  String? profileImageUrl;
  int profileId = 0;
  bool isLoading = true;

  // Store the original image URL without timestamp
  String? _originalImageUrl;
  String? _displayImageUrl;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    setState(() => isLoading = true);

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      profileId = prefs.getInt('profileId') ?? 0;

      print('Loading profile for ID: $profileId');

      if (profileId != 0) {
        final profileData = await AuthService.getTutorProfile(profileId);

        String firstName = profileData['firstName'] ?? '';
        String lastName = profileData['lastName'] ?? '';

        setState(() {
          userName = "$firstName $lastName".trim();
          userEmail = profileData['email'] ?? '';
          _originalImageUrl = profileData['profilePictureUrl'];
          // Only add timestamp if we're forcing refresh (after edit)
          _displayImageUrl = _originalImageUrl;
          isLoading = false;
        });

        print('Profile loaded - Name: $userName');
        print('Image URL: $_originalImageUrl');
      } else {
        print('No profileId found');
        setState(() => isLoading = false);
      }
    } catch (e) {
      print('Error loading profile: $e');
      setState(() => isLoading = false);
    }
  }

  // Call this method only after editing profile
  Future<void> _refreshProfileAfterEdit() async {
    setState(() => isLoading = true);

    try {
      final profileData = await AuthService.getTutorProfile(profileId);

      String firstName = profileData['firstName'] ?? '';
      String lastName = profileData['lastName'] ?? '';

      setState(() {
        userName = "$firstName $lastName".trim();
        userEmail = profileData['email'] ?? '';
        _originalImageUrl = profileData['profilePictureUrl'];
        // Add timestamp only when image actually changed
        if (_originalImageUrl != null && _originalImageUrl!.isNotEmpty) {
          String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
          _displayImageUrl = '${ApiConfig.baseUrl}$_originalImageUrl?t=$timestamp';
        } else {
          _displayImageUrl = _originalImageUrl;
        }
        isLoading = false;
      });
    } catch (e) {
      print('Error refreshing profile: $e');
      setState(() => isLoading = false);
    }
  }

  String getFullImageUrl() {
    if (_displayImageUrl == null || _displayImageUrl!.isEmpty) return '';
    if (_displayImageUrl!.startsWith('http')) return _displayImageUrl!;
    return '${ApiConfig.baseUrl}$_displayImageUrl';
  }

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
                        onPressed: () async {
                          await AuthService.logout();
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

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8F9FB),
        body: const Center(child: CircularProgressIndicator()),
        bottomNavigationBar: const CustomBottomNav(currentIndex: 3),
      );
    }

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
                          userName.isEmpty ? "User" : userName,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          userEmail.isEmpty ? "No email" : userEmail,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 35),

                        _buildProfileOption(
                          Icons.person_outline,
                          "Edit Profile",
                          onTap: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditProfileScreen(profileId: profileId),
                              ),
                            );
                            if (result == true) {
                              await _refreshProfileAfterEdit();
                            }
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

                  Positioned(
                    top: 0,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.black, width: 2),
                      ),
                      child: ClipOval(
                        child: _buildProfileImage(),
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

  Widget _buildProfileImage() {
    String fullUrl = getFullImageUrl();
    print('Displaying image from URL: $fullUrl');

    if (fullUrl.isNotEmpty) {
      return Image.network(
        fullUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          print('Image load error: $error');
          return const Icon(Icons.person, size: 60, color: Colors.grey);
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const Center(
            child: CircularProgressIndicator(strokeWidth: 2),
          );
        },
      );
    } else {
      return const Icon(Icons.person, size: 60, color: Colors.grey);
    }
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