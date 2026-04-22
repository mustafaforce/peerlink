import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/di/dependency_injection.dart';
import '../../../../app/router/app_router.dart';
import '../cubit/cubit.dart';
import '../widgets/friend_list_item.dart';

class FriendsListPage extends StatelessWidget {
  const FriendsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => FriendCubit(
        friendRepository: AppDependencies.friendRepository,
      )..loadFriends(),
      child: const _FriendsListContent(),
    );
  }
}

class _FriendsListContent extends StatelessWidget {
  const _FriendsListContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Friends'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: () => Navigator.of(context).pushNamed(AppRouter.searchUsers),
          ),
        ],
      ),
      body: BlocBuilder<FriendCubit, FriendState>(
        builder: (context, state) {
          if (state.status == FriendStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.friends.isEmpty) {
            return const Center(
              child: Text('No friends yet. Search for users to add!'),
            );
          }

          return ListView.builder(
            itemCount: state.friends.length,
            itemBuilder: (context, index) {
              final friend = state.friends[index];
              return FriendListItem(
                user: friend,
                onTap: () => Navigator.of(context).pushNamed(
                  AppRouter.viewProfile,
                  arguments: {'userId': friend['id']},
                ),
                onRemove: () {
                  context.read<FriendCubit>().removeFriend(friend['id']);
                },
              );
            },
          );
        },
      ),
    );
  }
}
