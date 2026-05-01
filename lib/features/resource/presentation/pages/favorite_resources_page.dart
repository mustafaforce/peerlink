import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/cubit.dart';
import '../widgets/resource_card.dart';

class FavoriteResourcesPage extends StatelessWidget {
  const FavoriteResourcesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => FavoriteResourceCubit()..loadFavorites(),
      child: const _FavoritesContent(),
    );
  }
}

class _FavoritesContent extends StatelessWidget {
  const _FavoritesContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Favorite Resources')),
      body: BlocBuilder<FavoriteResourceCubit, FavoriteResourceState>(
        builder: (context, state) {
          if (state.status == FavoriteResourceStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.favorites.isEmpty) {
            return const Center(child: Text('No favorite resources'));
          }

          return RefreshIndicator(
            onRefresh: () => context.read<FavoriteResourceCubit>().loadFavorites(),
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: state.favorites.length,
              itemBuilder: (context, index) {
                final favorite = state.favorites[index];
                final resource = favorite['resources'] ?? {};
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: ResourceCard(
                    resource: resource,
                    onTap: () {},
                    onFavorite: () {
                      final resourceId = resource['id'] as String?;
                      if (resourceId != null) {
                        context
                            .read<FavoriteResourceCubit>()
                            .removeFavorite(resourceId);
                      }
                    },
                    onDownload: () {},
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
