import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_designer_v2/common_views/banner.dart';
import 'package:studyu_designer_v2/common_views/form_consumer_widget.dart';
import 'package:studyu_designer_v2/common_views/form_table_layout.dart';
import 'package:studyu_designer_v2/common_views/standard_table.dart';
import 'package:studyu_designer_v2/common_views/text_paragraph.dart';
import 'package:studyu_designer_v2/features/design/enrollment/screener_question_form_controller.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/types/choice_question_form_view.dart';
import 'package:studyu_designer_v2/localization/string_hardcoded.dart';
import 'package:studyu_designer_v2/theme.dart';

abstract class IScreenerQuestionLogicFormViewModel {
  bool get isDirtyOptionsBannerVisible;
}

class ScreenerQuestionLogicFormView extends FormConsumerWidget {
  const ScreenerQuestionLogicFormView({required this.formViewModel, Key? key})
      : super(key: key);

  final ScreenerQuestionFormViewModel formViewModel;

  @override
  Widget build(BuildContext context, FormGroup form) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextParagraph(
          text: "Define which responses qualify or disqualify participants from "
                "enrolling in your study. To qualify as a participant, at least "
                "one of the qualifying response options and none of the "
                "disqualifying ones must be selected for this question in the "
                "screening survey.".hardcoded,
          style: ThemeConfig.bodyTextMuted(theme),
        ),
        const SizedBox(height: 16.0),
        FormLabel(
          labelText: "Screening rules".hardcoded,
          labelTextStyle: const TextStyle(fontWeight: FontWeight.bold),
          helpText:
              "Define which response options are qualifying or disqualifying "
              "when selected by the participant."
                  .hardcoded,
        ),
        _buildInfoBanner(context),
        const SizedBox(height: 12.0),
        _buildAnswerOptionsLogicControls(),
      ],
    );
  }

  _buildInfoBanner(BuildContext context) {
    return (!formViewModel.isReadonly && formViewModel.isDirtyOptionsBannerVisible)
        ? Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: BannerBox(
              style: BannerStyle.info,
              body: TextParagraph(
                  text:
                      "The options you see here are cleared automatically to "
                      "reflect the available responses. Every option is "
                      "qualifying by default unless you explicitly mark them "
                      "as disqualifying.".hardcoded),
              padding:
                  const EdgeInsets.symmetric(horizontal: 18.0, vertical: 12.0),
              noPrefix: true,
              isDismissed: !formViewModel.isMidValuesClearedInfoVisible,
              dismissIconSize: Theme.of(context).iconTheme.size ?? 14.0,
            ),
          )
        : const SizedBox.shrink();
  }

  _buildAnswerOptionsLogicControls() {
    return ReactiveFormArray(
      formArray: formViewModel.responseOptionsDisabledArray,
      builder: (context, formArray, child) {
        return StandardTable<AbstractControl>(
          items: formViewModel.responseOptionsDisabledControls,
          columns: const [
            StandardTableColumn(
              label: '', // don't care (showTableHeader=false)
              columnWidth: FixedColumnWidth(32.0),
            ),
            StandardTableColumn(
                label: '', // don't care (showTableHeader=false)
                columnWidth: FlexColumnWidth(5)),
            StandardTableColumn(
                label: '', // don't care (showTableHeader=false)
                columnWidth: FlexColumnWidth(4)),
          ],
          onSelectItem: (_) => {}, // no-op
          buildCellsAt: (context, item, rowIdx, __) {
            final optionControl = item as FormControl<dynamic>;
            final logicControl = formViewModel.responseOptionsLogicControls
                .controls[rowIdx] as FormControl<bool>;
            return _buildOptionLogicRow(context, optionControl, logicControl);
          },
          cellSpacing: 4.0,
          rowSpacing: 2.0,
          minRowHeight: null,
          showTableHeader: false,
          rowStyle: StandardTableStyle.plain,
          disableRowInteractions: true,
        );
      },
    );
  }

  List<Widget> _buildOptionLogicRow(BuildContext context,
      FormControl<dynamic> optionControl, FormControl<bool> logicControl) {
    final theme = Theme.of(context);

    // Use a UniqueKey to prevent carry-over of control states to other
    // sidesheet tabs
    final optionCells = buildChoiceOptionRow(context, optionControl);
    final iconWidget = optionCells[0];
    final optionWidget = optionCells[1];
    final logicWidget = Theme(
      data: theme.copyWith(
          inputDecorationTheme:
              ThemeConfig.dropdownInputDecorationTheme(theme)),
      child: ReactiveDropdownField<bool>(
        formControl: logicControl,
        items: formViewModel.logicControlOptions.map((option) {
          return DropdownMenuItem(
            value: option.value,
            child: Text(option.label),
          );
        }).toList(),
      ),
    );

    return [
      iconWidget,
      optionWidget,
      logicWidget,
    ];
  }
}