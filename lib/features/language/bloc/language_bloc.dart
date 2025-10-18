import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'language_event.dart';
import 'language_state.dart';

class LanguageBloc extends Bloc<LanguageEvent, LanguageState> {
  LanguageBloc() : super(const LanguageInitial(Locale('en'))) {
    on<LanguageChanged>(_onLanguageChanged);
    _loadSavedLanguage();
  }

  Future<void> _onLanguageChanged(
    LanguageChanged event,
    Emitter<LanguageState> emit,
  ) async {
    emit(LanguageInitial(event.locale));
    await _saveLanguage(event.locale.languageCode);
  }

  Future<void> _loadSavedLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final languageCode = prefs.getString('language_code') ?? 'en';
      add(LanguageChanged(Locale(languageCode)));
    } catch (e) {
      // Default to English if loading fails
      add(const LanguageChanged(Locale('en')));
    }
  }

  Future<void> _saveLanguage(String languageCode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('language_code', languageCode);
    } catch (e) {
      // Handle error silently
    }
  }
}
