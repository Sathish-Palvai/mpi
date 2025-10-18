import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../../core/forms/forms.dart';

/// Participant Validity create form schema definition
/// 
/// This class defines the form structure for participant validity creation operations.
/// It uses the config-driven forms library to declaratively define
/// all fields, validation rules, and layout configuration.
class ParticipantValidityCreateSchema {
  /// Get all form sections for the participant validity create screen
  static List<FormSectionConfig> getAllSections(BuildContext context) {
    return [
      FormSectionConfig(
        fields: [
          FormFieldConfig(
            id: 'ParticipantName',
            label: '${'participantValidity.RegistrationSubmit.ParticipantValidity.ParticipantName'.tr()} *',
            flex: 2,
            minLength: 1,
            maxLength: 10,
            readonly: true,
            required: true,
            placeholder: 'participantValidity.placeholders.ParticipantName'.tr(),
          ),
          FormFieldConfig(
            id: 'ParticipantState',
            label: '${'participantValidity.RegistrationSubmit.ParticipantValidity.ParticipantState'.tr()} *',
            flex: 2,
            readonly: true,
            required: true,
            placeholder: 'participantValidity.placeholders.ParticipantState'.tr(),
          ),
        ],
      ),
      FormSectionConfig(
        fields: [
          FormFieldConfig(
            id: 'StartDate',
            label: '${'participantValidity.RegistrationSubmit.ParticipantValidity.StartDate'.tr()} *',
            type: FieldType.date,
            flex: 2,
            minLength: 10,
            maxLength: 10,
            required: true,
          ),
          FormFieldConfig(
            id: 'TransactionId',
            label: 'participantValidity.RegistrationSubmit.ParticipantValidity.TransactionId'.tr(),
            flex: 2,
            minLength: 2,
            maxLength: 10,
            readonly: true,
            visible: false,
            required: false,
            placeholder: 'participantValidity.placeholders.TransactionId'.tr(),
          ),
        ],
      ),
    ];
  }
}
