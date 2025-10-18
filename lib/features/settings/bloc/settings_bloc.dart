import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'settings_event.dart';
import 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  static const String _themeKey = 'theme_mode';
  static const String _localeKey = 'locale';
  static const String _fontSizeKey = 'font_size';
  
  SettingsBloc() : super(SettingsInitial()) {
    on<LoadSettings>(_onLoadSettings);
    on<ChangeTheme>(_onChangeTheme);
    on<ChangeLanguage>(_onChangeLanguage);
    on<ChangeFontSize>(_onChangeFontSize);
  }

  Future<void> _onLoadSettings(
    LoadSettings event,
    Emitter<SettingsState> emit,
  ) async {
    emit(SettingsLoading());
    
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Load theme mode
      final themeIndex = prefs.getInt(_themeKey) ?? ThemeMode.system.index;
      final themeMode = ThemeMode.values[themeIndex];
      
      // Load locale
      final localeCode = prefs.getString(_localeKey) ?? 'en';
      final locale = Locale(localeCode);
      
      // Load font size
      final fontSizeIndex = prefs.getInt(_fontSizeKey) ?? FontSize.medium.index;
      final fontSize = FontSize.values[fontSizeIndex];
      
      emit(SettingsLoaded(
        themeMode: themeMode,
        locale: locale,
        fontSize: fontSize,
      ));
    } catch (e) {
      // If error, emit default settings
      emit(const SettingsLoaded(
        themeMode: ThemeMode.system,
        locale: Locale('en'),
      ));
    }
  }

  Future<void> _onChangeTheme(
    ChangeTheme event,
    Emitter<SettingsState> emit,
  ) async {
    if (state is SettingsLoaded) {
      final currentState = state as SettingsLoaded;
      
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt(_themeKey, event.themeMode.index);
        
        emit(currentState.copyWith(themeMode: event.themeMode));
      } catch (e) {
        // If saving fails, still emit the new state
        emit(currentState.copyWith(themeMode: event.themeMode));
      }
    }
  }

  Future<void> _onChangeLanguage(
    ChangeLanguage event,
    Emitter<SettingsState> emit,
  ) async {
    if (state is SettingsLoaded) {
      final currentState = state as SettingsLoaded;
      
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_localeKey, event.locale.languageCode);
        
        emit(currentState.copyWith(locale: event.locale));
      } catch (e) {
        // If saving fails, still emit the new state
        emit(currentState.copyWith(locale: event.locale));
      }
    }
  }

  Future<void> _onChangeFontSize(
    ChangeFontSize event,
    Emitter<SettingsState> emit,
  ) async {
    if (state is SettingsLoaded) {
      final currentState = state as SettingsLoaded;
      
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt(_fontSizeKey, event.fontSize.index);
        
        emit(currentState.copyWith(fontSize: event.fontSize));
      } catch (e) {
        // If saving fails, still emit the new state
        emit(currentState.copyWith(fontSize: event.fontSize));
      }
    }
  }
}
