import 'package:flutter_test/flutter_test.dart';
import 'package:technician_app/main.dart';

void main() {
  testWidgets('ApexFix Pro smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ApexFixProApp());
    expect(find.text('ApexFix Pro'), findsOneWidget);
  });
}
