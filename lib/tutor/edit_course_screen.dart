import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/custom_tab_header.dart';
import '../services/course_service.dart';
import '../utils/api_mapper.dart';

class EditCourseScreen extends StatefulWidget {
  final int courseId;
  const EditCourseScreen({super.key, required this.courseId});

  @override
  State<EditCourseScreen> createState() => _EditCourseScreenState();
}

class _EditCourseScreenState extends State<EditCourseScreen> {
  late TextEditingController _aboutController;
  late TextEditingController _subjectController;
  late TextEditingController _locationController;
  late TextEditingController _feeController;
  late TextEditingController _classesController;

  static const List<String> _dayList = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"];
  static const List<String> _categories = ["Matric", "Intermediate", "O Level", "A Level", "Entrance Test"];
  static const List<String> _modes = ["Online", "Student Home", "Tutor Home"];

  String? _selectedCategory;
  String? _selectedMode;
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 10, minute: 0);
  String _startDay = "Monday";
  String _endDay = "Friday";
  bool _showErrors = false;
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _aboutController = TextEditingController();
    _subjectController = TextEditingController();
    _locationController = TextEditingController();
    _feeController = TextEditingController();
    _classesController = TextEditingController();
    _loadCourseData();
  }

  Future<void> _loadCourseData() async {
    setState(() => _isLoading = true);

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int tutorProfileId = prefs.getInt('profileId') ?? 0;

      // Get all courses and find the one we need
      List<dynamic> courses = await CourseService.getTutorCourses(tutorProfileId);

      Map<String, dynamic>? courseData;
      for (var course in courses) {
        if (course['id'] == widget.courseId) {
          courseData = course;
          break;
        }
      }

      if (courseData == null) {
        throw Exception('Course not found');
      }

      _aboutController.text = courseData['about'] ?? '';
      _subjectController.text = courseData['subject'] ?? '';
      _locationController.text = courseData['location'] ?? '';

      // FIXED: Price without extra zero
      dynamic priceValue = courseData['price'];
      if (priceValue != null) {
        if (priceValue is int) {
          _feeController.text = priceValue.toString();
        } else if (priceValue is double) {
          if (priceValue == priceValue.toInt()) {
            _feeController.text = priceValue.toInt().toString();
          } else {
            _feeController.text = priceValue.toString();
          }
        } else {
          _feeController.text = priceValue.toString().replaceAll(RegExp(r'[^0-9]'), '');
        }
      } else {
        _feeController.text = '';
      }

      _classesController.text = courseData['classesPerMonth']?.toString() ?? '12';

      // Map backend values to display values
      _selectedCategory = _mapBackendCategoryToDisplay(courseData['category']);
      _selectedMode = _mapBackendModeToDisplay(courseData['teachingMode']);

      // Parse times
      if (courseData['startTime'] != null) {
        _startTime = _parseTimeOfDay(courseData['startTime']);
      }
      if (courseData['endTime'] != null) {
        _endTime = _parseTimeOfDay(courseData['endTime']);
      }

      // Normalize day values
      String rawStartDay = courseData['fromDay'] ?? "Monday";
      String rawEndDay = courseData['toDay'] ?? "Friday";

      _startDay = _normalizeDay(rawStartDay);
      _endDay = _normalizeDay(rawEndDay);

      setState(() => _isLoading = false);

    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorPopup("Error", e.toString().replaceFirst('Exception: ', ''));
    }
  }

  // Helper: Normalize day from uppercase to proper case
  String _normalizeDay(String day) {
    if (day.isEmpty) return "Monday";

    // Convert from "MONDAY" to "Monday"
    String lowerDay = day.toLowerCase();
    String capitalized = lowerDay[0].toUpperCase() + lowerDay.substring(1);

    // Ensure it's a valid day
    if (_dayList.contains(capitalized)) {
      return capitalized;
    }
    return "Monday";
  }

  String _mapBackendCategoryToDisplay(String? backendCategory) {
    if (backendCategory == null) return "";
    switch (backendCategory.toUpperCase()) {
      case "MATRIC": return "Matric";
      case "INTERMEDIATE": return "Intermediate";
      case "O_LEVEL": return "O Level";
      case "A_LEVEL": return "A Level";
      case "ENTRY_TEST": return "Entrance Test";
      default: return backendCategory;
    }
  }

  String _mapBackendModeToDisplay(String? backendMode) {
    if (backendMode == null) return "Online";
    switch (backendMode.toUpperCase()) {
      case "ONLINE": return "Online";
      case "STUDENT_HOME": return "Student Home";
      case "TUTOR_HOME": return "Tutor Home";
      default: return "Online";
    }
  }

  String _mapDisplayCategoryToBackend(String displayCategory) {
    switch (displayCategory) {
      case "Matric": return "MATRIC";
      case "Intermediate": return "INTERMEDIATE";
      case "O Level": return "O_LEVEL";
      case "A Level": return "A_LEVEL";
      case "Entrance Test": return "ENTRY_TEST";
      default: return displayCategory.toUpperCase();
    }
  }

  String _mapDisplayModeToBackend(String displayMode) {
    switch (displayMode) {
      case "Online": return "ONLINE";
      case "Student Home": return "STUDENT_HOME";
      case "Tutor Home": return "TUTOR_HOME";
      default: return displayMode.toUpperCase();
    }
  }

  // Safe time parser that handles all formats
  TimeOfDay _parseTimeOfDay(String timeStr) {
    if (timeStr.isEmpty) return const TimeOfDay(hour: 9, minute: 0);

    try {
      // Handle format like "2:00 PM" or "2:00PM"
      String cleanTime = timeStr.trim();
      bool isPM = cleanTime.toUpperCase().contains('PM');

      // Remove AM/PM
      cleanTime = cleanTime.toUpperCase().replaceAll('AM', '').replaceAll('PM', '').trim();

      List<String> parts = cleanTime.split(':');
      if (parts.isEmpty) return const TimeOfDay(hour: 9, minute: 0);

      int hour = int.tryParse(parts[0]) ?? 0;
      int minute = parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0;

      // Convert to 24-hour format
      if (isPM && hour != 12) {
        hour += 12;
      } else if (!isPM && hour == 12) {
        hour = 0;
      }

      return TimeOfDay(hour: hour, minute: minute);
    } catch (e) {
      return const TimeOfDay(hour: 9, minute: 0);
    }
  }

  String _formatTimeOfDay(TimeOfDay time) {
    int hour = time.hour;
    int minute = time.minute;
    String period = hour >= 12 ? "PM" : "AM";
    int hour12 = hour % 12;
    if (hour12 == 0) hour12 = 12;

    // Format: "2:00 PM" or "02:00 PM" - choose one based on your backend

    // Option 1: Without leading zero (2:00 PM)
    return "$hour12:${minute.toString().padLeft(2, '0')} $period";

    // Option 2: With leading zero (02:00 PM) - uncomment if backend needs leading zero
    // return "${hour12.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period";
  }

  @override
  void dispose() {
    _aboutController.dispose();
    _subjectController.dispose();
    _locationController.dispose();
    _feeController.dispose();
    _classesController.dispose();
    super.dispose();
  }

  Future<void> _pickTime(bool isStart) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _startTime : _endTime,
      builder: (context, child) => Theme(
          data: ThemeData.light().copyWith(colorScheme: const ColorScheme.light(primary: Colors.black)),
          child: child!),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: SafeArea(
        child: Column(
          children: [
            CustomTabHeader(title: Text("Edit Course", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("About", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    _buildAboutField(),
                    const SizedBox(height: 25),
                    const Text("Edit Teaching Details", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 15),
                    _buildField("Subject", _subjectController, "e.g. Maths"),
                    _buildDropdown("Category", _categories, _selectedCategory, (v) => setState(() => _selectedCategory = v)),
                    _buildDropdown("Teaching Mode", _modes, _selectedMode, (v) => setState(() => _selectedMode = v)),
                    _buildField("Area, City", _locationController, "e.g. Nazimabad, Karachi"),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(child: _buildTimeSelector("Start Time", _startTime, () => _pickTime(true))),
                        const SizedBox(width: 15),
                        Expanded(child: _buildTimeSelector("End Time", _endTime, () => _pickTime(false))),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(child: _buildSmallDropdown("From Day", _dayList, _startDay, (v) => setState(() => _startDay = v!))),
                        const Padding(padding: EdgeInsets.symmetric(horizontal: 10), child: Text("To")),
                        Expanded(child: _buildSmallDropdown("To Day", _dayList, _endDay, (v) => setState(() => _endDay = v!))),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(child: _buildField("Classes (Month)", _classesController, "Max 25", isNumeric: true, maxValue: 25)),
                        const SizedBox(width: 15),
                        Expanded(child: _buildField("Tuition Fee (PKR)", _feeController, "Max 50,000", isNumeric: true, maxValue: 50000)),
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

  Widget _buildField(String label, TextEditingController controller, String hint, {bool isNumeric = false, int? maxValue}) {
    int? val = int.tryParse(controller.text);
    bool hasError = _showErrors && (controller.text.trim().isEmpty || (isNumeric && val == null) || (maxValue != null && val != null && val > maxValue));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
          inputFormatters: isNumeric ? [FilteringTextInputFormatter.digitsOnly] : [],
          decoration: InputDecoration(
            hintText: hint,
            filled: true, fillColor: Colors.white,
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
    int wordCount = _aboutController.text.trim().isEmpty ? 0 : _aboutController.text.trim().split(RegExp(r'\s+')).length;
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: hasError ? Colors.red : const Color(0xFFEEEEEE))),
          child: TextField(controller: _aboutController, maxLines: 4, onChanged: (v) => setState(() {}), decoration: const InputDecoration(border: InputBorder.none, hintText: "Describe your course...")),
        ),
        const SizedBox(height: 5),
        Align(alignment: Alignment.centerRight, child: Text("$wordCount/100 words", style: const TextStyle(color: Colors.grey, fontSize: 11))),
      ],
    );
  }

  Widget _buildDropdown(String label, List<String> items, String? value, Function(String?) onChanged) {
    String? safeValue = items.contains(value) ? value : null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: safeValue,
              items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
        const SizedBox(height: 15),
      ],
    );
  }

  Widget _buildTimeSelector(String label, TimeOfDay time, VoidCallback onTap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_formatTimeOfDay(time), style: const TextStyle(fontSize: 12)),
                const Icon(Icons.access_time, size: 16, color: Colors.grey),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSmallDropdown(String label, List<String> items, String value, Function(String?) onChanged) {
    String safeValue = items.contains(value) ? value : items.first;
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
              value: safeValue,
              items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 12)))).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildButton(String text, Color bg, Color textColor, VoidCallback onTap) {
    return SizedBox(height: 55, child: ElevatedButton(onPressed: onTap, style: ElevatedButton.styleFrom(backgroundColor: bg, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))), child: Text(text, style: TextStyle(color: textColor, fontWeight: FontWeight.bold))));
  }

  Future<void> _validateAndSubmit() async {
    int? classes = int.tryParse(_classesController.text);
    int? fee = int.tryParse(_feeController.text);
    int wordCount = _aboutController.text.trim().isEmpty ? 0 : _aboutController.text.trim().split(RegExp(r'\s+')).length;

    double startDouble = _startTime.hour + _startTime.minute / 60.0;
    double endDouble = _endTime.hour + _endTime.minute / 60.0;

    if (classes != null && classes > 25) {
      _showErrorPopup("Invalid Class Count", "You cannot have more than 25 classes.");
      return;
    }

    if (fee != null && fee > 50000) {
      _showErrorPopup("Invalid Fee", "The tuition fee cannot exceed 50,000 PKR.");
      return;
    }

    if (endDouble <= startDouble) {
      _showErrorPopup("Invalid Time", "The end time must be strictly after the start time.");
      return;
    }

    if (wordCount > 100) {
      _showErrorPopup("Text Too Long", "About section cannot exceed 100 words.");
      return;
    }

    if (_aboutController.text.isEmpty || _subjectController.text.isEmpty || _selectedCategory == null || _feeController.text.isEmpty) {
      setState(() => _showErrors = true);
      _showErrorPopup("Missing Info", "Please fill in all required fields.");
    } else {
      await _updateCourse();
    }
  }

  Future<void> _updateCourse() async {
    setState(() => _isSaving = true);

    // Map display values to backend values
    String backendCategory = _mapDisplayCategoryToBackend(_selectedCategory!);
    String backendMode = _mapDisplayModeToBackend(_selectedMode!);

    // Parse price as integer
    int priceValue = int.tryParse(_feeController.text.trim()) ?? 0;

    // FIXED: Send time in 12-hour format for backend
    String startTime12 = _formatTimeOfDay(_startTime);  // Returns "2:00 PM"
    String endTime12 = _formatTimeOfDay(_endTime);      // Returns "4:00 PM"

    Map<String, dynamic> courseData = {
      'about': _aboutController.text.trim(),
      'subject': _subjectController.text.trim(),
      'category': backendCategory,
      'teachingMode': backendMode,
      'location': _locationController.text.trim(),
      'fromDay': _startDay.toUpperCase(),
      'toDay': _endDay.toUpperCase(),
      'startTime': startTime12,  // Now in 12-hour format like "2:00 PM"
      'endTime': endTime12,      // Now in 12-hour format like "4:00 PM"
      'classesPerMonth': int.parse(_classesController.text),
      'price': priceValue,
    };

    try {
      await CourseService.updateCourse(widget.courseId, courseData);
      setState(() => _isSaving = false);
      _showSuccessPopup();

    } catch (e) {
      setState(() => _isSaving = false);
      _showErrorPopup("Error", e.toString().replaceFirst('Exception: ', ''));
    }
  }

  void _showErrorPopup(String title, String message) {
    showDialog(context: context, builder: (context) => Dialog(
      backgroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      child: Padding(padding: const EdgeInsets.all(30), child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Text("⚠️", style: TextStyle(fontSize: 50)), const SizedBox(height: 15),
        Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)), const SizedBox(height: 10),
        Text(message, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey)), const SizedBox(height: 25),
        _buildButton("Try Again", Colors.black, Colors.white, () => Navigator.pop(context)),
      ])),
    ));
  }

  void _showSuccessPopup() {
    showDialog(context: context, barrierDismissible: false, builder: (context) => Dialog(
      backgroundColor: Colors.white, surfaceTintColor: Colors.transparent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      child: Padding(padding: const EdgeInsets.all(30), child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Text("🎉", style: TextStyle(fontSize: 50)), const SizedBox(height: 15),
        const Text("Changes Saved", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)), const SizedBox(height: 10),
        const Text("Course updated successfully!", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)), const SizedBox(height: 20),
        const CircularProgressIndicator(color: Colors.black),
      ])),
    ));

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pop(context);
        Navigator.pop(context, true);
      }
    });
  }
}