import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';

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
    final avgRating = resource['ratings_count'] != null &&
            resource['ratings_count'] > 0
        ? (resource['total_rating'] / resource['ratings_count'])
            .toStringAsFixed(1)
        : '0.0';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.whisperBorder),
        boxShadow: AppColors.cardShadow,
      ),
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
                  _fileTypeIcon(resource['file_type']),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          resource['title'] ?? 'Untitled',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user['full_name'] ?? 'Unknown',
                          style: TextStyle(
                            color: AppColors.warmGray300,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? AppColors.error : null,
                    ),
                    onPressed: onFavorite,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  if (resource['institution'] != null)
                    _InfoChip(
                      icon: Icons.school,
                      label: resource['institution'],
                    ),
                  if (resource['department'] != null)
                    _InfoChip(
                      icon: Icons.book,
                      label: resource['department'],
                    ),
                  if (resource['subject'] != null)
                    _InfoChip(
                      icon: Icons.subject,
                      label: resource['subject'],
                    ),
                  _InfoChip(icon: Icons.star, label: avgRating),
                  _InfoChip(
                    icon: Icons.download,
                    label: '${resource['downloads_count'] ?? 0}',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Chip(
                    label: Text(
                      resource['file_type'] ?? 'FILE',
                      style: const TextStyle(fontSize: 11),
                    ),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: onDownload,
                    icon: const Icon(Icons.download, size: 18),
                    label: const Text('Download'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _fileTypeIcon(String? fileType) {
    IconData icon;
    Color color;
    switch (fileType?.toUpperCase()) {
      case 'PDF':
        icon = Icons.picture_as_pdf;
        color = Colors.red;
        break;
      case 'DOC':
      case 'DOCX':
        icon = Icons.description;
        color = AppColors.notionBlue;
        break;
      case 'PPT':
      case 'PPTX':
        icon = Icons.slideshow;
        color = AppColors.orange;
        break;
      case 'XLS':
      case 'XLSX':
        icon = Icons.table_chart;
        color = AppColors.green;
        break;
      case 'PNG':
      case 'JPG':
      case 'JPEG':
        icon = Icons.image;
        color = AppColors.deepNavy;
        break;
      case 'ZIP':
      case 'RAR':
        icon = Icons.folder_zip;
        color = AppColors.warmDark;
        break;
      default:
        icon = Icons.insert_drive_file;
        color = AppColors.warmGray500;
    }
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: color),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.warmGray500),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.warmGray500,
          ),
        ),
      ],
    );
  }
}
