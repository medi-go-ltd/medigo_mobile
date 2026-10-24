import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:medigo_mobile/theme/app_theme.dart';

enum BodyViewSide { front, back }

/// Diagram display mode: overview (both) or a focused single side.
enum BodyDiagramViewMode { both, front, back }

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

  /// For symptoms that don't sit in one place (fever, nausea, dizziness…).
  static const generalArea = 'Whole body / general';

  static const areas = [...primaryAreas, ...extraAreas, generalArea];

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
  BodyDiagramViewMode _viewMode = BodyDiagramViewMode.both;

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
        const SizedBox(height: 6),
        _GeneralAreaTile(
          selected: widget.selectedAreas.contains(
            BodyDiagramWidget.generalArea,
          ),
          onTap: () => _toggleArea(BodyDiagramWidget.generalArea),
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
                        assetPath: _assetForArea(area),
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
                'Tap where you feel it, even if it feels internal',
                style: AppTypography.bodySecondary.copyWith(fontSize: 14),
              ),
            ],
          ),
        ),
        _ViewToggle(
          viewMode: _viewMode,
          onChanged: (mode) => setState(() => _viewMode = mode),
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
      child: switch (_viewMode) {
        BodyDiagramViewMode.both => _buildBothViews(),
        BodyDiagramViewMode.front => _buildFocusedView(BodyViewSide.front),
        BodyDiagramViewMode.back => _buildFocusedView(BodyViewSide.back),
      },
    );
  }

  Widget _buildBothViews() {
    return Stack(
      children: [
        Row(
          children: [
            Expanded(
              child: _BodyImagePanel(
                side: BodyViewSide.front,
                gender: widget.gender,
                selectedAreas: widget.selectedAreas,
                onAreaToggled: _toggleArea,
              ),
            ),
            Expanded(
              child: _BodyImagePanel(
                side: BodyViewSide.back,
                gender: widget.gender,
                selectedAreas: widget.selectedAreas,
                onAreaToggled: _toggleArea,
              ),
            ),
          ],
        ),
        const Positioned(
          left: 0,
          right: 0,
          bottom: 10,
          child: IgnorePointer(
            child: _TapInstructionCompact(),
          ),
        ),
      ],
    );
  }

  Widget _buildFocusedView(BodyViewSide side) {
    return Stack(
      children: [
        Positioned.fill(
          child: _BodyImagePanel(
            side: side,
            gender: widget.gender,
            selectedAreas: widget.selectedAreas,
            onAreaToggled: _toggleArea,
          ),
        ),
        const Positioned(
          left: 0,
          right: 0,
          bottom: 10,
          child: IgnorePointer(
            child: _TapInstructionCompact(),
          ),
        ),
      ],
    );
  }
}

class _TapInstructionCompact extends StatelessWidget {
  const _TapInstructionCompact();

