import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/cubit.dart';

class FeedFilterSheet extends StatefulWidget {
  const FeedFilterSheet({super.key});

  @override
  State<FeedFilterSheet> createState() => _FeedFilterSheetState();
}

class _FeedFilterSheetState extends State<FeedFilterSheet> {
  final _institutionController = TextEditingController();
  final _departmentController = TextEditingController();
  final _courseController = TextEditingController();
  final _yearController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final filter = context.read<FeedCubit>().state.filter;
    _institutionController.text = filter['institution'] ?? '';
    _departmentController.text = filter['department'] ?? '';
    _courseController.text = filter['course'] ?? '';
    _yearController.text = filter['year']?.toString() ?? '';
  }

  @override
  void dispose() {
    _institutionController.dispose();
    _departmentController.dispose();
    _courseController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).padding.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Filter Feed',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {
                  context.read<FeedCubit>().clearFilter();
                  Navigator.pop(context);
                },
                child: const Text('Clear All'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _institutionController,
            decoration: const InputDecoration(
              labelText: 'Institution',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _departmentController,
            decoration: const InputDecoration(
              labelText: 'Department',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _courseController,
            decoration: const InputDecoration(
              labelText: 'Course',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _yearController,
            decoration: const InputDecoration(
              labelText: 'Year',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                final filter = <String, dynamic>{};
                if (_institutionController.text.isNotEmpty) {
                  filter['institution'] = _institutionController.text;
                }
                if (_departmentController.text.isNotEmpty) {
                  filter['department'] = _departmentController.text;
                }
                if (_courseController.text.isNotEmpty) {
                  filter['course'] = _courseController.text;
                }
                if (_yearController.text.isNotEmpty) {
                  filter['year'] = int.tryParse(_yearController.text);
                }
                context.read<FeedCubit>().applyFilter(filter);
                Navigator.pop(context);
              },
              child: const Text('Apply Filters'),
            ),
          ),
        ],
      ),
    );
  }
}
