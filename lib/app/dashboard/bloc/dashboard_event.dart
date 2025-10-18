import 'package:equatable/equatable.dart';
import '../../../core/user_type.dart';

abstract class DashboardEvent extends Equatable {
  const DashboardEvent();

  @override
  List<Object> get props => [];
}

class LoadDashboardData extends DashboardEvent {
  final UserType userType;

  const LoadDashboardData({required this.userType});

  @override
  List<Object> get props => [userType];
}

class SearchChanged extends DashboardEvent {
  final String query;

  const SearchChanged({required this.query});

  @override
  List<Object> get props => [query];
}
