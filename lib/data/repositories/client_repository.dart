import 'package:multiple_result/multiple_result.dart';
import 'package:archimate/data/models/client_model.dart';

/// Error types for client operations
enum ClientErrorType {
  /// Failed to fetch clients
  fetchFailed,
  
  /// Failed to create client
  createFailed,
  
  /// Failed to update client
  updateFailed,
  
  /// Failed to delete client
  deleteFailed,
  
  /// Client not found
  notFound,
  
  /// Network error
  network,
  
  /// Unknown error
  unknown,
}

/// Error class for client operations
class ClientError {
  /// Creates a new [ClientError]
  const ClientError({
    required this.type,
    this.message,
    this.exception,
  });

  /// Type of error
  final ClientErrorType type;
  
  /// Error message
  final String? message;
  
  /// Original exception
  final Object? exception;
  
  @override
  String toString() {
    return message ?? 'Error: ${type.toString().split('.').last}';
  }
}

/// Repository interface for client operations
abstract class ClientRepository {
  /// Get all clients
  Future<Result<List<ClientModel>, ClientError>> getAllClients();
  
  /// Get a client by ID
  Future<Result<ClientModel, ClientError>> getClientById(String id);
  
  /// Create a new client
  Future<Result<ClientModel, ClientError>> createClient(ClientModel client);
  
  /// Update an existing client
  Future<Result<ClientModel, ClientError>> updateClient(ClientModel client);
  
  /// Delete a client
  Future<Result<bool, ClientError>> deleteClient(String id);
  
  /// Search clients by name or email
  Future<Result<List<ClientModel>, ClientError>> searchClients(String query);
  
  /// Stream of clients for real-time updates
  Stream<List<ClientModel>> watchClients();
}
