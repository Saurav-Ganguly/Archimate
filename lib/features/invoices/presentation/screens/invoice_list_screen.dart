import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:archimate/data/models/invoice_model.dart';
import 'package:archimate/features/invoices/presentation/providers/invoice_providers.dart';
import 'package:archimate/features/invoices/presentation/widgets/invoice_card.dart';
import 'package:archimate/presentation/shared_widgets/custom_button.dart';

/// Screen that displays a list of invoices
class InvoiceListScreen extends ConsumerStatefulWidget {
  /// Creates a new [InvoiceListScreen] instance
  const InvoiceListScreen({super.key});

  @override
  ConsumerState<InvoiceListScreen> createState() => _InvoiceListScreenState();
}

class _InvoiceListScreenState extends ConsumerState<InvoiceListScreen> {
  InvoiceStatus _selectedStatus = InvoiceStatus.sent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final invoicesAsync = ref.watch(invoicesByStatusProvider(_selectedStatus));
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Invoices'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildStatusFilter(InvoiceStatus.draft, 'Draft'),
                  _buildStatusFilter(InvoiceStatus.sent, 'Sent'),
                  _buildStatusFilter(InvoiceStatus.paid, 'Paid'),
                  _buildStatusFilter(InvoiceStatus.overdue, 'Overdue'),
                  _buildStatusFilter(InvoiceStatus.cancelled, 'Cancelled'),
                ],
              ),
            ),
          ),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.architecture,
                    size: 48,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Archimate',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Project Management',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard_outlined),
              title: const Text('Projects'),
              onTap: () {
                Navigator.pop(context);
                context.goNamed('projects');
              },
            ),
            ListTile(
              leading: const Icon(Icons.people_outline),
              title: const Text('Clients'),
              onTap: () {
                Navigator.pop(context);
                context.goNamed('clients');
              },
            ),
            ListTile(
              leading: const Icon(Icons.receipt_long_outlined),
              title: const Text('Invoices'),
              selected: true,
              onTap: () {
                Navigator.pop(context);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to settings
              },
            ),
          ],
        ),
      ),
      body: invoicesAsync.when(
        data: (invoices) {
          if (invoices.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 64,
                    color: theme.colorScheme.outline,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No invoices found',
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Create a new invoice to get started',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                  const SizedBox(height: 24),
                  CustomButton(
                    text: 'Create Invoice',
                    icon: Icons.add,
                    onPressed: () {
                      context.pushNamed('add-invoice');
                    },
                  ),
                ],
              ),
            );
          }
          
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(invoicesByStatusProvider(_selectedStatus));
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: invoices.length,
              itemBuilder: (context, index) {
                final invoice = invoices[index];
                return InvoiceCard(
                  invoice: invoice,
                  onTap: () {
                    context.goNamed(
                      'invoice-detail',
                      pathParameters: {'id': invoice.id},
                    );
                  },
                  onEdit: () {
                    context.pushNamed('edit-invoice', pathParameters: {'id': invoice.id});
                  },
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 48,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                'Error loading invoices',
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: theme.textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              CustomButton(
                text: 'Retry',
                icon: Icons.refresh,
                onPressed: () {
                  ref.invalidate(invoicesByStatusProvider(_selectedStatus));
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to create invoice screen
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildStatusFilter(InvoiceStatus status, String label) {
    final theme = Theme.of(context);
    final isSelected = status == _selectedStatus;
    
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedStatus = status;
          });
        },
        backgroundColor: theme.colorScheme.surface,
        selectedColor: theme.colorScheme.primary.withOpacity(0.2),
        checkmarkColor: theme.colorScheme.primary,
        labelStyle: TextStyle(
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.onSurface,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}
