import 'package:multiple_result/multiple_result.dart';
import 'package:archimate/data/models/invoice_model.dart';

/// Error types for invoice operations
enum InvoiceErrorType {
  /// Failed to fetch invoices
  fetchFailed,
  
  /// Failed to create invoice
  createFailed,
  
  /// Failed to update invoice
  updateFailed,
  
  /// Failed to delete invoice
  deleteFailed,
  
  /// Invoice not found
  notFound,
  
  /// Network error
  network,
  
  /// Unknown error
  unknown,
}

/// Error class for invoice operations
class InvoiceError {
  /// Creates a new [InvoiceError]
  const InvoiceError({
    required this.type,
    this.message,
    this.exception,
  });

  /// Type of error
  final InvoiceErrorType type;
  
  /// Error message
  final String? message;
  
  /// Original exception
  final Object? exception;
  
  @override
  String toString() {
    return message ?? 'Error: ${type.toString().split('.').last}';
  }
}

/// Repository interface for invoice operations
abstract class InvoiceRepository {
  /// Get all invoices
  Future<Result<List<InvoiceModel>, InvoiceError>> getAllInvoices();
  
  /// Get invoices by client ID
  Future<Result<List<InvoiceModel>, InvoiceError>> getInvoicesByClient(String clientId);
  
  /// Get invoices by project ID
  Future<Result<List<InvoiceModel>, InvoiceError>> getInvoicesByProject(String projectId);
  
  /// Get an invoice by ID
  Future<Result<InvoiceModel, InvoiceError>> getInvoiceById(String id);
  
  /// Create a new invoice
  Future<Result<InvoiceModel, InvoiceError>> createInvoice(InvoiceModel invoice);
  
  /// Update an existing invoice
  Future<Result<InvoiceModel, InvoiceError>> updateInvoice(InvoiceModel invoice);
  
  /// Delete an invoice
  Future<Result<bool, InvoiceError>> deleteInvoice(String id);
  
  /// Get invoices by status
  Future<Result<List<InvoiceModel>, InvoiceError>> getInvoicesByStatus(InvoiceStatus status);
  
  /// Mark invoice as paid
  Future<Result<InvoiceModel, InvoiceError>> markInvoiceAsPaid(
    String id, {
    required DateTime paymentDate,
    required String paymentMethod,
  });
  
  /// Generate invoice number
  Future<Result<String, InvoiceError>> generateInvoiceNumber();
  
  /// Stream of invoices for real-time updates
  Stream<List<InvoiceModel>> watchInvoices();
}
