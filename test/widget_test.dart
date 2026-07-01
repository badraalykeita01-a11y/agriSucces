import 'package:flutter_test/flutter_test.dart';

import 'package:agrisucces/core/constants/app_constants.dart';
import 'package:agrisucces/main.dart';

void main() {
  testWidgets('Splash screen displays branding', (WidgetTester tester) async {
    await tester.pumpWidget(const AgriSuccesApp());
    await tester.pump();

    expect(find.text(AppConstants.appName), findsOneWidget);
    expect(find.text(AppConstants.appSlogan), findsOneWidget);

    await tester.pump(AppConstants.splashDuration);
    await tester.pump();
  });
}
