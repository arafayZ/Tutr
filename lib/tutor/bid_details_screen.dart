import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/custom_tab_header.dart';
import 'course_detail_screen.dart';
import 'student_profile_screen.dart';

class BidDetailsScreen extends StatefulWidget {
  final String studentName;
  final bool isRequest;

  const BidDetailsScreen({super.key, required this.studentName, required this.isRequest});

  @override
  State<BidDetailsScreen> createState() => _BidDetailsScreenState();
}

class _BidDetailsScreenState extends State<BidDetailsScreen> {
  String _selectedStatus = "";
  final String tutorName = "Asim Ali Khan";

  // Unified method to show standard white-background dialogs
  void _showPopup(BuildContext context, Widget content) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        child: Padding(padding: const EdgeInsets.all(24), child: content),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: Column(
        children: [
          const CustomTabHeader(
            title: Text("Details", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _CourseHeaderCard(tutorName: tutorName),
                  const SizedBox(height: 25),
                  const Text("Student",
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 16)),
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => StudentProfileScreen(
                            student: StudentDetails(
                              id: "STU-001",
                              name: widget.studentName,
                              profilePic: 'assets/images/user.png',
                              location: "Nazimabad, Karachi",
                              dob: "10 Oct 2004",
                              gender: "Male",
                              college: "Govt. Degree College",
                              school: "Happy Palace",
                              phone: "+92 300 1234567",
                              email: "student@example.com",
                            ),
                            onDisconnect: (String id) => debugPrint("Disconnected: $id"),
                          ),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(15),
                    child: _StudentTile(name: widget.studentName),
                  ),
                  if (!widget.isRequest) ...[
                    const SizedBox(height: 30),
                    const _PriceRow(label: "Your Offer:", price: "2000 PKR", color: Colors.red),
                    const SizedBox(height: 15),
                    const _PriceRow(label: "Student Offer:", price: "1500 PKR", color: Colors.red),
                  ],
                ],
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_selectedStatus != "Rejected") ...[
                    _ActionButton(
                        label: widget.isRequest ? "Accept" : "Accept Offer",
                        color: Colors.black,
                        onTap: () => _showPopup(context, _SuccessPopup(studentName: widget.studentName))),
                    if (!widget.isRequest)
                      _ActionButton(
                          label: "Counter Offer",
                          color: const Color(0xFFE0E0E0),
                          textColor: Colors.black,
                          onTap: () => _showPopup(context, const _CounterPopup())),
                    _ActionButton(
                        label: widget.isRequest ? "Reject" : "Reject Offer",
                        color: const Color(0xFFE0E0E0),
                        textColor: Colors.black,
                        onTap: () async {
                          final res = await showDialog<bool>(
                            context: context,
                            builder: (context) => Dialog(
                              backgroundColor: Colors.white,
                              surfaceTintColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                              child: const Padding(padding: EdgeInsets.all(24), child: _RejectPopup()),
                            ),
                          );
                          if (res == true) setState(() => _selectedStatus = "Rejected");
                        }),
                  ] else ...[
                    const _RejectedStatusBox(),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- COURSE CARD ---
class _CourseHeaderCard extends StatelessWidget {
  final String tutorName;
  const _CourseHeaderCard({required this.tutorName});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CourseDetailScreen(
              course: const {
                "title": "Physics",
                "price": "2000 PKR",
                "rating": "4.2",
                "level": "Matric",
                "students": 23,
                "color": Color(0xFF8C1414),
                "mode": "Online",
                "location": "Nazimabad, Karachi",
                "about": "Advanced Physics concepts for Matric students.",
                "status": "Available",
              },
              onAvailableTap: () {},
              onDelete: (deletedCourse) {},
              showAvailableBtn: false,
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
        ),
        child: Row(
          children: [
            Container(
              width: 85,
              height: 85,
              decoration: BoxDecoration(color: const Color(0xFF8C1414), borderRadius: BorderRadius.circular(15)),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(tutorName, style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 12)),
                  const Text("Physics", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const Text("2000 PKR Matric", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                  const Row(children: [
                    Icon(Icons.star, color: Colors.amber, size: 14),
                    Text(" 4.2 | ONLINE", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold))
                  ]),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

// --- STUDENT TILE ---
class _StudentTile extends StatelessWidget {
  final String name;
  const _StudentTile({required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 5)],
      ),
      child: Row(
        children: [
          const CircleAvatar(radius: 25, backgroundColor: Colors.black, child: Icon(Icons.person, color: Colors.white)),
          const SizedBox(width: 15),
          Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black)),
        ],
      ),
    );
  }
}

// --- PRICE ROW ---
class _PriceRow extends StatelessWidget {
  final String label;
  final String price;
  final Color color;
  const _PriceRow({required this.label, required this.price, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
        Text(price, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }
}

// --- ACTION BUTTON ---
class _ActionButton extends StatelessWidget {
  final String label;
  final Color color;
  final Color textColor;
  final VoidCallback onTap;
  const _ActionButton({required this.label, required this.color, this.textColor = Colors.white, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: SizedBox(
        width: double.infinity,
        height: 60,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
              backgroundColor: color, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
          onPressed: onTap,
          child: Text(label, style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 16)),
        ),
      ),
    );
  }
}

// --- COUNTER OFFER POPUP (Updated with logic and secondary popup) ---
class _CounterPopup extends StatefulWidget {
  const _CounterPopup();
  @override
  State<_CounterPopup> createState() => _CounterPopupState();
}

class _CounterPopupState extends State<_CounterPopup> {
  final TextEditingController _amountController = TextEditingController();
  String? _errorMessage;

