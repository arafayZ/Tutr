// Importing Flutter's material design widgets
import 'package:flutter/material.dart';

// Stateful widget to represent a chat screen for a specific user
class ChatDetailsScreen extends StatefulWidget {
  final String userName; // Stores the name of the user being chatted with

  const ChatDetailsScreen({super.key, required this.userName});
  // Constructor requires userName, super.key allows widget tree optimizations

  @override
  State<ChatDetailsScreen> createState() => _ChatDetailsScreenState();
// Creates the mutable state for this widget
}

// State class for ChatDetailsScreen
class _ChatDetailsScreenState extends State<ChatDetailsScreen> {
  // Sample messages for demonstration purposes
  final List<Map<String, dynamic>> _messages = [
    {"text": "Can we shift today's class to 6 PM?", "isMe": false, "time": "4:30 AM"},
    {"text": "Yes, 6 PM works.", "isMe": true, "time": "9:30 AM"},
    {"text": "Perfect, see you then.", "isMe": false, "time": "9:44 AM"},
    {"text": "Thank you!", "isMe": true, "time": "9:50 AM"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB), // Matches inbox/background color
      body: SafeArea(
        bottom: false, // Avoids padding at the bottom, useful for custom input
        child: Column(
          children: [
            // --- ROUNDED HEADER (like inbox) ---
            Container(
              width: double.infinity, // Full width
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white, // Header background
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ), // Rounded bottom corners
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ], // Soft shadow under header
              ),
              child: Row(
                children: [
                  // Back Button
                  InkWell(
                    onTap: () => Navigator.pop(context), // Navigate back on tap
                    child: Container(
                      height: 40,
                      width: 40,
                      decoration: const BoxDecoration(
                        color: Colors.black, // Black circular button
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                      // White arrow icon
                    ),
                  ),
                  const SizedBox(width: 15), // Spacing
                  // Profile Avatar
                  const CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.black,
                    child: Icon(Icons.person, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  // User name text
                  Text(
                    widget.userName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),

            // --- MESSAGES LIST ---
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: _messages.length, // Number of messages to display
                itemBuilder: (context, index) {
                  final msg = _messages[index]; // Current message
                  return _buildMessageBubble(msg); // Build bubble for message
                },
              ),
            ),

            // --- INPUT AREA ---
            _buildMessageInput(), // Bottom text field and send button
          ],
        ),
      ),
    );
  }

  // Widget to build individual message bubbles
  Widget _buildMessageBubble(Map<String, dynamic> msg) {
    bool isMe = msg["isMe"]; // True if message is sent by current user
    return Column(
      crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      // Align right if sent by me, left otherwise
      children: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 5),
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
          // Bubbles take max 70% of screen width
          decoration: BoxDecoration(
            color: isMe ? Colors.black : Colors.white, // Color based on sender
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(15),
              topRight: const Radius.circular(15),
              bottomLeft: isMe ? const Radius.circular(15) : Radius.zero,
              bottomRight: isMe ? Radius.zero : const Radius.circular(15),
            ), // Custom rounded corners for bubble style
            boxShadow: isMe ? [] : [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 5,
                offset: const Offset(0, 2),
              )
            ], // Shadow only for received messages
          ),
          child: Text(
            msg["text"],
            style: TextStyle(
                color: isMe ? Colors.white : Colors.black,
                fontSize: 15
            ),
          ),
        ),
        // Message timestamp
        Padding(
          padding: const EdgeInsets.only(bottom: 10, left: 4, right: 4),
          child: Text(
            msg["time"],
            style: const TextStyle(fontSize: 10, color: Colors.grey),
          ),
        ),
      ],
    );
  }

  // Widget for input field and send button
  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
      decoration: const BoxDecoration(
        color: Colors.transparent, // Transparent to keep background consistent
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        decoration: BoxDecoration(
          color: Colors.white, // Input box background
          borderRadius: BorderRadius.circular(30), // Rounded edges
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ], // Soft shadow for input
        ),
        child: Row(
          children: [
            // Text input field
            const Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Type message...", // Placeholder text
                  border: InputBorder.none, // No border
                ),
              ),
            ),
            // Send button
            IconButton(
              onPressed: () {}, // Action when send is tapped (currently empty)
              icon: const Icon(Icons.send_rounded, color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }
}