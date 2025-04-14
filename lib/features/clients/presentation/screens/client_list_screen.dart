import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:archimate/features/clients/presentation/providers/client_providers.dart';
import 'package:archimate/features/clients/presentation/widgets/client_card.dart';
import 'package:archimate/presentation/shared_widgets/custom_button.dart';

/// Screen that displays a list of clients
class ClientListScreen extends ConsumerStatefulWidget {
  /// Creates a new [ClientListScreen] instance
  const ClientListScreen({super.key});

  @override
  ConsumerState<ClientListScreen> createState() => _ClientListScreenState();
}

class _ClientListScreenState extends ConsumerState<ClientListScreen> {
  final _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final clientsAsync = _isSearching && _searchController.text.isNotEmpty
        ? ref.watch(searchClientsProvider(_searchController.text))
        : ref.watch(allClientsProvider);

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search clients...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6)),
                ),
                style: TextStyle(color: theme.colorScheme.onSurface),
                autofocus: true,
                onChanged: (value) {
                  setState(() {});
                },
              )
            : const Text('Clients'),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                if (_isSearching) {
                  _searchController.clear();
                }
                _isSearching = !_isSearching;
              });
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.architecture,
                    size: 48,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Archimate',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Project Management',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard_outlined),
              title: const Text('Projects'),
              onTap: () {
                Navigator.pop(context);
                context.goNamed('projects');
              },
            ),
            ListTile(
              leading: const Icon(Icons.people_outline),
              title: const Text('Clients'),
              selected: true,
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.receipt_long_outlined),
              title: const Text('Invoices'),
              onTap: () {
                Navigator.pop(context);
                context.goNamed('invoices');
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to settings
              },
            ),
          ],
        ),
      ),
      body: clientsAsync.when(
        data: (clients) {
          if (clients.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.people_outline,
                    size: 64,
                    color: theme.colorScheme.outline,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _isSearching
                        ? 'No clients found'
                        : 'No clients yet',
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isSearching
                        ? 'Try a different search term'
                        : 'Add your first client to get started',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                  if (!_isSearching) ...[
                    const SizedBox(height: 24),
                    CustomButton(
                      text: 'Add Client',
                      icon: Icons.add,
                      onPressed: () {
                        context.pushNamed('add-client');
                      },
                    ),
                  ],
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              if (_isSearching && _searchController.text.isNotEmpty) {
                ref.invalidate(searchClientsProvider(_searchController.text));
              } else {
                ref.invalidate(allClientsProvider);
              }
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: clients.length,
              itemBuilder: (context, index) {
                final client = clients[index];
                return ClientCard(
                  client: client,
                  onTap: () {
                    context.goNamed(
                      'client-detail',
                      pathParameters: {'id': client.id},
                    );
                  },
                  onEdit: () {
                    context.pushNamed('edit-client', pathParameters: {'id': client.id});
                  },
                );
              },
            ),
          );
        },
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
                'Error loading clients',
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
                  if (_isSearching && _searchController.text.isNotEmpty) {
                    ref.invalidate(searchClientsProvider(_searchController.text));
                  } else {
                    ref.invalidate(allClientsProvider);
                  }
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to create client screen
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
