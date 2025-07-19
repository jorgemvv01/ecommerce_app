import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ecommerce_app/features/support/presentation/screens/support_screen.dart';
import 'package:villa_design/villa_design.dart';

void main() {
  Widget createWidgetUnderTest() {
    return const MaterialApp(
      home: SupportScreen(),
    );
  }

  group('SupportScreen', () {
    testWidgets('renders all contact information correctly', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Support & contact'), findsOneWidget);
      expect(find.text('Get in touch'), findsOneWidget);

      expect(find.widgetWithText(VillaActionCard, 'Email support'), findsOneWidget);
      expect(find.widgetWithText(VillaActionCard, 'Phone support'), findsOneWidget);
      expect(find.widgetWithText(VillaActionCard, 'Live chat'), findsOneWidget);

      expect(find.text('support@ecommerceapp.com'), findsOneWidget);
      expect(find.text('+1 (800) 555-0199'), findsOneWidget);
      expect(find.text('Available 24/7 on our website'), findsOneWidget);
    });
  });
}
