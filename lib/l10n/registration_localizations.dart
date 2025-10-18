import 'package:flutter/material.dart';
import 'app_localizations.dart';

/// Registration module localization helper
/// 
/// This class provides a nested structure for accessing registration-related
/// translations, mimicking the Angular i18n JSON structure.
/// 
/// Usage:
/// ```dart
/// final reg = RegistrationLocalizations.of(context);
/// Text(reg.participant.header.title);
/// Text(reg.participant.submit.participantName);
/// ```
class RegistrationLocalizations {
  final BuildContext context;
  final AppLocalizations _l10n;

  RegistrationLocalizations._(this.context, this._l10n);

  factory RegistrationLocalizations.of(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return RegistrationLocalizations._(context, l10n);
  }

  /// Participant-related translations
  ParticipantLocalizations get participant => ParticipantLocalizations._(_l10n);
}

/// Participant module translations with nested structure
class ParticipantLocalizations {
  final AppLocalizations _l10n;

  ParticipantLocalizations._(this._l10n);

  /// Header translations (titles)
  ParticipantHeaderLocalizations get header => ParticipantHeaderLocalizations._(_l10n);

  /// Tab labels
  ParticipantTabsLocalizations get tabs => ParticipantTabsLocalizations._(_l10n);

  /// Field placeholders
  ParticipantPlaceholdersLocalizations get placeholders => ParticipantPlaceholdersLocalizations._(_l10n);

  /// Tooltips
  ParticipantTooltipsLocalizations get tooltips => ParticipantTooltipsLocalizations._(_l10n);

  /// Validation messages
  ParticipantMessagesLocalizations get messages => ParticipantMessagesLocalizations._(_l10n);

  /// Query form fields (RegistrationQuery)
  ParticipantQueryLocalizations get query => ParticipantQueryLocalizations._(_l10n);

  /// Submit form fields (RegistrationSubmit)
  ParticipantSubmitLocalizations get submit => ParticipantSubmitLocalizations._(_l10n);

  /// Action buttons
  ParticipantButtonsLocalizations get buttons => ParticipantButtonsLocalizations._(_l10n);

  /// Feedback messages
  ParticipantFeedbackLocalizations get feedback => ParticipantFeedbackLocalizations._(_l10n);
}

/// Header translations
class ParticipantHeaderLocalizations {
  final AppLocalizations _l10n;

  ParticipantHeaderLocalizations._(this._l10n);

  String get title => _l10n.participantDetailsTitle;
  String get newTitle => _l10n.addNewParticipant;
}

/// Tab labels
class ParticipantTabsLocalizations {
  final AppLocalizations _l10n;

  ParticipantTabsLocalizations._(this._l10n);

  String get general => _l10n.participantGeneralTab;
  String get validity => _l10n.participantValidityTab;
  String get bankAccount => _l10n.participantBankAccountTab;
}

/// Field placeholders
class ParticipantPlaceholdersLocalizations {
  final AppLocalizations _l10n;

  ParticipantPlaceholdersLocalizations._(this._l10n);

  String get participantName => _l10n.participantNamePlaceholder;
  String get companyLongName => _l10n.companyLongNamePlaceholder;
  String get companyShortName => _l10n.companyShortNamePlaceholder;
  String get phonePart1 => _l10n.phonePart1Placeholder;
  String get phonePart2 => _l10n.phonePart2Placeholder;
  String get phonePart3 => _l10n.phonePart3Placeholder;
  String get transactionId => _l10n.transactionIdPlaceholder;
}

/// Tooltips
class ParticipantTooltipsLocalizations {
  final AppLocalizations _l10n;

  ParticipantTooltipsLocalizations._(this._l10n);

  String get addNewParticipant => _l10n.addNewParticipantTooltip;
  String get addParticipant => _l10n.addParticipantTooltip;
}

/// Validation messages
class ParticipantMessagesLocalizations {
  final AppLocalizations _l10n;

  ParticipantMessagesLocalizations._(this._l10n);

  String get companyLongName => _l10n.companyLongNamePattern;
  String get companyShortName => _l10n.companyShortNamePattern;
  String get participantName => _l10n.participantNamePattern;
}

/// Query form fields
class ParticipantQueryLocalizations {
  final AppLocalizations _l10n;

  ParticipantQueryLocalizations._(this._l10n);

  String get date => _l10n.tradeDateLabel;
  String get participantName => _l10n.participantNameLabel;
}

/// Submit form fields
class ParticipantSubmitLocalizations {
  final AppLocalizations _l10n;

  ParticipantSubmitLocalizations._(this._l10n);

  String get participantName => _l10n.participantNameLabel;
  String get participantType => _l10n.participantTypeLabel;
  String get startDate => _l10n.startDateLabel;
  String get endDate => _l10n.endDateLabel;
  String get area => _l10n.areaLabel;
  String get companyShortName => _l10n.companyShortNameLabel;
  String get companyLongName => _l10n.companyLongNameLabel;
  String get phonePart1Alias => _l10n.phonePart1Label;
  String get phonePart1 => _l10n.phoneNumberLabel;
  String get phonePart2 => _l10n.phonePart2Label;
  String get phonePart3 => _l10n.phonePart3Label;
  String get transactionId => _l10n.transactionIdLabel;
}

/// Action buttons
class ParticipantButtonsLocalizations {
  final AppLocalizations _l10n;

  ParticipantButtonsLocalizations._(this._l10n);

  String get reset => _l10n.resetButton;
  String get create => _l10n.createParticipantButton;
  String get creating => _l10n.creatingParticipant;
  String get save => _l10n.saveButton;
  String get saving => _l10n.savingChanges;
  String get query => _l10n.queryParticipantButton;
}

/// Feedback messages
class ParticipantFeedbackLocalizations {
  final AppLocalizations _l10n;

  ParticipantFeedbackLocalizations._(this._l10n);

  String get messagesTitle => _l10n.messagesTitle;
  String createdSuccess(String name) => _l10n.participantCreatedSuccess(name);
  String get updatedSuccess => _l10n.participantUpdatedSuccess;
  String get querySuccess => _l10n.participantQuerySuccess;
  String get fixFormErrors => _l10n.fixFormErrors;
  String get nameTrimmed => _l10n.participantNameTrimmed;
  String failedToCreate(String error) => _l10n.failedToCreateParticipant(error);
  String failedToUpdate(String error) => _l10n.failedToUpdateParticipant(error);
  String failedToQuery(String error) => _l10n.failedToQueryParticipant(error);
}
