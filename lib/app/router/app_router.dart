import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/otp_verification_page.dart';
import '../../features/auth/presentation/pages/signup_page.dart';
import '../../features/feed/presentation/pages/comments_page.dart';
import '../../features/feed/presentation/pages/create_post_page.dart';
import '../../features/feed/presentation/pages/feed_page.dart';
import '../../features/feed/presentation/pages/saved_posts_page.dart';
import '../../features/friend/presentation/pages/friend_requests_page.dart';
import '../../features/friend/presentation/pages/friends_list_page.dart';
import '../../features/friend/presentation/pages/search_users_page.dart';
import '../../features/friend/presentation/pages/blocked_users_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/profile/presentation/pages/view_profile_page.dart';
import '../../features/profile/presentation/pages/edit_profile_page.dart';
import '../../features/resource/presentation/pages/resources_page.dart';
import '../../features/resource/presentation/pages/upload_resource_page.dart';
import '../../features/resource/presentation/pages/resource_detail_page.dart';
import '../../features/resource/presentation/pages/favorite_resources_page.dart';

abstract final class AppRouter {
  static const String login = '/login';
  static const String signup = '/signup';
  static const String home = '/home';
  static const String forgotPassword = '/forgot-password';
  static const String otpVerification = '/otp-verification';
  static const String feed = '/feed';
  static const String createPost = '/create-post';
  static const String comments = '/comments';
  static const String savedPosts = '/saved-posts';
  static const String friends = '/friends';
  static const String friendRequests = '/friend-requests';
  static const String searchUsers = '/search-users';
  static const String blockedUsers = '/blocked-users';
  static const String viewProfile = '/view-profile';
  static const String editProfile = '/edit-profile';
  static const String resources = '/resources';
  static const String uploadResource = '/upload-resource';
  static const String resourceDetail = '/resource-detail';
  static const String favoriteResources = '/favorite-resources';

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
      case forgotPassword:
        page = const ForgotPasswordPage();
        break;
      case otpVerification:
        final args = settings.arguments as Map<String, dynamic>;
        page = OtpVerificationPage(email: args['email'] as String);
        break;
      case feed:
        page = const FeedPage();
        break;
      case createPost:
        page = const CreatePostPage();
        break;
      case comments:
        final args = settings.arguments as Map<String, dynamic>;
        page = CommentsPage(postId: args['postId'] as String);
        break;
      case savedPosts:
        page = const SavedPostsPage();
        break;
      case friends:
        page = const FriendsListPage();
        break;
      case friendRequests:
        page = const FriendRequestsPage();
        break;
      case searchUsers:
        page = const SearchUsersPage();
        break;
      case blockedUsers:
        page = const BlockedUsersPage();
        break;
      case viewProfile:
        final args = settings.arguments as Map<String, dynamic>?;
        page = ViewProfilePage(userId: args?['userId'] as String?);
        break;
      case editProfile:
        page = const EditProfilePage();
        break;
      case resources:
        page = const ResourcesPage();
        break;
      case uploadResource:
        page = const UploadResourcePage();
        break;
      case resourceDetail:
        final args = settings.arguments as Map<String, dynamic>;
        page = ResourceDetailPage(resourceId: args['resourceId'] as String);
        break;
      case favoriteResources:
        page = const FavoriteResourcesPage();
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
