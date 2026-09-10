import 'package:flutter/material.dart';

class AttachmentSheet extends StatelessWidget {
  final VoidCallback onDocument;
  final VoidCallback onGallery;
  final VoidCallback onCamera;

  const AttachmentSheet({
    super.key,
    required this.onDocument,
    required this.onGallery,
    required this.onCamera,
  });

  static Future<void> show(
      BuildContext context, {
        required VoidCallback onDocument,
        required VoidCallback onGallery,
        required VoidCallback onCamera,
      }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => AttachmentSheet(
        onDocument: onDocument,
        onGallery: onGallery,
        onCamera: onCamera,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildOption(
            icon: Icons.insert_drive_file,
            label: 'Document',
            color: Colors.purple,
            onTap: () {
              Navigator.pop(context);
              onDocument();
            },
          ),
          _buildOption(
            icon: Icons.photo_library,
            label: 'Gallery',
            color: Colors.blue,
            onTap: () {
              Navigator.pop(context);
              onGallery();
            },
          ),
          _buildOption(
            icon: Icons.camera_alt,
            label: 'Camera',
            color: Colors.green,
            onTap: () {
              Navigator.pop(context);
              onCamera();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}