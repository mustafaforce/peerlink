import 'package:equatable/equatable.dart';

enum SavedPostStatus { initial, loading, success, failure }

class SavedPostState extends Equatable {
  const SavedPostState({
    this.status = SavedPostStatus.initial,
    this.error,
    this.savedPosts = const [],
  });

  final SavedPostStatus status;
  final String? error;
  final List<Map<String, dynamic>> savedPosts;

  SavedPostState copyWith({
    SavedPostStatus? status,
    String? error,
    List<Map<String, dynamic>>? savedPosts,
  }) {
    return SavedPostState(
      status: status ?? this.status,
      error: error ?? this.error,
      savedPosts: savedPosts ?? this.savedPosts,
    );
  }

  @override
  List<Object?> get props => [status, error, savedPosts];
}
