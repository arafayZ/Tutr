import 'package:flutter/material.dart';
import 'dart:async';
import 'login_screen.dart';

class CreateNewPasswordScreen extends StatefulWidget {
  const CreateNewPasswordScreen({super.key});

  @override
  State<CreateNewPasswordScreen> createState() => _CreateNewPasswordScreenState();
}

class _CreateNewPasswordScreenState extends State<CreateNewPasswordScreen> {
  final TextEditingController _passController = TextEditingController();
  final TextEditingController _confirmPassController = TextEditingController();
  bool _showErrors = false;
  bool _isObscured1 = true;
  bool _isObscured2 = true;

  void _handleContinue() {
    setState(() {
      if (_passController.text.isEmpty ||
          _confirmPassController.text.isEmpty ||
          _passController.text != _confirmPassController.text) {
        _showErrors = true;
        _showErrorPopup();
      } else {
        _showErrors = false;
        // Logic: Jump straight to success popup
        _showSuccessPopup();
      }
    });
  }

  void _showErrorPopup() {
    String msg = _passController.text != _confirmPassController.text
        ? "Passwords do not match!"
        : "Please fill in all fields.";
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white, // Rule: White background
        surfaceTintColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        content: Text(msg,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: Color(0xFF0D1B3E))),
        actions: [
          Center(
              child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("OK", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF0D1B3E)))))
        ],
      ),
    );
  }

  void _showSuccessPopup() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white, // Rule: White background
        surfaceTintColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 20),
            // Replacing standard icon with your design intent
            const Icon(Icons.check_circle_outline, size: 80, color: Colors.blueGrey),
            const SizedBox(height: 20),
            const Text("Congratulations",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0D1B3E))),
            const SizedBox(height: 15),
            const Text(
              "Your Account is Ready to Use. You will be redirected to the Login Page in a Few Seconds.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            const CircularProgressIndicator(color: Color(0xFF0D1B3E)),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );

    // Redirection logic: Wait 5 seconds then go to Login
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
          // Header
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
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const CircleAvatar(
                        backgroundColor: Colors.black,
                        radius: 22,
                        child: Icon(Icons.arrow_back, color: Colors.white, size: 20),
                      ),
                    ),
                    const SizedBox(width: 20),
                    const Text("Create New Password",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0D1B3E))),
                  ],
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
                  const SizedBox(height: 100),
                  const Text("Create Your New Password",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0D1B3E))),
                  const SizedBox(height: 25),
                  _passwordField("Password", _passController, _isObscured1,
                          () => setState(() => _isObscured1 = !_isObscured1)),
                  const SizedBox(height: 15),
                  _passwordField("Confirm Password", _confirmPassController, _isObscured2,
                          () => setState(() => _isObscured2 = !_isObscured2)),
                  const SizedBox(height: 60),
                  GestureDetector(
                    onTap: _handleContinue,
                    child: Container(
                      width: double.infinity,
                      height: 60,
                      decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(30)),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Spacer(flex: 2),
                          Text("Continue",
                              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                          Spacer(),
                          Padding(
                            padding: EdgeInsets.only(right: 8.0),
                            child: CircleAvatar(
                              backgroundColor: Colors.white,
                              radius: 18,
                              child: Icon(Icons.arrow_forward, color: Colors.black, size: 20),
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

  Widget _passwordField(String hint, TextEditingController controller, bool obscured, VoidCallback toggle) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: _showErrors && controller.text.isEmpty ? Border.all(color: Colors.red, width: 1.5) : null,
      ),
      child: TextField(
        controller: controller,
        obscureText: obscured,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: const Icon(Icons.lock_outline, size: 20),
          suffixIcon: IconButton(
            icon: Icon(obscured ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 20),
            onPressed: toggle,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
        ),
      ),
    );
  }
}