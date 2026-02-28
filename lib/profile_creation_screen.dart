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
      // Mandatory checks
      bool isHeadlineValid = widget.role == "Student" || _headlineController.text.trim().isNotEmpty;
      bool isPhoneValid = _phoneController.text.length == 10;
      // Education check: At least one of the two must be filled
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
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const TutorVerificationScreen()),
          );
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
        backgroundColor: Colors.white,
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
              const Text(
                "Congratulations",
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF0D1B3E)),
              ),
              const SizedBox(height: 15),
              const Text(
                "Your account has been successfully\ncreated! You can now log in to\naccess your personalized dashboard.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, height: 1.5, color: Color(0xFF0D1B3E), fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 30),
              const CircularProgressIndicator(color: Color(0xFF0D1B3E)),
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
        surfaceTintColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        content: Text(message, textAlign: TextAlign.center, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: Color(0xFF0D1B3E))),
        actions: [
          Center(
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK", style: TextStyle(color: Color(0xFF0D1B3E), fontWeight: FontWeight.w900, fontSize: 18)),
            ),
          ),
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
          Container(
            width: double.infinity,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))],
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
                      radius: 22,
                      child: Icon(Icons.arrow_back, color: Colors.white, size: 20),
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
                              decoration: BoxDecoration(
                                  color: Colors.black,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2),
                                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 5)]),
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
                    _buildTextField(hint: "e.g., Math Tutor | Board Exam Expert", controller: _headlineController),
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

                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white, borderRadius: BorderRadius.circular(12),
                      border: _showErrors && _selectedGender == null ? Border.all(color: Colors.red, width: 1.5) : null,
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedGender,
                        hint: const Text("Gender", style: TextStyle(color: Colors.grey)),
                        isExpanded: true,
                        items: ["Male", "Female", "Other"].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                        onChanged: (val) => setState(() => _selectedGender = val),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  _buildTextField(
                    hint: "345892658",
                    controller: _phoneController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(10)],
                    prefixWidget: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(width: 12),
                        Text("🇵🇰", style: TextStyle(fontSize: 20)),
                        SizedBox(width: 8),
                        Text("( +92 ) ", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                  _buildSectionHeader("Education"),
                  _buildTextField(hint: "University", icon: Icons.school_outlined, controller: _uniController, isOptionalGroup: true),
                  const SizedBox(height: 12),
                  _buildTextField(hint: "High School", icon: Icons.account_balance_outlined, controller: _schoolController, isOptionalGroup: true),

                  const SizedBox(height: 20),
                  Row(
                    children: [
                      _buildSectionHeader("Work"),
                      const SizedBox(width: 8),
                      const Text("(Optional)", style: TextStyle(color: Colors.grey, fontSize: 14, fontStyle: FontStyle.italic)),
                    ],
                  ),
                  // UPDATED: Added isOptional: true here
                  _buildTextField(hint: "Work Experience", icon: Icons.work_outline, controller: _workController, isOptional: true),

                  const SizedBox(height: 40),

                  GestureDetector(
                    onTap: _validateAndContinue,
                    child: Container(
                      width: double.infinity,
                      height: 60,
                      decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 4))]),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Spacer(flex: 2),
                          const Text("Continue", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                          const Spacer(),
                          Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: CircleAvatar(
                              backgroundColor: Colors.white,
                              radius: 18,
                              child: const Icon(Icons.arrow_forward, color: Colors.black, size: 20),
                            ),
                          ),
                        ],
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
      child: Text(title, style: const TextStyle(color: Color(0xFF0D1B3E), fontWeight: FontWeight.bold, fontSize: 16)),
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

    // VALIDATION LOGIC REFINED:
    if (_showErrors) {
      if (isOptional) {
        // If it's truly optional (Work field), never show the red border
        showErrorBorder = false;
      } else if (isOptionalGroup) {
        // Education group (University OR High School must be filled)
        showErrorBorder = _uniController.text.trim().isEmpty && _schoolController.text.trim().isEmpty;
      } else {
        // Mandatory fields (Name, Phone, etc.)
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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