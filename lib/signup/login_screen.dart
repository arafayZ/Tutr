// Importing Flutter material design package for UI components
import 'package:flutter/material.dart';

// Importing role selection screen for registration navigation
import 'role_selection_screen.dart';

// Importing tutor and student dashboards for successful login navigation
import '../tutor/tutor_dashboard.dart';
import '../student/student_dashboard.dart';

// Importing forgot password screen
import 'forgot_password_screen.dart';

// Creating StatefulWidget for Login screen to manage input states and visibility
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

// State class for LoginScreen
class _LoginScreenState extends State<LoginScreen> {

  // Controller for the email input field to retrieve text
  final TextEditingController _emailController = TextEditingController();

  // Controller for the password input field to retrieve text
  final TextEditingController _passwordController = TextEditingController();

  // Boolean to toggle between showing and hiding password characters
  bool _obscureText = true;

  // Boolean to track the state of the "Remember me" checkbox
  bool _rememberMe = false;

  // Boolean used to trigger red borders on empty fields during validation
  bool _showErrors = false;

  @override
  void dispose() {
    // Disposing controllers when the screen is destroyed to prevent memory leaks
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Function to validate inputs and handle the login logic
  void _validateAndLogin() {
    setState(() {

      // Getting trimmed email and password to avoid issues with accidental spaces
      String email = _emailController.text.trim().toLowerCase();
      String password = _passwordController.text.trim();

      // Basic validation: check if fields are empty
      if (email.isEmpty || password.isEmpty) {
        _showErrors = true;
        _showErrorPopup("Please enter your email and password to sign in.");
      } else {
        _showErrors = false;

        // Simple role detection logic based on the email string content
        String? userRole;

        if (email.contains("tutor")) {
          userRole = "Tutor";
        } else if (email.contains("student")) {
          userRole = "Student";
        } else {
          userRole = "Tutor"; // Defaulting to Tutor if no keyword is found
        }

        // Determining which dashboard to navigate to based on the detected role
        Widget dashboard = (userRole == "Tutor")
            ? const TutorDashboard()
            : const StudentDashboard();

        // Navigate to the dashboard and clear the navigation stack
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => dashboard),
              (route) => false,
        );
      }
    });
  }

  // Function to show a custom error popup dialog
  void _showErrorPopup(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        // Background set to white as per user instructions
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25)),

        // Displaying the dynamic error message
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: Color(0xFF0D1B3E),
          ),
        ),

        // Action button to close the dialog
        actions: [
          Center(
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "OK",
                style: TextStyle(
                  color: Color(0xFF0D1B3E),
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                ),
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
      // Soft light grey/blue background for the whole page
      backgroundColor: const Color(0xFFF8F9FB),
      // SafeArea ensures content doesn't go under the status bar or notch
      body: SafeArea(
        // SingleChildScrollView allows the user to scroll if the keyboard covers the fields
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              // Large top margin to push content down the screen
              const SizedBox(height: 80),

              // Main Heading text
              const Text(
                "Welcome back",
                style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0D1B3E)),
              ),

              const SizedBox(height: 8),

              // Subheading text
              const Text(
                "sign in to access your account",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),

              const SizedBox(height: 60),

              // Reusable Email input field
              _buildInputField(
                controller: _emailController,
                hint: "Enter your email",
                icon: Icons.email_outlined,
              ),

              const SizedBox(height: 20),

              // Reusable Password input field with visibility toggle
              _buildInputField(
                controller: _passwordController,
                hint: "Password",
                icon: Icons.lock_outline,
                obscureText: _obscureText,

                // Eye icon button to flip the boolean for obscureText
                suffix: IconButton(
                  icon: Icon(
                    _obscureText
                        ? Icons.visibility_off
                        : Icons.visibility,
                    color: Colors.grey,
                  ),
                  onPressed: () => setState(
                          () => _obscureText = !_obscureText),
                ),
              ),

              const SizedBox(height: 15),

              // Row for the Remember Me checkbox and Forgot Password link
              Row(
                mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
                children: [

                  // Remember me checkbox group
                  Row(
                    children: [
                      Checkbox(
                        value: _rememberMe,
                        activeColor: Colors.black,
                        onChanged: (val) =>
                            setState(() => _rememberMe = val!),
                      ),
                      const Text(
                        "Remember me",
                        style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey),
                      ),
                    ],
                  ),

                  // Forgot password text button
                  TextButton(
                    onPressed: () {
                      // Navigate only if an email is provided
                      if (_emailController.text.trim().isNotEmpty) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ForgotPasswordScreen(
                                  email: _emailController.text.trim(),
                                ),
                          ),
                        );
                      } else {
                        // Error if they try to reset without typing an email first
                        _showErrorPopup(
                            "Please enter your email address first to reset your password.");
                      }
                    },
                    child: const Text(
                      "Forget password?",
                      style: TextStyle(
                          fontSize: 12,
                          color: Colors.black,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // Main Login/Sign-in button
              GestureDetector(
                onTap: _validateAndLogin,
                child: Container(
                  width: double.infinity,
                  height: 60,
                  decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius:
                      BorderRadius.circular(15)),
                  child: const Center(
                    child: Text(
                      "Sign in",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),

              // FIXED: Changed '3s5' to '35' to fix the compilation error
              const SizedBox(height: 35),

              // Footer section for new users to register
              Row(
                mainAxisAlignment:
                MainAxisAlignment.center,
                children: [
                  const Text(
                    "New member? ",
                    style:
                    TextStyle(color: Colors.grey),
                  ),

                  // Link to start the registration flow
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                            const RoleSelectionScreen()),
                      );
                    },
                    child: const Text(
                      "Register now",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Reusable TextField styling method
  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    Widget? suffix,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,

      decoration: InputDecoration(
        hintText: hint,
        hintStyle:
        const TextStyle(color: Colors.grey, fontSize: 14),

        // Icon shown at the start of the field
        prefixIcon:
        Icon(icon, color: Colors.grey.shade400, size: 22),

        // Optional widget (like the eye icon) at the end
        suffixIcon: suffix,

        filled: true,
        fillColor: Colors.white,

        contentPadding:
        const EdgeInsets.symmetric(vertical: 18, horizontal: 16),

        // Styling for the border when field is empty and error is triggered
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: _showErrors &&
              controller.text.isEmpty
              ? const BorderSide(
              color: Colors.red, width: 1.5)
              : BorderSide.none,
        ),

        // Styling for the border when user focuses on the field
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide:
          const BorderSide(color: Colors.black, width: 1),
        ),
      ),
    );
  }
}