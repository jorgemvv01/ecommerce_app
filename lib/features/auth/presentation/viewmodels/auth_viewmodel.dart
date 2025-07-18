import 'package:ecommerce_app/core/usecases/usecase.dart';
import 'package:ecommerce_app/features/auth/domain/entities/user.dart';
import 'package:ecommerce_app/features/auth/domain/usescases/check_auth_status.dart';
import 'package:ecommerce_app/features/auth/domain/usescases/login_user.dart';
import 'package:ecommerce_app/features/auth/domain/usescases/logout_user.dart';
import 'package:ecommerce_app/features/auth/domain/usescases/register_user.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthState extends Equatable {
  final AuthStatus status;
  final User? user;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
  });

  factory AuthState.initial() => const AuthState();

  AuthState copyWith({
    AuthStatus? status,
    User? user,
    String? errorMessage,
    bool clearError = false,
    bool clearUser = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: clearUser ? null : user ?? this.user,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, user, errorMessage];
}

class AuthViewModel extends StateNotifier<AuthState> {
  final LoginUser _loginUser;
  final LogoutUser _logoutUser;
  final CheckAuthStatus _checkAuthStatus;
  final RegisterUser _registerUser;

  AuthViewModel(
    this._loginUser,
    this._logoutUser,
    this._checkAuthStatus,
    this._registerUser
  ) : super(AuthState.initial()) {
    checkAuthStatus();
  }

  Future<void> checkAuthStatus() async {
    final failureOrUser = await _checkAuthStatus(NoParams());
    failureOrUser.fold(
      (failure) => state = state.copyWith(status: AuthStatus.unauthenticated),
      (user) => state = state.copyWith(status: AuthStatus.authenticated, user: user),
    );
  }

  Future<void> login(String username, String password) async {
    if(username.trim().isEmpty || password.trim().isEmpty){
      state = state.copyWith(status: AuthStatus.error, errorMessage: 'All fields are required');
      return;
    }
    state = state.copyWith(status: AuthStatus.loading);
    final params = LoginParams(username: username, password: password);
    final failureOrUser = await _loginUser(params);

    failureOrUser.fold(
      (failure) {
        state = state.copyWith(status: AuthStatus.error, errorMessage: failure.message);
        state = state.copyWith(status: AuthStatus.unauthenticated);
      },
      (user) => state = state.copyWith(status: AuthStatus.authenticated, user: user, errorMessage: null),
    );
  }

  Future<void> logout() async {
    await _logoutUser(NoParams());
    state = state.copyWith(status: AuthStatus.unauthenticated, clearUser: true);
  }

  Future<void> register({
    required String email,
    required String username,
    required String password,
  }) async {
    
    state = state.copyWith(status: AuthStatus.loading);
    String validateResult = _validateForm([
      ('Email', email.trim()),
      ('Username', username.trim()),
      ('Password', password.trim())
    ]);
    if(validateResult.isNotEmpty) {
      state = state.copyWith(status: AuthStatus.error, errorMessage: validateResult);
      return;
    }

    state = state.copyWith(status: AuthStatus.loading);
    final params = RegisterParams(email: email, username: username, password: password);
    final failureOrUser = await _registerUser(params);

    failureOrUser.fold(
      (failure) => state = state.copyWith(status: AuthStatus.error, errorMessage: failure.message),
      (user) => state = state.copyWith(status: AuthStatus.authenticated, user: user, clearError: true),
    );
  }
  
  String _validateForm(List<(String, dynamic)> formInputs) {

    String errorInformation = '';
    const validationList = ['', 0, '[]'];
    for (final element in formInputs) {
      if (validationList.contains(element.$2)) {
        errorInformation = 'The following field is required: "${element.$1}"';
        break;
      }
    }
    return errorInformation;
  }
}