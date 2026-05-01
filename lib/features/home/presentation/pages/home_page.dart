import 'package:flutter/material.dart';

import '../../../../app/di/dependency_injection.dart';
import '../../../../app/router/app_router.dart';
import '../../../feed/presentation/pages/feed_page.dart';
import '../../../friend/presentation/pages/friends_list_page.dart';
import '../../../profile/presentation/pages/view_profile_page.dart';
import '../../../resource/presentation/pages/resources_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  void _checkAuth() {
    final user = AppDependencies.authRepository.currentUser;
    if (user == null && mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRouter.login,
        (_) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = AppDependencies.authRepository.currentUserId;

    final pages = <Widget>[
      const FeedPage(),
      const ResourcesPage(),
      const FriendsListPage(),
      ViewProfilePage(userId: currentUserId),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: Color(0x1A000000)),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.article_outlined),
              activeIcon: Icon(Icons.article),
              label: 'Feed',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.folder_outlined),
              activeIcon: Icon(Icons.folder),
              label: 'Resources',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people_outline),
              activeIcon: Icon(Icons.people),
              label: 'Friends',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
