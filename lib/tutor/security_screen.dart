import 'package:flutter/material.dart';

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

  // --- POPUP DIALOG BUILDER ---
  void _showStatusDialog({required String title, required String message, required bool isSuccess}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.white, // Specified white background
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
                      Navigator.pop(context); // Close dialog
                      if (isSuccess) Navigator.pop(context); // Return to profile if success
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

  void _handleChangePassword() {
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

    // Success case
    _showStatusDialog(
      title: "Updated",
      message: "Your password has been changed successfully!",
      isSuccess: true,
    );
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      resizeToAvoidBottomInset: true, // Prevents keyboard from squishing the layout
      body: SafeArea(
        child: Column(
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
                    _buildPasswordField("Password", _currentPasswordController, _obscureCurrent, () {
                      setState(() => _obscureCurrent = !_obscureCurrent);
                    }),
                    const SizedBox(height: 20),
                    _buildPasswordField("New Password", _newPasswordController, _obscureNew, () {
                      setState(() => _obscureNew = !_obscureNew);
                    }),
                    const SizedBox(height: 20),
                    _buildPasswordField("Confirm Password", _confirmPasswordController, _obscureConfirm, () {
                      setState(() => _obscureConfirm = !_obscureConfirm);
                    }),
                    const SizedBox(height: 50),

                    // --- CHANGE PASSWORD BUTTON ---
                    InkWell(
                      onTap: _handleChangePassword,
                      child: Container(
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(35),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Spacer(flex: 2),
                            const Text("Change Password",
                                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                            const Spacer(),
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
      ),
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