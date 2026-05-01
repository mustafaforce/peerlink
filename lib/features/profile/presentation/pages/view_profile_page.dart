import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/di/dependency_injection.dart';
import '../../../../app/router/app_router.dart';
import '../../../feed/presentation/widgets/post_card.dart';
import '../cubit/cubit.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_stats.dart';
import '../widgets/profile_actions.dart';

class ViewProfilePage extends StatelessWidget {
  const ViewProfilePage({super.key, this.userId});

  final String? userId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProfileCubit(
        userRepository: AppDependencies.userRepository,
      )..loadProfile(userId: userId),
      child: _ViewProfileContent(userId: userId),
    );
  }
}

class _ViewProfileContent extends StatelessWidget {
  _ViewProfileContent({this.userId});

  final String? userId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          BlocBuilder<ProfileCubit, ProfileState>(
            builder: (context, state) {
              if (state.isOwnProfile) {
                return IconButton(
                  icon: const Icon(Icons.settings),
                  onPressed: () => Navigator.of(context).pushNamed(AppRouter.editProfile),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          if (state.status == ProfileStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == ProfileStatus.failure) {
            return Center(
              child: Text(state.error ?? 'Failed to load profile'),
            );
          }

          final user = state.user;
          if (user == null) {
            return const Center(child: Text('User not found'));
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ProfileHeader(user: user),
                ProfileStats(
                  postsCount: state.postsCount,
                  friendsCount: state.friendsCount,
                  resourcesCount: state.resourcesCount,
                ),
                ProfileActions(
                  user: user,
                  isOwnProfile: state.isOwnProfile,
                  friendStatus: state.friendStatus,
                  onRefresh: () => context.read<ProfileCubit>().loadProfile(
                    userId: userId,
                  ),
                ),
                const Divider(height: 32),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Posts',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                const SizedBox(height: 8),
                if (state.posts.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(child: Text('No posts yet')),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: state.posts.length,
                    itemBuilder: (context, index) {
                      final post = state.posts[index];
                      return PostCard(
                        post: post,
                        onLike: () {},
                        onComment: () => Navigator.of(context).pushNamed(
                          AppRouter.comments,
                          arguments: {'postId': post['id']},
                        ),
                        onSave: () {},
                        onReport: () {},
                        onShare: () {},
                      );
                    },
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
