import 'package:flutter/material.dart';
import '../../../../../core/forms/forms.dart';
import 'package:easy_localization/easy_localization.dart';

/// Participant Validity query form schema definition
/// 
/// This class defines the form structure for participant validity query operations.
/// It allows users to search for participant validity records by name and date.
class ParticipantValidityQuerySchema {
  /// Get form configuration for query fields
  static List<FormSectionConfig> getQuerySections(BuildContext context) {
    return [
      FormSectionConfig(
        fields: [
          FormFieldConfig(
            id: 'qParticipantName',
            label: 'participant.fields.participantName'.tr(),
            type: FieldType.select,
            flex: 1,
            required: true,
            minLength: 2,
            maxLength: 10,
            placeholder: 'participant.placeholders.participantName'.tr(),
            selectOptions: [], // Will be populated dynamically
            maxDropdownItems: 5, // Limit to 5 items with scrolling
          ),
        ],
      ),
      FormSectionConfig(
        fields: [
          FormFieldConfig(
            id: 'qDate',
            label: 'participant.fields.date'.tr(),
            type: FieldType.date,
            flex: 1,
            required: false,
            minLength: 10,
            maxLength: 10,
            placeholder: 'YYYY-MM-DD (optional)',
            initialValue: '', // Explicitly set to blank
          ),
        ],
      ),
    ];
  }

  /// Get all field IDs
  static List<String> getAllFieldIds(BuildContext context) {
    final sections = getQuerySections(context);
    final ids = <String>[];
    
    for (final section in sections) {
      for (final field in section.fields) {
        ids.add(field.id);
      }
    }
    
    return ids;
  }
}
