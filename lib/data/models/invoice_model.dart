import 'package:uuid/uuid.dart';

/// Status of an invoice
enum InvoiceStatus {
  /// Invoice is drafted but not sent
  draft,
  
  /// Invoice has been sent to client
  sent,
  
  /// Invoice has been paid
  paid,
  
  /// Invoice is overdue
  overdue,
  
  /// Invoice has been cancelled
  cancelled,
}

/// Model representing an invoice item
class InvoiceItemModel {
  /// Creates a new [InvoiceItemModel] instance
  const InvoiceItemModel({
    required this.id,
    required this.description,
    required this.quantity,
    required this.unitPrice,
    this.taxRate = 0.0,
  });

  /// Unique identifier for the invoice item
  final String id;
  
  /// Description of the item
  final String description;
  
  /// Quantity of the item
  final double quantity;
  
  /// Unit price of the item
  final double unitPrice;
  
  /// Tax rate applied to the item (percentage)
  final double taxRate;

  /// Total amount for this item (quantity * unitPrice)
  double get subtotal => quantity * unitPrice;

  /// Tax amount for this item
  double get taxAmount => subtotal * (taxRate / 100);

  /// Total amount including tax
  double get total => subtotal + taxAmount;

  /// Creates a new [InvoiceItemModel] with some fields updated
  InvoiceItemModel copyWith({
    String? id,
    String? description,
    double? quantity,
    double? unitPrice,
    double? taxRate,
  }) {
    return InvoiceItemModel(
      id: id ?? this.id,
      description: description ?? this.description,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      taxRate: taxRate ?? this.taxRate,
    );
  }

  /// Creates a [InvoiceItemModel] from JSON data
  factory InvoiceItemModel.fromJson(Map<String, dynamic> json) {
    return InvoiceItemModel(
      id: json['id'] as String,
      description: json['description'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      unitPrice: (json['unit_price'] as num).toDouble(),
      taxRate: (json['tax_rate'] as num?)?.toDouble() ?? 0.0,
    );
  }

  /// Converts the [InvoiceItemModel] to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'quantity': quantity,
      'unit_price': unitPrice,
      'tax_rate': taxRate,
    };
  }
}

/// Model representing an invoice in the application
class InvoiceModel {
  /// Creates a new [InvoiceModel] instance
  const InvoiceModel({
    required this.id,
    required this.invoiceNumber,
    required this.projectId,
    required this.clientId,
    required this.issueDate,
    required this.dueDate,
    required this.status,
    required this.items,
    this.notes,
    this.paymentDate,
    this.paymentMethod,
    required this.createdAt,
    required this.updatedAt,
    required this.userId,
  });

  /// Unique identifier for the invoice
  final String id;
  
  /// Invoice number (displayed to clients)
  final String invoiceNumber;
  
  /// ID of the project this invoice is for
  final String projectId;
  
  /// ID of the client this invoice is for
  final String clientId;
  
  /// Date the invoice was issued
  final DateTime issueDate;
  
  /// Due date for payment
  final DateTime dueDate;
  
  /// Current status of the invoice
  final InvoiceStatus status;
  
  /// Line items in the invoice
  final List<InvoiceItemModel> items;
  
  /// Additional notes on the invoice
  final String? notes;
  
  /// Date the invoice was paid (if applicable)
  final DateTime? paymentDate;
  
  /// Method of payment (if applicable)
  final String? paymentMethod;
  
  /// When the invoice was created
  final DateTime createdAt;
  
  /// When the invoice was last updated
  final DateTime updatedAt;
  
  /// ID of the user who owns this invoice
  final String userId;

  /// Subtotal of all items (before tax)
  double get subtotal => items.fold(0, (sum, item) => sum + item.subtotal);

  /// Total tax amount
  double get taxAmount => items.fold(0, (sum, item) => sum + item.taxAmount);

  /// Total amount including tax
  double get total => subtotal + taxAmount;

  /// Creates a new [InvoiceModel] with some fields updated
  InvoiceModel copyWith({
    String? id,
    String? invoiceNumber,
    String? projectId,
    String? clientId,
    DateTime? issueDate,
    DateTime? dueDate,
    InvoiceStatus? status,
    List<InvoiceItemModel>? items,
    String? notes,
    DateTime? paymentDate,
    String? paymentMethod,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? userId,
  }) {
    return InvoiceModel(
      id: id ?? this.id,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      projectId: projectId ?? this.projectId,
      clientId: clientId ?? this.clientId,
      issueDate: issueDate ?? this.issueDate,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      items: items ?? this.items,
      notes: notes ?? this.notes,
      paymentDate: paymentDate ?? this.paymentDate,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      userId: userId ?? this.userId,
    );
  }

  /// Creates a new invoice with default values
  factory InvoiceModel.create({
    required String projectId,
    required String clientId,
    required String invoiceNumber,
    required DateTime issueDate,
    required DateTime dueDate,
    required List<InvoiceItemModel> items,
    String? notes,
    required String userId,
  }) {
    final now = DateTime.now();
    return InvoiceModel(
      id: const Uuid().v4(),
      invoiceNumber: invoiceNumber,
      projectId: projectId,
      clientId: clientId,
      issueDate: issueDate,
      dueDate: dueDate,
      status: InvoiceStatus.draft,
      items: items,
      notes: notes,
      paymentDate: null,
      paymentMethod: null,
      createdAt: now,
      updatedAt: now,
      userId: userId,
    );
  }

  /// Creates a [InvoiceModel] from JSON data
  factory InvoiceModel.fromJson(Map<String, dynamic> json) {
    return InvoiceModel(
      id: json['id'] as String,
      invoiceNumber: json['invoice_number'] as String,
      projectId: json['project_id'] as String,
      clientId: json['client_id'] as String,
      issueDate: DateTime.parse(json['issue_date'] as String),
      dueDate: DateTime.parse(json['due_date'] as String),
      status: InvoiceStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => InvoiceStatus.draft,
      ),
      items: (json['items'] as List<dynamic>)
          .map((e) => InvoiceItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      notes: json['notes'] as String?,
      paymentDate: json['payment_date'] != null
          ? DateTime.parse(json['payment_date'] as String)
          : null,
      paymentMethod: json['payment_method'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      userId: json['user_id'] as String,
    );
  }

  /// Converts the [InvoiceModel] to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'invoice_number': invoiceNumber,
      'project_id': projectId,
      'client_id': clientId,
      'issue_date': issueDate.toIso8601String(),
      'due_date': dueDate.toIso8601String(),
      'status': status.name,
      'items': items.map((item) => item.toJson()).toList(),
      'notes': notes,
      'payment_date': paymentDate?.toIso8601String(),
      'payment_method': paymentMethod,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'user_id': userId,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is InvoiceModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
