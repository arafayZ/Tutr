// Import Flutter material design components
import 'package:flutter/material.dart';

// Import custom tab header widget for consistent screen headers
import '../widgets/custom_tab_header.dart';

// --- 1. MAIN SCREEN CLASS ---
class AddCourseScreen extends StatefulWidget {
  const AddCourseScreen({super.key});

  @override
  State<AddCourseScreen> createState() => _AddCourseScreenState();
}

// --- 2. STATE CLASS ---
class _AddCourseScreenState extends State<AddCourseScreen> {

  // Flag to determine whether the course form is pending submission
  bool isPending = false;

  // Text controllers for form input fields
  final TextEditingController _aboutController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _feeController = TextEditingController();

  // Predefined lists for dropdowns
  static const List<String> _timeList = ["09:00","10:00","11:00","12:00","13:00","14:00"];
  static const List<String> _dayList = ["Monday","Tuesday","Wednesday","Thursday","Friday","Saturday","Sunday"];
  static const List<String> _classList = ["04","08","12","16","20"];

  // Selected values for dropdowns
  String? _selectedCategory;
  String? _selectedMode;

  // Default start and end times
  String _startTime = "09:00";
  String _endTime = "10:00";

  // Default start and end days
  String _startDay = "Monday";
  String _endDay = "Friday";

  // Default classes per month
  String _classesPerMonth = "12";

  // Flag to show validation errors
  bool _showErrors = false;

  // Dispose controllers when the widget is removed from tree
  @override
  void dispose() {
    _aboutController.dispose();
    _subjectController.dispose();
    _locationController.dispose();
    _feeController.dispose();
    super.dispose();
  }

  // --- 3. BUILD METHOD ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB), // Page background

      // SafeArea ensures UI doesn't overlap system bars
      body: SafeArea(
        bottom: true, // Include bottom safe area
        child: Column(
          children: [
            // Custom tab header
            const CustomTabHeader(
              title: Text(
                "Add Course",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            // Expandable area: either show pending view or form
            Expanded(
              child: isPending ? _buildPendingView() : _buildFormView(),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- FORM VIEW ----------------
  // Method to build the form for adding course
  Widget _buildFormView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24,20,24,40), // Outer padding

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // Section title: About
          const Text("About", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height:10),

          // About field
          _buildAboutField(),

          // Word limit notice
          const Align(
            alignment: Alignment.centerRight,
            child: Text("(Word limit: 100)", style: TextStyle(color: Colors.grey,fontSize:11)),
          ),

          const SizedBox(height:25),

          // Section title: What You Provide
          const Text("What You Provide", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height:15),

          // Subject input field
          _buildField("Subject", _subjectController, "e.g. Maths"),

          // Dropdown for category
          _buildDropdown(
            "Category",
            const ["Metric","Intermediate","O/A Levels"],
            _selectedCategory,
                (v)=>setState(()=>_selectedCategory=v),
          ),

          // Dropdown for teaching mode
          _buildDropdown(
            "Teaching Mode",
            const ["Online","Student Home","Tutor Home"],
            _selectedMode,
                (v)=>setState(()=>_selectedMode=v),
          ),

          // Location input field
          _buildField("Area, City", _locationController, "e.g. Gulistan-e-Jauhar"),

          const SizedBox(height:10),

          // Row: Start Time and End Time dropdowns
          Row(
            children: [
              Expanded(
                child: _buildSmallDropdown("Start Time", _timeList, _startTime, (v)=>setState(()=>_startTime=v!)),
              ),
              const SizedBox(width:15),
              Expanded(
                child: _buildSmallDropdown("End Time", _timeList, _endTime, (v)=>setState(()=>_endTime=v!)),
              ),
            ],
          ),

          const SizedBox(height:20),

          // Row: Start Day and End Day dropdowns
          Row(
            children: [
              Expanded(
                child: _buildSmallDropdown("Days", _dayList, _startDay, (v)=>setState(()=>_startDay=v!)),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal:10,vertical:20),
                child: Text("To"),
              ),
              Expanded(
                child: _buildSmallDropdown("Days", _dayList, _endDay, (v)=>setState(()=>_endDay=v!)),
              ),
            ],
          ),

          const SizedBox(height:20),

          // Row: Classes per month and Tuition Fee
          Row(
            children: [
              Expanded(
                child: _buildSmallDropdown("Classes (Month)", _classList, _classesPerMonth, (v)=>setState(()=>_classesPerMonth=v!)),
              ),
              const SizedBox(width:15),
              Expanded(
                child: _buildField("Tuition Fee (PKR)", _feeController, "0000"),
              ),
            ],
          ),

          const SizedBox(height:40),

          // Row: Cancel and Add buttons
          Row(
            children: [
              Expanded(
                child: _buildButton("Cancel", const Color(0xFFEEEEEE), Colors.black, ()=>Navigator.pop(context)),
              ),
              const SizedBox(width:15),
              Expanded(
                child: _buildButton("Add", Colors.black, Colors.white, _validateAndSubmit),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------- GENERIC INPUT FIELD ----------------
  Widget _buildField(String label, TextEditingController controller, String hint) {
    bool hasError = _showErrors && controller.text.trim().isEmpty; // Show red border if error

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Field label
        Text(label, style: const TextStyle(fontSize:12,color:Colors.grey,fontWeight:FontWeight.bold)),
        const SizedBox(height:6),

        // Text input field
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.white,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: hasError ? Colors.red : Colors.transparent),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.black),
            ),
          ),
        ),
        const SizedBox(height:15),
      ],
    );
  }

