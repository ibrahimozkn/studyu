import 'package:json_annotation/json_annotation.dart';

import '../../data/data_reference.dart';
import '../../tables/study.dart';
import '../../tables/user_study.dart';
import '../study_result.dart';

part 'numeric_result.g.dart';

@JsonSerializable()
class NumericResult extends StudyResult {
  static const String studyResultType = 'numeric';

  late DataReference<num> resultProperty;

  NumericResult() : super(studyResultType);

  NumericResult.withId() : super.withId(studyResultType);

  factory NumericResult.fromJson(Map<String, dynamic> json) => _$NumericResultFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$NumericResultToJson(this);

  @override
  List<String> getHeaders(Study studySpec) {
    final schedule = studySpec.schedule;
    final numberOfDays = schedule.getNumberOfPhases() * schedule.phaseDuration;
    return Iterable<int>.generate(numberOfDays).map((e) => e.toString()).toList();
  }

  @override
  List getValues(UserStudy instance) {
    final resultSet = resultProperty
        .retrieveFromResults(instance)
        .map<int, num>((key, value) => MapEntry(instance.getDayOfStudyFor(key), value));
    final numberOfDays = instance.schedule.getNumberOfPhases() * instance.schedule.phaseDuration;
    return Iterable<int>.generate(numberOfDays).map((day) => resultSet[day]).toList();
  }
}
