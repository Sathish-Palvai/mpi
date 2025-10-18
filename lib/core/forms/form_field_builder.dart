import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'form_field_config.dart';

/// Reusable form field builder that creates widgets from configuration
class FormFieldBuilder {
  /// Spacing between fields
  static const double fieldSpacing = 18.0;
  
  /// Label font size delta (relative to theme)
  static const double labelFontDelta = 3.0;

  /// Build a form field widget from configuration
  static Widget buildField({
    required BuildContext context,
    required FormFieldConfig config,
    required TextEditingController controller,
    Map<String, TextEditingController>? allControllers,
    VoidCallback? onDateTap,
  }) {
    if (!config.visible) {
      return const SizedBox.shrink();
    }

    switch (config.type) {
      case FieldType.text:
      case FieldType.number:
      case FieldType.email:
      case FieldType.url:
      case FieldType.phone:
        return _buildTextField(context, config, controller);
        
      case FieldType.multiline:
        return _buildMultilineField(context, config, controller);
        
      case FieldType.date:
        return _buildDateField(context, config, controller, onDateTap);
        
      case FieldType.select:
        return _buildSelectField(context, config, controller, allControllers);
        
      case FieldType.checkbox:
        return _buildCheckboxField(context, config, controller);
        
      case FieldType.radio:
        return _buildRadioField(context, config, controller);
    }
  }

  /// Build a standard text field
  static Widget _buildTextField(
    BuildContext context,
    FormFieldConfig config,
    TextEditingController controller,
  ) {
    return TextFormField(
      controller: controller,
      enabled: !config.readonly,
      autofocus: config.autofocus,
      obscureText: config.obscureText,
      decoration: _buildInputDecoration(context, config),
      validator: buildValidator(config),
      keyboardType: config.keyboardType ?? _getKeyboardType(config.type),
      maxLength: config.maxLength,
      inputFormatters: _buildInputFormatters(config),
      style: Theme.of(context).textTheme.bodyLarge,
    );
  }

  /// Build a multiline text field
  static Widget _buildMultilineField(
    BuildContext context,
    FormFieldConfig config,
    TextEditingController controller,
  ) {
    return TextFormField(
      controller: controller,
      enabled: !config.readonly,
      decoration: _buildInputDecoration(context, config),
      validator: buildValidator(config),
      maxLines: config.maxLines ?? 3,
      maxLength: config.maxLength,
      style: Theme.of(context).textTheme.bodyLarge,
    );
  }

  /// Build a date picker field
  static Widget _buildDateField(
    BuildContext context,
    FormFieldConfig config,
    TextEditingController controller,
    VoidCallback? onDateTap,
  ) {
    return TextFormField(
      controller: controller,
      enabled: !config.readonly,
      decoration: _buildInputDecoration(context, config).copyWith(
        suffixIcon: const Icon(Icons.calendar_today),
      ),
      validator: buildValidator(config),
      maxLength: config.maxLength,
      readOnly: true,
      onTap: config.readonly ? null : onDateTap,
      style: Theme.of(context).textTheme.bodyLarge,
    );
  }

  /// Build a select/dropdown field
  static Widget _buildSelectField(
    BuildContext context,
    FormFieldConfig config,
    TextEditingController controller,
    Map<String, TextEditingController>? allControllers,
  ) {
    // If dynamic field, wrap in ValueListenableBuilder to rebuild when dependencies change
    if (config.isDynamic && config.dependsOn != null && allControllers != null) {
      // Get the dependent controllers
      final dependentControllers = config.dependsOn!
          .map((fieldId) => allControllers[fieldId])
          .where((c) => c != null)
          .cast<TextEditingController>()
          .toList();
      
      if (dependentControllers.isNotEmpty) {
        // Listen to the first dependent field (in this case, Area)
        return ValueListenableBuilder<TextEditingValue>(
          valueListenable: dependentControllers.first,
          builder: (context, value, child) {
            return _buildSelectFieldInternal(context, config, controller, allControllers);
          },
        );
      }
    }
    
    // Non-dynamic or no dependencies
    return _buildSelectFieldInternal(context, config, controller, allControllers);
  }

