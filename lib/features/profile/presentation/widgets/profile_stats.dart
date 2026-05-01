import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';

class ProfileStats extends StatelessWidget {
  const ProfileStats({
    super.key,
    this.postsCount = 0,
    this.friendsCount = 0,
    this.resourcesCount = 0,
  });

  final int postsCount;
  final int friendsCount;
  final int resourcesCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: AppColors.whisperBorder),
          bottom: BorderSide(color: AppColors.whisperBorder),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _StatItem(label: 'Posts', value: '$postsCount'),
          _StatItem(label: 'Friends', value: '$friendsCount'),
          _StatItem(label: 'Resources', value: '$resourcesCount'),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 4),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
