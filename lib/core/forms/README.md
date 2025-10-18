# Config-Driven Forms Library

## 📚 Library Structure

The config-driven forms system has been refactored into a reusable library that can be used across multiple screens in your application.

```
lib/
├── core/
│   └── forms/                          # ✨ Reusable Forms Library
│       ├── forms.dart                  # Main export file
│       ├── form_field_config.dart      # Configuration models
│       ├── form_field_builder.dart     # Widget builders
│       ├── form_controller_helper.dart # Controller management
│       └── response_messages_card.dart # Response messages component
│
└── app/
    └── dashboard/
        └── config_driven_forms/
            ├── schemas/
            │   └── participant_form_schema.dart  # Participant-specific schema
            ├── config_driven_participant_screen_v2.dart  # New refactored screen
            └── config_driven_participant_screen.dart     # Original (for reference)
```

---

## 🎯 Core Library Components

### 1. **form_field_config.dart**
Defines the configuration models:
- `FieldType` enum - All supported field types
- `FormFieldConfig` - Individual field configuration
- `FormSectionConfig` - Section/group configuration

### 2. **form_field_builder.dart**
Provides widget building utilities:
- `FormFieldBuilder.buildField()` - Build individual fields
- `FormFieldBuilder.buildFieldRow()` - Build responsive field rows
- `FormFieldBuilder.buildSection()` - Build complete sections
- `FormFieldBuilder.buildValidator()` - Generate validators from config
- `FormFieldBuilder.pickDate()` - Date picker helper

### 3. **form_controller_helper.dart**
Manages form state:
- `initializeControllers()` - Create controllers from schema
- `disposeControllers()` - Clean up controllers
- `getFormData()` - Extract data from controllers
- `getFormDataWithTypes()` - Extract with type conversion
- `validateForm()` - Validate entire form
- `hasUnsavedChanges()` - Check for modifications

### 4. **response_messages_card.dart**
Reusable component for displaying API response messages:
- `ResponseMessagesCard` widget - Display messages and statistics
- `ResponseMessage` model - Message data structure
- `ProcessingStatistics` model - Statistics data structure
- Static helper methods for data extraction
- [Full Documentation](RESPONSE_MESSAGES_COMPONENT.md)

---

## 🚀 Quick Start

### Step 1: Import the Library

```dart
import 'package:mpi/core/forms/forms.dart';
```

### Step 2: Define Your Form Schema

Create a schema file (e.g., `my_form_schema.dart`):

```dart
import 'package:flutter/material.dart';
import 'package:mpi/core/forms/forms.dart';

class MyFormSchema {
  static List<FormSectionConfig> getSections() {
    return [
      FormSectionConfig(
        title: 'Personal Information',
        fields: [
          FormFieldConfig(
            id: 'firstName',
            label: 'First Name',
            type: FieldType.text,
            required: true,
            minLength: 2,
            maxLength: 50,
          ),
          FormFieldConfig(
            id: 'email',
            label: 'Email Address',
            type: FieldType.email,
            required: true,
          ),
        ],
      ),
    ];
  }
}
```

### Step 3: Use in Your Screen

```dart
import 'package:flutter/material.dart' hide FormFieldBuilder;
import 'package:mpi/core/forms/forms.dart';
import 'my_form_schema.dart';

class MyFormScreen extends StatefulWidget {
  final Map<String, dynamic>? initialData;

  const MyFormScreen({super.key, this.initialData});

  @override
  State<MyFormScreen> createState() => _MyFormScreenState();
}

class _MyFormScreenState extends State<MyFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final Map<String, TextEditingController> _controllers;
  late final List<FormSectionConfig> _sections;

  @override
  void initState() {
    super.initState();
    _sections = MyFormSchema.getSections();
    _controllers = FormControllerHelper.initializeControllers(
      _sections,
      widget.initialData,
    );
  }

  @override
  void dispose() {
    FormControllerHelper.disposeControllers(_controllers);
    super.dispose();
  }

  void _pickDate(String fieldId) async {
    await FormFieldBuilder.pickDate(
      context: context,
      controller: _controllers[fieldId]!,
    );
  }

  void _save() {
    if (FormControllerHelper.validateForm(_formKey)) {
      final data = FormControllerHelper.getFormData(_controllers);
      // Save data...
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Form')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            ..._sections.map((section) {
              return FormFieldBuilder.buildSection(
                context: context,
                section: section,
                controllers: _controllers,
                onDateFieldTap: _pickDate,
              );
            }),
            ElevatedButton(
              onPressed: _save,
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
```

