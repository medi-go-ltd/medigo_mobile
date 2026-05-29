import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:medigo_mobile/theme/app_theme.dart';
import 'package:medigo_mobile/widgets/field_label.dart';
import 'package:medigo_mobile/widgets/upload_image_preview.dart';

class FileUploadField extends StatelessWidget {
  const FileUploadField({
    super.key,
    required this.label,
    required this.onFileSelected,
    this.filePath,
    this.validator,
    this.source = ImageSource.gallery,
    this.acceptCamera = true,
    this.previewSize = 56,
    this.required = false,
    this.errorText,
  });

  final String label;
  final void Function(String path) onFileSelected;
  final String? filePath;
  final String? Function(String?)? validator;
  final ImageSource source;
  final bool acceptCamera;
  final double previewSize;
  final bool required;
  final String? errorText;

  Future<void> _pickFile(BuildContext context) async {
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
        onFileSelected(picked.path);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to select file: $e')),
        );
      }
    }
  }

  String _fileName(String path) {
    final name = path.split('/').last;
    return name.length > 40 ? '${name.substring(0, 37)}...' : name;
  }

  @override
  Widget build(BuildContext context) {
    final hasFile = filePath != null && filePath!.isNotEmpty;
    final showImagePreview = hasFile && isImageFilePath(filePath!);
    final hasError = errorText != null && errorText!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FieldLabel(text: label, required: required),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _pickFile(context),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: hasError
                    ? Colors.red
                    : (hasFile ? AppColors.primary : AppColors.border),
                width: hasError || hasFile ? 1.6 : 1.4,
              ),
            ),
            child: Row(
              children: [
                if (showImagePreview)
                  UploadImagePreview(
                    filePath: filePath!,
                    size: previewSize,
                  )
                else
                  Icon(
                    hasFile ? Icons.check_circle : Icons.upload_file_outlined,
                    color:
                        hasFile ? AppColors.primary : AppColors.textSecondary,
                    size: 28,
                  ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hasFile
                            ? (showImagePreview
                                ? 'Photo selected'
                                : _fileName(filePath!))
                            : 'Tap to upload',
                        style: AppTypography.body.copyWith(
                          color: hasFile
                              ? AppColors.textPrimary
                              : AppColors.textSecondary,
                          fontWeight:
                              hasFile ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                      if (hasFile)
                        Text(
                          showImagePreview
                              ? 'Tap to change photo'
                              : 'Tap to change file',
                          style: AppTypography.bodySecondary.copyWith(
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                ),
                if (hasFile)
                  IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: AppColors.textSecondary,
                    ),
                    onPressed: () => onFileSelected(''),
                  ),
              ],
            ),
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 4),
          Text(
            errorText!,
            style: AppTypography.bodySecondary.copyWith(
              color: Colors.red,
              fontSize: 12,
            ),
          ),
        ] else if (validator != null && hasFile) ...[
          const SizedBox(height: 4),
          Builder(
            builder: (ctx) {
              final error = validator!(filePath);
              if (error != null) {
                return Text(
                  error,
                  style: AppTypography.bodySecondary.copyWith(
                    color: Colors.red,
                    fontSize: 12,
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ],
    );
  }
}
