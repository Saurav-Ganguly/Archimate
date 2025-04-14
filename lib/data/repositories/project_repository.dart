import 'package:multiple_result/multiple_result.dart';
import 'package:archimate/data/models/project_model.dart';

/// Error types for project operations
enum ProjectErrorType {
  /// Failed to fetch projects
  fetchFailed,
  
  /// Failed to create project
  createFailed,
  
  /// Failed to update project
  updateFailed,
  
  /// Failed to delete project
  deleteFailed,
  
  /// Project not found
  notFound,
  
  /// Network error
  network,
  
  /// Unknown error
  unknown,
}

/// Error class for project operations
class ProjectError {
  /// Creates a new [ProjectError]
  const ProjectError({
    required this.type,
    this.message,
    this.exception,
  });

  /// Type of error
  final ProjectErrorType type;
  
  /// Error message
  final String? message;
  
  /// Original exception
  final Object? exception;
  
  @override
  String toString() {
    return message ?? 'Error: ${type.toString().split('.').last}';
  }
}

/// Repository interface for project operations
abstract class ProjectRepository {
  /// Get all projects
  Future<Result<List<ProjectModel>, ProjectError>> getAllProjects();
  
  /// Get projects by client ID
  Future<Result<List<ProjectModel>, ProjectError>> getProjectsByClient(String clientId);
  
  /// Get a project by ID
  Future<Result<ProjectModel, ProjectError>> getProjectById(String id);
  
  /// Create a new project
  Future<Result<ProjectModel, ProjectError>> createProject(ProjectModel project);
  
  /// Update an existing project
  Future<Result<ProjectModel, ProjectError>> updateProject(ProjectModel project);
  
  /// Delete a project
  Future<Result<bool, ProjectError>> deleteProject(String id);
  
  /// Get projects by status
  Future<Result<List<ProjectModel>, ProjectError>> getProjectsByStatus(ProjectStatus status);
  
  /// Stream of projects for real-time updates
  Stream<List<ProjectModel>> watchProjects();
}
