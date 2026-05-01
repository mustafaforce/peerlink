import 'package:equatable/equatable.dart';

enum FavoriteResourceStatus { initial, loading, success, failure }

class FavoriteResourceState extends Equatable {
  const FavoriteResourceState({
    this.status = FavoriteResourceStatus.initial,
    this.error,
    this.favorites = const [],
  });

  final FavoriteResourceStatus status;
  final String? error;
  final List<Map<String, dynamic>> favorites;

  FavoriteResourceState copyWith({
    FavoriteResourceStatus? status,
    String? error,
    List<Map<String, dynamic>>? favorites,
  }) {
    return FavoriteResourceState(
      status: status ?? this.status,
      error: error ?? this.error,
      favorites: favorites ?? this.favorites,
    );
  }

  @override
  List<Object?> get props => [status, error, favorites];
}
