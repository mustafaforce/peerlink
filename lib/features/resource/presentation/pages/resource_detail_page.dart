import 'package:flutter/material.dart';

import '../../../../app/di/dependency_injection.dart';

class ResourceDetailPage extends StatefulWidget {
  const ResourceDetailPage({super.key, required this.resourceId});

  final String resourceId;

  @override
  State<ResourceDetailPage> createState() => _ResourceDetailPageState();
}

class _ResourceDetailPageState extends State<ResourceDetailPage> {
  Map<String, dynamic>? _resource;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadResource();
  }

  Future<void> _loadResource() async {
    try {
      final resource = await AppDependencies.resourceRepository.getResourceById(widget.resourceId);
      if (!mounted) return;
      setState(() {
        _resource = resource;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resource Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {},
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _resource == null
              ? const Center(child: Text('Resource not found'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _resource!['title'] ?? '',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.grey[300],
                            child: const Icon(Icons.person),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            (_resource!['users']?['full_name'] ?? 'Unknown'),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (_resource!['description'] != null) ...[
                        Text(_resource!['description']),
                        const SizedBox(height: 16),
                      ],
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          if (_resource!['institution'] != null)
                            Chip(label: Text(_resource!['institution'])),
                          if (_resource!['department'] != null)
                            Chip(label: Text(_resource!['department'])),
                          if (_resource!['course'] != null)
                            Chip(label: Text(_resource!['course'])),
                          if (_resource!['subject'] != null)
                            Chip(label: Text(_resource!['subject'])),
                          Chip(label: Text(_resource!['file_type'] ?? 'Unknown')),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _StatItem(
                            icon: Icons.download,
                            label: '${_resource!['downloads_count'] ?? 0}',
                            title: 'Downloads',
                          ),
                          _StatItem(
                            icon: Icons.star,
                            label: _resource!['ratings_count'] != null && _resource!['ratings_count'] > 0
                                ? '${(_resource!['total_rating'] / _resource!['ratings_count']).toStringAsFixed(1)}'
                                : '0.0',
                            title: 'Rating',
                          ),
                          _StatItem(
                            icon: Icons.favorite,
                            label: '${_resource!['favorites_count'] ?? 0}',
                            title: 'Favorites',
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _buildRatingSection(),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            AppDependencies.resourceRepository.incrementDownloads(widget.resourceId);
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
                ),
    );
  }

  Widget _buildRatingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Rate this Resource', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Row(
          children: List.generate(5, (index) {
            return IconButton(
              icon: const Icon(Icons.star_border),
              onPressed: () async {
                final userId = AppDependencies.authRepository.currentUserId;
                if (userId == null) return;
                await AppDependencies.resourceRepository.rateResource(
                  resourceId: widget.resourceId,
                  userId: userId,
                  rating: index + 1,
                );
                await _loadResource();
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Rated ${index + 1} stars')),
                );
              },
            );
          }),
        ),
      ],
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
        Icon(icon, color: Theme.of(context).primaryColor),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
      ],
    );
  }
}
