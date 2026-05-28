import 'dart:math' as math;

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

  // Ordered roughly head-to-toe so chips read naturally.
  static const areas = [
    'Head',
    'Throat',
    'Neck',
    'Left Shoulder',
    'Right Shoulder',
    'Chest',
    'Upper Back',
    'Left Arm',
    'Right Arm',
    'Left Elbow',
    'Right Elbow',
    'Abdomen',
    'Lower Back',
    'Pelvis',
    'Left Wrist',
    'Right Wrist',
    'Left Hand',
    'Right Hand',
    'Left Hip',
    'Right Hip',
    'Left Leg',
    'Right Leg',
    'Left Knee',
    'Right Knee',
    'Left Ankle',
    'Right Ankle',
    'Left Foot',
    'Right Foot',
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
          height: 320,
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
          spacing: 6,
          runSpacing: 6,
          children: areas.map((area) {
            final selected = selectedAreas.contains(area);
            return Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => onAreaToggled(area),
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.primary.withValues(alpha: 0.15)
                        : AppColors.surface,
                    borderRadius: BorderRadius.circular(18),
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
                          size: 14,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 4),
                      ],
                      Text(
                        area,
                        style: AppTypography.body.copyWith(
                          fontSize: 12,
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
  const _BodyPart(this.id, this.pathBuilder, {this.isJoint = false});

  final String id;
  final Path Function(Size size) pathBuilder;

  // Joints are small focal points (shoulders, elbows, hands, knees, etc.)
  // that overlay the main silhouette. They are invisible when unselected and
  // render as a prominent dot when selected.
  final bool isJoint;
}

class _BodyDiagramPainter extends CustomPainter {
  _BodyDiagramPainter({required this.selectedAreas});

  final Set<String> selectedAreas;

  static const _baseFill = Color(0xFFB8E4EC);
  static const _baseStroke = Color(0xFF6FB2BF);
  static const _accentStroke = Color(0xFF4A8B97);

  static const _parts = <_BodyPart>[
    // Silhouette shapes.
    _BodyPart('Head', _headPath),
    _BodyPart('Neck', _neckPath),
    _BodyPart('Chest', _chestPath),
    _BodyPart('Abdomen', _abdomenPath),
    _BodyPart('Upper Back', _upperBackPath),
    _BodyPart('Lower Back', _lowerBackPath),
    _BodyPart('Left Arm', _leftArmPath),
    _BodyPart('Right Arm', _rightArmPath),
    _BodyPart('Left Leg', _leftLegPath),
    _BodyPart('Right Leg', _rightLegPath),
    // Joints / focal points (rendered as overlay dots).
    _BodyPart('Throat', _throatPath, isJoint: true),
    _BodyPart('Left Shoulder', _leftShoulderPath, isJoint: true),
    _BodyPart('Right Shoulder', _rightShoulderPath, isJoint: true),
    _BodyPart('Left Elbow', _leftElbowPath, isJoint: true),
    _BodyPart('Right Elbow', _rightElbowPath, isJoint: true),
    _BodyPart('Left Wrist', _leftWristPath, isJoint: true),
    _BodyPart('Right Wrist', _rightWristPath, isJoint: true),
    _BodyPart('Left Hand', _leftHandPath, isJoint: true),
    _BodyPart('Right Hand', _rightHandPath, isJoint: true),
    _BodyPart('Pelvis', _pelvisPath, isJoint: true),
    _BodyPart('Left Hip', _leftHipPath, isJoint: true),
    _BodyPart('Right Hip', _rightHipPath, isJoint: true),
    _BodyPart('Left Knee', _leftKneePath, isJoint: true),
    _BodyPart('Right Knee', _rightKneePath, isJoint: true),
    _BodyPart('Left Ankle', _leftAnklePath, isJoint: true),
    _BodyPart('Right Ankle', _rightAnklePath, isJoint: true),
    _BodyPart('Left Foot', _leftFootPath, isJoint: true),
    _BodyPart('Right Foot', _rightFootPath, isJoint: true),
  ];

  // Z-order for rendering the silhouette (back to front). Joints are drawn
  // last as overlays in their own pass.
  static const _drawOrder = [
    'Left Arm',
    'Right Arm',
    'Chest',
    'Abdomen',
    'Upper Back',
    'Lower Back',
    'Left Leg',
    'Right Leg',
    'Neck',
    'Head',
  ];

  // Hit-test priority — small joints win over larger silhouette regions, then
  // limbs win over the torso.
  static const _hitOrder = [
    // Joints first (smallest, most specific).
    'Throat',
    'Left Shoulder',
    'Right Shoulder',
    'Left Elbow',
    'Right Elbow',
    'Left Wrist',
    'Right Wrist',
    'Left Hand',
    'Right Hand',
    'Left Hip',
    'Right Hip',
    'Pelvis',
    'Left Knee',
    'Right Knee',
    'Left Ankle',
    'Right Ankle',
    'Left Foot',
    'Right Foot',
    // Then medium-sized silhouette regions.
    'Head',
    'Neck',
    'Left Arm',
    'Right Arm',
    'Left Leg',
    'Right Leg',
    'Lower Back',
    'Upper Back',
    'Chest',
    'Abdomen',
  ];

  static Path _headPath(Size s) {
    final w = s.width;
    final h = s.height;
    return Path()..addOval(
      Rect.fromCenter(
        center: Offset(w * 0.5, h * 0.10),
        width: w * 0.15,
        height: h * 0.15,
      ),
    );
  }

  static Path _neckPath(Size s) {
    final w = s.width;
    final h = s.height;
    final cx = w * 0.5;
    final topY = h * 0.17;
    final botY = h * 0.22;
    final topHalf = w * 0.04;
    final botHalf = w * 0.055;
    return Path()
      ..moveTo(cx - topHalf, topY)
      ..quadraticBezierTo(cx, topY - h * 0.005, cx + topHalf, topY)
      ..lineTo(cx + botHalf, botY)
      ..lineTo(cx - botHalf, botY)
      ..close();
  }

  // Chest: rounded shoulders flaring out, tapering to the waist.
  static Path _chestPath(Size s) {
    final w = s.width;
    final h = s.height;
    final cx = w * 0.5;
    final neckBaseY = h * 0.22;
    final shoulderY = h * 0.275;
    final waistY = h * 0.45;
    final neckHalf = w * 0.055;
    final shoulderHalf = w * 0.17;
    final waistHalf = w * 0.13;

    return Path()
      ..moveTo(cx - neckHalf, neckBaseY)
      // Over the left shoulder cap.
      ..cubicTo(
        cx - shoulderHalf * 0.65, neckBaseY - h * 0.005,
        cx - shoulderHalf, neckBaseY,
        cx - shoulderHalf, shoulderY,
      )
      // Side of torso curving inward to the waist.
      ..cubicTo(
        cx - shoulderHalf, shoulderY + h * 0.04,
        cx - waistHalf, waistY - h * 0.05,
        cx - waistHalf, waistY,
      )
      ..lineTo(cx + waistHalf, waistY)
      ..cubicTo(
        cx + waistHalf, waistY - h * 0.05,
        cx + shoulderHalf, shoulderY + h * 0.04,
        cx + shoulderHalf, shoulderY,
      )
      ..cubicTo(
        cx + shoulderHalf, neckBaseY,
        cx + shoulderHalf * 0.65, neckBaseY - h * 0.005,
        cx + neckHalf, neckBaseY,
      )
      ..close();
  }

  // Abdomen: continues from chest waist down to hips.
  static Path _abdomenPath(Size s) {
    final w = s.width;
    final h = s.height;
    final cx = w * 0.5;
    final topY = h * 0.45;
    final botY = h * 0.555;
    final topHalf = w * 0.13;
    final hipHalf = w * 0.15;

    return Path()
      ..moveTo(cx - topHalf, topY)
      ..cubicTo(
        cx - topHalf, topY + h * 0.04,
        cx - hipHalf, botY - h * 0.04,
        cx - hipHalf, botY,
      )
      ..lineTo(cx + hipHalf, botY)
      ..cubicTo(
        cx + hipHalf, botY - h * 0.04,
        cx + topHalf, topY + h * 0.04,
        cx + topHalf, topY,
      )
      ..close();
  }

  // Upper back: slim spine indicator across the chest portion of the torso.
  static Path _upperBackPath(Size s) {
    final w = s.width;
    final h = s.height;
    final rect = Rect.fromCenter(
      center: Offset(w * 0.5, h * 0.345),
      width: w * 0.045,
      height: h * 0.19,
    );
    return Path()..addRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(w * 0.022)),
    );
  }

  // Lower back: slim spine indicator across the abdomen portion of the torso.
  static Path _lowerBackPath(Size s) {
    final w = s.width;
    final h = s.height;
    final rect = Rect.fromCenter(
      center: Offset(w * 0.5, h * 0.49),
      width: w * 0.045,
      height: h * 0.105,
    );
    return Path()..addRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(w * 0.022)),
    );
  }

  // Left arm: slim tapered limb with rounded shoulder cap and hand.
  static Path _leftArmPath(Size s) {
    final w = s.width;
    final h = s.height;

    // Shoulder cap — inner edge tucks under the chest.
    final shoulderInnerX = w * 0.305;
    final shoulderTopY = h * 0.245;
    final shoulderOuterX = w * 0.205;
    final shoulderCapY = h * 0.295;
    // Upper arm / elbow.
    final elbowOuterX = w * 0.19;
    final elbowInnerX = w * 0.26;
    final elbowY = h * 0.42;
    // Forearm / wrist.
    final wristOuterX = w * 0.205;
    final wristInnerX = w * 0.27;
    final wristY = h * 0.55;
    // Hand.
    final handBottomY = h * 0.585;
    final handBottomCx = w * 0.24;
    // Armpit (inner shoulder).
    final armpitX = w * 0.295;
    final armpitY = h * 0.33;

    return Path()
      ..moveTo(shoulderInnerX, shoulderTopY)
      // Up and over the shoulder cap (rounded deltoid).
      ..cubicTo(
        shoulderInnerX - w * 0.04, shoulderTopY - h * 0.015,
        shoulderOuterX + w * 0.015, shoulderTopY - h * 0.005,
        shoulderOuterX, shoulderCapY,
      )
      // Outer edge: shoulder -> elbow (slight inward taper).
      ..cubicTo(
        shoulderOuterX - w * 0.008, shoulderCapY + h * 0.05,
        elbowOuterX, elbowY - h * 0.05,
        elbowOuterX, elbowY,
      )
      // Outer edge: elbow -> wrist.
      ..cubicTo(
        elbowOuterX + w * 0.005, elbowY + h * 0.05,
        wristOuterX - w * 0.005, wristY - h * 0.04,
        wristOuterX, wristY,
      )
      // Hand: rounded bottom.
      ..cubicTo(
        wristOuterX, handBottomY - h * 0.003,
        handBottomCx - w * 0.025, handBottomY + h * 0.005,
        handBottomCx, handBottomY,
      )
      ..cubicTo(
        wristInnerX + w * 0.005, handBottomY + h * 0.003,
        wristInnerX + w * 0.005, handBottomY - h * 0.005,
        wristInnerX, wristY,
      )
      // Inner edge: wrist -> elbow.
      ..cubicTo(
        wristInnerX - w * 0.005, wristY - h * 0.04,
        elbowInnerX, elbowY + h * 0.05,
        elbowInnerX, elbowY,
      )
      // Inner edge: elbow -> armpit.
      ..cubicTo(
        elbowInnerX, elbowY - h * 0.06,
        armpitX - w * 0.005, armpitY + h * 0.04,
        armpitX, armpitY,
      )
      // Up into the chest/shoulder join.
      ..lineTo(shoulderInnerX, shoulderTopY)
      ..close();
  }

  static Path _rightArmPath(Size s) {
    return _mirrorPath(_leftArmPath(s), s.width);
  }

  // Left leg: slim tapered limb with knee, calf and a small foot pointing
  // forward (out to the left). Drawn in front of the abdomen so the inner gap
  // between the two legs is clearly visible.
  static Path _leftLegPath(Size s) {
    final w = s.width;
    final h = s.height;
    // Hip line — top of leg sits flush with abdomen bottom.
    final hipOuterX = w * 0.345;
    final hipInnerX = w * 0.485;
    final hipY = h * 0.555;
    // Knee.
    final kneeOuterX = w * 0.345;
    final kneeInnerX = w * 0.475;
    final kneeY = h * 0.755;
    // Ankle.
    final ankleOuterX = w * 0.37;
    final ankleInnerX = w * 0.455;
    final ankleY = h * 0.925;
    // Foot — small forward extension.
    final footBottomY = h * 0.955;
    final footHeelX = w * 0.365;
    final footToeX = w * 0.43;

    return Path()
      ..moveTo(hipOuterX, hipY)
      // Outer thigh -> knee (subtle taper).
      ..cubicTo(
        hipOuterX - w * 0.005, hipY + h * 0.05,
        kneeOuterX - w * 0.005, kneeY - h * 0.06,
        kneeOuterX, kneeY,
      )
      // Knee -> outer calf -> ankle.
      ..cubicTo(
        kneeOuterX + w * 0.008, kneeY + h * 0.05,
        ankleOuterX - w * 0.005, ankleY - h * 0.04,
        ankleOuterX, ankleY,
      )
      // Heel: small curve down to bottom of foot.
      ..cubicTo(
        ankleOuterX - w * 0.005, footBottomY - h * 0.005,
        footHeelX, footBottomY,
        footHeelX + w * 0.01, footBottomY,
      )
      // Bottom of foot to toe.
      ..lineTo(footToeX, footBottomY)
      // Top of foot back up to inner ankle.
      ..cubicTo(
        footToeX, footBottomY - h * 0.008,
        ankleInnerX + w * 0.01, ankleY + h * 0.005,
        ankleInnerX, ankleY,
      )
      // Inner calf -> knee.
      ..cubicTo(
        ankleInnerX + w * 0.005, ankleY - h * 0.04,
        kneeInnerX - w * 0.005, kneeY + h * 0.04,
        kneeInnerX, kneeY,
      )
      // Inner thigh -> hip.
      ..cubicTo(
        kneeInnerX, kneeY - h * 0.06,
        hipInnerX, hipY + h * 0.05,
        hipInnerX, hipY,
      )
      ..close();
  }

  static Path _rightLegPath(Size s) {
    return _mirrorPath(_leftLegPath(s), s.width);
  }

  // ----- Joints / focal points (rendered as overlay dots) ---------------

  // Joint hit/visual radius scales with the smaller dimension so it stays
  // proportional in both wide test layouts and square device layouts.
  static double _jointR(Size s, [double scale = 1.0]) {
    return math.min(s.width, s.height) * 0.035 * scale;
  }

  static Path _circleAt(Size s, double xFrac, double yFrac,
      [double rScale = 1.0]) {
    return Path()..addOval(
      Rect.fromCircle(
        center: Offset(s.width * xFrac, s.height * yFrac),
        radius: _jointR(s, rScale),
      ),
    );
  }

  static Path _throatPath(Size s) => _circleAt(s, 0.5, 0.20, 0.85);

  static Path _leftShoulderPath(Size s) => _circleAt(s, 0.27, 0.275, 1.15);
  static Path _rightShoulderPath(Size s) => _circleAt(s, 0.73, 0.275, 1.15);

  static Path _leftElbowPath(Size s) => _circleAt(s, 0.215, 0.435, 1.0);
  static Path _rightElbowPath(Size s) => _circleAt(s, 0.785, 0.435, 1.0);

  static Path _leftWristPath(Size s) => _circleAt(s, 0.235, 0.555, 0.9);
  static Path _rightWristPath(Size s) => _circleAt(s, 0.765, 0.555, 0.9);

  static Path _leftHandPath(Size s) => _circleAt(s, 0.245, 0.595, 1.05);
  static Path _rightHandPath(Size s) => _circleAt(s, 0.755, 0.595, 1.05);

  // Pelvis sits centered just below the abdomen, between the two hips.
  static Path _pelvisPath(Size s) => _circleAt(s, 0.5, 0.555, 1.1);

  static Path _leftHipPath(Size s) => _circleAt(s, 0.385, 0.575, 1.1);
  static Path _rightHipPath(Size s) => _circleAt(s, 0.615, 0.575, 1.1);

  static Path _leftKneePath(Size s) => _circleAt(s, 0.41, 0.755, 1.15);
  static Path _rightKneePath(Size s) => _circleAt(s, 0.59, 0.755, 1.15);

  static Path _leftAnklePath(Size s) => _circleAt(s, 0.42, 0.92, 0.9);
  static Path _rightAnklePath(Size s) => _circleAt(s, 0.58, 0.92, 0.9);

  static Path _leftFootPath(Size s) => _circleAt(s, 0.40, 0.95, 1.05);
  static Path _rightFootPath(Size s) => _circleAt(s, 0.60, 0.95, 1.05);

  static Path _mirrorPath(Path path, double width) {
    final matrix = Matrix4.identity()
      ..translateByDouble(width, 0.0, 0.0, 1.0)
      ..scaleByDouble(-1.0, 1.0, 1.0, 1.0);
    return path.transform(matrix.storage);
  }

  static String? regionAt(Offset position, Size size) {
    for (final id in _hitOrder) {
      final part = _parts.firstWhere((p) => p.id == id);
      if (part.pathBuilder(size).contains(position)) return id;
    }
    return null;
  }

  @override
  void paint(Canvas canvas, Size size) {
    // Pass 1: silhouette in z-order (arms, torso, legs, neck, head).
    for (final id in _drawOrder) {
      final part = _parts.firstWhere((p) => p.id == id);
      final path = part.pathBuilder(size);
      final selected = selectedAreas.contains(id);
      final fill = selected
          ? AppColors.primary.withValues(alpha: 0.55)
          : _baseFill;
      final stroke = selected ? AppColors.primary : _baseStroke;

      canvas.drawPath(
        path,
        Paint()
          ..color = fill
          ..style = PaintingStyle.fill
          ..isAntiAlias = true,
      );
      canvas.drawPath(
        path,
        Paint()
          ..color = stroke
          ..style = PaintingStyle.stroke
          ..strokeWidth = selected ? 2.5 : 1.4
          ..strokeJoin = StrokeJoin.round
          ..strokeCap = StrokeCap.round
          ..isAntiAlias = true,
      );
    }

    // Subtle anatomical details to reinforce the "human" silhouette.
    _drawAnatomyHints(canvas, size);

    // Pass 2: joint overlays. Only rendered when selected — keeps the
    // silhouette clean while still letting users see which joint is active.
    for (final part in _parts.where((p) => p.isJoint)) {
      if (!selectedAreas.contains(part.id)) continue;
      final path = part.pathBuilder(size);
      canvas.drawPath(
        path,
        Paint()
          ..color = AppColors.primary
          ..style = PaintingStyle.fill
          ..isAntiAlias = true,
      );
      canvas.drawPath(
        path,
        Paint()
          ..color = AppColors.surface
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.6
          ..isAntiAlias = true,
      );
    }
  }

  void _drawAnatomyHints(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final hintPaint = Paint()
      ..color = _accentStroke.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;

    // Collar line between neck and chest.
    final collar = Path()
      ..moveTo(w * 0.41, h * 0.245)
      ..quadraticBezierTo(w * 0.5, h * 0.265, w * 0.59, h * 0.245);
    canvas.drawPath(collar, hintPaint);

    // Waist crease at the chest/abdomen boundary.
    final waist = Path()
      ..moveTo(w * 0.37, h * 0.455)
      ..quadraticBezierTo(w * 0.5, h * 0.47, w * 0.63, h * 0.455);
    canvas.drawPath(waist, hintPaint);

    // Subtle inner-leg seam at the crotch line so the legs read as separate.
    final crotch = Path()
      ..moveTo(w * 0.5, h * 0.555)
      ..lineTo(w * 0.5, h * 0.58);
    canvas.drawPath(crotch, hintPaint);
  }

  @override
  bool shouldRepaint(covariant _BodyDiagramPainter oldDelegate) {
    return oldDelegate.selectedAreas != selectedAreas;
  }
}
