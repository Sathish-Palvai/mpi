import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

enum UserType {
  BSP,
  TSO,
  MO;

  String get displayName {
    switch (this) {
      case UserType.BSP:
        return 'BSP';
      case UserType.TSO:
        return 'TSO';
      case UserType.MO:
        return 'MO';
    }
  }

  String getLocalizedName(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context);
    switch (this) {
      case UserType.BSP:
        return appLocalizations.userTypeBsp;
      case UserType.TSO:
        return appLocalizations.userTypeTso;
      case UserType.MO:
        return appLocalizations.userTypeMo;
    }
  }

  Color get color {
    switch (this) {
      case UserType.BSP:
        return Colors.blue;
      case UserType.TSO:
        return Colors.orange;
      case UserType.MO:
        return Colors.green;
    }
  }

  Color get lightColor {
    switch (this) {
      case UserType.BSP:
        return Colors.blue.shade100;
      case UserType.TSO:
        return Colors.orange.shade100;
      case UserType.MO:
        return Colors.green.shade100;
    }
  }

  IconData get icon {
    switch (this) {
      case UserType.BSP:
        return Icons.business;
      case UserType.TSO:
        return Icons.electrical_services;
      case UserType.MO:
        return Icons.settings;
    }
  }
}
