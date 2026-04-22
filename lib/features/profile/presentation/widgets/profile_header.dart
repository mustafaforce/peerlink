import 'package:flutter/material.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key, required this.user});

  final Map<String, dynamic> user;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.grey[300],
              backgroundImage: user['avatar_url'] != null
                  ? NetworkImage(user['avatar_url'])
                  : null,
              child: user['avatar_url'] == null
                  ? Text(
                      (user['full_name'] ?? 'U')[0].toUpperCase(),
                      style: const TextStyle(fontSize: 36),
                    )
                  : null,
            ),
            const SizedBox(height: 12),
            Text(
              user['full_name'] ?? 'Unknown',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              user['email'] ?? '',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            if (user['bio'] != null && user['bio'].toString().isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                user['bio'],
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                if (user['institution'] != null)
                  Chip(
                    label: Text(user['institution']),
                    avatar: const Icon(Icons.school, size: 16),
                  ),
                if (user['department'] != null)
                  Chip(
                    label: Text(user['department']),
                    avatar: const Icon(Icons.book, size: 16),
                  ),
                if (user['year'] != null)
                  Chip(
                    label: Text('Year ${user['year']}'),
                    avatar: const Icon(Icons.calendar_today, size: 16),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
