import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/main.dart';
import 'package:mobile/widgets/common/cinematic_bottom_nav.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('CascadeSimulatorApp renders bottom nav tabs and page view', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const CascadeSimulatorApp());
    await tester.pump();

    // Verify Nav bar and Hero on Intro tab
    expect(find.text('CASCADE SIMULATOR'), findsOneWidget);
    expect(find.text('WHEN ONE SYSTEM FAILS,\nTHE CITY FOLLOWS.'), findsOneWidget);
    expect(find.text('ENTER SIMULATOR'), findsOneWidget);

    // Verify Bottom Nav widget is present
    expect(find.byType(CinematicBottomNav), findsOneWidget);

    // Tap on NETWORK in Bottom Nav
    final networkTab = find.descendant(
      of: find.byType(CinematicBottomNav),
      matching: find.text('NETWORK'),
    );
    expect(networkTab, findsOneWidget);
    await tester.tap(networkTab);
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('TOPOLOGY GRAPH'), findsOneWidget);

    // Tap on SIMULATE in Bottom Nav
    final simulateTab = find.descendant(
      of: find.byType(CinematicBottomNav),
      matching: find.text('SIMULATE'),
    );
    expect(simulateTab, findsOneWidget);
    await tester.tap(simulateTab);
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('SIMULATOR CONFIGURATION'), findsOneWidget);

    // Tap on ANALYTICS in Bottom Nav
    final analyticsTab = find.descendant(
      of: find.byType(CinematicBottomNav),
      matching: find.text('ANALYTICS'),
    );
    expect(analyticsTab, findsOneWidget);
    await tester.tap(analyticsTab);
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('CASCADE ANALYTICS'), findsOneWidget);
  });
}
