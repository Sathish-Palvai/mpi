import 'package:equatable/equatable.dart';

abstract class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object> get props => [];
}

class DashboardLoading extends DashboardState {}

class DashboardLoaded extends DashboardState {
  final List<Map<String, dynamic>> allParticipants;
  final List<Map<String, dynamic>> allUsers;
  final List<Map<String, dynamic>> allResources;
  final List<Map<String, dynamic>> filteredParticipants;
  final List<Map<String, dynamic>> filteredUsers;
  final List<Map<String, dynamic>> filteredResources;
  final String searchQuery;

  const DashboardLoaded({
    required this.allParticipants,
    required this.allUsers,
    required this.allResources,
    required this.filteredParticipants,
    required this.filteredUsers,
    required this.filteredResources,
    this.searchQuery = '',
  });

  @override
  List<Object> get props => [
        allParticipants,
        allUsers,
        allResources,
        filteredParticipants,
        filteredUsers,
        filteredResources,
        searchQuery,
      ];

  DashboardLoaded copyWith({
    List<Map<String, dynamic>>? allParticipants,
    List<Map<String, dynamic>>? allUsers,
    List<Map<String, dynamic>>? allResources,
    List<Map<String, dynamic>>? filteredParticipants,
    List<Map<String, dynamic>>? filteredUsers,
    List<Map<String, dynamic>>? filteredResources,
    String? searchQuery,
  }) {
    return DashboardLoaded(
      allParticipants: allParticipants ?? this.allParticipants,
      allUsers: allUsers ?? this.allUsers,
      allResources: allResources ?? this.allResources,
      filteredParticipants: filteredParticipants ?? this.filteredParticipants,
      filteredUsers: filteredUsers ?? this.filteredUsers,
      filteredResources: filteredResources ?? this.filteredResources,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class DashboardError extends DashboardState {
  final String message;

  const DashboardError(this.message);

  @override
  List<Object> get props => [message];
}
