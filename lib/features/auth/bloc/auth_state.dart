import 'package:equatable/equatable.dart';
import '../../../core/user_type.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final String username;
  final UserType userType;

  const AuthAuthenticated({
    required this.username,
    required this.userType,
  });

  @override
  List<Object> get props => [username, userType];
}

class AuthRegistrationSuccess extends AuthState {
  final String message;

  const AuthRegistrationSuccess({required this.message});

  @override
  List<Object> get props => [message];
}

class AuthUserAdded extends AuthAuthenticated {
  final String message;
  final String userId;
  final String timestamp;
  final bool isDemoMode;

  const AuthUserAdded({
    required this.message,
    required this.userId,
    required this.timestamp,
    this.isDemoMode = false,
    required String username,
    required UserType userType,
  }) : super(username: username, userType: userType);

  @override
  List<Object> get props => [...super.props, message, userId, timestamp, isDemoMode];
}

class AuthUsersLoaded extends AuthAuthenticated {
  final List<Map<String, dynamic>> users;
  final bool isDemoMode;

  const AuthUsersLoaded({
    required this.users,
    this.isDemoMode = false,
    required String username,
    required UserType userType,
  }) : super(username: username, userType: userType);

  @override
  List<Object> get props => [...super.props, users, isDemoMode];
}

class AuthUsersLoading extends AuthAuthenticated {
  const AuthUsersLoading({
    required String username,
    required UserType userType,
  }) : super(username: username, userType: userType);
}

class AuthOperationError extends AuthAuthenticated {
  final String message;

  const AuthOperationError({
    required this.message,
    required String username,
    required UserType userType,
  }) : super(username: username, userType: userType);

  @override
  List<Object> get props => [...super.props, message];
}

class AuthError extends AuthState {
  final String message;

  const AuthError({required this.message});

  @override
  List<Object> get props => [message];
}
