import 'dart:io';
import 'package:flutter/material.dart';

class FilePreview {
  final File file;
  final String fileName;
  final int fileSize;
  final String fileType;
  final bool isImage;

  FilePreview({
    required this.file,
    required this.fileName,
    required this.fileSize,
    required this.fileType,
    required this.isImage,
  });
}

class FilePreviewWidget extends StatelessWidget {
  final List<FilePreview> previews;
  final VoidCallback onCancel;
  final VoidCallback onSend;
  final bool isUploading;

  const FilePreviewWidget({
    super.key,
    required this.previews,
    required this.onCancel,
    required this.onSend,
    this.isUploading = false,
  });

  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  IconData _getIcon(String type) {
    final t = type.toLowerCase();
    if (t == 'pdf') return Icons.picture_as_pdf;
    if (t == 'doc' || t == 'docx') return Icons.description;
    if (t == 'xls' || t == 'xlsx') return Icons.table_chart;
    if (t == 'ppt' || t == 'pptx') return Icons.slideshow;
    if (t == 'zip' || t == 'rar') return Icons.folder_zip;
    return Icons.insert_drive_file;
  }

  Color _getColor(String type) {
    final t = type.toLowerCase();
    if (t == 'pdf') return Colors.red;
    if (t == 'doc' || t == 'docx') return Colors.blue;
    if (t == 'xls' || t == 'xlsx') return Colors.green;
    if (t == 'ppt' || t == 'pptx') return Colors.orange;
    return Colors.grey.shade700;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header: count + buttons
            Row(
              children: [
                Text(
                  '${previews.length} file${previews.length > 1 ? 's' : ''} selected',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: Colors.black87,
                  ),
                ),
                const Spacer(),
                // Cancel
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.grey),
                  onPressed: isUploading ? null : onCancel,
                  tooltip: 'Cancel',
                ),
                // Send
                isUploading
                    ? const Padding(
                  padding: EdgeInsets.all(12),
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
                    : Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.send_rounded,
                        color: Colors.white),
                    onPressed: onSend,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Horizontal list of previews
            SizedBox(
              height: 80,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: previews.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final preview = previews[index];

                  return Container(
                    width: 200,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      children: [
                        // Thumbnail
                        if (preview.isImage)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              preview.file,
                              width: 44,
                              height: 44,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                width: 44,
                                height: 44,
                                color: Colors.grey.shade300,
                                child: const Icon(Icons.broken_image),
                              ),
                            ),
                          )
                        else
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: _getColor(preview.fileType)
                                  .withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              _getIcon(preview.fileType),
                              color: _getColor(preview.fileType),
                              size: 24,
                            ),
                          ),

                        const SizedBox(width: 8),

                        // Info
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                preview.fileName,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _formatSize(preview.fileSize),
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}