  static Widget _buildSelectFieldInternal(
    BuildContext context,
    FormFieldConfig config,
    TextEditingController controller,
    Map<String, TextEditingController>? allControllers,
  ) {
    // Get dynamic options if field is dynamic
    Map<String, String>? optionsMap = config.selectOptionsMap;
    
    if (config.isDynamic && config.dynamicOptionsBuilder != null && allControllers != null) {
      // Get values of dependent fields
      final dependentValues = <String, String>{};
      if (config.dependsOn != null) {
        for (final fieldId in config.dependsOn!) {
          final dependentController = allControllers[fieldId];
          if (dependentController != null) {
            dependentValues[fieldId] = dependentController.text;
          }
        }
      }
      
      // Build dynamic options
      final dynamicOptions = config.dynamicOptionsBuilder!(dependentValues);
      if (dynamicOptions != null) {
        optionsMap = dynamicOptions;
      }
    }
    
    // Use selectOptionsMap if available, otherwise fall back to selectOptions
    final List<DropdownMenuItem<String>>? items;
    final Set<String> validValues = {};
    
    if (optionsMap != null) {
      items = optionsMap.entries.map((entry) {
        validValues.add(entry.value);
        return DropdownMenuItem(
          value: entry.value,
          child: Text(entry.key),
        );
      }).toList();
    } else if (config.selectOptions != null) {
      items = config.selectOptions!.map((option) {
        validValues.add(option);
        return DropdownMenuItem(
          value: option,
          child: Text(option),
        );
      }).toList();
    } else {
      items = null;
    }
    
    // Validate that the current value exists in the dropdown options
    String? currentValue;
    if (controller.text.isNotEmpty) {
      if (validValues.contains(controller.text)) {
        currentValue = controller.text;
      } else {
        // Value doesn't exist in options, clear it immediately
        debugPrint('⚠️ Clearing invalid dropdown value - Field: "${config.id}", Old value: "${controller.text}", Valid options: $validValues');
        controller.clear();
        currentValue = null;
      }
    }
    
    return DropdownButtonFormField<String>(
      key: ValueKey('${config.id}_${validValues.join("_")}'), // Force rebuild when options change
      value: currentValue,
      decoration: _buildInputDecoration(context, config),
      validator: buildValidator(config),
      items: items,
      onChanged: config.readonly
          ? null
          : (value) {
              if (value != null) {
                controller.text = value;
              }
            },
      style: Theme.of(context).textTheme.bodyLarge,
    );
  }

