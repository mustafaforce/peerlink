import 'package:flutter/material.dart';

import '../../../../app/di/dependency_injection.dart';
import '../../../../app/router/app_router.dart';

class ProfileActions extends StatelessWidget {
  const ProfileActions({
    super.key,
    required this.user,
    required this.isOwnProfile,
    this.friendStatus,
    this.onRefresh,
  });

  final Map<String, dynamic> user;
  final bool isOwnProfile;
  final String? friendStatus;
  final VoidCallback? onRefresh;

  @override
  Widget build(BuildContext context) {
    if (isOwnProfile) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () =>
                Navigator.of(context).pushNamed(AppRouter.editProfile),
            icon: const Icon(Icons.edit, size: 18),
            label: const Text('Edit Profile'),
          ),
        ),
      );
    }

    if (friendStatus == 'accepted') {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: friendStatus == 'pending'
                ? OutlinedButton.icon(
                    onPressed: null,
                    icon: const Icon(Icons.check, size: 18),
                    label: const Text('Request Sent'),
                  )
                : ElevatedButton.icon(
                    onPressed: () => _sendFriendRequest(context),
                    icon: const Icon(Icons.person_add, size: 18),
                    label: const Text('Add Friend'),
                  ),
          ),
          const SizedBox(width: 12),
          IconButton(
            onPressed: () => _blockUser(context),
            icon: const Icon(Icons.block),
            tooltip: 'Block User',
          ),
        ],
      ),
    );
  }

  Future<void> _sendFriendRequest(BuildContext context) async {
    try {
      final currentUserId = AppDependencies.authRepository.currentUserId;
      if (currentUserId == null) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(const SnackBar(content: Text('Please login first')));
        return;
      }
      await AppDependencies.friendRepository.sendFriendRequest(
        senderId: currentUserId,
        receiverId: user['id'],
      );
      onRefresh?.call();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('Friend request sent')));
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text('Failed: $e')));
    }
  }

  Future<void> _blockUser(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Block User'),
        content: const Text('Are you sure you want to block this user?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Block'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final currentUserId = AppDependencies.authRepository.currentUserId;
      if (currentUserId == null) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(const SnackBar(content: Text('Please login first')));
        return;
      }
      await AppDependencies.friendRepository.blockUser(
        blockerId: currentUserId,
        blockedId: user['id'],
      );
      onRefresh?.call();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('User blocked')));
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text('Failed: $e')));
    }
  }
}
