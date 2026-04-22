import 'package:flutter/material.dart';

import '../../../../app/di/dependency_injection.dart';

class ProfileActions extends StatelessWidget {
  const ProfileActions({super.key, required this.user, required this.isOwnProfile});

  final Map<String, dynamic> user;
  final bool isOwnProfile;

  @override
  Widget build(BuildContext context) {
    if (isOwnProfile) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: OutlinedButton.icon(
          onPressed: () {
            // Navigate to edit profile
          },
          icon: const Icon(Icons.edit),
          label: const Text('Edit Profile'),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _sendFriendRequest(context),
              icon: const Icon(Icons.person_add),
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please login to send a friend request')),
        );
        return;
      }

      await AppDependencies.friendRepository.sendFriendRequest(
        senderId: currentUserId,
        receiverId: user['id'],
      );
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Friend request sent')),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed: $e')),
      );
    }
  }

  Future<void> _blockUser(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Block User'),
        content: const Text('Are you sure you want to block this user?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Block'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final currentUserId = AppDependencies.authRepository.currentUserId;
        if (currentUserId == null) {
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please login to block users')),
          );
          return;
        }

        await AppDependencies.friendRepository.blockUser(
          blockerId: currentUserId,
          blockedId: user['id'],
        );
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User blocked')),
        );
      } catch (e) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e')),
        );
      }
    }
  }
}
