import 'package:equatable/equatable.dart';

enum ProfileStatus { initial, loading, success, failure }

class ProfileState extends Equatable {
  const ProfileState({
    this.status = ProfileStatus.initial,
    this.error,
    this.user,
    this.posts = const [],
    this.isOwnProfile = true,
    this.isPrivate = false,
  });

  final ProfileStatus status;
  final String? error;
  final Map<String, dynamic>? user;
  final List<Map<String, dynamic>> posts;
  final bool isOwnProfile;
  final bool isPrivate;

  ProfileState copyWith({
    ProfileStatus? status,
    String? error,
    Map<String, dynamic>? user,
    List<Map<String, dynamic>>? posts,
    bool? isOwnProfile,
    bool? isPrivate,
  }) {
    return ProfileState(
      status: status ?? this.status,
      error: error ?? this.error,
      user: user ?? this.user,
      posts: posts ?? this.posts,
      isOwnProfile: isOwnProfile ?? this.isOwnProfile,
      isPrivate: isPrivate ?? this.isPrivate,
    );
  }

  @override
  List<Object?> get props => [status, error, user, posts, isOwnProfile, isPrivate];
}
