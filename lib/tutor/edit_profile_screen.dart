// Import Dart IO for file operations
import 'dart:io';

// Import Flutter material design components
import 'package:flutter/material.dart';

// Import for controlling keyboard input formatting
import 'package:flutter/services.dart';

// Import Image Picker plugin
import 'package:image_picker/image_picker.dart';

// Import your custom header widget
import '../widgets/custom_tab_header.dart';
import '../services/auth_service.dart';
import '../config/api_config.dart';

class EditProfileScreen extends StatefulWidget {
  final int profileId;
  const EditProfileScreen({super.key, required this.profileId});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

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

  // --- Variables ---
  File? _image;
  final ImagePicker _picker = ImagePicker();
  String? _selectedGender;
  bool _isLoading = false;
  bool _isDataLoaded = false;
  String? _currentImageUrl;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    setState(() => _isLoading = true);

    try {
      final profileData = await AuthService.getTutorProfile(widget.profileId);

      _firstNameController.text = profileData['firstName'] ?? '';
      _lastNameController.text = profileData['lastName'] ?? '';
      _emailController.text = profileData['email'] ?? '';
      _phoneController.text = _formatPhoneNumber(profileData['phoneNumber'] ?? '');
      _headlineController.text = profileData['headline'] ?? '';
      _selectedGender = profileData['gender'];
      _locationController.text = profileData['location'] ?? '';
      _uniController.text = profileData['universityName'] ?? '';
      _schoolController.text = profileData['collegeName'] ?? '';
      _workController.text = profileData['workExperience'] ?? '';
      _currentImageUrl = profileData['profilePictureUrl'];

      if (profileData['dateOfBirth'] != null) {
        _dobController.text = _formatDateForDisplay(profileData['dateOfBirth']);
      }

      setState(() => _isDataLoaded = true);
    } catch (e) {
      _showErrorDialog(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String _formatPhoneNumber(String phone) {
    if (phone.startsWith('+92')) {
      return phone.substring(3);
    }
    return phone;
  }

  String _formatDateForDisplay(String date) {
    if (date.length >= 10) {
      var parts = date.split('-');
      if (parts.length == 3) {
        return "${parts[2]}/${parts[1]}/${parts[0]}";
      }
    }
    return date;
  }

  String _formatDateForBackend(String date) {
    if (date.contains('-') && date.length == 10) {
      return date;
    }
    if (date.contains('/')) {
      var parts = date.split('/');
      if (parts.length == 3) {
        return "${parts[2]}-${parts[1].padLeft(2, '0')}-${parts[0].padLeft(2, '0')}";
      }
    }
    return date;
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _dobController.dispose();
    _locationController.dispose();
    _phoneController.dispose();
    _uniController.dispose();
    _schoolController.dispose();
    _workController.dispose();
    _headlineController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (pickedFile != null) {
        setState(() => _image = File(pickedFile.path));
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
  }

  Future<void> _selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.black,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _dobController.text = "${picked.day}/${picked.month}/${picked.year}");
    }
  }

  Future<void> _handleSave() async {
    String email = _emailController.text.trim();

    if (email.isEmpty) {
      _showErrorDialog("Email address cannot be empty.");
      return;
    }

    if (!_isValidEmail(email)) {
      _showErrorDialog("Please enter a valid email address.");
      return;
    }

    setState(() => _isLoading = true);

    try {
      String phoneNumber = '+92${_phoneController.text.trim()}';

      Map<String, dynamic> profileData = {
        'profileId': widget.profileId,
        'firstName': _firstNameController.text.trim(),
        'lastName': _lastNameController.text.trim(),
        'phoneNumber': phoneNumber,
        'headline': _headlineController.text.trim(),
        'gender': _selectedGender,
        'dateOfBirth': _formatDateForBackend(_dobController.text.trim()),
        'location': _locationController.text.trim(),
        'universityName': _uniController.text.trim(),
        'collegeName': _schoolController.text.trim(),
        'workExperience': _workController.text.trim().isEmpty ? "Not specified" : _workController.text.trim(),
      };

      // 1. Update profile text fields
      await AuthService.editTutorProfile(profileData);

      // 2. Upload new image and delete old one
      if (_image != null) {
        await AuthService.uploadTutorImage(widget.profileId, _image!.path, oldImageUrl: _currentImageUrl);
      }

      setState(() => _isLoading = false);
      _showSuccessPopup();

    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorDialog(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        content: Text(message, textAlign: TextAlign.center),
        actions: [
          Center(
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  void _showSuccessPopup() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 70),
              const SizedBox(height: 20),
              const Text("Profile Updated!", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              const Text("Your changes have been saved successfully.", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 30),
              GestureDetector(
                onTap: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context, true); // Return to profile with refresh flag
                },
                child: Container(
                  width: double.infinity, height: 50,
                  decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(25)),
                  child: const Center(child: Text("Done", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String getFullImageUrl(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) return '';
    if (imageUrl.startsWith('http')) return imageUrl;
    return '${ApiConfig.baseUrl}$imageUrl';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && !_isDataLoaded) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8F9FB),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: Column(
        children: [
          CustomTabHeader(
            title: const Text("Edit Profile", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundColor: const Color(0xFFE0E0E0),
                          backgroundImage: _image != null
                              ? FileImage(_image!)
                              : (_currentImageUrl != null ? NetworkImage(getFullImageUrl(_currentImageUrl)) : null),
                          child: _image == null && _currentImageUrl == null
                              ? const Icon(Icons.person, size: 60, color: Colors.grey)
                              : null,
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

                  _buildTextField(
                    hint: "Email Address",
                    controller: _emailController,
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    readOnly: true,
                  ),
                  const SizedBox(height: 12),

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

                  _buildTextField(hint: "Area, City", icon: Icons.location_on_outlined, controller: _locationController),
                  const SizedBox(height: 12),

                  _buildGenderDropdown(),
                  const SizedBox(height: 12),

                  _buildPhoneField(),
                  const SizedBox(height: 20),

                  _buildSectionHeader("Education"),
                  _buildTextField(hint: "University", icon: Icons.school_outlined, controller: _uniController),
                  const SizedBox(height: 12),
                  _buildTextField(hint: "High School", icon: Icons.account_balance_outlined, controller: _schoolController),

                  const SizedBox(height: 20),
                  _buildSectionHeader("Work (Optional)"),
                  _buildTextField(hint: "Work Experience", icon: Icons.work_outline, controller: _workController),

                  const SizedBox(height: 40),

                  GestureDetector(
                    onTap: _isLoading ? null : _handleSave,
                    child: Container(
                      width: double.infinity, height: 60,
                      decoration: BoxDecoration(
                        color: _isLoading ? Colors.grey : Colors.black,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Center(
                        child: _isLoading
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Text("Save Changes", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
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
    bool readOnly = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      readOnly: readOnly,
      style: readOnly ? TextStyle(color: Colors.grey[600]) : null,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
        prefixIcon: icon != null ? Icon(icon, color: Colors.black87, size: 20) : prefixWidget,
        filled: true,
        fillColor: readOnly ? Colors.grey[100] : Colors.white,
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

  Widget _buildGenderDropdown() {
    return Container(
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
    );
  }

  Widget _buildPhoneField() {
    return _buildTextField(
      hint: "3001234567",
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
    );
  }
}