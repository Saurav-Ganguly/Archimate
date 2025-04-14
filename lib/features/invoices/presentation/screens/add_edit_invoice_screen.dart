import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:archimate/core/providers/auth_provider.dart';
import 'package:archimate/core/utils/form_validators.dart';
import 'package:archimate/data/models/invoice_model.dart';
import 'package:archimate/features/clients/presentation/providers/client_providers.dart';
import 'package:archimate/features/projects/presentation/providers/project_providers.dart';
import 'package:archimate/features/invoices/presentation/providers/invoice_providers.dart';

/// Screen for adding or editing an invoice
class AddEditInvoiceScreen extends ConsumerStatefulWidget {
  /// Creates a new [AddEditInvoiceScreen]
  const AddEditInvoiceScreen({
    super.key,
    this.invoiceId,
    this.projectId,
    this.clientId,
  });

  /// ID of the invoice to edit, or null if adding a new invoice
  final String? invoiceId;
  
  /// ID of the project to create an invoice for, or null if not specified
  final String? projectId;
  
  /// ID of the client to create an invoice for, or null if not specified
  final String? clientId;

  @override
  ConsumerState<AddEditInvoiceScreen> createState() => _AddEditInvoiceScreenState();
}

class _AddEditInvoiceScreenState extends ConsumerState<AddEditInvoiceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _invoiceNumberController = TextEditingController();
  final _notesController = TextEditingController();
  final _paymentMethodController = TextEditingController();
  
  DateTime _issueDate = DateTime.now();
  DateTime _dueDate = DateTime.now().add(const Duration(days: 30));
  DateTime? _paymentDate;
  String? _selectedProjectId;
  String? _selectedClientId;
  InvoiceStatus _status = InvoiceStatus.draft;
  bool _isLoading = false;
  InvoiceModel? _existingInvoice;
  
  final List<InvoiceItemModel> _invoiceItems = [];
  
  @override
  void initState() {
    super.initState();
    
    // If projectId or clientId is provided, use them as initial values
    _selectedProjectId = widget.projectId;
    _selectedClientId = widget.clientId;
    
    // Generate a new invoice number if creating a new invoice
    if (widget.invoiceId == null) {
      _generateInvoiceNumber();
    } else {
      _loadInvoice();
    }
  }

  @override
  void dispose() {
    _invoiceNumberController.dispose();
    _notesController.dispose();
    _paymentMethodController.dispose();
    super.dispose();
  }
  
  void _generateInvoiceNumber() {
    final now = DateTime.now();
    final year = now.year.toString();
    final month = now.month.toString().padLeft(2, '0');
    final random = now.millisecondsSinceEpoch.toString().substring(8, 12);
    
    _invoiceNumberController.text = 'INV-$year$month-$random';
  }

  Future<void> _loadInvoice() async {
    try {
      final invoice = await ref.read(invoiceByIdProvider(widget.invoiceId!).future);
      _existingInvoice = invoice;
      
      _invoiceNumberController.text = invoice.invoiceNumber;
      _notesController.text = invoice.notes ?? '';
      _paymentMethodController.text = invoice.paymentMethod ?? '';
      _issueDate = invoice.issueDate;
      _dueDate = invoice.dueDate;
      _paymentDate = invoice.paymentDate;
      _selectedProjectId = invoice.projectId;
      _selectedClientId = invoice.clientId;
      _status = invoice.status;
      
      // Copy invoice items
      _invoiceItems.clear();
      _invoiceItems.addAll(invoice.items);
      
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading invoice: $e')),
      );
    }
  }

  Future<void> _saveInvoice() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    if (_invoiceItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one item to the invoice')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Get the current user ID
      final currentUser = ref.read(currentUserProvider);
      if (currentUser == null) {
        throw Exception('You must be logged in to create an invoice');
      }
      
      final now = DateTime.now();
      final invoice = InvoiceModel(
        id: widget.invoiceId != null ? widget.invoiceId! : const Uuid().v4(),
        invoiceNumber: _invoiceNumberController.text,
        projectId: _selectedProjectId!,
        clientId: _selectedClientId!,
        issueDate: _issueDate,
        dueDate: _dueDate,
        status: _status,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
        paymentDate: _paymentDate,
        paymentMethod: _paymentMethodController.text.isEmpty ? null : _paymentMethodController.text,
        items: _invoiceItems,
        createdAt: _existingInvoice?.createdAt ?? now,
        updatedAt: now,
        userId: currentUser.id,
      );

      final notifier = ref.read(invoiceNotifierProvider.notifier);
      
      if (widget.invoiceId == null) {
        await notifier.createInvoice(invoice);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Invoice created successfully')),
          );
          context.pop();
        }
      } else {
        await notifier.updateInvoice(invoice);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Invoice updated successfully')),
          );
          context.pop();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving invoice: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _selectDate(BuildContext context, DateType dateType) async {
    final initialDate = dateType == DateType.issueDate 
        ? _issueDate 
        : dateType == DateType.dueDate 
            ? _dueDate 
            : _paymentDate ?? DateTime.now();
    
    final firstDate = dateType == DateType.dueDate 
        ? _issueDate  // Due date must be after issue date
        : DateTime(2020);
    
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: DateTime(2030),
    );
    
    if (pickedDate != null) {
      setState(() {
        if (dateType == DateType.issueDate) {
          _issueDate = pickedDate;
          // If due date is before new issue date, update it
          if (_dueDate.isBefore(_issueDate)) {
            _dueDate = _issueDate.add(const Duration(days: 30));
          }
        } else if (dateType == DateType.dueDate) {
          _dueDate = pickedDate;
        } else {
          _paymentDate = pickedDate;
        }
      });
    }
  }
  
  void _addInvoiceItem() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _InvoiceItemForm(
        onSave: (item) {
          setState(() {
            _invoiceItems.add(item);
          });
        },
      ),
    );
  }
  
  void _editInvoiceItem(int index) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _InvoiceItemForm(
        initialItem: _invoiceItems[index],
        onSave: (item) {
          setState(() {
            _invoiceItems[index] = item;
          });
        },
      ),
    );
  }
  
  void _removeInvoiceItem(int index) {
    setState(() {
      _invoiceItems.removeAt(index);
    });
  }
  
  double _calculateSubtotal() {
    return _invoiceItems.fold(0, (sum, item) => sum + (item.quantity * item.unitPrice));
  }
  
  double _calculateTax() {
    return _invoiceItems.fold(0, (sum, item) {
      final itemTotal = item.quantity * item.unitPrice;
      return sum + (itemTotal * (item.taxRate / 100));
    });
  }
  
  double _calculateTotal() {
    return _calculateSubtotal() + _calculateTax();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEditing = widget.invoiceId != null;
    final projectsAsync = ref.watch(allProjectsProvider);
    final clientsAsync = ref.watch(allClientsProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Invoice' : 'Create Invoice'),
      ),
      body: projectsAsync.when(
        data: (projects) => clientsAsync.when(
          data: (clients) {
            return Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  // Invoice number
                  TextFormField(
                    controller: _invoiceNumberController,
                    decoration: const InputDecoration(
                      labelText: 'Invoice Number',
                      border: OutlineInputBorder(),
                    ),
                    validator: FormValidators.required('Invoice number is required'),
                  ),
                  const SizedBox(height: 16),
                  
                  // Project dropdown
                  DropdownButtonFormField<String>(
                    value: _selectedProjectId,
                    decoration: const InputDecoration(
                      labelText: 'Project',
                      border: OutlineInputBorder(),
                    ),
                    items: projects.map((project) {
                      return DropdownMenuItem(
                        value: project.id,
                        child: Text(project.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedProjectId = value;
                        
                        // If project changes, update client if needed
                        if (value != null) {
                          final selectedProject = projects.firstWhere((p) => p.id == value);
                          if (_selectedClientId != selectedProject.clientId) {
                            _selectedClientId = selectedProject.clientId;
                          }
                        }
                      });
                    },
                    validator: FormValidators.required('Project is required'),
                  ),
                  const SizedBox(height: 16),
                  
                  // Client dropdown
                  DropdownButtonFormField<String>(
                    value: _selectedClientId,
                    decoration: const InputDecoration(
                      labelText: 'Client',
                      border: OutlineInputBorder(),
                    ),
                    items: clients.map((client) {
                      return DropdownMenuItem(
                        value: client.id,
                        child: Text(client.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedClientId = value;
                      });
                    },
                    validator: FormValidators.required('Client is required'),
                  ),
                  const SizedBox(height: 16),
                  
                  // Status dropdown
                  DropdownButtonFormField<InvoiceStatus>(
                    value: _status,
                    decoration: const InputDecoration(
                      labelText: 'Status',
                      border: OutlineInputBorder(),
                    ),
                    items: InvoiceStatus.values.map((status) {
                      return DropdownMenuItem(
                        value: status,
                        child: Text(status.displayName),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _status = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Dates
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () => _selectDate(context, DateType.issueDate),
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Issue Date',
                              border: OutlineInputBorder(),
                            ),
                            child: Text(
                              DateFormat('MMM dd, yyyy').format(_issueDate),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: InkWell(
                          onTap: () => _selectDate(context, DateType.dueDate),
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Due Date',
                              border: OutlineInputBorder(),
                            ),
                            child: Text(
                              DateFormat('MMM dd, yyyy').format(_dueDate),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Payment date and method (optional)
                  if (_status == InvoiceStatus.paid) ...[
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => _selectDate(context, DateType.paymentDate),
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'Payment Date',
                                border: OutlineInputBorder(),
                              ),
                              child: Text(
                                _paymentDate == null
                                    ? 'Select date'
                                    : DateFormat('MMM dd, yyyy').format(_paymentDate!),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _paymentMethodController,
                            decoration: const InputDecoration(
                              labelText: 'Payment Method',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                  
                  // Notes
                  TextFormField(
                    controller: _notesController,
                    decoration: const InputDecoration(
                      labelText: 'Notes (Optional)',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 24),
                  
                  // Invoice items section
                  Card(
                    margin: EdgeInsets.zero,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Invoice Items',
                                style: theme.textTheme.titleMedium,
                              ),
                              ElevatedButton.icon(
                                onPressed: _addInvoiceItem,
                                icon: const Icon(Icons.add),
                                label: const Text('Add Item'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: theme.colorScheme.primary,
                                  foregroundColor: theme.colorScheme.onPrimary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          
                          // Invoice items list
                          if (_invoiceItems.isEmpty)
                            const Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 16),
                                child: Text('No items added yet'),
                              ),
                            )
                          else
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _invoiceItems.length,
                              separatorBuilder: (context, index) => const Divider(),
                              itemBuilder: (context, index) {
                                final item = _invoiceItems[index];
                                final itemTotal = item.quantity * item.unitPrice;
                                
                                return ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  title: Text(item.description),
                                  subtitle: Text(
                                    '${item.quantity} × \$${item.unitPrice.toStringAsFixed(2)} ${item.taxRate > 0 ? '(+${item.taxRate}% tax)' : ''}',
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        '\$${itemTotal.toStringAsFixed(2)}',
                                        style: theme.textTheme.titleMedium,
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.edit_outlined),
                                        onPressed: () => _editInvoiceItem(index),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline),
                                        onPressed: () => _removeInvoiceItem(index),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          
                          if (_invoiceItems.isNotEmpty) ...[
                            const Divider(thickness: 1),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Subtotal'),
                                  Text('\$${_calculateSubtotal().toStringAsFixed(2)}'),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Tax'),
                                  Text('\$${_calculateTax().toStringAsFixed(2)}'),
                                ],
                              ),
                            ),
                            const Divider(),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Total',
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '\$${_calculateTotal().toStringAsFixed(2)}',
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Save button
                  ElevatedButton(
                    onPressed: _isLoading ? null : _saveInvoice,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator()
                        : Text(isEditing ? 'Update Invoice' : 'Create Invoice'),
                  ),
                ],
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Text('Error loading clients: $error'),
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error loading projects: $error'),
        ),
      ),
    );
  }
}

/// Form for adding or editing an invoice item
class _InvoiceItemForm extends StatefulWidget {
  const _InvoiceItemForm({
    this.initialItem,
    required this.onSave,
  });

  final InvoiceItemModel? initialItem;
  final void Function(InvoiceItemModel) onSave;

  @override
  State<_InvoiceItemForm> createState() => _InvoiceItemFormState();
}

class _InvoiceItemFormState extends State<_InvoiceItemForm> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _quantityController = TextEditingController();
  final _unitPriceController = TextEditingController();
  final _taxRateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    
    if (widget.initialItem != null) {
      _descriptionController.text = widget.initialItem!.description;
      _quantityController.text = widget.initialItem!.quantity.toString();
      _unitPriceController.text = widget.initialItem!.unitPrice.toString();
      _taxRateController.text = widget.initialItem!.taxRate.toString();
    } else {
      _quantityController.text = '1';
      _taxRateController.text = '0';
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _quantityController.dispose();
    _unitPriceController.dispose();
    _taxRateController.dispose();
    super.dispose();
  }

  void _saveItem() {
    if (_formKey.currentState!.validate()) {
      final item = InvoiceItemModel(
        id: widget.initialItem != null ? widget.initialItem!.id : const Uuid().v4(),
        description: _descriptionController.text,
        quantity: double.parse(_quantityController.text),
        unitPrice: double.parse(_unitPriceController.text),
        taxRate: double.parse(_taxRateController.text),
      );
      
      widget.onSave(item);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.initialItem == null ? 'Add Invoice Item' : 'Edit Invoice Item',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              validator: FormValidators.required('Description is required'),
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _quantityController,
                    decoration: const InputDecoration(
                      labelText: 'Quantity',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: FormValidators.number('Please enter a valid number'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _unitPriceController,
                    decoration: const InputDecoration(
                      labelText: 'Unit Price',
                      border: OutlineInputBorder(),
                      prefixText: '\$',
                    ),
                    keyboardType: TextInputType.number,
                    validator: FormValidators.number('Please enter a valid price'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _taxRateController,
              decoration: const InputDecoration(
                labelText: 'Tax Rate (%)',
                border: OutlineInputBorder(),
                suffixText: '%',
              ),
              keyboardType: TextInputType.number,
              validator: FormValidators.number('Please enter a valid tax rate'),
            ),
            const SizedBox(height: 24),
            
            ElevatedButton(
              onPressed: _saveItem,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(widget.initialItem == null ? 'Add Item' : 'Update Item'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Type of date being selected
enum DateType {
  /// Issue date of the invoice
  issueDate,
  
  /// Due date of the invoice
  dueDate,
  
  /// Payment date of the invoice
  paymentDate,
}

/// Extension on InvoiceStatus to provide display names
extension InvoiceStatusExtension on InvoiceStatus {
  /// Get a user-friendly display name for the status
  String get displayName {
    switch (this) {
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
