import 'dart:convert';

import 'package:ecommerce_app/features/auth/data/models/user_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class AuthLocalGateway {
  Future<void> saveSession(UserModel user, String token);
  Future<(UserModel, String)?> getSession();
  Future<void> clearSession();
}

class AuthLocalGatewayImpl implements AuthLocalGateway {
  final FlutterSecureStorage secureStorage;
  static const _userKey = 'SECURE_USER';
  static const _tokenKey = 'SECURE_TOKEN';

  AuthLocalGatewayImpl({required this.secureStorage});

  @override
  Future<void> clearSession() async {
    await secureStorage.delete(key: _userKey);
    await secureStorage.delete(key: _tokenKey);
  }

  @override
  Future<(UserModel, String)?> getSession() async {
    final userJsonString = await secureStorage.read(key: _userKey);
    final token = await secureStorage.read(key: _tokenKey);

    if (userJsonString != null && token != null) {
      final user = UserModel.fromJson(jsonDecode(userJsonString));
      return (user, token);
    }
    return null;
  }

  @override
  Future<void> saveSession(UserModel user, String token) async {
    await secureStorage.write(key: _userKey, value: json.encode(user.toJson()));
    await secureStorage.write(key: _tokenKey, value: token);
  }
}