import 'package:flutter/material.dart';
// Ensure this import path matches your project structure for the custom widget
import '../widgets/custom_tab_header.dart';

class EditCourseScreen extends StatefulWidget {
  final Map<String, dynamic> course;

  const EditCourseScreen({super.key, required this.course});

  @override
  State<EditCourseScreen> createState() => _EditCourseScreenState();
}

class _EditCourseScreenState extends State<EditCourseScreen> {
  // Controllers
  late TextEditingController _aboutController;
  late TextEditingController _subjectController;
  late TextEditingController _locationController;
  late TextEditingController _feeController;

  // Predefined lists
  static const List<String> _timeList = ["09:00", "10:00", "11:00", "12:00", "13:00", "14:00", "18:00", "20:00"];
  static const List<String> _dayList = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"];
  static const List<String> _classList = ["04", "08", "12", "16", "20", "23", "45"];

  // Selected values
  String? _selectedCategory;
  String? _selectedMode;
  String _startTime = "18:00";
  String _endTime = "20:00";
  String _startDay = "Monday";
  String _endDay = "Friday";
  String _classesPerMonth = "20";

  bool _showErrors = false;

  @override
  void initState() {
    super.initState();
    _aboutController = TextEditingController(text: "Master ${widget.course['title']} with step-by-step guidance!");
    _subjectController = TextEditingController(text: widget.course['title']);
    _locationController = TextEditingController(text: "Nazimabad, Karachi");

    String priceOnly = widget.course['price'].toString().replaceAll(" PKR", "");
    _feeController = TextEditingController(text: priceOnly);

    _selectedCategory = widget.course['level'];
    _selectedMode = "Online";
    _classesPerMonth = widget.course['students'].toString();
  }

  @override
  void dispose() {
    _aboutController.dispose();
    _subjectController.dispose();
    _locationController.dispose();
    _feeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: SafeArea(
        child: Column(
          children: [
            // --- HEADER (Updated to match other screens) ---
            const CustomTabHeader(
              title: Text(
                "Edit Course",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("About", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    _buildAboutField(),
                    const SizedBox(height: 25),
                    const Text("What You Provide", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 15),
                    _buildField("Subject", _subjectController, "e.g. Maths"),
                    _buildDropdown("Category", const ["Matric", "Inter", "O/A Levels"], _selectedCategory, (v) => setState(() => _selectedCategory = v)),
                    _buildDropdown("Teaching Mode", const ["Online", "Student Home", "Tutor Home"], _selectedMode, (v) => setState(() => _selectedMode = v)),
                    _buildField("Area, City", _locationController, "e.g. Gulistan-e-Jauhar"),
                    Row(
                      children: [
                        Expanded(child: _buildSmallDropdown("Start Time", _timeList, _startTime, (v) => setState(() => _startTime = v!))),
                        const SizedBox(width: 15),
                        Expanded(child: _buildSmallDropdown("End Time", _timeList, _endTime, (v) => setState(() => _endTime = v!))),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(child: _buildSmallDropdown("Days", _dayList, _startDay, (v) => setState(() => _startDay = v!))),
                        const Padding(padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20), child: Text("To")),
                        Expanded(child: _buildSmallDropdown("Days", _dayList, _endDay, (v) => setState(() => _endDay = v!))),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(child: _buildSmallDropdown("Classes (Month)", _classList, _classesPerMonth, (v) => setState(() => _classesPerMonth = v!))),
                        const SizedBox(width: 15),
                        Expanded(child: _buildField("Tuition Fee (PKR)", _feeController, "0000")),
                      ],
                    ),
                    const SizedBox(height: 40),
                    Row(
                      children: [
                        Expanded(child: _buildButton("Cancel", const Color(0xFFEEEEEE), Colors.black, () => Navigator.pop(context))),
                        const SizedBox(width: 15),
                        Expanded(child: _buildButton("Save Changes", Colors.black, Colors.white, _validateAndSubmit)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- HELPER METHODS ---

  Widget _buildField(String label, TextEditingController controller, String hint) {
    bool hasError = _showErrors && controller.text.trim().isEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.white,
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: hasError ? Colors.red : Colors.transparent)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.black)),
          ),
        ),
        const SizedBox(height: 15),
      ],
    );
  }

  Widget _buildAboutField() {
    bool hasError = _showErrors && _aboutController.text.trim().isEmpty;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: hasError ? Colors.red : const Color(0xFFEEEEEE))),
      child: TextField(controller: _aboutController, maxLines: 4, decoration: const InputDecoration(hintText: "Describe your course...", border: InputBorder.none)),
    );
  }

  Widget _buildDropdown(String label, List<String> items, String? value, Function(String?) onChanged) {
    bool hasError = _showErrors && value == null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: hasError ? Colors.red : Colors.transparent)),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: items.contains(value) ? value : null,
              items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
        const SizedBox(height: 15),
      ],
    );
  }

  Widget _buildSmallDropdown(String label, List<String> items, String value, Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: items.contains(value) ? value : items.first,
              items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 12)))).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildButton(String text, Color bg, Color textColor, VoidCallback onTap) {
    return SizedBox(
      height: 55,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(backgroundColor: bg, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
        child: Text(text, style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
      ),
    );
  }

  void _validateAndSubmit() {
    if (_aboutController.text.isEmpty || _subjectController.text.isEmpty) {
      setState(() => _showErrors = true);
    } else {
      // Create a map of the updated data
      Map<String, dynamic> updatedCourse = {
        ...widget.course, // Keep original values like 'color' and 'rating'
        "title": _subjectController.text,
        "price": "${_feeController.text} PKR",
        "level": _selectedCategory,
        "students": int.tryParse(_classesPerMonth) ?? 0,
        "about": _aboutController.text,
      };

      _showSuccessPopup(updatedCourse);
    }
  }

// Update the popup to return the updatedCourse map
  void _showSuccessPopup(Map<String, dynamic> updatedData) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        child: const Padding(
          padding: EdgeInsets.all(30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("✅", style: TextStyle(fontSize: 50)),
              SizedBox(height: 15),
              Text("Updated!", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              Text("Course changes saved successfully.", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
              SizedBox(height: 20),
              CircularProgressIndicator(color: Colors.black),
            ],
          ),
        ),
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pop(context); // Close popup
        Navigator.pop(context, updatedData); // Return the NEW data map
      }
    });
  }
}