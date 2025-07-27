// This is a basic Flutter widget test for the STEM Prediction App.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:stem_prediction_app/main.dart';

void main() {
  testWidgets('STEM Prediction App loads correctly', (
    WidgetTester tester,
  ) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const STEMPredictionApp());

    // Wait for animations to complete
    await tester.pumpAndSettle();

    // Verify that the home screen loads with key elements.
    expect(
      find.text('Predict Female Graduation Rates in STEM'),
      findsOneWidget,
    );
    expect(find.text('Start Predicting'), findsOneWidget);
    expect(find.text('What can you predict?'), findsOneWidget);
  });

  testWidgets('Navigation to prediction screen works', (
    WidgetTester tester,
  ) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const STEMPredictionApp());
    await tester.pumpAndSettle();

    // Tap the Start Predicting button and navigate to prediction screen.
    await tester.tap(find.text('Start Predicting'));
    await tester.pumpAndSettle();

    // Verify that we've navigated to the prediction screen.
    expect(find.text('Year'), findsOneWidget);
    expect(find.text('Female Enrollment Percentage'), findsOneWidget);
    expect(find.text('Gender Gap Index'), findsOneWidget);
    expect(find.text('Country'), findsOneWidget);
    expect(find.text('STEM Field'), findsOneWidget);
    expect(find.text('Predict'), findsOneWidget);
  });

  testWidgets('App initializes without errors', (WidgetTester tester) async {
    // This is a basic smoke test to ensure the app can be built without errors
    await tester.pumpWidget(const STEMPredictionApp());

    // Just verify the app builds successfully
    expect(find.byType(STEMPredictionApp), findsOneWidget);
  });
}
