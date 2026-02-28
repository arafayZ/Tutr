import 'dart:async';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'login_screen.dart'; // Import your login screen file

class TutorVerificationScreen extends StatefulWidget {
  const TutorVerificationScreen({super.key});

  @override
  State<TutorVerificationScreen> createState() => _TutorVerificationScreenState();
}

class _TutorVerificationScreenState extends State<TutorVerificationScreen> {
  String? _idFileName;
  String? _degreeFileName;
  bool _showErrors = false;

  Future<void> _pickFile(String type) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'png', 'jpeg'],
    );

    if (result != null) {
      setState(() {
        if (type == "ID") {
          _idFileName = result.files.single.name;
        } else {
          _degreeFileName = result.files.single.name;
        }
      });
    }
  }

  // Popup for missing files - White Background
  void _showErrorPopup() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        content: const Text(
          "Please upload all mandatory documents to continue.",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: Color(0xFF0D1B3E)),
        ),
        actions: [
          Center(
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK", style: TextStyle(color: Color(0xFF0D1B3E), fontWeight: FontWeight.bold, fontSize: 18)),
            ),
          ),
        ],
      ),
    );
  }

  // Congratulations Popup - White Background & 5 Second Redirect
  void _showSuccessPopup() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 120,
                  width: 120,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: AssetImage('assets/images/verification_complete.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Congratulations",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0D1B3E)),
                ),
                const SizedBox(height: 15),
                const Text(
                  "Your account has been successfully created! We’re reviewing your documents and will notify you once approved. You can log in now, but access is currently limited.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey, height: 1.5),
                ),
                const SizedBox(height: 30),
                const CircularProgressIndicator(
                  color: Color(0xFF0D1B3E),
                  strokeWidth: 3,
                ),
              ],
            ),
          ),
        );
      },
    );

    // After 5 seconds, navigate to Login Screen
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: Column(
        children: [
          // Custom Header
          Container(
            width: double.infinity,
            height: 120,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5))],
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(left: 24.0),
                child: Align(
                  alignment: Alignment.centerLeft,
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
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  const Text("Verify Your Identity", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF0D1B3E))),
                  const SizedBox(height: 12),
                  const Text(
                    "To maintain a safe and trusted learning environment, all tutors are required to complete identity verification before starting.",
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 40),

                  // ID Upload Field
                  _buildUploadField(
                    label: _idFileName ?? "+ Identity Card (ID)",
                    onTap: () => _pickFile("ID"),
                    isUploaded: _idFileName != null,
                  ),
                  const SizedBox(height: 20),

                  // Degree Upload Field
                  _buildUploadField(
                    label: _degreeFileName ?? "+ Degree / Certificate",
                    onTap: () => _pickFile("Degree"),
                    isUploaded: _degreeFileName != null,
                  ),

                  const SizedBox(height: 100),
                  const Center(
                    child: Text(
                      "By clicking Submit, you agree to our identity verification process and confirm that all provided information is correct and complete.",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Submit Button
                  GestureDetector(
                    onTap: () {
                      if (_idFileName != null && _degreeFileName != null) {
                        setState(() => _showErrors = false);
                        _showSuccessPopup();
                      } else {
                        setState(() => _showErrors = true);
                        _showErrorPopup();
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      height: 60,
                      decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(30)),
                      child: const Center(
                        child: Text("Submit", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Reusable Upload Field Widget
  Widget _buildUploadField({required String label, required VoidCallback onTap, required bool isUploaded}) {
    Color borderColor = Colors.black.withOpacity(0.2);
    if (isUploaded) {
      borderColor = Colors.green;
    } else if (_showErrors) {
      borderColor = Colors.red;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 70,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(35),
          border: Border.all(
            color: borderColor,
            width: (_showErrors && !isUploaded) ? 2.0 : 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 16,
                  color: isUploaded ? Colors.black : (_showErrors ? Colors.red : Colors.grey),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(
              isUploaded ? Icons.check_circle : Icons.note_add_outlined,
              color: isUploaded ? Colors.green : (_showErrors ? Colors.red : Colors.black),
            ),
          ],
        ),
      ),
    );
  }
}