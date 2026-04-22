import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/di/dependency_injection.dart';
import '../cubit/cubit.dart';
import '../widgets/friend_request_item.dart';

class FriendRequestsPage extends StatelessWidget {
  const FriendRequestsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => FriendCubit(
        friendRepository: AppDependencies.friendRepository,
      )..loadPendingRequests(),
      child: const _FriendRequestsContent(),
    );
  }
}

class _FriendRequestsContent extends StatelessWidget {
  const _FriendRequestsContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Friend Requests'),
      ),
      body: BlocBuilder<FriendCubit, FriendState>(
        builder: (context, state) {
          if (state.status == FriendStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.pendingRequests.isEmpty) {
            return const Center(
              child: Text('No pending friend requests'),
            );
          }

          return ListView.builder(
            itemCount: state.pendingRequests.length,
            itemBuilder: (context, index) {
              final request = state.pendingRequests[index];
              return FriendRequestItem(
                request: request,
                onAccept: () {
                  context.read<FriendCubit>().acceptRequest(request['id']);
                },
                onReject: () {
                  context.read<FriendCubit>().rejectRequest(request['id']);
                },
              );
            },
          );
        },
      ),
    );
  }
}
