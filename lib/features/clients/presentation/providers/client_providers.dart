import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:archimate/core/providers/repository_providers.dart';
import 'package:archimate/data/models/client_model.dart';

/// Provider for all clients
final allClientsProvider = FutureProvider<List<ClientModel>>((ref) async {
  final repository = ref.watch(clientRepositoryProvider);
  final result = await repository.getAllClients();
  
  return result.when(
    (success) => success,
    (error) => throw error,
  );
});

/// Provider for searching clients
final searchClientsProvider = FutureProvider.family<List<ClientModel>, String>((ref, query) async {
  final repository = ref.watch(clientRepositoryProvider);
  final result = await repository.searchClients(query);
  
  return result.when(
    (success) => success,
    (error) => throw error,
  );
});

/// Provider for a single client by ID
final clientByIdProvider = FutureProvider.family<ClientModel, String>((ref, id) async {
  final repository = ref.watch(clientRepositoryProvider);
  final result = await repository.getClientById(id);
  
  return result.when(
    (success) => success,
    (error) => throw error,
  );
});

/// Notifier for client operations
class ClientNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {
    // Nothing to initialize
  }
  
  /// Create a new client
  Future<ClientModel> createClient(ClientModel client) async {
    state = const AsyncValue.loading();
    
    try {
      final repository = ref.read(clientRepositoryProvider);
      final result = await repository.createClient(client);
      
      return result.when(
        (success) {
          state = const AsyncValue.data(null);
          ref.invalidate(allClientsProvider);
          return success;
        },
        (error) {
          state = AsyncValue.error(error, StackTrace.current);
          throw error;
        },
      );
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }
  
  /// Update an existing client
  Future<ClientModel> updateClient(ClientModel client) async {
    state = const AsyncValue.loading();
    
    try {
      final repository = ref.read(clientRepositoryProvider);
      final result = await repository.updateClient(client);
      
      return result.when(
        (success) {
          state = const AsyncValue.data(null);
          ref.invalidate(allClientsProvider);
          ref.invalidate(clientByIdProvider(client.id));
          return success;
        },
        (error) {
          state = AsyncValue.error(error, StackTrace.current);
          throw error;
        },
      );
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }
  
  /// Delete a client
  Future<void> deleteClient(String id) async {
    state = const AsyncValue.loading();
    
    try {
      final repository = ref.read(clientRepositoryProvider);
      final result = await repository.deleteClient(id);
      
      result.when(
        (success) {
          state = const AsyncValue.data(null);
          ref.invalidate(allClientsProvider);
          ref.invalidate(clientByIdProvider(id));
        },
        (error) {
          state = AsyncValue.error(error, StackTrace.current);
          throw error;
        },
      );
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }
}

/// Provider for the client notifier
final clientNotifierProvider = AsyncNotifierProvider<ClientNotifier, void>(() {
  return ClientNotifier();
});
