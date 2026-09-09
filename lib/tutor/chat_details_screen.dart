// lib/tutor/chat_details_screen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/chat_service.dart';
import '../services/websocket_service.dart';
import '../models/chat_models.dart';
import '../config/api_config.dart';

class TutorChatDetailsScreen extends StatefulWidget {
  final String userName;
  final String? userImage;
  final int? studentId;       // Profile ID (for reference only)
  final int? studentUserId;   // User ID from users table
  final int? tutorId;         // Profile ID (for reference only)
  final int? tutorUserId;     // User ID from users table
  final int? chatRoomId;
  final int? connectionId;

  const TutorChatDetailsScreen({
    super.key,
    required this.userName,
    this.userImage,
    this.studentId,
    this.studentUserId,
    this.tutorId,
    this.tutorUserId,
    this.chatRoomId,
    this.connectionId,
  });

  @override
  State<TutorChatDetailsScreen> createState() => _TutorChatDetailsScreenState();
}

class _TutorChatDetailsScreenState extends State<TutorChatDetailsScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<Message> _messages = [];
  Set<int> _messageIds = {};
  int _chatRoomId = 0;
  int _senderId = 0;
  int _recipientId = 0;
  bool _isLoading = true;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  Future<void> _initializeChat() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    _senderId = prefs.getInt('userId') ?? 0;
    if (_senderId == 0) {
      _senderId = prefs.getInt('profileId') ?? 0;
    }

    // ✅ Determine recipient (student's user ID)
    _recipientId = widget.studentUserId ?? 0;

    print('🔍 Tutor Chat Init:');
    print('   Sender (Tutor) User ID: $_senderId');
    print('   Recipient (Student) User ID: $_recipientId');

    await _getOrCreateChatRoom();
    await _loadMessages();
    _connectWebSocket();
  }

  Future<void> _getOrCreateChatRoom() async {
    try {
      // ✅ If chatRoomId is provided, use it
      if (widget.chatRoomId != null && widget.chatRoomId! > 0) {
        _chatRoomId = widget.chatRoomId!;
        print('✅ Using existing chat room ID: $_chatRoomId');
        return;
      }

      // ✅ Use SHARED chat room (one per student-tutor pair)
      // Need both studentUserId and tutorUserId
      if (widget.studentUserId != null && widget.studentUserId! > 0 && _senderId > 0) {
        print('🔍 Getting/Creating shared chat room for student: ${widget.studentUserId}, tutor: $_senderId');

        final chatRoom = await ChatService.getOrCreateSharedChatRoom(
          widget.studentUserId!,  // Student User ID
          _senderId,              // Tutor User ID
          _senderId,              // Current user (tutor)
        );

        _chatRoomId = chatRoom.id;
        print('✅ Shared chat room ID: $_chatRoomId');

        // Update recipient if needed
        if (chatRoom.studentUserId != null && chatRoom.studentUserId != _senderId) {
          _recipientId = chatRoom.studentUserId!;
        } else if (chatRoom.tutorUserId != null && chatRoom.tutorUserId != _senderId) {
          _recipientId = chatRoom.tutorUserId!;
        }
      } else {
        // Fallback: Try connection-based approach
        if (widget.connectionId != null && widget.connectionId! > 0) {
          print('⚠️ Fallback: Using connection-based chat room');
          final chatRoom = await ChatService.getOrCreateChatRoom(
            widget.connectionId!,
            _senderId,
          );
          _chatRoomId = chatRoom.id;
          if (chatRoom.studentUserId != null && chatRoom.studentUserId != _senderId) {
            _recipientId = chatRoom.studentUserId!;
          } else if (chatRoom.tutorUserId != null && chatRoom.tutorUserId != _senderId) {
            _recipientId = chatRoom.tutorUserId!;
          }
        } else {
          throw Exception('No studentUserId or connectionId provided');
        }
      }
    } catch (e) {
      print('❌ Error getting chat room: $e');
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to open chat: ${e.toString().replaceFirst('Exception: ', '')}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _loadMessages() async {
    if (_chatRoomId == 0) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      final messages = await ChatService.getMessages(_chatRoomId, _senderId);
      setState(() {
        _messages = messages.reversed.toList();
        _messageIds = _messages.map((m) => m.id).toSet();
        _isLoading = false;
      });
      _scrollToBottom();
    } catch (e) {
      print('Error loading messages: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _connectWebSocket() {
    WebSocketService.instance.connect(_senderId);
    WebSocketService.instance.addListener(_onNewMessage);
  }

  void _onNewMessage(Message message) {
    if (message.chatRoomId == _chatRoomId || _chatRoomId == 0) {
      setState(() {
        if (!_messageIds.contains(message.id)) {
          _messageIds.add(message.id);
          _messages.add(message);
        }
      });
      _scrollToBottom();
    }
  }

  void _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isSending) return;

    setState(() => _isSending = true);

    try {
      if (_chatRoomId > 0 && _recipientId > 0) {
        final request = SendMessageRequest(
          chatRoomId: _chatRoomId,
          senderId: _senderId,
          recipientId: _recipientId,
          content: text,
        );
        final message = await ChatService.sendMessage(request);

        setState(() {
          if (!_messageIds.contains(message.id)) {
            _messageIds.add(message.id);
            _messages.add(message);
          }
          _messageController.clear();
          _isSending = false;
        });

        WebSocketService.instance.sendMessage(message);
      } else {
        setState(() {
          _isSending = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Chat room not initialized'),
            backgroundColor: Colors.red,
          ),
        );
      }
      _scrollToBottom();
    } catch (e) {
      print('Error sending message: $e');
      setState(() => _isSending = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to send message'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _deleteMessage(Message message) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Message'),
        content: const Text('Are you sure you want to delete this message?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await ChatService.deleteMessage(message.id, _senderId);
      setState(() {
        _messages.removeWhere((m) => m.id == message.id);
        _messageIds.remove(message.id);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Message deleted'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('Error deleting message: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to delete message'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteAllMessages() async {
    if (_messages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No messages to delete'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete All Messages'),
        content: Text(
          'Are you sure you want to delete all messages in this chat with ${widget.userName}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete All'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);

    try {
      for (var message in _messages) {
        await ChatService.deleteMessage(message.id, _senderId);
      }

      setState(() {
        _messages.clear();
        _messageIds.clear();
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All messages deleted'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('Error deleting all messages: $e');
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to delete messages'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _scrollToBottom() {
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

  String _formatMessageTime(DateTime time) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final date = DateTime(time.year, time.month, time.day);
    final diff = today.difference(date).inDays;

    int hour = time.hour;
    final minute = time.minute;
    final amPm = hour >= 12 ? 'PM' : 'AM';
    int hour12 = hour % 12;
    if (hour12 == 0) hour12 = 12;
    final timeStr = "$hour12:${minute.toString().padLeft(2, '0')} $amPm";

    if (diff == 0) {
      return timeStr;
    } else if (diff == 1) {
      return "Yesterday $timeStr";
    } else if (diff < 7) {
      final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return "${weekdays[time.weekday - 1]} $timeStr";
    } else {
      return "${date.day}/${date.month}/${date.year} $timeStr";
    }
  }

  @override
  void dispose() {
    WebSocketService.instance.removeListener(_onNewMessage);
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userImageUrl = widget.userImage != null && widget.userImage!.isNotEmpty
        ? '${ApiConfig.baseUrl}${widget.userImage}'
        : null;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(userImageUrl),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: Colors.black))
                  : _messages.isEmpty
                  ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.chat_bubble_outline, size: 60, color: Colors.grey),
                    SizedBox(height: 16),
                    Text("No messages yet", style: TextStyle(color: Colors.grey, fontSize: 16)),
                    Text("Start the conversation!", style: TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              )
                  : ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(20),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  final bool isMe = message.senderId == _senderId;
                  return GestureDetector(
                    onLongPress: () => _deleteMessage(message),
                    child: _buildMessageBubble(message, isMe),
                  );
                },
              ),
            ),
            _buildMessageInput(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(String? userImageUrl) {
    return Container(
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
              decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle),
              child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
            ),
          ),
          const SizedBox(width: 15),
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.grey[300],
            backgroundImage: userImageUrl != null ? NetworkImage(userImageUrl) : null,
            child: userImageUrl == null ? const Icon(Icons.person, color: Colors.white, size: 20) : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              widget.userName,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'delete_all') {
                _deleteAllMessages();
              }
            },
            icon: const Icon(Icons.more_vert, color: Colors.black, size: 28),
            itemBuilder: (context) => [
              const PopupMenuItem<String>(
                value: 'delete_all',
                child: Row(
                  children: [
                    Icon(Icons.delete_sweep, color: Colors.red, size: 20),
                    SizedBox(width: 8),
                    Text('Delete All Messages'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Message message, bool isMe) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Flexible(
            child: Column(
              crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.7,
                  ),
                  decoration: BoxDecoration(
                    color: isMe ? Colors.black : Colors.grey.shade200,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: isMe ? const Radius.circular(16) : const Radius.circular(4),
                      bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(16),
                    ),
                  ),
                  child: Text(
                    message.content,
                    style: TextStyle(
                      color: isMe ? Colors.white : Colors.black87,
                      fontSize: 15,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 4, left: 4, right: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _formatMessageTime(message.sentAt),
                        style: const TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                      if (isMe) ...[
                        const SizedBox(width: 4),
                        Icon(
                          message.isRead ? Icons.done_all : Icons.done,
                          size: 14,
                          color: message.isRead ? Colors.blue : Colors.grey,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: const BoxDecoration(color: Colors.white),
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
                  enabled: !_isSending,
                  decoration: const InputDecoration(
                    hintText: "Type message...",
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              IconButton(
                onPressed: _isSending ? null : _sendMessage,
                icon: _isSending
                    ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : const Icon(
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