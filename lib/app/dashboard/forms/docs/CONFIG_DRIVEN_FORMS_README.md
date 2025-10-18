# Config-Driven Form System for Flutter

## Overview

This is a complete config-driven form implementation for Flutter that allows you to define forms declaratively using configuration objects instead of manually building widgets.

## Architecture

### Core Components

1. **`FormFieldConfig`** - Defines a single form field
2. **`FormSectionConfig`** - Groups related fields into sections
3. **`ParticipantFormSchema`** - Contains the form schema definitions
4. **`ConfigDrivenParticipantScreen`** - The screen that renders the config-driven form

### Field Types

```dart
enum FieldType {
  text,       // Standard text input
  number,     // Numeric input with decimal support
  date,       // Date picker
  select,     // Dropdown selection
  multiline,  // Multi-line text area
  phone,      // Phone number input (digits only)
}
```

## Usage

### 1. Basic Field Configuration

```dart
FormFieldConfig(
  id: 'ParticipantName',           // Unique field identifier
  label: 'Participant Name',       // Display label
  type: FieldType.text,            // Field type
  flex: 2,                         // Column span (1-12)
  minLength: 4,                    // Minimum length
  maxLength: 4,                    // Maximum length
  required: true,                  // Is required?
  readonly: false,                 // Is read-only?
  visible: true,                   // Is visible?
  placeholder: 'Enter name',       // Placeholder text
  pattern: RegExp(r'^[A-Z0-9]{4}$'), // Validation pattern
  patternMessage: 'Invalid format', // Pattern error message
)
```

### 2. Section Configuration

```dart
FormSectionConfig(
  title: 'Basic Information',  // Optional section title
  fields: [
    FormFieldConfig(...),
    FormFieldConfig(...),
  ],
)
```

### 3. Complete Form Schema Example

```dart
class MyFormSchema {
  static List<FormSectionConfig> getFormSections() {
    return [
      FormSectionConfig(
        title: 'User Information',
        fields: [
          FormFieldConfig(
            id: 'firstName',
            label: 'First Name',
            flex: 2,
            required: true,
            maxLength: 50,
          ),
          FormFieldConfig(
            id: 'lastName',
            label: 'Last Name',
            flex: 2,
            required: true,
            maxLength: 50,
          ),
        ],
      ),
      FormSectionConfig(
        title: 'Contact Details',
        fields: [
          FormFieldConfig(
            id: 'email',
            label: 'Email',
            type: FieldType.text,
            keyboardType: TextInputType.emailAddress,
            required: true,
            pattern: RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$'),
            patternMessage: 'Invalid email format',
          ),
          FormFieldConfig(
            id: 'phone',
            label: 'Phone',
            type: FieldType.phone,
            maxLength: 10,
            required: true,
          ),
        ],
      ),
    ];
  }
}
```

### 4. Using in Your Screen

```dart
class MyScreen extends StatefulWidget {
  @override
  State<MyScreen> createState() => _MyScreenState();
}

class _MyScreenState extends State<MyScreen> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    for (var section in MyFormSchema.getFormSections()) {
      for (var field in section.fields) {
        _controllers[field.id] = TextEditingController();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: MyFormSchema.getFormSections()
            .map((section) => _buildSection(section))
            .toList(),
      ),
    );
  }

  Widget _buildSection(FormSectionConfig section) {
    // Use the builder methods from ConfigDrivenParticipantScreen
    // or create your own
  }
}
```

## Features

### ✅ Automatic Validation

- **Required fields** - Validates non-empty values
- **Min/Max length** - Character count validation
- **Pattern matching** - RegExp validation
- **Custom messages** - Field-specific error messages

### ✅ Responsive Layout

- **Mobile** (< 600px) - Fields stack vertically
- **Desktop** (≥ 600px) - Fields use Row with flex sizing
- **Flexible columns** - Use `flex` property for span control

### ✅ Multiple Field Types

- Text input (single line)
- Number input (with decimal support)
- Date picker
- Dropdown select
- Multi-line text area
- Phone number (digits only)

### ✅ Field Configuration Options

```dart
FormFieldConfig(
  // Core properties
  id: 'fieldId',              // Required: unique identifier
  label: 'Field Label',       // Required: display label
  type: FieldType.text,       // Default: text
  
  // Layout
  flex: 1,                    // Column span weight (1-12)
  
  // Validation
  required: true,             // Is required?
  minLength: 1,               // Minimum characters
  maxLength: 50,              // Maximum characters
  pattern: RegExp(r'...'),    // Validation pattern
  patternMessage: 'Error',    // Pattern error message
  
  // Behavior
  readonly: false,            // Is read-only?
  visible: true,              // Is visible?
  
  // UI customization
  placeholder: 'hint text',   // Placeholder text
  showLabel: true,            // Show label?
  alias: 'Custom Label',      // Override label
  
  // Input configuration
  keyboardType: TextInputType.text,
  selectOptions: ['A', 'B'],  // For select fields
  initialValue: 'default',    // Initial value
)
```

## Advantages Over Manual Widget Building

### 1. **DRY (Don't Repeat Yourself)**
```dart
// ❌ Manual approach - repeated code
TextFormField(
  controller: _field1Controller,
  decoration: InputDecoration(...),
  validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
  maxLength: 50,
)
TextFormField(
  controller: _field2Controller,
  decoration: InputDecoration(...),
  validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
  maxLength: 50,
)

// ✅ Config approach - reusable
FormFieldConfig(id: 'field1', label: 'Field 1', maxLength: 50)
FormFieldConfig(id: 'field2', label: 'Field 2', maxLength: 50)
```

