import 'package:flutter/material.dart';

import '../../../../app/di/dependency_injection.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _bioController = TextEditingController();
  final _institutionController = TextEditingController();
  final _departmentController = TextEditingController();
  final _yearController = TextEditingController();
  final _phoneController = TextEditingController();
  
  bool _isPrivate = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentProfile();
  }

  Future<void> _loadCurrentProfile() async {
    final userRepo = AppDependencies.userRepository;
    final userId = userRepo.currentUserId;
    if (userId == null) return;
    
    final user = await userRepo.getUserById(userId);
    if (user != null && mounted) {
      setState(() {
        _fullNameController.text = user['full_name'] ?? '';
        _bioController.text = user['bio'] ?? '';
        _institutionController.text = user['institution'] ?? '';
        _departmentController.text = user['department'] ?? '';
        _yearController.text = (user['year'] ?? '').toString();
        _phoneController.text = user['phone'] ?? '';
        _isPrivate = user['is_private'] ?? false;
      });
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _bioController.dispose();
    _institutionController.dispose();
    _departmentController.dispose();
    _yearController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final userRepo = AppDependencies.userRepository;
      final userId = userRepo.currentUserId;
      if (userId == null) {
        _showMessage('Not authenticated');
        return;
      }

      await userRepo.updateUser(userId, {
        'full_name': _fullNameController.text.trim(),
        'bio': _bioController.text.trim(),
        'institution': _institutionController.text.trim(),
        'department': _departmentController.text.trim(),
        'year': int.tryParse(_yearController.text),
        'phone': _phoneController.text.trim(),
        'is_private': _isPrivate,
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
      Navigator.of(context).pop();
    } catch (e) {
      _showMessage('Failed to update profile');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          TextButton(
            onPressed: _isSubmitting ? null : _saveProfile,
            child: _isSubmitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _fullNameController,
              decoration: const InputDecoration(labelText: 'Full Name'),
              validator: (value) {
                if ((value ?? '').trim().isEmpty) return 'Full name is required';
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _bioController,
              decoration: const InputDecoration(labelText: 'Bio'),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _institutionController,
              decoration: const InputDecoration(labelText: 'Institution'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _departmentController,
              decoration: const InputDecoration(labelText: 'Department'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _yearController,
              decoration: const InputDecoration(labelText: 'Year'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(labelText: 'Phone'),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Private Account'),
              subtitle: const Text('Only friends can see your profile'),
              value: _isPrivate,
              onChanged: (value) => setState(() => _isPrivate = value),
            ),
          ],
        ),
      ),
    );
  }
}
