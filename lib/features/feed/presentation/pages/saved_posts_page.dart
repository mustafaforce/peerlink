import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/cubit.dart';
import '../widgets/post_card.dart';

class SavedPostsPage extends StatelessWidget {
  const SavedPostsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SavedPostCubit()..loadSavedPosts(),
      child: const _SavedPostsContent(),
    );
  }
}

class _SavedPostsContent extends StatelessWidget {
  const _SavedPostsContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Saved Posts')),
      body: BlocBuilder<SavedPostCubit, SavedPostState>(
        builder: (context, state) {
          if (state.status == SavedPostStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.savedPosts.isEmpty) {
            return const Center(child: Text('No saved posts'));
          }

          return RefreshIndicator(
            onRefresh: () => context.read<SavedPostCubit>().loadSavedPosts(),
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: state.savedPosts.length,
              itemBuilder: (context, index) {
                final saved = state.savedPosts[index];
                final post = saved['posts'] ?? {};
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: PostCard(
                    post: post,
                    onLike: () {},
                    onComment: () {},
                    onSave: () {
                      final postId = post['id'] as String?;
                      if (postId != null) {
                        context.read<SavedPostCubit>().unsavePost(postId);
                      }
                    },
                    onReport: () {},
                    onShare: () {},
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
