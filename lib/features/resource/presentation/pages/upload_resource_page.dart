import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

import '../../../../app/di/dependency_injection.dart';
import '../../../../app/theme/app_colors.dart';

class UploadResourcePage extends StatefulWidget {
  const UploadResourcePage({super.key});

  @override
  State<UploadResourcePage> createState() => _UploadResourcePageState();
}

class _UploadResourcePageState extends State<UploadResourcePage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _institutionController = TextEditingController();
  final _departmentController = TextEditingController();
  final _courseController = TextEditingController();
  final _subjectController = TextEditingController();

  PlatformFile? _selectedFile;
  String? _selectedFileType;
  bool _isSubmitting = false;

  final _fileTypes = [
    'PDF', 'DOC', 'DOCX', 'PPT', 'PPTX',
    'XLS', 'XLSX', 'TXT', 'ZIP', 'RAR',
    'PNG', 'JPG', 'JPEG',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _institutionController.dispose();
    _departmentController.dispose();
    _courseController.dispose();
    _subjectController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Resource'),
        actions: [
          TextButton(
            onPressed: _isSubmitting ? null : _submit,
            child: _isSubmitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Upload'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title *',
                hintText: 'Resource title',
              ),
              validator: (value) {
                if ((value ?? '').trim().isEmpty) return 'Title is required';
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Describe the resource',
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _selectedFileType,
              decoration: const InputDecoration(
                labelText: 'File Type *',
              ),
              items: _fileTypes
                  .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                  .toList(),
              onChanged: (v) => setState(() => _selectedFileType = v),
              validator: (v) => v == null ? 'File type is required' : null,
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
              controller: _courseController,
              decoration: const InputDecoration(labelText: 'Course'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _subjectController,
              decoration: const InputDecoration(labelText: 'Subject'),
            ),
            const SizedBox(height: 24),
            Container(
              height: 150,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.whisperBorder),
                borderRadius: BorderRadius.circular(8),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: _isSubmitting ? null : _pickFile,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.cloud_upload_outlined,
                        size: 48,
                        color: AppColors.warmGray300,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _selectedFile?.name ?? 'Select File to Upload',
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        _selectedFile == null
                            ? 'Tap to choose file'
                            : _formatBytes(_selectedFile!.size),
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.warmGray300,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedFile?.bytes == null || _selectedFile!.bytes!.isEmpty) {
      _showMessage('Please select a file to upload');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final userId = AppDependencies.authRepository.currentUserId;
      if (userId == null) {
        _showMessage('Not authenticated');
        return;
      }

      final file = _selectedFile!;
      final extension = file.name.split('.').last.toLowerCase();
      final fileType = _selectedFileType ?? extension.toUpperCase();

      final fileUrl = await AppDependencies.resourceRepository.uploadResourceFile(
        userId: userId,
        fileName: file.name,
        fileBytes: file.bytes!,
        contentType: _contentType(extension),
      );

      await AppDependencies.resourceRepository.uploadResource(
        userId: userId,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        fileUrl: fileUrl,
        fileType: fileType,
        fileSize: file.size,
        institution: _institutionController.text.trim().isNotEmpty
            ? _institutionController.text.trim()
            : null,
        department: _departmentController.text.trim().isNotEmpty
            ? _departmentController.text.trim()
            : null,
        course: _courseController.text.trim().isNotEmpty
            ? _courseController.text.trim()
            : null,
        subject: _subjectController.text.trim().isNotEmpty
            ? _subjectController.text.trim()
            : null,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('Resource uploaded')));
      Navigator.of(context).pop(true);
    } catch (_) {
      _showMessage('Failed to upload resource');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: _fileTypes.map((t) => t.toLowerCase()).toList(),
      withData: true,
    );
    if (!mounted || result == null || result.files.isEmpty) return;

    final file = result.files.first;
    final ext = file.extension?.toUpperCase();

    setState(() {
      _selectedFile = file;
      if (ext != null && _fileTypes.contains(ext)) {
        _selectedFileType = ext;
      }
    });
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  String? _contentType(String ext) {
    switch (ext.toLowerCase()) {
      case 'pdf': return 'application/pdf';
      case 'doc': return 'application/msword';
      case 'docx': return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      case 'ppt': return 'application/vnd.ms-powerpoint';
      case 'pptx': return 'application/vnd.openxmlformats-officedocument.presentationml.presentation';
      case 'xls': return 'application/vnd.ms-excel';
      case 'xlsx': return 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
      case 'txt': return 'text/plain';
      case 'zip': return 'application/zip';
      case 'rar': return 'application/vnd.rar';
      case 'png': return 'image/png';
      case 'jpg': case 'jpeg': return 'image/jpeg';
      default: return null;
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}
