import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  const UserEntity({required this.id, required this.name, required this.email, this.tenantName});

  final String id;
  final String name;
  final String email;
  final String? tenantName;

  @override
  List<Object?> get props => [id, name, email, tenantName];
}
