import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _dateController;
  late TextEditingController _locationController;
  late TextEditingController _phoneController;
  late TextEditingController _uniController;
  late TextEditingController _degreeController;

  DateTime? selectedDate;
  String? selectedGender;
  File? _imageFile;
  final List<String> _genders = ["Male", "Female", "Other"];

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(text: "Abdul");
    _lastNameController = TextEditingController(text: "Rafay");
    _dateController = TextEditingController(text: "19 January 2003");
    _locationController = TextEditingController(text: "Nazimabad, Karachi");
    _phoneController = TextEditingController(text: "345892658");
    _uniController = TextEditingController(text: "KIET");
    _degreeController = TextEditingController(text: "BSCS");

    selectedDate = DateTime(2003, 1, 19);
    selectedGender = "Male";
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _dateController.dispose();
    _locationController.dispose();
    _phoneController.dispose();
    _uniController.dispose();
    _degreeController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _imageFile = File(image.path);
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime(2003, 1, 19),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.black,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
        _dateController.text = "${picked.day} ${_getMonthName(picked.month)} ${picked.year}";
      });
    }
  }

  String _getMonthName(int month) {
    const months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    final double bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            _buildHeader(context),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 30),
                  Center(
                    child: Stack(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.black, width: 2),
                          ),
                          child: CircleAvatar(
                            radius: 55,
                            backgroundColor: Colors.grey[200],
                            backgroundImage: _imageFile != null
                                ? FileImage(_imageFile!)
                                : const AssetImage('assets/images/rafay.jpeg') as ImageProvider,
                          ),
                        ),
                        Positioned(
                          bottom: 5,
                          right: 5,
                          child: GestureDetector(
                            onTap: _pickImage,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle),
                              child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  const Text("Personal Details", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
                  const SizedBox(height: 15),
                  _customTextField(hint: "First Name", controller: _firstNameController),
                  _customTextField(hint: "Last Name", controller: _lastNameController),
                  GestureDetector(
                    onTap: () => _selectDate(context),
                    child: AbsorbPointer(
                      child: _customTextField(hint: "Date of Birth", controller: _dateController, icon: Icons.calendar_month_outlined),
                    ),
                  ),
                  _customTextField(hint: "Location", controller: _locationController, icon: Icons.location_on_outlined),
                  _genderDropdown(),
                  _phoneField(),
                  const SizedBox(height: 25),
                  const Text("Education", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
                  const SizedBox(height: 15),
                  _customTextField(hint: "University", controller: _uniController, icon: Icons.school_outlined),
                  _customTextField(hint: "Degree", controller: _degreeController, icon: Icons.book_outlined),
                  const SizedBox(height: 40),
                  GestureDetector(
                    onTap: () => _showUpdatePopup(context),
                    child: Container(
                      width: double.infinity,
                      height: 60,
                      decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(35)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Spacer(flex: 2),
                          const Text("Update", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                          const Spacer(),
                          Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: const CircleAvatar(
                              backgroundColor: Colors.white,
                              radius: 18,
                              child: Icon(Icons.arrow_forward, color: Colors.black, size: 20),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: bottomPadding > 0 ? bottomPadding : 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 50, 20, 25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(40), bottomRight: Radius.circular(40)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle),
              child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
            ),
          ),
          const Expanded(child: Center(child: Text("Edit Profile", style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold)))),
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _customTextField({required String hint, IconData? icon, required TextEditingController controller}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
          icon: icon != null ? Icon(icon, color: Colors.grey, size: 20) : null,
        ),
      ),
    );
  }

  Widget _genderDropdown() {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedGender,
          isExpanded: true,
          style: const TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w500),
          icon: const Icon(Icons.arrow_drop_down, color: Colors.black87),
          items: _genders.map((String value) => DropdownMenuItem(value: value, child: Text(value))).toList(),
          onChanged: (newValue) => setState(() => selectedGender = newValue),
        ),
      ),
    );
  }

  Widget _phoneField() {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Image.network('https://flagcdn.com/w20/pk.png', width: 25),
          const SizedBox(width: 10),
          const Text("( +92 ) ", style: TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w500)),
          Expanded(
            child: TextField(
              controller: _phoneController,
              keyboardType: TextInputType.number,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(10)],
              decoration: const InputDecoration(border: InputBorder.none),
            ),
          ),
        ],
      ),
    );
  }

  void _showUpdatePopup(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) {
            Navigator.of(context, rootNavigator: true).pop();
            Navigator.of(context).pop();
          }
        });

        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 20),
              const CircularProgressIndicator(color: Colors.black, strokeWidth: 3),
              const SizedBox(height: 25),
              const Text("Success!", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.black)),
              const SizedBox(height: 10),
              const Text(
                "Profile updated successfully.\nReturning in 3 seconds...",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}