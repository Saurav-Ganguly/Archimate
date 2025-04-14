import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:archimate/data/models/client_model.dart';

/// Data source for client operations using Supabase
class ClientDataSource {
  /// Creates a new [ClientDataSource] instance
  ClientDataSource({required SupabaseClient client}) : _client = client;

  final SupabaseClient _client;
  
  /// Table name in Supabase
  static const String _tableName = 'clients';

  /// Get all clients
  Future<List<ClientModel>> getAllClients() async {
    final response = await _client
        .from(_tableName)
        .select()
        .order('name');
    
    return response.map((json) => ClientModel.fromJson(json)).toList();
  }

  /// Get a client by ID
  Future<ClientModel> getClientById(String id) async {
    final response = await _client
        .from(_tableName)
        .select()
        .eq('id', id)
        .single();
    
    return ClientModel.fromJson(response);
  }

  /// Create a new client
  Future<ClientModel> createClient(ClientModel client) async {
    try {
      print('Creating client with data: ${client.toJson()}');
      
      // Insert the client
      final response = await _client
          .from(_tableName)
          .insert(client.toJson())
          .select()
          .single();
      
      final createdClient = ClientModel.fromJson(response);
      print('Client created successfully with ID: ${createdClient.id}');
      
      // Verify the client was created by fetching it again
      try {
        await Future.delayed(const Duration(milliseconds: 300)); // Small delay to ensure database consistency
        final verificationCheck = await _client
            .from(_tableName)
            .select()
            .eq('id', createdClient.id)
            .maybeSingle();
            
        if (verificationCheck == null) {
          print('WARNING: Client verification failed - client not found after creation');
        } else {
          print('Client verified after creation: ${verificationCheck['id']}');
        }
      } catch (e) {
        print('Client verification check failed: $e');
        // Continue anyway as the client was created
      }
      
      return createdClient;
    } catch (e) {
      print('Error creating client: $e');
      rethrow;
    }
  }

  /// Update an existing client
  Future<ClientModel> updateClient(ClientModel client) async {
    final response = await _client
        .from(_tableName)
        .update(client.toJson())
        .eq('id', client.id)
        .select()
        .single();
    
    return ClientModel.fromJson(response);
  }

  /// Delete a client
  Future<void> deleteClient(String id) async {
    await _client
        .from(_tableName)
        .delete()
        .eq('id', id);
  }

  /// Search clients by name or email
  Future<List<ClientModel>> searchClients(String query) async {
    final response = await _client
        .from(_tableName)
        .select()
        .or('name.ilike.%$query%,email.ilike.%$query%')
        .order('name');
    
    return response.map((json) => ClientModel.fromJson(json)).toList();
  }

  /// Stream of clients for real-time updates
  Stream<List<ClientModel>> watchClients() {
    return _client
        .from(_tableName)
        .stream(primaryKey: ['id'])
        .order('name')
        .map((data) => data.map((json) => ClientModel.fromJson(json)).toList());
  }
}
