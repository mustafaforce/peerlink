import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';

class PostCard extends StatelessWidget {
  const PostCard({
    super.key,
    required this.post,
    this.onLike,
    this.onComment,
    this.onSave,
    this.onReport,
    this.onShare,
  });

  final Map<String, dynamic> post;
  final VoidCallback? onLike;
  final VoidCallback? onComment;
  final VoidCallback? onSave;
  final VoidCallback? onReport;
  final VoidCallback? onShare;

  @override
  Widget build(BuildContext context) {
    final user = post['users'] as Map<String, dynamic>? ?? {};
    final isAnonymous = post['is_anonymous'] ?? false;
    final isLiked = post['is_liked'] ?? false;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.whisperBorder),
        boxShadow: AppColors.cardShadow,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.warmGray300.withValues(alpha: 0.2),
                  backgroundImage: isAnonymous
                      ? null
                      : (user['avatar_url'] != null
                          ? NetworkImage(user['avatar_url'])
                          : null),
                  child: isAnonymous
                      ? const Icon(Icons.person, color: AppColors.warmGray500, size: 20)
                      : (user['avatar_url'] == null
                          ? Text(
                              (user['full_name'] ?? 'U')[0].toUpperCase(),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            )
                          : null),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isAnonymous ? 'Anonymous' : (user['full_name'] ?? 'Unknown'),
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        _formatTime(post['created_at']),
                        style: TextStyle(
                          color: AppColors.warmGray300,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'report') onReport?.call();
                    if (value == 'save') onSave?.call();
                  },
                  itemBuilder: (_) => [
                    const PopupMenuItem(
                      value: 'save',
                      child: Row(
                        children: [
                          Icon(Icons.bookmark_border, size: 18),
                          SizedBox(width: 8),
                          Text('Save Post'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'report',
                      child: Row(
                        children: [
                          Icon(Icons.flag_outlined, size: 18),
                          SizedBox(width: 8),
                          Text('Report'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              post['content'] ?? '',
              style: const TextStyle(fontSize: 15, height: 1.5),
            ),
            if (post['image_urls'] != null && (post['image_urls'] as List).isNotEmpty) ...[
              const SizedBox(height: 12),
              SizedBox(
                height: 180,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: (post['image_urls'] as List).length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          post['image_urls'][index],
                          height: 180,
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
            if (post['institution'] != null ||
                post['department'] != null ||
                post['course'] != null) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: [
                  if (post['institution'] != null)
                    Chip(
                      label: Text(
                        post['institution'],
                        style: const TextStyle(fontSize: 11),
                      ),
                    ),
                  if (post['department'] != null)
                    Chip(
                      label: Text(
                        post['department'],
                        style: const TextStyle(fontSize: 11),
                      ),
                    ),
                  if (post['course'] != null)
                    Chip(
                      label: Text(
                        post['course'],
                        style: const TextStyle(fontSize: 11),
                      ),
                    ),
                ],
              ),
            ],
            const Divider(height: 24),
            Row(
              children: [
                _ActionButton(
                  icon: isLiked ? Icons.favorite : Icons.favorite_border,
                  label: '${post['likes_count'] ?? 0}',
                  color: isLiked ? AppColors.error : AppColors.warmGray500,
                  onTap: onLike,
                ),
                const SizedBox(width: 8),
                _ActionButton(
                  icon: Icons.comment_outlined,
                  label: '${post['comments_count'] ?? 0}',
                  color: AppColors.warmGray500,
                  onTap: onComment,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(dynamic time) {
    if (time == null) return '';
    final dt = DateTime.tryParse(time.toString());
    if (dt == null) return '';
    final diff = DateTime.now().difference(dt);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'Just now';
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    this.color,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final Color? color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Row(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
