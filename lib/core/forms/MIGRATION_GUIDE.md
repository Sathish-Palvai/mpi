# 🔄 Migration Guide: Config-Driven Forms Refactoring

## What Changed?

The config-driven forms system has been refactored into a **reusable library** that can be shared across multiple screens.

---

## 📦 New Structure

### Before
```
lib/app/dashboard/config_driven_forms/
└── config_driven_participant_screen.dart (790 lines - monolithic)
    ├── FieldType enum
    ├── FormFieldConfig class
    ├── FormSectionConfig class
    ├── ParticipantFormSchema class
    └── ConfigDrivenParticipantScreen widget
```

### After
```
lib/
├── core/forms/                          # ✨ NEW: Reusable Library
│   ├── forms.dart                       # Main export
│   ├── form_field_config.dart           # Models (120 lines)
│   ├── form_field_builder.dart          # Builders (490 lines)
│   └── form_controller_helper.dart      # Helpers (160 lines)
│
└── app/dashboard/config_driven_forms/
    ├── schemas/
    │   └── participant_form_schema.dart # Participant schema (200 lines)
    └── config_driven_participant_screen_v2.dart # New screen (250 lines)
```

---

## 🎯 Benefits

| Aspect | Before | After |
|--------|--------|-------|
| **Code Reuse** | Copy-paste entire file | Import library |
| **Maintenance** | Update each screen | Update library once |
| **Form Creation** | 790 lines | 200-250 lines |
| **Controller Setup** | Manual | Automatic |
| **Validation** | Repeated code | Declarative |
| **New Field Types** | Edit each screen | Add to library |

---

## 🚀 How to Use the New System

### Option 1: Start Fresh (Recommended)

Create a new form using the library:

```dart
// 1. Create schema file
class MyFormSchema {
  static List<FormSectionConfig> getSections() {
    return [/* your fields */];
  }
}

// 2. Import library
import 'package:mpi/core/forms/forms.dart';

// 3. Use FormControllerHelper and FormFieldBuilder
```

See [README.md](./README.md) for complete examples.

### Option 2: Migrate Existing Screen

If you want to migrate the original participant screen:

1. **Replace imports:**
   ```dart
   // Old
   // (no imports, everything in one file)
   
   // New
   import 'package:flutter/material.dart' hide FormFieldBuilder;
   import 'package:mpi/core/forms/forms.dart';
   import 'schemas/participant_form_schema.dart';
   ```

2. **Remove duplicated classes:**
   Delete from your screen:
   - `FieldType` enum
   - `FormFieldConfig` class  
   - `FormSectionConfig` class
   - `ParticipantFormSchema` class (move to schemas/)
   - All builder methods (`_buildField`, `_buildValidator`, etc.)

3. **Use helper classes:**
   ```dart
   // Old
   final controller = TextEditingController(text: initialValue);
   _controllers[field.id] = controller;
   
   // New
   _controllers = FormControllerHelper.initializeControllers(
     sections,
     initialData,
   );
   ```

4. **Use library builders:**
   ```dart
   // Old
   _buildSection(section)
   
   // New
   FormFieldBuilder.buildSection(
     context: context,
     section: section,
     controllers: _controllers,
     onDateFieldTap: _pickDate,
   );
   ```

---

## 📝 Step-by-Step Migration Example

### Original File (790 lines)

```dart
// config_driven_participant_screen.dart
import 'package:flutter/material.dart';

enum FieldType { ... }
class FormFieldConfig { ... }
class FormSectionConfig { ... }
class ParticipantFormSchema { ... }

class ConfigDrivenParticipantScreen extends StatefulWidget {
  // ... 500 lines of implementation
  
  void _initializeControllers() { ... }
  InputDecoration _inputDecoration() { ... }
  String? Function(String?)? _buildValidator() { ... }
  Widget _buildField() { ... }
  // ... etc
}
```

### Migrated Files

**1. Schema (200 lines)**
```dart
// schemas/participant_form_schema.dart
import 'package:mpi/core/forms/forms.dart';

class ParticipantFormSchema {
  static List<FormSectionConfig> getSections() {
    return [/* sections */];
  }
}
```

