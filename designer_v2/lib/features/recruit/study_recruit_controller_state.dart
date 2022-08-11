import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/features/study/study_base_state.dart';
import 'package:studyu_designer_v2/repositories/model_repository.dart';

class StudyRecruitControllerState extends StudyControllerBaseState {
  const StudyRecruitControllerState({
    super.studyWithMetadata,
    this.invites = const AsyncValue.loading(),
  });

  /// The list of invite codes (if any) for the currently selected study
  ///
  /// Wrapped in an [AsyncValue] that mirrors the [StudyController]'s current
  /// [Study] async states, so that it can be used with [AsyncValueWidget]
  final AsyncValue<List<StudyInvite>?> invites;

  @override
  StudyRecruitControllerState copyWith({
    WrappedModel<Study>? Function()? studyWithMetadata,
    AsyncValue<List<StudyInvite>> Function()? invites,
  }) {
    return StudyRecruitControllerState(
      studyWithMetadata: (studyWithMetadata != null)
          ? studyWithMetadata() : this.studyWithMetadata,
      invites: (invites != null) ? invites() : this.invites,
    );
  }

  // - Equatable

  @override
  List<Object?> get props => [invites];
}
