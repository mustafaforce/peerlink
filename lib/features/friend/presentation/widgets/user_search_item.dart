import 'package:flutter/material.dart';

class UserSearchItem extends StatelessWidget {
  const UserSearchItem({
    super.key,
    required this.user,
    this.onTap,
    this.onAddFriend,
  });

  final Map<String, dynamic> user;
  final VoidCallback? onTap;
  final VoidCallback? onAddFriend;

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
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (user['institution'] != null)
            Text(user['institution']),
          if (user['department'] != null)
            Text('${user['department']}${user['year'] != null ? ' • Year ${user['year']}' : ''}'),
        ],
      ),
      trailing: IconButton(
        icon: const Icon(Icons.person_add),
        onPressed: onAddFriend,
      ),
      onTap: onTap,
    );
  }
}