  void _validateAndSubmit() {
    final String input = _amountController.text.trim();
    final int? amount = int.tryParse(input);

    setState(() {
      if (input.isEmpty) {
        _errorMessage = "Enter an amount";
      } else if (amount == null) {
        _errorMessage = "Enter numbers only";
      } else if (amount > 50000) {
        _errorMessage = "Maximum limit: 50,000 PKR";
      } else if (amount <= 0) {
        _errorMessage = "Enter a valid amount";
      } else {
        _errorMessage = null;
        Navigator.pop(context); // Close input popup

        // Show Success Popup for Counter Offer
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => Dialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
            child: const Padding(
              padding: EdgeInsets.all(24),
              child: _CounterSuccessView(),
            ),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text("Student Offer", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const Text("1500 PKR", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 20)),
        const SizedBox(height: 20),
        TextField(
            controller: _amountController,
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
                hintText: "Enter Counter Offer",
                errorText: _errorMessage,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20))),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(child: TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel"))),
            Expanded(
                child: ElevatedButton(
                    onPressed: _validateAndSubmit,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.black, shape: const StadiumBorder()),
                    child: const Text("Send", style: TextStyle(color: Colors.white)))),
          ],
        )
      ],
    );
  }
}

// --- COUNTER SUCCESS VIEW ---
class _CounterSuccessView extends StatefulWidget {
  const _CounterSuccessView();
  @override
  State<_CounterSuccessView> createState() => _CounterSuccessViewState();
}

class _CounterSuccessViewState extends State<_CounterSuccessView> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 2), () {
      if (mounted) Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.check_circle, color: Colors.green, size: 60),
        SizedBox(height: 15),
        Text("Offer Sent!", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        Text("Your counter offer has been sent to the student.",
            textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 13)),
        SizedBox(height: 20),
      ],
    );
  }
}

// --- REJECT POPUP ---
class _RejectPopup extends StatelessWidget {
  const _RejectPopup();
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text("Are you sure?", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        const SizedBox(height: 25),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("CANCEL")),
            TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text("REJECT", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold))),
          ],
        )
      ],
    );
  }
}

// --- SUCCESS POPUP (ACCEPTING) ---
class _SuccessPopup extends StatefulWidget {
  final String studentName;
  const _SuccessPopup({required this.studentName});
  @override
  State<_SuccessPopup> createState() => _SuccessPopupState();
}

class _SuccessPopupState extends State<_SuccessPopup> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pop(context);
        Navigator.pushReplacementNamed(context, '/connection', arguments: widget.studentName);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text("🎉", style: TextStyle(fontSize: 50)),
        const SizedBox(height: 15),
        const Text("Congratulations", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        Text("You're now connected with ${widget.studentName}.",
            textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey, fontSize: 13)),
        const SizedBox(height: 20),
        const CircularProgressIndicator(color: Colors.black, strokeWidth: 2),
      ],
    );
  }
}

// --- REJECTED STATUS BOX ---
class _RejectedStatusBox extends StatelessWidget {
  const _RejectedStatusBox();
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.red.shade200)),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.cancel_outlined, color: Colors.red),
          SizedBox(width: 10),
          Text("Offer Rejected", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}