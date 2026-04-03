import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';

class SecurityScreen extends StatefulWidget {
  const SecurityScreen({super.key});

  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
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
    _newPasswordController.addListener(_validatePasswordStrength);
  }

  void _validatePasswordStrength() {
    String password = _newPasswordController.text;
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
    _newPasswordController.removeListener(_validatePasswordStrength);
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _showStatusDialog({required String title, required String message, required bool isSuccess}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSuccess ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isSuccess ? Icons.check_circle : Icons.error_outline,
                    color: isSuccess ? Colors.green : Colors.red,
                    size: 50,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  title,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 15, color: Colors.grey),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      if (isSuccess) Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text("OK", style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleChangePassword() async {
    String currentPw = _currentPasswordController.text.trim();
    String newPw = _newPasswordController.text.trim();
    String confirmPw = _confirmPasswordController.text.trim();

    if (currentPw.isEmpty || newPw.isEmpty || confirmPw.isEmpty) {
      _showStatusDialog(
        title: "Error",
        message: "Please fill in all the fields before proceeding.",
        isSuccess: false,
      );
      return;
    }

    if (newPw != confirmPw) {
      _showStatusDialog(
        title: "Mismatch",
        message: "The new password and confirmation do not match.",
        isSuccess: false,
      );
      return;
    }

    // Password strength validation
    if (!isPasswordValid) {
      _showStatusDialog(
        title: "Weak Password",
        message: "Password must contain:\n"
            "• At least 8 characters\n"
            "• One uppercase letter\n"
            "• One lowercase letter\n"
            "• One number\n"
            "• One special character (!@#\$%^&*)",
        isSuccess: false,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int userId = prefs.getInt('userId') ?? 0;

      if (userId == 0) {
        throw Exception('User not found. Please login again.');
      }

      await AuthService.changePassword(
        userId: userId,
        currentPassword: currentPw,
        newPassword: newPw,
        confirmPassword: confirmPw,
      );

      setState(() => _isLoading = false);

      _showStatusDialog(
        title: "Success",
        message: "Your password has been changed successfully!",
        isSuccess: true,
      );

      _currentPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();

    } catch (e) {
      setState(() => _isLoading = false);
      _showStatusDialog(
        title: "Error",
        message: e.toString().replaceFirst('Exception: ', ''),
        isSuccess: false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // --- HEADER ---
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      InkWell(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          height: 40, width: 40,
                          decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle),
                          child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                        ),
                      ),
                      const Expanded(
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.only(right: 40),
                            child: Text("Security", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // --- SCROLLABLE CONTENT ---
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: Column(
                      children: [
                        const SizedBox(height: 40),
                        _buildPasswordField("Current Password", _currentPasswordController, _obscureCurrent, () {
                          setState(() => _obscureCurrent = !_obscureCurrent);
                        }),
                        const SizedBox(height: 20),

                        // New Password field with strength indicator
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildPasswordField("New Password", _newPasswordController, _obscureNew, () {
                              setState(() => _obscureNew = !_obscureNew);
                            }),
                            if (_newPasswordController.text.isNotEmpty) ...[
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

                        const SizedBox(height: 20),
                        _buildPasswordField("Confirm Password", _confirmPasswordController, _obscureConfirm, () {
                          setState(() => _obscureConfirm = !_obscureConfirm);
                        }),
                        const SizedBox(height: 50),

                        // --- CHANGE PASSWORD BUTTON ---
                        InkWell(
                          onTap: _isLoading ? null : _handleChangePassword,
                          child: Container(
                            height: 60,
                            decoration: BoxDecoration(
                              color: _isLoading ? Colors.grey : Colors.black,
                              borderRadius: BorderRadius.circular(35),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Spacer(flex: 2),
                                _isLoading
                                    ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                                    : const Text(
                                  "Change Password",
                                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                                const Spacer(),
                                if (!_isLoading)
                                  Container(
                                    height: 40, width: 40,
                                    margin: const EdgeInsets.only(right: 10),
                                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                                    child: const Icon(Icons.arrow_forward, color: Colors.black),
                                  ),
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
            if (_isLoading)
              Container(
                color: Colors.black54,
                child: const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              ),
          ],
        ),
      ),
    );
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

  Widget _buildPasswordField(String hint, TextEditingController controller, bool obscure, VoidCallback onToggle) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        cursorColor: Colors.black,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey.shade500),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          suffixIcon: IconButton(
            icon: Icon(
              obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
              color: Colors.grey,
            ),
            onPressed: onToggle,
          ),
        ),
      ),
    );
  }
}