import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medigo_mobile/widgets/body_diagram_widget.dart';

void main() {
  testWidgets('highlights selected area on diagram and chips', (
    tester,
  ) async {
    String? selected = 'Chest';

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BodyDiagramWidget(
            selectedArea: selected,
            onAreaSelected: (area) => selected = area,
          ),
        ),
      ),
    );

    expect(find.text('Selected: Chest'), findsOneWidget);

    await tester.tap(find.text('Right Arm'));
    await tester.pump();

    expect(selected, 'Right Arm');
  });

  testWidgets('tap on diagram selects body region', (tester) async {
    String? selected;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BodyDiagramWidget(
            onAreaSelected: (area) => selected = area,
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

    expect(selected, 'Right Arm');
  });
}
