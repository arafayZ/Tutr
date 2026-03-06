// import 'package:flutter/material.dart'; // Import Flutter UI library
// import '../widgets/custom_bottom_nav.dart'; // Import the bottom navigation bar
//
// // --- 1. THE CUSTOM HEADER YOU PROVIDED ---
// class CustomTabHeader extends StatelessWidget {
//   final VoidCallback? onBackTap; // Optional callback for the back button
//
//   const CustomTabHeader({super.key, this.onBackTap}); // Constructor
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: double.infinity, // Full width
//       height: 100, // Height for the tab
//       decoration: const BoxDecoration(
//         color: Colors.white, // White background
//         borderRadius: BorderRadius.only(
//           bottomLeft: Radius.circular(30), // Rounded bottom corners
//           bottomRight: Radius.circular(30),
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black12, // Subtle shadow
//             blurRadius: 10,
//             offset: Offset(0, 5), // Shadow below the tab
//           ),
//         ],
//       ),
//       child: SafeArea(
//         bottom: false, // Don't pad the bottom
//         child: Align(
//           alignment: Alignment.centerLeft, // Align content to the left
//           child: Padding(
//             padding: const EdgeInsets.only(left: 24.0), // Padding for the back button
//             child: GestureDetector(
//               onTap: onBackTap ?? () => Navigator.pop(context), // Go back on tap
//               child: const CircleAvatar(
//                 backgroundColor: Colors.black, // Black circle background
//                 radius: 22,
//                 child: Icon(Icons.arrow_back, color: Colors.white, size: 20), // White arrow icon
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// // --- 2. MAIN BIDS LIST SCREEN ---
// class MyBidsScreen extends StatelessWidget {
//   const MyBidsScreen({super.key}); // Constructor
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF8F9FB), // Light background color
//       extendBody: true, // Content flows behind the bottom nav bar
//       body: Column(
//         children: [
//           const CustomTabHeader(), // Using your custom header widget
//           Padding(
//             padding: const EdgeInsets.all(16.0), // Padding for search bar
//             child: TextField(
//               decoration: InputDecoration(
//                 hintText: "Search Here...", // Search placeholder
//                 prefixIcon: const Icon(Icons.search), // Search icon
//                 filled: true, // Fill the background
//                 fillColor: Colors.white, // White fill
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(15), // Rounded corners
//                   borderSide: BorderSide.none, // No border outline
//                 ),
//               ),
//             ),
//           ),
//           Expanded(
//             child: ListView.builder(
//               itemCount: 5, // Mocking 5 items
//               padding: const EdgeInsets.only(bottom: 100), // Space for bottom nav
//               itemBuilder: (context, index) => _BidListTile(
//                 name: "Bilal Raza", // Student name
//                 onTap: () => Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (context) => const BidDetailsScreen()), // Navigate to details
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {}, // Action for FAB
//         backgroundColor: Colors.black, // Black background
//         shape: const CircleBorder(), // Circular shape
//         child: const Icon(Icons.add, color: Colors.white, size: 30), // Plus icon
//       ),
//       floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked, // Center the FAB
//       bottomNavigationBar: const CustomBottomNav(), // Custom bottom bar
//     );
//   }
// }
//
// // --- 3. BID DETAILS SCREEN ---
// class BidDetailsScreen extends StatelessWidget {
//   const BidDetailsScreen({super.key}); // Constructor
//
//   void _showPopup(BuildContext context, Widget content) { // Helper for white popups
//     showDialog(
//       context: context,
//       builder: (context) => Dialog(
//         backgroundColor: Colors.white, // Force white background per your request
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)), // Rounded edges
//         child: Padding(padding: const EdgeInsets.all(24), child: content), // Padding inside popup
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF8F9FB), // Light background
//       extendBody: true, // Content flows behind nav
//       body: Column(
//         children: [
//           const CustomTabHeader(), // Reusing your header widget
//           Expanded(
//             child: SingleChildScrollView(
//               padding: const EdgeInsets.all(20), // Outer padding
//               child: Column(
//                 children: [
//                   const _BidInfoCard(), // Course info card
//                   const SizedBox(height: 40), // Spacing
//                   _StatusButton(
//                     label: "Accept Offer", // Accept button
//                     color: Colors.black,
//                     onTap: () => _showPopup(context, const _SuccessPopup()), // Show success popup
//                   ),
//                   _StatusButton(
//                     label: "Counter Offer", // Counter offer button
//                     color: const Color(0xFFE0E0E0),
//                     textColor: Colors.black,
//                     onTap: () => _showPopup(context, const _CounterPopup()), // Show counter popup
//                   ),
//                   _StatusButton(
//                     label: "Reject Offer", // Reject button
//                     color: const Color(0xFFE0E0E0),
//                     textColor: Colors.black,
//                     onTap: () => _showPopup(context, const _RejectPopup()), // Show reject popup
//                   ),
//                   const SizedBox(height: 100), // Spacing for navigation
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {}, // FAB Action
//         backgroundColor: Colors.black,
//         shape: const CircleBorder(),
//         child: const Icon(Icons.add, color: Colors.white, size: 30),
//       ),
//       floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
//       bottomNavigationBar: const CustomBottomNav(),
//     );
//   }
// }
//
// // --- 4. POPUP CONTENT & COMPONENTS ---
//
// class _SuccessPopup extends StatelessWidget {
//   const _SuccessPopup();
//   @override
//   Widget build(BuildContext context) {
//     return const Column( // Using const for efficiency
//       mainAxisSize: MainAxisSize.min, // Wrap content height
//       children: [
//         Text("🎉", style: TextStyle(fontSize: 50)), // Celebration emoji
//         SizedBox(height: 15),
//         Text("Congratulations",
//             style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF1A237E))),
//         SizedBox(height: 10),
//         Text("You're now connected with your student. Get ready to start your lessons!",
//             textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 13)),
//         SizedBox(height: 20),
//         CircularProgressIndicator(color: Colors.black, strokeWidth: 2), // Loading indicator
//       ],
//     );
//   }
// }
//
// class _CounterPopup extends StatelessWidget {
//   const _CounterPopup();
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       mainAxisSize: MainAxisSize.min, // Wrap content height
//       children: [
//         const Text("Student Offer", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
//         const Text("1500 PKR", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 20)),
//         const SizedBox(height: 20),
//         const Text("Enter your offer", style: TextStyle(fontWeight: FontWeight.w500)),
//         const SizedBox(height: 10),
//         TextField(
//           textAlign: TextAlign.center,
//           decoration: InputDecoration(
//             hintText: "1700", // Suggested counter price
//             border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
//           ),
//         ),
//         const SizedBox(height: 20),
//         Row(
//           children: [
//             Expanded(child: TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel"))), // Close button
//             Expanded(
//               child: ElevatedButton(
//                 onPressed: () {}, // Send counter offer
//                 style: ElevatedButton.styleFrom(backgroundColor: Colors.black, shape: const StadiumBorder()),
//                 child: const Text("Send", style: TextStyle(color: Colors.white)),
//               ),
//             ),
//           ],
//         )
//       ],
//     );
//   }
// }
//
// class _RejectPopup extends StatelessWidget {
//   const _RejectPopup();
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       mainAxisSize: MainAxisSize.min, // Wrap content height
//       children: [
//         const Text("Are you sure?", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
//         const SizedBox(height: 15),
//         const Text("Do you really want to reject this student's bid? This action cannot be undone.",
//             textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
//         const SizedBox(height: 25),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.end, // Align buttons to right
//           children: [
//             TextButton(onPressed: () => Navigator.pop(context), child: const Text("CANCEL", style: TextStyle(color: Colors.black))),
//             TextButton(onPressed: () {}, child: const Text("REJECT", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold))),
//           ],
//         )
//       ],
//     );
//   }
// }
//
// class _BidListTile extends StatelessWidget {
//   final String name;
//   final VoidCallback onTap;
//   const _BidListTile({required this.name, required this.onTap});
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), // Outer margins
//       padding: const EdgeInsets.all(12), // Inner padding
//       decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)), // White rounded tile
//       child: Row(
//         children: [
//           const CircleAvatar(backgroundColor: Colors.black, radius: 25), // Placeholder for profile pic
//           const SizedBox(width: 15),
//           Text(name, style: const TextStyle(fontWeight: FontWeight.bold)), // Student name
//           const Spacer(), // Push button to right
//           ElevatedButton(
//             onPressed: onTap, // Tap for details
//             style: ElevatedButton.styleFrom(backgroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
//             child: const Text("Details", style: TextStyle(color: Colors.white, fontSize: 11)),
//           )
//         ],
//       ),
//     );
//   }
// }
//
// class _BidInfoCard extends StatelessWidget {
//   const _BidInfoCard();
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(20), // Inner padding
//       decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]), // Shadowed white card
//       child: Column(
//         children: [
//           Row(
//             children: [
//               Container(width: 80, height: 80, decoration: BoxDecoration(color: Colors.red[900], borderRadius: BorderRadius.circular(10))), // Course image placeholder
//               const SizedBox(width: 15),
//               const Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text("Physics", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)), // Subject
//                   Text("2000 PKR | Matric", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)), // Price/Grade
//                   Text("⭐ 4.2 | ONLINE", style: TextStyle(fontSize: 10, color: Colors.grey)), // Rating/Mode
//                 ],
//               ),
//             ],
//           ),
//           const Divider(height: 40), // Horizontal line
//           const Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text("Your Offer:", style: TextStyle(fontWeight: FontWeight.bold)),
//               Text("2000 PKR", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 18)), // Tutor price
//             ],
//           ),
//           const Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text("Student Offer:", style: TextStyle(fontWeight: FontWeight.bold)),
//               Text("1500 PKR", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 18)), // Student price
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class _StatusButton extends StatelessWidget {
//   final String label;
//   final Color color;
//   final Color textColor;
//   final VoidCallback onTap;
//
//   const _StatusButton({required this.label, required this.color, this.textColor = Colors.white, required this.onTap});
//
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 12), // Space between buttons
//       child: SizedBox(
//         width: double.infinity, // Full width
//         height: 55, // Fixed height
//         child: ElevatedButton(
//           style: ElevatedButton.styleFrom(backgroundColor: color, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
//           onPressed: onTap, // Button action
//           child: Text(label, style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';

/// A reusable Header widget with a white background, rounded bottom corners,
/// and a back button. This should be the only widget in this file.
class CustomTabHeader extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onBackTap; // Optional callback for the back button
  final Widget? title; // Optional title if you want to add text later

  const CustomTabHeader({
    super.key,
    this.onBackTap,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 100, // Fixed height for the header
      decoration: const BoxDecoration(
        color: Colors.white, // Pure white background
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30), // Rounded corners per your design
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12, // Light shadow for depth
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            // Back Button
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 24.0),
                child: GestureDetector(
                  onTap: onBackTap ?? () => Navigator.pop(context),
                  child: const CircleAvatar(
                    backgroundColor: Colors.black, // High contrast black circle
                    radius: 22,
                    child: Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),
            // Centered Title (Optional addition)
            if (title != null)
              Center(child: title),
          ],
        ),
      ),
    );
  }

  // This allows the widget to be used in the 'preferredSize' property of a Scaffold
  @override
  Size get preferredSize => const Size.fromHeight(100);
}