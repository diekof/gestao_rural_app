import 'package:equatable/equatable.dart';

class DashboardEntity extends Equatable {
  const DashboardEntity({
    required this.totalRevenue,
    required this.totalExpense,
    required this.estimatedProfit,
    required this.totalFarms,
    required this.totalFields,
    required this.totalSeasons,
    required this.totalMachines,
  });

  final double totalRevenue;
  final double totalExpense;
  final double estimatedProfit;
  final int totalFarms;
  final int totalFields;
  final int totalSeasons;
  final int totalMachines;

  @override
  List<Object?> get props => [totalRevenue, totalExpense, estimatedProfit, totalFarms, totalFields, totalSeasons, totalMachines];
}
