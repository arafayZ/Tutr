// Importing Flutter material design package
import 'package:flutter/material.dart';

// Importing async library for Timer
import 'dart:async';

// Importing Login screen to navigate after success
import 'login_screen.dart';

// Creating a StatefulWidget for Create New Password screen
class CreateNewPasswordScreen extends StatefulWidget {
  const CreateNewPasswordScreen({super.key});

  @override
  State<CreateNewPasswordScreen> createState() => _CreateNewPasswordScreenState();
}

// State class for CreateNewPasswordScreen
class _CreateNewPasswordScreenState extends State<CreateNewPasswordScreen> {

  // Controller for password field
  final TextEditingController _passController = TextEditingController();

  // Controller for confirm password field
  final TextEditingController _confirmPassController = TextEditingController();

  // Boolean to show validation errors
  bool _showErrors = false;

  // Boolean to hide/show first password
  bool _isObscured1 = true;

  // Boolean to hide/show confirm password
  bool _isObscured2 = true;

  // Function called when Continue button is pressed
  void _handleContinue() {
    setState(() {
      // Check if fields are empty or passwords don’t match
      if (_passController.text.isEmpty ||
          _confirmPassController.text.isEmpty ||
          _passController.text != _confirmPassController.text) {

        _showErrors = true; // Enable error highlighting
        _showErrorPopup();  // Show error dialog

      } else {
        _showErrors = false; // Remove error state
        _showSuccessPopup(); // Show success dialog
      }
    });
  }

  // Function to show error popup
  void _showErrorPopup() {

    // Decide error message
    String msg = _passController.text != _confirmPassController.text
        ? "Passwords do not match!"
        : "Please fill in all fields.";

    // Show alert dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white, // White background
        surfaceTintColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        content: Text(
          msg,
          textAlign: TextAlign.center,
          style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: Color(0xFF0D1B3E)),
        ),
        actions: [
          Center(
            child: TextButton(
              onPressed: () => Navigator.pop(context), // Close dialog
              child: const Text(
                "OK",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Color(0xFF0D1B3E)),
              ),
            ),
          )
        ],
      ),
    );
  }

  // Function to show success popup
  void _showSuccessPopup() {

    showDialog(
      context: context,
      barrierDismissible: false, // Prevent closing manually
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 20),

            // Success icon
            const Icon(Icons.check_circle_outline,
                size: 80,
                color: Colors.blueGrey),

            const SizedBox(height: 20),

            // Congratulations text
            const Text(
              "Congratulations",
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0D1B3E)),
            ),

            const SizedBox(height: 15),

            // Success message
            const Text(
              "Your Account is Ready to Use. You will be redirected to the Login Page in a Few Seconds.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),

            const SizedBox(height: 20),

            // Loading indicator
            const CircularProgressIndicator(color: Color(0xFF0D1B3E)),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );

    // Wait 5 seconds then navigate to Login screen
    Timer(const Duration(seconds: 5), () {
      if (mounted) { // Check if widget is still active
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
              (route) => false, // Remove all previous routes
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {

    // Main screen structure
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),

      body: Column(
        children: [

          // Header section
          Container(
            width: double.infinity,
            height: 120,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30)),
              boxShadow: [
                BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, 5))
              ],
            ),

            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Row(
                  children: [

                    // Back button
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const CircleAvatar(
                        backgroundColor: Colors.black,
                        radius: 22,
                        child: Icon(Icons.arrow_back,
                            color: Colors.white,
                            size: 20),
                      ),
                    ),

                    const SizedBox(width: 20),

                    // Screen title
                    const Text(
                      "Create New Password",
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0D1B3E)),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Body section
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  const SizedBox(height: 100),

                  const Text(
                    "Create Your New Password",
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0D1B3E)),
                  ),

                  const SizedBox(height: 25),

                  // Password field
                  _passwordField(
                      "Password",
                      _passController,
                      _isObscured1,
                          () => setState(() =>
                      _isObscured1 = !_isObscured1)),

                  const SizedBox(height: 15),

                  // Confirm password field
                  _passwordField(
                      "Confirm Password",
                      _confirmPassController,
                      _isObscured2,
                          () => setState(() =>
                      _isObscured2 = !_isObscured2)),

                  const SizedBox(height: 60),

                  // Continue button
                  GestureDetector(
                    onTap: _handleContinue,
                    child: Container(
                      width: double.infinity,
                      height: 60,
                      decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(30)),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Spacer(flex: 2),
                          Text(
                            "Continue",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                          ),
                          Spacer(),
                          Padding(
                            padding: EdgeInsets.only(right: 8.0),
                            child: CircleAvatar(
                              backgroundColor: Colors.white,
                              radius: 18,
                              child: Icon(Icons.arrow_forward,
                                  color: Colors.black,
                                  size: 20),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Reusable password field widget
  Widget _passwordField(
      String hint,
      TextEditingController controller,
      bool obscured,
      VoidCallback toggle) {

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),

        // Show red border if error and field empty
        border: _showErrors && controller.text.isEmpty
            ? Border.all(color: Colors.red, width: 1.5)
            : null,
      ),

      child: TextField(
        controller: controller,
        obscureText: obscured, // Hide/show text

        decoration: InputDecoration(
          hintText: hint,

          // Lock icon at start
          prefixIcon: const Icon(Icons.lock_outline, size: 20),

          // Eye icon to toggle visibility
          suffixIcon: IconButton(
            icon: Icon(
                obscured
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                size: 20),
            onPressed: toggle,
          ),

          border: InputBorder.none,
          contentPadding:
          const EdgeInsets.symmetric(vertical: 18),
        ),
      ),
    );
  }
}