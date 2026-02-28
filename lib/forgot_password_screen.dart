import 'package:flutter/material.dart';
import 'create_new_password_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  final String email;
  // Added 'const' to the constructor to fix the performance warning
  const ForgotPasswordScreen({super.key, required this.email});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  // Using 'const' here would cause errors because controllers are dynamic objects,
  // but we can make the list generation more efficient.
  final List<TextEditingController> _controllers = List.generate(4, (index) => TextEditingController());
  bool _showErrors = false;

  void _verifyOtp() {
    bool isComplete = _controllers.every((controller) => controller.text.isNotEmpty);

    if (!isComplete) {
      setState(() => _showErrors = true);
      _showErrorPopup();
    } else {
      setState(() => _showErrors = false);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const CreateNewPasswordScreen()),
      );
    }
  }

  void _showErrorPopup() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white, // Rule: White background
        surfaceTintColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        content: const Text(
          "Please enter the complete 4-digit code.",
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
                    const Text(
                      "Forgot Password",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0D1B3E)),
                    ),
                  ],
                ),
              ),
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  const SizedBox(height: 60),
                  Text(
                    "Code has been Sent to ${widget.email}",
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 13, color: Colors.black87),
                  ),
                  const SizedBox(height: 40),

                  // OTP Input Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(4, (index) => _otpBox(index)),
                  ),

                  const SizedBox(height: 60),

                  // Verify Button
                  GestureDetector(
                    onTap: _verifyOtp,
                    child: Container(
                      width: double.infinity,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Row( // Added 'const' to the row structure
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Spacer(flex: 2),
                          Text(
                            "Verify",
                            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                          ),
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

  Widget _otpBox(int index) {
    return Container(
      width: 65,
      height: 65,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: _showErrors && _controllers[index].text.isEmpty ? Colors.red : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: TextField(
        controller: _controllers[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        decoration: const InputDecoration(
          counterText: "",
          border: InputBorder.none,
        ),
        onChanged: (value) {
          if (value.isNotEmpty && index < 3) FocusScope.of(context).nextFocus();
          if (value.isEmpty && index > 0) FocusScope.of(context).previousFocus();
        },
      ),
    );
  }
}