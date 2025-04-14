import 'package:multiple_result/multiple_result.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:archimate/data/datasources/remote/project_data_source.dart';
import 'package:archimate/data/models/project_model.dart';
import 'package:archimate/data/repositories/project_repository.dart';

/// Implementation of [ProjectRepository] using Supabase
class ProjectRepositoryImpl implements ProjectRepository {
  /// Creates a new [ProjectRepositoryImpl] instance
  ProjectRepositoryImpl({required ProjectDataSource dataSource})
      : _dataSource = dataSource;

  final ProjectDataSource _dataSource;

  @override
  Future<Result<List<ProjectModel>, ProjectError>> getAllProjects() async {
    try {
      final projects = await _dataSource.getAllProjects();
      return Success(projects);
    } on PostgrestException catch (e) {
      return Error(ProjectError(
        type: ProjectErrorType.fetchFailed,
        message: e.message,
        exception: e,
      ));
    } catch (e) {
      return Error(ProjectError(
        type: ProjectErrorType.unknown,
        message: e.toString(),
        exception: e,
      ));
    }
  }

  @override
  Future<Result<List<ProjectModel>, ProjectError>> getProjectsByClient(
      String clientId) async {
    try {
      final projects = await _dataSource.getProjectsByClient(clientId);
      return Success(projects);
    } on PostgrestException catch (e) {
      return Error(ProjectError(
        type: ProjectErrorType.fetchFailed,
        message: e.message,
        exception: e,
      ));
    } catch (e) {
      return Error(ProjectError(
        type: ProjectErrorType.unknown,
        message: e.toString(),
        exception: e,
      ));
    }
  }

  @override
  Future<Result<ProjectModel, ProjectError>> getProjectById(String id) async {
    try {
      final project = await _dataSource.getProjectById(id);
      return Success(project);
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') {
        return Error(ProjectError(
          type: ProjectErrorType.notFound,
          message: 'Project not found',
          exception: e,
        ));
      }
      return Error(ProjectError(
        type: ProjectErrorType.fetchFailed,
        message: e.message,
        exception: e,
      ));
    } catch (e) {
      return Error(ProjectError(
        type: ProjectErrorType.unknown,
        message: e.toString(),
        exception: e,
      ));
    }
  }

  @override
  Future<Result<ProjectModel, ProjectError>> createProject(
      ProjectModel project) async {
    try {
      final createdProject = await _dataSource.createProject(project);
      return Success(createdProject);
    } on PostgrestException catch (e) {
      return Error(ProjectError(
        type: ProjectErrorType.createFailed,
        message: e.message,
        exception: e,
      ));
    } catch (e) {
      return Error(ProjectError(
        type: ProjectErrorType.unknown,
        message: e.toString(),
        exception: e,
      ));
    }
  }

  @override
  Future<Result<ProjectModel, ProjectError>> updateProject(
      ProjectModel project) async {
    try {
      final updatedProject = await _dataSource.updateProject(project);
      return Success(updatedProject);
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') {
        return Error(ProjectError(
          type: ProjectErrorType.notFound,
          message: 'Project not found',
          exception: e,
        ));
      }
      return Error(ProjectError(
        type: ProjectErrorType.updateFailed,
        message: e.message,
        exception: e,
      ));
    } catch (e) {
      return Error(ProjectError(
        type: ProjectErrorType.unknown,
        message: e.toString(),
        exception: e,
      ));
    }
  }

  @override
  Future<Result<bool, ProjectError>> deleteProject(String id) async {
    try {
      await _dataSource.deleteProject(id);
      return const Success(true);
    } on PostgrestException catch (e) {
      return Error(ProjectError(
        type: ProjectErrorType.deleteFailed,
        message: e.message,
        exception: e,
      ));
    } catch (e) {
      return Error(ProjectError(
        type: ProjectErrorType.unknown,
        message: e.toString(),
        exception: e,
      ));
    }
  }

  @override
  Future<Result<List<ProjectModel>, ProjectError>> getProjectsByStatus(
      ProjectStatus status) async {
    try {
      final projects = await _dataSource.getProjectsByStatus(status);
      return Success(projects);
    } on PostgrestException catch (e) {
      return Error(ProjectError(
        type: ProjectErrorType.fetchFailed,
        message: e.message,
        exception: e,
      ));
    } catch (e) {
      return Error(ProjectError(
        type: ProjectErrorType.unknown,
        message: e.toString(),
        exception: e,
      ));
    }
  }

  @override
  Stream<List<ProjectModel>> watchProjects() {
    return _dataSource.watchProjects();
  }
}
