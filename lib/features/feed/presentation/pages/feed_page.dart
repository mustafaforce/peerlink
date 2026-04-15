import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/di/dependency_injection.dart';
import '../../../../app/router/app_router.dart';
import '../cubit/cubit.dart';
import '../widgets/post_card.dart';
import '../widgets/feed_filter_sheet.dart';

class FeedPage extends StatelessWidget {
  const FeedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => FeedCubit(
        feedRepository: AppDependencies.feedRepository,
      )..loadFeed(),
      child: const _FeedContent(),
    );
  }
}

class _FeedContent extends StatelessWidget {
  const _FeedContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Academic Feed'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => Navigator.of(context).pushNamed(AppRouter.viewProfile),
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterSheet(context),
          ),
          IconButton(
            icon: const Icon(Icons.bookmark_outline),
            onPressed: () => Navigator.of(context).pushNamed(AppRouter.savedPosts),
          ),
        ],
      ),
      body: BlocBuilder<FeedCubit, FeedState>(
        builder: (context, state) {
          if (state.status == FeedStatus.loading && state.posts.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == FeedStatus.failure && state.posts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.error ?? 'Failed to load feed'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<FeedCubit>().loadFeed(refresh: true),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state.posts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.article_outlined, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('No posts yet'),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pushNamed(AppRouter.createPost),
                    child: const Text('Create First Post'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => context.read<FeedCubit>().loadFeed(refresh: true),
            child: NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                if (notification is ScrollEndNotification &&
                    notification.metrics.extentAfter < 300) {
                  context.read<FeedCubit>().loadMore();
                }
                return false;
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.posts.length + (state.hasMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == state.posts.length) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  final post = state.posts[index];
                  return PostCard(
                    post: post,
                    onLike: () {
                      final isLiked = post['is_liked'] ?? false;
                      if (isLiked) {
                        context.read<FeedCubit>().unlikePost(post['id']);
                      } else {
                        context.read<FeedCubit>().likePost(post['id']);
                      }
                    },
                    onComment: () => Navigator.of(context).pushNamed(
                      AppRouter.comments,
                      arguments: {'postId': post['id']},
                    ),
                    onSave: () => context.read<FeedCubit>().savePost(post['id']),
                    onReport: () => _showReportDialog(context, post['id']),
                    onShare: () {},
                  );
                },
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).pushNamed(AppRouter.createPost),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (bottomSheetContext) => BlocProvider.value(
        value: context.read<FeedCubit>(),
        child: const FeedFilterSheet(),
      ),
    );
  }

  void _showReportDialog(BuildContext context, String postId) {
    final reasons = ['spam', 'inappropriate', 'harassment', 'copyright', 'other'];
    
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Report Post'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: reasons.map((reason) {
            return ListTile(
              title: Text(reason),
              onTap: () {
                Navigator.pop(dialogContext);
                context.read<FeedCubit>().reportPost(postId, reason);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Post reported')),
                );
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}
