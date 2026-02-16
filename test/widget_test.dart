import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weatherapp/main.dart';

void main() {
  testWidgets('WeatherApp renders without crashing', (tester) async {
    await tester.pumpWidget(const WeatherApp());
    // Verify the app loads with a search field
    expect(find.byType(TextField), findsOneWidget);
  });
}
