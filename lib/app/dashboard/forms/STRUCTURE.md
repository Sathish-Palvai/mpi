# Forms Directory Structure

This directory has been reorganized from `config_driven_forms` to `forms` for better clarity and scalability.

## Directory Structure

```
lib/app/dashboard/forms/
├── participant/
│   ├── schemas/
│   │   ├── participant_create_schema.dart
│   │   ├── participant_update_schema.dart
│   │   └── participant_query_schema.dart
│   ├── participant_create_screen.dart
│   ├── participant_update_screen.dart
│   └── participant_query_component.dart
└── docs/
    └── (documentation files)
```

## Organization

### Participant Module (`participant/`)
All participant-related screens, components, and schemas are grouped together:

- **Screens**: 
  - `participant_create_screen.dart` - Create new participants
  - `participant_update_screen.dart` - Update existing participants
  
- **Components**: 
  - `participant_query_component.dart` - Reusable query bottom sheet
  
- **Schemas** (`schemas/`):
  - `participant_create_schema.dart` - Form configuration for creation
  - `participant_update_schema.dart` - Form configuration for updates
  - `participant_query_schema.dart` - Query form configuration

## Future Modules

As more forms are added, they should follow the same structure:

```
forms/
├── participant/
│   ├── schemas/
│   ├── [screens]
│   └── [components]
├── resource/
│   ├── schemas/
│   ├── [screens]
│   └── [components]
├── user/
│   ├── schemas/
│   ├── [screens]
│   └── [components]
└── docs/
```

## Import Path Changes

### Before (config_driven_forms):
```dart
import 'app/dashboard/config_driven_forms/participant_update_screen.dart';
import 'app/dashboard/config_driven_forms/schemas/participant_update_schema.dart';
```

### After (forms):
```dart
import 'app/dashboard/forms/participant/participant_update_screen.dart';
import 'app/dashboard/forms/participant/schemas/participant_update_schema.dart';
```

## Benefits

1. **Better Organization**: Related files are grouped together by module
2. **Scalability**: Easy to add new form modules (resource, user, etc.)
3. **Clear Naming**: "forms" is more intuitive than "config_driven_forms"
4. **Maintainability**: Each module is self-contained with its own schemas
5. **Discoverability**: Easy to find all participant-related files in one place

## Migration Notes

All imports have been updated in:
- ✅ `lib/main.dart`
- ✅ `participant_update_screen.dart`
- ✅ `participant_create_screen.dart`
- ✅ `participant_query_component.dart`

The old `config_driven_forms` directory has been removed.
