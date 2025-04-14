import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:archimate/data/models/project_model.dart';
import 'package:archimate/features/projects/presentation/providers/project_providers.dart';
import 'package:archimate/presentation/shared_widgets/custom_button.dart';

/// Screen that displays project details
class ProjectDetailScreen extends ConsumerWidget {
  /// Creates a new [ProjectDetailScreen] instance
  const ProjectDetailScreen({
    super.key,
    required this.projectId,
  });

  /// ID of the project to display
  final String projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final projectAsync = ref.watch(projectByIdProvider(projectId));
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Project Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // Navigate to edit project screen
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              _showOptionsMenu(context, ref);
            },
          ),
        ],
      ),
      body: projectAsync.when(
        data: (project) => _buildProjectDetails(context, project),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 48,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                'Error loading project',
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: theme.textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              CustomButton(
                text: 'Retry',
                icon: Icons.refresh,
                onPressed: () {
                  ref.invalidate(projectByIdProvider(projectId));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProjectDetails(BuildContext context, ProjectModel project) {
    final theme = Theme.of(context);
    final currencyFormat = NumberFormat.currency(symbol: '\$');
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status indicator
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            decoration: BoxDecoration(
              color: _getStatusColor(project.status, theme),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _getStatusText(project.status),
              style: theme.textTheme.titleSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Project name
          Text(
            project.name,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Project description
          Text(
            project.description,
            style: theme.textTheme.bodyLarge,
          ),
          
          const SizedBox(height: 24),
          
          // Project details section
          _buildSectionTitle(context, 'Project Details'),
          
          const SizedBox(height: 8),
          
          _buildDetailItem(
            context,
            Icons.calendar_today,
            'Start Date',
            DateFormat('MMMM d, y').format(project.startDate),
          ),
          
          if (project.endDate != null)
            _buildDetailItem(
              context,
              Icons.event,
              'End Date',
              DateFormat('MMMM d, y').format(project.endDate!),
            ),
          
          _buildDetailItem(
            context,
            Icons.attach_money,
            'Budget',
            currencyFormat.format(project.budget),
          ),
          
          if (project.location != null)
            _buildDetailItem(
              context,
              Icons.location_on_outlined,
              'Location',
              project.location!,
            ),
          
          if (project.projectType != null)
            _buildDetailItem(
              context,
              Icons.category_outlined,
              'Project Type',
              project.projectType!,
            ),
          
          const SizedBox(height: 24),
          
          // Team section
          _buildSectionTitle(context, 'Team Members'),
          
          const SizedBox(height: 8),
          
          if (project.assignedTeamMembers.isEmpty)
            Text(
              'No team members assigned',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.outline,
                fontStyle: FontStyle.italic,
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: project.assignedTeamMembers.length,
              itemBuilder: (context, index) {
                final member = project.assignedTeamMembers[index];
                return ListTile(
                  leading: CircleAvatar(
                    child: Text(member.substring(0, 1).toUpperCase()),
                  ),
                  title: Text(member),
                  contentPadding: EdgeInsets.zero,
                );
              },
            ),
          
          const SizedBox(height: 24),
          
          // Action buttons
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  text: 'View Invoices',
                  icon: Icons.receipt_long_outlined,
                  isOutlined: true,
                  onPressed: () {
                    // Navigate to project invoices
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: CustomButton(
                  text: 'View Files',
                  icon: Icons.folder_outlined,
                  isOutlined: true,
                  onPressed: () {
                    // Navigate to project files
                  },
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          CustomButton(
            text: 'Create Invoice',
            icon: Icons.add,
            onPressed: () {
              // Navigate to create invoice for this project
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Divider(
          color: theme.colorScheme.outline.withOpacity(0.5),
          thickness: 1,
        ),
      ],
    );
  }

  Widget _buildDetailItem(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
                Text(
                  value,
                  style: theme.textTheme.bodyLarge,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showOptionsMenu(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(
                Icons.edit,
                color: theme.colorScheme.primary,
              ),
              title: const Text('Edit Project'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to edit project screen
              },
            ),
            ListTile(
              leading: Icon(
                Icons.content_copy,
                color: theme.colorScheme.primary,
              ),
              title: const Text('Duplicate Project'),
              onTap: () {
                Navigator.pop(context);
                // Duplicate project logic
              },
            ),
            ListTile(
              leading: Icon(
                Icons.archive_outlined,
                color: theme.colorScheme.primary,
              ),
              title: const Text('Archive Project'),
              onTap: () {
                Navigator.pop(context);
                // Archive project logic
              },
            ),
            ListTile(
              leading: Icon(
                Icons.delete_outline,
                color: theme.colorScheme.error,
              ),
              title: Text(
                'Delete Project',
                style: TextStyle(
                  color: theme.colorScheme.error,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _confirmDeleteProject(context, ref);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteProject(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Project'),
        content: const Text(
          'Are you sure you want to delete this project? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteProject(context, ref);
            },
            child: Text(
              'Delete',
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteProject(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(projectNotifierProvider.notifier).deleteProject(projectId);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Project deleted successfully'),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete project: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Color _getStatusColor(ProjectStatus status, ThemeData theme) {
    switch (status) {
      case ProjectStatus.planning:
        return Colors.blue;
      case ProjectStatus.inProgress:
        return theme.colorScheme.primary;
      case ProjectStatus.onHold:
        return Colors.orange;
      case ProjectStatus.completed:
        return Colors.green;
      case ProjectStatus.cancelled:
        return Colors.red;
    }
  }

  String _getStatusText(ProjectStatus status) {
    switch (status) {
      case ProjectStatus.planning:
        return 'Planning';
      case ProjectStatus.inProgress:
        return 'In Progress';
      case ProjectStatus.onHold:
        return 'On Hold';
      case ProjectStatus.completed:
        return 'Completed';
      case ProjectStatus.cancelled:
        return 'Cancelled';
    }
  }
}
