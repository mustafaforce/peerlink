import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/di/dependency_injection.dart';
import '../../../../database/repositories/resource_repository.dart';
import 'resource_detail_state.dart';

class ResourceDetailCubit extends Cubit<ResourceDetailState> {
  ResourceDetailCubit({required this.resourceId})
      : _resourceRepository = AppDependencies.resourceRepository,
        super(const ResourceDetailState());

  final String resourceId;
  final ResourceRepository _resourceRepository;

  Future<void> loadResource() async {
    emit(state.copyWith(status: ResourceDetailStatus.loading));
    try {
      final resource = await _resourceRepository.getResourceById(resourceId);
      if (resource.isEmpty) {
        emit(state.copyWith(
          status: ResourceDetailStatus.failure,
          error: 'Resource not found',
        ));
        return;
      }

      int userRating = 0;
      final userId = AppDependencies.authRepository.currentUserId;
      if (userId != null) {
        final rating = await _resourceRepository.getUserRating(resourceId, userId);
        userRating = rating ?? 0;
      }

      emit(state.copyWith(
        status: ResourceDetailStatus.success,
        resource: resource,
        userRating: userRating,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ResourceDetailStatus.failure,
        error: e.toString(),
      ));
    }
  }

  Future<void> rateResource(int rating) async {
    final userId = AppDependencies.authRepository.currentUserId;
    if (userId == null) return;

    try {
      await _resourceRepository.rateResource(
        resourceId: resourceId,
        userId: userId,
        rating: rating,
      );
      emit(state.copyWith(userRating: rating));
      await loadResource();
    } catch (e) {
      emit(state.copyWith(
        status: ResourceDetailStatus.failure,
        error: e.toString(),
      ));
    }
  }

  Future<void> download() async {
    try {
      final resource = state.resource;
      final fileUrl = resource?['file_url'] as String?;
      if (fileUrl != null) {
        await launchUrl(Uri.parse(fileUrl), mode: LaunchMode.externalApplication);
      }
      await _resourceRepository.incrementDownloads(resourceId);
    } catch (_) {}
  }
}
