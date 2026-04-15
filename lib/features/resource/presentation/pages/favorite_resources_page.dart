import 'package:flutter/material.dart';

import '../../../../app/di/dependency_injection.dart';
import '../widgets/resource_card.dart';

class FavoriteResourcesPage extends StatefulWidget {
  const FavoriteResourcesPage({super.key});

  @override
  State<FavoriteResourcesPage> createState() => _FavoriteResourcesPageState();
}

class _FavoriteResourcesPageState extends State<FavoriteResourcesPage> {
  List<Map<String, dynamic>> _favorites = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() => _isLoading = true);
    try {
      final userId = AppDependencies.authRepository.currentUserId;
      if (userId != null) {
        final favorites = await AppDependencies.favoriteResourceRepository.getUserFavorites(userId);
        if (!mounted) return;
        setState(() {
          _favorites = favorites;
          _isLoading = false;
        });
      } else {
        if (!mounted) return;
        setState(() {
          _favorites = [];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorite Resources'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _favorites.isEmpty
              ? const Center(child: Text('No favorite resources'))
              : RefreshIndicator(
                  onRefresh: _loadFavorites,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _favorites.length,
                    itemBuilder: (context, index) {
                      final favorite = _favorites[index];
                      final resource = favorite['resources'] ?? {};
                      return ResourceCard(
                        resource: resource,
                        onTap: () {},
                        onFavorite: () async {
                          final userId = AppDependencies.authRepository.currentUserId;
                          final resourceId = resource['id'] as String?;
                          if (userId == null || resourceId == null) return;
                          await AppDependencies.favoriteResourceRepository.removeFavorite(
                            userId,
                            resourceId,
                          );
                          await _loadFavorites();
                        },
                        onDownload: () {},
                      );
                    },
                  ),
                ),
    );
  }
}
