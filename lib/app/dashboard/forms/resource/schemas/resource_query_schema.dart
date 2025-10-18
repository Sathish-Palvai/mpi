import 'package:flutter/material.dart';
import '../../../../../core/forms/forms.dart';
import '../../../../../l10n/app_localizations.dart';

/// Resource query form schema definition
/// 
/// This class defines the form structure for resource query operations.
/// It allows users to search for resource data by participant name, resource name, date, and record status.
class ResourceQuerySchema {
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
            minLength: 4,
            maxLength: 4,
            placeholder: 'Select participant',
            selectOptions: [], // Will be populated dynamically
          ),
          FormFieldConfig(
            id: 'resourceName',
            label: 'Resource Name',
            type: FieldType.select,
            flex: 1,
            required: true,
            minLength: 1,
            maxLength: 10,
            placeholder: 'Select resource',
            selectOptions: [], // Will be populated dynamically
          ),
        ],
      ),
      FormSectionConfig(
        fields: [
          FormFieldConfig(
            id: 'date',
            label: 'Date',
            type: FieldType.date,
            flex: 1,
            required: false,
            minLength: 10,
            maxLength: 10,
            placeholder: 'YYYY-MM-DD',
          ),
          FormFieldConfig(
            id: 'recordStatus',
            label: 'Record Status',
            type: FieldType.select,
            flex: 1,
            required: false,
            placeholder: 'Select status',
            selectOptions: [
              'Active',
              'Inactive',
              'Pending',
              'Suspended',
            ],
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
