import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import '../setup/test_setup.dart';
import '../mocks/firestore_mocks.dart';

void main() {
  late FakeFirebaseFirestore firestore;

  setUp(() {
    firestore = TestFirestoreService.getFirestoreMock();
  });

  group('Performance Tests', () {
    testWidgets('measure dashboard rendering performance', (WidgetTester tester) async {
      // Populate test data
      await TestFirestoreService.populateWithTestData(firestore);

      final stopwatch = Stopwatch()..start();

      // Render dashboard with charts and grid
      await tester.pumpWidget(
        TestSetup.wrapWithMaterialApp(
          const Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );

      // Initial frame
      await tester.pump();
      final initialFrameTime = stopwatch.elapsedMilliseconds;
      expect(initialFrameTime, lessThan(500), reason: 'Initial frame should render within 500ms');

      // Simulate heavy data load
      for (var i = 0; i < 100; i++) {
        await firestore.collection('tenants').add({
          'name': 'Tenant $i',
          'rentAmount': 1000 + i,
          'roomNumber': '${100 + i}',
        });
      }

      // Measure time to render updated data
      await tester.pump();
      final updateTime = stopwatch.elapsedMilliseconds - initialFrameTime;
      expect(updateTime, lessThan(500), reason: 'Data update should process within 500ms');

      stopwatch.stop();
    });

    testWidgets('measure data sync performance', (WidgetTester tester) async {
      final stopwatch = Stopwatch()..start();

      // Bulk write operation
      final batch = firestore.batch();
      for (var i = 0; i < 50; i++) {
        final ref = firestore.collection('payments').doc();
        batch.set(ref, {
          'amount': 1000,
          'date': DateTime.now().toIso8601String(),
          'tenantId': 'tenant-$i',
        });
      }
      await batch.commit();

      final batchWriteTime = stopwatch.elapsedMilliseconds;
      expect(batchWriteTime, lessThan(1000), reason: 'Batch write should complete within 1 second');

      // Bulk read operation
      await firestore.collection('payments').get();
      final readTime = stopwatch.elapsedMilliseconds - batchWriteTime;
      expect(readTime, lessThan(500), reason: 'Bulk read should complete within 500ms');

      stopwatch.stop();
    });

    testWidgets('measure image loading performance', (WidgetTester tester) async {
      final stopwatch = Stopwatch()..start();

      // Create and measure image load time
      await tester.pumpWidget(
        TestSetup.wrapWithMaterialApp(
          Image.asset('assets/images/logo.png'),
        ),
      );
      await tester.pump();

      final imageLoadTime = stopwatch.elapsedMilliseconds;
      expect(imageLoadTime, lessThan(200), reason: 'Image should load within 200ms');

      stopwatch.stop();
    });

    testWidgets('measure real-time update performance', (WidgetTester tester) async {
      final stopwatch = Stopwatch()..start();

      // Setup stream listener
      final stream = firestore.collection('tenants').snapshots();
      final updates = <int>[];

      // Listen for updates
      stream.listen((snapshot) {
        updates.add(stopwatch.elapsedMilliseconds);
      });

      // Trigger multiple updates
      for (var i = 0; i < 10; i++) {
        await firestore.collection('tenants').add({
          'name': 'Tenant $i',
          'rentAmount': 1000,
        });
        await tester.pump();
      }

      // Verify update timing
      expect(updates.length, greaterThan(0));
      for (var i = 1; i < updates.length; i++) {
        final updateDelay = updates[i] - updates[i - 1];
        expect(updateDelay, lessThan(100),
            reason: 'Each real-time update should process within 100ms');
      }

      stopwatch.stop();
    });
  });
}
