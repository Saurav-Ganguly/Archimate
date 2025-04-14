import 'package:multiple_result/multiple_result.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:archimate/data/datasources/remote/invoice_data_source.dart';
import 'package:archimate/data/models/invoice_model.dart';
import 'package:archimate/data/repositories/invoice_repository.dart';

/// Implementation of [InvoiceRepository] using Supabase
class InvoiceRepositoryImpl implements InvoiceRepository {
  /// Creates a new [InvoiceRepositoryImpl] instance
  InvoiceRepositoryImpl({required InvoiceDataSource dataSource})
      : _dataSource = dataSource;

  final InvoiceDataSource _dataSource;

  @override
  Future<Result<List<InvoiceModel>, InvoiceError>> getAllInvoices() async {
    try {
      final invoices = await _dataSource.getAllInvoices();
      return Success(invoices);
    } on PostgrestException catch (e) {
      return Error(InvoiceError(
        type: InvoiceErrorType.fetchFailed,
        message: e.message,
        exception: e,
      ));
    } catch (e) {
      return Error(InvoiceError(
        type: InvoiceErrorType.unknown,
        message: e.toString(),
        exception: e,
      ));
    }
  }

  @override
  Future<Result<List<InvoiceModel>, InvoiceError>> getInvoicesByClient(
      String clientId) async {
    try {
      final invoices = await _dataSource.getInvoicesByClient(clientId);
      return Success(invoices);
    } on PostgrestException catch (e) {
      return Error(InvoiceError(
        type: InvoiceErrorType.fetchFailed,
        message: e.message,
        exception: e,
      ));
    } catch (e) {
      return Error(InvoiceError(
        type: InvoiceErrorType.unknown,
        message: e.toString(),
        exception: e,
      ));
    }
  }

  @override
  Future<Result<List<InvoiceModel>, InvoiceError>> getInvoicesByProject(
      String projectId) async {
    try {
      final invoices = await _dataSource.getInvoicesByProject(projectId);
      return Success(invoices);
    } on PostgrestException catch (e) {
      return Error(InvoiceError(
        type: InvoiceErrorType.fetchFailed,
        message: e.message,
        exception: e,
      ));
    } catch (e) {
      return Error(InvoiceError(
        type: InvoiceErrorType.unknown,
        message: e.toString(),
        exception: e,
      ));
    }
  }

  @override
  Future<Result<InvoiceModel, InvoiceError>> getInvoiceById(String id) async {
    try {
      final invoice = await _dataSource.getInvoiceById(id);
      return Success(invoice);
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') {
        return Error(InvoiceError(
          type: InvoiceErrorType.notFound,
          message: 'Invoice not found',
          exception: e,
        ));
      }
      return Error(InvoiceError(
        type: InvoiceErrorType.fetchFailed,
        message: e.message,
        exception: e,
      ));
    } catch (e) {
      return Error(InvoiceError(
        type: InvoiceErrorType.unknown,
        message: e.toString(),
        exception: e,
      ));
    }
  }

  @override
  Future<Result<InvoiceModel, InvoiceError>> createInvoice(
      InvoiceModel invoice) async {
    try {
      final createdInvoice = await _dataSource.createInvoice(invoice);
      return Success(createdInvoice);
    } on PostgrestException catch (e) {
      return Error(InvoiceError(
        type: InvoiceErrorType.createFailed,
        message: e.message,
        exception: e,
      ));
    } catch (e) {
      return Error(InvoiceError(
        type: InvoiceErrorType.unknown,
        message: e.toString(),
        exception: e,
      ));
    }
  }

  @override
  Future<Result<InvoiceModel, InvoiceError>> updateInvoice(
      InvoiceModel invoice) async {
    try {
      final updatedInvoice = await _dataSource.updateInvoice(invoice);
      return Success(updatedInvoice);
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') {
        return Error(InvoiceError(
          type: InvoiceErrorType.notFound,
          message: 'Invoice not found',
          exception: e,
        ));
      }
      return Error(InvoiceError(
        type: InvoiceErrorType.updateFailed,
        message: e.message,
        exception: e,
      ));
    } catch (e) {
      return Error(InvoiceError(
        type: InvoiceErrorType.unknown,
        message: e.toString(),
        exception: e,
      ));
    }
  }

  @override
  Future<Result<bool, InvoiceError>> deleteInvoice(String id) async {
    try {
      await _dataSource.deleteInvoice(id);
      return const Success(true);
    } on PostgrestException catch (e) {
      return Error(InvoiceError(
        type: InvoiceErrorType.deleteFailed,
        message: e.message,
        exception: e,
      ));
    } catch (e) {
      return Error(InvoiceError(
        type: InvoiceErrorType.unknown,
        message: e.toString(),
        exception: e,
      ));
    }
  }

  @override
  Future<Result<List<InvoiceModel>, InvoiceError>> getInvoicesByStatus(
      InvoiceStatus status) async {
    try {
      final invoices = await _dataSource.getInvoicesByStatus(status);
      return Success(invoices);
    } on PostgrestException catch (e) {
      return Error(InvoiceError(
        type: InvoiceErrorType.fetchFailed,
        message: e.message,
        exception: e,
      ));
    } catch (e) {
      return Error(InvoiceError(
        type: InvoiceErrorType.unknown,
        message: e.toString(),
        exception: e,
      ));
    }
  }

  @override
  Future<Result<InvoiceModel, InvoiceError>> markInvoiceAsPaid(
    String id, {
    required DateTime paymentDate,
    required String paymentMethod,
  }) async {
    try {
      final updatedInvoice = await _dataSource.markInvoiceAsPaid(
        id,
        paymentDate: paymentDate,
        paymentMethod: paymentMethod,
      );
      return Success(updatedInvoice);
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') {
        return Error(InvoiceError(
          type: InvoiceErrorType.notFound,
          message: 'Invoice not found',
          exception: e,
        ));
      }
      return Error(InvoiceError(
        type: InvoiceErrorType.updateFailed,
        message: e.message,
        exception: e,
      ));
    } catch (e) {
      return Error(InvoiceError(
        type: InvoiceErrorType.unknown,
        message: e.toString(),
        exception: e,
      ));
    }
  }

  @override
  Future<Result<String, InvoiceError>> generateInvoiceNumber() async {
    try {
      final invoiceNumber = await _dataSource.generateInvoiceNumber();
      return Success(invoiceNumber);
    } catch (e) {
      return Error(InvoiceError(
        type: InvoiceErrorType.unknown,
        message: e.toString(),
        exception: e,
      ));
    }
  }

  @override
  Stream<List<InvoiceModel>> watchInvoices() {
    return _dataSource.watchInvoices();
  }
}
