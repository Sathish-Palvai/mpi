import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mpi/app/dashboard/bloc/dashboard_event.dart';
import 'package:mpi/app/dashboard/bloc/dashboard_state.dart';
import '../../../services/api_service.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  DashboardBloc() : super(DashboardLoading()) {
    on<LoadDashboardData>(_onLoadDashboardData);
    on<SearchChanged>(_onSearchChanged);
  }

  Future<void> _onLoadDashboardData(
      LoadDashboardData event, Emitter<DashboardState> emit) async {
    try {
      // Use API service with userType to get the correct list data
      final participants = await ApiService.getParticipants(userType: event.userType);
      final users = await ApiService.getUsers();
      final resources = await ApiService.getResources();

      emit(DashboardLoaded(
        allParticipants: participants,
        allUsers: users,
        allResources: resources,
        filteredParticipants: participants,
        filteredUsers: users,
        filteredResources: resources,
      ));
    } catch (e) {
      emit(DashboardError('Failed to load data: ${e.toString()}'));
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
