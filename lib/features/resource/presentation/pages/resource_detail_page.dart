import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/theme/app_colors.dart';
import '../cubit/cubit.dart';

class ResourceDetailPage extends StatelessWidget {
  const ResourceDetailPage({super.key, required this.resourceId});

  final String resourceId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ResourceDetailCubit(resourceId: resourceId)..loadResource(),
      child: const _DetailContent(),
    );
  }
}

class _DetailContent extends StatelessWidget {
  const _DetailContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Resource Details')),
      body: BlocBuilder<ResourceDetailCubit, ResourceDetailState>(
        builder: (context, state) {
          if (state.status == ResourceDetailStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == ResourceDetailStatus.failure) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.error ?? 'Failed to load resource'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<ResourceDetailCubit>().loadResource(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final resource = state.resource;
          if (resource == null) {
            return const Center(child: Text('Resource not found'));
          }

          final avgRating = resource['ratings_count'] != null &&
                  resource['ratings_count'] > 0
              ? (resource['total_rating'] / resource['ratings_count'])
                  .toStringAsFixed(1)
              : null;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  resource['title'] ?? '',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: AppColors.warmGray300.withValues(alpha: 0.2),
                      child: const Icon(Icons.person, size: 20),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      resource['users']?['full_name'] ?? 'Unknown',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                if (resource['description'] != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    resource['description'],
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.5,
                      color: AppColors.warmGray500,
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    if (resource['institution'] != null)
                      Chip(label: Text(resource['institution'])),
                    if (resource['department'] != null)
                      Chip(label: Text(resource['department'])),
                    if (resource['course'] != null)
                      Chip(label: Text(resource['course'])),
                    if (resource['subject'] != null)
                      Chip(label: Text(resource['subject'])),
                    Chip(label: Text(resource['file_type'] ?? 'FILE')),
                  ],
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: AppColors.whisperBorder),
                      bottom: BorderSide(color: AppColors.whisperBorder),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _StatItem(
                        icon: Icons.download,
                        label: '${resource['downloads_count'] ?? 0}',
                        title: 'Downloads',
                      ),
                      _StatItem(
                        icon: Icons.star,
                        label: avgRating ?? '0.0',
                        title: 'Rating',
                      ),
                      _StatItem(
                        icon: Icons.favorite,
                        label: '${resource['favorites_count'] ?? 0}',
                        title: 'Favorites',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Rate this Resource',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                ),
                const SizedBox(height: 8),
                _StarRating(
                  currentRating: state.userRating,
                  onRate: (rating) {
                    context.read<ResourceDetailCubit>().rateResource(rating);
                  },
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      context.read<ResourceDetailCubit>().download();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Download started')),
                      );
                    },
                    icon: const Icon(Icons.download),
                    label: const Text('Download Resource'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StarRating extends StatelessWidget {
  const _StarRating({required this.currentRating, required this.onRate});

  final int currentRating;
  final void Function(int) onRate;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(5, (index) {
        final starIndex = index + 1;
        final isFilled = starIndex <= currentRating;
        return IconButton(
          icon: Icon(
            isFilled ? Icons.star : Icons.star_border,
            color: isFilled ? AppColors.orange : AppColors.warmGray300,
          ),
          onPressed: () => onRate(starIndex),
        );
      }),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.icon,
    required this.label,
    required this.title,
  });

  final IconData icon;
  final String label;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: AppColors.notionBlue),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
        Text(
          title,
          style: TextStyle(
            color: AppColors.warmGray300,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
