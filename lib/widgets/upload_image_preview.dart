import 'dart:io';

import 'package:flutter/material.dart';
import 'package:medigo_mobile/theme/app_theme.dart';

const _imageExtensions = ['jpg', 'jpeg', 'png', 'gif', 'webp', 'heic', 'heif'];

/// Whether [path] is likely an image we can preview with [Image.file].
bool isImageFilePath(String path) {
  if (path.isEmpty) return false;

  final lower = path.toLowerCase();
  final segments = path.split('.');
  if (segments.length > 1) {
    final ext = segments.last.toLowerCase();
    if (_imageExtensions.contains(ext)) return true;
  }

  // iOS/Android image_picker temp files often have no extension.
  if (lower.contains('image_picker')) return true;

  final file = File(path);
  return file.existsSync();
}

/// Small thumbnail for a local image file selected via image picker.
class UploadImagePreview extends StatelessWidget {
  const UploadImagePreview({
    super.key,
    required this.filePath,
    this.size = 56,
    this.borderRadius = 10,
  });

  final String filePath;
  final double size;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    if (!File(filePath).existsSync()) {
      return SizedBox(
        width: size,
        height: size,
        child: Icon(
          Icons.broken_image_outlined,
          size: size * 0.4,
          color: AppColors.textSecondary,
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppColors.highlight,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: Image.file(
          File(filePath),
          width: size,
          height: size,
          fit: BoxFit.cover,
          gaplessPlayback: true,
          errorBuilder: (context, error, stackTrace) => Icon(
            Icons.broken_image_outlined,
            size: size * 0.4,
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
