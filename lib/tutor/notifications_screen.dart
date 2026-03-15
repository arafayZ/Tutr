import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                physics: const BouncingScrollPhysics(),
                children: [
                  const SizedBox(height: 10),
                  _buildSectionHeader("Today"),
                  _buildNotificationItem(
                    icon: Icons.refresh,
                    title: "Counter Offer for Physic",
                    subtitle: "Ahmed Khan has sent a new offer.\nTap to review.",
                  ),
                  _buildNotificationItem(
                    icon: Icons.check,
                    title: "Physics Offer Accepted",
                    subtitle: "Asim Ali Khan accepted your offer.",
                  ),
                  _buildNotificationItem(
                    icon: Icons.chat_bubble_outline,
                    title: "New message",
                    subtitle: "Afzal sent you a message.",
                  ),
                  const SizedBox(height: 15),
                  _buildSectionHeader("Yesterday"),
                  _buildNotificationItem(
                    icon: Icons.close,
                    title: "Your bid was declined",
                    subtitle: "The student has declined your offer.",
                  ),
                  _buildNotificationItem(
                    icon: Icons.person_outline,
                    title: "New Request for Physic",
                    subtitle: "Ali has sent a request for your subject ad. Please review the request and respond.",
                  ),
                  const SizedBox(height: 15),
                  _buildSectionHeader("Nov 20, 2025"),
                  _buildNotificationItem(
                    icon: Icons.lock_open_outlined,
                    title: "Account Approved",
                    subtitle: "Congratulations! Your account has been approved.\nYou now have full access to all features.",
                  ),
                  const SizedBox(height: 100), // Space for bottom nav
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
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 15,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              height: 40,
              width: 40,
              decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle),
              child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
            ),
          ),
          const Expanded(
            child: Center(
              child: Padding(
                padding: EdgeInsets.only(right: 40),
                child: Text(
                  "Notifications",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15, left: 5),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Color(0xFF2D3142),
        ),
      ),
    );
  }

  Widget _buildNotificationItem({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: Color(0xFFF1F4FF), // Light blue tint for icons
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFF2D3142), size: 22),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Color(0xFF2D3142),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------------------------
// import 'package:flutter/material.dart';
//
// class _NotificationsScreenState extends State<NotificationsScreen> {
//   // 2. This list will eventually come from your Backend/API
//   final List<NotificationModel> _notifications = [
//     NotificationModel(
//       icon: Icons.refresh,
//       title: "Counter Offer for Physics",
//       subtitle: "Ahmed Khan has sent a new offer.\nTap to review.",
//       category: "Today",
//     ),
//     NotificationModel(
//       icon: Icons.check,
//       title: "Physics Offer Accepted",
//       subtitle: "Asim Ali Khan accepted your offer.",
//       category: "Today",
//     ),
//     NotificationModel(
//       icon: Icons.chat_bubble_outline,
//       title: "New message",
//       subtitle: "Afzal sent you a message.",
//       category: "Today",
//     ),
//     NotificationModel(
//       icon: Icons.close,
//       title: "Your bid was declined",
//       subtitle: "The student has declined your offer.",
//       category: "Yesterday",
//     ),
//     NotificationModel(
//       icon: Icons.person_outline,
//       title: "New Request for Physics",
//       subtitle: "Ali has sent a request for your subject ad. Please review.",
//       category: "Yesterday",
//     ),
//     NotificationModel(
//       icon: Icons.lock_open_outlined,
//       title: "Account Approved",
//       subtitle: "Congratulations! Your account has been approved.",
//       category: "Nov 20, 2025",
//     ),
//   ];
//
//   @override
//   Widget build(BuildContext context) {
//     // Grouping notifications by category for the UI
//     Map<String, List<NotificationModel>> groupedNotifications = {};
//     for (var n in _notifications) {
//       groupedNotifications.putIfAbsent(n.category, () => []).add(n);
//     }
//
//     return Scaffold(
//       backgroundColor: const Color(0xFFF8F9FB),
//       body: SafeArea(
//         child: Column(
//           children: [
//             _buildHeader(context),
//             Expanded(
//               child: _notifications.isEmpty
//                   ? _buildEmptyState() // Handle case with no notifications
//                   : ListView.builder(
//                 padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//                 physics: const BouncingScrollPhysics(),
//                 itemCount: groupedNotifications.keys.length,
//                 itemBuilder: (context, index) {
//                   String category = groupedNotifications.keys.elementAt(index);
//                   List<NotificationModel> items = groupedNotifications[category]!;
//
//                   return Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const SizedBox(height: 10),
//                       _buildSectionHeader(category),
//                       ...items.map((item) => _buildNotificationItem(item)),
//                       const SizedBox(height: 10),
//                     ],
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   // Rest of your helper methods (Header, SectionHeader, Item) remain the same...
//   Widget _buildHeader(BuildContext context) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: const BorderRadius.only(
//           bottomLeft: Radius.circular(30),
//           bottomRight: Radius.circular(30),
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.06),
//             blurRadius: 15,
//             offset: const Offset(0, 8),
//           )
//         ],
//       ),
//       child: Row(
//         children: [
//           GestureDetector(
//             onTap: () => Navigator.pop(context),
//             child: Container(
//               height: 40,
//               width: 40,
//               decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle),
//               child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
//             ),
//           ),
//           const Expanded(
//             child: Center(
//               child: Padding(
//                 padding: EdgeInsets.only(right: 40),
//                 child: Text(
//                   "Notifications",
//                   style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildSectionHeader(String title) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 15, left: 5),
//       child: Text(
//         title,
//         style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2D3142)),
//       ),
//     );
//   }
//
//   Widget _buildNotificationItem(NotificationModel item) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 15),
//       padding: const EdgeInsets.all(15),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [
//           BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
//         ],
//       ),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Container(
//             padding: const EdgeInsets.all(10),
//             decoration: const BoxDecoration(color: Color(0xFFF1F4FF), shape: BoxShape.circle),
//             child: Icon(item.icon, color: const Color(0xFF2D3142), size: 22),
//           ),
//           const SizedBox(width: 15),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF2D3142))),
//                 const SizedBox(height: 4),
//                 Text(item.subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12, height: 1.4)),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildEmptyState() {
//     return const Center(
//       child: Text("No new notifications", style: TextStyle(color: Colors.grey)),
//     );
//   }
// }
//
// // 1. Notification Model to represent your backend data
// class NotificationModel {
//   final IconData icon;
//   final String title;
//   final String subtitle;
//   final String category; // e.g., "Today", "Yesterday"
//
//   NotificationModel({
//     required this.icon,
//     required this.title,
//     required this.subtitle,
//     required this.category,
//   });
// }
//
// class NotificationsScreen extends StatefulWidget {
//   const NotificationsScreen({super.key});
//
//   @override
//   State<NotificationsScreen> createState() => _NotificationsScreenState();
// }
