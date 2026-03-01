// Import standard Dart and Flutter libraries
import 'dart:io'; // Used for handling the profile image file
import 'dart:async'; // Used for the 5-second timer on the success screen
import 'package:flutter/material.dart'; // Standard Flutter UI components
import 'package:flutter/services.dart'; // Used to limit input (like numbers only for phone)
import 'package:image_picker/image_picker.dart'; // Library to pick images from camera or gallery
import 'login_screen.dart'; // Link to the login page
import 'tutor_verification_screen.dart'; // Link to the verification page for tutors

// A StatefulWidget because the user's input (text, images) changes the UI
class ProfileCreationScreen extends StatefulWidget {
  final String role; // Stores if the user is a "Tutor" or "Student"
  const ProfileCreationScreen({super.key, required this.role});

  @override
  State<ProfileCreationScreen> createState() => _ProfileCreationScreenState();
}

class _ProfileCreationScreenState extends State<ProfileCreationScreen> {
  // Controllers to grab the text typed into the input boxes
  final TextEditingController _headlineController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _uniController = TextEditingController();
  final TextEditingController _schoolController = TextEditingController();
  final TextEditingController _workController = TextEditingController();

  File? _image; // Variable to hold the picked profile photo
  final ImagePicker _picker = ImagePicker(); // Tool to open camera/gallery
  String? _selectedGender; // Variable to store the chosen gender from dropdown
  bool _showErrors = false; // Tracks if we should show red borders for empty fields

  @override
  void dispose() {
    // Clean up all controllers when the screen is closed to save memory
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

  // Function to show the "Gallery or Camera" menu at the bottom
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
                if (mounted) Navigator.pop(context); // Close the menu
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.black),
              title: const Text('Camera'),
              onTap: () async {
                final XFile? pickedFile = await _picker.pickImage(source: ImageSource.camera);
                if (pickedFile != null) setState(() => _image = File(pickedFile.path));
                if (mounted) Navigator.pop(context); // Close the menu
              },
            ),
          ],
        ),
      ),
    );
  }

  // Function to show the Date Picker calendar
  Future<void> _selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000), // Default year shown
      firstDate: DateTime(1950), // Oldest date allowed
      lastDate: DateTime.now(), // Newest date allowed (today)
      builder: (context, child) => Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: Colors.black, onPrimary: Colors.white, onSurface: Colors.black),
          ),
          child: child!),
    );
    // If a date was picked, format it and put it in the text box
    if (picked != null) setState(() => _dobController.text = "${picked.day}/${picked.month}/${picked.year}");
  }

  // The logic that runs when you click the "Continue" button
  void _validateAndContinue() {
    setState(() {
      // Logic for Tutor: Headline is required. For Student: Headline is optional.
      bool isHeadlineValid = widget.role == "Student" || _headlineController.text.trim().isNotEmpty;
      // Phone number must be exactly 10 digits
      bool isPhoneValid = _phoneController.text.length == 10;
      // Education check: User must fill in either University OR High School
      bool isEducationValid = _uniController.text.trim().isNotEmpty || _schoolController.text.trim().isNotEmpty;

      // Check if any required field is missing
      if (!isHeadlineValid ||
          _firstNameController.text.trim().isEmpty ||
          _lastNameController.text.trim().isEmpty ||
          _dobController.text.trim().isEmpty ||
          _locationController.text.trim().isEmpty ||
          !isPhoneValid ||
          _selectedGender == null ||
          !isEducationValid) {
        _showErrors = true; // Show red borders
        _showErrorPopup("Please fill in all mandatory fields correctly.");
      } else {
        _showErrors = false; // Hide red borders

        if (widget.role == "Tutor") {
          // If Tutor, go to the ID verification screen
          Navigator.push(context, MaterialPageRoute(builder: (context) => const TutorVerificationScreen()));
        } else {
          // If Student, show the success message
          _showCongratulationsDialog();
        }
      }
    });
  }

  // The "Success" popup screen for students
  void _showCongratulationsDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevents closing the popup by tapping outside
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
                backgroundColor: Color(0xFFFFC107), // Gold/Yellow color
                child: Icon(Icons.person, size: 80, color: Colors.white),
              ),
              const SizedBox(height: 25),
              const Text("Congratulations", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
              const Text("Your account has been successfully\ncreated!", textAlign: TextAlign.center),
              const SizedBox(height: 30),
              const CircularProgressIndicator(color: Color(0xFF0D1B3E)), // Loading spinner
            ],
          ),
        ),
      ),
    );

    // Wait 5 seconds, then send the user to the Login Screen
    Timer(const Duration(seconds: 5), () {
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
              (route) => false, // Clears the previous screens
        );
      }
    });
  }

  // Simple popup to show error messages
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
      backgroundColor: const Color(0xFFF8F9FB), // Light grey background
      body: Column(
        children: [
          // Header Container with the Back Button
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
                  // Profile Photo Upload Section
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

                  // If user is a Tutor, show the Headline field
                  if (widget.role == "Tutor") ...[
                    _buildSectionHeader("Headline"),
                    _buildTextField(hint: "e.g., Math Tutor", controller: _headlineController),
                    const SizedBox(height: 20),
                  ],

                  // Personal Details Section
                  _buildSectionHeader("Personal Details"),
                  _buildTextField(hint: "First Name", controller: _firstNameController),
                  const SizedBox(height: 12),
                  _buildTextField(hint: "Last Name", controller: _lastNameController),
                  const SizedBox(height: 12),
                  // Date of Birth Field (Clicks open the calendar)
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

                  // Phone Number Field with Pakistan Flag
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
                        Text("( +92 ) ", style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                  // Education Section
                  _buildSectionHeader("Education"),
                  _buildTextField(hint: "University", icon: Icons.school_outlined, controller: _uniController, isOptionalGroup: true),
                  const SizedBox(height: 12),
                  _buildTextField(hint: "High School", icon: Icons.account_balance_outlined, controller: _schoolController, isOptionalGroup: true),

                  const SizedBox(height: 20),
                  // Work Section (Optional)
                  Row(
                    children: [
                      _buildSectionHeader("Work"),
                      const SizedBox(width: 8),
                      const Text("(Optional)", style: TextStyle(color: Colors.grey, fontSize: 14)),
                    ],
                  ),
                  _buildTextField(hint: "Work Experience", icon: Icons.work_outline, controller: _workController, isOptional: true),

                  const SizedBox(height: 40),

                  // The Final Continue Button
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

  // Simple helper to build bold section titles
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4),
      child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
    );
  }

  // Helper function to build all text fields with validation logic
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
        showErrorBorder = false; // Never show red for Work field
      } else if (isOptionalGroup) {
        // Show red only if BOTH university and school are empty
        showErrorBorder = _uniController.text.trim().isEmpty && _schoolController.text.trim().isEmpty;
      } else {
        showErrorBorder = controller.text.trim().isEmpty; // Show red for mandatory empty fields
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
          // Set border to red if there is a validation error
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