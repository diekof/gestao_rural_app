import 'package:equatable/equatable.dart';

class FarmEntity extends Equatable {
  const FarmEntity(
      {required this.id,
      required this.name,
      required this.owner,
      required this.city,
      required this.state});
  final String id;
  final String name;
  final String owner;
  final String city;
  final String state;
  @override
  List<Object?> get props => [id, name, owner, city, state];
}

class FieldEntity extends Equatable {
  const FieldEntity(
      {required this.id, required this.name, required this.farmId});
  final String id;
  final String name;
  final String farmId;
  @override
  List<Object?> get props => [id, name, farmId];
}

class CropEntity extends Equatable {
  const CropEntity(
      {required this.id, required this.name, required this.category});
  final String id;
  final String name;
  final String category;
  @override
  List<Object?> get props => [id, name, category];
}

class SeasonEntity extends Equatable {
  const SeasonEntity(
      {required this.id, required this.name, required this.year});
  final String id;
  final String name;
  final int year;
  @override
  List<Object?> get props => [id, name, year];
}

class OperationEntity extends Equatable {
  const OperationEntity(
      {required this.id, required this.type, required this.description});
  final String id;
  final String type;
  final String description;
  @override
  List<Object?> get props => [id, type, description];
}

class MachineEntity extends Equatable {
  const MachineEntity({
    required this.id,
    required this.name,
    this.code,
    this.type,
    this.manufacturer,
    this.model,
    this.year,
    this.status,
    this.hourMeter,
    this.notes,
    this.createdAt,
    this.updatedAt,
    this.tenantId,
  });

  final String id;
  final String name;
  final String? code;
  final String? type;
  final String? manufacturer;
  final String? model;
  final int? year;
  final String? status;
  final double? hourMeter;
  final String? notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? tenantId;

  @override
  List<Object?> get props => [
        id,
        name,
        code,
        type,
        manufacturer,
        model,
        year,
        status,
        hourMeter,
        notes,
        createdAt,
        updatedAt,
        tenantId,
      ];
}

class MachineRecordEntity extends Equatable {
  const MachineRecordEntity(
      {required this.id, required this.machineId, required this.recordType});
  final String id;
  final String machineId;
  final String recordType;
  @override
  List<Object?> get props => [id, machineId, recordType];
}

class FinancialEntryEntity extends Equatable {
  const FinancialEntryEntity(
      {required this.id,
      required this.type,
      required this.description,
      required this.value});
  final String id;
  final String type;
  final String description;
  final double value;
  @override
  List<Object?> get props => [id, type, description, value];
}

class AiResultEntity extends Equatable {
  const AiResultEntity({required this.score, required this.recommendations});
  final double score;
  final List<String> recommendations;
  @override
  List<Object?> get props => [score, recommendations];
}

class SatelliteImageEntity extends Equatable {
  const SatelliteImageEntity(
      {required this.id,
      required this.provider,
      required this.ndviAverage,
      required this.thumbnailUrl});
  final String id;
  final String provider;
  final double ndviAverage;
  final String thumbnailUrl;
  @override
  List<Object?> get props => [id, provider, ndviAverage, thumbnailUrl];
}

class FuelCreditEntity extends Equatable {
  const FuelCreditEntity({
    required this.id,
    required this.userId,
    required this.userName,
    required this.creditLimit,
    required this.balance,
    required this.status,
    this.lastRechargeAt,
  });

  final String id;
  final String userId;
  final String userName;
  final double creditLimit;
  final double balance;
  final String status;
  final DateTime? lastRechargeAt;

  double get consumed => creditLimit - balance;
  double get usagePercent =>
      creditLimit <= 0 ? 0 : (consumed / creditLimit).clamp(0, 1);

  @override
  List<Object?> get props =>
      [id, userId, userName, creditLimit, balance, status, lastRechargeAt];
}

class FuelSupplyEntity extends Equatable {
  const FuelSupplyEntity({
    required this.id,
    required this.userId,
    required this.workerName,
    this.machineId,
    this.machineName,
    required this.liters,
    required this.value,
    required this.madeAt,
    this.location,
    this.note,
  });

  final String id;
  final String userId;
  final String workerName;
  final String? machineId;
  final String? machineName;
  final double liters;
  final double value;
  final DateTime madeAt;
  final String? location;
  final String? note;

  @override
  List<Object?> get props => [
        id,
        userId,
        workerName,
        machineId,
        machineName,
        liters,
        value,
        madeAt,
        location,
        note,
      ];
}

class FuelSupplyInput {
  const FuelSupplyInput({
    required this.value,
    required this.liters,
    required this.date,
    this.userId,
    this.machineId,
    this.location,
    this.note,
    this.tenantId,
  });

  final double value;
  final double liters;
  final DateTime date;
  final String? userId;
  final String? machineId;
  final String? location;
  final String? note;
  final String? tenantId;
}

class MachineInput {
  const MachineInput({
    required this.code,
    required this.name,
    required this.type,
    required this.manufacturer,
    required this.model,
    required this.year,
    required this.status,
    required this.hourMeter,
    this.notes,
    this.tenantId,
  });

  final String code;
  final String name;
  final String type;
  final String manufacturer;
  final String model;
  final int year;
  final String status;
  final double hourMeter;
  final String? notes;
  final String? tenantId;
}
