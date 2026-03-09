import '../../domain/entities/dashboard_entity.dart';

class DashboardModel {
  DashboardModel({
    required this.totalRevenue,
    required this.totalExpense,
    required this.estimatedProfit,
    required this.totalFarms,
    required this.totalFields,
    required this.totalSeasons,
    required this.totalMachines,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    return DashboardModel(
      totalRevenue: (json['totalRevenue'] as num?)?.toDouble() ?? 0,
      totalExpense: (json['totalExpense'] as num?)?.toDouble() ?? 0,
      estimatedProfit: (json['estimatedProfit'] as num?)?.toDouble() ?? 0,
      totalFarms: (json['totalFarms'] as num?)?.toInt() ?? 0,
      totalFields: (json['totalFields'] as num?)?.toInt() ?? 0,
      totalSeasons: (json['totalSeasons'] as num?)?.toInt() ?? 0,
      totalMachines: (json['totalMachines'] as num?)?.toInt() ?? 0,
    );
  }

  final double totalRevenue;
  final double totalExpense;
  final double estimatedProfit;
  final int totalFarms;
  final int totalFields;
  final int totalSeasons;
  final int totalMachines;

  DashboardEntity toEntity() => DashboardEntity(
        totalRevenue: totalRevenue,
        totalExpense: totalExpense,
        estimatedProfit: estimatedProfit,
        totalFarms: totalFarms,
        totalFields: totalFields,
        totalSeasons: totalSeasons,
        totalMachines: totalMachines,
      );
}
