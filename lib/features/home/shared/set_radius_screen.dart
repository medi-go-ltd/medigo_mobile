import 'package:flutter/material.dart';
import 'package:medigo_mobile/theme/app_theme.dart';

class SetRadiusScreen extends StatefulWidget {
  const SetRadiusScreen({
    super.key,
    required this.initialRadius,
    required this.initialIsAvailable,
    required this.onSave,
  });

  final double initialRadius;
  final bool initialIsAvailable;
  final void Function(double radiusKm, bool setAvailable) onSave;

  @override
  State<SetRadiusScreen> createState() => _SetRadiusScreenState();
}

class _SetRadiusScreenState extends State<SetRadiusScreen> {
  late double _radius;
  late bool _setAvailable;

  @override
  void initState() {
    super.initState();
    _radius = widget.initialRadius;
    _setAvailable = widget.initialIsAvailable;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
          color: AppColors.textPrimary,
        ),
        title: const Text(
          'Set Radius',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 24),
            Text(
              'Operating radius (km)',
              style: AppTypography.bodySecondary.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_radius.round()} km',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                const Text(
                  '1–100 km',
                  style: AppTypography.bodySecondary,
                ),
              ],
            ),
            Slider(
              value: _radius,
              min: 1,
              max: 100,
              divisions: 99,
              activeColor: AppColors.primary,
              onChanged: (v) => setState(() => _radius = v),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.highlight.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Checkbox(
                    value: _setAvailable,
                    onChanged: (v) => setState(() => _setAvailable = v ?? true),
                    activeColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _setAvailable = !_setAvailable),
                      child: Text(
                        'Set status to Available when I save',
                        style: AppTypography.body.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  widget.onSave(_radius, _setAvailable);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.surface,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  textStyle: AppTypography.button,
                ),
                child: const Text('Save'),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
