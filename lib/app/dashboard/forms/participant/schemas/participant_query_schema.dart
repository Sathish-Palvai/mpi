import 'package:flutter/material.dart';
import '../../../../../core/forms/forms.dart';
import '../../../../../l10n/app_localizations.dart';

/// Participant query form schema definition
/// 
/// This class defines the form structure for participant query operations.
/// It allows users to search for participant data by name and trade date.
class ParticipantQuerySchema {
  /// Get form configuration for query fields
  static List<FormSectionConfig> getQuerySections(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return [
      FormSectionConfig(
        fields: [
          FormFieldConfig(
            id: 'participantName',
            label: l10n.participantNameLabel,
            type: FieldType.select,
            flex: 1,
            required: true,
            placeholder: 'Select participant to query',
            selectOptions: [], // Will be populated dynamically
          ),
        ],
      ),
      FormSectionConfig(
        fields: [
          FormFieldConfig(
            id: 'tradeDate',
            label: l10n.tradeDateLabel,
            type: FieldType.date,
            flex: 1,
            required: false,
            minLength: 10,
            maxLength: 10,
            placeholder: 'YYYY-MM-DD (optional)',
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
