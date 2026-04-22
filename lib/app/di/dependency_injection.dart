import 'package:supabase_flutter/supabase_flutter.dart';

import '../../database/repositories/repositories.dart';
import '../../features/auth/data/repositories/auth_repository.dart';

abstract final class AppDependencies {
  static late final AuthRepository authRepository;
  static late final UserRepository userRepository;
  static late final PostRepository postRepository;
  static late final CommentRepository commentRepository;
  static late final FriendRepository friendRepository;
  static late final ResourceRepository resourceRepository;
  static late final LikeRepository likeRepository;
  static late final SavedPostRepository savedPostRepository;
  static late final ReportRepository reportRepository;
  static late final ResourceRatingRepository resourceRatingRepository;
  static late final FavoriteResourceRepository favoriteResourceRepository;
  static late final FeedRepository feedRepository;

  static void register() {
    final client = Supabase.instance.client;

    authRepository = AuthRepository(client: client);
    userRepository = UserRepository(client: client);
    postRepository = PostRepository(client: client);
    commentRepository = CommentRepository(client: client);
    friendRepository = FriendRepository(client: client);
    resourceRepository = ResourceRepository(client: client);
    likeRepository = LikeRepository(client: client);
    savedPostRepository = SavedPostRepository(client: client);
    reportRepository = ReportRepository(client: client);
    resourceRatingRepository = ResourceRatingRepository(client: client);
    favoriteResourceRepository = FavoriteResourceRepository(client: client);
    feedRepository = FeedRepository(client: client);
  }
}
