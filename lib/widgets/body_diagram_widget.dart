import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:medigo_mobile/theme/app_theme.dart';

enum BodyViewSide { front, back }

const _bodyMapIconColor = Color(0xFF0B7F8E);

class BodyDiagramWidget extends StatefulWidget {
  const BodyDiagramWidget({
    super.key,
    this.selectedAreas = const {},
    this.gender,
    required this.onAreaToggled,
  });

  final Set<String> selectedAreas;
  final String? gender;
  final ValueChanged<String> onAreaToggled;

  static const primaryAreas = [
    'Head',
    'Throat',
    'Neck',
    'Left Shoulder',
    'Right Shoulder',
    'Chest',
    'Upper Back',
    'Lower Back',
    'Left Arm',
    'Right Arm',
    'Abdomen',
    'Pelvis',
    'Left Leg',
    'Right Leg',
  ];

  static const extraAreas = [
    'Left Elbow',
    'Right Elbow',
    'Left Wrist',
    'Right Wrist',
    'Left Hand',
    'Right Hand',
    'Left Hip',
    'Right Hip',
    'Left Knee',
    'Right Knee',
    'Left Ankle',
    'Right Ankle',
    'Left Foot',
    'Right Foot',
  ];

  static const areas = [...primaryAreas, ...extraAreas];

  static int _areaSortOrder(String a, String b) {
    final ai = areas.indexOf(a);
    final bi = areas.indexOf(b);
    return ai.compareTo(bi);
  }

  static String formatAreas(Iterable<String> areas) {
    final sorted = areas.toList()..sort(_areaSortOrder);
    return sorted.join(', ');
  }

  @override
  State<BodyDiagramWidget> createState() => _BodyDiagramWidgetState();
}

class _BodyDiagramWidgetState extends State<BodyDiagramWidget> {
  BodyViewSide _activeView = BodyViewSide.front;

  void _toggleArea(String area) {
    HapticFeedback.selectionClick();
    widget.onAreaToggled(area);
  }

  @override
  Widget build(BuildContext context) {
    final gridAreas = [
      ...BodyDiagramWidget.primaryAreas,
      '__more__',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildHeader(),
        const SizedBox(height: 12),
        _buildDiagramCard(),
        const SizedBox(height: 18),
        Text(
          'Or choose from the list',
          style: AppTypography.body.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 10),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 6,
            crossAxisSpacing: 6,
            childAspectRatio: 2.55,
          ),
          itemCount: gridAreas.length,
          itemBuilder: (context, index) {
            final area = gridAreas[index];
            if (area == '__more__') {
              return _MoreAreasTile(
                onTap: _showMoreAreaPicker,
              );
            }
            return _BodyAreaTile(
              label: area,
              assetPath: _assetForArea(area),
              selected: widget.selectedAreas.contains(area),
              onTap: () => _toggleArea(area),
            );
          },
        ),
        if (widget.selectedAreas.isNotEmpty) ...[
          const SizedBox(height: 16),
          _SelectedAreasBar(
            selectedAreas: widget.selectedAreas,
            onAreaToggled: _toggleArea,
          ),
        ],
      ],
    );
  }

  void _showMoreAreaPicker() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'More areas',
                    style: AppTypography.pageTitle.copyWith(fontSize: 22),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Choose a more specific body area',
                    style: AppTypography.bodySecondary,
                  ),
                  const SizedBox(height: 16),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 8,
                          crossAxisSpacing: 8,
                          childAspectRatio: 3.2,
                        ),
                    itemCount: BodyDiagramWidget.extraAreas.length,
                    itemBuilder: (context, index) {
                      final area = BodyDiagramWidget.extraAreas[index];
                      return _ExtraAreaTile(
                        label: area,
                        icon: _extraIconForArea(area),
                        selected: widget.selectedAreas.contains(area),
                        onTap: () {
                          _toggleArea(area);
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Where is the issue?',
                style: AppTypography.pageTitle.copyWith(fontSize: 22),
              ),
              const SizedBox(height: 2),
              Text(
                'Tap on the body or choose an area below',
                style: AppTypography.bodySecondary.copyWith(fontSize: 14),
              ),
            ],
          ),
        ),
        _ViewToggle(
          activeView: _activeView,
          onChanged: (view) => setState(() => _activeView = view),
        ),
      ],
    );
  }

  Widget _buildDiagramCard() {
    return Container(
      height: 370,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final showBoth = constraints.maxWidth >= 360;
          if (!showBoth) {
            return _BodyImagePanel(
              side: _activeView,
              gender: widget.gender,
              selectedAreas: widget.selectedAreas,
              onAreaToggled: _toggleArea,
            );
          }

          return Row(
            children: [
              Expanded(
                flex: 38,
                child: _BodyImagePanel(
                  side: BodyViewSide.front,
                  gender: widget.gender,
                  selectedAreas: widget.selectedAreas,
                  onAreaToggled: _toggleArea,
                ),
              ),
              SizedBox(
                width: 92,
                child: _TapInstruction(),
              ),
              Expanded(
                flex: 38,
                child: _BodyImagePanel(
                  side: BodyViewSide.back,
                  gender: widget.gender,
                  selectedAreas: widget.selectedAreas,
                  onAreaToggled: _toggleArea,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _TapInstruction extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          'assets/images/body_map/tap_body_area.png',
          width: 52,
          height: 52,
          fit: BoxFit.contain,
        ),
        const SizedBox(height: 12),
        Text(
          'Tap on a body\narea to select',
          textAlign: TextAlign.center,
          style: AppTypography.body.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            height: 1.18,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'You can select\nmultiple areas',
          textAlign: TextAlign.center,
          style: AppTypography.body.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            height: 1.18,
          ),
        ),
      ],
    );
  }
}

