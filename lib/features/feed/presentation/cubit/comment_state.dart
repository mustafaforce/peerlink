import 'package:equatable/equatable.dart';

enum CommentStatus { initial, loading, success, failure }

class CommentState extends Equatable {
  const CommentState({
    this.status = CommentStatus.initial,
    this.error,
    this.comments = const [],
  });

  final CommentStatus status;
  final String? error;
  final List<Map<String, dynamic>> comments;

  CommentState copyWith({
    CommentStatus? status,
    String? error,
    List<Map<String, dynamic>>? comments,
  }) {
    return CommentState(
      status: status ?? this.status,
      error: error ?? this.error,
      comments: comments ?? this.comments,
    );
  }

  @override
  List<Object?> get props => [status, error, comments];
}
