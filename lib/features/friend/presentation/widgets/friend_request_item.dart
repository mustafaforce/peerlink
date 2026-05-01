import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';

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
              backgroundImage: sender['avatar_url'] != null
                  ? NetworkImage(sender['avatar_url'])
                  : null,
              child: sender['avatar_url'] == null
                  ? Text(
                      (sender['full_name'] ?? 'U')[0].toUpperCase(),
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
                    sender['full_name'] ?? 'Unknown',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  if (sender['institution'] != null)
                    Text(
                      sender['institution'],
                      style: TextStyle(
                        color: AppColors.warmGray500,
                        fontSize: 13,
                      ),
                    ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.check, color: Color(0xFF1AAE39)),
              onPressed: onAccept,
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Color(0xFFDC2626)),
              onPressed: onReject,
            ),
          ],
        ),
      ),
    );
  }
}
