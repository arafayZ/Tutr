// Import standard Dart and Flutter libraries
import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'login_screen.dart';
import 'tutor_verification_screen.dart';

class ProfileCreationScreen extends StatefulWidget {
  final String role;
  const ProfileCreationScreen({super.key, required this.role});

  @override
  State<ProfileCreationScreen> createState() => _ProfileCreationScreenState();
}

class _ProfileCreationScreenState extends State<ProfileCreationScreen> {
  // Controllers for input fields
  final TextEditingController _headlineController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _uniController = TextEditingController();
  final TextEditingController _schoolController = TextEditingController();
  final TextEditingController _workController = TextEditingController();

  File? _image;
  final ImagePicker _picker = ImagePicker();
  String? _selectedGender;
  bool _showErrors = false;

  @override
  void dispose() {
    _headlineController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _dobController.dispose();
    _locationController.dispose();
    _phoneController.dispose();
    _uniController.dispose();
    _schoolController.dispose();
    _workController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.black),
              title: const Text('Gallery'),
              onTap: () async {
                final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
                if (pickedFile != null) setState(() => _image = File(pickedFile.path));
                if (mounted) Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.black),
              title: const Text('Camera'),
              onTap: () async {
                final XFile? pickedFile = await _picker.pickImage(source: ImageSource.camera);
                if (pickedFile != null) setState(() => _image = File(pickedFile.path));
                if (mounted) Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: Colors.black, onPrimary: Colors.white, onSurface: Colors.black),
          ),
          child: child!),
    );
    if (picked != null) setState(() => _dobController.text = "${picked.day}/${picked.month}/${picked.year}");
  }

  void _validateAndContinue() {
    setState(() {
      bool isHeadlineValid = widget.role == "Student" || _headlineController.text.trim().isNotEmpty;
      bool isPhoneValid = _phoneController.text.length == 10;
      bool isEducationValid = _uniController.text.trim().isNotEmpty || _schoolController.text.trim().isNotEmpty;

      if (!isHeadlineValid ||
          _firstNameController.text.trim().isEmpty ||
          _lastNameController.text.trim().isEmpty ||
          _dobController.text.trim().isEmpty ||
          _locationController.text.trim().isEmpty ||
          !isPhoneValid ||
          _selectedGender == null ||
          !isEducationValid) {
        _showErrors = true;
        _showErrorPopup("Please fill in all mandatory fields correctly.");
      } else {
        _showErrors = false;
        if (widget.role == "Tutor") {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const TutorVerificationScreen()));
        } else {
          _showCongratulationsDialog();
        }
      }
    });
  }

  void _showCongratulationsDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.white, // Strictly white per requirement
        surfaceTintColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircleAvatar(
                radius: 70,
                backgroundColor: Color(0xFFFFC107),
                child: Icon(Icons.person, size: 80, color: Colors.white),
              ),
              const SizedBox(height: 25),
              const Text("Congratulations", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
              const Text("Your account has been successfully\ncreated!", textAlign: TextAlign.center),
              const SizedBox(height: 30),
              const CircularProgressIndicator(color: Colors.black),
            ],
          ),
        ),
      ),
    );

    Timer(const Duration(seconds: 5), () {
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
              (route) => false,
        );
      }
    });
  }

  void _showErrorPopup(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        content: Text(message, textAlign: TextAlign.center),
        actions: [
          Center(child: TextButton(onPressed: () => Navigator.pop(context), child: const Text("OK"))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            height: 120,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
            ),
            child: SafeArea(
              child: Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 24.0),
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const CircleAvatar(
                      backgroundColor: Colors.black,
                      child: Icon(Icons.arrow_back, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Photo
                  Center(
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundColor: const Color(0xFFE0E0E0),
                          backgroundImage: _image != null ? FileImage(_image!) : null,
                          child: _image == null ? const Icon(Icons.person, size: 60, color: Colors.grey) : null,
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

                  if (widget.role == "Tutor") ...[
                    _buildSectionHeader("Headline"),
                    _buildTextField(hint: "e.g., Math Tutor", controller: _headlineController),
                    const SizedBox(height: 20),
                  ],

                  _buildSectionHeader("Personal Details"),
                  _buildTextField(hint: "First Name", controller: _firstNameController),
                  const SizedBox(height: 12),
                  _buildTextField(hint: "Last Name", controller: _lastNameController),
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
                    decoration: BoxDecoration(
                      color: Colors.white, borderRadius: BorderRadius.circular(12),
                      border: _showErrors && _selectedGender == null ? Border.all(color: Colors.red, width: 1.5) : null,
                    ),
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
                  // Education Section - Dynamic Hints
                  _buildSectionHeader("Education"),
                  _buildTextField(
                      hint: widget.role == "Student" ? "School" : "University",
                      icon: Icons.school_outlined,
                      controller: _uniController,
                      isOptionalGroup: true
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                      hint: widget.role == "Student" ? "College" : "High School",
                      icon: Icons.account_balance_outlined,
                      controller: _schoolController,
                      isOptionalGroup: true
                  ),

                  // Work Section - Only for Tutors
                  if (widget.role == "Tutor") ...[
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        _buildSectionHeader("Work"),
                        const SizedBox(width: 8),
                        const Text("(Optional)", style: TextStyle(color: Colors.grey, fontSize: 14)),
                      ],
                    ),
                    _buildTextField(hint: "Work Experience", icon: Icons.work_outline, controller: _workController, isOptional: true),
                  ],

                  const SizedBox(height: 40),

                  GestureDetector(
                    onTap: _validateAndContinue,
                    child: Container(
                      width: double.infinity,
                      height: 60,
                      decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(30)),
                      child: const Center(
                        child: Text("Continue", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
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
    bool isOptional = false,
    bool isOptionalGroup = false,
  }) {
    bool showErrorBorder = false;

    if (_showErrors) {
      if (isOptional) {
        showErrorBorder = false;
      } else if (isOptionalGroup) {
        showErrorBorder = _uniController.text.trim().isEmpty && _schoolController.text.trim().isEmpty;
      } else {
        showErrorBorder = controller.text.trim().isEmpty;
      }
    }

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
          borderSide: showErrorBorder ? const BorderSide(color: Colors.red, width: 1.5) : BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.black, width: 1),
        ),
      ),
    );
  }
}