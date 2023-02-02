import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:studyu_app/theme.dart';
import 'package:studyu_app/widgets/questionnaire/annotated_scale_question_widget.dart';
import 'package:studyu_core/core.dart';

import 'question_widget.dart';

class ScaleQuestionWidget extends QuestionWidget {
  final ScaleQuestion question;
  final Function(Answer) onDone;

  const ScaleQuestionWidget({Key key, @required this.question, this.onDone}) : super(key: key);

  @override
  State<ScaleQuestionWidget> createState() => _ScaleQuestionWidgetState();
}

class _ScaleQuestionWidgetState extends State<ScaleQuestionWidget> {
  double value;

  @override
  void initState() {
    super.initState();
    value = widget.question.initial;
  }

  void onSliderChanged(double value) {
    setState(() {
      this.value = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final sliderRange = (widget.question.maximum - widget.question.minimum).abs();
    final divisions = (widget.question.maximum - widget.question.minimum) ~/ widget.question.step;

    Color minColor = widget.question.minColor != null ? Color(widget.question.minColor) : null;
    Color maxColor = widget.question.maxColor != null ? Color(widget.question.maxColor) : null;

    final isColored = minColor != null || maxColor != null;
    if (isColored) {
      // set defaults if one or the other is undefined
      minColor ??= Colors.white;
      maxColor ??= Colors.white;
    }

    final theme = Theme.of(context);
    final coloredSliderTheme = ThemeConfig.coloredSliderTheme(theme);
    final thumbColor = isColored ? Color.lerp(minColor, maxColor, value / sliderRange).withOpacity(1) : null;
    final activeTrackColor = isColored ? coloredSliderTheme.activeTrackColor : null;
    final inactiveTrackColor = isColored ? coloredSliderTheme.inactiveTrackColor : null;

    const sliderHeight = 12.0;

    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const SizedBox(width: 24),
            ...buildAnnotations(widget.question, context),
            const SizedBox(width: 24),
          ],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (isColored)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    height: sliderHeight,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(8)),
                      gradient: LinearGradient(
                        colors: [minColor, maxColor],
                      ),
                    ),
                  ),
                )
              else
                const SizedBox.shrink(),
              Theme(
                data: isColored
                    ? theme.copyWith(
                        sliderTheme: SliderThemeData(
                          overlayColor: thumbColor.withOpacity(0.5),
                        ),
                      )
                    : theme,
                child: Slider(
                  value: value,
                  onChanged: onSliderChanged,
                  activeColor: activeTrackColor,
                  inactiveColor: inactiveTrackColor,
                  thumbColor: thumbColor,
                  min: widget.question.minimum,
                  max: widget.question.maximum,
                  divisions: divisions,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => widget.onDone(widget.question.constructAnswer(value)),
            child: Text(AppLocalizations.of(context).done),
          ),
        )
      ],
    );
  }
}
