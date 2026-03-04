// Import the Flutter material design package
import 'package:flutter/material.dart';

// Stateful widget for adding a new course
class AddCourseScreen extends StatefulWidget {
  const AddCourseScreen({super.key});

  @override
  State<AddCourseScreen> createState() => _AddCourseScreenState();
}

// State class for AddCourseScreen
class _AddCourseScreenState extends State<AddCourseScreen> {
  // Flag to simulate the tutor's approval status.
  // Set to 'true' to show the "Account Pending" screen.
  bool isPending = false;

  // Controllers to manage the text input for the form fields.
  // Each controller is linked to a TextField to capture user input.
  final TextEditingController _aboutController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _feeController = TextEditingController();

  // Static lists to populate the dropdown menus.
  // These are constant lists that won't change during runtime.
  static const List<String> _timeList = ["00:00", "09:00", "10:00", "11:00", "12:00", "13:00", "14:00"];
  static const List<String> _dayList = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"];
  static const List<String> _classList = ["00", "01", "02", "03", "04", "05", "06", "07", "08", "09", "10"];

  // State variables to hold the user's selected values from dropdowns.
  String? _selectedCategory; // Selected category (Metric, Intermediate, etc.)
  String? _selectedMode; // Selected teaching mode (Online, Tutor Home, etc.)
  String _startTime = "00:00"; // Default start time
  String _endTime = "00:00"; // Default end time
  String _startDay = "Monday"; // Default start day
  String _endDay = "Friday"; // Default end day
  String _classesPerMonth = "00"; // Default number of classes per month

