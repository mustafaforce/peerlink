import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';

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
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.whisperBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: AppColors.warmGray300.withValues(alpha: 0.2),
              backgroundImage: user['avatar_url'] != null
                  ? NetworkImage(user['avatar_url'])
                  : null,
              child: user['avatar_url'] == null
                  ? Text(
                      (user['full_name'] ?? 'U')[0].toUpperCase(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user['full_name'] ?? 'Unknown',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    'Blocked',
                    style: TextStyle(
                      color: AppColors.warmGray300,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: onUnblock,
              child: const Text('Unblock'),
            ),
          ],
        ),
      ),
    );
  }
}
