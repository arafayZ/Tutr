// Import standard Flutter tools and other screens in your project
import 'dart:async';
import 'package:flutter/gestures.dart'; // Used for the clickable text in "Terms and Conditions"
import 'package:flutter/material.dart';
import 'profile_creation_screen.dart';
import 'login_screen.dart';

// Creating a StatefulWidget because the screen needs to track user input and errors
class SignupScreen extends StatefulWidget {
  final String role; // Stores if the user is a "Tutor" or "Student" passed from the previous screen
  const SignupScreen({super.key, required this.role});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  // Controllers to get the text typed into each box
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  // Booleans to track UI states (show/hide password, check boxes, and errors)
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreeToTerms = false;
  bool _showErrors = false;

  @override
  void dispose() {
    // Clean up all controllers when the user leaves the screen to save phone memory
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Function to show the "Terms and Conditions" popup
  void _showTermsPopup() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white, // Setting the background to white
        surfaceTintColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Condition & Attending", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              const Text("By signing up, you confirm that you are at least 18 years old..."), // Terms text
              const SizedBox(height: 20),
              const Text("Terms & Use", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              const Text("All payments and fees made through the app are final..."), // Usage text
            ],
          ),
        ),
        actions: [
          // OK button to close the popup
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
          ),
        ],
      ),
    );
  }

  // The main logic when the user clicks the "Continue" button
  void _handleSignup() {
    setState(() {
      // 1. Check if any text field is empty
      if (_nameController.text.isEmpty || _emailController.text.isEmpty ||
          _passwordController.text.isEmpty || _confirmPasswordController.text.isEmpty) {
        _showErrors = true;
        _showDialogPopup("Please fill in all mandatory fields to continue.");
      }
      // 2. Check if the two passwords match
      else if (_passwordController.text != _confirmPasswordController.text) {
        _showDialogPopup("Passwords do not match.");
      }
      // 3. Check if the user checked the "Terms" box
      else if (!_agreeToTerms) {
        _showDialogPopup("You must agree to the terms and conditions to sign up.");
      }
      // 4. If everything is perfect, move to the Profile Creation screen
      else {
        _showErrors = false;
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ProfileCreationScreen(role: widget.role)),
        );
      }
    });
  }

  // Helper function to show basic error popups
  void _showDialogPopup(String message) {
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
      backgroundColor: const Color(0xFFF8F9FB), // Light background color
      body: Column(
        children: [
          // White Header with the Back Button
          Container(
            width: double.infinity, height: 120,
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
                    onTap: () => Navigator.pop(context), // Goes back to the previous screen
                    child: const CircleAvatar(backgroundColor: Colors.black, child: Icon(Icons.arrow_back, color: Colors.white)),
                  ),
                ),
              ),
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 30),
                  const Text("Get Started", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                  // Shows if you are starting "as a Tutor" or "as a Student"
                  Text("as a ${widget.role}", style: const TextStyle(fontSize: 18, color: Colors.black54)),
                  const SizedBox(height: 40),

                  // Building the input fields using a helper function
                  _buildTextField(label: "Full name", icon: Icons.person_outline, controller: _nameController),
                  const SizedBox(height: 16),
                  _buildTextField(label: "Valid email", icon: Icons.email_outlined, controller: _emailController),
                  const SizedBox(height: 16),
                  _buildTextField(
                    label: "Strong password", icon: Icons.lock_outline,
                    isPassword: true, controller: _passwordController,
                    obscure: _obscurePassword,
                    onToggle: () => setState(() => _obscurePassword = !_obscurePassword), // Flips eye icon
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    label: "Confirm password", icon: Icons.lock_outline,
                    isPassword: true, controller: _confirmPasswordController,
                    obscure: _obscureConfirmPassword,
                    onToggle: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                  ),

                  const SizedBox(height: 20),

                  // The Terms and Conditions Checkbox Row
                  Row(
                    children: [
                      Checkbox(
                        value: _agreeToTerms,
                        activeColor: Colors.black,
                        onChanged: (val) => setState(() => _agreeToTerms = val!),
                      ),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            style: const TextStyle(color: Colors.black87, fontSize: 9),
                            children: [
                              const TextSpan(text: "By checking the box you agree to our "),
                              TextSpan(
                                text: "Terms and Conditions",
                                style: const TextStyle(fontWeight: FontWeight.bold),
                                // This makes the text "Terms and Conditions" clickable
                                recognizer: TapGestureRecognizer()..onTap = _showTermsPopup,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),

                  // The Big Black "Continue" Button
                  GestureDetector(
                    onTap: _handleSignup,
                    child: Container(
                      width: double.infinity, height: 60,
                      decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(30)),
                      child: const Center(child: Text("Continue", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold))),
                    ),
                  ),

                  const SizedBox(height: 25),

                  // Link to Login if they already have an account
                  GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen())),
                    child: const Text("Already a member? Login"),
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

  // Reusable helper function to create styled TextFields easily
  Widget _buildTextField({required String label, required IconData icon, required TextEditingController controller, bool isPassword = false, bool? obscure, VoidCallback? onToggle}) {
    return TextField(
      controller: controller,
      obscureText: isPassword ? (obscure ?? true) : false, // Hides text for passwords
      decoration: InputDecoration(
        hintText: label,
        prefixIcon: Icon(icon, color: Colors.grey),
        // Eye icon for passwords only
        suffixIcon: isPassword ? IconButton(icon: Icon((obscure ?? true) ? Icons.visibility_off_outlined : Icons.visibility_outlined), onPressed: onToggle) : null,
        filled: true, fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          // Shows a red border if the user tried to continue with an empty field
          borderSide: _showErrors && controller.text.isEmpty ? const BorderSide(color: Colors.red, width: 1.5) : BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.black, width: 1)),
      ),
    );
  }
}