### 2. **Easy Maintenance**
- Change validation rules in one place
- Update styling globally
- Add new field types without touching UI code

### 3. **Type Safety**
- Enum-based field types
- Compile-time checking
- IDE autocomplete support

### 4. **Testability**
```dart
test('should validate required fields', () {
  final config = FormFieldConfig(
    id: 'test',
    label: 'Test',
    required: true,
  );
  
  final validator = buildValidator(config);
  expect(validator(''), isNotNull); // Should fail
  expect(validator('value'), isNull); // Should pass
});
```

### 5. **Reusability**
- Use same config for create/edit forms
- Share field definitions across screens
- Build form variations from base config

### 6. **Dynamic Forms**
```dart
// Can be loaded from JSON, API, or database
final formConfig = await loadFormConfigFromAPI();
buildFormFromConfig(formConfig);
```

## Extending the System

### Add New Field Type

```dart
// 1. Add to enum
enum FieldType {
  // ... existing types
  checkbox,  // New type
}

// 2. Implement in _buildField method
case FieldType.checkbox:
  return CheckboxListTile(
    title: Text(displayLabel),
    value: controller.text == 'true',
    onChanged: config.readonly ? null : (value) {
      controller.text = value.toString();
    },
  );
```

### Add Custom Validator

```dart
FormFieldConfig(
  id: 'email',
  label: 'Email',
  customValidator: (value) {
    if (value == null) return 'Required';
    if (!value.contains('@')) return 'Invalid email';
    return null;
  },
)
```

### Add Conditional Visibility

```dart
FormFieldConfig(
  id: 'companyName',
  label: 'Company',
  visible: userType == 'business', // Dynamic visibility
)
```

## Comparison with Angular Approach

| Angular | Flutter Config-Driven |
|---------|----------------------|
| `control: formRef.get('@Field')` | `controller: _controllers['Field']` |
| `span: 'col-span-2'` | `flex: 2` |
| `type: 'select'` | `type: FieldType.select` |
| `pattern: this.pattern` | `pattern: RegExp(r'...')` |
| `required: true` | `required: true` |
| `readonly: true` | `readonly: true` |
| `visible: false` | `visible: false` |
| `minLen: 4` | `minLength: 4` |
| `maxLen: 10` | `maxLength: 10` |

## Best Practices

### 1. **Group Related Fields**
```dart
FormSectionConfig(
  title: 'Address',
  fields: [
    FormFieldConfig(id: 'street', ...),
    FormFieldConfig(id: 'city', ...),
    FormFieldConfig(id: 'zip', ...),
  ],
)
```

### 2. **Use Constants for Patterns**
```dart
class ValidationPatterns {
  static final email = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  static final phone = RegExp(r'^\d{10}$');
  static final zipCode = RegExp(r'^\d{5}$');
}
```

### 3. **Separate Schema from UI**
```dart
// schema.dart
class FormSchemas {
  static List<FormSectionConfig> participant() { ... }
  static List<FormSectionConfig> resource() { ... }
}

// screen.dart
class MyScreen extends StatelessWidget {
  final sections = FormSchemas.participant();
}
```

### 4. **Use copyWith for Variations**
```dart
final baseField = FormFieldConfig(
  id: 'base',
  label: 'Base',
  required: true,
);

final editField = baseField.copyWith(
  readonly: true,
  label: 'Base (Read-Only)',
);
```

## Testing Example

```dart
void main() {
  group('FormFieldConfig', () {
    test('creates valid configuration', () {
      final config = FormFieldConfig(
        id: 'test',
        label: 'Test Field',
        required: true,
        maxLength: 10,
      );
      
      expect(config.id, 'test');
      expect(config.required, true);
      expect(config.maxLength, 10);
    });
    
    test('copyWith preserves unchanged values', () {
      final original = FormFieldConfig(
        id: 'test',
        label: 'Test',
        required: true,
      );
      
      final copy = original.copyWith(readonly: true);
      
      expect(copy.id, 'test');
      expect(copy.required, true);
      expect(copy.readonly, true);
    });
  });
}
```

## Route Configuration

Add to your router:

```dart
// Import the screen with updated path
import 'app/dashboard/config_driven_forms/config_driven_participant_screen.dart';

GoRoute(
  path: '/participant/config/:id',
  builder: (context, state) {
    final id = state.pathParameters['id'];
    // Load participant data
    final participant = getParticipant(id);
    
    return ConfigDrivenParticipantScreen(
      participant: participant,
    );
  },
),
```

## Performance Considerations

- Controllers are initialized once in `initState`
- Validators are created on-demand (not cached)
- Layout rebuilds only on field visibility changes
- Responsive layout uses `LayoutBuilder` (minimal overhead)

## Future Enhancements

- [ ] Field dependencies (show field B when field A is selected)
- [ ] Async validators (check username availability)
- [ ] Field groups with collapsible sections
- [ ] Drag-and-drop form builder UI
- [ ] Export/import form definitions as JSON
- [ ] Field templates library
- [ ] Localization support
- [ ] Accessibility improvements

## License

MIT
