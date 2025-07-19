import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:villa_design/villa_design.dart';

import 'package:ecommerce_app/features/auth/presentation/screens/login_screen.dart';
import 'package:ecommerce_app/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:ecommerce_app/features/auth/presentation/providers/auth_providers.dart';

class MockAuthViewModel extends StateNotifier<AuthState> with Mock implements AuthViewModel {
  MockAuthViewModel(super.initialState);
}

void main() {
  late MockAuthViewModel mockAuthViewModel;

  Widget createWidgetUnderTest() {
    return ProviderScope(
      overrides: [
        authViewModelProvider.overrideWith((ref) => mockAuthViewModel),
      ],
      child: const MaterialApp(
        home: LoginScreen(),
      ),
    );
  }

  setUp(() {
    mockAuthViewModel = MockAuthViewModel(AuthState.initial());
  });

  group('LoginScreen', () {
    testWidgets('renders initial layout correctly', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.widgetWithText(VillaTextField, 'Username'), findsOneWidget);
      expect(find.widgetWithText(VillaTextField, 'Password'), findsOneWidget);
      expect(find.text('Login'), findsNWidgets(2));
      expect(find.text('Sign up'), findsOneWidget);
    });

    testWidgets('calls login on ViewModel when login button is tapped', (tester) async {
      when(() => mockAuthViewModel.login(any(), any())).thenAnswer((_) async {});

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.enterText(find.widgetWithText(VillaTextField, 'Username'), 'testuser');
      await tester.enterText(find.widgetWithText(VillaTextField, 'Password'), 'password');
      
      await tester.tap(find.widgetWithText(VillaElevatedButton, 'Login'));
      await tester.pump();

      verify(() => mockAuthViewModel.login('testuser', 'password')).called(1);
    });

    testWidgets('does not call login when state is loading', (tester) async {
      
      await tester.pumpWidget(createWidgetUnderTest());
      
      await tester.tap(find.text('Login').last);
      await tester.pump();

      verifyNever(() => mockAuthViewModel.login(any(), any()));
    });
  });
}
