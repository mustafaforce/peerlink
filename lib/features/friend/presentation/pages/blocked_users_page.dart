import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/di/dependency_injection.dart';
import '../cubit/cubit.dart';
import '../widgets/blocked_user_item.dart';

class BlockedUsersPage extends StatelessWidget {
  const BlockedUsersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => FriendCubit(
        friendRepository: AppDependencies.friendRepository,
      )..loadBlockedUsers(),
      child: const _BlockedUsersContent(),
    );
  }
}

class _BlockedUsersContent extends StatelessWidget {
  const _BlockedUsersContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Blocked Users'),
      ),
      body: BlocBuilder<FriendCubit, FriendState>(
        builder: (context, state) {
          if (state.status == FriendStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.blockedUsers.isEmpty) {
            return const Center(
              child: Text('No blocked users'),
            );
          }

          return ListView.builder(
            itemCount: state.blockedUsers.length,
            itemBuilder: (context, index) {
              final user = state.blockedUsers[index];
              return BlockedUserItem(
                user: user,
                onUnblock: () {
                  context.read<FriendCubit>().unblockUser(user['id']);
                },
              );
            },
          );
        },
      ),
    );
  }
}
