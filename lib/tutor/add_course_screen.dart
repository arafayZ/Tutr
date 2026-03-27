import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/custom_tab_header.dart';

class AddCourseScreen extends StatefulWidget {
  const AddCourseScreen({super.key});

  @override
  State<AddCourseScreen> createState() => _AddCourseScreenState();
}

class _AddCourseScreenState extends State<AddCourseScreen> {
  bool isPending = false;

  final TextEditingController _aboutController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _feeController = TextEditingController();
  final TextEditingController _classesController = TextEditingController();

  static const List<String> _dayList = [
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday",
    "Sunday"
  ];

  String? _selectedCategory;
  String? _selectedMode;

  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 10, minute: 0);

  String _startDay = "Monday";
  String _endDay = "Friday";

  bool _showErrors = false;

  @override
  void initState() {
    super.initState();
    _classesController.text = "12";
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
    // Ensure the result is explicitly treated as TimeOfDay?
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _startTime : _endTime,
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.black, // Hand, selected circle, and AM/PM toggle
              onPrimary: Colors.white, // Text inside the selection
              surface: Colors.white, // Background of the picker
              onSurface: Colors.black, // Default numbers/text
            ),
            // Specifically targets the AM/PM toggle box style
            timePickerTheme: TimePickerThemeData(
              dayPeriodColor: WidgetStateColor.resolveWith((states) =>
              states.contains(WidgetState.selected)
                  ? Colors.black.withValues(alpha: 0.2) // Highlighted box bg
                  : Colors.transparent),
              dayPeriodTextColor: WidgetStateColor.resolveWith((states) =>
              states.contains(WidgetState.selected)
                  ? Colors.black // Selected AM/PM text color
                  : Colors.black),
              dayPeriodBorderSide: const BorderSide(color: Colors.black),
            ),
          ),
          child: child!,
        );
      },
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
            const CustomTabHeader(
              title: Text("Add Course",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ),
            Expanded(
              child: isPending ? _buildPendingView() : _buildFormView(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("About", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          _buildAboutField(),
          const SizedBox(height: 25),
          const Text("What You Provide",
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          _buildField("Subject", _subjectController, "e.g. Maths"),
          _buildDropdown(
              "Category",
              const ["Metric", "Intermediate", "O Level", "A Level"],
              _selectedCategory,
                  (v) => setState(() => _selectedCategory = v)),
          _buildDropdown(
              "Teaching Mode",
              const ["Online", "Student Home", "Tutor Home"],
              _selectedMode,
                  (v) => setState(() => _selectedMode = v)),
          _buildField("Area, City", _locationController, "e.g. Nazimabad, Karachi"),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                  child: _buildTimeSelector(
                      "Start Time", _startTime, () => _pickTime(true))),
              const SizedBox(width: 15),
              Expanded(
                  child: _buildTimeSelector(
                      "End Time", _endTime, () => _pickTime(false))),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                  child: _buildSmallDropdown("Days", _dayList, _startDay,
                          (v) => setState(() => _startDay = v!))),
              const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                  child: Text("To")),
              Expanded(
                  child: _buildSmallDropdown("Days", _dayList, _endDay,
                          (v) => setState(() => _endDay = v!))),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildField("Classes (Month)", _classesController,
                    "Max 25",
                    isNumeric: true, maxValue: 25),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: _buildField("Tuition Fee (PKR)", _feeController,
                    "Max 50,000",
                    isNumeric: true, maxValue: 50000),
              ),
            ],
          ),
          const SizedBox(height: 40),
          Row(
            children: [
              Expanded(
                  child: _buildButton("Cancel", const Color(0xFFEEEEEE),
                      Colors.black, () => Navigator.pop(context))),
              const SizedBox(width: 15),
              Expanded(
                  child: _buildButton(
                      "Add", Colors.black, Colors.white, _validateAndSubmit)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSelector(String label, TimeOfDay time, VoidCallback onTap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(12)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(time.format(context), style: const TextStyle(fontSize: 12)),
                const Icon(Icons.access_time, size: 16, color: Colors.grey),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildField(String label, TextEditingController controller, String hint,
      {bool isNumeric = false, int? maxValue}) {
    int? val = int.tryParse(controller.text);
    bool hasError = _showErrors &&
        (controller.text.trim().isEmpty ||
            (isNumeric && val == null) ||
            (maxValue != null && val != null && val > maxValue));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
          inputFormatters:
          isNumeric ? [FilteringTextInputFormatter.digitsOnly] : [],
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFFBDBDBD), fontSize: 14),
            filled: true,
            fillColor: Colors.white,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                  color: hasError ? Colors.red : Colors.transparent),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.black),
            ),
          ),
        ),
        const SizedBox(height: 15),
      ],
    );
  }

  Widget _buildAboutField() {
    bool hasError = _showErrors && _aboutController.text.trim().isEmpty;
    int wordCount = _aboutController.text.trim().isEmpty
        ? 0
        : _aboutController.text.trim().split(RegExp(r'\s+')).length;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
                color: hasError ? Colors.red : const Color(0xFFEEEEEE)),
          ),
          child: TextField(
            controller: _aboutController,
            maxLines: 4,
            onChanged: (v) => setState(() {}),
            decoration: const InputDecoration(
              hintText: "Describe your course...",
              hintStyle: TextStyle(color: Color(0xFFBDBDBD), fontSize: 14),
              border: InputBorder.none,
            ),
          ),
        ),
        const SizedBox(height: 5),
        Align(
          alignment: Alignment.centerRight,
          child: Text("$wordCount/100 words",
              style: const TextStyle(color: Colors.grey, fontSize: 11)),
        ),
      ],
    );
  }

  Widget _buildDropdown(String label, List<String> items, String? value,
      Function(String?) onChanged) {
    bool hasError = _showErrors && value == null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: hasError ? Colors.red : Colors.transparent),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              hint: const Text("Select",
                  style: TextStyle(color: Color(0xFFBDBDBD), fontSize: 14)),
              value: value,
              items: items
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ),
        const SizedBox(height: 15),
      ],
    );
  }

  Widget _buildSmallDropdown(String label, List<String> items, String value,
      Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(12)),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: value,
              items: items
                  .map((e) => DropdownMenuItem(
                  value: e, child: Text(e, style: const TextStyle(fontSize: 12))))
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildButton(
      String text, Color bg, Color textColor, VoidCallback onTap) {
    return SizedBox(
      height: 55,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          elevation: 0,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
        child: Text(text,
            style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
      ),
    );
  }

  void _validateAndSubmit() {
    setState(() {
      int? fee = int.tryParse(_feeController.text);
      int? classes = int.tryParse(_classesController.text);
      int wordCount = _aboutController.text.trim().isEmpty
          ? 0
          : _aboutController.text.trim().split(RegExp(r'\s+')).length;

      // Convert time to double for comparison
      double startDouble = _startTime.hour + _startTime.minute / 60.0;
      double endDouble = _endTime.hour + _endTime.minute / 60.0;

      // 1. Check for Range/Limit Errors (Classes and Fee)
      if ((classes != null && classes > 25) || (fee != null && fee > 50000)) {
        String errorTitle = (classes ?? 0) > 25 ? "Invalid Class Count" : "Invalid Fee";
        String errorMsg = (classes ?? 0) > 25
            ? "You cannot add more than 25 classes per month."
            : "The tuition fee cannot exceed 50,000 PKR.";
        _showErrorPopup(errorTitle, errorMsg);
        _showErrors = true;
        return;
      }

      // 2. Check for Time Logic Errors (End time must be after Start time)
      if (endDouble <= startDouble) {
        _showErrorPopup(
            "Invalid Time",
            "The end time must be strictly after the start time."
        );
        _showErrors = true;
        return;
      }

      // 3. Check for Word Count Errors
      if (wordCount > 100) {
        _showErrorPopup(
            "Text Too Long",
            "The 'About' section cannot exceed 100 words."
        );
        _showErrors = true;
        return;
      }

      // 4. Standard empty field validation
      if (_aboutController.text.isEmpty ||
          _subjectController.text.isEmpty ||
          _selectedCategory == null ||
          _selectedMode == null || // Added mode check
          fee == null ||
          classes == null) {
        _showErrors = true;
        // Optionally show a popup for missing fields too
        _showErrorPopup("Missing Info", "Please fill in all the required fields.");
      } else {
        _showErrors = false;
        _showSuccessPopup();
      }
    });
  }

  void _showErrorPopup(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("⚠️", style: TextStyle(fontSize: 50)),
              const SizedBox(height: 15),
              Text(title,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Text(message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 25),
              _buildButton("Try Again", Colors.black, Colors.white,
                      () => Navigator.pop(context)),
            ],
          ),
        ),
      ),
    );
  }

  void _showSuccessPopup() {
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
              Text("🎉", style: TextStyle(fontSize: 50)),
              SizedBox(height: 15),
              Text("Congratulations",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              Text("Course added successfully!",
                  textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
              SizedBox(height: 20),
              CircularProgressIndicator(color: Colors.black),
            ],
          ),
        ),
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pop(context);
        Navigator.pop(context);
      }
    });
  }

  Widget _buildPendingView() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)
                ],
              ),
              child: Icon(Icons.hourglass_empty_rounded,
                  size: 100, color: Colors.grey[300]),
            ),
            const SizedBox(height: 30),
            const Text("Under Review",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            const Text(
              "Your account is currently under review by the admin.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 16, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}