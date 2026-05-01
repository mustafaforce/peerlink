import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/di/dependency_injection.dart';
import '../../../../app/router/app_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../cubit/cubit.dart';
import '../widgets/resource_card.dart';

class ResourcesPage extends StatelessWidget {
  const ResourcesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ResourceCubit(
        resourceRepository: AppDependencies.resourceRepository,
      )..loadResources(),
      child: const _ResourcesContent(),
    );
  }
}

class _ResourcesContent extends StatefulWidget {
  const _ResourcesContent();

  @override
  State<_ResourcesContent> createState() => _ResourcesContentState();
}

class _ResourcesContentState extends State<_ResourcesContent> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Academic Resources'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_outline),
            onPressed: () =>
                Navigator.of(context).pushNamed(AppRouter.favoriteResources),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search resources...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.filter_list),
                  onPressed: () => _showFilterSheet(context),
                ),
              ),
              onSubmitted: (query) {
                context.read<ResourceCubit>().searchResources(query);
              },
            ),
          ),
          Expanded(
            child: BlocBuilder<ResourceCubit, ResourceState>(
              builder: (context, state) {
                if (state.status == ResourceStatus.loading &&
                    state.resources.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state.status == ResourceStatus.failure &&
                    state.resources.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(state.error ?? 'Failed to load resources'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () =>
                              context.read<ResourceCubit>().loadResources(refresh: true),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                if (state.resources.isEmpty) {
                  return const Center(child: Text('No resources found'));
                }

                return RefreshIndicator(
                  onRefresh: () =>
                      context.read<ResourceCubit>().loadResources(refresh: true),
                  child: NotificationListener<ScrollNotification>(
                    onNotification: (notification) {
                      if (notification is ScrollEndNotification &&
                          notification.metrics.extentAfter < 300) {
                        context.read<ResourceCubit>().loadMore();
                      }
                      return false;
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      itemCount:
                          state.resources.length + (state.hasMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == state.resources.length) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }

                        final resource = state.resources[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: ResourceCard(
                            resource: resource,
                            onTap: () => Navigator.of(context).pushNamed(
                              AppRouter.resourceDetail,
                              arguments: {'resourceId': resource['id']},
                            ),
                            onFavorite: () {
                              final isFav = resource['is_favorite'] ?? false;
                              if (isFav) {
                                context
                                    .read<ResourceCubit>()
                                    .removeFromFavorites(resource['id']);
                              } else {
                                context
                                    .read<ResourceCubit>()
                                    .addToFavorites(resource['id']);
                              }
                            },
                            onDownload: () {
                              context
                                  .read<ResourceCubit>()
                                  .downloadResource(resource['id']);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Download started')),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'resource_fab',
        onPressed: () =>
            Navigator.of(context).pushNamed(AppRouter.uploadResource),
        child: const Icon(Icons.upload),
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => _ResourceFilterSheet(),
    );
  }
}

class _ResourceFilterSheet extends StatefulWidget {
  const _ResourceFilterSheet();

  @override
  State<_ResourceFilterSheet> createState() => _ResourceFilterSheetState();
}

class _ResourceFilterSheetState extends State<_ResourceFilterSheet> {
  final _institutionController = TextEditingController();
  final _departmentController = TextEditingController();
  final _courseController = TextEditingController();
  final _subjectController = TextEditingController();

  @override
  void dispose() {
    _institutionController.dispose();
    _departmentController.dispose();
    _courseController.dispose();
    _subjectController.dispose();
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
      decoration: const BoxDecoration(
        color: AppColors.pureWhite,
        border: Border(top: BorderSide(color: AppColors.whisperBorder)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filter Resources',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _institutionController,
            decoration: const InputDecoration(labelText: 'Institution'),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _departmentController,
            decoration: const InputDecoration(labelText: 'Department'),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _courseController,
            decoration: const InputDecoration(labelText: 'Course'),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _subjectController,
            decoration: const InputDecoration(labelText: 'Subject'),
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
                if (_subjectController.text.isNotEmpty) {
                  filter['subject'] = _subjectController.text;
                }
                context.read<ResourceCubit>().applyFilter(filter);
                Navigator.pop(context);
              },
              child: const Text('Apply'),
            ),
          ),
        ],
      ),
    );
  }
}
