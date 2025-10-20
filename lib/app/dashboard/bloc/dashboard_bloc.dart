import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mpi/app/dashboard/bloc/dashboard_event.dart';
import 'package:mpi/app/dashboard/bloc/dashboard_state.dart';
import '../../../services/api_service.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  DashboardBloc() : super(DashboardLoading()) {
    on<LoadDashboardData>(_onLoadDashboardData);
    on<RefreshDashboardData>(_onRefreshDashboardData);
    on<SearchChanged>(_onSearchChanged);
  }

  Future<void> _onLoadDashboardData(
      LoadDashboardData event, Emitter<DashboardState> emit) async {
    try {
      print('>>> Loading dashboard data for userType: ${event.userType} (displayName: ${event.userType.displayName})');
      // Use API service with userType to get the correct list data
      final participants = await ApiService.getParticipants(userType: event.userType);
      final users = await ApiService.getUsersByUserType(event.userType.displayName);
      final resources = await ApiService.getResourcesByUserType(event.userType.displayName);

      print('>>> Dashboard data loaded: ${participants.length} participants, ${users.length} users, ${resources.length} resources');

      emit(DashboardLoaded(
        allParticipants: participants,
        allUsers: users,
        allResources: resources,
        filteredParticipants: participants,
        filteredUsers: users,
        filteredResources: resources,
      ));
    } catch (e) {
      print('>>> Error loading dashboard data: $e');
      print('>>> Stack trace: ${StackTrace.current}');
      emit(DashboardError('Failed to load data: ${e.toString()}'));
    }
  }

  Future<void> _onRefreshDashboardData(
      RefreshDashboardData event, Emitter<DashboardState> emit) async {
    try {
      print('>>> Refreshing dashboard data for userType: ${event.userType} (displayName: ${event.userType.displayName})');
      
      // Emit loading state to show refresh animation
      emit(DashboardLoading());
      
      // Use API service with userType to get the correct list data
      final participants = await ApiService.getParticipants(userType: event.userType);
      final users = await ApiService.getUsersByUserType(event.userType.displayName);
      final resources = await ApiService.getResourcesByUserType(event.userType.displayName);

      print('>>> Dashboard data refreshed: ${participants.length} participants, ${users.length} users, ${resources.length} resources');

      emit(DashboardLoaded(
        allParticipants: participants,
        allUsers: users,
        allResources: resources,
        filteredParticipants: participants,
        filteredUsers: users,
        filteredResources: resources,
      ));
    } catch (e) {
      print('>>> Error refreshing dashboard data: $e');
      print('>>> Stack trace: ${StackTrace.current}');
      emit(DashboardError('Failed to refresh data: ${e.toString()}'));
    }
  }

  void _onSearchChanged(SearchChanged event, Emitter<DashboardState> emit) {
    if (state is DashboardLoaded) {
      final currentState = state as DashboardLoaded;
      final query = event.query.toLowerCase();

      final filteredParticipants = currentState.allParticipants.where((p) {
        return p.values.any((v) => v.toString().toLowerCase().contains(query));
      }).toList();

      final filteredUsers = currentState.allUsers.where((u) {
        return u.values.any((v) => v.toString().toLowerCase().contains(query));
      }).toList();

      final filteredResources = currentState.allResources.where((r) {
        return r.values.any((v) => v.toString().toLowerCase().contains(query));
      }).toList();

      emit(currentState.copyWith(
        filteredParticipants: filteredParticipants,
        filteredUsers: filteredUsers,
        filteredResources: filteredResources,
        searchQuery: query,
      ));
    }
  }
}
