import 'package:uuid/uuid.dart';

/// Model representing a client in the application
class ClientModel {
  /// Creates a new [ClientModel] instance
  const ClientModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.address,
    this.company,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    required this.userId,
  });

  /// Unique identifier for the client
  final String id;
  
  /// Name of the client
  final String name;
  
  /// Email address of the client
  final String email;
  
  /// Phone number of the client
  final String? phone;
  
  /// Physical address of the client
  final String? address;
  
  /// Company name of the client
  final String? company;
  
  /// Additional notes about the client
  final String? notes;
  
  /// When the client was created
  final DateTime createdAt;
  
  /// When the client was last updated
  final DateTime updatedAt;
  
  /// ID of the user who owns this client
  final String userId;

  /// Creates a new [ClientModel] with some fields updated
  ClientModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? address,
    String? company,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? userId,
  }) {
    return ClientModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      company: company ?? this.company,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      userId: userId ?? this.userId,
    );
  }

  /// Creates a new client with default values
  factory ClientModel.create({
    required String name,
    required String email,
    String? phone,
    String? address,
    String? company,
    String? notes,
    required String userId,
  }) {
    final now = DateTime.now();
    return ClientModel(
      id: const Uuid().v4(),
      name: name,
      email: email,
      phone: phone,
      address: address,
      company: company,
      notes: notes,
      createdAt: now,
      updatedAt: now,
      userId: userId,
    );
  }

  /// Creates a [ClientModel] from JSON data
  factory ClientModel.fromJson(Map<String, dynamic> json) {
    return ClientModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      company: json['company'] as String?,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      userId: json['user_id'] as String,
    );
  }

  /// Converts the [ClientModel] to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'company': company,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'user_id': userId,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ClientModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
