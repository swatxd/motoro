import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MotoroApp());

    // Verify that the login screen renders branding text
    expect(find.textContaining('MOTORO'), findsWidgets);
  });
}
