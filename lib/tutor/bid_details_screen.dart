import 'dart:async';
import 'package:flutter/material.dart';
import '../widgets/custom_tab_header.dart';

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

  void _showPopup(BuildContext context, Widget content) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
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
          const CustomTabHeader(title: Text("Bid Details", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _CourseHeaderCard(tutorName: tutorName),
                  const SizedBox(height: 25),
                  const Text("Student", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1A237E), fontSize: 16)),
                  const SizedBox(height: 12),
                  _StudentTile(name: widget.studentName),
                  const SizedBox(height: 30),
                  _PriceRow(label: "Your Offer:", price: "2000 PKR", color: Colors.red),
                  const SizedBox(height: 15),
                  _PriceRow(label: "Student Offer:", price: "1500 PKR", color: Colors.red),
                  const SizedBox(height: 40),

                  if (_selectedStatus != "Rejected") ...[
                    _ActionButton(
                        label: "Accept Offer",
                        color: Colors.black,
                        onTap: () => _showPopup(context, _SuccessPopup(studentName: widget.studentName))
                    ),
                    if (!widget.isRequest)
                      _ActionButton(
                          label: "Counter Offer",
                          color: const Color(0xFFE0E0E0),
                          textColor: Colors.black,
                          onTap: () => _showPopup(context, const _CounterPopup())
                      ),
                    _ActionButton(
                        label: "Reject Offer",
                        color: const Color(0xFFE0E0E0),
                        textColor: Colors.black,
                        onTap: () async {
                          final res = await showDialog<bool>(
                            context: context,
                            builder: (context) => Dialog(
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                              child: const Padding(padding: EdgeInsets.all(24), child: _RejectPopup()),
                            ),
                          );
                          if (res == true) setState(() => _selectedStatus = "Rejected");
                        }
                    ),
                  ] else ...[
                    _RejectedStatusBox(),
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

// --- Internal Helper UI Components ---

class _CourseHeaderCard extends StatelessWidget {
  final String tutorName;
  const _CourseHeaderCard({required this.tutorName});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Row(
        children: [
          Container(width: 85, height: 85, decoration: BoxDecoration(color: Colors.red[900], borderRadius: BorderRadius.circular(15))),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tutorName, style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 12)),
                const Text("Physics", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                const Text("2000 PKR Matric", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                const Row(children: [Icon(Icons.star, color: Colors.amber, size: 14), Text(" 4.2 | ONLINE", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold))]),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _StudentTile extends StatelessWidget {
  final String name;
  const _StudentTile({required this.name});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const CircleAvatar(radius: 25, backgroundColor: Colors.black),
        const SizedBox(width: 15),
        Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1A237E))),
      ],
    );
  }
}

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
        Text(label, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A237E))),
        Text(price, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }
}

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
          style: ElevatedButton.styleFrom(backgroundColor: color, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
          onPressed: onTap,
          child: Text(label, style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 16)),
        ),
      ),
    );
  }
}

class _RejectedStatusBox extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.red.shade200)),
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

// --- POPUPS (Consolidated in this file) ---

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
        const Text("Congratulations", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF1A237E))),
        Text("You're now connected with ${widget.studentName}.", textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey, fontSize: 13)),
        const SizedBox(height: 20),
        const CircularProgressIndicator(color: Colors.black, strokeWidth: 2),
      ],
    );
  }
}

class _CounterPopup extends StatelessWidget {
  const _CounterPopup();
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text("Student Offer", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const Text("1500 PKR", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 20)),
        const SizedBox(height: 20),
        TextField(textAlign: TextAlign.center, decoration: InputDecoration(hintText: "Enter Counter Offer", border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)))),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(child: TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel"))),
            Expanded(child: ElevatedButton(onPressed: () => Navigator.pop(context), style: ElevatedButton.styleFrom(backgroundColor: Colors.black, shape: const StadiumBorder()), child: const Text("Send", style: TextStyle(color: Colors.white)))),
          ],
        )
      ],
    );
  }
}

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
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("CANCEL", style: TextStyle(color: Colors.black))),
            TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("REJECT", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold))),
          ],
        )
      ],
    );
  }
}