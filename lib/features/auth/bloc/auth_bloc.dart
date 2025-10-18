import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import '../../../core/user_type.dart';
import '../services/soap_registration_service.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthAuthenticated? _currentUser;

  AuthBloc() : super(AuthInitial()) {
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthRegistrationRequested>(_onRegistrationRequested);
    on<AuthAddUserRequested>(_onAddUserRequested);
    on<AuthGetUsersRequested>(_onGetUsersRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
  }

  // Test users data - in a real app, this would be managed by a backend
  static final Map<String, Map<String, dynamic>> _testUsers = {
    'D027': {'password': 'password', 'userType': UserType.BSP},
    'C001': {'password': 'password', 'userType': UserType.TSO},
    'A001': {'password': 'password', 'userType': UserType.MO},
  };

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    try {
      // Validate credentials
      if (_testUsers.containsKey(event.username)) {
        final userData = _testUsers[event.username]!;
        if (userData['password'] == event.password &&
            userData['userType'] == event.userType) {
          _currentUser = AuthAuthenticated(
            username: event.username,
            userType: event.userType,
          );
          emit(_currentUser!);
        } else {
          emit(const AuthError(message: 'Invalid credentials or user type'));
        }
      } else {
        emit(const AuthError(message: 'User not found'));
      }
    } catch (e) {
      emit(AuthError(message: 'Login failed: ${e.toString()}'));
    }
  }

  Future<void> _onRegistrationRequested(
    AuthRegistrationRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      // Call SOAP registration service for backward compatibility
      final result = await SoapRegistrationService.addUser(
        fullName: event.fullName,
        email: event.email,
        username: event.username,
        password: event.password,
        userType: event.userType.name,
        company: event.company,
        phoneNumber: event.phoneNumber,
      );

      if (result['success'] == true) {
        // Store user data locally for demo purposes
        _testUsers[event.username] = {
          'password': event.password,
          'userType': event.userType,
          'fullName': event.fullName,
          'email': event.email,
          'company': event.company,
          'phoneNumber': event.phoneNumber,
          'userId': result['userId'],
          'registrationDate': result['timestamp'],
        };

        emit(AuthRegistrationSuccess(message: result['message']));
      } else {
        emit(AuthError(message: result['message']));
      }
    } catch (e) {
      emit(AuthError(message: 'Registration failed: ${e.toString()}'));
    }
  }

  Future<void> _onAddUserRequested(
    AuthAddUserRequested event,
    Emitter<AuthState> emit,
  ) async {
    // Emit loading state that maintains authentication
    if (_currentUser != null) {
      emit(AuthUsersLoading(
        username: _currentUser!.username,
        userType: _currentUser!.userType,
      ));
    } else {
      emit(AuthLoading());
    }
    
    try {
      final result = await SoapRegistrationService.addUser(
        fullName: event.fullName,
        email: event.email,
        username: event.username,
        password: event.password,
        userType: event.userType.name,
        company: event.company,
        phoneNumber: event.phoneNumber,
      );

      if (result['success'] == true) {
        emit(AuthUserAdded(
          message: result['message'],
          userId: result['userId'],
          timestamp: result['timestamp'],
          isDemoMode: result['demoMode'] ?? false,
          username: _currentUser?.username ?? 'unknown',
          userType: _currentUser?.userType ?? UserType.BSP,
        ));
      } else {
        // Use AuthOperationError instead of AuthError to maintain authentication
        if (_currentUser != null) {
          emit(AuthOperationError(
            message: result['message'] ?? 'Failed to add user',
            username: _currentUser!.username,
            userType: _currentUser!.userType,
          ));
        } else {
          emit(AuthError(message: result['message'] ?? 'Failed to add user'));
        }
      }
    } catch (e) {
      // Use AuthOperationError instead of AuthError to maintain authentication
      if (_currentUser != null) {
        emit(AuthOperationError(
          message: 'Error adding user: ${e.toString()}',
          username: _currentUser!.username,
          userType: _currentUser!.userType,
        ));
      } else {
        emit(AuthError(message: 'Error adding user: ${e.toString()}'));
      }
    }
  }

  Future<void> _onGetUsersRequested(
    AuthGetUsersRequested event,
    Emitter<AuthState> emit,
  ) async {
    print('DEBUG AuthBloc: _onGetUsersRequested called');
    // Emit loading state that maintains authentication
    if (_currentUser != null) {
      emit(AuthUsersLoading(
        username: _currentUser!.username,
        userType: _currentUser!.userType,
      ));
    } else {
      emit(AuthLoading());
    }
    
    try {
      print('DEBUG AuthBloc: Calling SoapRegistrationService.getUserList()');
      final result = await SoapRegistrationService.getUserList();
      print('DEBUG AuthBloc: getUserList result: $result');

      if (result['success'] == true) {
        final users = List<Map<String, dynamic>>.from(result['users']);
        print('DEBUG AuthBloc: Emitting AuthUsersLoaded with ${users.length} users');
        emit(AuthUsersLoaded(
          users: users,
          isDemoMode: result['demoMode'] ?? false,
          username: _currentUser?.username ?? 'unknown',
          userType: _currentUser?.userType ?? UserType.BSP,
        ));
      } else {
        print('DEBUG AuthBloc: getUserList failed: ${result['message']}');
        // Use AuthOperationError instead of AuthError to maintain authentication
        if (_currentUser != null) {
          emit(AuthOperationError(
            message: result['message'] ?? 'Failed to load users',
            username: _currentUser!.username,
            userType: _currentUser!.userType,
          ));
        } else {
          emit(AuthError(message: result['message'] ?? 'Failed to load users'));
        }
      }
    } catch (e) {
      print('DEBUG AuthBloc: Exception in _onGetUsersRequested: $e');
      // Use AuthOperationError instead of AuthError to maintain authentication
      if (_currentUser != null) {
        emit(AuthOperationError(
          message: 'Error loading users: ${e.toString()}',
          username: _currentUser!.username,
          userType: _currentUser!.userType,
        ));
      } else {
        emit(AuthError(message: 'Error loading users: ${e.toString()}'));
      }
    }
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    _currentUser = null;
    emit(AuthInitial());
  }
}
