import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:archimate/core/providers/repository_providers.dart';
import 'package:archimate/data/models/invoice_model.dart';

/// Provider for all invoices
final allInvoicesProvider = FutureProvider<List<InvoiceModel>>((ref) async {
  final repository = ref.watch(invoiceRepositoryProvider);
  final result = await repository.getAllInvoices();
  
  return result.when(
    (success) => success,
    (error) => throw error,
  );
});

/// Provider for invoices by client
final invoicesByClientProvider = FutureProvider.family<List<InvoiceModel>, String>((ref, clientId) async {
  final repository = ref.watch(invoiceRepositoryProvider);
  final result = await repository.getInvoicesByClient(clientId);
  
  return result.when(
    (success) => success,
    (error) => throw error,
  );
});

/// Provider for invoices by project
final invoicesByProjectProvider = FutureProvider.family<List<InvoiceModel>, String>((ref, projectId) async {
  final repository = ref.watch(invoiceRepositoryProvider);
  final result = await repository.getInvoicesByProject(projectId);
  
  return result.when(
    (success) => success,
    (error) => throw error,
  );
});

/// Provider for invoices by status
final invoicesByStatusProvider = FutureProvider.family<List<InvoiceModel>, InvoiceStatus>((ref, status) async {
  final repository = ref.watch(invoiceRepositoryProvider);
  final result = await repository.getInvoicesByStatus(status);
  
  return result.when(
    (success) => success,
    (error) => throw error,
  );
});

/// Provider for a single invoice by ID
final invoiceByIdProvider = FutureProvider.family<InvoiceModel, String>((ref, id) async {
  final repository = ref.watch(invoiceRepositoryProvider);
  final result = await repository.getInvoiceById(id);
  
  return result.when(
    (success) => success,
    (error) => throw error,
  );
});

/// Provider for generating invoice number
final generateInvoiceNumberProvider = FutureProvider<String>((ref) async {
  final repository = ref.watch(invoiceRepositoryProvider);
  final result = await repository.generateInvoiceNumber();
  
  return result.when(
    (success) => success,
    (error) => throw error,
  );
});

/// Notifier for invoice operations
class InvoiceNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {
    // Nothing to initialize
  }
  
  /// Create a new invoice
  Future<InvoiceModel> createInvoice(InvoiceModel invoice) async {
    state = const AsyncValue.loading();
    
    try {
      final repository = ref.read(invoiceRepositoryProvider);
      final result = await repository.createInvoice(invoice);
      
      return result.when(
        (success) {
          state = const AsyncValue.data(null);
          ref.invalidate(allInvoicesProvider);
          ref.invalidate(invoicesByClientProvider(invoice.clientId));
          ref.invalidate(invoicesByProjectProvider(invoice.projectId));
          ref.invalidate(invoicesByStatusProvider(invoice.status));
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
  
  /// Update an existing invoice
  Future<InvoiceModel> updateInvoice(InvoiceModel invoice) async {
    state = const AsyncValue.loading();
    
    try {
      final repository = ref.read(invoiceRepositoryProvider);
      final result = await repository.updateInvoice(invoice);
      
      return result.when(
        (success) {
          state = const AsyncValue.data(null);
          ref.invalidate(allInvoicesProvider);
          ref.invalidate(invoicesByClientProvider(invoice.clientId));
          ref.invalidate(invoicesByProjectProvider(invoice.projectId));
          ref.invalidate(invoicesByStatusProvider(invoice.status));
          ref.invalidate(invoiceByIdProvider(invoice.id));
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
  
  /// Delete an invoice
  Future<void> deleteInvoice(String id) async {
    state = const AsyncValue.loading();
    
    try {
      final repository = ref.read(invoiceRepositoryProvider);
      final result = await repository.deleteInvoice(id);
      
      result.when(
        (success) {
          state = const AsyncValue.data(null);
          ref.invalidate(allInvoicesProvider);
          // We don't know the client ID, project ID, or status here, so we can't invalidate those specific providers
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
  
  /// Mark an invoice as paid
  Future<InvoiceModel> markInvoiceAsPaid(
    String id, {
    required DateTime paymentDate,
    required String paymentMethod,
  }) async {
    state = const AsyncValue.loading();
    
    try {
      final repository = ref.read(invoiceRepositoryProvider);
      final result = await repository.markInvoiceAsPaid(
        id,
        paymentDate: paymentDate,
        paymentMethod: paymentMethod,
      );
      
      return result.when(
        (success) {
          state = const AsyncValue.data(null);
          ref.invalidate(allInvoicesProvider);
          ref.invalidate(invoiceByIdProvider(id));
          // We don't know the client ID or project ID here, so we can't invalidate those specific providers
          ref.invalidate(invoicesByStatusProvider(InvoiceStatus.paid));
          ref.invalidate(invoicesByStatusProvider(InvoiceStatus.sent)); // Previous status was likely 'sent'
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
}

/// Provider for the invoice notifier
final invoiceNotifierProvider = AsyncNotifierProvider<InvoiceNotifier, void>(() {
  return InvoiceNotifier();
});
