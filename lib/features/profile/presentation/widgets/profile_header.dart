import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';

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
              backgroundColor: AppColors.warmGray300.withValues(alpha: 0.2),
              backgroundImage: user['avatar_url'] != null
                  ? NetworkImage(user['avatar_url'])
                  : null,
              child: user['avatar_url'] == null
                  ? Text(
                      (user['full_name'] ?? 'U')[0].toUpperCase(),
                      style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w700),
                    )
                  : null,
            ),
            const SizedBox(height: 12),
            Text(
              user['full_name'] ?? 'Unknown',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 4),
            Text(
              user['email'] ?? '',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (user['bio'] != null && user['bio'].toString().isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                user['bio'],
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.warmGray500,
                    ),
              ),
            ],
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                if (user['institution'] != null)
                  Chip(
                    avatar: const Icon(Icons.school, size: 14),
                    label: Text(user['institution']),
                  ),
                if (user['department'] != null)
                  Chip(
                    avatar: const Icon(Icons.book, size: 14),
                    label: Text(user['department']),
                  ),
                if (user['year'] != null)
                  Chip(
                    avatar: const Icon(Icons.calendar_today, size: 14),
                    label: Text('Year ${user['year']}'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
