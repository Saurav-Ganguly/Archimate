import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:archimate/data/models/invoice_model.dart';
import 'package:archimate/features/clients/presentation/providers/client_providers.dart';
import 'package:archimate/features/invoices/presentation/providers/invoice_providers.dart';
import 'package:archimate/features/projects/presentation/providers/project_providers.dart';
import 'package:archimate/presentation/shared_widgets/custom_button.dart';

/// Screen that displays invoice details
class InvoiceDetailScreen extends ConsumerWidget {
  /// Creates a new [InvoiceDetailScreen] instance
  const InvoiceDetailScreen({
    super.key,
    required this.invoiceId,
  });

  /// ID of the invoice to display
  final String invoiceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final invoiceAsync = ref.watch(invoiceByIdProvider(invoiceId));
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Invoice Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // Navigate to edit invoice screen
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              _showOptionsMenu(context, ref);
            },
          ),
        ],
      ),
      body: invoiceAsync.when(
        data: (invoice) => _buildInvoiceDetails(context, ref, invoice),
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
                'Error loading invoice',
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
                  ref.invalidate(invoiceByIdProvider(invoiceId));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInvoiceDetails(BuildContext context, WidgetRef ref, InvoiceModel invoice) {
    final theme = Theme.of(context);
    final currencyFormat = NumberFormat.currency(symbol: '\$');
    final clientAsync = ref.watch(clientByIdProvider(invoice.clientId));
    final projectAsync = ref.watch(projectByIdProvider(invoice.projectId));
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status indicator
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            decoration: BoxDecoration(
              color: _getStatusColor(invoice.status, theme),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _getStatusText(invoice.status),
              style: theme.textTheme.titleSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Invoice header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Invoice',
                    style: theme.textTheme.titleMedium,
                  ),
                  Text(
                    invoice.invoiceNumber,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Total Amount',
                    style: theme.textTheme.titleMedium,
                  ),
                  Text(
                    currencyFormat.format(invoice.total),
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Dates section
          _buildSectionTitle(context, 'Dates'),
          
          const SizedBox(height: 8),
          
          Row(
            children: [
              Expanded(
                child: _buildDetailItem(
                  context,
                  Icons.calendar_today,
                  'Issue Date',
                  DateFormat('MMMM d, y').format(invoice.issueDate),
                ),
              ),
              Expanded(
                child: _buildDetailItem(
                  context,
                  Icons.event,
                  'Due Date',
                  DateFormat('MMMM d, y').format(invoice.dueDate),
                ),
              ),
            ],
          ),
          
          if (invoice.status == InvoiceStatus.paid && invoice.paymentDate != null)
            Row(
              children: [
                Expanded(
                  child: _buildDetailItem(
                    context,
                    Icons.check_circle_outline,
                    'Payment Date',
                    DateFormat('MMMM d, y').format(invoice.paymentDate!),
                  ),
                ),
                if (invoice.paymentMethod != null)
                  Expanded(
                    child: _buildDetailItem(
                      context,
                      Icons.payment,
                      'Payment Method',
                      invoice.paymentMethod!,
                    ),
                  ),
              ],
            ),
          
          const SizedBox(height: 24),
          
          // Client and project section
          _buildSectionTitle(context, 'Details'),
          
          const SizedBox(height: 8),
          
          clientAsync.when(
            data: (client) => _buildDetailItem(
              context,
              Icons.person_outline,
              'Client',
              client.name,
            ),
            loading: () => const CircularProgressIndicator(),
            error: (_, __) => _buildDetailItem(
              context,
              Icons.person_outline,
              'Client',
              'Error loading client',
            ),
          ),
          
          projectAsync.when(
            data: (project) => _buildDetailItem(
              context,
              Icons.dashboard_outlined,
              'Project',
              project.name,
            ),
            loading: () => const CircularProgressIndicator(),
            error: (_, __) => _buildDetailItem(
              context,
              Icons.dashboard_outlined,
              'Project',
              'Error loading project',
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Invoice items section
          _buildSectionTitle(context, 'Invoice Items'),
          
          const SizedBox(height: 8),
          
          // Invoice items table
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Table header
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Text(
                          'Description',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Text(
                          'Qty',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Unit Price',
                          textAlign: TextAlign.right,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Total',
                          textAlign: TextAlign.right,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const Divider(),
                  
                  // Table rows
                  ...invoice.items.map((item) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 3,
                          child: Text(
                            item.description,
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Text(
                            item.quantity.toString(),
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            currencyFormat.format(item.unitPrice),
                            textAlign: TextAlign.right,
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            currencyFormat.format(item.subtotal),
                            textAlign: TextAlign.right,
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  )),
                  
                  const Divider(),
                  
                  // Subtotal
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Row(
                      children: [
                        const Spacer(flex: 6),
                        Expanded(
                          flex: 2,
                          child: Text(
                            'Subtotal',
                            textAlign: TextAlign.right,
                            style: theme.textTheme.titleSmall,
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            currencyFormat.format(invoice.subtotal),
                            textAlign: TextAlign.right,
                            style: theme.textTheme.titleSmall,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Tax
                  if (invoice.taxAmount > 0)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Row(
                        children: [
                          const Spacer(flex: 6),
                          Expanded(
                            flex: 2,
                            child: Text(
                              'Tax',
                              textAlign: TextAlign.right,
                              style: theme.textTheme.titleSmall,
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              currencyFormat.format(invoice.taxAmount),
                              textAlign: TextAlign.right,
                              style: theme.textTheme.titleSmall,
                            ),
                          ),
                        ],
                      ),
                    ),
                  
                  // Total
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Row(
                      children: [
                        const Spacer(flex: 6),
                        Expanded(
                          flex: 2,
                          child: Text(
                            'Total',
                            textAlign: TextAlign.right,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            currencyFormat.format(invoice.total),
                            textAlign: TextAlign.right,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Notes section
          if (invoice.notes != null && invoice.notes!.isNotEmpty) ...[
            _buildSectionTitle(context, 'Notes'),
            
            const SizedBox(height: 8),
            
            Text(invoice.notes!),
            
            const SizedBox(height: 24),
          ],
          
          // Action buttons
          if (invoice.status == InvoiceStatus.sent)
            CustomButton(
              text: 'Mark as Paid',
              icon: Icons.check_circle_outline,
              onPressed: () {
                _showMarkAsPaidDialog(context, ref, invoice);
              },
            ),
          
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  text: 'Download PDF',
                  icon: Icons.download_outlined,
                  isOutlined: true,
                  onPressed: () {
                    // Download invoice as PDF
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: CustomButton(
                  text: 'Send Email',
                  icon: Icons.email_outlined,
                  isOutlined: true,
                  onPressed: () {
                    // Send invoice via email
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Divider(
          color: theme.colorScheme.outline.withOpacity(0.5),
          thickness: 1,
        ),
      ],
    );
  }

  Widget _buildDetailItem(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
                Text(
                  value,
                  style: theme.textTheme.bodyLarge,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showOptionsMenu(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(
                Icons.edit,
                color: theme.colorScheme.primary,
              ),
              title: const Text('Edit Invoice'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to edit invoice screen
              },
            ),
            ListTile(
              leading: Icon(
                Icons.content_copy,
                color: theme.colorScheme.primary,
              ),
              title: const Text('Duplicate Invoice'),
              onTap: () {
                Navigator.pop(context);
                // Duplicate invoice logic
              },
            ),
            ListTile(
              leading: Icon(
                Icons.delete_outline,
                color: theme.colorScheme.error,
              ),
              title: Text(
                'Delete Invoice',
                style: TextStyle(
                  color: theme.colorScheme.error,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _confirmDeleteInvoice(context, ref);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showMarkAsPaidDialog(BuildContext context, WidgetRef ref, InvoiceModel invoice) {
    final theme = Theme.of(context);
    final paymentDateController = TextEditingController(
      text: DateFormat('yyyy-MM-dd').format(DateTime.now()),
    );
    final paymentMethodController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mark Invoice as Paid'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: paymentDateController,
              decoration: const InputDecoration(
                labelText: 'Payment Date',
                hintText: 'YYYY-MM-DD',
                prefixIcon: Icon(Icons.calendar_today),
              ),
              readOnly: true,
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: invoice.issueDate,
                  lastDate: DateTime.now().add(const Duration(days: 1)),
                );
                
                if (date != null) {
                  paymentDateController.text = DateFormat('yyyy-MM-dd').format(date);
                }
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: paymentMethodController,
              decoration: const InputDecoration(
                labelText: 'Payment Method',
                hintText: 'e.g., Bank Transfer, Cash, Credit Card',
                prefixIcon: Icon(Icons.payment),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (paymentDateController.text.isEmpty ||
                  paymentMethodController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please fill in all fields'),
                  ),
                );
                return;
              }
              
              Navigator.pop(context);
              _markInvoiceAsPaid(
                context,
                ref,
                paymentDate: DateFormat('yyyy-MM-dd').parse(paymentDateController.text),
                paymentMethod: paymentMethodController.text,
              );
            },
            child: Text(
              'Mark as Paid',
              style: TextStyle(
                color: theme.colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteInvoice(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Invoice'),
        content: const Text(
          'Are you sure you want to delete this invoice? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteInvoice(context, ref);
            },
            child: Text(
              'Delete',
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _markInvoiceAsPaid(
    BuildContext context,
    WidgetRef ref, {
    required DateTime paymentDate,
    required String paymentMethod,
  }) async {
    try {
      await ref.read(invoiceNotifierProvider.notifier).markInvoiceAsPaid(
        invoiceId,
        paymentDate: paymentDate,
        paymentMethod: paymentMethod,
      );
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invoice marked as paid successfully'),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to mark invoice as paid: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _deleteInvoice(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(invoiceNotifierProvider.notifier).deleteInvoice(invoiceId);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invoice deleted successfully'),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete invoice: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Color _getStatusColor(InvoiceStatus status, ThemeData theme) {
    switch (status) {
      case InvoiceStatus.draft:
        return Colors.grey;
      case InvoiceStatus.sent:
        return theme.colorScheme.primary;
      case InvoiceStatus.paid:
        return Colors.green;
      case InvoiceStatus.overdue:
        return Colors.orange;
      case InvoiceStatus.cancelled:
        return Colors.red;
    }
  }

  String _getStatusText(InvoiceStatus status) {
    switch (status) {
      case InvoiceStatus.draft:
        return 'Draft';
      case InvoiceStatus.sent:
        return 'Sent';
      case InvoiceStatus.paid:
        return 'Paid';
      case InvoiceStatus.overdue:
        return 'Overdue';
      case InvoiceStatus.cancelled:
        return 'Cancelled';
    }
  }
}
