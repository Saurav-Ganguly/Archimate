import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:archimate/data/models/project_model.dart';

/// A card widget that displays project information
class ProjectCard extends StatelessWidget {
  /// Creates a new [ProjectCard] instance
  const ProjectCard({
    super.key,
    required this.project,
    required this.onTap,
  });

  /// The project to display
  final ProjectModel project;
  
  /// Callback when the card is tapped
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currencyFormat = NumberFormat.currency(symbol: '\$');
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status indicator
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
              color: _getStatusColor(project.status, theme),
              child: Text(
                _getStatusText(project.status),
                style: theme.textTheme.labelMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Project name
                  Text(
                    project.name,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Project description
                  Text(
                    project.description,
                    style: theme.textTheme.bodyMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Project details
                  Row(
                    children: [
                      _buildDetailItem(
                        context,
                        Icons.calendar_today,
                        'Start: ${DateFormat('MMM d, y').format(project.startDate)}',
                      ),
                      const SizedBox(width: 16),
                      if (project.endDate != null)
                        _buildDetailItem(
                          context,
                          Icons.event,
                          'End: ${DateFormat('MMM d, y').format(project.endDate!)}',
                        ),
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  
                  Row(
                    children: [
                      _buildDetailItem(
                        context,
                        Icons.attach_money,
                        'Budget: ${currencyFormat.format(project.budget)}',
                      ),
                      const SizedBox(width: 16),
                      if (project.location != null)
                        _buildDetailItem(
                          context,
                          Icons.location_on_outlined,
                          project.location!,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(BuildContext context, IconData icon, String text) {
    final theme = Theme.of(context);
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
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
