import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

class TestSetup {
  static Future<void> setupFirebaseForTesting() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
  }

  static Widget wrapWithMaterialApp(Widget widget) {
    return MaterialApp(
      home: Scaffold(
        body: widget,
      ),
    );
  }

  static Widget wrapWithMaterialAppAndProvider(Widget widget, List<SingleChildWidget> providers) {
    return MultiProvider(
      providers: providers,
      child: MaterialApp(
        home: Scaffold(
          body: widget,
        ),
      ),
    );
  }
}

/// Helper function to pump widget with necessary wrappers
Future<void> pumpWidgetWithWrappers(WidgetTester tester, Widget widget) async {
  await tester.pumpWidget(TestSetup.wrapWithMaterialApp(widget));
  await tester.pumpAndSettle();
}

/// Helper function to pump widget with providers and necessary wrappers
Future<void> pumpWidgetWithProvidersAndWrappers(
  WidgetTester tester,
  Widget widget,
  List<SingleChildWidget> providers,
) async {
  await tester.pumpWidget(TestSetup.wrapWithMaterialAppAndProvider(widget, providers));
  await tester.pumpAndSettle();
}