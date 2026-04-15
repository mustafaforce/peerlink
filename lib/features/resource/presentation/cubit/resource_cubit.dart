import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../database/repositories/resource_repository.dart';
import 'resource_state.dart';

class ResourceCubit extends Cubit<ResourceState> {
  ResourceCubit({required ResourceRepository resourceRepository})
      : _resourceRepository = resourceRepository,
        super(const ResourceState());

  final ResourceRepository _resourceRepository;

  Future<void> loadResources({bool refresh = false}) async {
    if (refresh) {
      emit(state.copyWith(status: ResourceStatus.loading, resources: []));
    } else if (state.status == ResourceStatus.loading) {
      return;
    } else {
      emit(state.copyWith(status: ResourceStatus.loading));
    }

    try {
      final resources = await _resourceRepository.searchResources(
        query: state.searchQuery.isNotEmpty ? state.searchQuery : null,
        institution: state.filter['institution'],
        department: state.filter['department'],
        course: state.filter['course'],
        subject: state.filter['subject'],
      );

      emit(state.copyWith(
        status: ResourceStatus.success,
        resources: resources,
        hasMore: resources.length >= 20,
      ));
    } catch (e) {
      emit(state.copyWith(status: ResourceStatus.failure, error: e.toString()));
    }
  }

  Future<void> loadMore() async {
    if (!state.hasMore || state.status == ResourceStatus.loading) return;

    emit(state.copyWith(status: ResourceStatus.loading));

    try {
      final resources = await _resourceRepository.searchResources(
        query: state.searchQuery.isNotEmpty ? state.searchQuery : null,
        institution: state.filter['institution'],
        department: state.filter['department'],
        course: state.filter['course'],
        subject: state.filter['subject'],
        offset: state.resources.length,
      );

      emit(state.copyWith(
        status: ResourceStatus.success,
        resources: [...state.resources, ...resources],
        hasMore: resources.length >= 20,
      ));
    } catch (e) {
      emit(state.copyWith(status: ResourceStatus.failure, error: e.toString()));
    }
  }

  Future<void> searchResources(String query) async {
    emit(state.copyWith(searchQuery: query));
    await loadResources(refresh: true);
  }

  void applyFilter(Map<String, dynamic> filter) {
    emit(state.copyWith(filter: filter));
    loadResources(refresh: true);
  }

  void clearFilter() {
    emit(state.copyWith(filter: {}));
    loadResources(refresh: true);
  }

  Future<void> uploadResource({
    required String title,
    required String description,
    required String fileUrl,
    required String fileType,
    required int fileSize,
    String? institution,
    String? department,
    String? course,
    String? subject,
  }) async {
    final userId = _resourceRepository.currentUserId;
    if (userId == null) {
      emit(state.copyWith(status: ResourceStatus.failure, error: 'Not authenticated'));
      return;
    }

    try {
      await _resourceRepository.uploadResource(
        userId: userId,
        title: title,
        description: description,
        fileUrl: fileUrl,
        fileType: fileType,
        fileSize: fileSize,
        institution: institution,
        department: department,
        course: course,
        subject: subject,
      );
      await loadResources(refresh: true);
    } catch (e) {
      emit(state.copyWith(status: ResourceStatus.failure, error: e.toString()));
    }
  }

  Future<void> rateResource(String resourceId, int rating) async {
    final userId = _resourceRepository.currentUserId;
    if (userId == null) return;

    try {
      await _resourceRepository.rateResource(
        resourceId: resourceId,
        userId: userId,
        rating: rating,
      );
      await loadResources(refresh: true);
    } catch (e) {
      emit(state.copyWith(status: ResourceStatus.failure, error: e.toString()));
    }
  }

  Future<void> addToFavorites(String resourceId) async {
    final userId = _resourceRepository.currentUserId;
    if (userId == null) return;

    try {
      await _resourceRepository.addFavorite(
        resourceId: resourceId,
        userId: userId,
      );
    } catch (e) {
      emit(state.copyWith(status: ResourceStatus.failure, error: e.toString()));
    }
  }

  Future<void> removeFromFavorites(String resourceId) async {
    final userId = _resourceRepository.currentUserId;
    if (userId == null) return;

    try {
      await _resourceRepository.removeFavorite(
        resourceId: resourceId,
        userId: userId,
      );
    } catch (e) {
      emit(state.copyWith(status: ResourceStatus.failure, error: e.toString()));
    }
  }

  Future<void> downloadResource(String resourceId) async {
    try {
      await _resourceRepository.incrementDownloads(resourceId);
      await loadResources(refresh: true);
    } catch (e) {
      emit(state.copyWith(status: ResourceStatus.failure, error: e.toString()));
    }
  }
}
