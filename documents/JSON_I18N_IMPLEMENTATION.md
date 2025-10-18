# JSON-Based Internationalization Implementation

## Overview

This document describes the implementation of JSON-based internationalization using the `easy_localization` package, which provides native support for nested JSON structures similar to Angular's i18n approach.

## Implementation Details

### Package Used
- **easy_localization**: v3.0.8
- Package URL: https://pub.dev/packages/easy_localization

### Advantages Over ARB

1. **Native Nested Structure**: JSON supports natural nesting unlike ARB's flat structure
2. **Angular-like Syntax**: Familiar dot notation for accessing nested keys
3. **Simpler Migration**: Direct mapping from Angular JSON files
4. **Better Organization**: Logical grouping of related translations
5. **No Wrapper Classes Needed**: Direct access to nested keys

## File Structure

```
assets/
└── lang/
    ├── en.json          # English translations
    └── ja.json          # Japanese translations (future)

lib/
├── l10n/
│   ├── app_en.arb       # Legacy ARB (still used for app-wide translations)
│   └── app_es.arb       # Spanish ARB
└── main.dart            # EasyLocalization initialization
```

## JSON Structure

### English (assets/lang/en.json)

```json
{
  "participant": {
    "header": {
      "title": "Participant Details",
      "newTitle": "Add New Participant"
    },
    "tabs": {
      "generalTab": "General Details",
      "validityTab": "Participant Validity",
      "bankAccountTab": "Bank Account"
    },
    "placeholders": {
      "ParticipantName": "System generated value",
      "CompanyLongName": "Must be of pattern: Japanese characters",
      "CompanyShortName": "Must be of pattern: Japanese characters",
      "PhonePart1": "XXXXX",
      "PhonePart2": "XXXX",
      "PhonePart3": "XXXX",
      "TransactionId": ""
    },
    "messages": {
      "CompanyLongName": "Must be of pattern: Japanese characters",
      "CompanyShortName": "Must be of pattern: Japanese characters",
      "ParticipantName": "Must be of pattern : (^[A-W]([0-9][0-9][1-9]|[0-9][1-9][0-9]|[1-9][0-9][0-9])$)"
    },
    "RegistrationQuery": {
      "Date": "Trade Date",
      "Participant": {
        "ParticipantName": "Participant Name"
      }
    },
    "RegistrationSubmit": {
      "Participant": {
        "ParticipantName": "Participant Name",
        "ParticipantType": "Participant Type",
        "StartDate": "Start Date",
        "EndDate": "End Date",
        "Area": "Area",
        "CompanyShortName": "Company Short Name",
        "CompanyLongName": "Company Long Name",
        "PhonePart1Alias": "Phone Part1",
        "PhonePart1": "Phone Number",
        "PhonePart2": "Phone Part2",
        "PhonePart3": "Phone Part3",
        "TransactionId": "Transaction Id"
      }
    },
    "buttons": {
      "reset": "Reset",
      "create": "Create Participant",
      "creating": "Creating...",
      "save": "Save",
      "saving": "Saving...",
      "query": "Query"
    },
    "feedback": {
      "messagesTitle": "Messages",
      "createdSuccess": "Participant created successfully with name: {name}",
      "updatedSuccess": "Participant updated successfully",
      "querySuccess": "Participant data loaded successfully",
      "fixFormErrors": "Please fix the errors in the form",
      "nameTrimmed": "Participant name trimmed to first 4 chars (max length = 4).",
      "failedToCreate": "Failed to add participant: {error}",
      "failedToUpdate": "Failed to update participant: {error}",
      "failedToQuery": "Failed to query participant: {error}"
    }
  }
}
```

## Configuration

### 1. pubspec.yaml

```yaml
dependencies:
  easy_localization: ^3.0.8

flutter:
  assets:
    - assets/lang/
```

### 2. main.dart Initialization

```dart
import 'package:easy_localization/easy_localization.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  
  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('ja')],
      path: 'assets/lang',
      fallbackLocale: const Locale('en'),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  // ...
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      // ...
      localizationsDelegates: [
        ...context.localizationDelegates,
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      // ...
    );
  }
}
```

## Usage in Code

### Import Statement

```dart
import 'package:easy_localization/easy_localization.dart';
```

### Accessing Translations

#### Method 1: Using .tr() extension

```dart
Text('participant.header.title'.tr())
```

#### Method 2: Using context (when available)

```dart
Text(context.tr('participant.header.title'))
```

### In Schema Files

```dart
import 'package:easy_localization/easy_localization.dart';

class ParticipantUpdateSchema {
  static List<FormSectionConfig> getUpsertSections(BuildContext context) {
    return [
      FormSectionConfig(
        fields: [
          FormFieldConfig(
            id: 'ParticipantName',
            label: 'participant.RegistrationSubmit.Participant.ParticipantName'.tr(),
            placeholder: 'participant.placeholders.ParticipantName'.tr(),
            patternMessage: 'participant.messages.ParticipantName'.tr(),
          ),
          FormFieldConfig(
            id: 'CompanyShortName',
            label: 'participant.RegistrationSubmit.Participant.CompanyShortName'.tr(),
            placeholder: 'participant.placeholders.CompanyShortName'.tr(),
            patternMessage: 'participant.messages.CompanyShortName'.tr(),
          ),
        ],
      ),
    ];
  }
}
```

