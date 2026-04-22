import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.grey[300],
                  backgroundImage: isAnonymous
                      ? null
                      : (user['avatar_url'] != null
                          ? NetworkImage(user['avatar_url'])
                          : null),
                  child: isAnonymous
                      ? const Icon(Icons.person, color: Colors.grey)
                      : (user['avatar_url'] == null
                          ? Text((user['full_name'] ?? 'U')[0].toUpperCase())
                          : null),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isAnonymous ? 'Anonymous' : (user['full_name'] ?? 'Unknown'),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        _formatTime(post['created_at']),
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'report') onReport?.call();
                    if (value == 'save') onSave?.call();
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'save',
                      child: Row(
                        children: [
                          Icon(Icons.bookmark_border),
                          SizedBox(width: 8),
                          Text('Save Post'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'report',
                      child: Row(
                        children: [
                          Icon(Icons.flag_outlined),
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
            Text(post['content'] ?? ''),
            if (post['image_urls'] != null && (post['image_urls'] as List).isNotEmpty) ...[
              const SizedBox(height: 12),
              SizedBox(
                height: 200,
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
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
            if (post['institution'] != null || post['department'] != null || post['course'] != null) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 4,
                children: [
                  if (post['institution'] != null)
                    Chip(label: Text(post['institution'], style: const TextStyle(fontSize: 10))),
                  if (post['department'] != null)
                    Chip(label: Text(post['department'], style: const TextStyle(fontSize: 10))),
                  if (post['course'] != null)
                    Chip(label: Text(post['course'], style: const TextStyle(fontSize: 10))),
                ],
              ),
            ],
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _ActionButton(
                  icon: isLiked ? Icons.favorite : Icons.favorite_border,
                  label: '${post['likes_count'] ?? 0}',
                  color: isLiked ? Colors.red : null,
                  onTap: onLike,
                ),
                _ActionButton(
                  icon: Icons.comment_outlined,
                  label: '${post['comments_count'] ?? 0}',
                  onTap: onComment,
                ),
                _ActionButton(
                  icon: Icons.share_outlined,
                  label: '${post['shares_count'] ?? 0}',
                  onTap: onShare,
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
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(color: color)),
          ],
        ),
      ),
    );
  }
}
