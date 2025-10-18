import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../../core/forms/forms.dart';

/// Participant update form schema definition
/// 
/// This class defines the form structure for participant update operations.
/// It uses the config-driven forms library to declaratively define
/// all fields, validation rules, and layout configuration.
class ParticipantUpdateSchema {
  // Common patterns for validation
  static final participantNamePattern = RegExp(r'^[A-Z0-9]{4}$');
  static final japaneseStringPattern = RegExp(r'^[\u3040-\u309F\u30A0-\u30FF\u4E00-\u9FAFa-zA-Z0-9\s]+$');
  static final numberPattern = RegExp(r'^\d+$');

  /// Get form configuration for upsert (create/update) fields
  static List<FormSectionConfig> getUpsertSections(BuildContext context, {String? participantType}) {
    // Check if participant type is TSO (TRANSMISSION_SYSTEM_OPERATOR)
    final isTSO = participantType == 'TRANSMISSION_SYSTEM_OPERATOR' || 
                  participantType == 'TSO';
    
    return [
      // Section 1: Basic Information
      FormSectionConfig(
        title: '',
        fields: [
          FormFieldConfig(
            id: 'ParticipantName',
            label: 'participant.RegistrationSubmit.Participant.ParticipantName'.tr(),
            flex: 2,
            minLength: 4,
            maxLength: 4,
            readonly: true,
            placeholder: 'participant.placeholders.ParticipantName'.tr(),
            pattern: participantNamePattern,
            patternMessage: 'participant.messages.ParticipantName'.tr(),
          ),
          FormFieldConfig(
            id: 'ParticipantType',
            label: 'participant.RegistrationSubmit.Participant.ParticipantType'.tr(),
            flex: 2,
            readonly: true,
            initialValue: 'BALANCING_SERVICE_PROVIDER',
          ),
        ],
      ),
      
      // Section 2: Area and Dates
      FormSectionConfig(
        fields: [
          FormFieldConfig(
            id: 'Area',
            label: 'participant.RegistrationSubmit.Participant.Area'.tr(),
            type: FieldType.select,
            flex: 2,
            visible: isTSO, // Visible only for TSO participants
            readonly: true,
            selectOptions: [
              'HOKKAIDO',
              'TOHOKU',
              'TOKYO',
              'CHUBU',
              'HOKURIKU',
              'KANSAI',
              'CHUGOKU',
              'SHIKOKU',
              'KYUSHU',
              'OKINAWA',
            ],
          ),
          FormFieldConfig(
            id: 'StartDate',
            label: 'participant.RegistrationSubmit.Participant.StartDate'.tr(),
            type: FieldType.date,
            flex: 1,
            minLength: 10,
            maxLength: 10,
          ),
          FormFieldConfig(
            id: 'EndDate',
            label: 'participant.RegistrationSubmit.Participant.EndDate'.tr(),
            type: FieldType.date,
            flex: 1,
            readonly: true,
            required: false,
          ),
        ],
      ),

      // Section 3: Company Information
      FormSectionConfig(
        title: '',
        fields: [
          FormFieldConfig(
            id: 'CompanyShortName',
            label: 'participant.RegistrationSubmit.Participant.CompanyShortName'.tr(),
            flex: 2,
            minLength: 1,
            maxLength: 10,
            placeholder: 'participant.placeholders.CompanyShortName'.tr(),
            pattern: japaneseStringPattern,
            patternMessage: 'participant.messages.CompanyShortName'.tr(),
          ),
          FormFieldConfig(
            id: 'CompanyLongName',
            label: 'participant.RegistrationSubmit.Participant.CompanyLongName'.tr(),
            type: FieldType.multiline,
            flex: 2,
            minLength: 1,
            maxLength: 50,
            maxLines: 1,
            placeholder: 'participant.placeholders.CompanyLongName'.tr(),
            pattern: japaneseStringPattern,
            patternMessage: 'participant.messages.CompanyLongName'.tr(),
          ),
        ],
      ),
    ];
  }

  /// Get form configuration for other controls (phone, etc.)
  static List<FormSectionConfig> getOtherControlsSections(BuildContext context) {
    return [
      FormSectionConfig(
        title: '',
        fields: [
          FormFieldConfig(
            id: 'PhonePart1',
            label: 'participant.RegistrationSubmit.Participant.PhonePart1'.tr(),
            type: FieldType.phone,
            flex: 3,
            minLength: 1,
            maxLength: 5,
            placeholder: 'participant.placeholders.PhonePart1'.tr(),
            pattern: numberPattern,
            alias: 'participant.RegistrationSubmit.Participant.PhonePart1Alias'.tr(),
            keyboardType: TextInputType.phone,
          ),
          FormFieldConfig(
            id: 'PhonePart2',
            label: 'participant.RegistrationSubmit.Participant.PhonePart2'.tr(),
            type: FieldType.phone,
            flex: 3,
            minLength: 0,
            maxLength: 4,
            placeholder: 'participant.placeholders.PhonePart2'.tr(),
            pattern: numberPattern,
            showLabel: false,
            required: false,
            keyboardType: TextInputType.phone,
          ),
          FormFieldConfig(
            id: 'PhonePart3',
            label: 'participant.RegistrationSubmit.Participant.PhonePart3'.tr(),
            type: FieldType.phone,
            flex: 3,
            minLength: 0,
            maxLength: 4,
            placeholder: 'participant.placeholders.PhonePart3'.tr(),
            pattern: numberPattern,
            showLabel: false,
            required: false,
            keyboardType: TextInputType.phone,
          ),
        ],
      ),
      
      FormSectionConfig(
        fields: [
          FormFieldConfig(
            id: 'TransactionId',
            label: 'participant.RegistrationSubmit.Participant.TransactionId'.tr(),
            flex: 1,
            readonly: true,
            required: false,
            visible: false,
            minLength: 0,
            maxLength: 10,
            placeholder: 'participant.placeholders.TransactionId'.tr(),
          ),
        ],
      ),
    ];
  }

  /// Get all sections combined
  static List<FormSectionConfig> getAllSections(BuildContext context, {String? participantType}) {
    return [
      ...getUpsertSections(context, participantType: participantType),
      ...getOtherControlsSections(context),
    ];
  }

  /// Get all field IDs
  static List<String> getAllFieldIds(BuildContext context, {String? participantType}) {
    final sections = getAllSections(context, participantType: participantType);
    final ids = <String>[];
    
    for (final section in sections) {
      for (final field in section.fields) {
        ids.add(field.id);
      }
    }
    
    return ids;
  }
}