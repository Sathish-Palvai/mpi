import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../../core/forms/forms.dart';

/// Participant create form schema definition
/// 
/// This class defines the form structure for participant creation operations.
/// It uses the config-driven forms library to declaratively define
/// all fields, validation rules, and layout configuration.
class ParticipantCreateSchema {
  // Common patterns for validation
  static final participantNamePattern = RegExp(r'^[A-Z0-9]{4}$');
  static final japaneseStringPattern = RegExp(r'^[\u3040-\u309F\u30A0-\u30FF\u4E00-\u9FAFa-zA-Z0-9\s]+$');
  static final numberPattern = RegExp(r'^\d+$');

  /// Get form configuration for create fields
  static List<FormSectionConfig> getCreateSections(BuildContext context) {
    return [
      // Section 1: Basic Information
      FormSectionConfig(
        fields: [
          FormFieldConfig(
            id: 'ParticipantName',
            label: 'participant.RegistrationSubmit.Participant.ParticipantName'.tr(),
            flex: 2,
            minLength: 0,
            maxLength: 4,
            readonly: true,
            required: false,
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
            visible: false,
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
            label: '${'participant.RegistrationSubmit.Participant.StartDate'.tr()} *',
            type: FieldType.date,
            flex: 1,
            minLength: 10,
            maxLength: 10,
            required: true,
          ),
        ],
      ),

      // Section 3: Company Information
      FormSectionConfig(
        fields: [
          FormFieldConfig(
            id: 'CompanyShortName',
            label: '${'participant.RegistrationSubmit.Participant.CompanyShortName'.tr()} *',
            flex: 2,
            minLength: 1,
            maxLength: 10,
            required: true,
            placeholder: 'Max 10 chars',
            pattern: japaneseStringPattern,
            patternMessage: 'participant.messages.CompanyShortName'.tr(),
          ),
          FormFieldConfig(
            id: 'CompanyLongName',
            label: '${'participant.RegistrationSubmit.Participant.CompanyLongName'.tr()} *',
            type: FieldType.multiline,
            flex: 2,
            minLength: 1,
            maxLength: 50,
            maxLines: 4,
            required: true,
            placeholder: 'Max 50 chars',
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
        fields: [
          FormFieldConfig(
            id: 'PhonePart1',
            label: '${'participant.RegistrationSubmit.Participant.PhonePart1'.tr()} *',
            type: FieldType.phone,
            flex: 3,
            minLength: 1,
            maxLength: 5,
            required: true,
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
    ];
  }

  /// Get all sections combined
  static List<FormSectionConfig> getAllSections(BuildContext context) {
    return [
      ...getCreateSections(context),
      ...getOtherControlsSections(context),
    ];
  }

  /// Get all field IDs
  static List<String> getAllFieldIds(BuildContext context) {
    final sections = getAllSections(context);
    final ids = <String>[];
    
    for (final section in sections) {
      for (final field in section.fields) {
        ids.add(field.id);
      }
    }
    
    return ids;
  }
}