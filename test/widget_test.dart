// This is a basic Flutter widget test for the Hamro Restro app.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:restrox/core/network/dio_client.dart';
import 'package:restrox/main.dart';

void main() {
  // flutter_secure_storage talks to the platform over a MethodChannel that
  // doesn't exist in the plain widget-test environment — without a mock
  // handler, AuthProvider.tryAutoLogin() hangs forever awaiting it. This
  // simulates "no session stored yet" so AppGate resolves to LoginScreen.
  const secureStorageChannel = MethodChannel('plugins.it_nomads.com/flutter_secure_storage');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      secureStorageChannel,
      (call) async => call.method == 'readAll' ? <String, String>{} : null,
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(secureStorageChannel, null);
  });

  testWidgets('Hamro Restro app loads and shows the login screen', (WidgetTester tester) async {
    // Build our app and trigger a frame. With no stored session, the app
    // gate should land on LoginScreen rather than the bottom-nav shell.
    await tester.pumpWidget(RestroXApp(dioClient: DioClient()));
    // AppGate resolves the stored-session check asynchronously — pump past
    // the loading spinner once that future settles.
    await tester.pumpAndSettle();

    expect(find.text('Hamro Restro'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Enter your email'), findsOneWidget);
    expect(find.text('Enter your password'), findsOneWidget);
  });
}
