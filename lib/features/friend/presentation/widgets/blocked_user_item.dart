import 'package:flutter/material.dart';

class BlockedUserItem extends StatelessWidget {
  const BlockedUserItem({
    super.key,
    required this.user,
    this.onUnblock,
  });

  final Map<String, dynamic> user;
  final VoidCallback? onUnblock;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.grey[300],
        backgroundImage: user['avatar_url'] != null
            ? NetworkImage(user['avatar_url'])
            : null,
        child: user['avatar_url'] == null
            ? Text((user['full_name'] ?? 'U')[0].toUpperCase())
            : null,
      ),
      title: Text(user['full_name'] ?? 'Unknown'),
      subtitle: const Text('Blocked'),
      trailing: TextButton(
        onPressed: onUnblock,
        child: const Text('Unblock'),
      ),
    );
  }
}
