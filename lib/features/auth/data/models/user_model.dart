import 'package:ecommerce_app/features/auth/domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.email,
    required super.username,
    required super.password,
    required super.firstName,
    required super.lastName,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      email: json['email'],
      password: json['password'],
      username: json['username'],
      firstName: json['name']['firstname'],
      lastName: json['name']['lastname'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'password' : password,
      'name': {
        'firstname': firstName,
        'lastname': lastName,
      },
    };
  }
}