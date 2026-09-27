import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/main.dart';
import 'package:flutter_app/screens/service_screen.dart';
import 'package:flutter_app/theme/app_theme.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MotoroApp());

    // Verify that the login screen renders branding text
    expect(find.textContaining('MOTORO'), findsWidgets);
  });

  testWidgets('ServiceScreen renders diagnostics, authorized centers and typography', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.reset());

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const ServiceScreen(),
      ),
    );

    // Initial frame and async load pump
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // Verify key titles and sections rendered
    expect(find.text('Service & Maintenance'), findsOneWidget);
    expect(find.text('Authorized Centers'), findsOneWidget);
    expect(find.text('Recommended Services'), findsOneWidget);
    expect(find.text('Service Records History'), findsOneWidget);
  });
}
