import 'package:flutter_test/flutter_test.dart';
import 'package:real_estate_app/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const HoroazhonApp());
    await tester.pumpAndSettle();

    // Verify the app renders without errors
    expect(find.byType(HoroazhonApp), findsOneWidget);
  });
}
