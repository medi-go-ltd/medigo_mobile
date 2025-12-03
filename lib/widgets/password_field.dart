import 'package:flutter/material.dart';
import 'package:medigo_mobile/widgets/app_text_field.dart';
import 'package:medigo_mobile/widgets/password_strength_indicator.dart';

class PasswordField extends StatefulWidget {
  const PasswordField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onFieldSubmitted,
    required this.validator,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final void Function(String)? onFieldSubmitted;
  final String? Function(String?)? validator;

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppTextField(
          controller: widget.controller,
          focusNode: widget.focusNode,
          label: 'Password',
          hintText: 'Password',
          icon: Icons.lock_outline,
          keyboardType: TextInputType.visiblePassword,
          textInputAction: TextInputAction.next,
          obscureText: !_isPasswordVisible,
          validator: widget.validator,
          onFieldSubmitted: widget.onFieldSubmitted,
          onChanged: (_) => setState(() {}),
          suffixIcon: IconButton(
            icon: Icon(
              _isPasswordVisible
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
            ),
            onPressed: () {
              setState(() {
                _isPasswordVisible = !_isPasswordVisible;
              });
            },
          ),
        ),
        if (widget.controller.text.isNotEmpty) ...[
          const SizedBox(height: 12),
          PasswordStrengthIndicator(password: widget.controller.text),
        ],
      ],
    );
  }
}