### Step 3b: Add Response Messages (Optional)

To display API response messages and statistics:

```dart
import 'package:flutter/material.dart' hide FormFieldBuilder;
import 'package:mpi/core/forms/forms.dart';

class _MyFormScreenState extends State<MyFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late Map<String, TextEditingController> _controllers;
  late List<FormSectionConfig> _sections;
  
  // Add these for response handling
  Map<String, dynamic>? _submissionResponse;
  bool _showResponse = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _sections = MyFormSchema.getSections();
    _controllers = FormControllerHelper.initializeControllers(_sections, {});
  }

  @override
  void dispose() {
    FormControllerHelper.disposeControllers(_controllers);
    super.dispose();
  }

  Future<void> _save() async {
    if (!FormControllerHelper.validateForm(_formKey)) return;
    
    setState(() => _isSubmitting = true);
    
    try {
      final data = FormControllerHelper.getFormData(_controllers);
      final response = await ApiService.submit(data);
      
      setState(() {
        _submissionResponse = response;
        _showResponse = true;
        _isSubmitting = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Saved successfully!')),
      );
    } catch (e) {
      setState(() {
        _submissionResponse = {
          'RegistrationData': {
            'RegistrationSubmit': {
              'Messages': {'Error': {'#text': 'Failed: $e'}},
            },
          },
        };
        _showResponse = true;
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Form')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            // Display response messages
            ResponseMessagesCard(
              response: _submissionResponse,
              visible: _showResponse,
              title: 'Submission Result',
            ),
            if (_showResponse) const SizedBox(height: 24),
            
            // Build form sections
            ..._sections.map((section) {
              return FormFieldBuilder.buildSection(
                context: context,
                section: section,
                controllers: _controllers,
                onDateFieldTap: _pickDate,
              );
            }),
            
            // Submit button
            ElevatedButton(
              onPressed: _isSubmitting ? null : _save,
              child: _isSubmitting 
                  ? CircularProgressIndicator() 
                  : Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _pickDate(String fieldId) async {
    await FormFieldBuilder.pickDate(
      context: context,
      controller: _controllers[fieldId]!,
    );
  }
}
```

For complete ResponseMessagesCard documentation, see [RESPONSE_MESSAGES_COMPONENT.md](RESPONSE_MESSAGES_COMPONENT.md).

---

## 📋 Supported Field Types

```dart
enum FieldType {
  text,       // Standard text input
  number,     // Numeric input (digits only)
  date,       // Date picker
  select,     // Dropdown selection
  multiline,  // Multi-line text area
  phone,      // Phone number input
  checkbox,   // Checkbox (true/false)
  radio,      // Radio button group
  email,      // Email input with validation
  url,        // URL input with validation
}
```

---

## 🎨 Field Configuration Options

```dart
FormFieldConfig(
  // Required
  id: 'fieldId',              // Unique identifier
  label: 'Field Label',       // Display label
  
  // Type & Layout
  type: FieldType.text,       // Field type (default: text)
  flex: 1,                    // Responsive flex ratio (default: 1)
  
  // Validation
  required: true,             // Is field required? (default: true)
  minLength: 2,               // Minimum length
  maxLength: 50,              // Maximum length
  pattern: RegExp(r'^\d+$'),  // Validation pattern
  patternMessage: 'Error msg', // Pattern error message
  customValidator: (value) => null, // Custom validation function
  
  // Number-specific
  minValue: 0,                // Minimum numeric value
  maxValue: 100,              // Maximum numeric value
  
  // Behavior
  readonly: false,            // Is field read-only?
  visible: true,              // Is field visible?
  autofocus: false,           // Auto-focus on load?
  obscureText: false,         // Hide text (passwords)?
  
  // Options (for select/radio)
  selectOptions: ['A', 'B'],  // Dropdown/radio options
  
  // Display
  showLabel: true,            // Show label?
  alias: 'Custom Label',      // Override label text
  placeholder: 'Hint text',   // Placeholder text
  helperText: 'Help text',    // Help text below field
  initialValue: 'default',    // Initial value
  
  // Icons
  prefixIcon: Icons.person,   // Leading icon
  suffixIcon: Icons.check,    // Trailing icon
  
  // Keyboard
  keyboardType: TextInputType.phone, // Keyboard type
  maxLines: 3,                // Lines (for multiline)
)
```

---

## 🔧 Helper Methods

### FormControllerHelper