class _BodyImagePanel extends StatelessWidget {
  const _BodyImagePanel({
    required this.side,
    required this.gender,
    required this.selectedAreas,
    required this.onAreaToggled,
  });

  final BodyViewSide side;
  final String? gender;
  final Set<String> selectedAreas;
  final ValueChanged<String> onAreaToggled;

  @override
  Widget build(BuildContext context) {
    final zones = _zonesForSide(side);
    final aspectRatio = _bodyAspectRatio(side: side, gender: gender);
    return LayoutBuilder(
      builder: (context, constraints) {
        final container = Size(constraints.maxWidth, constraints.maxHeight);
        final figureSize = _fittedFigureSize(container, aspectRatio);
        return Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: figureSize.width,
              height: figureSize.height,
              child: GestureDetector(
                key: ValueKey('body-map-${side.name}-panel'),
                behavior: HitTestBehavior.opaque,
                onTapDown: (details) {
                  final normalized = Offset(
                    details.localPosition.dx / figureSize.width,
                    details.localPosition.dy / figureSize.height,
                  );
                  final area = _areaAtNormalized(
                    normalized,
                    zones,
                    _hitOrderForSide(side),
                  );
                  if (area != null) onAreaToggled(area);
                },
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned.fill(
                      child: Image.asset(
                        _bodyImageAsset(side: side, gender: gender),
                        fit: BoxFit.fill,
                      ),
                    ),
                    ...zones
                        .where((zone) => selectedAreas.contains(zone.area))
                        .map(
                          (zone) => _SelectionGlow(
                            zone: zone,
                            figureSize: figureSize,
                          ),
                        ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SelectionGlow extends StatelessWidget {
  const _SelectionGlow({required this.zone, required this.figureSize});

  final _BodyZone zone;
  final Size figureSize;

  @override
  Widget build(BuildContext context) {
    final glow = zone.glowRect;
    final isEllipse = (glow.width - glow.height).abs() > 0.001;
    return Positioned(
      left: glow.left * figureSize.width,
      top: glow.top * figureSize.height,
      width: glow.width * figureSize.width,
      height: glow.height * figureSize.height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: isEllipse ? BoxShape.rectangle : BoxShape.circle,
          borderRadius: isEllipse
              ? BorderRadius.all(
                  Radius.elliptical(
                    glow.width * figureSize.width / 2,
                    glow.height * figureSize.height / 2,
                  ),
                )
              : null,
          gradient: RadialGradient(
            colors: [
              AppColors.primary.withValues(alpha: 0.62),
              AppColors.primary.withValues(alpha: 0.30),
              AppColors.primary.withValues(alpha: 0.0),
            ],
            stops: const [0.0, 0.58, 1.0],
          ),
        ),
      ),
    );
  }
}

class _BodyZone {
  const _BodyZone(this.area, this.hitRect, this.glowRect);

  final String area;
  final Rect hitRect;
  final Rect glowRect;
}

List<_BodyZone> _zonesForSide(BodyViewSide side) {
  return side == BodyViewSide.front ? _frontZones : _backZones;
}

List<String> _hitOrderForSide(BodyViewSide side) {
  return side == BodyViewSide.front ? _frontHitOrder : _backHitOrder;
}

String _bodyImageAsset({required BodyViewSide side, String? gender}) {
  final normalizedGender = gender?.trim().toLowerCase();
  final genderFolder = normalizedGender == 'female' ? 'female' : 'male';
  final view = side == BodyViewSide.front ? 'front' : 'back';
  return 'assets/images/body_map/body_${view}_$genderFolder.png';
}

double _bodyAspectRatio({required BodyViewSide side, String? gender}) {
  final isFemale = gender?.trim().toLowerCase() == 'female';
  if (isFemale) {
    return side == BodyViewSide.front ? 265 / 545 : 250 / 545;
  }
  return side == BodyViewSide.front ? 285 / 555 : 275 / 555;
}

Size _fittedFigureSize(Size container, double aspectRatio) {
  final containerAspect = container.width / container.height;
  if (aspectRatio > containerAspect) {
    return Size(container.width, container.width / aspectRatio);
  }
  return Size(container.height * aspectRatio, container.height);
}

String? _areaAtNormalized(
  Offset normalized,
  List<_BodyZone> zones,
  List<String> hitOrder,
) {
  if (normalized.dx < 0 ||
      normalized.dx > 1 ||
      normalized.dy < 0 ||
      normalized.dy > 1) {
    return null;
  }

  final zonesByArea = {for (final zone in zones) zone.area: zone};
  for (final area in hitOrder) {
    final zone = zonesByArea[area];
    if (zone != null && _zoneHitContains(zone, normalized)) return area;
  }
  return null;
}

bool _zoneHitContains(_BodyZone zone, Offset point) {
  final rect = zone.hitRect;
  final center = rect.center;
  final rx = rect.width / 2;
  final ry = rect.height / 2;
  if (rx <= 0 || ry <= 0) return false;

  final dx = (point.dx - center.dx) / rx;
  final dy = (point.dy - center.dy) / ry;
  return (dx * dx) + (dy * dy) <= 1;
}

_BodyZone _bodyZone(String area, double cx, double cy, double radius) {
  final glow = Rect.fromCircle(center: Offset(cx, cy), radius: radius);
  return _BodyZone(area, glow, glow);
}

_BodyZone _bodyHeadZone(String area, double cx, double cy) {
  const glowRx = 0.048;
  const glowRy = 0.052;
  const hitRx = 0.052;
  const hitRy = 0.068;
  final glow = Rect.fromCenter(
    center: Offset(cx, cy),
    width: glowRx * 2,
    height: glowRy * 2,
  );
  final hit = Rect.fromCenter(
    center: Offset(cx, cy),
    width: hitRx * 2,
    height: hitRy * 2,
  );
  return _BodyZone(area, hit, glow);
}

_BodyZone _bodyLegZone(
  String area,
  double cx,
  double cy,
  double rx,
  double ry,
) {
  final glow = Rect.fromCenter(
    center: Offset(cx, cy),
    width: rx * 2,
    height: ry * 2,
  );
  return _BodyZone(area, glow, glow);
}

_BodyZone _bodyFootZone(
  String area,
  double cx,
  double cy,
  double rx,
  double ry,
) {
  final glow = Rect.fromCenter(
    center: Offset(cx, cy),
    width: rx * 2,
    height: ry * 2,
  );
  return _BodyZone(area, glow, glow);
}

_BodyZone _bodyAnkleZone(String area, double cx, double cy) {
  const glowRx = 0.038;
  const glowRy = 0.032;
  const hitRx = 0.042;
  const hitRy = 0.038;
  final glow = Rect.fromCenter(
    center: Offset(cx, cy),
    width: glowRx * 2,
    height: glowRy * 2,
  );
  final hit = Rect.fromCenter(
    center: Offset(cx, cy),
    width: hitRx * 2,
    height: hitRy * 2,
  );
  return _BodyZone(area, hit, glow);
}

const _frontHitOrder = [
  'Head',
  'Neck',
  'Throat',
  'Left Hand',
  'Right Hand',
  'Left Wrist',
  'Right Wrist',
  'Left Elbow',
  'Right Elbow',
  'Left Shoulder',
  'Right Shoulder',
  'Left Knee',
  'Right Knee',
  'Left Ankle',
  'Right Ankle',
  'Left Foot',
  'Right Foot',
  'Left Hip',
  'Right Hip',
  'Left Arm',
  'Right Arm',
  'Left Leg',
  'Right Leg',
  'Abdomen',
  'Pelvis',
  'Chest',
];

const _backHitOrder = [
  'Head',
  'Neck',
  'Left Hand',
  'Right Hand',
  'Left Wrist',
  'Right Wrist',
  'Left Elbow',
  'Right Elbow',
  'Left Shoulder',
  'Right Shoulder',
  'Left Knee',
  'Right Knee',
  'Left Ankle',
  'Right Ankle',
  'Left Foot',
  'Right Foot',
  'Left Hip',
  'Right Hip',
  'Left Arm',
  'Right Arm',
  'Left Leg',
  'Right Leg',
  'Lower Back',
  'Pelvis',
  'Upper Back',
];

final _frontZones = [
  _bodyHeadZone('Head', 0.540, 0.082),
  _bodyZone('Throat', 0.540, 0.182, 0.035),
  _bodyZone('Neck', 0.540, 0.151, 0.040),
  _bodyZone('Left Shoulder', 0.725, 0.211, 0.065),
  _bodyZone('Right Shoulder', 0.335, 0.211, 0.065),
  _bodyZone('Chest', 0.540, 0.297, 0.085),
  _bodyZone('Abdomen', 0.537, 0.395, 0.078),
  _bodyZone('Pelvis', 0.535, 0.502, 0.076),
  _bodyZone('Left Arm', 0.814, 0.432, 0.055),
  _bodyZone('Right Arm', 0.263, 0.432, 0.055),
  _bodyZone('Left Elbow', 0.839, 0.481, 0.042),
  _bodyZone('Right Elbow', 0.235, 0.481, 0.042),
  _bodyZone('Left Wrist', 0.889, 0.559, 0.035),
  _bodyZone('Right Wrist', 0.181, 0.559, 0.035),
  _bodyZone('Left Hand', 0.665, 0.647, 0.045),
  _bodyZone('Right Hand', 0.409, 0.647, 0.045),
  _bodyZone('Left Hip', 0.620, 0.550, 0.052),
  _bodyZone('Right Hip', 0.455, 0.550, 0.052),
  _bodyLegZone('Left Leg', 0.640, 0.748, 0.050, 0.100),
  _bodyLegZone('Right Leg', 0.419, 0.748, 0.050, 0.100),
  _bodyZone('Left Knee', 0.640, 0.705, 0.048),
  _bodyZone('Right Knee', 0.419, 0.705, 0.048),
  _bodyAnkleZone('Left Ankle', 0.654, 0.879),
  _bodyAnkleZone('Right Ankle', 0.418, 0.879),
  _bodyFootZone('Left Foot', 0.651, 0.955, 0.055, 0.020),
  _bodyFootZone('Right Foot', 0.421, 0.955, 0.055, 0.020),
];

final _backZones = [
  _bodyHeadZone('Head', 0.459, 0.082),
  _bodyZone('Neck', 0.458, 0.151, 0.040),
  _bodyZone('Left Shoulder', 0.248, 0.211, 0.065),
  _bodyZone('Right Shoulder', 0.665, 0.211, 0.065),
  _bodyZone('Upper Back', 0.460, 0.297, 0.088),
  _bodyZone('Lower Back', 0.459, 0.452, 0.072),
  _bodyZone('Pelvis', 0.459, 0.508, 0.080),
  _bodyZone('Left Arm', 0.165, 0.432, 0.055),
  _bodyZone('Right Arm', 0.753, 0.432, 0.055),
  _bodyZone('Left Elbow', 0.778, 0.481, 0.042),
  _bodyZone('Right Elbow', 0.142, 0.481, 0.042),
  _bodyZone('Left Wrist', 0.831, 0.559, 0.035),
  _bodyZone('Right Wrist', 0.089, 0.559, 0.035),
  _bodyZone('Left Hand', 0.320, 0.645, 0.045),
  _bodyZone('Right Hand', 0.589, 0.645, 0.045),
  _bodyZone('Left Hip', 0.380, 0.548, 0.052),
  _bodyZone('Right Hip', 0.545, 0.548, 0.052),
  _bodyLegZone('Left Leg', 0.333, 0.748, 0.050, 0.098),
  _bodyLegZone('Right Leg', 0.567, 0.748, 0.050, 0.098),
  _bodyZone('Left Knee', 0.342, 0.723, 0.048),
  _bodyZone('Right Knee', 0.565, 0.723, 0.048),
  _bodyAnkleZone('Left Ankle', 0.325, 0.877),
  _bodyAnkleZone('Right Ankle', 0.578, 0.877),
  _bodyFootZone('Left Foot', 0.252, 0.958, 0.072, 0.018),
  _bodyFootZone('Right Foot', 0.580, 0.958, 0.072, 0.018),
];

String _assetForArea(String area) {
  switch (area) {
    case 'Head':
      return 'assets/images/body_map/head.png';
    case 'Throat':
      return 'assets/images/body_map/throat.png';
    case 'Neck':
      return 'assets/images/body_map/neck.png';
    case 'Left Shoulder':
      return 'assets/images/body_map/left_shoulder.png';
    case 'Right Shoulder':
      return 'assets/images/body_map/right_shoulder.png';
    case 'Chest':
      return 'assets/images/body_map/chest.png';
    case 'Upper Back':
      return 'assets/images/body_map/upper_back.png';
    case 'Lower Back':
      return 'assets/images/body_map/lower_back.png';
    case 'Left Arm':
      return 'assets/images/body_map/left_arm.png';
    case 'Right Arm':
      return 'assets/images/body_map/right_arm.png';
    case 'Abdomen':
      return 'assets/images/body_map/abdomen.png';
    case 'Pelvis':
      return 'assets/images/body_map/pelvis.png';
    case 'Left Leg':
      return 'assets/images/body_map/left_leg.png';
    case 'Right Leg':
      return 'assets/images/body_map/right_leg.png';
    default:
      return 'assets/images/body_map/more.png';
  }
}

class _ViewToggle extends StatelessWidget {
  const _ViewToggle({required this.activeView, required this.onChanged});

  final BodyViewSide activeView;
  final ValueChanged<BodyViewSide> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 176,
      height: 38,
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      padding: const EdgeInsets.all(2),
      child: Row(
        children: [
          _toggleChip('Front', BodyViewSide.front),
          _toggleChip('Back', BodyViewSide.back),
        ],
      ),
    );
  }

  Widget _toggleChip(String label, BodyViewSide side) {
    final selected = activeView == side;
    return Expanded(
      child: GestureDetector(
        onTap: () => onChanged(side),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? AppColors.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: selected ? AppColors.primary : AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

class _BodyAreaTile extends StatelessWidget {
  const _BodyAreaTile({
    required this.label,
    required this.assetPath,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String assetPath;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : AppColors.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected ? AppColors.primary : const Color(0xFFE5E7EB),
            ),
          ),
          child: Row(
            children: [
              Image.asset(
                assetPath,
                width: 30,
                height: 30,
                fit: BoxFit.contain,
                color: selected ? AppColors.surface : _bodyMapIconColor,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    height: 1.12,
                    color: selected ? AppColors.surface : AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MoreAreasTile extends StatelessWidget {
  const _MoreAreasTile({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Row(
            children: [
              Image.asset(
                'assets/images/body_map/more.png',
                width: 30,
                height: 30,
                fit: BoxFit.contain,
                color: _bodyMapIconColor,
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'More Areas',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    height: 1.12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExtraAreaTile extends StatelessWidget {
  const _ExtraAreaTile({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? AppColors.primary : const Color(0xFFE5E7EB),
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 22,
                color: selected ? AppColors.surface : _bodyMapIconColor,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: selected ? AppColors.surface : AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

IconData _extraIconForArea(String area) {
  if (area.contains('Elbow')) return Icons.linear_scale_rounded;
  if (area.contains('Wrist')) return Icons.horizontal_rule_rounded;
  if (area.contains('Hand')) return Icons.back_hand_outlined;
  if (area.contains('Hip')) return Icons.accessibility_new_rounded;
  if (area.contains('Knee')) return Icons.expand_more_rounded;
  if (area.contains('Ankle')) return Icons.more_horiz_rounded;
  if (area.contains('Foot')) return Icons.directions_walk_rounded;
  return Icons.add_circle_outline_rounded;
}

class _SelectedAreasBar extends StatelessWidget {
  const _SelectedAreasBar({
    required this.selectedAreas,
    required this.onAreaToggled,
  });

  final Set<String> selectedAreas;
  final ValueChanged<String> onAreaToggled;

  @override
  Widget build(BuildContext context) {
    final sortedAreas = selectedAreas.toList()
      ..sort(BodyDiagramWidget._areaSortOrder);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Text(
            'Selected areas (${selectedAreas.length})',
            style: AppTypography.body.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Wrap(
              alignment: WrapAlignment.end,
              spacing: 8,
              runSpacing: 6,
              children: sortedAreas
                  .map(
                    (area) => _SelectedAreaChip(
                      label: area,
                      onRemove: () => onAreaToggled(area),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _SelectedAreaChip extends StatelessWidget {
  const _SelectedAreaChip({required this.label, required this.onRemove});

  final String label;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FFFF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.55)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: AppTypography.body.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: onRemove,
            child: Icon(
              Icons.close,
              size: 14,
              color: AppColors.primary.withValues(alpha: 0.85),
            ),
          ),
        ],
      ),
    );
  }
}