**2. Screen (250 lines)**
```dart
// config_driven_participant_screen_v2.dart
import 'package:flutter/material.dart' hide FormFieldBuilder;
import 'package:mpi/core/forms/forms.dart';
import 'schemas/participant_form_schema.dart';

class ConfigDrivenParticipantScreen extends StatefulWidget {
  @override
  void initState() {
    _sections = ParticipantFormSchema.getSections();
    _controllers = FormControllerHelper.initializeControllers(
      _sections,
      widget.participant,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        child: ListView(
          children: _sections.map((section) {
            return FormFieldBuilder.buildSection(
              context: context,
              section: section,
              controllers: _controllers,
              onDateFieldTap: _pickDate,
            );
          }).toList(),
        ),
      ),
    );
  }
}
```

**Result:** 790 lines → 450 lines (43% reduction)

---

## 🔧 Migration Checklist

### For Each Form Screen:

- [ ] Create schema file in `schemas/` directory
- [ ] Move form configuration to schema file
- [ ] Import library: `import 'package:mpi/core/forms/forms.dart'`
- [ ] Add hide clause: `import 'package:flutter/material.dart' hide FormFieldBuilder`
- [ ] Replace controller initialization with `FormControllerHelper.initializeControllers()`
- [ ] Replace controller disposal with `FormControllerHelper.disposeControllers()`
- [ ] Replace `_buildSection()` with `FormFieldBuilder.buildSection()`
- [ ] Replace `_buildField()` with `FormFieldBuilder.buildField()`
- [ ] Replace `_buildValidator()` with `FormFieldBuilder.buildValidator()`
- [ ] Replace date picking with `FormFieldBuilder.pickDate()`
- [ ] Replace data extraction with `FormControllerHelper.getFormData()`
- [ ] Test form validation
- [ ] Test form submission
- [ ] Test responsive layout
- [ ] Remove old implementation file (optional)

---

## 🎯 What to Keep vs Remove

### Keep in Your Screen:
✅ Screen-specific UI (AppBar, Drawer, etc.)  
✅ Business logic (save, delete, etc.)  
✅ Navigation logic  
✅ BLoC integration  
✅ API calls  
✅ Error handling  

### Remove from Your Screen:
❌ Field type enums  
❌ Configuration classes  
❌ Form schema definitions  
❌ Controller initialization loops  
❌ Validator builder methods  
❌ Input decoration builders  
❌ Field widget builders  
❌ Section builders  

### Move to Schema File:
📦 Field definitions  
📦 Validation patterns  
📦 Section configurations  
📦 Form structure  

---

## 📊 Before vs After Comparison

### Controller Initialization

**Before (Manual):**
```dart
void _initializeControllers() {
  final allSections = [
    ...ParticipantFormSchema.getUpsertSections(),
    ...ParticipantFormSchema.getOtherControlsSections(),
  ];

  for (var section in allSections) {
    for (var field in section.fields) {
      final controller = TextEditingController(
        text: widget.participant[field.id]?.toString() ?? 
              field.initialValue ?? 
              '',
      );
      _controllers[field.id] = controller;
    }
  }
}

@override
void dispose() {
  for (var controller in _controllers.values) {
    controller.dispose();
  }
  super.dispose();
}
```

**After (Automatic):**
```dart
@override
void initState() {
  super.initState();
  _sections = ParticipantFormSchema.getSections();
  _controllers = FormControllerHelper.initializeControllers(
    _sections,
    widget.participant,
  );
}

@override
void dispose() {
  FormControllerHelper.disposeControllers(_controllers);
  super.dispose();
}
```

### Building Form Sections

**Before (Custom):**
```dart
Widget _buildSection(FormSectionConfig section) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      if (section.title != null) ...[
        Text(section.title!, style: /* ... */),
        const SizedBox(height: 16),
      ],
      _buildFieldRow(section.fields),
      const SizedBox(height: _fieldSpacing),
    ],
  );
}

Widget _buildFieldRow(List<FormFieldConfig> fields) {
  return LayoutBuilder(
    builder: (context, constraints) {
      final isMobile = constraints.maxWidth < 600;
      // ... 50+ lines of layout logic
    },
  );
}
```

**After (Library):**
```dart
FormFieldBuilder.buildSection(
  context: context,
  section: section,
  controllers: _controllers,
  onDateFieldTap: _pickDate,
)
```

### Getting Form Data

**Before (Manual):**
```dart
final payload = <String, dynamic>{};
for (final entry in _controllers.entries) {
  payload[entry.key] = entry.value.text;
}
```

**After (Helper):**
```dart
final payload = FormControllerHelper.getFormData(_controllers);

// Or with type conversion:
final typedPayload = FormControllerHelper.getFormDataWithTypes(
  _controllers,
  _sections,
);
```

---

## 🆕 New Features Available

The library provides additional features not in the original:

