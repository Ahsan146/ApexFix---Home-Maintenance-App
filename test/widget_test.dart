import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:ApexFix/main.dart';
import 'package:ApexFix/providers/app_provider.dart';

void main() {
  testWidgets('ApexFix customer app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AppProvider()),
        ],
        child: const ApexFixApp(),
      ),
    );
    expect(find.byType(ApexFixApp), findsOneWidget);
  });
}
