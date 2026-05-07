import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../services/auth_service.dart';
import '../config/api_config.dart';
import '../utils/status_bar_config.dart';

class EditProfileScreen extends StatefulWidget {
  final int profileId;
  const EditProfileScreen({super.key, required this.profileId});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  // Controllers
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _dateController;
  late TextEditingController _locationController;
  late TextEditingController _phoneController;
  late TextEditingController _schoolController;
  late TextEditingController _collegeController;
  late TextEditingController _emailController;

  // Variables
  DateTime? selectedDate;
  String? selectedGender;
  File? _imageFile;
  String? _currentImageUrl;
  bool _isLoading = false;
  bool _isDataLoaded = false;

  final List<String> _genders = ["Male", "Female", "Other"];
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    StatusBarConfig.setLightStatusBar();
    _initializeControllers();
    _loadProfileData();
  }

  @override
  void dispose() {
    StatusBarConfig.resetStatusBar();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _dateController.dispose();
    _locationController.dispose();
    _phoneController.dispose();
    _schoolController.dispose();
    _collegeController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _initializeControllers() {
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _dateController = TextEditingController();
    _locationController = TextEditingController();
    _phoneController = TextEditingController();
    _schoolController = TextEditingController();
    _collegeController = TextEditingController();
    _emailController = TextEditingController();
  }

  Future<void> _loadProfileData() async {
    setState(() => _isLoading = true);

    try {
      final profileData = await AuthService.getStudentProfile(widget.profileId);

      _firstNameController.text = profileData['firstName'] ?? '';
      _lastNameController.text = profileData['lastName'] ?? '';
      _emailController.text = profileData['email'] ?? '';
      _locationController.text = profileData['location'] ?? '';
      _schoolController.text = profileData['schoolName'] ?? '';
      _collegeController.text = profileData['collegeName'] ?? '';
      selectedGender = profileData['gender'];
      _currentImageUrl = profileData['profilePictureUrl'];

      // Format phone number (remove +92 for display)
      String phone = profileData['phoneNumber'] ?? '';
      if (phone.startsWith('+92')) {
        phone = phone.substring(3);
      }
      _phoneController.text = phone;

      // Format date for display
      if (profileData['dateOfBirth'] != null) {
        String dob = profileData['dateOfBirth'];
        if (dob.isNotEmpty && dob.contains('-')) {
          var parts = dob.split('-');
          if (parts.length == 3) {
            DateTime date = DateTime.parse(dob);
            selectedDate = date;
            _dateController.text = "${date.day} ${_getMonthName(date.month)} ${date.year}";
          }
        }
      }

      setState(() => _isDataLoaded = true);
    } catch (e) {
      _showErrorDialog(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String _getMonthName(int month) {
    const months = ["January", "February", "March", "April", "May", "June",
      "July", "August", "September", "October", "November", "December"];
    return months[month - 1];
  }

  String _formatDateForBackend(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  String getFullImageUrl(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) return '';
    if (imageUrl.startsWith('http')) return imageUrl;
    return '${ApiConfig.baseUrl}$imageUrl';
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (pickedFile != null) {
        setState(() => _imageFile = File(pickedFile.path));
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime(2000),
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
      setState(() {
        selectedDate = picked;
        _dateController.text = "${picked.day} ${_getMonthName(picked.month)} ${picked.year}";
      });
    }
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
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

    if (selectedDate == null) {
      _showErrorDialog("Please select your date of birth.");
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
        'gender': selectedGender,
        'dateOfBirth': _formatDateForBackend(selectedDate!),
        'location': _locationController.text.trim(),
        'schoolName': _schoolController.text.trim(),
        'collegeName': _collegeController.text.trim(),
      };

      if (_imageFile != null) {
        profileData['profileImage'] = _imageFile;
      }

      await AuthService.editStudentProfile(profileData);

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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Error", style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK", style: TextStyle(color: Colors.black)),
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
              const Text("Your changes have been saved successfully.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 30),
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pop(context, true);
                },
                child: Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(25)),
                  child: const Center(
                    child: Text("Done", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && !_isDataLoaded) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8F9FB),
        appBar: AppBar(
          backgroundColor: Colors.black,
          elevation: 0,
          toolbarHeight: 0,
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Colors.black,
            statusBarIconBrightness: Brightness.light,
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        toolbarHeight: 0,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.black,
          statusBarIconBrightness: Brightness.light,
        ),
      ),
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 30),
                    Center(
                      child: Stack(
                        children: [
                          // Profile Image Circle
                          CircleAvatar(
                            radius: 59,
                            backgroundColor: const Color(0xFFE0E0E0),
                            backgroundImage: _imageFile != null
                                ? FileImage(_imageFile!)
                                : (_currentImageUrl != null && _currentImageUrl!.isNotEmpty
                                ? NetworkImage(getFullImageUrl(_currentImageUrl))
                                : null),
                            child: (_imageFile == null &&
                                (_currentImageUrl == null || _currentImageUrl!.isEmpty))
                                ? const Icon(Icons.person, size: 60, color: Colors.grey)
                                : null,
                          ),
                          // Camera Button
                          Positioned(
                            bottom: 0,
                            right: 0,
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

                    const Text("Personal Details",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
                    const SizedBox(height: 15),

                    _customTextField(hint: "First Name", controller: _firstNameController),
                    _customTextField(hint: "Last Name", controller: _lastNameController),

                    _customTextField(
                      hint: "Email Address",
                      controller: _emailController,
                      readOnly: true,
                    ),

                    GestureDetector(
                      onTap: () => _selectDate(context),
                      child: AbsorbPointer(
                        child: _customTextField(
                            hint: "Date of Birth",
                            controller: _dateController,
                            icon: Icons.calendar_month_outlined
                        ),
                      ),
                    ),

                    _customTextField(
                        hint: "Location",
                        controller: _locationController,
                        icon: Icons.location_on_outlined
                    ),

                    _genderDropdown(),
                    _phoneField(),

                    const SizedBox(height: 25),
                    const Text("Education",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
                    const SizedBox(height: 15),

                    _customTextField(
                        hint: "School Name",
                        controller: _schoolController,
                        icon: Icons.school_outlined
                    ),

                    _customTextField(
                        hint: "College Name",
                        controller: _collegeController,
                        icon: Icons.account_balance_outlined
                    ),

                    const SizedBox(height: 40),

                    GestureDetector(
                      onTap: _isLoading ? null : _handleSave,
                      child: Container(
                        width: double.infinity,
                        height: 60,
                        decoration: BoxDecoration(
                          color: _isLoading ? Colors.grey : Colors.black,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Center(
                          child: _isLoading
                              ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                          )
                              : const Text("Update",
                              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 45,
              height: 45,
              decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle),
              child: const Icon(Icons.arrow_back, color: Colors.white, size: 22),
            ),
          ),
          const Expanded(
            child: Center(
              child: Text("Edit Profile",
                  style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(width: 45),
        ],
      ),
    );
  }

  Widget _customTextField({
    required String hint,
    IconData? icon,
    required TextEditingController controller,
    bool readOnly = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      decoration: BoxDecoration(
        color: readOnly ? Colors.grey[100] : Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: readOnly ? Colors.grey[600] : Colors.black),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
          icon: icon != null ? Icon(icon, color: Colors.grey, size: 20) : null,
        ),
      ),
    );
  }

  Widget _genderDropdown() {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedGender,
          isExpanded: true,
          style: const TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w500),
          icon: const Icon(Icons.arrow_drop_down, color: Colors.black87),
          hint: const Text("Select Gender"),
          items: _genders.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (newValue) => setState(() => selectedGender = newValue),
        ),
      ),
    );
  }

  Widget _phoneField() {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          const Text("+92", style: TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w500)),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _phoneController,
              keyboardType: TextInputType.number,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10)
              ],
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: "3001234567",
                hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}