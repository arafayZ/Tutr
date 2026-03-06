import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
// --- NEW IMPORT ---
import '../widgets/custom_tab_header.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  // ... (All your controllers and logic remain exactly the same) ...
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

  File? _image;
  final ImagePicker _picker = ImagePicker();
  String? _selectedGender;
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null) {
        List<String> nameParts = (args['name'] ?? "").split(" ");
        _firstNameController.text = nameParts.isNotEmpty ? nameParts[0] : "";
        _lastNameController.text = nameParts.length > 1 ? nameParts.sublist(1).join(" ") : "";
        _emailController.text = args['email'] ?? "";
      }
      _isInitialized = true;
    }
  }

  // ... (Image pick and date select methods remain the same) ...
  Future<void> _pickImage() async { /* ... */ }
  Future<void> _selectDate() async { /* ... */ }
  void _showSuccessPopup() { /* ... */ }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      // Removed the AppBar to use CustomTabHeader instead
      body: Column(
        children: [
          // --- COPIED HEADER LOGIC ---
          CustomTabHeader(
            title: const Text(
              "Edit Profile",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            // Optional: If your CustomTabHeader supports a leading widget,
            // you can add the back button here. Otherwise, it uses the default one.
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Photo Section
                  Center(
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundColor: const Color(0xFFE0E0E0),
                          backgroundImage: _image != null
                              ? FileImage(_image!)
                              : const AssetImage('assets/images/rafay.jpeg') as ImageProvider,
                        ),
                        Positioned(
                          bottom: 0, right: 0,
                          child: GestureDetector(
                            onTap: _pickImage,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle),
                              child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  _buildSectionHeader("Headline"),
                  _buildTextField(hint: "e.g., Math Tutor", controller: _headlineController),
                  const SizedBox(height: 20),

                  _buildSectionHeader("Personal Details"),
                  _buildTextField(hint: "First Name", controller: _firstNameController),
                  const SizedBox(height: 12),
                  _buildTextField(hint: "Last Name", controller: _lastNameController),
                  const SizedBox(height: 12),
                  _buildTextField(hint: "Email Address", controller: _emailController, icon: Icons.email_outlined),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: _selectDate,
                    child: AbsorbPointer(child: _buildTextField(hint: "Date of Birth", icon: Icons.calendar_today_outlined, controller: _dobController)),
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(hint: "Area, City", icon: Icons.location_on_outlined, controller: _locationController),
                  const SizedBox(height: 12),

                  // Gender Dropdown
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedGender,
                        hint: const Text("Gender"),
                        isExpanded: true,
                        items: ["Male", "Female", "Other"].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                        onChanged: (val) => setState(() => _selectedGender = val),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Phone Number Input
                  _buildTextField(
                    hint: "xxxxxxxxxx",
                    controller: _phoneController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(10)],
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
                  _buildSectionHeader("Education"),
                  _buildTextField(hint: "University", icon: Icons.school_outlined, controller: _uniController),
                  const SizedBox(height: 12),
                  _buildTextField(hint: "High School", icon: Icons.account_balance_outlined, controller: _schoolController),

                  const SizedBox(height: 20),
                  _buildSectionHeader("Work (Optional)"),
                  _buildTextField(hint: "Work Experience", icon: Icons.work_outline, controller: _workController),

                  const SizedBox(height: 40),

                  // Save Changes Button
                  GestureDetector(
                    onTap: _showSuccessPopup,
                    child: Container(
                      width: double.infinity,
                      height: 60,
                      decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(30)),
                      child: const Center(
                        child: Text("Save Changes", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
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

  // ... (Helper widgets _buildSectionHeader and _buildTextField) ...
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4),
      child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
    );
  }

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