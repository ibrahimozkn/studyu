import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyu_designer_v2/constants.dart';
import 'package:studyu_flutter_common/studyu_flutter_common.dart';

import 'locale_providers.dart';

Locale fallbackLocale = Locale(Config.defaultLocale.first, Config.defaultLocale.last);

@immutable
class LocaleState {
  const LocaleState(this.locale);

  final Locale locale;

  LocaleState copyWith({Locale? locale}) {
    return LocaleState(locale ?? this.locale);
  }
}

class LocaleStateNotifier extends StateNotifier<LocaleState> {
  final Ref ref;
  static const _localStorageKey = 'lang';

  LocaleStateNotifier(this.ref) : super(LocaleState(fallbackLocale));

  /// Initialize Locale
  /// Can be run at startup to establish the initial local from storage, or the platform
  /// 1. Attempts to restore locale from storage
  /// 2. IF no locale in storage, attempts to set local from the platform settings
  Future<void> initLocale() async {
    // Attempt to restore from storage
    bool fromStorageSuccess = await restoreFromStorage();

    // If storage restore did not work, set from platform
    if (!fromStorageSuccess) {
      setLocale(ref.read(platformLocaleProvider));
    }
  }

  /// Set Locale
  /// Attempts to set the locale if it's in our list of supported locales.
  /// IF NOT: get the first locale that matches our language code and set that
  /// ELSE: do nothing.
  void setLocale(Locale locale) {
    List<Locale> supportedLocales = ref.read(supportedLocalesProvider);

    // Set the locale if it's in our list of supported locales
    if (supportedLocales.contains(locale)) {
      state = state.copyWith(locale: locale);
      save();
    }

    // Get the closest language locale and set that instead
    Locale? closestLocale;
    for (Locale supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        closestLocale = supportedLocale;
      }
    }
    if (closestLocale != null) {
      state = state.copyWith(locale: closestLocale);
      save();
    }
  }

  /// Restore Locale from Storage
  Future<bool> restoreFromStorage() async {
    try {
      LocaleState? state = await load();
      if (state == null) {
        return false;
      }
      state = state;
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<LocaleState?> load() async {
    try {
      String? locString = await SecureStorage.read(_localStorageKey);
      if (locString != null) {
        final locale = locString.split('-');
        return LocaleState(Locale(locale.first, locale.last));
      }
    } catch (e) {
      rethrow;
    }
    return null;
  }

  Future<void> save() async {
    SecureStorage.write(_localStorageKey, state.locale.toLanguageTag());
  }
}
