import 'dart:async';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'profile_creation_screen.dart';
import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  final String role;
  const SignupScreen({super.key, required this.role});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreeToTerms = false;
  bool _showErrors = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Matches the "Condition & Attending" and "Terms & Use" screenshot
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
              const Text(
                "Condition & Attending",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0D1B3E)),
              ),
              const SizedBox(height: 10),
              const Text(
                "By signing up, you confirm that you are at least 18 years old and that all the information you provide is accurate and up-to-date. Both students and tutors agree to communicate respectfully and follow all guidelines provided within the app. Tutors are responsible for the correctness of their course details, schedules, and availability.",
                style: TextStyle(fontSize: 13, height: 1.4, color: Colors.black87),
              ),
              const SizedBox(height: 20),
              const Text(
                "Terms & Use",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0D1B3E)),
              ),
              const SizedBox(height: 10),
              const Text(
                "All payments and fees made through the app are final. The platform is not responsible for any content or interactions shared between users. By creating an account, you acknowledge and accept these terms and conditions.",
                style: TextStyle(fontSize: 13, height: 1.4, color: Colors.black87),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "OK",
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Color(0xFF0D1B3E)),
            ),
          ),
        ],
      ),
    );
  }

  void _handleSignup() {
    setState(() {
      if (_nameController.text.isEmpty || _emailController.text.isEmpty ||
          _passwordController.text.isEmpty || _confirmPasswordController.text.isEmpty) {
        _showErrors = true;
        _showDialogPopup("Please fill in all mandatory fields to continue.");
      } else if (_passwordController.text != _confirmPasswordController.text) {
        _showDialogPopup("Passwords do not match.");
      } else if (!_agreeToTerms) {
        _showDialogPopup("You must agree to the terms and conditions to sign up.");
      } else {
        _showErrors = false;
        // Proceed to Profile Creation
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ProfileCreationScreen(role: widget.role)),
        );
      }
    });
  }

  void _showDialogPopup(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        content: Padding(
          padding: const EdgeInsets.only(top: 15),
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: Color(0xFF0D1B3E)),
          ),
        ),
        actions: [
          Center(
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF0D1B3E))),
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
          // Header
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
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 30),
                  const Text("Get Started", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF0D1B3E))),
                  Text("as a ${widget.role}", style: const TextStyle(fontSize: 18, color: Colors.black54)),
                  const SizedBox(height: 40),

                  _buildTextField(label: "Full name", icon: Icons.person_outline, controller: _nameController),
                  const SizedBox(height: 16),
                  _buildTextField(label: "Valid email", icon: Icons.email_outlined, controller: _emailController),
                  const SizedBox(height: 16),

                  _buildTextField(
                    label: "Strong password",
                    icon: Icons.lock_outline,
                    isPassword: true,
                    controller: _passwordController,
                    obscure: _obscurePassword,
                    onToggle: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  const SizedBox(height: 16),

                  _buildTextField(
                    label: "Confirm password",
                    icon: Icons.lock_outline,
                    isPassword: true,
                    controller: _confirmPasswordController,
                    obscure: _obscureConfirmPassword,
                    onToggle: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                  ),

                  const SizedBox(height: 20),

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
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0D1B3E),
                                ),
                                recognizer: TapGestureRecognizer()..onTap = _showTermsPopup,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),

                  GestureDetector(
                    onTap: _handleSignup,
                    child: Container(
                      width: double.infinity, height: 60,
                      decoration: BoxDecoration(
                        color: Colors.black, borderRadius: BorderRadius.circular(30),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 8, offset: const Offset(0, 4))],
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Spacer(flex: 2),
                          Text("Continue", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                          Spacer(),
                          CircleAvatar(backgroundColor: Colors.white, radius: 18, child: Icon(Icons.arrow_forward, color: Colors.black, size: 20)),
                          SizedBox(width: 10),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  GestureDetector(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
                    },
                    child: RichText(
                      text: const TextSpan(
                        style: TextStyle(color: Colors.black54, fontSize: 10),
                        children: [
                          TextSpan(text: "Already a member? "),
                          TextSpan(text: "Login", style: TextStyle(color: Color(0xFF0D1B3E), fontWeight: FontWeight.bold)),
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

  Widget _buildTextField({required String label, required IconData icon, required TextEditingController controller, bool isPassword = false, bool? obscure, VoidCallback? onToggle}) {
    return TextField(
      controller: controller,
      obscureText: isPassword ? (obscure ?? true) : false,
      decoration: InputDecoration(
        hintText: label,
        prefixIcon: Icon(icon, color: Colors.grey),
        suffixIcon: isPassword ? IconButton(icon: Icon((obscure ?? true) ? Icons.visibility_off_outlined : Icons.visibility_outlined), onPressed: onToggle) : null,
        filled: true, fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: _showErrors && controller.text.isEmpty ? const BorderSide(color: Colors.red, width: 1.5) : BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.black, width: 1)),
      ),
    );
  }
}