# Response Messages Card - Quick Reference

## Component Location

```
lib/core/forms/response_messages_card.dart
```

## Import Statement

```dart
import 'package:mpi/core/forms/forms.dart';
```

## Minimal Usage

```dart
// Add state variables
Map<String, dynamic>? _response;
bool _showResponse = false;

// Display component
ResponseMessagesCard(
  response: _response,
  visible: _showResponse,
)
```

## Complete Example

```dart
import 'package:flutter/material.dart' hide FormFieldBuilder;
import 'package:mpi/core/forms/forms.dart';

class MyScreen extends StatefulWidget {
  @override
  State<MyScreen> createState() => _MyScreenState();
}

class _MyScreenState extends State<MyScreen> {
  Map<String, dynamic>? _response;
  bool _showResponse = false;

  Future<void> _submit() async {
    try {
      final response = await ApiService.submit(data);
      setState(() {
        _response = response;
        _showResponse = true;
      });
    } catch (e) {
      setState(() {
        _response = {
          'RegistrationData': {
            'RegistrationSubmit': {
              'Messages': {'Error': {'#text': e.toString()}},
            },
          },
        };
        _showResponse = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ResponseMessagesCard(
          response: _response,
          visible: _showResponse,
          title: 'Result',
        ),
        // ... your form here
      ],
    );
  }
}
```

## Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `response` | `Map<String, dynamic>?` | required | API response data |
| `title` | `String` | `'Messages'` | Card header title |
| `visible` | `bool` | `true` | Show/hide card |
| `initiallyCollapsed` | `bool` | `false` | Start collapsed |
| `onCollapsedChanged` | `ValueChanged<bool>?` | `null` | Collapse callback |

## Expected Response Format

```json
{
  "RegistrationData": {
    "ProcessingStatistics": {
      "@Received": "1",
      "@Valid": "1",
      "@Successful": "1",
      "@ProcessingTimeMs": "45"
    },
    "RegistrationSubmit": {
      "Messages": {
        "Information": [{"#text": "Success message"}],
        "Warning": [{"#text": "Warning message"}],
        "Error": [{"#text": "Error message"}]
      }
    }
  }
}
```

## Static Methods

```dart
// Extract messages
List<ResponseMessage> messages = 
  ResponseMessagesCard.extractMessages(response);

// Extract statistics
ProcessingStatistics? stats = 
  ResponseMessagesCard.extractStatistics(response);
```

## Visual Layout

```
┌─────────────────────────────────────────┐
│ Messages (3)              [📊] [▼]      │  ← Header
├─────────────────────────────────────────┤
│ Type    │ Message                       │
├─────────┼───────────────────────────────┤
│ info    │ Participant updated           │  ← Info (blue)
│ warn    │ Field deprecated              │  ← Warning (orange)
│ error   │ Validation failed             │  ← Error (red)
└─────────────────────────────────────────┘
```

## Features

✅ Automatic message categorization  
✅ Color-coded message types  
✅ Processing statistics popup  
✅ Collapsible content  
✅ Selectable text  
✅ Theme-aware  
✅ Responsive layout  

## Migration from Old Code

### Before
```dart
Widget _buildResponseGrid() {
  if (!_showResponse || _submissionResponse == null) 
    return const SizedBox.shrink();
  
  // 150+ lines of code...
  final registrationData = _submissionResponse!['RegistrationData'];
  final messages = registrationSubmit?['Messages'];
  
  // Parse messages...
  // Build widgets...
  
  return Card(...); // Lots of manual widget building
}
```

### After
```dart
ResponseMessagesCard(
  response: _submissionResponse,
  visible: _showResponse,
  title: 'Messages',
)
```

**Savings:** ~150 lines → 4 lines per screen

## Documentation

- **Full Docs:** [RESPONSE_MESSAGES_COMPONENT.md](lib/core/forms/RESPONSE_MESSAGES_COMPONENT.md)
- **Library Docs:** [README.md](lib/core/forms/README.md)
- **Complete Summary:** [RESPONSE_MESSAGES_SUMMARY.md](RESPONSE_MESSAGES_SUMMARY.md)

## Common Patterns

### Pattern 1: Simple Display
```dart
ResponseMessagesCard(
  response: _response,
  visible: _showResponse,
)
```

### Pattern 2: Custom Title
```dart
ResponseMessagesCard(
  response: _response,
  visible: _showResponse,
  title: 'Validation Results',
)
```

### Pattern 3: Start Collapsed
```dart
ResponseMessagesCard(
  response: _response,
  visible: _showResponse,
  initiallyCollapsed: true,
)
```

### Pattern 4: Track State
```dart
ResponseMessagesCard(
  response: _response,
  visible: _showResponse,
  onCollapsedChanged: (collapsed) {
    debugPrint('Messages collapsed: $collapsed');
  },
)
```

## Integration with Forms Library

```dart
import 'package:flutter/material.dart' hide FormFieldBuilder;
import 'package:mpi/core/forms/forms.dart';

// Use both together
Column(
  children: [
    // Response messages
    ResponseMessagesCard(
      response: _response,
      visible: _showResponse,
    ),
    
    // Form sections
    ...sections.map((section) =>
      FormFieldBuilder.buildSection(
        context: context,
        section: section,
        controllers: controllers,
      ),
    ),
  ],
)
```

## Error Handling

```dart
try {
  final response = await ApiService.submit(data);
  setState(() {
    _response = response;
    _showResponse = true;
  });
} catch (e) {
  // Create error response
  setState(() {
    _response = {
      'RegistrationData': {
        'RegistrationSubmit': {
          'Messages': {
            'Error': {'#text': 'Failed to submit: $e'},
          },
        },
      },
    };
    _showResponse = true;
  });
}
```

## Message Types & Colors

| Type | Display | Color | Use Case |
|------|---------|-------|----------|
| Information | `info` | Blue | Success, status updates |
| Warning | `warn` | Orange | Deprecations, suggestions |
| Error | `error` | Red | Validation errors, failures |

## Statistics Fields

When available, shows popup with:
- **Received:** Total records received
- **Valid:** Valid records
- **Invalid:** Invalid records
- **Successful:** Successfully processed
- **Unsuccessful:** Failed to process
- **Processing Time:** Time in milliseconds

## Best Practices

✅ **DO:** Use `visible` flag to control display  
✅ **DO:** Set meaningful `title` for context  
✅ **DO:** Handle both success and error responses  
✅ **DO:** Show response after form submission  

❌ **DON'T:** Forget to set `_showResponse = true`  
❌ **DON'T:** Modify response structure directly  
❌ **DON'T:** Use without state management  

## File Size Metrics

- **Component:** 387 lines
- **Documentation:** 836 lines
- **Example Integration:** 48 lines (added to v2 screen)
- **Summary:** 488 lines

**Total Created:** 1,759 lines

**Code Eliminated Per Screen:** ~150 lines of duplication

## Status

✅ **Component created** - Production ready  
✅ **Documentation complete** - Full API reference  
✅ **Library integrated** - Exported from forms.dart  
✅ **Example updated** - config_driven_participant_screen_v2.dart  
✅ **Zero errors** - All files compile  
✅ **Ready to use** - Can be imported immediately  

---

**Last Updated:** December 2024  
**Component Version:** 1.0.0  
**Status:** ✅ Production Ready
