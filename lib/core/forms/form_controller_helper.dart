import 'package:flutter/material.dart';
import 'form_field_config.dart';

/// Helper class for managing form controllers
class FormControllerHelper {
  /// Initialize controllers from form sections
  static Map<String, TextEditingController> initializeControllers(
    List<FormSectionConfig> sections,
    Map<String, dynamic>? initialData,
  ) {
    final controllers = <String, TextEditingController>{};

    for (final section in sections) {
      for (final field in section.fields) {
        final initialValue = initialData?[field.id]?.toString() ??
            field.initialValue ??
            '';
        controllers[field.id] = TextEditingController(text: initialValue);
      }
    }

    return controllers;
  }

  /// Dispose all controllers
  static void disposeControllers(Map<String, TextEditingController> controllers) {
    for (final controller in controllers.values) {
      controller.dispose();
    }
  }

  /// Get form data from controllers
  static Map<String, dynamic> getFormData(
    Map<String, TextEditingController> controllers,
  ) {
    final data = <String, dynamic>{};
    
    for (final entry in controllers.entries) {
      data[entry.key] = entry.value.text;
    }
    
    return data;
  }

  /// Get form data with type conversion
  static Map<String, dynamic> getFormDataWithTypes(
    Map<String, TextEditingController> controllers,
    List<FormSectionConfig> sections,
  ) {
    final data = <String, dynamic>{};
    final fieldConfigs = <String, FormFieldConfig>{};

    // Build field config lookup
    for (final section in sections) {
      for (final field in section.fields) {
        fieldConfigs[field.id] = field;
      }
    }

    // Convert values based on field type
    for (final entry in controllers.entries) {
      final fieldId = entry.key;
      final controller = entry.value;
      final config = fieldConfigs[fieldId];

      if (config == null) {
        data[fieldId] = controller.text;
        continue;
      }

      switch (config.type) {
        case FieldType.number:
          data[fieldId] = num.tryParse(controller.text);
          break;
        case FieldType.checkbox:
          data[fieldId] = controller.text == '1' || controller.text == 'true';
          break;
        case FieldType.date:
          data[fieldId] = controller.text.isEmpty ? null : controller.text;
          break;
        default:
          data[fieldId] = controller.text;
      }
    }

    return data;
  }

  /// Reset all controllers
  static void resetControllers(
    Map<String, TextEditingController> controllers,
  ) {
    for (final controller in controllers.values) {
      controller.clear();
    }
  }

  /// Update controllers with new data
  static void updateControllers(
    Map<String, TextEditingController> controllers,
    Map<String, dynamic> data,
  ) {
    for (final entry in data.entries) {
      if (controllers.containsKey(entry.key)) {
        controllers[entry.key]!.text = entry.value?.toString() ?? '';
      }
    }
  }

  /// Validate all fields
  static bool validateForm(GlobalKey<FormState> formKey) {
    return formKey.currentState?.validate() ?? false;
  }

  /// Get all visible field IDs
  static List<String> getVisibleFieldIds(List<FormSectionConfig> sections) {
    final ids = <String>[];
    
    for (final section in sections) {
      for (final field in section.fields) {
        if (field.visible) {
          ids.add(field.id);
        }
      }
    }
    
    return ids;
  }

  /// Get all required field IDs
  static List<String> getRequiredFieldIds(List<FormSectionConfig> sections) {
    final ids = <String>[];
    
    for (final section in sections) {
      for (final field in section.fields) {
        if (field.required && field.visible) {
          ids.add(field.id);
        }
      }
    }
    
    return ids;
  }

  /// Check if form has unsaved changes
  static bool hasUnsavedChanges(
    Map<String, TextEditingController> controllers,
    Map<String, dynamic>? originalData,
  ) {
    if (originalData == null) return false;

    for (final entry in controllers.entries) {
      final originalValue = originalData[entry.key]?.toString() ?? '';
      final currentValue = entry.value.text;
      
      if (originalValue != currentValue) {
        return true;
      }
    }

    return false;
  }
}
