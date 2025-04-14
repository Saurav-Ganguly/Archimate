import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:archimate/core/providers/repository_providers.dart';
import 'package:archimate/data/models/project_model.dart';

/// Provider for all projects
final allProjectsProvider = FutureProvider<List<ProjectModel>>((ref) async {
  final repository = ref.watch(projectRepositoryProvider);
  final result = await repository.getAllProjects();
  
  return result.when(
    (projects) => projects,
    (error) => throw error,
  );
});

/// Provider for projects by status
final projectsByStatusProvider = FutureProvider.family<List<ProjectModel>, ProjectStatus>((ref, status) async {
  final repository = ref.watch(projectRepositoryProvider);
  final result = await repository.getProjectsByStatus(status);
  
  return result.when(
    (projects) => projects,
    (error) => throw error,
  );
});

/// Provider for projects by client
final projectsByClientProvider = FutureProvider.family<List<ProjectModel>, String>((ref, clientId) async {
  final repository = ref.watch(projectRepositoryProvider);
  final result = await repository.getProjectsByClient(clientId);
  
  return result.when(
    (projects) => projects,
    (error) => throw error,
  );
});

/// Provider for a single project by ID
final projectByIdProvider = FutureProvider.family<ProjectModel, String>((ref, id) async {
  final repository = ref.watch(projectRepositoryProvider);
  final result = await repository.getProjectById(id);
  
  return result.when(
    (project) => project,
    (error) => throw error,
  );
});

/// Notifier for project operations
class ProjectNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {
    // Nothing to initialize
  }
  
  /// Create a new project
  Future<ProjectModel> createProject(ProjectModel project) async {
    state = const AsyncValue.loading();
    
    try {
      final repository = ref.read(projectRepositoryProvider);
      final result = await repository.createProject(project);
      
      return result.when(
        (createdProject) {
          state = const AsyncValue.data(null);
          ref.invalidate(allProjectsProvider);
          ref.invalidate(projectsByStatusProvider(project.status));
          ref.invalidate(projectsByClientProvider(project.clientId));
          return createdProject;
        },
        (error) {
          state = AsyncValue.error(error, StackTrace.current);
          throw error;
        },
      );
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }
  
  /// Update an existing project
  Future<ProjectModel> updateProject(ProjectModel project) async {
    state = const AsyncValue.loading();
    
    try {
      final repository = ref.read(projectRepositoryProvider);
      final result = await repository.updateProject(project);
      
      return result.when(
        (updatedProject) {
          state = const AsyncValue.data(null);
          ref.invalidate(allProjectsProvider);
          ref.invalidate(projectsByStatusProvider(project.status));
          ref.invalidate(projectsByClientProvider(project.clientId));
          ref.invalidate(projectByIdProvider(project.id));
          return updatedProject;
        },
        (error) {
          state = AsyncValue.error(error, StackTrace.current);
          throw error;
        },
      );
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }
  
  /// Delete a project
  Future<void> deleteProject(String id) async {
    state = const AsyncValue.loading();
    
    try {
      final repository = ref.read(projectRepositoryProvider);
      final result = await repository.deleteProject(id);
      
      result.when(
        (_) {
          state = const AsyncValue.data(null);
          ref.invalidate(allProjectsProvider);
          // We don't know the status or client ID here, so we can't invalidate those specific providers
          // In a real app, we might want to fetch the project first to get those details
        },
        (error) {
          state = AsyncValue.error(error, StackTrace.current);
          throw error;
        },
      );
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }
}

/// Provider for the project notifier
final projectNotifierProvider = AsyncNotifierProvider<ProjectNotifier, void>(() {
  return ProjectNotifier();
});
