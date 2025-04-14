import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:archimate/core/providers/auth_provider.dart';
import 'package:archimate/core/utils/form_validators.dart';
import 'package:archimate/data/models/client_model.dart';
import 'package:archimate/features/clients/presentation/providers/client_providers.dart';

/// Screen for adding or editing a client
class AddEditClientScreen extends ConsumerStatefulWidget {
  /// Creates a new [AddEditClientScreen]
  const AddEditClientScreen({
    super.key,
    this.clientId,
  });

  /// ID of the client to edit, or null if adding a new client
  final String? clientId;

  @override
  ConsumerState<AddEditClientScreen> createState() => _AddEditClientScreenState();
}

class _AddEditClientScreenState extends ConsumerState<AddEditClientScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _companyController = TextEditingController();
  final _notesController = TextEditingController();
  
  bool _isLoading = false;
  ClientModel? _existingClient;

  @override
  void initState() {
    super.initState();
    if (widget.clientId != null) {
      _loadClient();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _companyController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadClient() async {
    try {
      final client = await ref.read(clientByIdProvider(widget.clientId!).future);
      _existingClient = client;
      
      _nameController.text = client.name;
      _emailController.text = client.email;
      _phoneController.text = client.phone ?? '';
      _addressController.text = client.address ?? '';
      _companyController.text = client.company ?? '';
      _notesController.text = client.notes ?? '';
      
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading client: $e')),
      );
    }
  }

  Future<void> _saveClient() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Get the current user ID
      final currentUser = ref.read(currentUserProvider);
      if (currentUser == null) {
        throw Exception('You must be logged in to create a client');
      }
      
      final now = DateTime.now();
      final client = ClientModel(
        id: widget.clientId != null ? widget.clientId! : const Uuid().v4(),
        name: _nameController.text,
        email: _emailController.text,
        phone: _phoneController.text.isEmpty ? null : _phoneController.text,
        address: _addressController.text.isEmpty ? null : _addressController.text,
        company: _companyController.text.isEmpty ? null : _companyController.text,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
        createdAt: _existingClient?.createdAt ?? now,
        updatedAt: now,
        userId: currentUser.id,
      );

      final notifier = ref.read(clientNotifierProvider.notifier);
      
      if (widget.clientId == null) {
        await notifier.createClient(client);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Client created successfully')),
          );
          context.pop();
        }
      } else {
        await notifier.updateClient(client);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Client updated successfully')),
          );
          context.pop();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving client: $e')),
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

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.clientId != null;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Client' : 'Add Client'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Client Name',
                border: OutlineInputBorder(),
              ),
              validator: FormValidators.required('Client name is required'),
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: FormValidators.email('Please enter a valid email address'),
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone (Optional)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
              validator: FormValidators.phone('Please enter a valid phone number'),
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _companyController,
              decoration: const InputDecoration(
                labelText: 'Company (Optional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Address (Optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes (Optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            
            ElevatedButton(
              onPressed: _isLoading ? null : _saveClient,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : Text(isEditing ? 'Update Client' : 'Create Client'),
            ),
          ],
        ),
      ),
    );
  }
}
