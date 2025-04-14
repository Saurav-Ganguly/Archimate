import 'package:uuid/uuid.dart';

/// Model representing an invoice item in the application
class InvoiceItemModel {
  /// Creates a new [InvoiceItemModel] instance
  const InvoiceItemModel({
    required this.id,
    required this.description,
    required this.quantity,
    required this.unitPrice,
    this.taxRate = 0,
    this.invoiceId = '',
  });

  /// Unique identifier for the invoice item
  final String id;
  
  /// Description of the item
  final String description;
  
  /// Quantity of the item
  final double quantity;
  
  /// Unit price of the item
  final double unitPrice;
  
  /// Tax rate for the item (percentage)
  final double taxRate;
  
  /// ID of the invoice this item belongs to
  final String invoiceId;
  
  /// Total price of the item (quantity * unitPrice)
  double get total => quantity * unitPrice;
  
  /// Tax amount for the item (total * taxRate / 100)
  double get taxAmount => total * (taxRate / 100);
  
  /// Total price including tax
  double get totalWithTax => total + taxAmount;
  
  /// Creates a new [InvoiceItemModel] with some fields updated
  InvoiceItemModel copyWith({
    String? id,
    String? description,
    double? quantity,
    double? unitPrice,
    double? taxRate,
    String? invoiceId,
  }) {
    return InvoiceItemModel(
      id: id ?? this.id,
      description: description ?? this.description,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      taxRate: taxRate ?? this.taxRate,
      invoiceId: invoiceId ?? this.invoiceId,
    );
  }
  
  /// Creates a new [InvoiceItemModel] from a JSON object
  factory InvoiceItemModel.fromJson(Map<String, dynamic> json) {
    return InvoiceItemModel(
      id: json['id'] as String,
      description: json['description'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      unitPrice: (json['unit_price'] as num).toDouble(),
      taxRate: json['tax_rate'] != null ? (json['tax_rate'] as num).toDouble() : 0,
      invoiceId: json['invoice_id'] as String,
    );
  }
  
  /// Converts this model to a JSON object
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'quantity': quantity,
      'unit_price': unitPrice,
      'tax_rate': taxRate,
      'invoice_id': invoiceId,
    };
  }
  
  /// Creates a new [InvoiceItemModel] with a generated ID
  factory InvoiceItemModel.create({
    required String description,
    required double quantity,
    required double unitPrice,
    double taxRate = 0,
    String invoiceId = '',
  }) {
    return InvoiceItemModel(
      id: const Uuid().v4(),
      description: description,
      quantity: quantity,
      unitPrice: unitPrice,
      taxRate: taxRate,
      invoiceId: invoiceId,
    );
  }
}
