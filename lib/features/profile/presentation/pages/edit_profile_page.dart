import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';

import '../../../../app/di/dependency_injection.dart';
import '../../../../app/theme/app_colors.dart';
import '../cubit/cubit.dart';

class EditProfilePage extends StatelessWidget {
  const EditProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProfileCubit(
        userRepository: AppDependencies.userRepository,
      )..loadProfile(),
      child: const _EditForm(),
    );
  }
}

class _EditForm extends StatefulWidget {
  const _EditForm();

  @override
  State<_EditForm> createState() => _EditFormState();
}

class _EditFormState extends State<_EditForm> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _bioController = TextEditingController();
  final _institutionController = TextEditingController();
  final _departmentController = TextEditingController();
  final _yearController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _isPrivate = false;
  bool _isSubmitting = false;
  String? _avatarUrl;
  Uint8List? _newAvatarBytes;
  String? _newAvatarName;

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

  void _initFromUser(Map<String, dynamic> user) {
    _fullNameController.text = user['full_name'] ?? '';
    _bioController.text = user['bio'] ?? '';
    _institutionController.text = user['institution'] ?? '';
    _departmentController.text = user['department'] ?? '';
    _yearController.text = (user['year'] ?? '').toString();
    _phoneController.text = user['phone'] ?? '';
    _isPrivate = user['is_private'] ?? false;
    _avatarUrl = user['avatar_url'];
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    final cubit = context.read<ProfileCubit>();

    if (_newAvatarBytes != null && _newAvatarName != null) {
      await cubit.updateAvatar(
        fileName: _newAvatarName!,
        fileBytes: _newAvatarBytes!,
      );
    }

    await cubit.updateProfile(
      fullName: _fullNameController.text.trim(),
      bio: _bioController.text.trim(),
      institution: _institutionController.text.trim().isNotEmpty
          ? _institutionController.text.trim()
          : null,
      department: _departmentController.text.trim().isNotEmpty
          ? _departmentController.text.trim()
          : null,
      year: int.tryParse(_yearController.text),
      phone: _phoneController.text.trim().isNotEmpty
          ? _phoneController.text.trim()
          : null,
      isPrivate: _isPrivate,
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('Profile updated')));
    Navigator.of(context).pop();
  }

  Future<void> _pickAvatar() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );
    if (!mounted || result == null || result.files.isEmpty) return;

    final file = result.files.first;
    if (file.bytes == null || file.bytes!.isEmpty) return;

    setState(() {
      _newAvatarBytes = file.bytes;
      _newAvatarName = file.name;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          TextButton(
            onPressed: _isSubmitting ? null : _save,
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
      body: BlocListener<ProfileCubit, ProfileState>(
        listener: (context, state) {
          if (state.status == ProfileStatus.failure && state.error != null) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(content: Text(state.error!)));
          }
        },
        child: BlocBuilder<ProfileCubit, ProfileState>(
          builder: (context, state) {
            if (state.status == ProfileStatus.loading && state.user == null) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.user != null && _fullNameController.text.isEmpty) {
              _initFromUser(state.user!);
            }

            return Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Center(
                    child: GestureDetector(
                      onTap: _pickAvatar,
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: AppColors.warmGray300.withValues(alpha: 0.2),
                            backgroundImage: _newAvatarBytes != null
                                ? MemoryImage(_newAvatarBytes!)
                                : (_avatarUrl != null
                                    ? NetworkImage(_avatarUrl!)
                                    : null),
                            child: _newAvatarBytes == null && _avatarUrl == null
                                ? const Icon(
                                    Icons.person,
                                    size: 50,
                                    color: AppColors.warmGray500,
                                  )
                                : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: AppColors.notionBlue,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                size: 18,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: TextButton(
                      onPressed: _pickAvatar,
                      child: const Text('Change Photo'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _fullNameController,
                    decoration: const InputDecoration(labelText: 'Full Name'),
                    validator: (v) =>
                        (v ?? '').trim().isEmpty ? 'Full name is required' : null,
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
                    onChanged: (v) => setState(() => _isPrivate = v),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
