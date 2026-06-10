import 'package:equatable/equatable.dart';

abstract class DashboardEvent extends Equatable {
  const DashboardEvent();

  @override
  List<Object?> get props => [];
}

class LoadDashboard extends DashboardEvent {
  const LoadDashboard({this.month});

  final DateTime? month;

  @override
  List<Object?> get props => [month];
}

class ChangeMonth extends DashboardEvent {
  const ChangeMonth({required this.month});

  final DateTime month;

  @override
  List<Object?> get props => [month];
}