  // ---------------- ABOUT FIELD ----------------
  Widget _buildAboutField() {
    bool hasError = _showErrors && _aboutController.text.trim().isEmpty;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: hasError ? Colors.red : const Color(0xFFEEEEEE)),
      ),
      child: TextField(
        controller: _aboutController,
        maxLines: 4,
        decoration: const InputDecoration(
          hintText: "Describe your course...",
          border: InputBorder.none,
        ),
      ),
    );
  }

  // ---------------- DROPDOWN ----------------
  Widget _buildDropdown(String label, List<String> items, String? value, Function(String?) onChanged) {
    bool hasError = _showErrors && value == null; // Show red border if no selection

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize:12,color:Colors.grey,fontWeight:FontWeight.bold)),
        const SizedBox(height:6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal:16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: hasError ? Colors.red : Colors.transparent),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              hint: Text("Select $label"),
              value: value,
              items: items.map((e)=>DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
        const SizedBox(height:15),
      ],
    );
  }

  // ---------------- SMALL DROPDOWN ----------------
  Widget _buildSmallDropdown(String label, List<String> items, String value, Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize:11,color:Colors.grey,fontWeight:FontWeight.bold)),
        const SizedBox(height:5),
        Container(
          padding: const EdgeInsets.symmetric(horizontal:12),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: value,
              items: items.map((e)=>DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize:12)))).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  // ---------------- BUTTON ----------------
  Widget _buildButton(String text, Color bg, Color textColor, VoidCallback onTap) {
    return SizedBox(
      height:55,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
        child: Text(text, style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
      ),
    );
  }

  // ---------------- VALIDATION ----------------
  void _validateAndSubmit() {
    setState(() {
      // Check required fields
      if (_aboutController.text.isEmpty || _subjectController.text.isEmpty || _selectedCategory == null) {
        _showErrors = true;
      } else {
        _showErrors = false;
        _showSuccessPopup(); // Show confirmation
      }
    });
  }

  // ---------------- SUCCESS POPUP ----------------
  void _showSuccessPopup() {
    showDialog(
      context: context,
      barrierDismissible: false, // User can't close manually
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        child: const Padding(
          padding: EdgeInsets.all(30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("🎉", style:TextStyle(fontSize:50)), // Celebration emoji
              SizedBox(height:15),
              Text("Congratulations", style: TextStyle(fontSize:20,fontWeight:FontWeight.bold)),
              SizedBox(height:10),
              Text("Course added successfully!", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
              SizedBox(height:20),
              CircularProgressIndicator(color: Colors.black),
            ],
          ),
        ),
      ),
    );

    // Auto-close popup and navigate back after 2 seconds
    Future.delayed(const Duration(seconds:2),(){
      if(mounted){
        Navigator.pop(context); // Close popup
        Navigator.pop(context); // Go back to previous screen
      }
    });
  }

  // ---------------- PENDING SCREEN ----------------
  Widget _buildPendingView(){
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal:40),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Circular container with hourglass icon
            Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha:0.05), blurRadius:10)
                ],
              ),
              child: Icon(Icons.hourglass_empty_rounded, size:100, color: Colors.grey[300]),
            ),
            const SizedBox(height:30),
            // Pending text
            const Text("Under Review", style: TextStyle(fontSize:22,fontWeight:FontWeight.bold)),
            const SizedBox(height:12),
            const Text(
              "Your account is currently under review by the admin. You will be able to add courses once your profile is approved.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize:16, height:1.5),
            ),
          ],
        ),
      ),
    );
  }
}