import 'package:flutter/material.dart';
import 'package:medigo_mobile/theme/app_theme.dart';

class BodyDiagramWidget extends StatelessWidget {
  const BodyDiagramWidget({
    super.key,
    this.selectedAreas = const {},
    required this.onAreaToggled,
  });

  final Set<String> selectedAreas;
  final ValueChanged<String> onAreaToggled;

  static const areas = [
    'Head',
    'Neck',
    'Chest',
    'Abdomen',
    'Back',
    'Left Arm',
    'Right Arm',
    'Left Leg',
    'Right Leg',
  ];

  static int _areaSortOrder(String a, String b) {
    final ai = areas.indexOf(a);
    final bi = areas.indexOf(b);
    return ai.compareTo(bi);
  }

  static String formatAreas(Iterable<String> areas) {
    final sorted = areas.toList()..sort(_areaSortOrder);
    return sorted.join(', ');
  }

  String get _selectionLabel {
    if (selectedAreas.isEmpty) {
      return 'Tap a body area or choose below';
    }
    return 'Selected: ${formatAreas(selectedAreas)}';
  }

  @override
  Widget build(BuildContext context) {
    final hasSelection = selectedAreas.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          _selectionLabel,
          style: AppTypography.bodySecondary.copyWith(
            color: hasSelection ? AppColors.primary : null,
            fontWeight: hasSelection ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          height: 280,
          decoration: BoxDecoration(
            color: AppColors.highlight,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final size = Size(constraints.maxWidth, constraints.maxHeight);
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTapDown: (details) {
                    final area = _BodyDiagramPainter.regionAt(
                      details.localPosition,
                      size,
                    );
                    if (area != null) onAreaToggled(area);
                  },
                  child: CustomPaint(
                    size: size,
                    painter: _BodyDiagramPainter(
                      selectedAreas: selectedAreas,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: areas.map((area) {
            final selected = selectedAreas.contains(area);
            return Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => onAreaToggled(area),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.primary.withValues(alpha: 0.15)
                        : AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: selected ? AppColors.primary : AppColors.border,
                      width: selected ? 1.6 : 1.2,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (selected) ...[
                        const Icon(
                          Icons.check_circle,
                          size: 16,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 6),
                      ],
                      Text(
                        area,
                        style: AppTypography.body.copyWith(
                          fontSize: 13,
                          fontWeight:
                              selected ? FontWeight.w600 : FontWeight.w500,
                          color: selected
                              ? AppColors.primary
                              : AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _BodyPart {
  const _BodyPart(this.id, this.bounds);

  final String id;
  final Rect Function(Size size) bounds;
}

class _BodyDiagramPainter extends CustomPainter {
  _BodyDiagramPainter({required this.selectedAreas});

  final Set<String> selectedAreas;

  static const _baseFill = Color(0xFFB8E4EC);
  static const _baseStroke = Color(0xFF8EC5D0);

  static const _parts = <_BodyPart>[
    _BodyPart('Head', _headBounds),
    _BodyPart('Neck', _neckBounds),
    _BodyPart('Chest', _chestBounds),
    _BodyPart('Abdomen', _abdomenBounds),
    _BodyPart('Back', _backBounds),
    _BodyPart('Left Arm', _leftArmBounds),
    _BodyPart('Right Arm', _rightArmBounds),
    _BodyPart('Left Leg', _leftLegBounds),
    _BodyPart('Right Leg', _rightLegBounds),
  ];

  static Rect _headBounds(Size s) {
    final w = s.width * 0.2;
    final h = s.height * 0.13;
    return Rect.fromCenter(
      center: Offset(s.width * 0.5, s.height * 0.11),
      width: w,
      height: h,
    );
  }

  static Rect _neckBounds(Size s) {
    return Rect.fromCenter(
      center: Offset(s.width * 0.5, s.height * 0.2),
      width: s.width * 0.12,
      height: s.height * 0.05,
    );
  }

  static Rect _chestBounds(Size s) {
    return Rect.fromCenter(
      center: Offset(s.width * 0.5, s.height * 0.32),
      width: s.width * 0.34,
      height: s.height * 0.14,
    );
  }

  static Rect _abdomenBounds(Size s) {
    return Rect.fromCenter(
      center: Offset(s.width * 0.5, s.height * 0.46),
      width: s.width * 0.3,
      height: s.height * 0.12,
    );
  }

  static Rect _backBounds(Size s) {
    return Rect.fromCenter(
      center: Offset(s.width * 0.5, s.height * 0.38),
      width: s.width * 0.14,
      height: s.height * 0.28,
    );
  }

  static Rect _leftArmBounds(Size s) {
    return Rect.fromLTWH(
      s.width * 0.14,
      s.height * 0.24,
      s.width * 0.16,
      s.height * 0.28,
    );
  }

  static Rect _rightArmBounds(Size s) {
    return Rect.fromLTWH(
      s.width * 0.7,
      s.height * 0.24,
      s.width * 0.16,
      s.height * 0.28,
    );
  }

  static Rect _leftLegBounds(Size s) {
    return Rect.fromLTWH(
      s.width * 0.34,
      s.height * 0.54,
      s.width * 0.14,
      s.height * 0.36,
    );
  }

  static Rect _rightLegBounds(Size s) {
    return Rect.fromLTWH(
      s.width * 0.52,
      s.height * 0.54,
      s.width * 0.14,
      s.height * 0.36,
    );
  }

  static String? regionAt(Offset position, Size size) {
    // Prefer smaller / more specific regions first (arms, legs, neck, head).
    const order = [
      'Left Arm',
      'Right Arm',
      'Left Leg',
      'Right Leg',
      'Head',
      'Neck',
      'Back',
      'Chest',
      'Abdomen',
    ];
    for (final id in order) {
      final part = _parts.firstWhere((p) => p.id == id);
      if (part.bounds(size).contains(position)) return id;
    }
    return null;
  }

  @override
  void paint(Canvas canvas, Size size) {
    for (final part in _parts) {
      final rect = part.bounds(size);
      final selected = selectedAreas.contains(part.id);
      final fill = selected
          ? AppColors.primary.withValues(alpha: 0.55)
          : _baseFill;
      final stroke = selected ? AppColors.primary : _baseStroke;

      final radius = part.id == 'Head'
          ? Radius.elliptical(rect.width / 2, rect.height / 2)
          : const Radius.circular(10);

      final rrect = RRect.fromRectAndRadius(rect, radius);
      canvas.drawRRect(
        rrect,
        Paint()
          ..color = fill
          ..style = PaintingStyle.fill,
      );
      canvas.drawRRect(
        rrect,
        Paint()
          ..color = stroke
          ..style = PaintingStyle.stroke
          ..strokeWidth = selected ? 2.5 : 1.5,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _BodyDiagramPainter oldDelegate) {
    return oldDelegate.selectedAreas != selectedAreas;
  }
}
