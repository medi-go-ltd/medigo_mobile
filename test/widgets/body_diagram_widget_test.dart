import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medigo_mobile/widgets/body_diagram_widget.dart';

void main() {
  testWidgets('highlights selected areas on diagram and chips', (
    tester,
  ) async {
    final selected = <String>{'Chest'};

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BodyDiagramWidget(
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
      ),
    );

    expect(find.text('Selected: Chest'), findsOneWidget);

    await tester.tap(find.text('Right Arm'));
    await tester.pump();

    expect(selected, {'Chest', 'Right Arm'});
  });

  testWidgets('tapping selected chip deselects area', (tester) async {
    final selected = <String>{'Chest'};

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
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
      ),
    );

    await tester.tap(find.text('Chest'));
    await tester.pump();

    expect(selected, isEmpty);
    expect(find.text('Tap a body area or choose below'), findsOneWidget);
  });

  testWidgets('tap on diagram selects body region', (tester) async {
    String? toggled;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BodyDiagramWidget(
            onAreaToggled: (area) => toggled = area,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final diagramBox = tester.renderObject<RenderBox>(
      find.descendant(
        of: find.byType(BodyDiagramWidget),
        matching: find.byType(CustomPaint),
      ),
    );
    final size = diagramBox.size;
    // Matches _rightArmBounds center: x 0.7 + 8% width, y 0.24 + 14% height.
    final localTap = Offset(size.width * 0.78, size.height * 0.38);
    await tester.tapAt(diagramBox.localToGlobal(localTap));
    await tester.pump();

    expect(toggled, 'Right Arm');
  });
}