### 1. Type Conversion
```dart
final data = FormControllerHelper.getFormDataWithTypes(
  controllers,
  sections,
);
// Numbers as numbers, booleans as booleans, etc.
```

### 2. Change Detection
```dart
if (FormControllerHelper.hasUnsavedChanges(controllers, originalData)) {
  // Prompt user before navigating away
}
```

### 3. Batch Updates
```dart
FormControllerHelper.updateControllers(controllers, newData);
```

### 4. Reset Form
```dart
FormControllerHelper.resetControllers(controllers);
```

### 5. Field Queries
```dart
final visibleFields = FormControllerHelper.getVisibleFieldIds(sections);
final requiredFields = FormControllerHelper.getRequiredFieldIds(sections);
```

### 6. More Field Types
- ✨ `FieldType.checkbox`
- ✨ `FieldType.radio`
- ✨ `FieldType.email` (with validation)
- ✨ `FieldType.url` (with validation)

### 7. Enhanced Field Config
- ✨ `customValidator` - Custom validation functions
- ✨ `prefixIcon` / `suffixIcon` - Field icons
- ✨ `helperText` - Help text below field
- ✨ `autofocus` - Auto-focus on load
- ✨ `obscureText` - Password fields
- ✨ `minValue` / `maxValue` - Number validation

---

## 🐛 Common Migration Issues

### Issue 1: FormFieldBuilder Conflict

**Error:**
```
The name 'FormFieldBuilder' is defined in multiple libraries
```

**Solution:**
```dart
import 'package:flutter/material.dart' hide FormFieldBuilder;
```

### Issue 2: Missing onDateFieldTap

**Error:**
```
Date picker doesn't show up
```

**Solution:**
```dart
// Always provide callback for date fields
FormFieldBuilder.buildSection(
  context: context,
  section: section,
  controllers: _controllers,
  onDateFieldTap: (fieldId) => _pickDate(fieldId), // Add this!
);
```

### Issue 3: Schema Import Path

**Error:**
```
Target of URI doesn't exist: '../../../core/forms/forms.dart'
```

**Solution:**
Check your directory depth and adjust:
```dart
// From schemas/ directory (4 levels deep)
import '../../../../core/forms/forms.dart';

// From config_driven_forms/ directory (3 levels deep)
import '../../../core/forms/forms.dart';
```

---

## 📚 Files Reference

### Core Library Files:
- `lib/core/forms/forms.dart` - Main export
- `lib/core/forms/form_field_config.dart` - Config models
- `lib/core/forms/form_field_builder.dart` - Widget builders
- `lib/core/forms/form_controller_helper.dart` - Controller management
- `lib/core/forms/README.md` - Library documentation

### Example Files:
- `lib/app/dashboard/config_driven_forms/schemas/participant_form_schema.dart` - Schema example
- `lib/app/dashboard/config_driven_forms/config_driven_participant_screen_v2.dart` - Screen example
- `lib/app/dashboard/config_driven_forms/config_driven_participant_screen.dart` - Original (for reference)

---

## ✅ Testing After Migration

### Test Checklist:
- [ ] Form loads with initial data
- [ ] All fields render correctly
- [ ] Required validation works
- [ ] Pattern validation works
- [ ] Min/max length validation works
- [ ] Date picker opens and updates field
- [ ] Dropdowns show options and update
- [ ] Checkboxes toggle correctly
- [ ] Form submission works
- [ ] Error messages display correctly
- [ ] Readonly fields are disabled
- [ ] Hidden fields are not visible
- [ ] Responsive layout works (mobile & desktop)
- [ ] Controllers dispose properly (no memory leaks)

---

## 🎓 Next Steps

1. **Test the new participant screen:**
   - Update your route to use `config_driven_participant_screen_v2.dart`
   - Test all functionality
   - Compare with original

2. **Create schemas for other forms:**
   - Resource form
   - Interface form
   - etc.

3. **Gradually migrate existing forms:**
   - One form at a time
   - Keep old version until new is tested
   - Delete old version when confident

4. **Extend the library:**
   - Add custom field types if needed
   - Add common validation patterns
   - Create field presets

5. **Write tests:**
   - Unit tests for validators
   - Widget tests for builders
   - Integration tests for complete forms

---

## 🎉 You're Done!

The forms library is now ready to use across your entire application!

**Questions?** Check:
- `lib/core/forms/README.md` - Complete library documentation
- Original files for reference
- Test the v2 screen to see it in action

**Happy migrating!** 🚀
