import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:medigo_mobile/theme/app_theme.dart';

class MultiFileUploadField extends StatelessWidget {
  const MultiFileUploadField({
    super.key,
    required this.label,
    required this.filePaths,
    required this.onFilesChanged,
    this.maxFiles = 10,
    this.acceptCamera = true,
  });

  final String label;
  final List<String> filePaths;
  final void Function(List<String> paths) onFilesChanged;
  final int maxFiles;
  final bool acceptCamera;

  Future<void> _pickFile(BuildContext context) async {
    if (filePaths.length >= maxFiles) return;

    try {
      final picker = ImagePicker();
      final source = acceptCamera
          ? await showModalBottomSheet<ImageSource>(
              context: context,
              builder: (ctx) => SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.photo_library),
                      title: const Text('Choose from gallery'),
                      onTap: () => Navigator.pop(ctx, ImageSource.gallery),
                    ),
                    ListTile(
                      leading: const Icon(Icons.camera_alt),
                      title: const Text('Take photo'),
                      onTap: () => Navigator.pop(ctx, ImageSource.camera),
                    ),
                    if (Navigator.canPop(ctx))
                      ListTile(
                        leading: const Icon(Icons.close),
                        title: const Text('Cancel'),
                        onTap: () => Navigator.pop(ctx),
                      ),
                  ],
                ),
              ),
            )
          : ImageSource.gallery;

      if (source == null && acceptCamera) return;

      final picked = await picker.pickImage(
        source: source ?? ImageSource.gallery,
        maxWidth: 1920,
        imageQuality: 85,
      );

      if (picked != null && picked.path.isNotEmpty && context.mounted) {
        onFilesChanged([...filePaths, picked.path]);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to select file: $e')),
        );
      }
    }
  }

  void _removeFile(int index) {
    final updated = [...filePaths]..removeAt(index);
    onFilesChanged(updated);
  }

  String _friendlyName(int index) {
    return 'Document ${index + 1}';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.bodySecondary),
        const SizedBox(height: 8),
        if (filePaths.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.highlight.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border, width: 1.2),
            ),
            child: Column(
              children: filePaths
                  .asMap()
                  .entries
                  .map((e) => Padding(
                        padding: EdgeInsets.only(
                          bottom: e.key < filePaths.length - 1 ? 6 : 0,
                        ),
                        child: _buildFileChip(e.value, e.key),
                      ))
                  .toList(),
            ),
          ),
        if (filePaths.isNotEmpty) const SizedBox(height: 8),
        if (filePaths.length < maxFiles)
          InkWell(
            onTap: () => _pickFile(context),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.border,
                width: 1.4,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.add_photo_alternate_outlined,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  filePaths.isEmpty
                      ? 'Add documents'
                      : 'Add another',
                  style: AppTypography.bodySecondary.copyWith(
                    fontSize: 14,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          ),
      ],
    );
  }

  Widget _buildFileChip(String path, int index) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.primary, width: 1.2),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.insert_drive_file_outlined,
            color: AppColors.primary,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _friendlyName(index),
              style: AppTypography.bodySecondary.copyWith(
                fontSize: 13,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          GestureDetector(
            onTap: () => _removeFile(index),
            child: const Padding(
              padding: EdgeInsets.all(4),
              child: Icon(
                Icons.close,
                color: AppColors.textSecondary,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