### In Screen Files

```dart
import 'package:easy_localization/easy_localization.dart';

class ParticipantUpdateScreen extends StatefulWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('participant.header.title'.tr()),
      ),
      body: Column(
        children: [
          Text('participant.tabs.generalTab'.tr()),
          ElevatedButton(
            onPressed: () {},
            child: Text('participant.buttons.save'.tr()),
          ),
        ],
      ),
    );
  }
}
```

## Parameterized Translations

For translations with parameters (e.g., `{name}`, `{error}`):

```dart
// In JSON:
"createdSuccess": "Participant created successfully with name: {name}"

// In code:
Text(tr('participant.feedback.createdSuccess', namedArgs: {'name': participantName}))
```

## Migration Strategy

### Phase 1: Participant Forms (Current)
- ✅ Updated `participant_update_schema.dart`
- ✅ Updated `participant_update_screen.dart`
- ✅ Updated `participant_create_schema.dart`
- ✅ Updated `participant_create_screen.dart`
- ⏳ Update `participant_query_component.dart`

### Phase 2: Other Modules (Future)
- Keep using ARB for app-wide translations
- Migrate specific modules to JSON as needed
- Both systems can coexist

### Hybrid Approach
Currently using:
- **ARB**: General app translations (buttons, navigation, etc.)
- **JSON**: Registration module (participant forms)

## Language Switching

```dart
// Change language to Japanese
context.setLocale(Locale('ja'));

// Get current locale
Locale currentLocale = context.locale;
```

## Best Practices

1. **Consistent Naming**: Follow Angular naming convention
   ```
   module.section.subsection.key
   participant.RegistrationSubmit.Participant.ParticipantName
   ```

2. **Organize Logically**: Group related translations under common parents
   ```json
   {
     "participant": {
       "header": { /* header items */ },
       "tabs": { /* tab items */ },
       "buttons": { /* button items */ }
     }
   }
   ```

3. **Import Once**: Add import at top of file
   ```dart
   import 'package:easy_localization/easy_localization.dart';
   ```

4. **Use .tr() for Static**: Use .tr() extension for simple translations
   ```dart
   label: 'participant.header.title'.tr()
   ```

5. **Use context.tr() for Dynamic**: Use context when you have parameters
   ```dart
   context.tr('participant.feedback.createdSuccess', 
              namedArgs: {'name': name})
   ```

## Files Updated

### Schemas
1. `lib/app/dashboard/config_driven_forms/schemas/participant_update_schema.dart`
   - Removed AppLocalizations import
   - Added easy_localization import
   - Converted all labels, placeholders, and messages to JSON keys

2. `lib/app/dashboard/config_driven_forms/schemas/participant_create_schema.dart`
   - Same changes as update schema
   - Updated required field labels with asterisk

### Screens
1. `lib/app/dashboard/config_driven_forms/participant_update_screen.dart`
   - Replaced AppLocalizations with easy_localization
   - Updated AppBar title to use JSON key
   - Updated tab header to use JSON key

2. `lib/app/dashboard/config_driven_forms/participant_create_screen.dart`
   - Same changes as update screen

### Configuration
1. `lib/main.dart`
   - Added EasyLocalization initialization
   - Updated MaterialApp configuration

2. `pubspec.yaml`
   - Added easy_localization package
   - Configured assets/lang/ path

### Assets
1. `assets/lang/en.json`
   - Created with complete participant translations
   - Organized in nested structure matching Angular

## Testing

1. **Verify Translations Load**
   ```bash
   flutter run
   ```

2. **Check for Missing Keys**
   - Watch console for translation errors
   - Missing keys will display the key name

3. **Hot Reload Support**
   - JSON changes require app restart
   - Code changes support hot reload

## Future Enhancements

1. **Add Japanese Translation** (`ja.json`)
2. **Migrate More Modules** to JSON structure
3. **Create Translation Management Tool**
4. **Add Translation Coverage Tests**
5. **Consider Removing ARB** (if fully migrated)

## Comparison: ARB vs JSON

| Feature | ARB (Flutter) | JSON (easy_localization) |
|---------|---------------|--------------------------|
| Structure | Flat only | Nested support ✅ |
| Access | `l10n.key` | `'path.to.key'.tr()` ✅ |
| Organization | Comments | Native nesting ✅ |
| Angular-like | No | Yes ✅ |
| Flutter Native | Yes | No |
| Build Time | Generated | Runtime loading |
| Hot Reload | Yes | Restart needed |

## Resources

- [easy_localization Package](https://pub.dev/packages/easy_localization)
- [easy_localization GitHub](https://github.com/aissat/easy_localization)
- [Flutter Internationalization](https://docs.flutter.dev/development/accessibility-and-localization/internationalization)

## Support

For issues or questions:
1. Check the easy_localization documentation
2. Review this implementation guide
3. Test translations in isolation
4. Verify JSON structure is valid
