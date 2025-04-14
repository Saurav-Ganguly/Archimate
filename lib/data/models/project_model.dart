import 'package:uuid/uuid.dart';

/// Status of a project
enum ProjectStatus {
  /// Project is in planning phase
  planning,
  
  /// Project is in progress
  inProgress,
  
  /// Project is on hold
  onHold,
  
  /// Project is completed
  completed,
  
  /// Project is cancelled
  cancelled,
}

/// Model representing a project in the application
class ProjectModel {
  /// Creates a new [ProjectModel] instance
  const ProjectModel({
    required this.id,
    required this.name,
    required this.description,
    required this.clientId,
    required this.status,
    required this.startDate,
    this.endDate,
    required this.budget,
    required this.createdAt,
    required this.updatedAt,
    this.assignedTeamMembers = const [],
    this.location,
    this.projectType,
    required this.userId,
  });

  /// Unique identifier for the project
  final String id;
  
  /// Name of the project
  final String name;
  
  /// Description of the project
  final String description;
  
  /// ID of the client associated with this project
  final String clientId;
  
  /// Current status of the project
  final ProjectStatus status;
  
  /// Start date of the project
  final DateTime startDate;
  
  /// End date of the project (if available)
  final DateTime? endDate;
  
  /// Budget for the project
  final double budget;
  
  /// When the project was created
  final DateTime createdAt;
  
  /// When the project was last updated
  final DateTime updatedAt;
  
  /// List of team members assigned to this project
  final List<String> assignedTeamMembers;
  
  /// Location of the project
  final String? location;
  
  /// Type of the project (residential, commercial, etc.)
  final String? projectType;
  
  /// ID of the user who owns this project
  final String userId;

  /// Creates a new [ProjectModel] with some fields updated
  ProjectModel copyWith({
    String? id,
    String? name,
    String? description,
    String? clientId,
    ProjectStatus? status,
    DateTime? startDate,
    DateTime? endDate,
    double? budget,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? assignedTeamMembers,
    String? location,
    String? projectType,
    String? userId,
  }) {
    return ProjectModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      clientId: clientId ?? this.clientId,
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      budget: budget ?? this.budget,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      assignedTeamMembers: assignedTeamMembers ?? this.assignedTeamMembers,
      location: location ?? this.location,
      projectType: projectType ?? this.projectType,
      userId: userId ?? this.userId,
    );
  }

  /// Creates a new project with default values
  factory ProjectModel.create({
    required String name,
    required String description,
    required String clientId,
    required double budget,
    required DateTime startDate,
    DateTime? endDate,
    String? location,
    String? projectType,
    List<String>? assignedTeamMembers,
    required String userId,
  }) {
    final now = DateTime.now();
    return ProjectModel(
      id: const Uuid().v4(),
      name: name,
      description: description,
      clientId: clientId,
      status: ProjectStatus.planning,
      startDate: startDate,
      endDate: endDate,
      budget: budget,
      createdAt: now,
      updatedAt: now,
      assignedTeamMembers: assignedTeamMembers ?? [],
      location: location,
      projectType: projectType,
      userId: userId,
    );
  }

  /// Creates a [ProjectModel] from JSON data
  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      clientId: json['client_id'] as String,
      status: ProjectStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => ProjectStatus.planning,
      ),
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: json['end_date'] != null
          ? DateTime.parse(json['end_date'] as String)
          : null,
      budget: (json['budget'] as num).toDouble(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      assignedTeamMembers: (json['assigned_team_members'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      location: json['location'] as String?,
      projectType: json['project_type'] as String?,
      userId: json['user_id'] as String,
    );
  }

  /// Converts the [ProjectModel] to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'client_id': clientId,
      'status': status.name,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'budget': budget,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'assigned_team_members': assignedTeamMembers,
      'location': location,
      'project_type': projectType,
      'user_id': userId,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProjectModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
