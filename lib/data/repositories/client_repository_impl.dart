import 'package:multiple_result/multiple_result.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:archimate/data/datasources/remote/client_data_source.dart';
import 'package:archimate/data/models/client_model.dart';
import 'package:archimate/data/repositories/client_repository.dart';

/// Implementation of [ClientRepository] using Supabase
class ClientRepositoryImpl implements ClientRepository {
  /// Creates a new [ClientRepositoryImpl] instance
  ClientRepositoryImpl({required ClientDataSource dataSource})
      : _dataSource = dataSource;

  final ClientDataSource _dataSource;

  @override
  Future<Result<List<ClientModel>, ClientError>> getAllClients() async {
    try {
      final clients = await _dataSource.getAllClients();
      return Success(clients);
    } on PostgrestException catch (e) {
      return Error(ClientError(
        type: ClientErrorType.fetchFailed,
        message: e.message,
        exception: e,
      ));
    } catch (e) {
      return Error(ClientError(
        type: ClientErrorType.unknown,
        message: e.toString(),
        exception: e,
      ));
    }
  }

  @override
  Future<Result<ClientModel, ClientError>> getClientById(String id) async {
    try {
      final client = await _dataSource.getClientById(id);
      return Success(client);
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') {
        return Error(ClientError(
          type: ClientErrorType.notFound,
          message: 'Client not found',
          exception: e,
        ));
      }
      return Error(ClientError(
        type: ClientErrorType.fetchFailed,
        message: e.message,
        exception: e,
      ));
    } catch (e) {
      return Error(ClientError(
        type: ClientErrorType.unknown,
        message: e.toString(),
        exception: e,
      ));
    }
  }

  @override
  Future<Result<ClientModel, ClientError>> createClient(
      ClientModel client) async {
    try {
      final createdClient = await _dataSource.createClient(client);
      return Success(createdClient);
    } on PostgrestException catch (e) {
      return Error(ClientError(
        type: ClientErrorType.createFailed,
        message: e.message,
        exception: e,
      ));
    } catch (e) {
      return Error(ClientError(
        type: ClientErrorType.unknown,
        message: e.toString(),
        exception: e,
      ));
    }
  }

  @override
  Future<Result<ClientModel, ClientError>> updateClient(
      ClientModel client) async {
    try {
      final updatedClient = await _dataSource.updateClient(client);
      return Success(updatedClient);
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') {
        return Error(ClientError(
          type: ClientErrorType.notFound,
          message: 'Client not found',
          exception: e,
        ));
      }
      return Error(ClientError(
        type: ClientErrorType.updateFailed,
        message: e.message,
        exception: e,
      ));
    } catch (e) {
      return Error(ClientError(
        type: ClientErrorType.unknown,
        message: e.toString(),
        exception: e,
      ));
    }
  }

  @override
  Future<Result<bool, ClientError>> deleteClient(String id) async {
    try {
      await _dataSource.deleteClient(id);
      return const Success(true);
    } on PostgrestException catch (e) {
      return Error(ClientError(
        type: ClientErrorType.deleteFailed,
        message: e.message,
        exception: e,
      ));
    } catch (e) {
      return Error(ClientError(
        type: ClientErrorType.unknown,
        message: e.toString(),
        exception: e,
      ));
    }
  }

  @override
  Future<Result<List<ClientModel>, ClientError>> searchClients(
      String query) async {
    try {
      final clients = await _dataSource.searchClients(query);
      return Success(clients);
    } on PostgrestException catch (e) {
      return Error(ClientError(
        type: ClientErrorType.fetchFailed,
        message: e.message,
        exception: e,
      ));
    } catch (e) {
      return Error(ClientError(
        type: ClientErrorType.unknown,
        message: e.toString(),
        exception: e,
      ));
    }
  }

  @override
  Stream<List<ClientModel>> watchClients() {
    return _dataSource.watchClients();
  }
}
