import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/custom_tab_header.dart';

class EditCourseScreen extends StatefulWidget {
  final Map<String, dynamic> course;
  const EditCourseScreen({super.key, required this.course});

  @override
  State<EditCourseScreen> createState() => _EditCourseScreenState();
}

class _EditCourseScreenState extends State<EditCourseScreen> {
  late TextEditingController _aboutController, _subjectController, _locationController, _feeController, _classesController;

  static const List<String> _dayList = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"];
  static const List<String> _categories = ["Metric", "Intermediate", "O Level", "A Level", "Entrance Test"];

  String? _selectedCategory;
  String? _selectedMode;
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 10, minute: 0);
  String _startDay = "Monday", _endDay = "Friday";
  bool _showErrors = false;

  @override
  void initState() {
    super.initState();
    _aboutController = TextEditingController(text: widget.course['about'] ?? "Master ${widget.course['title']}!");
    _subjectController = TextEditingController(text: widget.course['title']);
    _locationController = TextEditingController(text: "Nazimabad, Karachi");

    // Extract numbers only from price string (e.g., "5000 PKR" -> "5000")
    String priceOnly = widget.course['price'].toString().replaceAll(RegExp(r'[^0-9]'), "");
    _feeController = TextEditingController(text: priceOnly);
    _classesController = TextEditingController(text: widget.course['students'].toString());

    _selectedCategory = _categories.contains(widget.course['level']) ? widget.course['level'] : null;
    _selectedMode = "Online";
  }

  @override
  void dispose() {
    _aboutController.dispose(); _subjectController.dispose(); _locationController.dispose();
    _feeController.dispose(); _classesController.dispose();
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
    if (picked != null) setState(() => isStart ? _startTime = picked : _endTime = picked);
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
              child: SingleChildScrollView(
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
                    _buildDropdown("Teaching Mode", const ["Online", "Student Home", "Tutor Home"], _selectedMode, (v) => setState(() => _selectedMode = v)),
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
                        Expanded(child: _buildSmallDropdown("Days", _dayList, _startDay, (v) => setState(() => _startDay = v!))),
                        const Padding(padding: EdgeInsets.symmetric(horizontal: 10), child: Text("To")),
                        Expanded(child: _buildSmallDropdown("Days", _dayList, _endDay, (v) => setState(() => _endDay = v!))),
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

  // --- Helper Methods ---

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
              isExpanded: true, value: safeValue,
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
              children: [Text(time.format(context), style: const TextStyle(fontSize: 12)), const Icon(Icons.access_time, size: 16, color: Colors.grey)],
            ),
          ),
        ),
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
              isExpanded: true, value: value,
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

  void _validateAndSubmit() {
    int? classes = int.tryParse(_classesController.text);
    int? fee = int.tryParse(_feeController.text);
    int wordCount = _aboutController.text.trim().isEmpty ? 0 : _aboutController.text.trim().split(RegExp(r'\s+')).length;

    if (classes != null && classes > 25) {
      _showErrorPopup("Invalid Class Count", "You cannot have more than 25 classes.");
      return;
    }

    if (fee != null && fee > 50000) {
      _showErrorPopup("Invalid Fee", "The tuition fee cannot exceed 50,000 PKR.");
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
      _showSuccessPopup();
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
        Navigator.pop(context, {
          "title": _subjectController.text, "price": "${_feeController.text} PKR",
          "level": _selectedCategory, "students": int.parse(_classesController.text), "about": _aboutController.text,
        });
      }
    });
  }
}