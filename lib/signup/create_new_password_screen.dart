import 'package:flutter/material.dart';
import 'dart:async';
import '../services/auth_service.dart';
import 'login_screen.dart';

class CreateNewPasswordScreen extends StatefulWidget {
  final String email;
  final String otpCode;

  const CreateNewPasswordScreen({
    super.key,
    required this.email,
    required this.otpCode,
  });

  @override
  State<CreateNewPasswordScreen> createState() => _CreateNewPasswordScreenState();
}

class _CreateNewPasswordScreenState extends State<CreateNewPasswordScreen> {
  final TextEditingController _passController = TextEditingController();
  final TextEditingController _confirmPassController = TextEditingController();

  bool _showErrors = false;
  bool _isObscured1 = true;
  bool _isObscured2 = true;
  bool _isLoading = false;

  // Password strength tracking
  bool _hasMinLength = false;
  bool _hasUppercase = false;
  bool _hasLowercase = false;
  bool _hasDigit = false;
  bool _hasSpecialChar = false;

  @override
  void initState() {
    super.initState();
    _passController.addListener(_validatePasswordStrength);
  }

  void _validatePasswordStrength() {
    String password = _passController.text;
    setState(() {
      _hasMinLength = password.length >= 8;
      _hasUppercase = password.contains(RegExp(r'[A-Z]'));
      _hasLowercase = password.contains(RegExp(r'[a-z]'));
      _hasDigit = password.contains(RegExp(r'[0-9]'));
      _hasSpecialChar = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    });
  }

  bool get isPasswordValid {
    return _hasMinLength && _hasUppercase && _hasLowercase && _hasDigit && _hasSpecialChar;
  }

  int get passwordStrength {
    int strength = 0;
    if (_hasMinLength) strength++;
    if (_hasUppercase) strength++;
    if (_hasLowercase) strength++;
    if (_hasDigit) strength++;
    if (_hasSpecialChar) strength++;
    return strength;
  }

  String get passwordStrengthText {
    int strength = passwordStrength;
    if (strength <= 2) return 'Weak';
    if (strength <= 4) return 'Medium';
    return 'Strong';
  }

  Color get passwordStrengthColor {
    int strength = passwordStrength;
    if (strength <= 2) return Colors.red;
    if (strength <= 4) return Colors.orange;
    return Colors.green;
  }

  @override
  void dispose() {
    _passController.removeListener(_validatePasswordStrength);
    _passController.dispose();
    _confirmPassController.dispose();
    super.dispose();
  }

  void _handleContinue() async {
    String newPassword = _passController.text.trim();
    String confirmPassword = _confirmPassController.text.trim();

    setState(() {
      _showErrors = newPassword.isEmpty || confirmPassword.isEmpty;
    });

    if (newPassword.isEmpty || confirmPassword.isEmpty) {
      _showErrorPopup("Please fill in all fields.");
      return;
    }

    // Password strength validation
    if (!isPasswordValid) {
      _showErrorPopup(
          "Password must contain:\n"
              "• At least 8 characters\n"
              "• One uppercase letter\n"
              "• One lowercase letter\n"
              "• One number\n"
              "• One special character (!@#%^&*)"
      );
      return;
    }

    if (newPassword != confirmPassword) {
      _showErrorPopup("Passwords do not match.");
      return;
    }

    setState(() => _isLoading = true);

    try {
      await AuthService.resetPassword(
        widget.email,
        widget.otpCode,
        newPassword,
        confirmPassword,
      );

      if (!mounted) return;

      _showSuccessPopup();
    } catch (e) {
      if (!mounted) return;
      String errorMsg = e.toString().replaceFirst('Exception: ', '');
      _showErrorPopup(errorMsg);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showErrorPopup(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: Color(0xFF0D1B3E),
          ),
        ),
        actions: [
          Center(
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "OK",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Color(0xFF0D1B3E),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSuccessPopup() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 20),
            Image.asset(
              'assets/images/verification_complete.png',
              height: 120,
              width: 120,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 20),
            const Text(
              "Congratulations",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0D1B3E),
              ),
            ),
            const SizedBox(height: 15),
            const Text(
              "Your password has been reset successfully. You will be redirected to the Login Page in a Few Seconds.",
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

  Widget _buildRequirementTile(String text, bool isMet) {
    return Row(
      children: [
        Icon(
          isMet ? Icons.check_circle : Icons.circle_outlined,
          size: 12,
          color: isMet ? Colors.green : Colors.grey,
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            fontSize: 10,
            color: isMet ? Colors.green : Colors.grey[600],
            decoration: isMet ? TextDecoration.lineThrough : null,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, 5),
                )
              ],
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Align(
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
                    const Text(
                      "Create New Password",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0D1B3E),
                      ),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  const Text(
                    "Create Your New Password",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0D1B3E),
                    ),
                  ),
                  const SizedBox(height: 25),

                  // Password field with strength indicator
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _passwordField(
                        "Password",
                        _passController,
                        _isObscured1,
                            () => setState(() => _isObscured1 = !_isObscured1),
                      ),
                      if (_passController.text.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    "Password Strength: ",
                                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                  ),
                                  Text(
                                    passwordStrengthText,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: passwordStrengthColor,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              LinearProgressIndicator(
                                value: passwordStrength / 5,
                                backgroundColor: Colors.grey[200],
                                color: passwordStrengthColor,
                                minHeight: 4,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Requirements:",
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey[700]),
                              ),
                              _buildRequirementTile("At least 8 characters", _hasMinLength),
                              _buildRequirementTile("Uppercase letter (A-Z)", _hasUppercase),
                              _buildRequirementTile("Lowercase letter (a-z)", _hasLowercase),
                              _buildRequirementTile("Number (0-9)", _hasDigit),
                              _buildRequirementTile("Special character (!@#\$%^&*)", _hasSpecialChar),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),

                  const SizedBox(height: 15),

                  _passwordField(
                    "Confirm Password",
                    _confirmPassController,
                    _isObscured2,
                        () => setState(() => _isObscured2 = !_isObscured2),
                  ),

                  const SizedBox(height: 60),

                  GestureDetector(
                    onTap: _isLoading ? null : _handleContinue,
                    child: Container(
                      width: double.infinity,
                      height: 60,
                      decoration: BoxDecoration(
                        color: _isLoading ? Colors.grey : Colors.black,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Center(
                        child: _isLoading
                            ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                            : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Spacer(flex: 2),
                            Text(
                              "Continue",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Spacer(),
                            Padding(
                              padding: EdgeInsets.only(right: 8.0),
                              child: CircleAvatar(
                                backgroundColor: Colors.white,
                                radius: 18,
                                child: Icon(
                                  Icons.arrow_forward,
                                  color: Colors.black,
                                  size: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
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

  Widget _passwordField(
      String hint,
      TextEditingController controller,
      bool obscured,
      VoidCallback toggle,
      ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: _showErrors && controller.text.isEmpty
            ? Border.all(color: Colors.red, width: 1.5)
            : null,
      ),
      child: TextField(
        controller: controller,
        obscureText: obscured,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: const Icon(Icons.lock_outline, size: 20),
          suffixIcon: IconButton(
            icon: Icon(
              obscured ? Icons.visibility_off_outlined : Icons.visibility_outlined,
              size: 20,
            ),
            onPressed: toggle,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
        ),
      ),
    );
  }
}