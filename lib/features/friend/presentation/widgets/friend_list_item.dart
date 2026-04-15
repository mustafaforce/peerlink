import 'package:flutter/material.dart';

class FriendListItem extends StatelessWidget {
  const FriendListItem({
    super.key,
    required this.user,
    this.onTap,
    this.onRemove,
  });

  final Map<String, dynamic> user;
  final VoidCallback? onTap;
  final VoidCallback? onRemove;

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
      subtitle: Text(user['institution'] ?? ''),
      trailing: IconButton(
        icon: const Icon(Icons.person_remove),
        onPressed: () => _showRemoveDialog(context),
      ),
      onTap: onTap,
    );
  }

  void _showRemoveDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Friend'),
        content: Text('Remove ${user['full_name']} from your friends?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onRemove?.call();
            },
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }
}
