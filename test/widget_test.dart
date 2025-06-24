// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_weather_app/main.dart';

void main() {
  group('Weather App Widget Tests', () {
    testWidgets('should initialize the application successfully',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(const MyApp());

      // Assert
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('should render MaterialApp widget',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(const MyApp());

      // Assert
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('should not throw errors during initialization',
        (WidgetTester tester) async {
      // Arrange & Act & Assert
      expect(() async {
        await tester.pumpWidget(const MyApp());
      }, isNot(throwsException));
    });
  });
}
