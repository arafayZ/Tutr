// Import Dart IO for file operations (used for image picking)
import 'dart:io';

// Import Flutter material design components
import 'package:flutter/material.dart';

// Import for controlling keyboard input formatting
import 'package:flutter/services.dart';

// Import Image Picker plugin
import 'package:image_picker/image_picker.dart';

// Import your custom header widget
import '../widgets/custom_tab_header.dart';

// --- 1. MAIN SCREEN CLASS ---
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

// --- 2. STATE CLASS ---
class _EditProfileScreenState extends State<EditProfileScreen> {

  // --- Controllers for input fields ---
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _uniController = TextEditingController();
  final TextEditingController _schoolController = TextEditingController();
  final TextEditingController _workController = TextEditingController();
  final TextEditingController _headlineController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  // --- Variables for image and gender ---
  File? _image;  // Stores selected profile image
  final ImagePicker _picker = ImagePicker();  // Image picker instance
  String? _selectedGender; // Selected gender
  bool _isInitialized = false; // To prevent multiple initialization

  // --- 3. INITIAL DATA FETCH ---
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Only initialize once
    if (!_isInitialized) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

      // Load initial data from navigation arguments
      if (args != null) {
        // Split full name into first and last
        List<String> nameParts = (args['name'] ?? "").split(" ");
        _firstNameController.text = nameParts.isNotEmpty ? nameParts[0] : "";
        _lastNameController.text = nameParts.length > 1 ? nameParts.sublist(1).join(" ") : "";
        _emailController.text = args['email'] ?? "";
      }
      _isInitialized = true;
    }
  }

  // --- 4. IMAGE PICKER METHOD ---
  Future<void> _pickImage() async {
    // Method will open gallery or camera and store selected image
    // Implementation goes here...
  }

  // --- 5. DATE PICKER METHOD ---
  Future<void> _selectDate() async {
    // Method opens date picker and sets selected DOB
    // Implementation goes here...
  }

  // --- 6. SUCCESS POPUP METHOD ---
  void _showSuccessPopup() {
    // Show dialog confirming changes saved
    // Implementation goes here...
  }

  // --- 7. BUILD METHOD ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB), // Background color for screen

      // Use column for header + scrollable content
      body: Column(
        children: [

          // --- 7a. CUSTOM HEADER ---
          CustomTabHeader(
            title: const Text(
              "Edit Profile",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),

          // --- 7b. MAIN SCROLLABLE FORM ---
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // --- Profile Photo Section ---
                  Center(
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundColor: const Color(0xFFE0E0E0),
                          backgroundImage: _image != null
                              ? FileImage(_image!) // Show picked image
                              : const AssetImage('assets/images/rafay.jpeg') as ImageProvider, // Default placeholder
                        ),
                        Positioned(
                          bottom: 0, right: 0,
                          child: GestureDetector(
                            onTap: _pickImage, // Open image picker
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: Colors.black,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  // --- HEADLINE ---
                  _buildSectionHeader("Headline"),
                  _buildTextField(hint: "e.g., Math Tutor", controller: _headlineController),
                  const SizedBox(height: 20),

                  // --- PERSONAL DETAILS ---
                  _buildSectionHeader("Personal Details"),
                  _buildTextField(hint: "First Name", controller: _firstNameController),
                  const SizedBox(height: 12),
                  _buildTextField(hint: "Last Name", controller: _lastNameController),
                  const SizedBox(height: 12),
                  _buildTextField(
                    hint: "Email Address",
                    controller: _emailController,
                    icon: Icons.email_outlined,
                  ),
                  const SizedBox(height: 12),

                  // Date of Birth (with date picker)
                  GestureDetector(
                    onTap: _selectDate,
                    child: AbsorbPointer(
                      child: _buildTextField(
                        hint: "Date of Birth",
                        icon: Icons.calendar_today_outlined,
                        controller: _dobController,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  _buildTextField(
                    hint: "Area, City",
                    icon: Icons.location_on_outlined,
                    controller: _locationController,
                  ),
                  const SizedBox(height: 12),

                  // --- GENDER DROPDOWN ---
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedGender,
                        hint: const Text("Gender"),
                        isExpanded: true,
                        items: ["Male", "Female", "Other"]
                            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                            .toList(),
                        onChanged: (val) => setState(() => _selectedGender = val),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // --- PHONE NUMBER ---
                  _buildTextField(
                    hint: "xxxxxxxxxx",
                    controller: _phoneController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10),
                    ],
                    prefixWidget: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(width: 12),
                        Text("🇵🇰", style: TextStyle(fontSize: 20)),
                        SizedBox(width: 8),
                        Text("( +92 ) ", style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // --- EDUCATION SECTION ---
                  _buildSectionHeader("Education"),
                  _buildTextField(hint: "University", icon: Icons.school_outlined, controller: _uniController),
                  const SizedBox(height: 12),
                  _buildTextField(hint: "High School", icon: Icons.account_balance_outlined, controller: _schoolController),

                  const SizedBox(height: 20),

                  // --- WORK EXPERIENCE ---
                  _buildSectionHeader("Work (Optional)"),
                  _buildTextField(hint: "Work Experience", icon: Icons.work_outline, controller: _workController),

                  const SizedBox(height: 40),

                  // --- SAVE CHANGES BUTTON ---
                  GestureDetector(
                    onTap: _showSuccessPopup, // Trigger save
                    child: Container(
                      width: double.infinity,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Center(
                        child: Text(
                          "Save Changes",
                          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- HELPER WIDGETS ---

  // Section header with bold text
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4),
      child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
    );
  }

  // Reusable text field widget with optional icon and prefix
  Widget _buildTextField({
    required String hint,
    IconData? icon,
    Widget? prefixWidget,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: icon != null ? Icon(icon, color: Colors.black87, size: 20) : prefixWidget,
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.black, width: 1),
        ),
      ),
    );
  }
}