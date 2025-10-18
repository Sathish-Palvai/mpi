import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'settings_state.dart';

abstract class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object?> get props => [];
}

class LoadSettings extends SettingsEvent {
  const LoadSettings();
}

class ChangeTheme extends SettingsEvent {
  final ThemeMode themeMode;
  
  const ChangeTheme(this.themeMode);
  
  @override
  List<Object?> get props => [themeMode];
}

class ChangeLanguage extends SettingsEvent {
  final Locale locale;
  
  const ChangeLanguage(this.locale);
  
  @override
  List<Object?> get props => [locale];
}

class ChangeFontSize extends SettingsEvent {
  final FontSize fontSize;
  
  const ChangeFontSize(this.fontSize);
  
  @override
  List<Object?> get props => [fontSize];
}
