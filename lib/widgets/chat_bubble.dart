import 'package:flutter/material.dart';
import 'package:medigo_mobile/theme/app_theme.dart';

class ChatBubble extends StatelessWidget {
  const ChatBubble({
    super.key,
    required this.text,
    required this.isOutgoing,
  });

  final String text;

  /// True when this message was sent by the current user (right-aligned).
  final bool isOutgoing;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isOutgoing ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.78,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isOutgoing ? AppColors.primary : AppColors.highlight,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isOutgoing ? 16 : 4),
            bottomRight: Radius.circular(isOutgoing ? 4 : 16),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 14,
            color: isOutgoing ? AppColors.surface : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
