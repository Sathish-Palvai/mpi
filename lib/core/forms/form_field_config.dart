import 'package:flutter/material.dart';

/// Field type enum for different input types
enum FieldType {
  text,
  number,
  date,
  select,
  multiline,
  phone,
  checkbox,
  radio,
  email,
  url,
}

/// Field configuration class for defining form fields declaratively
class FormFieldConfig {
  /// Unique identifier for the field (maps to data key)
  final String id;
  
  /// Display label for the field
  final String label;
  
  /// Type of input field
  final FieldType type;
  
  /// Flex value for responsive layout (like col-span in CSS grid)
  final int flex;
  
  /// Minimum length validation
  final int? minLength;
  
  /// Maximum length validation
  final int? maxLength;
  
  /// Whether the field is required
  final bool required;
  
  /// Whether the field is read-only
  final bool readonly;
  
  /// Whether the field is visible
  final bool visible;
  
  /// Placeholder text
  final String? placeholder;
  
  /// RegExp pattern for validation
  final RegExp? pattern;
  
  /// Error message for pattern validation
  final String? patternMessage;
  
  /// Options for select/dropdown fields (simple list)
  final List<String>? selectOptions;
  
  /// Options for select/dropdown fields with label-value pairs
  /// Map format: {'Display Label': 'value'}
  final Map<String, String>? selectOptionsMap;
  
  /// Initial value for the field
  final String? initialValue;
  
  /// Whether to show the label
  final bool showLabel;
  
  /// Custom label override
  final String? alias;
  
  /// Keyboard type for input
  final TextInputType? keyboardType;
  
  /// Helper text shown below the field
  final String? helperText;
  
  /// Suffix icon for the field
  final IconData? suffixIcon;
  
  /// Prefix icon for the field
  final IconData? prefixIcon;
  
  /// Custom validator function (for complex validation)
  final String? Function(String?)? customValidator;
  
  /// Minimum value (for number fields)
  final num? minValue;
  
  /// Maximum value (for number fields)
  final num? maxValue;
  
  /// Number of lines (for multiline fields)
  final int? maxLines;
  
  /// Enable autofocus
  final bool autofocus;
  
  /// Obscure text (for password fields)
  final bool obscureText;
  
  /// Whether this field has dynamic options based on other fields
  final bool isDynamic;
  
  /// List of field IDs this field depends on (for dynamic behavior)
  final List<String>? dependsOn;
  
  /// Function to build dynamic options based on dependent field values
  final Map<String, String>? Function(Map<String, String> values)? dynamicOptionsBuilder;

  const FormFieldConfig({
    required this.id,
    required this.label,
    this.type = FieldType.text,
    this.flex = 1,
    this.minLength,
    this.maxLength,
    this.required = true,
    this.readonly = false,
    this.visible = true,
    this.placeholder,
    this.pattern,
    this.patternMessage,
    this.selectOptions,
    this.selectOptionsMap,
    this.initialValue,
    this.showLabel = true,
    this.alias,
    this.keyboardType,
    this.helperText,
    this.suffixIcon,
    this.prefixIcon,
    this.customValidator,
    this.minValue,
    this.maxValue,
    this.maxLines,
    this.autofocus = false,
    this.obscureText = false,
    this.isDynamic = false,
    this.dependsOn,
    this.dynamicOptionsBuilder,
  });

  /// Create a copy with modified properties
  FormFieldConfig copyWith({
    String? id,
    String? label,
    FieldType? type,
    int? flex,
    int? minLength,
    int? maxLength,
    bool? required,
    bool? readonly,
    bool? visible,
    String? placeholder,
    RegExp? pattern,
    String? patternMessage,
    List<String>? selectOptions,
    Map<String, String>? selectOptionsMap,
    String? initialValue,
    bool? showLabel,
    String? alias,
    TextInputType? keyboardType,
    String? helperText,
    IconData? suffixIcon,
    IconData? prefixIcon,
    String? Function(String?)? customValidator,
    num? minValue,
    num? maxValue,
    int? maxLines,
    bool? autofocus,
    bool? obscureText,
    bool? isDynamic,
    List<String>? dependsOn,
    Map<String, String>? Function(Map<String, String> values)? dynamicOptionsBuilder,
  }) {
    return FormFieldConfig(
      id: id ?? this.id,
      label: label ?? this.label,
      type: type ?? this.type,
      flex: flex ?? this.flex,
      minLength: minLength ?? this.minLength,
      maxLength: maxLength ?? this.maxLength,
      required: required ?? this.required,
      readonly: readonly ?? this.readonly,
      visible: visible ?? this.visible,
      placeholder: placeholder ?? this.placeholder,
      pattern: pattern ?? this.pattern,
      patternMessage: patternMessage ?? this.patternMessage,
      selectOptions: selectOptions ?? this.selectOptions,
      selectOptionsMap: selectOptionsMap ?? this.selectOptionsMap,
      initialValue: initialValue ?? this.initialValue,
      showLabel: showLabel ?? this.showLabel,
      alias: alias ?? this.alias,
      keyboardType: keyboardType ?? this.keyboardType,
      helperText: helperText ?? this.helperText,
      suffixIcon: suffixIcon ?? this.suffixIcon,
      prefixIcon: prefixIcon ?? this.prefixIcon,
      customValidator: customValidator ?? this.customValidator,
      minValue: minValue ?? this.minValue,
      maxValue: maxValue ?? this.maxValue,
      maxLines: maxLines ?? this.maxLines,
      autofocus: autofocus ?? this.autofocus,
      obscureText: obscureText ?? this.obscureText,
      isDynamic: isDynamic ?? this.isDynamic,
      dependsOn: dependsOn ?? this.dependsOn,
      dynamicOptionsBuilder: dynamicOptionsBuilder ?? this.dynamicOptionsBuilder,
    );
  }

  /// Get the display label (alias if provided, otherwise label)
  String get displayLabel => alias ?? label;
}

/// Configuration for form sections (groups of fields)
class FormSectionConfig {
  /// List of fields in this section
  final List<FormFieldConfig> fields;
  
  /// Optional section title/header
  final String? title;
  
  /// Optional section description
  final String? description;
  
  /// Whether the section is collapsible
  final bool collapsible;
  
  /// Whether the section starts collapsed
  final bool initiallyCollapsed;
  
  /// Whether to show a divider after this section
  final bool showDividerAfter;

  const FormSectionConfig({
    required this.fields,
    this.title,
    this.description,
    this.collapsible = false,
    this.initiallyCollapsed = false,
    this.showDividerAfter = false,
  });
}
