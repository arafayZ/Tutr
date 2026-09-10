import 'package:flutter/material.dart';
import '../models/chat_models.dart';

class ReplyPreviewWidget extends StatelessWidget {
  final Message message;
  final VoidCallback onCancel;

  const ReplyPreviewWidget({
    super.key,
    required this.message,
    required this.onCancel,
  });

  IconData _getReplyIcon() {
    if (message.audioUrl != null && message.audioUrl!.isNotEmpty) {
      return Icons.mic;
    }
    if (message.fileUrl != null && message.fileUrl!.isNotEmpty) {
      return Icons.attach_file;
    }
    return Icons.chat_bubble;
  }

  String _getReplyText() {
    if (message.audioUrl != null && message.audioUrl!.isNotEmpty) {
      return '🎵 Audio message';
    }
    if (message.fileUrl != null && message.fileUrl!.isNotEmpty) {
      return '📎 ${message.fileName ?? "File"}';
    }
    return message.content;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        border: Border(
          top: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          Icon(_getReplyIcon(), color: Colors.blue, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Replying to ${message.senderName}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _getReplyText(),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 20, color: Colors.grey),
            onPressed: onCancel,
          ),
        ],
      ),
    );
  }
}