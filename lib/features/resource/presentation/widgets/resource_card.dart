import 'package:flutter/material.dart';

class ResourceCard extends StatelessWidget {
  const ResourceCard({
    super.key,
    required this.resource,
    this.onTap,
    this.onFavorite,
    this.onDownload,
  });

  final Map<String, dynamic> resource;
  final VoidCallback? onTap;
  final VoidCallback? onFavorite;
  final VoidCallback? onDownload;

  @override
  Widget build(BuildContext context) {
    final user = resource['users'] as Map<String, dynamic>? ?? {};
    final isFavorite = resource['is_favorite'] ?? false;
    final avgRating = resource['ratings_count'] != null && resource['ratings_count'] > 0
        ? (resource['total_rating'] / resource['ratings_count']).toStringAsFixed(1)
        : '0.0';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _getFileIcon(resource['file_type']),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          resource['title'] ?? 'Untitled',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user['full_name'] ?? 'Unknown',
                          style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border, color: isFavorite ? Colors.red : null),
                    onPressed: onFavorite,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  if (resource['institution'] != null) _InfoChip(icon: Icons.school, label: resource['institution']),
                  if (resource['department'] != null) _InfoChip(icon: Icons.book, label: resource['department']),
                  if (resource['subject'] != null) _InfoChip(icon: Icons.subject, label: resource['subject']),
                  _InfoChip(icon: Icons.star, label: avgRating),
                  _InfoChip(icon: Icons.download, label: '${resource['downloads_count'] ?? 0}'),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Chip(label: Text(resource['file_type'] ?? 'FILE', style: const TextStyle(fontSize: 10)), padding: EdgeInsets.zero, materialTapTargetSize: MaterialTapTargetSize.shrinkWrap),
                  const Spacer(),
                  TextButton.icon(onPressed: onDownload, icon: const Icon(Icons.download, size: 18), label: const Text('Download')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _getFileIcon(String? fileType) {
    IconData icon;
    Color color;
    switch (fileType?.toUpperCase()) {
      case 'PDF': icon = Icons.picture_as_pdf; color = Colors.red; break;
      case 'DOC': case 'DOCX': icon = Icons.description; color = Colors.blue; break;
      case 'PPT': case 'PPTX': icon = Icons.slideshow; color = Colors.orange; break;
      case 'XLS': case 'XLSX': icon = Icons.table_chart; color = Colors.green; break;
      case 'PNG': case 'JPG': case 'JPEG': icon = Icons.image; color = Colors.purple; break;
      case 'ZIP': case 'RAR': icon = Icons.folder_zip; color = Colors.brown; break;
      default: icon = Icons.insert_drive_file; color = Colors.grey;
    }
    return Container(width: 48, height: 48, decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Icon(icon, color: color));
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});
  final IconData icon;
  final String label;
  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 14, color: Colors.grey[600]),
      const SizedBox(width: 4),
      Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
    ]);
  }
}