  // Control flag to show red borders if validation fails.
  // When true, empty fields will be highlighted with red borders.
  bool _showErrors = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(), // Custom app bar with back button
      // Logic: If account is pending, show the hourglass view. Otherwise, show the form.
      body: isPending ? _buildPendingView() : _buildFormView(),
    );
  }

  // --- PENDING VIEW (Displays when tutor is not yet approved) ---
  // This widget is shown when the tutor's account is still under review
  Widget _buildPendingView() {
    // FIX: Center does not have a padding parameter. Use a Padding widget wrapper.
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Visual representation of the waiting state (Hourglass).
            Icon(
              Icons.hourglass_empty_rounded,
              size: 150,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 30),
            // Informative text explaining why the user cannot add a course yet.
            const Text(
              "Your account is pending. You cannot add courses until your account is approved.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- MAIN FORM VIEW (The data entry screen) ---
  // This widget contains all the form fields for adding a new course
  Widget _buildFormView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Heading: About
          const Text("About", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF000000))),
          const SizedBox(height: 10),
          _buildAboutField(), // Multiline description box for course description
          const Align(
            alignment: Alignment.centerRight,
            child: Text("(Word limit: 100)", style: TextStyle(color: Colors.grey, fontSize: 11)),
          ),
          const SizedBox(height: 20),

          // Section Heading: What You Provide
          const Text("What You Provide", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF000000))),
          const SizedBox(height: 15),

          // Subject field with label positioned above the box for alignment.
          _buildFieldWithHeading("Subject", _subjectController, hint: "maths"),

          // Dropdowns for Category and Mode selection
          _buildDropdown("Category", const ["Metric", "Intermediate", "O & A Level", "Entrance Test"], _selectedCategory, (val) => setState(() => _selectedCategory = val)),
          _buildDropdown("Teaching Mode", const ["Online", "Tutor Home", "Student Home"], _selectedMode, (val) => setState(() => _selectedMode = val)),

          // Location field (Area, City). Fixed typo in hint.
          _buildFieldWithHeading("Area, City", _locationController, hint: "Gulistan-e-Jauhar"),

          const SizedBox(height: 10),
          // Row for Start and End Time dropdowns (side by side)
          Row(
            children: [
              Expanded(child: _buildSmallDropdown("Start Time", _timeList, _startTime, (val) => setState(() => _startTime = val!))),
              const SizedBox(width: 15),
              Expanded(child: _buildSmallDropdown("End Time", _timeList, _endTime, (val) => setState(() => _endTime = val!))),
            ],
          ),

          const SizedBox(height: 20),
          // Row for Days selection with a "To" separator between start and end day
          Row(
            children: [
              Expanded(child: _buildSmallDropdown("Days", _dayList, _startDay, (val) => setState(() => _startDay = val!))),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                child: Text("To", style: TextStyle(fontWeight: FontWeight.w500)),
              ),
              Expanded(child: _buildSmallDropdown("Days", _dayList, _endDay, (val) => setState(() => _endDay = val!))),
            ],
          ),

          const SizedBox(height: 20),
          // Row for Class frequency and Tuition Fee (side by side)
          Row(
            children: [
              Expanded(child: _buildSmallDropdown("Classes (per month)", _classList, _classesPerMonth, (val) => setState(() => _classesPerMonth = val!))),
              const SizedBox(width: 15),
              Expanded(child: _buildFieldWithHeading("Tuition Fee (PKR)", _feeController, hint: "0000")),
            ],
          ),

          const SizedBox(height: 60),
          // Final Action Buttons: Cancel and Add. Added 'const' to improve performance.
          Row(
            children: [
              Expanded(child: _buildButton("Cancel", const Color(0xFFEEEEEE), Colors.black, () => Navigator.pop(context))),
              const SizedBox(width: 15),
              Expanded(child: _buildButton("Add", Colors.black, Colors.white, _validateAndSubmit)),
            ],
          ),
          const SizedBox(height: 40), // Bottom padding
        ],
      ),
    );
  }

  // --- UI Reusable Helpers ---
  // These methods create reusable UI components to avoid code duplication

  // Builds the custom app bar with a black circular back button
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0, // Remove shadow
      centerTitle: true,
      // Custom back button with black background
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: CircleAvatar(
          backgroundColor: Colors.black,
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 18),
            onPressed: () => Navigator.pop(context), // Navigate back when pressed
          ),
        ),
      ),
      title: const Text("Add Course", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
    );
  }

  // Builds a text field with a heading label above it
  Widget _buildFieldWithHeading(String label, TextEditingController controller, {String? hint}) {
    // Check if this field should show an error (empty and validation enabled)
    bool hasError = _showErrors && controller.text.trim().isEmpty;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          TextField(
            controller: controller, // Link the controller to capture input
            decoration: InputDecoration(
              hintText: hint, // Optional hint text
              hintStyle: const TextStyle(color: Colors.black54, fontSize: 14),
              filled: true,
              fillColor: const Color(0xFFF8F9FB), // Light background color
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: hasError ? const BorderSide(color: Colors.red, width: 1.5) : BorderSide.none, // Red border if error
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.black, width: 1), // Black border when focused
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Special field for the "About" section (multiline text area)
  Widget _buildAboutField() {
    // Check if this field should show an error (empty and validation enabled)
    bool hasError = _showErrors && _aboutController.text.trim().isEmpty;
    return Container(
      height: 150, // Fixed height for multiline input
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: hasError ? Colors.red : Colors.grey[300]!, width: hasError ? 1.5 : 1.0) // Red border if error
      ),
      child: TextField(
        controller: _aboutController, // Link the controller
        maxLines: 6, // Allow up to 6 lines of text
        decoration: const InputDecoration(
          hintText: "Describe your subject and what students will learn.",
          hintStyle: TextStyle(color: Colors.grey, fontSize: 13),
          border: InputBorder.none, // Remove default border (using container border instead)
        ),
      ),
    );
  }

  // Builds a dropdown field with label heading
  Widget _buildDropdown(String label, List<String> items, String? value, Function(String?) onChanged) {
    // Check if this dropdown should show an error (no selection and validation enabled)
    bool hasError = _showErrors && value == null;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FB),
              borderRadius: BorderRadius.circular(12),
              border: hasError ? Border.all(color: Colors.red, width: 1.5) : null, // Red border if error
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true, // Take full width of container
                hint: Text("Select $label", style: const TextStyle(color: Colors.black54, fontSize: 14)),
                value: value, // Currently selected value
                items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(), // Create menu items
                onChanged: onChanged, // Callback when selection changes
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Builds a smaller dropdown (used in rows with multiple dropdowns)
  Widget _buildSmallDropdown(String label, List<String> items, String value, Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(color: const Color(0xFFF8F9FB), borderRadius: BorderRadius.circular(12)),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: value, // Currently selected value
              items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 13)))).toList(),
              onChanged: onChanged, // Callback when selection changes
            ),
          ),
        ),
      ],
    );
  }

  // Builds a custom button with specified colors and text
  Widget _buildButton(String text, Color bg, Color textColor, VoidCallback onTap) {
    return SizedBox(
      height: 55,
      child: ElevatedButton(
        onPressed: onTap, // Callback when button is pressed
        style: ElevatedButton.styleFrom(
            backgroundColor: bg, // Background color
            elevation: 0, // No shadow
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)) // Rounded corners
        ),
        child: Text(text, style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
      ),
    );
  }

  // Validation method - checks if all required fields are filled
  void _validateAndSubmit() {
    setState(() {
      // Check if any required field is empty
      if (_aboutController.text.trim().isEmpty ||
          _subjectController.text.trim().isEmpty ||
          _locationController.text.trim().isEmpty ||
          _feeController.text.trim().isEmpty ||
          _selectedCategory == null ||
          _selectedMode == null) {
        _showErrors = true; // Enable error highlighting
        _showErrorPopup("Please fill in all mandatory fields to continue."); // Show error popup
      } else {
        _showErrors = false; // Clear errors
        _showSuccessPopup(); // Show success popup
      }
    });
  }

  // Shows an error dialog with custom message
  void _showErrorPopup(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        content: Text(message, textAlign: TextAlign.center),
        actions: [
          Center(
            child: TextButton(
              onPressed: () => Navigator.pop(context), // Close dialog
              child: const Text("OK", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  // Shows a success dialog with animation and auto-closes after 3 seconds
  void _showSuccessPopup() {
    showDialog(
      context: context,
      barrierDismissible: false, // User cannot dismiss by tapping outside
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("🎉", style: TextStyle(fontSize: 60)), // Celebration emoji
              const SizedBox(height: 20),
              const Text("Congratulations",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1A237E))),
              const SizedBox(height: 15),
              const Text(
                "Your subject ad has been added successfully. Students can now view and place bids on it.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 30),
              const CircularProgressIndicator(color: Colors.black, strokeWidth: 2), // Loading indicator
            ],
          ),
        ),
      ),
    );

    // Auto-close the dialog after 3 seconds and navigate back
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) { // Check if widget is still in tree
        Navigator.pop(context); // Close the success dialog
        Navigator.pop(context); // Go back to previous screen
      }
    });
  }
}