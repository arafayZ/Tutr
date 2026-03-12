import 'package:flutter/material.dart';

class ChatDetailsScreen extends StatefulWidget {
  final String userName;

  const ChatDetailsScreen({super.key, required this.userName});

  @override
  State<ChatDetailsScreen> createState() => _ChatDetailsScreenState();
}

class _ChatDetailsScreenState extends State<ChatDetailsScreen> {
  // Controller to handle the text input
  final TextEditingController _messageController = TextEditingController();
  // Controller to handle automatic scrolling to the bottom
  final ScrollController _scrollController = ScrollController();

  final List<Map<String, dynamic>> _messages = [
    {"text": "Can we shift today's class to 6 PM?", "isMe": false, "time": "4:30 AM"},
    {"text": "Yes, 6 PM works.", "isMe": true, "time": "9:30 AM"},
    {"text": "Perfect, see you then.", "isMe": false, "time": "9:44 AM"},
    {"text": "Thank you!", "isMe": true, "time": "9:50 AM"},
  ];

  // Function to handle sending messages
  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        _messages.add({
          "text": text,
          "isMe": true,
          "time": _getCurrentTime(),
        });
        _messageController.clear();
      });

      // Small delay to ensure the ListView has rendered the new item before scrolling
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  // Helper to format current time
  String _getCurrentTime() {
    final now = DateTime.now();
    final hour = now.hour > 12 ? now.hour - 12 : (now.hour == 0 ? 12 : now.hour);
    final amPm = now.hour >= 12 ? 'PM' : 'AM';
    return "$hour:${now.minute.toString().padLeft(2, '0')} $amPm";
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // --- ROUNDED HEADER ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      height: 40,
                      width: 40,
                      decoration: const BoxDecoration(
                        color: Colors.black,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                    ),
                  ),
                  const SizedBox(width: 15),
                  const CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.black,
                    child: Icon(Icons.person, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
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
                controller: _scrollController,
                padding: const EdgeInsets.all(20),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  return _buildMessageBubble(_messages[index]);
                },
              ),
            ),

            // --- INPUT AREA ---
            _buildMessageInput(),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> msg) {
    bool isMe = msg["isMe"];
    return Column(
      crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 5),
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
          decoration: BoxDecoration(
            color: isMe ? Colors.black : Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(15),
              topRight: const Radius.circular(15),
              bottomLeft: isMe ? const Radius.circular(15) : Radius.zero,
              bottomRight: isMe ? Radius.zero : const Radius.circular(15),
            ),
            boxShadow: isMe ? [] : [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 5,
                offset: const Offset(0, 2),
              )
            ],
          ),
          child: Text(
            msg["text"],
            style: TextStyle(
                color: isMe ? Colors.white : Colors.black,
                fontSize: 15
            ),
          ),
        ),
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

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: SafeArea(
        child: Container(
          margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom == 0 ? 10 : 0,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 15),
          decoration: BoxDecoration(
            color: const Color(0xFFF8F9FB),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  onSubmitted: (_) => _sendMessage(),
                  decoration: const InputDecoration(
                    hintText: "Type message...",
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              IconButton(
                onPressed: _sendMessage,
                icon: const Icon(
                  Icons.send_rounded,
                  color: Colors.black,
                  size: 24,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}