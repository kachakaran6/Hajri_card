import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../constants/translations.dart';
import 'package:hajriapp/l10n/app_localizations.dart';

final localeProvider = StateNotifierProvider<LocaleNotifier, String>((ref) {
  return LocaleNotifier();
});

class LocaleNotifier extends StateNotifier<String> {
  LocaleNotifier() : super('en') {
    _loadLocale();
  }

  void _loadLocale() {
    try {
      final box = Hive.box('settings');
      final savedLocale = box.get('language', defaultValue: 'en') as String;
      state = savedLocale;
    } catch (_) {
      state = 'en';
    }
  }

  void setLocale(String languageCode) {
    if (Translations.keys.containsKey(languageCode)) {
      state = languageCode;
      try {
        final box = Hive.box('settings');
        box.put('language', languageCode);
      } catch (_) {}
    }
  }
}

extension LocalizationExtension on BuildContext {
  String translate(String key) {
    final l10n = AppLocalizations.of(this);
    if (l10n == null) return key;
    
    switch (key.toLowerCase()) {
      case 'present': return l10n.present;
      case 'absent': return l10n.absent;
      case 'half day': return l10n.halfDay;
      case 'leave': return l10n.leave;
      case 'holiday': return l10n.holiday;
      case 'overtime': return l10n.overtime;
      default: return key;
    }
  }
}
