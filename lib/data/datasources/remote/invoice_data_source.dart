import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:archimate/data/models/invoice_model.dart';

/// Data source for invoice operations using Supabase
class InvoiceDataSource {
  /// Creates a new [InvoiceDataSource] instance
  InvoiceDataSource({required SupabaseClient client}) : _client = client;

  final SupabaseClient _client;
  
  /// Table name in Supabase
  static const String _tableName = 'invoices';
  
  /// Items table name in Supabase
  static const String _itemsTableName = 'invoice_items';

  /// Get all invoices
  Future<List<InvoiceModel>> getAllInvoices() async {
    final response = await _client
        .from(_tableName)
        .select('*, items:$_itemsTableName(*)')
        .order('created_at', ascending: false);
    
    return _processInvoiceResponse(response);
  }

  /// Get invoices by client ID
  Future<List<InvoiceModel>> getInvoicesByClient(String clientId) async {
    final response = await _client
        .from(_tableName)
        .select('*, items:$_itemsTableName(*)')
        .eq('client_id', clientId)
        .order('created_at', ascending: false);
    
    return _processInvoiceResponse(response);
  }

  /// Get invoices by project ID
  Future<List<InvoiceModel>> getInvoicesByProject(String projectId) async {
    final response = await _client
        .from(_tableName)
        .select('*, items:$_itemsTableName(*)')
        .eq('project_id', projectId)
        .order('created_at', ascending: false);
    
    return _processInvoiceResponse(response);
  }

  /// Get an invoice by ID
  Future<InvoiceModel> getInvoiceById(String id) async {
    final response = await _client
        .from(_tableName)
        .select('*, items:$_itemsTableName(*)')
        .eq('id', id)
        .single();
    
    return _processInvoiceJson(response);
  }

  /// Create a new invoice
  Future<InvoiceModel> createInvoice(InvoiceModel invoice) async {
    // Prepare data for RPC call
    final invoiceData = invoice.toJson();
    final items = invoiceData.remove('items') as List;
    
    // Call the RPC function
    final response = await _client
        .rpc('create_invoice_with_items', params: {
          'p_invoice': invoiceData,
          'p_items': items,
        });
    
    // Get the invoice ID from the response
    final invoiceId = response.data as String;
    
    // Get the complete invoice with items
    final invoiceResponse = await _client
        .from(_tableName)
        .select('*, items:$_itemsTableName(*)')
        .eq('id', invoiceId)
        .single();
    
    return _processInvoiceJson(invoiceResponse);
  }

  /// Update an existing invoice
  Future<InvoiceModel> updateInvoice(InvoiceModel invoice) async {
    // Update the invoice first
    final invoiceData = invoice.toJson();
    final items = invoiceData.remove('items') as List;
    
    await _client
        .from(_tableName)
        .update(invoiceData)
        .eq('id', invoice.id);
    
    // Delete existing items
    await _client
        .from(_itemsTableName)
        .delete()
        .eq('invoice_id', invoice.id);
    
    // Insert updated items
    for (final item in items) {
      item['invoice_id'] = invoice.id;
      await _client.from(_itemsTableName).insert(item);
    }
    
    // Get the updated invoice with items
    final response = await _client
        .from(_tableName)
        .select('*, items:$_itemsTableName(*)')
        .eq('id', invoice.id)
        .single();
    
    return _processInvoiceJson(response);
  }

  /// Delete an invoice
  Future<void> deleteInvoice(String id) async {
    // The ON DELETE CASCADE will handle deleting related items
    await _client
        .from(_tableName)
        .delete()
        .eq('id', id);
  }

  /// Get invoices by status
  Future<List<InvoiceModel>> getInvoicesByStatus(InvoiceStatus status) async {
    final response = await _client
        .from(_tableName)
        .select('*, items:$_itemsTableName(*)')
        .eq('status', status.name)
        .order('created_at', ascending: false);
    
    return _processInvoiceResponse(response);
  }

  /// Mark invoice as paid
  Future<InvoiceModel> markInvoiceAsPaid(
    String id, {
    required DateTime paymentDate,
    required String paymentMethod,
  }) async {
    final response = await _client
        .from(_tableName)
        .update({
          'status': InvoiceStatus.paid.name,
          'payment_date': paymentDate.toIso8601String(),
          'payment_method': paymentMethod,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', id)
        .select('*, items:$_itemsTableName(*)')
        .single();
    
    return _processInvoiceJson(response);
  }

  /// Generate invoice number
  Future<String> generateInvoiceNumber() async {
    // Get the current year
    final year = DateTime.now().year;
    
    // Count existing invoices for this year
    final response = await _client
        .from(_tableName)
        .select('id')
        .like('invoice_number', 'INV-$year-%');
    
    final count = response.length + 1;
    
    // Format: INV-YYYY-XXXX (e.g., INV-2025-0001)
    return 'INV-$year-${count.toString().padLeft(4, '0')}';
  }

  /// Stream of invoices for real-time updates
  Stream<List<InvoiceModel>> watchInvoices() {
    return _client
        .from(_tableName)
        .stream(primaryKey: ['id'])
        .order('created_at')
        .asyncMap((data) async {
          // For each invoice, fetch its items
          final invoices = <InvoiceModel>[];
          
          for (final json in data) {
            final items = await _client
                .from(_itemsTableName)
                .select()
                .eq('invoice_id', json['id']);
            
            json['items'] = items;
            invoices.add(_processInvoiceJson(json));
          }
          
          return invoices;
        });
  }

  // Helper method to process invoice JSON with items
  InvoiceModel _processInvoiceJson(Map<String, dynamic> json) {
    final itemsJson = json['items'] as List;
    final items = itemsJson
        .map((item) => InvoiceItemModel.fromJson(item))
        .toList();
    
    json['items'] = items;
    return InvoiceModel.fromJson(json);
  }

  // Helper method to process a list of invoice JSON objects
  List<InvoiceModel> _processInvoiceResponse(List<dynamic> response) {
    return response.map((json) => _processInvoiceJson(json)).toList();
  }
}