  @override
  Widget build(BuildContext context) {
    return Text(
      'Tap a body area · select multiple',
      textAlign: TextAlign.center,
      style: AppTypography.bodySecondary.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _BodyImagePanel extends StatefulWidget {
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
  State<_BodyImagePanel> createState() => _BodyImagePanelState();
}

class _BodyImagePanelState extends State<_BodyImagePanel> {
  static const double _minScale = 1.0;
  static const double _maxScale = 3.5;
  static const double _zoomStep = 0.35;

  final TransformationController _transform = TransformationController();
  double _scale = 1.0;

  @override
  void dispose() {
    _transform.dispose();
    super.dispose();
  }

  void _setScale(double next, {required Size viewport}) {
    final clamped = next.clamp(_minScale, _maxScale);
    if (clamped <= _minScale + 0.001) {
      _transform.value = Matrix4.identity();
      setState(() => _scale = _minScale);
      return;
    }

    // Scale around the viewport centre and keep the current pan when possible.
    final current = _transform.value.clone();
    final currentScale =
        current.getMaxScaleOnAxis().clamp(_minScale, _maxScale);
    final focalX = viewport.width / 2;
    final focalY = viewport.height / 2;
    final nextMatrix = Matrix4.identity()
      ..translateByDouble(focalX, focalY, 0, 1)
      ..scaleByDouble(clamped / currentScale, clamped / currentScale, 1, 1)
      ..translateByDouble(-focalX, -focalY, 0, 1)
      ..multiply(current);
    _transform.value = nextMatrix;
    setState(() => _scale = clamped);
  }

  void _zoomIn(Size viewport) =>
      _setScale(_scale + _zoomStep, viewport: viewport);

  void _zoomOut(Size viewport) =>
      _setScale(_scale - _zoomStep, viewport: viewport);

  void _resetZoom() {
    _transform.value = Matrix4.identity();
    setState(() => _scale = _minScale);
  }

  @override
  Widget build(BuildContext context) {
    final zones = _zonesForSide(widget.side, gender: widget.gender);
    final aspectRatio =
        _bodyAspectRatio(side: widget.side, gender: widget.gender);
    // Keep zoom on the outer edge so it sits in empty space, not on the legs.
    final controlsOnLeft = widget.side == BodyViewSide.front;
    return LayoutBuilder(
      builder: (context, constraints) {
        final container = Size(constraints.maxWidth, constraints.maxHeight);
        final figureSize = _fittedFigureSize(container, aspectRatio);
        return Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            Positioned.fill(
              child: InteractiveViewer(
                key: ValueKey('body-map-${widget.side.name}-viewer'),
                transformationController: _transform,
                minScale: _minScale,
                maxScale: _maxScale,
                panEnabled: _scale > 1.01,
                scaleEnabled: true,
                boundaryMargin: const EdgeInsets.all(48),
                clipBehavior: Clip.hardEdge,
                onInteractionEnd: (_) {
                  final scale = _transform.value.getMaxScaleOnAxis();
                  if ((scale - _scale).abs() > 0.01) {
                    setState(() => _scale = scale);
                  }
                },
                child: Center(
                  child: SizedBox(
                    width: figureSize.width,
                    height: figureSize.height,
                    child: GestureDetector(
                      key: ValueKey('body-map-${widget.side.name}-panel'),
                      behavior: HitTestBehavior.opaque,
                      onTapDown: (details) {
                        final normalized = Offset(
                          details.localPosition.dx / figureSize.width,
                          details.localPosition.dy / figureSize.height,
                        );
                        final area = _areaAtNormalized(
                          normalized,
                          zones,
                          _hitOrderForSide(widget.side),
                        );
                        if (area != null) widget.onAreaToggled(area);
                      },
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Positioned.fill(
                            child: Image.asset(
                              _bodyImageAsset(
                                side: widget.side,
                                gender: widget.gender,
                              ),
                              fit: BoxFit.fill,
                            ),
                          ),
                          ...zones
                              .where(
                                (zone) =>
                                    widget.selectedAreas.contains(zone.area),
                              )
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
                ),
              ),
            ),
            Positioned(
              top: 8,
              left: controlsOnLeft ? 4 : null,
              right: controlsOnLeft ? null : 4,
              child: _ZoomControls(
                onZoomIn: () => _zoomIn(container),
                onZoomOut: () => _zoomOut(container),
                onReset: _resetZoom,
                canZoomIn: _scale < _maxScale - 0.01,
                canZoomOut: _scale > _minScale + 0.01,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ZoomControls extends StatelessWidget {
  const _ZoomControls({
    required this.onZoomIn,
    required this.onZoomOut,
    required this.onReset,
    required this.canZoomIn,
    required this.canZoomOut,
  });

  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  final VoidCallback onReset;
  final bool canZoomIn;
  final bool canZoomOut;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface.withValues(alpha: 0.94),
      elevation: 2,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            key: const ValueKey('body-zoom-in'),
            tooltip: 'Zoom in',
            onPressed: canZoomIn ? onZoomIn : null,
            icon: const Icon(Icons.add, size: 20),
            visualDensity: VisualDensity.compact,
          ),
          IconButton(
            key: const ValueKey('body-zoom-out'),
            tooltip: 'Zoom out',
            onPressed: canZoomOut ? onZoomOut : null,
            icon: const Icon(Icons.remove, size: 20),
            visualDensity: VisualDensity.compact,
          ),
          IconButton(
            key: const ValueKey('body-zoom-reset'),
            tooltip: 'Reset zoom',
            onPressed: canZoomOut ? onReset : null,
            icon: const Icon(Icons.fit_screen_outlined, size: 18),
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
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

bool _isFemaleGender(String? gender) =>
    gender?.trim().toLowerCase() == 'female';

List<_BodyZone> _zonesForSide(BodyViewSide side, {String? gender}) {
  final isFemale = _isFemaleGender(gender);
  if (side == BodyViewSide.front) {
    return isFemale ? _femaleFrontZones : _maleFrontZones;
  }
  return isFemale ? _femaleBackZones : _maleBackZones;
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
  // Match assets/images/body_map/body_{front|back}_{male|female}.png
  if (isFemale) {
    return side == BodyViewSide.front ? 874 / 1800 : 849 / 1852;
  }
  return 1024 / 1536;
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

/// Tap/glow zones tuned to the 3D [body_front_male.png] / [body_back_male.png].
/// Front: patient's left = image right. Back: patient's left = image left.
final _maleFrontZones = [
  _bodyHeadZone('Head', 0.500, 0.085),
  _bodyZone('Throat', 0.500, 0.148, 0.038),
  _bodyZone('Neck', 0.500, 0.168, 0.042),
  _bodyZone('Left Shoulder', 0.675, 0.222, 0.062),
  _bodyZone('Right Shoulder', 0.322, 0.222, 0.062),
  _bodyZone('Chest', 0.500, 0.296, 0.090),
  _bodyZone('Abdomen', 0.500, 0.390, 0.080),
  _bodyZone('Pelvis', 0.500, 0.500, 0.078),
  _bodyZone('Left Arm', 0.722, 0.388, 0.050),
  _bodyZone('Right Arm', 0.276, 0.388, 0.050),
  _bodyZone('Left Elbow', 0.778, 0.462, 0.040),
  _bodyZone('Right Elbow', 0.221, 0.462, 0.040),
  _bodyZone('Left Wrist', 0.793, 0.526, 0.034),
  _bodyZone('Right Wrist', 0.196, 0.526, 0.034),
  _bodyZone('Left Hand', 0.793, 0.548, 0.042),
  _bodyZone('Right Hand', 0.206, 0.548, 0.042),
  _bodyZone('Left Hip', 0.580, 0.517, 0.050),
  _bodyZone('Right Hip', 0.419, 0.517, 0.050),
  _bodyLegZone('Left Leg', 0.588, 0.700, 0.048, 0.095),
  _bodyLegZone('Right Leg', 0.412, 0.700, 0.048, 0.095),
  _bodyZone('Left Knee', 0.607, 0.683, 0.046),
  _bodyZone('Right Knee', 0.393, 0.683, 0.046),
  _bodyAnkleZone('Left Ankle', 0.621, 0.849),
  _bodyAnkleZone('Right Ankle', 0.379, 0.849),
  _bodyFootZone('Left Foot', 0.630, 0.904, 0.055, 0.022),
  _bodyFootZone('Right Foot', 0.369, 0.904, 0.055, 0.022),
];

final _maleBackZones = [
  _bodyHeadZone('Head', 0.500, 0.080),
  _bodyZone('Neck', 0.500, 0.162, 0.042),
  _bodyZone('Left Shoulder', 0.315, 0.217, 0.062),
  _bodyZone('Right Shoulder', 0.684, 0.217, 0.062),
  _bodyZone('Upper Back', 0.500, 0.292, 0.090),
  _bodyZone('Lower Back', 0.500, 0.420, 0.072),
  _bodyZone('Pelvis', 0.500, 0.500, 0.080),
  _bodyZone('Left Arm', 0.267, 0.384, 0.050),
  _bodyZone('Right Arm', 0.732, 0.384, 0.050),
  _bodyZone('Left Elbow', 0.207, 0.458, 0.040),
  _bodyZone('Right Elbow', 0.792, 0.458, 0.040),
  _bodyZone('Left Wrist', 0.190, 0.523, 0.034),
  _bodyZone('Right Wrist', 0.817, 0.523, 0.034),
  _bodyZone('Left Hand', 0.191, 0.545, 0.042),
  _bodyZone('Right Hand', 0.808, 0.545, 0.042),
  _bodyZone('Left Hip', 0.421, 0.514, 0.050),
  _bodyZone('Right Hip', 0.578, 0.514, 0.050),
  _bodyLegZone('Left Leg', 0.411, 0.700, 0.048, 0.095),
  _bodyLegZone('Right Leg', 0.588, 0.700, 0.048, 0.095),
  _bodyZone('Left Knee', 0.395, 0.680, 0.046),
  _bodyZone('Right Knee', 0.604, 0.680, 0.046),
  _bodyAnkleZone('Left Ankle', 0.375, 0.847),
  _bodyAnkleZone('Right Ankle', 0.625, 0.847),
  _bodyFootZone('Left Foot', 0.367, 0.903, 0.055, 0.022),
  _bodyFootZone('Right Foot', 0.632, 0.903, 0.055, 0.022),
];

/// Tap/glow zones tuned to the 3D [body_front_female.png] / [body_back_female.png].
final _femaleFrontZones = [
  _bodyHeadZone('Head', 0.497, 0.084),
  _bodyZone('Throat', 0.496, 0.152, 0.036),
  _bodyZone('Neck', 0.495, 0.172, 0.040),
  _bodyZone('Left Shoulder', 0.690, 0.231, 0.060),
  _bodyZone('Right Shoulder', 0.300, 0.231, 0.060),
  _bodyZone('Chest', 0.494, 0.309, 0.088),
  _bodyZone('Abdomen', 0.495, 0.407, 0.078),
  _bodyZone('Pelvis', 0.493, 0.520, 0.076),
  _bodyZone('Left Arm', 0.739, 0.407, 0.050),
  _bodyZone('Right Arm', 0.249, 0.407, 0.050),
  _bodyZone('Left Elbow', 0.787, 0.485, 0.040),
  _bodyZone('Right Elbow', 0.201, 0.485, 0.040),
  _bodyZone('Left Wrist', 0.836, 0.554, 0.034),
  _bodyZone('Right Wrist', 0.149, 0.554, 0.034),
  _bodyZone('Left Hand', 0.839, 0.583, 0.042),
  _bodyZone('Right Hand', 0.147, 0.583, 0.042),
  _bodyZone('Left Hip', 0.605, 0.544, 0.050),
  _bodyZone('Right Hip', 0.381, 0.544, 0.050),
  _bodyLegZone('Left Leg', 0.603, 0.720, 0.050, 0.095),
  _bodyLegZone('Right Leg', 0.386, 0.720, 0.050, 0.095),
  _bodyZone('Left Knee', 0.593, 0.720, 0.046),
  _bodyZone('Right Knee', 0.396, 0.720, 0.046),
  _bodyAnkleZone('Left Ankle', 0.593, 0.896),
  _bodyAnkleZone('Right Ankle', 0.396, 0.896),
  _bodyFootZone('Left Foot', 0.589, 0.955, 0.050, 0.022),
  _bodyFootZone('Right Foot', 0.402, 0.955, 0.050, 0.022),
];

final _femaleBackZones = [
  _bodyHeadZone('Head', 0.494, 0.083),
  _bodyZone('Neck', 0.494, 0.170, 0.040),
  _bodyZone('Left Shoulder', 0.290, 0.228, 0.060),
  _bodyZone('Right Shoulder', 0.700, 0.228, 0.060),
  _bodyZone('Upper Back', 0.495, 0.305, 0.088),
  _bodyZone('Lower Back', 0.495, 0.430, 0.072),
  _bodyZone('Pelvis', 0.494, 0.520, 0.078),
  _bodyZone('Left Arm', 0.235, 0.402, 0.050),
  _bodyZone('Right Arm', 0.754, 0.402, 0.050),
  _bodyZone('Left Elbow', 0.184, 0.479, 0.040),
  _bodyZone('Right Elbow', 0.806, 0.479, 0.040),
  _bodyZone('Left Wrist', 0.134, 0.548, 0.034),
  _bodyZone('Right Wrist', 0.859, 0.548, 0.034),
  _bodyZone('Left Hand', 0.133, 0.576, 0.042),
  _bodyZone('Right Hand', 0.861, 0.576, 0.042),
  _bodyZone('Left Hip', 0.373, 0.538, 0.050),
  _bodyZone('Right Hip', 0.615, 0.538, 0.050),
  _bodyLegZone('Left Leg', 0.378, 0.710, 0.050, 0.095),
  _bodyLegZone('Right Leg', 0.609, 0.710, 0.050, 0.095),
  _bodyZone('Left Knee', 0.389, 0.712, 0.046),
  _bodyZone('Right Knee', 0.600, 0.712, 0.046),
  _bodyAnkleZone('Left Ankle', 0.382, 0.886),
  _bodyAnkleZone('Right Ankle', 0.605, 0.886),
  _bodyFootZone('Left Foot', 0.388, 0.944, 0.050, 0.022),
  _bodyFootZone('Right Foot', 0.598, 0.944, 0.050, 0.022),
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
    case 'Left Elbow':
      return 'assets/images/body_map/left_elbow.png';
    case 'Right Elbow':
      return 'assets/images/body_map/right_elbow.png';
    case 'Left Wrist':
      return 'assets/images/body_map/left_wrist.png';
    case 'Right Wrist':
      return 'assets/images/body_map/right_wrist.png';
    case 'Left Hand':
      return 'assets/images/body_map/left_hand.png';
    case 'Right Hand':
      return 'assets/images/body_map/right_hand.png';
    case 'Left Hip':
      return 'assets/images/body_map/left_hip.png';
    case 'Right Hip':
      return 'assets/images/body_map/right_hip.png';
    case 'Left Knee':
      return 'assets/images/body_map/left_knee.png';
    case 'Right Knee':
      return 'assets/images/body_map/right_knee.png';
    case 'Left Ankle':
      return 'assets/images/body_map/left_ankle.png';
    case 'Right Ankle':
      return 'assets/images/body_map/right_ankle.png';
    case 'Left Foot':
      return 'assets/images/body_map/left_foot.png';
    case 'Right Foot':
      return 'assets/images/body_map/right_foot.png';
    default:
      return 'assets/images/body_map/more.png';
  }
}

class _ViewToggle extends StatelessWidget {
  const _ViewToggle({required this.viewMode, required this.onChanged});

  final BodyDiagramViewMode viewMode;
  final ValueChanged<BodyDiagramViewMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 210,
      height: 38,
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      padding: const EdgeInsets.all(2),
      child: Row(
        children: [
          _toggleChip('Both', BodyDiagramViewMode.both),
          _toggleChip('Front', BodyDiagramViewMode.front),
          _toggleChip('Back', BodyDiagramViewMode.back),
        ],
      ),
    );
  }

  Widget _toggleChip(String label, BodyDiagramViewMode mode) {
    final selected = viewMode == mode;
    return Expanded(
      child: GestureDetector(
        onTap: () => onChanged(mode),
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
              fontSize: 12,
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

class _GeneralAreaTile extends StatelessWidget {
  const _GeneralAreaTile({required this.selected, required this.onTap});

  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final foreground = selected ? AppColors.surface : AppColors.textPrimary;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : AppColors.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected ? AppColors.primary : const Color(0xFFE5E7EB),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.accessibility_new_rounded,
                size: 26,
                color: selected ? AppColors.surface : _bodyMapIconColor,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Whole body / not in one place',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: foreground,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Fever, nausea, dizziness, tiredness…',
                      style: TextStyle(
                        fontSize: 12,
                        color: selected
                            ? AppColors.surface.withValues(alpha: 0.85)
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                selected ? Icons.check_circle : Icons.add_circle_outline,
                size: 20,
                color: selected ? AppColors.surface : _bodyMapIconColor,
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
              Image.asset(
                assetPath,
                width: 28,
                height: 28,
                fit: BoxFit.contain,
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
