import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/signup_page.dart';
import '../../features/home/presentation/pages/home_page.dart';

abstract final class AppRouter {
  static const String login = '/login';
  static const String signup = '/signup';
  static const String home = '/home';

  static String get initialRoute {
    final Session? session = Supabase.instance.client.auth.currentSession;
    return session == null ? login : home;
  }

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    late final Widget page;

    switch (settings.name) {
      case login:
        page = const LoginPage();
        break;
      case signup:
        page = const SignupPage();
        break;
      case home:
        page = const HomePage();
        break;
      default:
        page = const LoginPage();
    }

    return PageRouteBuilder<void>(
      settings: settings,
      pageBuilder:
          (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) => page,
      transitionDuration: const Duration(milliseconds: 340),
      reverseTransitionDuration: const Duration(milliseconds: 240),
      transitionsBuilder: (_, animation, secondaryAnimation, child) {
        final Animation<Offset> slideAnimation =
            Tween<Offset>(
              begin: const Offset(0.06, 0),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
            );

        return FadeTransition(
          opacity: animation,
          child: SlideTransition(position: slideAnimation, child: child),
        );
      },
    );
  }
}