```dart
// Initialize
final controllers = FormControllerHelper.initializeControllers(
  sections,
  initialData,
);

// Get data
final data = FormControllerHelper.getFormData(controllers);

// Get data with type conversion
final typedData = FormControllerHelper.getFormDataWithTypes(
  controllers,
  sections,
);

// Validate
final isValid = FormControllerHelper.validateForm(formKey);

// Check changes
final hasChanges = FormControllerHelper.hasUnsavedChanges(
  controllers,
  originalData,
);

// Update values
FormControllerHelper.updateControllers(controllers, newData);

// Reset
FormControllerHelper.resetControllers(controllers);

// Dispose
FormControllerHelper.disposeControllers(controllers);
```

### FormFieldBuilder

```dart
// Build single field
FormFieldBuilder.buildField(
  context: context,
  config: fieldConfig,
  controller: controller,
  onDateTap: () => _pickDate(),
);

// Build field row (responsive)
FormFieldBuilder.buildFieldRow(
  context: context,
  fields: [field1, field2],
  controllers: controllers,
  onDateFieldTap: (fieldId) => _pickDate(fieldId),
);

// Build section
FormFieldBuilder.buildSection(
  context: context,
  section: sectionConfig,
  controllers: controllers,
  onDateFieldTap: (fieldId) => _pickDate(fieldId),
);

// Pick date
await FormFieldBuilder.pickDate(
  context: context,
  controller: controller,
  initialDate: DateTime.now(),
  firstDate: DateTime(2000),
  lastDate: DateTime(2100),
);

// Build validator
final validator = FormFieldBuilder.buildValidator(fieldConfig);
```

---

## 💡 Best Practices

### 1. Separate Schema from UI
```dart
// ✅ Good: Schema in separate file
class UserFormSchema {
  static List<FormSectionConfig> getSections() { ... }
}

// ❌ Bad: Schema mixed with UI code
class UserScreen extends StatefulWidget {
  final sections = [FormSectionConfig(...)]; // Don't do this
}
```

### 2. Use Type Conversion When Needed
```dart
// For API calls with typed data
final data = FormControllerHelper.getFormDataWithTypes(
  controllers,
  sections,
);
// Returns: { 'age': 25, 'active': true, 'name': 'John' }

// For simple string data
final data = FormControllerHelper.getFormData(controllers);
// Returns: { 'age': '25', 'active': '1', 'name': 'John' }
```

### 3. Reuse Common Patterns
```dart
class CommonPatterns {
  static final emailPattern = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  static final phonePattern = RegExp(r'^\d{10}$');
  
  static FormFieldConfig emailField({
    required String id,
    String label = 'Email',
  }) {
    return FormFieldConfig(
      id: id,
      label: label,
      type: FieldType.email,
      pattern: emailPattern,
    );
  }
}
```

### 4. Handle Date Fields Properly
```dart
// Always provide onDateFieldTap callback
void _pickDate(String fieldId) async {
  await FormFieldBuilder.pickDate(
    context: context,
    controller: _controllers[fieldId]!,
  );
}

// Use in buildSection
FormFieldBuilder.buildSection(
  context: context,
  section: section,
  controllers: _controllers,
  onDateFieldTap: _pickDate, // Required for date fields
);
```

### 5. Remember to Import with Hide
```dart
// Avoid conflict with Flutter's FormFieldBuilder
import 'package:flutter/material.dart' hide FormFieldBuilder;
import 'package:mpi/core/forms/forms.dart';
```

---

## 🎯 Example: Creating a New Form

Let's create a resource form using the library:

### 1. Create Schema

```dart
// lib/app/dashboard/config_driven_forms/schemas/resource_form_schema.dart
import 'package:flutter/material.dart';
import '../../../../core/forms/forms.dart';

class ResourceFormSchema {
  static List<FormSectionConfig> getSections() {
    return [
      FormSectionConfig(
        title: 'Resource Information',
        fields: [
          FormFieldConfig(
            id: 'ResourceName',
            label: 'Resource Name',
            type: FieldType.text,
            required: true,
            minLength: 3,
            maxLength: 100,
          ),
          FormFieldConfig(
            id: 'RatedOutput',
            label: 'Rated Output (MW)',
            type: FieldType.number,
            required: true,
            minValue: 0,
            maxValue: 10000,
          ),
        ],
      ),
      FormSectionConfig(
        title: 'Technical Details',
        fields: [
          FormFieldConfig(
            id: 'ThermalType',
            label: 'Thermal Type',
            type: FieldType.select,
            selectOptions: ['COAL', 'GAS', 'NUCLEAR', 'HYDRO'],
            required: true,
          ),
          FormFieldConfig(
            id: 'BlackStart',
            label: 'Black Start Capability',
            type: FieldType.checkbox,
            required: false,
          ),
        ],
      ),
    ];
  }
}
```

