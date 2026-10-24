import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medigo_mobile/widgets/body_diagram_widget.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        child: child,
      ),
    ),
  );
}

void main() {
  testWidgets('highlights selected areas on diagram and grid tiles', (
    tester,
  ) async {
    final selected = <String>{'Chest'};

    await tester.pumpWidget(
      _wrap(
        BodyDiagramWidget(
          selectedAreas: selected,
          onAreaToggled: (area) {
            if (selected.contains(area)) {
              selected.remove(area);
            } else {
              selected.add(area);
            }
          },
        ),
      ),
    );

    expect(find.text('Selected areas (1)'), findsOneWidget);
    expect(find.text('Chest'), findsWidgets);

    await tester.ensureVisible(find.text('Right Arm'));
    await tester.tap(find.text('Right Arm'));
    await tester.pump();

    expect(selected, {'Chest', 'Right Arm'});
  });

  testWidgets('whole body tile toggles the general area', (tester) async {
    final selected = <String>{};

    await tester.pumpWidget(
      _wrap(
        BodyDiagramWidget(
          selectedAreas: selected,
          onAreaToggled: (area) {
            if (!selected.remove(area)) selected.add(area);
          },
        ),
      ),
    );

    final tile = find.text('Whole body / not in one place');
    await tester.ensureVisible(tile);
    await tester.tap(tile);
    await tester.pump();

    expect(selected, {BodyDiagramWidget.generalArea});
  });

  testWidgets('tapping selected chip deselects area', (tester) async {
    final selected = <String>{'Chest'};

    await tester.pumpWidget(
      _wrap(
        StatefulBuilder(
          builder: (context, setState) {
            return BodyDiagramWidget(
              selectedAreas: selected,
              onAreaToggled: (area) => setState(() {
                if (selected.contains(area)) {
                  selected.remove(area);
                } else {
                  selected.add(area);
                }
              }),
            );
          },
        ),
      ),
    );

    await tester.ensureVisible(find.byIcon(Icons.close));
    await tester.tap(find.byIcon(Icons.close));
    await tester.pump();

    expect(selected, isEmpty);
    expect(find.text('Selected areas'), findsNothing);
  });

  testWidgets('tap on diagram selects body region', (tester) async {
    String? toggled;

    await tester.pumpWidget(
      _wrap(
        BodyDiagramWidget(
          onAreaToggled: (area) => toggled = area,
        ),
      ),
    );
    await tester.pumpAndSettle();

    final diagramBox = tester.renderObject<RenderBox>(
      find.byKey(const ValueKey('body-map-front-panel')),
    );
    final size = diagramBox.size;
    // Face centre on the 3D front figure.
    final localTap = Offset(size.width * 0.50, size.height * 0.085);
    await tester.tapAt(diagramBox.localToGlobal(localTap));
    await tester.pump();

    expect(toggled, 'Head');
  });

  testWidgets('tap on female diagram selects head region', (tester) async {
    String? toggled;

    await tester.pumpWidget(
      _wrap(
        BodyDiagramWidget(
          gender: 'Female',
          onAreaToggled: (area) => toggled = area,
        ),
      ),
    );
    await tester.pumpAndSettle();

    final diagramBox = tester.renderObject<RenderBox>(
      find.byKey(const ValueKey('body-map-front-panel')),
    );
    final size = diagramBox.size;
    final localTap = Offset(size.width * 0.50, size.height * 0.084);
    await tester.tapAt(diagramBox.localToGlobal(localTap));
    await tester.pump();

    expect(toggled, 'Head');
  });

  testWidgets('tap on diagram selects leg region', (tester) async {
    String? toggled;

    await tester.pumpWidget(
      _wrap(
        SizedBox(
          width: 420,
          child: BodyDiagramWidget(
            onAreaToggled: (area) => toggled = area,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final diagramBox = tester.renderObject<RenderBox>(
      find.byKey(const ValueKey('body-map-front-panel')),
    );
    final size = diagramBox.size;
    // Shin on the patient's left leg (image right), below the knee hit zone.
    final localTap = Offset(size.width * 0.59, size.height * 0.78);
    await tester.tapAt(diagramBox.localToGlobal(localTap));
    await tester.pump();

    expect(toggled, 'Left Leg');
  });

  testWidgets('more areas opens extra body part picker', (tester) async {
    await tester.pumpWidget(
      _wrap(
        const BodyDiagramWidget(onAreaToggled: _noop),
      ),
    );

    expect(find.text('Left Elbow'), findsNothing);

    await tester.ensureVisible(find.text('More Areas'));
    await tester.tap(find.text('More Areas'));
    await tester.pumpAndSettle();

    expect(find.text('Left Elbow'), findsOneWidget);
    expect(find.text('Choose a more specific body area'), findsOneWidget);
  });

  testWidgets('zoom in control increases body map scale', (tester) async {
    await tester.pumpWidget(
      _wrap(
        const BodyDiagramWidget(onAreaToggled: _noop),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('body-zoom-in')), findsWidgets);

    await tester.tap(find.byKey(const ValueKey('body-zoom-in')).first);
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('body-zoom-out')), findsWidgets);
    expect(find.byKey(const ValueKey('body-zoom-reset')), findsWidgets);
  });

  testWidgets('view toggle defaults to both and can focus one side', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        const BodyDiagramWidget(onAreaToggled: _noop),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('body-map-front-panel')), findsOneWidget);
    expect(find.byKey(const ValueKey('body-map-back-panel')), findsOneWidget);

    await tester.tap(find.text('Front'));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('body-map-front-panel')), findsOneWidget);
    expect(find.byKey(const ValueKey('body-map-back-panel')), findsNothing);

    await tester.tap(find.text('Back'));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('body-map-front-panel')), findsNothing);
    expect(find.byKey(const ValueKey('body-map-back-panel')), findsOneWidget);

    await tester.tap(find.text('Both'));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('body-map-front-panel')), findsOneWidget);
    expect(find.byKey(const ValueKey('body-map-back-panel')), findsOneWidget);
  });
}

void _noop(String _) {}