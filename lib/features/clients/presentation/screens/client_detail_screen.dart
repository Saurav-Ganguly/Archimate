import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:archimate/features/clients/presentation/providers/client_providers.dart';
import 'package:archimate/features/projects/presentation/providers/project_providers.dart';
import 'package:archimate/features/projects/presentation/widgets/project_card.dart';
import 'package:archimate/presentation/shared_widgets/custom_button.dart';

/// Screen that displays client details
class ClientDetailScreen extends ConsumerWidget {
  /// Creates a new [ClientDetailScreen] instance
  const ClientDetailScreen({
    super.key,
    required this.clientId,
  });

  /// ID of the client to display
  final String clientId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final clientAsync = ref.watch(clientByIdProvider(clientId));
    final projectsAsync = ref.watch(projectsByClientProvider(clientId));
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Client Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // Navigate to edit client screen
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
      body: clientAsync.when(
        data: (client) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Client header
              Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: theme.colorScheme.primary,
                    child: Text(
                      _getInitials(client.name),
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: theme.colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          client.name,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (client.company != null && client.company!.isNotEmpty)
                          Text(
                            client.company!,
                            style: theme.textTheme.titleMedium,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Contact information section
              _buildSectionTitle(context, 'Contact Information'),
              
              const SizedBox(height: 8),
              
              _buildContactItem(
                context,
                Icons.email_outlined,
                'Email',
                client.email,
                onTap: () {
                  // Launch email app
                },
              ),
              
              if (client.phone != null && client.phone!.isNotEmpty)
                _buildContactItem(
                  context,
                  Icons.phone_outlined,
                  'Phone',
                  client.phone!,
                  onTap: () {
                    // Launch phone app
                  },
                ),
              
              if (client.address != null && client.address!.isNotEmpty)
                _buildContactItem(
                  context,
                  Icons.location_on_outlined,
                  'Address',
                  client.address!,
                  onTap: () {
                    // Launch maps app
                  },
                ),
              
              const SizedBox(height: 24),
              
              // Notes section
              _buildSectionTitle(context, 'Notes'),
              
              const SizedBox(height: 8),
              
              if (client.notes != null && client.notes!.isNotEmpty)
                Text(client.notes!)
              else
                Text(
                  'No notes available',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.outline,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              
              const SizedBox(height: 24),
              
              // Projects section
              _buildSectionTitle(context, 'Projects'),
              
              const SizedBox(height: 8),
              
              projectsAsync.when(
                data: (projects) {
                  if (projects.isEmpty) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'No projects for this client',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.outline,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        const SizedBox(height: 16),
                        CustomButton(
                          text: 'Create Project',
                          icon: Icons.add,
                          onPressed: () {
                            // Navigate to create project screen
                          },
                        ),
                      ],
                    );
                  }
                  
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ...projects.map((project) => ProjectCard(
                        project: project,
                        onTap: () {
                          context.goNamed(
                            'project-detail',
                            pathParameters: {'id': project.id},
                          );
                        },
                      )),
                      const SizedBox(height: 16),
                      CustomButton(
                        text: 'Create Project',
                        icon: Icons.add,
                        onPressed: () {
                          // Navigate to create project screen
                        },
                      ),
                    ],
                  );
                },
                loading: () => const Center(
                  child: CircularProgressIndicator(),
                ),
                error: (error, stackTrace) => Text(
                  'Error loading projects: ${error.toString()}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
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
                        // Navigate to client invoices
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomButton(
                      text: 'Create Invoice',
                      icon: Icons.add,
                      onPressed: () {
                        // Navigate to create invoice for this client
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
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
                'Error loading client',
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
                  ref.invalidate(clientByIdProvider(clientId));
                },
              ),
            ],
          ),
        ),
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

  Widget _buildContactItem(
    BuildContext context,
    IconData icon,
    String label,
    String value, {
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(
              icon,
              size: 24,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.bodySmall?.copyWith(
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
            if (onTap != null)
              Icon(
                Icons.open_in_new,
                size: 16,
                color: theme.colorScheme.primary,
              ),
          ],
        ),
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
              title: const Text('Edit Client'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to edit client screen
              },
            ),
            ListTile(
              leading: Icon(
                Icons.content_copy,
                color: theme.colorScheme.primary,
              ),
              title: const Text('Duplicate Client'),
              onTap: () {
                Navigator.pop(context);
                // Duplicate client logic
              },
            ),
            ListTile(
              leading: Icon(
                Icons.delete_outline,
                color: theme.colorScheme.error,
              ),
              title: Text(
                'Delete Client',
                style: TextStyle(
                  color: theme.colorScheme.error,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _confirmDeleteClient(context, ref);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteClient(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Client'),
        content: const Text(
          'Are you sure you want to delete this client? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteClient(context, ref);
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

  Future<void> _deleteClient(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(clientNotifierProvider.notifier).deleteClient(clientId);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Client deleted successfully'),
          ),
        );
        context.goNamed('clients');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete client: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  /// Get the initials from a name (e.g., "John Doe" -> "JD")
  String _getInitials(String name) {
    if (name.isEmpty) return '';
    
    final parts = name.trim().split(' ');
    if (parts.length == 1) {
      return parts[0][0].toUpperCase();
    }
    
    return parts[0][0].toUpperCase() + parts.last[0].toUpperCase();
  }
}
