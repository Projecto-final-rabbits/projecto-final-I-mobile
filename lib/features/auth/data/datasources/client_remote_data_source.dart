import 'package:dio/dio.dart';

import '../../../../core/error/exceptions.dart';
import '../models/client_model.dart';

abstract class ClientRemoteDataSource {
  /// Calls the https://ventas-135751842587.us-central1.run.app/clientes/ endpoint
  ///
  /// Throws a [ServerException] for all error codes.
  Future<List<ClientModel>> getClients();
}

class ClientRemoteDataSourceImpl implements ClientRemoteDataSource {
  final Dio client;

  ClientRemoteDataSourceImpl({required this.client});

  @override
  Future<List<ClientModel>> getClients() async {
    try {
      final response = await client.get('/clientes');

      if (response.statusCode == 200) {
        return (response.data as List)
            .map((json) => ClientModel.fromJson(json))
            .toList();
      } else {
        throw ServerException(
          message: 'Failed to load clients: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw ServerException(message: 'Failed to load clients: ${e.toString()}');
    }
  }
}