### 2. Create Screen

```dart
// lib/app/dashboard/config_driven_forms/config_driven_resource_screen.dart
import 'package:flutter/material.dart' hide FormFieldBuilder;
import 'package:go_router/go_router.dart';
import '../../../core/forms/forms.dart';
import 'schemas/resource_form_schema.dart';

class ConfigDrivenResourceScreen extends StatefulWidget {
  final Map<String, dynamic>? resource;

  const ConfigDrivenResourceScreen({super.key, this.resource});

  @override
  State<ConfigDrivenResourceScreen> createState() => 
      _ConfigDrivenResourceScreenState();
}

class _ConfigDrivenResourceScreenState 
    extends State<ConfigDrivenResourceScreen> {
  final _formKey = GlobalKey<FormState>();
  late final Map<String, TextEditingController> _controllers;
  late final List<FormSectionConfig> _sections;

  @override
  void initState() {
    super.initState();
    _sections = ResourceFormSchema.getSections();
    _controllers = FormControllerHelper.initializeControllers(
      _sections,
      widget.resource,
    );
  }

  @override
  void dispose() {
    FormControllerHelper.disposeControllers(_controllers);
    super.dispose();
  }

  void _save() {
    if (FormControllerHelper.validateForm(_formKey)) {
      final data = FormControllerHelper.getFormDataWithTypes(
        _controllers,
        _sections,
      );
      debugPrint('Saving resource: $data');
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Resource Details')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            ..._sections.map((section) => FormFieldBuilder.buildSection(
              context: context,
              section: section,
              controllers: _controllers,
              onDateFieldTap: (_) {},
            )),
            ElevatedButton(
              onPressed: _save,
              child: const Text('Save Resource'),
            ),
          ],
        ),
      ),
    );
  }
}
```

### 3. Add Route

```dart
// In main.dart
GoRoute(
  path: '/resource-config',
  builder: (context, state) {
    final resourceData = state.extra as Map<String, dynamic>?;
    return ConfigDrivenResourceScreen(resource: resourceData);
  },
),
```

---

## ✨ Benefits of Library Approach

### Code Reusability
- ✅ One library, multiple forms
- ✅ Consistent behavior across app
- ✅ Easy to maintain and update

### Development Speed
- ✅ ~80% less boilerplate code
- ✅ Faster form creation
- ✅ No repetitive controller management

### Type Safety
- ✅ Compile-time field type checking
- ✅ IDE autocomplete support
- ✅ Catch errors early

### Consistency
- ✅ Uniform validation patterns
- ✅ Consistent UI/UX
- ✅ Centralized styling

---

## 📊 Comparison: Before vs After

### Before (Traditional Approach)
```dart
// ~1600 lines per form
// Controllers scattered everywhere
// Validation logic duplicated
// 5+ locations to update per field change
```

### After (Library Approach)
```dart
// ~150-200 lines per form
// Auto-managed controllers
// Declarative validation
// 1 location to update per field
```

**Result:** 80-90% code reduction! 🎉

---

## 🐛 Troubleshooting

### FormFieldBuilder conflict
```dart
// Error: FormFieldBuilder is ambiguous
import 'package:flutter/material.dart';

// Solution: Hide Flutter's FormFieldBuilder
import 'package:flutter/material.dart' hide FormFieldBuilder;
```

### Controllers not disposing
```dart
// Always dispose in screen's dispose method
@override
void dispose() {
  FormControllerHelper.disposeControllers(_controllers);
  super.dispose();
}
```

### Date picker not showing
```dart
// Make sure to provide onDateFieldTap callback
FormFieldBuilder.buildSection(
  // ...
  onDateFieldTap: (fieldId) => _pickDate(fieldId), // Required!
);
```

---

## 🎓 Next Steps

1. ✅ Library created in `lib/core/forms/`
2. ✅ Participant schema separated
3. ✅ New refactored screen created (v2)
4. ⏳ Create schemas for other entities
5. ⏳ Migrate existing forms gradually
6. ⏳ Add custom field types as needed
7. ⏳ Write unit tests for library

---

## 📚 Additional Resources

- **forms.dart** - Main library export
- **form_field_config.dart** - Configuration API
- **form_field_builder.dart** - Widget builders
- **form_controller_helper.dart** - State management
- **participant_form_schema.dart** - Example schema

---

**Happy form building!** 🚀
