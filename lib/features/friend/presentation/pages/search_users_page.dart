import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/di/dependency_injection.dart';
import '../../../../app/router/app_router.dart';
import '../cubit/cubit.dart';
import '../widgets/user_search_item.dart';

class SearchUsersPage extends StatefulWidget {
  const SearchUsersPage({super.key});

  @override
  State<SearchUsersPage> createState() => _SearchUsersPageState();
}

class _SearchUsersPageState extends State<SearchUsersPage> {
  final _searchController = TextEditingController();
  final _institutionController = TextEditingController();
  final _departmentController = TextEditingController();
  bool _showFilters = false;

  @override
  void dispose() {
    _searchController.dispose();
    _institutionController.dispose();
    _departmentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => FriendCubit(
        friendRepository: AppDependencies.friendRepository,
      ),
      child: Builder(
        builder: (ctx) => Scaffold(
          appBar: AppBar(title: const Text('Search Users')),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search by name or email',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _showFilters
                                ? Icons.filter_list_off
                                : Icons.filter_list,
                          ),
                          onPressed: () =>
                              setState(() => _showFilters = !_showFilters),
                        ),
                      ),
                      onSubmitted: (_) => _doSearch(ctx),
                    ),
                    if (_showFilters) ...[
                      const SizedBox(height: 12),
                      TextField(
                        controller: _institutionController,
                        decoration: const InputDecoration(
                          hintText: 'Institution (optional)',
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _departmentController,
                        decoration: const InputDecoration(
                          hintText: 'Department (optional)',
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _doSearch(ctx),
                        child: const Text('Search'),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: BlocBuilder<FriendCubit, FriendState>(
                  builder: (context, state) {
                    if (state.status == FriendStatus.loading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (state.searchResults.isEmpty) {
                      return const Center(
                        child: Text('No users found. Try a different search.'),
                      );
                    }

                    return ListView.builder(
                      itemCount: state.searchResults.length,
                      itemBuilder: (context, index) {
                        final user = state.searchResults[index];
                        return UserSearchItem(
                          user: user,
                          onTap: () => Navigator.of(context).pushNamed(
                            AppRouter.viewProfile,
                            arguments: {'userId': user['id']},
                          ),
                          onAddFriend: () {
                            context
                                .read<FriendCubit>()
                                .sendFriendRequest(user['id']);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Friend request sent!'),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _doSearch(BuildContext ctx) {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    ctx.read<FriendCubit>().searchUsers(
          query: query,
          institution: _institutionController.text.trim().isNotEmpty
              ? _institutionController.text.trim()
              : null,
          department: _departmentController.text.trim().isNotEmpty
              ? _departmentController.text.trim()
              : null,
        );
  }
}
