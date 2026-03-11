import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_client.dart';
import '../../domain/repositories/agro_repository.dart';
import '../datasources/agro_remote_datasource.dart';
import '../repositories/agro_repository_impl.dart';

final agroRemoteDatasourceProvider = Provider<AgroRemoteDatasource>(
  (ref) =>
      AgroRemoteDatasource(ref.read(apiClientProvider), ref.read(tokenStorageProvider)),
);

final agroRepositoryProvider = Provider<AgroRepository>(
  (ref) => AgroRepositoryImpl(ref.read(agroRemoteDatasourceProvider)),
);
