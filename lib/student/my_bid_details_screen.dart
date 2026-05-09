import 'package:flutter/material.dart';

class MyBidDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> bidData;

  const MyBidDetailsScreen({super.key, required this.bidData});

  @override
  State<MyBidDetailsScreen> createState() => _MyBidDetailsScreenState();
}

class _MyBidDetailsScreenState extends State<MyBidDetailsScreen> {
  // tracks if the offer has been rejected
  bool isRejected = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTutorCard(),
                    const SizedBox(height: 25),
                    const Text(
                      "Tutor",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildTutorProfileRow(),
                    const SizedBox(height: 25),
                    const Text(
                      "What You'll Get",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 15),
                    _buildFeatureItem(Icons.assignment, "20 Classes per month"),
                    _buildFeatureItem(Icons.access_time, "6:00 P.M - 8:00 P.M"),
                    _buildFeatureItem(Icons.calendar_month, "Monday to Friday"),
                    _buildFeatureItem(Icons.devices, "Online"),
                    _buildFeatureItem(Icons.location_on, "Nazimabad"),
                    const SizedBox(height: 30),
                    _buildOfferSection(),
                    const SizedBox(height: 30),
                    // Buttons are hidden once the offer is rejected
                    if (!isRejected) _buildActionButtons(context),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 50, bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            left: 20,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Colors.black,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
              ),
            ),
          ),
          const Text(
            "My Bids",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildTutorCard() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FB),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.red.shade900,
              borderRadius: BorderRadius.circular(15),
              image: const DecorationImage(
                image: NetworkImage('https://via.placeholder.com/80'),
                fit: BoxFit.cover,
                opacity: 0.5,
              ),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.bidData['name'] ?? "Asim Ali Khan",
                  style: const TextStyle(color: Colors.orange, fontSize: 12, fontWeight: FontWeight.bold),
                ),
                const Text(
                  "Physics",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const Text(
                  "2000 PKR / Metric",
                  style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                ),
                const Row(
                  children: [
                    Icon(Icons.star, color: Colors.orange, size: 14),
                    Text(" 4.2", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    SizedBox(width: 10),
                    VerticalDivider(width: 1, thickness: 1, color: Colors.black),
                    SizedBox(width: 10),
                    Text("ONLINE", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTutorProfileRow() {
    return Row(
      children: [
        const CircleAvatar(
          radius: 20,
          backgroundColor: Colors.black,
          backgroundImage: NetworkImage('https://via.placeholder.com/40'),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.bidData['name'] ?? "Asim Ali Khan",
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
            ),
            const Text("Tutor", style: TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        )
      ],
    );
  }

  Widget _buildFeatureItem(IconData icon, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade700),
          const SizedBox(width: 15),
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildOfferSection() {
    return Column(
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text("Your Offer: ", style: TextStyle(fontWeight: FontWeight.bold)),
            Text("1500 PKR", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        const SizedBox(height: 5),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const Text("Tutor Offer: ", style: TextStyle(fontWeight: FontWeight.bold)),
            // Text changes to "Rejected" based on status
            Text(
              isRejected ? "Rejected" : "1800 PKR",
              style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () => _showRejectPopup(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE5E7EB),
              foregroundColor: Colors.black,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
            child: const Text("Reject Offer", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: ElevatedButton(
            onPressed: () => _showSuccessPopup(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
            child: const Text("Connect", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  void _showSuccessPopup(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        // Automatic closure for success popup
        Future.delayed(const Duration(seconds: 3), () {
          if (Navigator.canPop(dialogContext)) {
            Navigator.pop(dialogContext);
          }
        });

        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("🎉", style: TextStyle(fontSize: 80)),
                const SizedBox(height: 25),
                const Text(
                  "Congratulations",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1C43),
                  ),
                ),
                const SizedBox(height: 15),
                const Text(
                  "You're now connected with your tutor. Get ready to start your lessons!",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 14, height: 1.5),
                ),
                const SizedBox(height: 30),
                const CircularProgressIndicator(
                  color: Color(0xFF1A1C43),
                  strokeWidth: 3,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showRejectPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text(
            "Are you sure?",
            style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1A1C43)),
          ),
          content: const Text(
            "Do you really want to reject this tutor's bid? This action cannot be undone.",
            style: TextStyle(color: Color(0xFF1A1C43), height: 1.5),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text(
                "CANCEL",
                style: TextStyle(color: Color(0xFF1A1C43), fontWeight: FontWeight.bold),
              ),
            ),
            TextButton(
              onPressed: () {
                // Update local UI state to "Rejected"
                setState(() => isRejected = true);
                Navigator.pop(dialogContext); // Only close the dialog
              },
              child: const Text(
                "REJECT",
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }
}