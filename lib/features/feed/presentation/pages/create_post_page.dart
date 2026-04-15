import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/di/dependency_injection.dart';
import '../cubit/cubit.dart';

class CreatePostPage extends StatefulWidget {
  const CreatePostPage({super.key});

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  final _contentController = TextEditingController();
  final _institutionController = TextEditingController();
  final _departmentController = TextEditingController();
  final _courseController = TextEditingController();
  final _yearController = TextEditingController();
  
  bool _isAnonymous = false;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _contentController.dispose();
    _institutionController.dispose();
    _departmentController.dispose();
    _courseController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => FeedCubit(
        feedRepository: AppDependencies.feedRepository,
      ),
      child: Builder(
        builder: (context) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Create Post'),
              actions: [
                TextButton(
                  onPressed: _isSubmitting ? null : () => _submitPost(context),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Post'),
                ),
              ],
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _contentController,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      hintText: "What's on your mind?",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  CheckboxListTile(
                    title: const Text('Post Anonymously'),
                    subtitle: const Text('Your name will not be shown'),
                    value: _isAnonymous,
                    onChanged: (value) => setState(() => _isAnonymous = value ?? false),
                  ),
                  const Divider(),
                  const Text('Academic Filters (Optional)',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _institutionController,
                    decoration: const InputDecoration(
                      labelText: 'Institution',
                      hintText: 'e.g., Harvard University',
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _departmentController,
                    decoration: const InputDecoration(
                      labelText: 'Department',
                      hintText: 'e.g., Computer Science',
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _courseController,
                    decoration: const InputDecoration(
                      labelText: 'Course',
                      hintText: 'e.g., CS101',
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _yearController,
                    decoration: const InputDecoration(
                      labelText: 'Year',
                      hintText: 'e.g., 2024',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _submitPost(BuildContext context) async {
    if (_contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter some content')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await context.read<FeedCubit>().createPost(
            content: _contentController.text.trim(),
            institution: _institutionController.text.trim().isNotEmpty
                ? _institutionController.text.trim()
                : null,
            department: _departmentController.text.trim().isNotEmpty
                ? _departmentController.text.trim()
                : null,
            course: _courseController.text.trim().isNotEmpty
                ? _courseController.text.trim()
                : null,
            year: int.tryParse(_yearController.text),
            isAnonymous: _isAnonymous,
          );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post created successfully')),
      );
      Navigator.of(context).pop();
    } catch (e) {
      _showMessage('Failed to create post');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}
