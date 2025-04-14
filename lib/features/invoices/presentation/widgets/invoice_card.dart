import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:archimate/data/models/invoice_model.dart';

/// A card widget that displays invoice information
class InvoiceCard extends StatelessWidget {
  /// Creates a new [InvoiceCard] instance
  const InvoiceCard({
    super.key,
    required this.invoice,
    required this.onTap,
    this.onEdit,
  });

  /// The invoice to display
  final InvoiceModel invoice;
  
  /// Callback when the card is tapped
  final VoidCallback onTap;
  
  /// Callback when the edit button is tapped
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currencyFormat = NumberFormat.currency(symbol: '\$');
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status indicator
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
              color: _getStatusColor(invoice.status, theme),
              child: Text(
                _getStatusText(invoice.status),
                style: theme.textTheme.labelMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Invoice number and date
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        invoice.invoiceNumber,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        currencyFormat.format(invoice.total),
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Action buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (onEdit != null)
                        TextButton.icon(
                          onPressed: onEdit,
                          icon: const Icon(Icons.edit_outlined, size: 18),
                          label: const Text('Edit'),
                          style: TextButton.styleFrom(
                            foregroundColor: theme.colorScheme.primary,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                          ),
                        ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Invoice details
                  Row(
                    children: [
                      _buildDetailItem(
                        context,
                        Icons.calendar_today,
                        'Issue: ${DateFormat('MMM d, y').format(invoice.issueDate)}',
                      ),
                      const SizedBox(width: 16),
                      _buildDetailItem(
                        context,
                        Icons.event,
                        'Due: ${DateFormat('MMM d, y').format(invoice.dueDate)}',
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Payment info if paid
                  if (invoice.status == InvoiceStatus.paid && invoice.paymentDate != null)
                    Row(
                      children: [
                        _buildDetailItem(
                          context,
                          Icons.check_circle_outline,
                          'Paid: ${DateFormat('MMM d, y').format(invoice.paymentDate!)}',
                        ),
                        if (invoice.paymentMethod != null) ...[
                          const SizedBox(width: 16),
                          _buildDetailItem(
                            context,
                            Icons.payment,
                            'Method: ${invoice.paymentMethod}',
                          ),
                        ],
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(BuildContext context, IconData icon, String text) {
    final theme = Theme.of(context);
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
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
