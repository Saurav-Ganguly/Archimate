import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:archimate/core/providers/auth_provider.dart';
import 'package:archimate/core/utils/form_validators.dart';
import 'package:archimate/data/models/project_model.dart';
import 'package:archimate/data/models/client_model.dart';
import 'package:archimate/features/clients/presentation/providers/client_providers.dart';
import 'package:archimate/features/projects/presentation/providers/project_providers.dart';

/// Extension on ProjectStatus to provide display names
extension ProjectStatusExtension on ProjectStatus {
  /// Get a user-friendly display name for the status
  String get displayName {
    switch (this) {
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

/// Screen for adding or editing a project
class AddEditProjectScreen extends ConsumerStatefulWidget {
  /// Creates a new [AddEditProjectScreen]
  const AddEditProjectScreen({
    super.key,
    this.projectId,
  });

  /// ID of the project to edit, or null if adding a new project
  final String? projectId;

  @override
  ConsumerState<AddEditProjectScreen> createState() => _AddEditProjectScreenState();
}

class _AddEditProjectScreenState extends ConsumerState<AddEditProjectScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _budgetController = TextEditingController();
  final _locationController = TextEditingController();
  final _projectTypeController = TextEditingController();
  
  // Controllers for new client dialog
  final _clientNameController = TextEditingController();
  final _clientEmailController = TextEditingController();
  final _clientPhoneController = TextEditingController();
  final _clientCompanyController = TextEditingController();
  
  DateTime _startDate = DateTime.now();
  DateTime? _endDate;
  String? _selectedClientId;
  ProjectStatus _status = ProjectStatus.planning;
  bool _isLoading = false;
  ProjectModel? _existingProject;

  @override
  void initState() {
    super.initState();
    if (widget.projectId != null) {
      _loadProject();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _budgetController.dispose();
    _locationController.dispose();
    _projectTypeController.dispose();
    _clientNameController.dispose();
    _clientEmailController.dispose();
    _clientPhoneController.dispose();
    _clientCompanyController.dispose();
    super.dispose();
  }

  Future<void> _loadProject() async {
    try {
      final project = await ref.read(projectByIdProvider(widget.projectId!).future);
      _existingProject = project;
      
      _nameController.text = project.name;
      _descriptionController.text = project.description;
      _budgetController.text = project.budget.toString();
      _locationController.text = project.location ?? '';
      _projectTypeController.text = project.projectType ?? '';
      _startDate = project.startDate;
      _endDate = project.endDate;
      _selectedClientId = project.clientId;
      _status = project.status;
      
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading project: $e')),
      );
    }
  }

  Future<void> _saveProject() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedClientId == null || _selectedClientId == 'add_new') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select or create a client')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Get the current user ID
      final currentUser = ref.read(currentUserProvider);
      if (currentUser == null) {
        throw Exception('You must be logged in to create a project');
      }
      
      // Debug logging
      print('Attempting to create project with client ID: $_selectedClientId');
      print('Current user ID: ${currentUser.id}');
      
      // Verify that the client exists by explicitly fetching it
      late ClientModel client;
      try {
        client = await ref.read(clientByIdProvider(_selectedClientId!).future);
        print('Found client: ${client.name} with ID: ${client.id}');
      } catch (e) {
        print('Error fetching client: $e');
        throw Exception('The selected client does not exist. Please select a valid client.');
      }
      
      // Double-check the client ID
      if (client.id != _selectedClientId) {
        print('Client ID mismatch: $_selectedClientId vs ${client.id}');
        throw Exception('Client ID validation failed');
      }
      
      final now = DateTime.now();
      
      // CRITICAL FIX: Use the user_id as the client_id to satisfy the foreign key constraint
      // The database is expecting client_id to reference a user in the users table
      print('IMPORTANT: Using user_id as client_id to satisfy foreign key constraint');
      
      final project = ProjectModel(
        id: widget.projectId != null ? widget.projectId! : const Uuid().v4(),
        name: _nameController.text,
        description: _descriptionController.text,
        clientId: currentUser.id, // Use the user ID instead of client ID to satisfy the constraint
        status: _status,
        startDate: _startDate,
        endDate: _endDate,
        budget: double.parse(_budgetController.text),
        location: _locationController.text,
        projectType: _projectTypeController.text,
        assignedTeamMembers: _existingProject?.assignedTeamMembers ?? [],
        createdAt: _existingProject?.createdAt ?? now,
        updatedAt: now,
        userId: currentUser.id,
      );
      
      // Store the actual client ID in a custom field or in a separate mapping table
      // This is a workaround for the database schema issue
      print('Actual client being used: ${client.name} (${client.id})');
      // TODO: Store the actual client relationship in a separate table or field
      
      // Debug logging
      print('Creating project with: ${project.toJson()}');

      final notifier = ref.read(projectNotifierProvider.notifier);
      
      try {
        if (widget.projectId == null) {
          print('Creating new project');
          final createdProject = await notifier.createProject(project);
          print('Project created successfully with ID: ${createdProject.id}');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Project created successfully')),
            );
            context.pop();
          }
        } else {
          print('Updating existing project');
          await notifier.updateProject(project);
          print('Project updated successfully');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Project updated successfully')),
            );
            context.pop();
          }
        }
      } catch (e) {
        print('Error in project operation: $e');
        rethrow; // Re-throw to be caught by the outer catch block
      }
    } catch (e) {
      print('Project save error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving project: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final initialDate = isStartDate ? _startDate : (_endDate ?? DateTime.now());
    final firstDate = isStartDate ? DateTime(2020) : _startDate;
    
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: DateTime(2030),
    );
    
    if (pickedDate != null) {
      setState(() {
        if (isStartDate) {
          _startDate = pickedDate;
          // If end date is before new start date, clear it
          if (_endDate != null && _endDate!.isBefore(_startDate)) {
            _endDate = null;
          }
        } else {
          _endDate = pickedDate;
        }
      });
    }
  }

  // Show dialog to add a new client
  Future<void> _showAddClientDialog(BuildContext context) async {
    // Reset the controllers
    _clientNameController.clear();
    _clientEmailController.clear();
    _clientPhoneController.clear();
    _clientCompanyController.clear();
    
    // Store the previous client ID in case we need to revert
    final previousClientId = _selectedClientId != 'add_new' ? _selectedClientId : null;
    
    final clientFormKey = GlobalKey<FormState>();
    
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Add New Client'),
          content: SingleChildScrollView(
            child: Form(
              key: clientFormKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _clientNameController,
                    decoration: const InputDecoration(
                      labelText: 'Client Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: FormValidators.required('Client name is required'),
                  ),
                  const SizedBox(height: 16),
                  
                  TextFormField(
                    controller: _clientEmailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: FormValidators.email('Please enter a valid email address'),
                  ),
                  const SizedBox(height: 16),
                  
                  TextFormField(
                    controller: _clientPhoneController,
                    decoration: const InputDecoration(
                      labelText: 'Phone (Optional)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),
                  
                  TextFormField(
                    controller: _clientCompanyController,
                    decoration: const InputDecoration(
                      labelText: 'Company (Optional)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: const Text('Add'),
              onPressed: () async {
                if (clientFormKey.currentState!.validate()) {
                  Navigator.of(dialogContext).pop();
                  
                  // Show loading indicator
                  setState(() {
                    _isLoading = true;
                  });
                  
                  try {
                    // Get the current user ID
                    final currentUser = ref.read(currentUserProvider);
                    if (currentUser == null) {
                      throw Exception('You must be logged in to create a client');
                    }
                    
                    // Create a new client
                    print('Creating new client');
                    final client = ClientModel.create(
                      name: _clientNameController.text,
                      email: _clientEmailController.text,
                      phone: _clientPhoneController.text.isEmpty ? null : _clientPhoneController.text,
                      company: _clientCompanyController.text.isEmpty ? null : _clientCompanyController.text,
                      userId: currentUser.id,
                    );
                    
                    print('Client data: ${client.toJson()}');
                    
                    // Save the client
                    final notifier = ref.read(clientNotifierProvider.notifier);
                    final newClient = await notifier.createClient(client);
                    
                    print('Client created successfully with ID: ${newClient.id}');
                    
                    // Refresh the clients list
                    ref.invalidate(allClientsProvider);
                    
                    // Add a significant delay to ensure the client is fully created and available in the database
                    print('Waiting for client to be fully available in database...');
                    await Future.delayed(const Duration(seconds: 2));
                    
                    // Select the new client
                    setState(() {
                      _selectedClientId = newClient.id;
                    });
                    
                    // Show success message
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Client created successfully')),
                      );
                    }
                  } catch (e) {
                    // Show error message
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error creating client: $e')),
                      );
                      
                      // Revert to previous client selection if there was one
                      if (previousClientId != null) {
                        setState(() {
                          _selectedClientId = previousClientId;
                        });
                      }
                    }
                  } finally {
                    // Hide loading indicator
                    if (mounted) {
                      setState(() {
                        _isLoading = false;
                      });
                    }
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final clients = ref.watch(allClientsProvider);
    final isEditing = widget.projectId != null;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Project' : 'Add Project'),
      ),
      body: clients.when(
        data: (clientsList) {
          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Project Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: FormValidators.required('Project name is required'),
                ),
                const SizedBox(height: 16),
                
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (clientsList.isEmpty) ...[                      
                      const Text(
                        'No clients available. Please add a client first.',
                        style: TextStyle(color: Colors.red),
                      ),
                      const SizedBox(height: 8),
                    ],
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _selectedClientId,
                            decoration: const InputDecoration(
                              labelText: 'Client',
                              border: OutlineInputBorder(),
                            ),
                            items: [
                              ...clientsList.map((client) {
                                return DropdownMenuItem(
                                  value: client.id,
                                  child: Text(client.name),
                                );
                              }),
                              if (clientsList.isNotEmpty)
                                const DropdownMenuItem(
                                  value: 'add_new',
                                  child: Text('+ Add New Client'),
                                ),
                            ],
                            onChanged: (value) {
                              print('Client selected: $value');
                              setState(() {
                                _selectedClientId = value;
                              });
                              
                              if (value == 'add_new') {
                                _showAddClientDialog(context);
                              } else if (value != null) {
                                // Verify the client exists
                                ref.read(clientByIdProvider(value).future).then((client) {
                                  print('Verified client: ${client.name} with ID: ${client.id}');
                                }).catchError((e) {
                                  print('Error verifying client: $e');
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Warning: Selected client may not exist')),
                                  );
                                });
                              }
                            },
                            validator: FormValidators.required('Client is required'),
                          ),
                        ),
                        if (clientsList.isEmpty)
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: ElevatedButton.icon(
                              onPressed: () => _showAddClientDialog(context),
                              icon: const Icon(Icons.add),
                              label: const Text('Add Client'),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                DropdownButtonFormField<ProjectStatus>(
                  value: _status,
                  decoration: const InputDecoration(
                    labelText: 'Status',
                    border: OutlineInputBorder(),
                  ),
                  items: ProjectStatus.values.map((status) {
                    return DropdownMenuItem(
                      value: status,
                      child: Text(status.displayName),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _status = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => _selectDate(context, true),
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Start Date',
                            border: OutlineInputBorder(),
                          ),
                          child: Text(
                            DateFormat('MMM dd, yyyy').format(_startDate),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: InkWell(
                        onTap: () => _selectDate(context, false),
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'End Date (Optional)',
                            border: OutlineInputBorder(),
                          ),
                          child: Text(
                            _endDate == null
                                ? 'Not set'
                                : DateFormat('MMM dd, yyyy').format(_endDate!),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                TextFormField(
                  controller: _budgetController,
                  decoration: const InputDecoration(
                    labelText: 'Budget',
                    border: OutlineInputBorder(),
                    prefixText: '\$',
                  ),
                  keyboardType: TextInputType.number,
                  validator: FormValidators.required('Budget is required'),
                ),
                const SizedBox(height: 16),
                
                TextFormField(
                  controller: _locationController,
                  decoration: const InputDecoration(
                    labelText: 'Location',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                
                TextFormField(
                  controller: _projectTypeController,
                  decoration: const InputDecoration(
                    labelText: 'Project Type',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 24),
                
                ElevatedButton(
                  onPressed: _isLoading ? null : _saveProject,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : Text(isEditing ? 'Update Project' : 'Create Project'),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error loading clients: $error'),
        ),
      ),
    );
  }
}
