import 'package:studyu_designer_v2/constants.dart';
import 'package:studyu_designer_v2/localization/string_hardcoded.dart';

extension EnumX on Enum {
  String toShortString() {
    return toString().split('.').last;
  }
}

extension StringX on String {
  bool get isNewId => this == Config.newModelId;

  String toKey() {
    return toLowerCase().replaceAll(' ', '_');
  }

  String withDuplicateLabel({label = kDuplicateLabel}) {
    final regexStr = r"\((?:" + label + r")\s*(\d*)\)$";
    final suffixFactory =
        (n) => (n > 0) ? "($label ${n.toString()})" : "($label)";
    final regex = RegExp(regexStr);

    Iterable<RegExpMatch> matches = regex.allMatches(this);

    if (matches.isNotEmpty) {
      final matchedSuffix = matches.last;
      final matchedIncrement = matchedSuffix.group(1);
      final currentIncrement =
          (matchedIncrement == null || matchedIncrement == '')
              ? 0
              : int.parse(matchedIncrement);
      final strWithoutLabel =
          replaceRange(matchedSuffix.start, matchedSuffix.end, '').trim();
      return "$strWithoutLabel ${suffixFactory(currentIncrement + 1)}";
    }
    return "${this} ${suffixFactory(0)}";
  }

  List<String> get alphabet {
    return [
      'a',
      'b',
      'c',
      'd',
      'e',
      'f',
      'g',
      'h',
      'i',
      'j',
      'k',
      'l',
      'm',
      'n',
      'o'
    ];
  }

  String alphabetLetterFrom(int idx) {
    return alphabet[idx % alphabet.length];
  }

  String ensureSuffix(String suffix) {
    if (!endsWith(suffix)) {
      return this + suffix;
    }
    return this;
  }
}

extension DurationX on Duration {
  int get daysPerMonth => 30;
  int get daysPerYear => 365;
  int get microsecondsPerMonth => Duration.microsecondsPerDay * daysPerMonth;
  int get microsecondsPerYear => Duration.microsecondsPerDay * daysPerYear;
  int get inMonths => inMicroseconds ~/ microsecondsPerMonth;
  int get inYears => inMicroseconds ~/ microsecondsPerYear;
}

extension DateTimeAgoX on DateTime {
  String _timeAgoFormatted({inSeconds = true}) {
    Duration diff = DateTime.now().difference(this);

    if (diff.inYears >= 1) {
      if (diff.inYears == 1) {
        return '${diff.inYears} year ago'.hardcoded;
      } else {
        return '${diff.inYears} years ago'.hardcoded;
      }
    } else if (diff.inMonths >= 1) {
      if (diff.inMonths == 1) {
        return '${diff.inMonths} month ago'.hardcoded;
      } else {
        return '${diff.inMonths} months ago'.hardcoded;
      }
    } else if (diff.inDays >= 1) {
      if (diff.inDays == 1) {
        return '${diff.inDays} day ago'.hardcoded;
      } else {
        return '${diff.inDays} days ago'.hardcoded;
      }
    } else if (diff.inHours >= 1) {
      if (diff.inHours == 1) {
        return '${diff.inHours} hour ago'.hardcoded;
      } else {
        return '${diff.inHours} hours ago'.hardcoded;
      }
    } else if (diff.inMinutes >= 1) {
      if (diff.inMinutes == 1) {
        return '${diff.inMinutes} minute ago'.hardcoded;
      } else {
        return '${diff.inMinutes} minutes ago'.hardcoded;
      }
    } else if (diff.inSeconds >= 1 && inSeconds) {
      if (diff.inSeconds == 1) {
        return '${diff.inSeconds} minute ago'.hardcoded;
      } else {
        return '${diff.inSeconds} minutes ago'.hardcoded;
      }
    } else {
      return 'just now'.hardcoded;
    }
  }

  String toTimeAgoString() {
    return _timeAgoFormatted(inSeconds: false);
  }

  String toTimeAgoStringPrecise() {
    return _timeAgoFormatted(inSeconds: true);
  }
}

typedef ListElementFactory<E> = E Function();

extension ListX<E> on List<E> {
  List<E> separatedBy(ListElementFactory<E> separatorBuilder) {
    final List<E> results = [];
    for (var i = 0; i < length; i++) {
      results.add(this[i]);
      if (i != length - 1) {
        results.add(separatorBuilder());
      }
    }
    return results;
  }
}

extension FirstWhereOrNullExtension<E> on Iterable<E> {
  E? firstWhereOrNull(bool Function(E) test) {
    for (E element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}
