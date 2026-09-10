import 'package:flutter/material.dart';
import '../config/api_config.dart';
import '../services/file_opener_service.dart';

class ImageMessageWidget extends StatelessWidget {
  final String imageUrl;
  final bool isMe;

  const ImageMessageWidget({
    super.key,
    required this.imageUrl,
    this.isMe = false,
  });

  @override
  Widget build(BuildContext context) {
    final fullUrl = imageUrl.startsWith('http')
        ? imageUrl
        : '${ApiConfig.baseUrl}$imageUrl';

    return GestureDetector(
      // ✅ Tap to open fullscreen
      onTap: () {
        FileOpenerService.openImageViewer(
          context,
          imageUrl: imageUrl,
          title: 'Image',
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Hero(
          tag: 'image_$imageUrl',
          child: Image.network(
            fullUrl,
            width: 200,
            height: 200,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, progress) {
              if (progress == null) return child;
              return Container(
                width: 200,
                height: 200,
                color: Colors.grey.shade300,
                child: Center(
                  child: CircularProgressIndicator(
                    value: progress.expectedTotalBytes != null
                        ? progress.cumulativeBytesLoaded /
                        progress.expectedTotalBytes!
                        : null,
                    strokeWidth: 2,
                    color: Colors.black,
                  ),
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 200,
                height: 150,
                color: Colors.grey.shade200,
                child: const Center(
                  child: Icon(Icons.broken_image, color: Colors.grey, size: 40),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}