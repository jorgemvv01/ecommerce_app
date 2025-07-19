import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:villa_design/villa_design.dart';

import 'package:ecommerce_app/features/auth/presentation/screens/register_screen.dart';
import 'package:ecommerce_app/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:ecommerce_app/features/auth/presentation/providers/auth_providers.dart';
import 'package:ecommerce_app/core/widgets/custom_loading.dart';

class MockAuthViewModel extends StateNotifier<AuthState> with Mock implements AuthViewModel {
  MockAuthViewModel(super.initialState);
}

void main() {

  Widget createWidgetUnderTest({required MockAuthViewModel mock}) {
    return ProviderScope(
      overrides: [
        authViewModelProvider.overrideWith((ref) => mock),
      ],
      child: const MaterialApp(
        home: RegisterScreen(),
      ),
    );
  }


  group('RegisterScreen', () {
    testWidgets('renders initial layout correctly', (tester) async {
      final mockAuthViewModel = MockAuthViewModel(AuthState.initial());

      await tester.pumpWidget(createWidgetUnderTest(mock: mockAuthViewModel));

      expect(find.widgetWithText(VillaTextField, 'Email'), findsOneWidget);
      expect(find.widgetWithText(VillaTextField, 'Username'), findsOneWidget);
      expect(find.widgetWithText(VillaTextField, 'Password'), findsOneWidget);
      expect(find.text('Create'), findsOneWidget);
    });

    testWidgets('calls register on ViewModel when form is valid and button is tapped', (tester) async {
      final mockAuthViewModel = MockAuthViewModel(AuthState.initial());
      when(() => mockAuthViewModel.register(email: any(named: 'email'), username: any(named: 'username'), password: any(named: 'password'))).thenAnswer((_) async {});

      await tester.pumpWidget(createWidgetUnderTest(mock: mockAuthViewModel));
      
      await tester.enterText(find.widgetWithText(VillaTextField, 'Email'), 'test@test.com');
      await tester.enterText(find.widgetWithText(VillaTextField, 'Username'), 'testuser');
      await tester.enterText(find.widgetWithText(VillaTextField, 'Password'), 'password123');
      
      await tester.tap(find.text('Create'));
      await tester.pump();

      verify(() => mockAuthViewModel.register(email: 'test@test.com', username: 'testuser', password: 'password123')).called(1);
    });

    testWidgets('shows loading indicator when state is loading', (tester) async {
      final mockAuthViewModel = MockAuthViewModel(const AuthState(status: AuthStatus.loading));

      await tester.pumpWidget(createWidgetUnderTest(mock: mockAuthViewModel));

      expect(find.byType(CustomLoading), findsOneWidget);
      expect(find.byType(VillaTextField), findsNothing);
    });
  });
}
