import 'package:flutter/material.dart';

class FriendRequestItem extends StatelessWidget {
  const FriendRequestItem({
    super.key,
    required this.request,
    this.onAccept,
    this.onReject,
  });

  final Map<String, dynamic> request;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;

  @override
  Widget build(BuildContext context) {
    final sender = request['sender'] ?? {};

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.grey[300],
        backgroundImage: sender['avatar_url'] != null
            ? NetworkImage(sender['avatar_url'])
            : null,
        child: sender['avatar_url'] == null
            ? Text((sender['full_name'] ?? 'U')[0].toUpperCase())
            : null,
      ),
      title: Text(sender['full_name'] ?? 'Unknown'),
      subtitle: Text(sender['institution'] ?? ''),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.check, color: Colors.green),
            onPressed: onAccept,
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.red),
            onPressed: onReject,
          ),
        ],
      ),
    );
  }
}
