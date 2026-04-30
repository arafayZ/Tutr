import 'package:flutter/material.dart';

class CourseDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> courseData;

  const CourseDetailsScreen({super.key, required this.courseData});

  // 1. Success Popup Logic (Auto-closes after 5 seconds)
  void _showSuccessPopup(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        Future.delayed(const Duration(seconds: 5), () {
          if (Navigator.canPop(context)) Navigator.pop(context);
        });

        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 100,
                  width: 100,
                  decoration: const BoxDecoration(
                    color: Color(0xFF22AD19),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 60),
                ),
                const SizedBox(height: 30),
                Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1A1C43))),
                const SizedBox(height: 15),
                Text(message, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey, fontSize: 14, height: 1.5)),
              ],
            ),
          ),
        );
      },
    );
  }

  // 2. Send Offer Input Dialog
  void _showSendOfferDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(25.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Current Price", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(courseData['price'] ?? "2000 PKR", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue)),
                const SizedBox(height: 15),
                const Divider(thickness: 2),
                const SizedBox(height: 15),
                const Text("Enter your offer", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                TextField(
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: "1500",
                    hintStyle: const TextStyle(color: Colors.grey, fontSize: 20),
                    contentPadding: const EdgeInsets.symmetric(vertical: 15),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(35), borderSide: const BorderSide(color: Colors.grey)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(35), borderSide: const BorderSide(color: Colors.grey)),
                  ),
                ),
                const SizedBox(height: 30),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE5E7EB),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Cancel", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                        ),
                        onPressed: () {
                          Navigator.pop(context); // Close input dialog
                          _showSuccessPopup(context, "Offer Sent", "Your offer has been sent to the tutor. Waiting for their response.");
                        },
                        child: const Text("Send", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final double headerHeight = MediaQuery.of(context).size.height * 0.35;
    final double bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(height: headerHeight, width: double.infinity, color: courseData['color'] ?? const Color(0xFF8C1414)),
                Positioned(
                  top: 50, left: 20,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(padding: const EdgeInsets.all(8), decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle), child: const Icon(Icons.arrow_back, color: Colors.black, size: 24)),
                  ),
                ),
                Positioned(bottom: -120, left: 0, right: 0, child: _buildMainInfoCard()),
              ],
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 140)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTutorSection(),
                  const SizedBox(height: 30),
                  _buildFeaturesSection(),
                  const SizedBox(height: 30),
                  _buildReviewsHeader(),
                  const SizedBox(height: 15),
                  _buildReviewItem("Omar Farooq", "Amazing tutor!", "4 weeks ago"),
                  _buildReviewItem("Ayesha Noor", "Excellent teaching!", "1 hour ago"),
                  const SizedBox(height: 30),
                  _buildBottomActions(context),
                  SizedBox(height: bottomPadding > 0 ? bottomPadding + 10 : 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainInfoCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(25), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 15, offset: const Offset(0, 8))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text("Asim Ali Khan", style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 12)), Row(children: [Icon(Icons.star, color: Colors.orange, size: 16), Text(" 4.2", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))])]),
          const SizedBox(height: 8),
          Text(courseData['sub'] ?? "Course Title", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1A1C43))),
          const SizedBox(height: 12),
          Row(children: [const Icon(Icons.grid_view, size: 16, color: Colors.grey), const SizedBox(width: 5), Text(courseData['category'] ?? "General", style: const TextStyle(color: Colors.grey, fontSize: 13)), const Spacer(), Text(courseData['price'] ?? "0 PKR", style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 18))]),
          const SizedBox(height: 20),
          const Text("About", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          const Text("Master concepts with step-by-step guidance! Learn clearly and gain confidence for exams.", style: TextStyle(color: Colors.grey, fontSize: 13, height: 1.5)),
        ],
      ),
    );
  }

  Widget _buildTutorSection() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text("Tutor", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A1C43))),
      const SizedBox(height: 15),
      Row(children: [const CircleAvatar(radius: 25, backgroundColor: Colors.black, child: Icon(Icons.person, color: Colors.white)), const SizedBox(width: 15), Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [Text("Asim Ali Khan", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1A1C43))), Text("Senior Instructor", style: TextStyle(color: Colors.grey, fontSize: 12))])]),
    ]);
  }

  Widget _buildFeaturesSection() {
    final String location = courseData['location'] ?? "Online";
    final bool isOnline = location.toLowerCase().contains("online");
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text("What You'll Get", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A1C43))),
      const SizedBox(height: 15),
      _buildFeatureRow(Icons.class_rounded, "20 Classes per month"),
      _buildFeatureRow(Icons.access_time, "6:00 P.M - 8:00 P.M"),
      _buildFeatureRow(isOnline ? Icons.mobile_screen_share_rounded : Icons.home_work_outlined, isOnline ? "Online Class" : "Home/Tutor: $location"),
      _buildFeatureRow(Icons.calendar_month_rounded, "Monday to Friday"),
    ]);
  }

  Widget _buildFeatureRow(IconData icon, String text) {
    return Padding(padding: const EdgeInsets.only(bottom: 15), child: Row(children: [Icon(icon, size: 22, color: Colors.black54), const SizedBox(width: 15), Text(text, style: const TextStyle(fontSize: 14, color: Color(0xFF1A1C43)))]));
  }

  Widget _buildReviewsHeader() {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text("Reviews", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A1C43))), TextButton(onPressed: () {}, child: const Text("SEE ALL", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 12)))]);
  }

  Widget _buildReviewItem(String name, String comment, String timeAgo) {
    return Container(margin: const EdgeInsets.only(bottom: 20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [const CircleAvatar(radius: 20, backgroundColor: Colors.grey, child: Icon(Icons.person, color: Colors.white)), const SizedBox(width: 12), Expanded(child: Text(name, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1A1C43)))), const Icon(Icons.star, color: Colors.orange, size: 14), const Text(" 4.5", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))]), Padding(padding: const EdgeInsets.only(left: 52, top: 5), child: Text(comment, style: const TextStyle(color: Colors.black87, fontSize: 13))), Padding(padding: const EdgeInsets.only(left: 52, top: 4), child: Text(timeAgo, style: const TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.w500)))]));
  }

  Widget _buildBottomActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.black, padding: const EdgeInsets.symmetric(vertical: 18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
            onPressed: () => _showSuccessPopup(context, "Request Sent", "Your connection request has been sent to the tutor."),
            child: const Text("Connect Request", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE5E7EB), padding: const EdgeInsets.symmetric(vertical: 18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
            onPressed: () => _showSendOfferDialog(context),
            child: const Text("Send Offer", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }
}