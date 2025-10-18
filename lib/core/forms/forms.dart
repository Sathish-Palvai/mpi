/// Config-Driven Forms Library
/// 
/// A reusable, declarative form building system for Flutter applications.
/// Define forms using configuration objects and let the library handle
/// the widget building, validation, and controller management.
/// 
/// ## Features
/// - Declarative form configuration
/// - Automatic controller management
/// - Built-in validation
/// - Responsive layouts
/// - Type-safe field definitions
/// - Theme-aware styling
/// 
/// ## Usage
/// ```dart
/// import 'package:mpi/core/forms/forms.dart';
/// 
/// // Define your form schema
/// final sections = [
///   FormSectionConfig(
///     title: 'Personal Information',
///     fields: [
///       FormFieldConfig(
///         id: 'name',
///         label: 'Full Name',
///         type: FieldType.text,
///         required: true,
///       ),
///       FormFieldConfig(
///         id: 'email',
///         label: 'Email',
///         type: FieldType.email,
///         required: true,
///       ),
///     ],
///   ),
/// ];
/// 
/// // Initialize controllers
/// final controllers = FormControllerHelper.initializeControllers(sections, initialData);
/// 
/// // Build form UI
/// FormFieldBuilder.buildSection(
///   context: context,
///   section: sections[0],
///   controllers: controllers,
///   onDateFieldTap: (fieldId) => _pickDate(fieldId),
/// );
/// ```
library forms;

export 'form_field_config.dart';
export 'form_field_builder.dart';
export 'form_controller_helper.dart';
export 'response_messages_card.dart';
