import 'package:flutter/material.dart';

import '../../../../app/di/dependency_injection.dart';
import '../widgets/post_card.dart';

class SavedPostsPage extends StatefulWidget {
  const SavedPostsPage({super.key});

  @override
  State<SavedPostsPage> createState() => _SavedPostsPageState();
}

class _SavedPostsPageState extends State<SavedPostsPage> {
  List<Map<String, dynamic>> _savedPosts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSavedPosts();
  }

  Future<void> _loadSavedPosts() async {
    setState(() => _isLoading = true);
    try {
      final userId = AppDependencies.authRepository.currentUserId;
      if (userId != null) {
        final saved = await AppDependencies.savedPostRepository.getSavedPosts(userId);
        if (!mounted) return;
        setState(() {
          _savedPosts = saved;
          _isLoading = false;
        });
      } else {
        if (!mounted) return;
        setState(() {
          _savedPosts = [];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Posts'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _savedPosts.isEmpty
              ? const Center(child: Text('No saved posts'))
              : RefreshIndicator(
                  onRefresh: _loadSavedPosts,
                  child: ListView.builder(
                    itemCount: _savedPosts.length,
                    itemBuilder: (context, index) {
                      final saved = _savedPosts[index];
                      final post = saved['posts'] ?? {};
                      return PostCard(
                        post: post,
                        onLike: () {},
                        onComment: () {},
                        onSave: () async {
                          final userId = AppDependencies.authRepository.currentUserId;
                          if (userId == null || post['id'] == null) return;
                          await AppDependencies.savedPostRepository
                              .unsavePost(userId, post['id'] as String);
                          await _loadSavedPosts();
                        },
                        onReport: () {},
                        onShare: () {},
                      );
                    },
                  ),
                ),
    );
  }
}
