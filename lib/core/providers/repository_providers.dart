import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:archimate/core/providers/auth_provider.dart';
import 'package:archimate/data/datasources/remote/client_data_source.dart';
import 'package:archimate/data/datasources/remote/invoice_data_source.dart';
import 'package:archimate/data/datasources/remote/project_data_source.dart';
import 'package:archimate/data/repositories/client_repository.dart';
import 'package:archimate/data/repositories/client_repository_impl.dart';
import 'package:archimate/data/repositories/invoice_repository.dart';
import 'package:archimate/data/repositories/invoice_repository_impl.dart';
import 'package:archimate/data/repositories/project_repository.dart';
import 'package:archimate/data/repositories/project_repository_impl.dart';

/// Provider for the project data source
final projectDataSourceProvider = Provider<ProjectDataSource>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return ProjectDataSource(client: client);
});

/// Provider for the client data source
final clientDataSourceProvider = Provider<ClientDataSource>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return ClientDataSource(client: client);
});

/// Provider for the invoice data source
final invoiceDataSourceProvider = Provider<InvoiceDataSource>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return InvoiceDataSource(client: client);
});

/// Provider for the project repository
final projectRepositoryProvider = Provider<ProjectRepository>((ref) {
  final dataSource = ref.watch(projectDataSourceProvider);
  return ProjectRepositoryImpl(dataSource: dataSource);
});

/// Provider for the client repository
final clientRepositoryProvider = Provider<ClientRepository>((ref) {
  final dataSource = ref.watch(clientDataSourceProvider);
  return ClientRepositoryImpl(dataSource: dataSource);
});

/// Provider for the invoice repository
final invoiceRepositoryProvider = Provider<InvoiceRepository>((ref) {
  final dataSource = ref.watch(invoiceDataSourceProvider);
  return InvoiceRepositoryImpl(dataSource: dataSource);
});
