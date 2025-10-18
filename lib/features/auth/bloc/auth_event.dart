import 'package:equatable/equatable.dart';
import '../../../core/user_type.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class AuthLoginRequested extends AuthEvent {
  final String username;
  final String password;
  final UserType userType;

  const AuthLoginRequested({
    required this.username,
    required this.password,
    required this.userType,
  });

  @override
  List<Object> get props => [username, password, userType];
}

class AuthRegistrationRequested extends AuthEvent {
  final String fullName;
  final String email;
  final String username;
  final String password;
  final UserType userType;
  final String company;
  final String? phoneNumber;

  const AuthRegistrationRequested({
    required this.fullName,
    required this.email,
    required this.username,
    required this.password,
    required this.userType,
    required this.company,
    this.phoneNumber,
  });

  @override
  List<Object> get props => [
        fullName,
        email,
        username,
        password,
        userType,
        company,
        phoneNumber ?? '',
      ];
}

class AuthAddUserRequested extends AuthEvent {
  final String fullName;
  final String email;
  final String username;
  final String password;
  final UserType userType;
  final String company;
  final String? phoneNumber;

  const AuthAddUserRequested({
    required this.fullName,
    required this.email,
    required this.username,
    required this.password,
    required this.userType,
    required this.company,
    this.phoneNumber,
  });

  @override
  List<Object> get props => [fullName, email, username, password, userType, company, phoneNumber ?? ''];
}

class AuthGetUsersRequested extends AuthEvent {
  const AuthGetUsersRequested();

  @override
  List<Object> get props => [];
}

class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}
