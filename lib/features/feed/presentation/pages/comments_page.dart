import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/theme/app_colors.dart';
import '../cubit/cubit.dart';

class CommentsPage extends StatelessWidget {
  const CommentsPage({super.key, required this.postId});

  final String postId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CommentCubit(postId: postId)..loadComments(),
      child: const _CommentsBody(),
    );
  }
}

class _CommentsBody extends StatelessWidget {
  const _CommentsBody();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Comments')),
      body: BlocBuilder<CommentCubit, CommentState>(
        builder: (context, state) {
          if (state.status == CommentStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == CommentStatus.failure) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.error ?? 'Failed to load comments'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<CommentCubit>().loadComments(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state.comments.isEmpty) {
            return const Center(child: Text('No comments yet. Be the first!'));
          }

          return RefreshIndicator(
            onRefresh: () => context.read<CommentCubit>().loadComments(),
            child: ListView.builder(
              itemCount: state.comments.length,
              itemBuilder: (context, index) {
                final comment = state.comments[index];
                return _CommentTile(comment: comment);
              },
            ),
          );
        },
      ),
      bottomNavigationBar: const _CommentInput(),
    );
  }
}

class _CommentInput extends StatefulWidget {
  const _CommentInput();

  @override
  State<_CommentInput> createState() => _CommentInputState();
}

class _CommentInputState extends State<_CommentInput> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final content = _controller.text.trim();
    if (content.isEmpty) return;
    context.read<CommentCubit>().addComment(content);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.whisperBorder)),
        color: AppColors.pureWhite,
      ),
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(
                hintText: 'Write a comment...',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                isDense: true,
              ),
              onSubmitted: (_) => _submit(),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: _submit,
            icon: const Icon(Icons.send),
            color: AppColors.notionBlue,
          ),
        ],
      ),
    );
  }
}

class _CommentTile extends StatelessWidget {
  const _CommentTile({required this.comment});

  final Map<String, dynamic> comment;

  @override
  Widget build(BuildContext context) {
    final user = comment['users'] ?? {};

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.warmGray300.withValues(alpha: 0.2),
            backgroundImage: user['avatar_url'] != null
                ? NetworkImage(user['avatar_url'])
                : null,
            child: user['avatar_url'] == null
                ? Text(
                    (user['full_name'] ?? 'U')[0].toUpperCase(),
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  )
                : null,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      user['full_name'] ?? 'Unknown',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatTime(comment['created_at']),
                      style: TextStyle(color: AppColors.warmGray300, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  comment['content'] ?? '',
                  style: const TextStyle(fontSize: 15),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(dynamic time) {
    if (time == null) return '';
    final dt = DateTime.tryParse(time.toString());
    if (dt == null) return '';
    final diff = DateTime.now().difference(dt);
    if (diff.inDays > 0) return '${diff.inDays}d';
    if (diff.inHours > 0) return '${diff.inHours}h';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m';
    return 'now';
  }
}
