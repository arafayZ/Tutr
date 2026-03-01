// Importing Flutter material design package
import 'package:flutter/material.dart';

// Importing Create New Password screen for navigation
import 'create_new_password_screen.dart';

// Creating StatefulWidget for Forgot Password screen
class ForgotPasswordScreen extends StatefulWidget {

  // Variable to store user email
  final String email;

  // Constructor with required email parameter
  const ForgotPasswordScreen({super.key, required this.email});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

// State class for ForgotPasswordScreen
class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {

  // Creating 4 controllers for 4 OTP input boxes
  final List<TextEditingController> _controllers =
  List.generate(4, (index) => TextEditingController());

  // Boolean to show validation errors
  bool _showErrors = false;

  // Function to verify OTP
  void _verifyOtp() {

    // Check if all OTP boxes are filled
    bool isComplete =
    _controllers.every((controller) => controller.text.isNotEmpty);

    if (!isComplete) {
      // If OTP is incomplete
      setState(() => _showErrors = true); // Show red borders
      _showErrorPopup(); // Show error dialog
    } else {
      // If OTP is complete
      setState(() => _showErrors = false);

      // Navigate to Create New Password screen
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => const CreateNewPasswordScreen()),
      );
    }
  }

  // Function to show error popup
  void _showErrorPopup() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white, // White background
        surfaceTintColor: Colors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25)),

        // Error message text
        content: const Text(
          "Please enter the complete 4-digit code.",
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: Color(0xFF0D1B3E)),
        ),

        // OK button
        actions: [
          Center(
            child: TextButton(
              onPressed: () => Navigator.pop(context), // Close dialog
              child: const Text(
                "OK",
                style: TextStyle(
                    color: Color(0xFF0D1B3E),
                    fontWeight: FontWeight.bold,
                    fontSize: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    // Main screen layout
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
                padding:
                const EdgeInsets.symmetric(horizontal: 24.0),

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
                      "Forgot Password",
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
              padding:
              const EdgeInsets.symmetric(horizontal: 24.0),

              child: Column(
                children: [

                  const SizedBox(height: 60),

                  // Showing message with user email
                  Text(
                    "Code has been Sent to ${widget.email}",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black87),
                  ),

                  const SizedBox(height: 40),

                  // Row of 4 OTP input boxes
                  Row(
                    mainAxisAlignment:
                    MainAxisAlignment.spaceEvenly,
                    children:
                    List.generate(4, (index) => _otpBox(index)),
                  ),

                  const SizedBox(height: 60),

                  // Verify button
                  GestureDetector(
                    onTap: _verifyOtp, // Call verify function
                    child: Container(
                      width: double.infinity,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius:
                        BorderRadius.circular(30),
                      ),

                      child: const Row(
                        mainAxisAlignment:
                        MainAxisAlignment.center,
                        children: [
                          Spacer(flex: 2),

                          // Button text
                          Text(
                            "Verify",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                          ),

                          Spacer(),

                          // Arrow icon
                          Padding(
                            padding:
                            EdgeInsets.only(right: 8.0),
                            child: CircleAvatar(
                              backgroundColor:
                              Colors.white,
                              radius: 18,
                              child: Icon(
                                  Icons.arrow_forward,
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

  // Widget for single OTP box
  Widget _otpBox(int index) {

    return Container(
      width: 65,
      height: 65,

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),

        // Show red border if error and field is empty
        border: Border.all(
          color: _showErrors &&
              _controllers[index].text.isEmpty
              ? Colors.red
              : Colors.transparent,
          width: 1.5,
        ),
      ),

      child: TextField(
        controller: _controllers[index], // Attach controller

        textAlign: TextAlign.center, // Center text

        keyboardType: TextInputType.number, // Numeric keyboard

        maxLength: 1, // Only 1 digit allowed

        style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold),

        decoration: const InputDecoration(
          counterText: "", // Hide character counter
          border: InputBorder.none,
        ),

        onChanged: (value) {
          // Move to next box if value entered
          if (value.isNotEmpty && index < 3)
            FocusScope.of(context).nextFocus();

          // Move to previous box if deleted
          if (value.isEmpty && index > 0)
            FocusScope.of(context).previousFocus();
        },
      ),
    );
  }
}