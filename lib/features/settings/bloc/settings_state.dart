import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

enum FontSize {
  small,
  medium,
  large,
  extraLarge;

  double get scaleFactor {
    switch (this) {
      case FontSize.small:
        return 0.65;
      case FontSize.medium:
        return 0.80;
      case FontSize.large:
        return 0.95;
      case FontSize.extraLarge:
        return 1.10;
    }
  }

  String get label {
    return 'settings.fontSize.sizes.$name'.tr();
  }

  String get description {
    return 'settings.fontSize.descriptions.$name'.tr();
  }
}

abstract class SettingsState extends Equatable {
  const SettingsState();

  @override
  List<Object?> get props => [];
}

class SettingsInitial extends SettingsState {}

class SettingsLoading extends SettingsState {}

class SettingsLoaded extends SettingsState {
  final ThemeMode themeMode;
  final Locale locale;
  final FontSize fontSize;
  
  const SettingsLoaded({
    required this.themeMode,
    required this.locale,
    this.fontSize = FontSize.medium,
  });
  
  @override
  List<Object?> get props => [themeMode, locale, fontSize];
  
  SettingsLoaded copyWith({
    ThemeMode? themeMode,
    Locale? locale,
    FontSize? fontSize,
  }) {
    return SettingsLoaded(
      themeMode: themeMode ?? this.themeMode,
      locale: locale ?? this.locale,
      fontSize: fontSize ?? this.fontSize,
    );
  }
}
