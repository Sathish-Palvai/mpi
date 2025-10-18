import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class LanguageState extends Equatable {
  const LanguageState();

  @override
  List<Object> get props => [];
}

class LanguageInitial extends LanguageState {
  final Locale locale;

  const LanguageInitial(this.locale);

  @override
  List<Object> get props => [locale];
}
