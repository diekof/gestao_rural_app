import '../../domain/entities/dashboard_entity.dart';

class DashboardModel {
  DashboardModel({
    required this.totalFarms,
    required this.totalFields,
    required this.activeSeasons,
    required this.operationsCurrentMonth,
    required this.totalRevenue,
    required this.totalExpense,
    required this.netBalance,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    return DashboardModel(
      totalFarms: (json['totalFarms'] as num?)?.toInt() ?? 0,
      totalFields: (json['totalFields'] as num?)?.toInt() ?? 0,
      activeSeasons: (json['activeSeasons'] as num?)?.toInt() ?? 0,
      operationsCurrentMonth:
          (json['operationsCurrentMonth'] as num?)?.toInt() ?? 0,
      totalRevenue: (json['totalRevenue'] as num?)?.toDouble() ?? 0,
      totalExpense: (json['totalExpense'] as num?)?.toDouble() ?? 0,
      netBalance: (json['netBalance'] as num?)?.toDouble() ?? 0,
    );
  }

  final int totalFarms;
  final int totalFields;
  final int activeSeasons;
  final int operationsCurrentMonth;
  final double totalRevenue;
  final double totalExpense;
  final double netBalance;

  DashboardEntity toEntity() => DashboardEntity(
        totalFarms: totalFarms,
        totalFields: totalFields,
        activeSeasons: activeSeasons,
        operationsCurrentMonth: operationsCurrentMonth,
        totalRevenue: totalRevenue,
        totalExpense: totalExpense,
        netBalance: netBalance,
      );
}
