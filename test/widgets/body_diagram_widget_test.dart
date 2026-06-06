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
    // Upper skull on the front figure.
    final localTap = Offset(size.width * 0.50, size.height * 0.06);
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
    final localTap = Offset(size.width * 0.50, size.height * 0.09);
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
    // Mid-shin on the patient's left leg (image right).
    final localTap = Offset(size.width * 0.64, size.height * 0.80);
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
}

void _noop(String _) {}