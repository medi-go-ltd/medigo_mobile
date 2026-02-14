import 'package:flutter/material.dart';
import 'package:medigo_mobile/theme/app_theme.dart';

class ChatBubble extends StatelessWidget {
  const ChatBubble({
    super.key,
    required this.text,
    required this.isFromDoctor,
  });

  final String text;
  final bool isFromDoctor;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isFromDoctor ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isFromDoctor ? AppColors.primary : AppColors.highlight,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isFromDoctor ? 16 : 4),
            bottomRight: Radius.circular(isFromDoctor ? 4 : 16),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 14,
            color: isFromDoctor ? AppColors.surface : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