  /// Build a checkbox field
  static Widget _buildCheckboxField(
    BuildContext context,
    FormFieldConfig config,
    TextEditingController controller,
  ) {
    return FormField<bool>(
      initialValue: controller.text == 'true' || controller.text == '1',
      validator: (value) {
        if (config.required && value != true) {
          return '${config.displayLabel} is required';
        }
        return null;
      },
      builder: (FormFieldState<bool> field) {
        return CheckboxListTile(
          title: Text(
            config.displayLabel,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontSize: (Theme.of(context).textTheme.bodyLarge?.fontSize ?? 14) +
                  labelFontDelta,
            ),
          ),
          value: field.value ?? false,
          onChanged: config.readonly
              ? null
              : (bool? value) {
                  field.didChange(value);
                  controller.text = value == true ? '1' : '0';
                },
          controlAffinity: ListTileControlAffinity.leading,
          enabled: !config.readonly,
          subtitle: field.hasError
              ? Text(
                  field.errorText ?? '',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                )
              : null,
        );
      },
    );
  }

  /// Build a radio field
  static Widget _buildRadioField(
    BuildContext context,
    FormFieldConfig config,
    TextEditingController controller,
  ) {
    // Validate that the current value exists in the radio options
    final Set<String> validValues = {};
    if (config.selectOptionsMap != null) {
      validValues.addAll(config.selectOptionsMap!.values);
    } else if (config.selectOptions != null) {
      validValues.addAll(config.selectOptions!);
    }
    
    String? initialValue = controller.text.isEmpty ? null : controller.text;
    if (initialValue != null && !validValues.contains(initialValue)) {
      debugPrint('⚠️ Radio field ${config.id}: value "$initialValue" not in options $validValues');
      controller.text = '';
      initialValue = null;
    }
    
    return FormField<String>(
      initialValue: initialValue,
      validator: buildValidator(config),
      builder: (FormFieldState<String> field) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (config.showLabel)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  '${config.displayLabel}${config.required ? ' *' : ''}',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontSize:
                        (Theme.of(context).textTheme.bodyLarge?.fontSize ?? 14) +
                            labelFontDelta,
                  ),
                ),
              ),
            // Use selectOptionsMap if available, otherwise fall back to selectOptions
            ...?(config.selectOptionsMap != null
                ? config.selectOptionsMap!.entries.map((entry) {
                    return RadioListTile<String>(
                      title: Text(entry.key),
                      value: entry.value,
                      groupValue: field.value,
                      onChanged: config.readonly
                          ? null
                          : (String? value) {
                              field.didChange(value);
                              if (value != null) {
                                controller.text = value;
                              }
                            },
                    );
                  })
                : config.selectOptions?.map((option) {
                    return RadioListTile<String>(
                      title: Text(option),
                      value: option,
                      groupValue: field.value,
                      onChanged: config.readonly
                          ? null
                          : (String? value) {
                              field.didChange(value);
                              if (value != null) {
                                controller.text = value;
                              }
                            },
                    );
                  })),
            if (field.hasError)
              Padding(
                padding: const EdgeInsets.only(top: 8.0, left: 12.0),
                child: Text(
                  field.errorText ?? '',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  /// Build input decoration with theme awareness
  static InputDecoration _buildInputDecoration(
    BuildContext context,
    FormFieldConfig config,
  ) {
    final theme = Theme.of(context);
    final baseFontSize = theme.textTheme.bodyLarge?.fontSize ?? 14.0;

    return InputDecoration(
      labelText: config.showLabel
          ? '${config.displayLabel}${config.required ? ' *' : ''}'
          : null,
      labelStyle: theme.textTheme.bodyLarge?.copyWith(
        fontSize: baseFontSize + labelFontDelta,
        fontStyle: config.readonly ? FontStyle.italic : FontStyle.normal,
        color: config.readonly ? theme.textTheme.bodyMedium?.color?.withOpacity(0.7) : null,
      ),
      hintText: config.placeholder,
      hintStyle: config.readonly 
          ? TextStyle(fontStyle: FontStyle.italic, color: theme.hintColor.withOpacity(0.5))
          : null,
      helperText: config.helperText,
      prefixIcon: config.prefixIcon != null ? Icon(config.prefixIcon) : null,
      suffixIcon: config.suffixIcon != null ? Icon(config.suffixIcon) : null,
      border: const OutlineInputBorder(),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: theme.dividerColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: theme.colorScheme.error),
      ),
      filled: config.readonly,
      fillColor: config.readonly ? theme.colorScheme.surfaceContainerHighest.withOpacity(0.3) : null,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
    );
  }

  /// Build validator function from configuration
  static String? Function(String?)? buildValidator(FormFieldConfig config) {
    return (String? value) {
      // Custom validator takes precedence
      if (config.customValidator != null) {
        final customError = config.customValidator!(value);
        if (customError != null) return customError;
      }

      // Required validation
      if (config.required && (value == null || value.trim().isEmpty)) {
        return '${config.displayLabel} is required';
      }

      // Skip other validations if empty and not required
      if (value == null || value.isEmpty) {
        return null;
      }

      // Min length validation
      if (config.minLength != null && value.length < config.minLength!) {
        return '${config.displayLabel} must be at least ${config.minLength} characters';
      }

      // Max length validation
      if (config.maxLength != null && value.length > config.maxLength!) {
        return '${config.displayLabel} must not exceed ${config.maxLength} characters';
      }

      // Pattern validation
      if (config.pattern != null && !config.pattern!.hasMatch(value)) {
        return config.patternMessage ??
            '${config.displayLabel} format is invalid';
      }

      // Number validation
      if (config.type == FieldType.number) {
        final numValue = num.tryParse(value);
        if (numValue == null) {
          return '${config.displayLabel} must be a valid number';
        }
        if (config.minValue != null && numValue < config.minValue!) {
          return '${config.displayLabel} must be at least ${config.minValue}';
        }
        if (config.maxValue != null && numValue > config.maxValue!) {
          return '${config.displayLabel} must not exceed ${config.maxValue}';
        }
      }

      // Email validation
      if (config.type == FieldType.email) {
        final emailRegex = RegExp(
          r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
        );
        if (!emailRegex.hasMatch(value)) {
          return '${config.displayLabel} must be a valid email address';
        }
      }

      // URL validation
      if (config.type == FieldType.url) {
        final urlRegex = RegExp(
          r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
        );
        if (!urlRegex.hasMatch(value)) {
          return '${config.displayLabel} must be a valid URL';
        }
      }

      return null;
    };
  }

  /// Get keyboard type based on field type
  static TextInputType _getKeyboardType(FieldType type) {
    switch (type) {
      case FieldType.number:
      case FieldType.phone:
        return TextInputType.number;
      case FieldType.email:
        return TextInputType.emailAddress;
      case FieldType.url:
        return TextInputType.url;
      case FieldType.multiline:
        return TextInputType.multiline;
      default:
        return TextInputType.text;
    }
  }

  /// Build input formatters based on field type
  static List<TextInputFormatter>? _buildInputFormatters(FormFieldConfig config) {
    final formatters = <TextInputFormatter>[];

    // Max length formatter
    if (config.maxLength != null) {
      formatters.add(LengthLimitingTextInputFormatter(config.maxLength));
    }

    // Number-only formatter
    if (config.type == FieldType.number || config.type == FieldType.phone) {
      formatters.add(FilteringTextInputFormatter.digitsOnly);
    }

    return formatters.isEmpty ? null : formatters;
  }

  /// Build a field row with responsive layout
  static Widget buildFieldRow({
    required BuildContext context,
    required List<FormFieldConfig> fields,
    required Map<String, TextEditingController> controllers,
    required Function(String fieldId) onDateFieldTap,
  }) {
    // Filter out invisible fields before building the layout
    final visibleFields = fields.where((field) => field.visible).toList();
    
    if (visibleFields.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;

        if (isMobile) {
          // Stack vertically on mobile
          return Column(
            children: visibleFields.map((field) {
              return Padding(
                padding: const EdgeInsets.only(bottom: fieldSpacing),
                child: buildField(
                  context: context,
                  config: field,
                  controller: controllers[field.id]!,
                  allControllers: controllers,
                  onDateTap: field.type == FieldType.date
                      ? () => onDateFieldTap(field.id)
                      : null,
                ),
              );
            }).toList(),
          );
        } else {
          // Use flex layout on desktop
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < visibleFields.length; i++) ...[
                Expanded(
                  flex: visibleFields[i].flex,
                  child: buildField(
                    context: context,
                    config: visibleFields[i],
                    controller: controllers[visibleFields[i].id]!,
                    allControllers: controllers,
                    onDateTap: visibleFields[i].type == FieldType.date
                        ? () => onDateFieldTap(visibleFields[i].id)
                        : null,
                  ),
                ),
                if (i < visibleFields.length - 1) const SizedBox(width: fieldSpacing),
              ],
            ],
          );
        }
      },
    );
  }

  /// Build a section with optional title
  static Widget buildSection({
    required BuildContext context,
    required FormSectionConfig section,
    required Map<String, TextEditingController> controllers,
    required Function(String fieldId) onDateFieldTap,
  }) {
    // Check if title is not null and not empty
    final hasTitle = section.title != null && section.title!.trim().isNotEmpty;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hasTitle) ...[
          Text(
            section.title!,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          if (section.description != null)
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                section.description!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ),
          const SizedBox(height: 16),
        ],
        buildFieldRow(
          context: context,
          fields: section.fields,
          controllers: controllers,
          onDateFieldTap: onDateFieldTap,
        ),
        const SizedBox(height: fieldSpacing),
        // Add divider after section if specified
        if (section.showDividerAfter) ...[
          const Divider(
            color: Color(0xFFE0E0E0),
            thickness: 1,
            height: 1,
          ),
          const SizedBox(height: fieldSpacing),
        ],
      ],
    );
  }

  /// Show date picker and update controller
  static Future<void> pickDate({
    required BuildContext context,
    required TextEditingController controller,
    DateTime? initialDate,
    DateTime? firstDate,
    DateTime? lastDate,
  }) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: firstDate ?? DateTime(1900),
      lastDate: lastDate ?? DateTime(2100),
    );

    if (picked != null) {
      controller.text = DateFormat('yyyy-MM-dd').format(picked);
    }
  }
}
