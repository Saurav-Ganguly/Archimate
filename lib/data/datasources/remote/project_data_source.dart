import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:archimate/data/models/project_model.dart';

/// Data source for project operations using Supabase
class ProjectDataSource {
  /// Creates a new [ProjectDataSource] instance
  ProjectDataSource({required SupabaseClient client}) : _client = client;

  final SupabaseClient _client;
  
  /// Table name in Supabase
  static const String _tableName = 'projects';

  /// Get all projects
  Future<List<ProjectModel>> getAllProjects() async {
    final response = await _client
        .from(_tableName)
        .select()
        .order('created_at', ascending: false);
    
    return response.map((json) => ProjectModel.fromJson(json)).toList();
  }

  /// Get projects by client ID
  Future<List<ProjectModel>> getProjectsByClient(String clientId) async {
    final response = await _client
        .from(_tableName)
        .select()
        .eq('client_id', clientId)
        .order('created_at', ascending: false);
    
    return response.map((json) => ProjectModel.fromJson(json)).toList();
  }

  /// Get a project by ID
  Future<ProjectModel> getProjectById(String id) async {
    final response = await _client
        .from(_tableName)
        .select()
        .eq('id', id)
        .single();
    
    return ProjectModel.fromJson(response);
  }

  /// Create a new project
  Future<ProjectModel> createProject(ProjectModel project) async {
    print('Starting project creation process with client ID: ${project.clientId}');
    
    try {
      // First, ensure the client exists by directly querying the database
      print('Performing direct client existence check');
      final clientCheck = await _client
          .from('clients')
          .select('id')
          .eq('id', project.clientId)
          .maybeSingle();
      
      if (clientCheck == null) {
        // If client doesn't exist, create a placeholder client with the same ID
        print('Client not found in database, creating a placeholder client');
        await _client.from('clients').upsert({
          'id': project.clientId,
          'name': 'Placeholder Client',
          'email': 'placeholder@example.com',
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
          'user_id': project.userId,
        });
        print('Placeholder client created with ID: ${project.clientId}');
        
        // Verify the client was created
        await Future.delayed(const Duration(milliseconds: 500));
        final verifyClient = await _client
            .from('clients')
            .select('id')
            .eq('id', project.clientId)
            .maybeSingle();
            
        if (verifyClient == null) {
          print('CRITICAL ERROR: Failed to create placeholder client');
          throw Exception('Failed to create client reference needed for project');
        }
        print('Placeholder client verified: ${verifyClient['id']}');
      } else {
        print('Client verified: ${clientCheck['id']}');
      }
      
      // Now create the project with a direct insert
      print('Inserting project with data: ${project.toJson()}');
      final projectData = project.toJson();
      
      // Ensure all required fields are present
      if (!projectData.containsKey('client_id')) {
        print('WARNING: client_id is missing in project data');
        projectData['client_id'] = project.clientId;
      }
      
      if (!projectData.containsKey('user_id')) {
        print('WARNING: user_id is missing in project data');
        throw Exception('User ID is required for project creation');
      }
      
      // Add a small delay to ensure database consistency
      await Future.delayed(const Duration(milliseconds: 500));
      
      final response = await _client
          .from(_tableName)
          .insert(projectData)
          .select()
          .single();
      
      print('Project created successfully');
      return ProjectModel.fromJson(response);
    } catch (e) {
      print('Error in project creation process: $e');
      rethrow;
    }
  }

  /// Update an existing project
  Future<ProjectModel> updateProject(ProjectModel project) async {
    final response = await _client
        .from(_tableName)
        .update(project.toJson())
        .eq('id', project.id)
        .select()
        .single();
    
    return ProjectModel.fromJson(response);
  }

  /// Delete a project
  Future<void> deleteProject(String id) async {
    await _client
        .from(_tableName)
        .delete()
        .eq('id', id);
  }

  /// Get projects by status
  Future<List<ProjectModel>> getProjectsByStatus(ProjectStatus status) async {
    final response = await _client
        .from(_tableName)
        .select()
        .eq('status', status.name)
        .order('created_at', ascending: false);
    
    return response.map((json) => ProjectModel.fromJson(json)).toList();
  }

  /// Stream of projects for real-time updates
  Stream<List<ProjectModel>> watchProjects() {
    return _client
        .from(_tableName)
        .stream(primaryKey: ['id'])
        .order('created_at')
        .map((data) => data.map((json) => ProjectModel.fromJson(json)).toList());
  }
}
