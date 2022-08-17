import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/common_views/async_value_widget.dart';
import 'package:studyu_designer_v2/common_views/text_paragraph.dart';
import 'package:studyu_designer_v2/features/design/study_form_providers.dart';
import 'package:studyu_designer_v2/features/forms/form_array_table.dart';
import 'package:studyu_designer_v2/features/design/measurements/survey/survey_form_controller.dart';
import 'package:studyu_designer_v2/features/study/study_controller.dart';
import 'package:studyu_designer_v2/localization/string_hardcoded.dart';

class StudyDesignMeasurementsFormView extends ConsumerWidget {
  const StudyDesignMeasurementsFormView(this.studyId, {Key? key})
      : super(key: key);

  final String studyId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(studyControllerProvider(studyId));
    print("StudyDesignMeasurementsFormView.build");

    return AsyncValueWidget<Study>(
      value: state.study,
      data: (study) {
        final formViewModel =
            ref.read(measurementsFormViewModelProvider(studyId));
        return ReactiveForm(
          formGroup: formViewModel.form,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextParagraph(
                  text: "Define the data you want to gather from participants "
                      "to evaluate the effect of your interventions & for "
                      "additional context. The data will be self-reported "
                      "by participants in one or more surveys served via "
                      "the StudyU app.".hardcoded),
              const SizedBox(height: 32.0),
              ReactiveFormConsumer(
                // [ReactiveFormConsumer] is needed to to rerender when descendant controls are updated
                // By default, ReactiveFormArray only updates when adding/removing controls
                  builder: (context, form, child) {
                    return ReactiveFormArray(
                      formArray: formViewModel.measurementsArray,
                      builder: (context, formArray, child) {
                        return FormArrayTable<MeasurementSurveyFormViewModel>(
                          items: formViewModel.measurementViewModels,
                          onSelectItem: formViewModel.onSelectItem,
                          getActionsAt: (viewModel, _) => formViewModel.availablePopupActions(viewModel),
                          onNewItem: formViewModel.onNewItem,
                          onNewItemLabel: 'Add survey'.hardcoded,
                          rowTitle: (viewModel) => viewModel.formData?.title ?? 'Missing item title'.hardcoded,
                          sectionTitle: "Surveys".hardcoded,
                          sectionTitleDivider: false,
                          emptyIcon: Icons.content_paste_off_rounded,
                          emptyTitle: "No surveys defined".hardcoded,
                          emptyDescription: "You need to define at least one survey to determine the effect of your intervention(s).".hardcoded,
                        );
                      },
                    );
                  }
              ),
            ],
          ),
        );
      },
    );
  }
}