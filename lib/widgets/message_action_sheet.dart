// import 'package:flutter/material.dart';
//
// class MessageActionSheet extends StatelessWidget {
//   final bool isMe;
//   final VoidCallback onReply;
//   final VoidCallback onForward;
//   final VoidCallback onDelete;
//
//   const MessageActionSheet({
//     super.key,
//     required this.isMe,
//     required this.onReply,
//     required this.onForward,
//     required this.onDelete,
//   });
//
//   static Future<void> show(
//       BuildContext context, {
//         required bool isMe,
//         required VoidCallback onReply,
//         required VoidCallback onForward,
//         required VoidCallback onDelete,
//       }) {
//     return showModalBottomSheet(
//       context: context,
//       backgroundColor: Colors.transparent,
//       builder: (context) => MessageActionSheet(
//         isMe: isMe,
//         onReply: onReply,
//         onForward: onForward,
//         onDelete: onDelete,
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.15),
//             blurRadius: 20,
//             offset: const Offset(0, 8),
//           ),
//         ],
//       ),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           const SizedBox(height: 8),
//           Container(
//             width: 40,
//             height: 4,
//             decoration: BoxDecoration(
//               color: Colors.grey.shade300,
//               borderRadius: BorderRadius.circular(2),
//             ),
//           ),
//           const SizedBox(height: 8),
//
//           ListTile(
//             leading: const Icon(Icons.reply, color: Colors.blue),
//             title: const Text(
//               'Reply',
//               style: TextStyle(fontWeight: FontWeight.w600),
//             ),
//             onTap: () {
//               Navigator.pop(context);
//               onReply();
//             },
//           ),
//
//           ListTile(
//             leading: const Icon(Icons.forward, color: Colors.green),
//             title: const Text(
//               'Forward',
//               style: TextStyle(fontWeight: FontWeight.w600),
//             ),
//             onTap: () {
//               Navigator.pop(context);
//               onForward();
//             },
//           ),
//
//           ListTile(
//             leading: const Icon(Icons.delete, color: Colors.red),
//             title: const Text(
//               'Delete',
//               style: TextStyle(fontWeight: FontWeight.w600, color: Colors.red),
//             ),
//             onTap: () {
//               Navigator.pop(context);
//               onDelete();
//             },
//           ),
//
//           const SizedBox(height: 8),
//         ],
//       ),
//     );
//   }
// }