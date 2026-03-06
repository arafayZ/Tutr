import 'package:flutter/material.dart';
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

  static const List<String> _timeList = [
    "09:00","10:00","11:00","12:00","13:00","14:00"
  ];

  static const List<String> _dayList = [
    "Monday","Tuesday","Wednesday","Thursday","Friday","Saturday","Sunday"
  ];

  static const List<String> _classList = [
    "04","08","12","16","20"
  ];

  String? _selectedCategory;
  String? _selectedMode;

  String _startTime = "09:00";
  String _endTime = "10:00";

  String _startDay = "Monday";
  String _endDay = "Friday";

  String _classesPerMonth = "12";

  bool _showErrors = false;

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
      // Wrapping with SafeArea ensures system nav bars don't cover content
      body: SafeArea(
        bottom: true, // This is the key fix
        child: Column(
          children: [
            const CustomTabHeader(
              title: Text(
                "Add Course",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: isPending ? _buildPendingView() : _buildFormView(),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- FORM VIEW ----------------

  Widget _buildFormView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24,20,24,40),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          const Text(
            "About",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),

          const SizedBox(height:10),

          _buildAboutField(),

          const Align(
            alignment: Alignment.centerRight,
            child: Text(
              "(Word limit: 100)",
              style: TextStyle(color: Colors.grey,fontSize:11),
            ),
          ),

          const SizedBox(height:25),

          const Text(
            "What You Provide",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),

          const SizedBox(height:15),

          _buildField("Subject", _subjectController, "e.g. Maths"),

          _buildDropdown(
            "Category",
            const ["Metric","Intermediate","O/A Levels"],
            _selectedCategory,
                (v)=>setState(()=>_selectedCategory=v),
          ),

          _buildDropdown(
            "Teaching Mode",
            const ["Online","Student Home","Tutor Home"],
            _selectedMode,
                (v)=>setState(()=>_selectedMode=v),
          ),

          _buildField(
            "Area, City",
            _locationController,
            "e.g. Gulistan-e-Jauhar",
          ),

          const SizedBox(height:10),

          Row(
            children: [
              Expanded(
                child: _buildSmallDropdown(
                  "Start Time",
                  _timeList,
                  _startTime,
                      (v)=>setState(()=>_startTime=v!),
                ),
              ),

              const SizedBox(width:15),

              Expanded(
                child: _buildSmallDropdown(
                  "End Time",
                  _timeList,
                  _endTime,
                      (v)=>setState(()=>_endTime=v!),
                ),
              ),
            ],
          ),

          const SizedBox(height:20),

          Row(
            children: [

              Expanded(
                child: _buildSmallDropdown(
                  "Days",
                  _dayList,
                  _startDay,
                      (v)=>setState(()=>_startDay=v!),
                ),
              ),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal:10,vertical:20),
                child: Text("To"),
              ),

              Expanded(
                child: _buildSmallDropdown(
                  "Days",
                  _dayList,
                  _endDay,
                      (v)=>setState(()=>_endDay=v!),
                ),
              ),
            ],
          ),

          const SizedBox(height:20),

          Row(
            children: [

              Expanded(
                child: _buildSmallDropdown(
                  "Classes (Month)",
                  _classList,
                  _classesPerMonth,
                      (v)=>setState(()=>_classesPerMonth=v!),
                ),
              ),

              const SizedBox(width:15),

              Expanded(
                child: _buildField(
                  "Tuition Fee (PKR)",
                  _feeController,
                  "0000",
                ),
              ),
            ],
          ),

          const SizedBox(height:40),

          Row(
            children: [

              Expanded(
                child: _buildButton(
                  "Cancel",
                  const Color(0xFFEEEEEE),
                  Colors.black,
                      ()=>Navigator.pop(context),
                ),
              ),

              const SizedBox(width:15),

              Expanded(
                child: _buildButton(
                  "Add",
                  Colors.black,
                  Colors.white,
                  _validateAndSubmit,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------- FORM INPUT FIELD ----------------

  Widget _buildField(String label, TextEditingController controller, String hint) {

    bool hasError = _showErrors && controller.text.trim().isEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Text(
          label,
          style: const TextStyle(
            fontSize:12,
            color:Colors.grey,
            fontWeight:FontWeight.bold,
          ),
        ),

        const SizedBox(height:6),

        TextField(
          controller: controller,

          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.white,

            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: hasError ? Colors.red : Colors.transparent,
              ),
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
        border: Border.all(
          color: hasError ? Colors.red : const Color(0xFFEEEEEE),
        ),
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

  Widget _buildDropdown(
      String label,
      List<String> items,
      String? value,
      Function(String?) onChanged,
      ) {

    bool hasError = _showErrors && value == null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Text(
          label,
          style: const TextStyle(
            fontSize:12,
            color:Colors.grey,
            fontWeight:FontWeight.bold,
          ),
        ),

        const SizedBox(height:6),

        Container(
          padding: const EdgeInsets.symmetric(horizontal:16),

          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: hasError ? Colors.red : Colors.transparent,
            ),
          ),

          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              hint: Text("Select $label"),
              value: value,
              items: items
                  .map((e)=>DropdownMenuItem(
                value: e,
                child: Text(e),
              ))
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ),

        const SizedBox(height:15),
      ],
    );
  }

  // ---------------- SMALL DROPDOWN ----------------

  Widget _buildSmallDropdown(
      String label,
      List<String> items,
      String value,
      Function(String?) onChanged,
      ) {

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Text(
          label,
          style: const TextStyle(
            fontSize:11,
            color:Colors.grey,
            fontWeight:FontWeight.bold,
          ),
        ),

        const SizedBox(height:5),

        Container(
          padding: const EdgeInsets.symmetric(horizontal:12),

          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),

          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: value,
              items: items
                  .map((e)=>DropdownMenuItem(
                value: e,
                child: Text(
                  e,
                  style: const TextStyle(fontSize:12),
                ),
              ))
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  // ---------------- BUTTON ----------------

  Widget _buildButton(
      String text,
      Color bg,
      Color textColor,
      VoidCallback onTap,
      ) {

    return SizedBox(
      height:55,

      child: ElevatedButton(
        onPressed: onTap,

        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),

        child: Text(
          text,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // ---------------- VALIDATION ----------------

  void _validateAndSubmit() {

    setState(() {

      if (_aboutController.text.isEmpty ||
          _subjectController.text.isEmpty ||
          _selectedCategory == null) {

        _showErrors = true;

      } else {

        _showErrors = false;
        _showSuccessPopup();
      }
    });
  }

  // ---------------- SUCCESS POPUP ----------------

  void _showSuccessPopup() {

    showDialog(
      context: context,
      barrierDismissible: false,

      builder: (context) => Dialog(
        backgroundColor: Colors.white,

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),

        child: const Padding(
          padding: EdgeInsets.all(30),

          child: Column(
            mainAxisSize: MainAxisSize.min,

            children: [

              Text("🎉",style:TextStyle(fontSize:50)),

              SizedBox(height:15),

              Text(
                "Congratulations",
                style: TextStyle(
                  fontSize:20,
                  fontWeight:FontWeight.bold,
                ),
              ),

              SizedBox(height:10),

              Text(
                "Course added successfully!",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),

              SizedBox(height:20),

              CircularProgressIndicator(color: Colors.black),
            ],
          ),
        ),
      ),
    );

    Future.delayed(const Duration(seconds:2),(){

      if(mounted){
        Navigator.pop(context);
        Navigator.pop(context);
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

            Container(
              padding: const EdgeInsets.all(30),

              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha:0.05),
                    blurRadius:10,
                  )
                ],
              ),

              child: Icon(
                Icons.hourglass_empty_rounded,
                size:100,
                color: Colors.grey[300],
              ),
            ),

            const SizedBox(height:30),

            const Text(
              "Under Review",
              style: TextStyle(
                fontSize:22,
                fontWeight:FontWeight.bold,
              ),
            ),

            const SizedBox(height:12),

            const Text(
              "Your account is currently under review by the admin. You will be able to add courses once your profile is approved.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
                fontSize:16,
                height:1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}