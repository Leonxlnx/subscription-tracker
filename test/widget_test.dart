// Basic widget test for Subscription Tracker app
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:subscription_tracker/main.dart';

void main() {
  testWidgets('App launches successfully', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const SubscriptionTrackerApp());

    // Verify the app is loaded
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
