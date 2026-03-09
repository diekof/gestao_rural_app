import 'package:equatable/equatable.dart';

class DashboardEntity extends Equatable {
  const DashboardEntity({
    required this.totalFarms,
    required this.totalFields,
    required this.activeSeasons,
    required this.operationsCurrentMonth,
    required this.totalRevenue,
    required this.totalExpense,
    required this.netBalance,
  });

  final int totalFarms;
  final int totalFields;
  final int activeSeasons;
  final int operationsCurrentMonth;
  final double totalRevenue;
  final double totalExpense;
  final double netBalance;

  @override
  List<Object?> get props => [
        totalFarms,
        totalFields,
        activeSeasons,
        operationsCurrentMonth,
        totalRevenue,
        totalExpense,
        netBalance,
      ];
}
