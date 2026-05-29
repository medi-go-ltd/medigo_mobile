import 'package:flutter/material.dart';
import 'package:medigo_mobile/theme/app_theme.dart';

/// Label for form fields; appends a red asterisk when [required] is true.
class FieldLabel extends StatelessWidget {
  const FieldLabel({
    super.key,
    required this.text,
    this.required = false,
  });

  final String text;
  final bool required;

  @override
  Widget build(BuildContext context) {
    if (!required) {
      return Text(text, style: AppTypography.bodySecondary);
    }

    return Text.rich(
      TextSpan(
        style: AppTypography.bodySecondary,
        children: [
          TextSpan(text: text),
          const TextSpan(
            text: ' *',
            style: TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
