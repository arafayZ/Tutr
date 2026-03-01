// Import standard Dart and Flutter libraries
import 'dart:async'; // Used for the 5-second timer on the success screen
import 'package:flutter/material.dart'; // Standard Flutter UI components
import 'package:file_picker/file_picker.dart'; // Library to pick PDF or Image files from the phone
import 'login_screen.dart'; // Link to the login page for redirection

// Creating a StatefulWidget because we need to update the screen when files are selected
class TutorVerificationScreen extends StatefulWidget {
  const TutorVerificationScreen({super.key});

  @override
  State<TutorVerificationScreen> createState() => _TutorVerificationScreenState();
}

class _TutorVerificationScreenState extends State<TutorVerificationScreen> {
  // Variables to store the names of the selected files
  String? _idFileName;
  String? _degreeFileName;

  // Boolean to track if we should show red borders (error state)
  bool _showErrors = false;

  // Function to open the phone's file explorer
  Future<void> _pickFile(String type) async {
    // Only allow specific file types like PDF and common images
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'png', 'jpeg'],
    );

    // If a file was picked successfully
    if (result != null) {
      setState(() {
        // Save the file name to the correct variable based on which button was clicked
        if (type == "ID") {
          _idFileName = result.files.single.name;
        } else {
          _degreeFileName = result.files.single.name;
        }
      });
    }
  }

  // Popup that shows if the user clicks "Submit" without uploading files
  void _showErrorPopup() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white, // White background per instructions
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
              onPressed: () => Navigator.pop(context), // Close the popup
              child: const Text("OK", style: TextStyle(color: Color(0xFF0D1B3E), fontWeight: FontWeight.bold, fontSize: 18)),
            ),
          ),
        ],
      ),
    );
  }

  // Popup that shows when the tutor successfully submits their documents
  void _showSuccessPopup() {
    showDialog(
      context: context,
      barrierDismissible: false, // User cannot tap outside to close this
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
                // Displaying the verification success image
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
                const Text("Congratulations", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 15),
                const Text(
                  "Your account has been successfully created! We’re reviewing your documents...",
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                // Small loading spinner
                const CircularProgressIndicator(color: Color(0xFF0D1B3E)),
              ],
            ),
          ),
        );
      },
    );

    // Wait for 5 seconds, then go to the Login Screen
    Timer(const Duration(seconds: 5), () {
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
              (route) => false, // Remove all previous screens from history
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
          // White Top Header with a Back Button
          Container(
            width: double.infinity, height: 120,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(left: 24.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context), // Go back to Signup screen
                    child: const CircleAvatar(backgroundColor: Colors.black, child: Icon(Icons.arrow_back, color: Colors.white)),
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
                  const Text("Verify Your Identity", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  const Text("To maintain a safe and trusted learning environment...", style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 40),

                  // Button to upload ID Card
                  _buildUploadField(
                    label: _idFileName ?? "+ Identity Card (ID)",
                    onTap: () => _pickFile("ID"),
                    isUploaded: _idFileName != null,
                  ),
                  const SizedBox(height: 20),

                  // Button to upload Degree/Certificate
                  _buildUploadField(
                    label: _degreeFileName ?? "+ Degree / Certificate",
                    onTap: () => _pickFile("Degree"),
                    isUploaded: _degreeFileName != null,
                  ),

                  const SizedBox(height: 100),
                  const Center(child: Text("By clicking Submit, you agree to our process...", textAlign: TextAlign.center, style: TextStyle(fontSize: 11, color: Colors.grey))),
                  const SizedBox(height: 20),

                  // The Final Submit Button
                  GestureDetector(
                    onTap: () {
                      // Check if both files are uploaded before showing success
                      if (_idFileName != null && _degreeFileName != null) {
                        setState(() => _showErrors = false);
                        _showSuccessPopup();
                      } else {
                        // If something is missing, show red borders and error popup
                        setState(() => _showErrors = true);
                        _showErrorPopup();
                      }
                    },
                    child: Container(
                      width: double.infinity, height: 60,
                      decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(30)),
                      child: const Center(child: Text("Submit", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold))),
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

  // Reusable helper function to build the upload buttons
  Widget _buildUploadField({required String label, required VoidCallback onTap, required bool isUploaded}) {
    // Logic to change border color based on file status or errors
    Color borderColor = Colors.black.withOpacity(0.2);
    if (isUploaded) {
      borderColor = Colors.green; // Turn green if uploaded
    } else if (_showErrors) {
      borderColor = Colors.red; // Turn red if the user missed it
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity, height: 70,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(35),
          border: Border.all(color: borderColor, width: (_showErrors && !isUploaded) ? 2.0 : 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                label, // Shows filename if selected, otherwise shows hint
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 16, color: isUploaded ? Colors.black : (_showErrors ? Colors.red : Colors.grey)),
              ),
            ),
            // Changes icon to a checkmark if the file is picked
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