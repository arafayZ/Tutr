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

  // --- VALIDATION HELPERS ---

  // Checks if the email format is valid (e.g., name@domain.com)
  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  // --- POPUPS & LOGIC ---

  // Function to show the "Terms and Conditions" popup
  void _showTermsPopup() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Condition & Attending", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              const Text("By signing up, you confirm that you are at least 18 years old and that all the information you provide is accurate and up-to-date. Both students and tutors agree to communicate respectfully and follow all guidelines provided within the app."),
              const SizedBox(height: 20),
              const Text("Terms & Use", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              const Text("All payments and fees made through the app are final. The platform is not responsible for any content or interactions shared between users. By creating an account, you acknowledge and accept these terms and conditions."),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Colors.black)),
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
      // 2. NEW: Email Format Validation
      else if (!_isValidEmail(_emailController.text)) {
        _showDialogPopup("Please enter a valid email address.");
      }
      // 3. Check if the two passwords match
      else if (_passwordController.text != _confirmPasswordController.text) {
        _showDialogPopup("Passwords do not match.");
      }
      // 4. Check if the user checked the "Terms" box
      else if (!_agreeToTerms) {
        _showDialogPopup("You must agree to the terms and conditions to sign up.");
      }
      // 5. Success -> Navigate to Profile Creation
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Text(message, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16)),
        actions: [
          Center(
            child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("OK", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold))
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
                    onTap: () => Navigator.pop(context),
                    child: const CircleAvatar(
                        backgroundColor: Colors.black,
                        child: Icon(Icons.arrow_back, color: Colors.white)
                    ),
                  ),
                ),
              ),
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  const SizedBox(height: 30),
                  const Text("Get Started", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                  Text("as a ${widget.role}", style: const TextStyle(fontSize: 18, color: Colors.black54)),
                  const SizedBox(height: 40),

                  _buildTextField(label: "Full name", icon: Icons.person_outline, controller: _nameController),
                  const SizedBox(height: 16),
                  _buildTextField(label: "Valid email", icon: Icons.email_outlined, controller: _emailController),
                  const SizedBox(height: 16),
                  _buildTextField(
                    label: "Strong password", icon: Icons.lock_outline,
                    isPassword: true, controller: _passwordController,
                    obscure: _obscurePassword,
                    onToggle: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    label: "Confirm password", icon: Icons.lock_outline,
                    isPassword: true, controller: _confirmPasswordController,
                    obscure: _obscureConfirmPassword,
                    onToggle: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                  ),

                  const SizedBox(height: 20),

                  // Terms Row
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
                            style: const TextStyle(color: Colors.black87, fontSize: 11),
                            children: [
                              const TextSpan(text: "By checking the box you agree to our "),
                              TextSpan(
                                text: "Terms and Conditions",
                                style: const TextStyle(fontWeight: FontWeight.bold, decoration: TextDecoration.underline),
                                recognizer: TapGestureRecognizer()..onTap = _showTermsPopup,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),

                  // Continue Button
                  GestureDetector(
                    onTap: _handleSignup,
                    child: Container(
                      width: double.infinity, height: 60,
                      decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(30)),
                      child: const Center(
                          child: Text("Continue", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold))
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen())),
                    child: const Text.rich(
                      TextSpan(
                        text: "Already a member? ",
                        children: [
                          TextSpan(text: "Login", style: TextStyle(fontWeight: FontWeight.bold)),
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

  // Reusable helper function for TextFields
  Widget _buildTextField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    bool isPassword = false,
    bool? obscure,
    VoidCallback? onToggle
  }) {
    // Determine the keyboard type based on the hint text
    TextInputType keyboardType = TextInputType.text;
    if (label.toLowerCase().contains("email")) {
      keyboardType = TextInputType.emailAddress;
    }

    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: isPassword ? (obscure ?? true) : false,
      decoration: InputDecoration(
        hintText: label,
        prefixIcon: Icon(icon, color: Colors.grey),
        suffixIcon: isPassword
            ? IconButton(
            icon: Icon((obscure ?? true) ? Icons.visibility_off_outlined : Icons.visibility_outlined),
            onPressed: onToggle
        )
            : null,
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: _showErrors && controller.text.isEmpty
              ? const BorderSide(color: Colors.red, width: 1.5)
              : BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.black, width: 1)
        ),
      ),
    );
  }
}