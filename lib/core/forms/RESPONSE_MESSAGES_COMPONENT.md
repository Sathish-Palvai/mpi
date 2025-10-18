# Response Messages Card Component

## Overview

The `ResponseMessagesCard` is a reusable Flutter component designed to display API response messages and processing statistics in a consistent, user-friendly format. It's part of the config-driven forms library and can be used across any screen that needs to display backend response information.

## Features

✅ **Message Categorization** - Automatically categorizes messages as info, warn, or error  
✅ **Color Coding** - Visual distinction with color-coded message types  
✅ **Processing Statistics** - Displays detailed processing metrics in a popup  
✅ **Collapsible Content** - Save screen space with expand/collapse functionality  
✅ **Selectable Text** - Users can copy messages for reporting or debugging  
✅ **Theme Aware** - Automatically adapts to Material Design theme  
✅ **Type Safe** - Strongly typed models for messages and statistics  

## Component Structure

```
ResponseMessagesCard
├── ResponseMessage (model)
├── ProcessingStatistics (model)
└── _ResponseMessagesCardState (widget)
```

## Data Models

### ResponseMessage

```dart
class ResponseMessage {
  final String type;      // 'info', 'warn', 'error'
  final String message;   // The actual message text
}
```

### ProcessingStatistics

```dart
class ProcessingStatistics {
  final String received;
  final String valid;
  final String invalid;
  final String successful;
  final String unsuccessful;
  final String processingTime;
}
```

## Usage

### Basic Usage

```dart
import 'package:mpi/core/forms/forms.dart';

ResponseMessagesCard(
  response: apiResponse,
  title: 'Messages',
  visible: true,
)
```

### With State Management

```dart
class MyScreen extends StatefulWidget {
  @override
  State<MyScreen> createState() => _MyScreenState();
}

class _MyScreenState extends State<MyScreen> {
  Map<String, dynamic>? _response;
  bool _showResponse = false;

  Future<void> _submitForm() async {
    try {
      final response = await ApiService.submit(data);
      setState(() {
        _response = response;
        _showResponse = true;
      });
    } catch (e) {
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ResponseMessagesCard(
          response: _response,
          visible: _showResponse,
          title: 'Submission Result',
          initiallyCollapsed: false,
          onCollapsedChanged: (collapsed) {
            debugPrint('Messages collapsed: $collapsed');
          },
        ),
        // ... rest of your UI
      ],
    );
  }
}
```

### Complete Example

```dart
import 'package:flutter/material.dart';
import 'package:mpi/core/forms/forms.dart';

class ParticipantScreen extends StatefulWidget {
  @override
  State<ParticipantScreen> createState() => _ParticipantScreenState();
}

class _ParticipantScreenState extends State<ParticipantScreen> {
  Map<String, dynamic>? _submissionResponse;
  bool _showResponse = false;
  bool _isSubmitting = false;

  Future<void> _saveParticipant() async {
    setState(() => _isSubmitting = true);

    try {
      final response = await ApiService.updateParticipant(data);
      
      setState(() {
        _submissionResponse = response;
        _showResponse = true;
        _isSubmitting = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Success!')),
      );
    } catch (e) {
      setState(() {
        _submissionResponse = {
          'RegistrationData': {
            'RegistrationSubmit': {
              'Messages': {
                'Error': {'#text': 'Failed: $e'},
              },
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
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Column(
          children: [
            // Show response messages
            ResponseMessagesCard(
              response: _submissionResponse,
              visible: _showResponse,
              title: 'Submission Result',
            ),
            if (_showResponse) SizedBox(height: 24),
            
            // Form fields here...
            
            ElevatedButton(
              onPressed: _isSubmitting ? null : _saveParticipant,
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
```

## API Reference

### Constructor Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `response` | `Map<String, dynamic>?` | Yes | - | API response containing messages and statistics |
| `title` | `String` | No | `'Messages'` | Header title for the card |
| `visible` | `bool` | No | `true` | Whether to show the card |
| `initiallyCollapsed` | `bool` | No | `false` | Start in collapsed state |
| `onCollapsedChanged` | `ValueChanged<bool>?` | No | `null` | Callback when collapse state changes |

### Static Methods

#### `extractMessages()`

Extracts and normalizes messages from API response.

```dart
List<ResponseMessage> messages = 
  ResponseMessagesCard.extractMessages(response);
```

**Returns:** List of `ResponseMessage` objects

#### `extractStatistics()`

Extracts processing statistics from API response.

```dart
ProcessingStatistics? stats = 
  ResponseMessagesCard.extractStatistics(response);
```

**Returns:** `ProcessingStatistics` object or `null` if not available

## Expected API Response Format

The component expects responses in the following format:

```json
{
  "RegistrationData": {
    "ProcessingStatistics": {
      "@Received": "1",
      "@Valid": "1",
      "@Invalid": "0",
      "@Successful": "1",
      "@Unsuccessful": "0",
      "@ProcessingTimeMs": "45"
    },
    "RegistrationSubmit": {
      "Messages": {
        "Information": [
          {"#text": "Participant updated successfully"},
          {"#text": "Changes saved to database"}
        ],
        "Warning": [
          {"#text": "Field X is deprecated"}
        ],
        "Error": [
          {"#text": "Validation failed for field Y"}
        ]
      }
    }
  }
}
```

### Message Types

- **Information** → Displayed as `info` (blue)
- **Warning** → Displayed as `warn` (orange)
- **Error** → Displayed as `error` (red)

### Message Formats

Messages can be in multiple formats:

1. **Array of objects**: `[{"#text": "message1"}, {"#text": "message2"}]`
2. **Single object**: `{"#text": "message"}`
3. **Array of strings**: `["message1", "message2"]`
4. **Single string**: `"message"`

The component handles all formats automatically.

## UI Components

### Header

- Title text (customizable)
- Message count badge
- Statistics popup button (if stats available)
- Expand/collapse toggle button

### Statistics Popup

Displays when user clicks the bar chart icon:

- Received count
- Valid count
- Invalid count
- Successful count
- Unsuccessful count
- Processing time (ms)

### Messages Table

Two-column table with:

1. **Type column** - Message type badge (info/warn/error)
2. **Message column** - Selectable message text

### Color Scheme

| Message Type | Color |
|--------------|-------|
| info | Primary theme color (blue) |
| warn | Orange (#FF6B00) |
| error | Error theme color (red) |

## Customization Examples

### Custom Title

```dart
ResponseMessagesCard(
  response: response,
  title: 'Validation Results',
)
```

### Start Collapsed

```dart
ResponseMessagesCard(
  response: response,
  initiallyCollapsed: true,
)
```

### Track Collapse State

```dart
ResponseMessagesCard(
  response: response,
  onCollapsedChanged: (collapsed) {
    // Save preference, log analytics, etc.
    SharedPreferences.setBool('messages_collapsed', collapsed);
  },
)
```

### Conditional Visibility

```dart
ResponseMessagesCard(
  response: response,
  visible: hasSubmitted && response != null,
)
```

## Integration with Form Library

The component is designed to work seamlessly with other form library components:

```dart
import 'package:flutter/material.dart' hide FormFieldBuilder;
import 'package:mpi/core/forms/forms.dart';

class MyFormScreen extends StatefulWidget {
  @override
  State<MyFormScreen> createState() => _MyFormScreenState();
}

class _MyFormScreenState extends State<MyFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late Map<String, TextEditingController> _controllers;
  late List<FormSectionConfig> _sections;
  
  Map<String, dynamic>? _response;
  bool _showResponse = false;

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

  Future<void> _submit() async {
    if (!FormControllerHelper.validateForm(_formKey)) return;
    
    final data = FormControllerHelper.getFormData(_controllers);
    final response = await ApiService.submit(data);
    
    setState(() {
      _response = response;
      _showResponse = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Response messages
            ResponseMessagesCard(
              response: _response,
              visible: _showResponse,
            ),
            
            // Form sections
            Form(
              key: _formKey,
              child: Column(
                children: _sections.map((section) {
                  return FormFieldBuilder.buildSection(
                    context: context,
                    section: section,
                    controllers: _controllers,
                  );
                }).toList(),
              ),
            ),
            
            // Submit button
            ElevatedButton(
              onPressed: _submit,
              child: Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
```

## Benefits

### Before (Duplicated Code)

```dart
// In participant_detail_screen.dart (~150 lines)
Widget _buildResponseGrid() { ... }
Widget _buildValidityResponseGrid() { ... }
Widget _buildStatRow() { ... }

// In resource_detail_screen.dart (~150 lines)
Widget _buildResponseGrid() { ... }

// In interface_detail_screen.dart (~150 lines)
Widget _buildResponseGrid() { ... }

// Total: ~450+ lines of duplicated code
```

### After (Reusable Component)

```dart
// In all screens (~5 lines each)
ResponseMessagesCard(
  response: _response,
  visible: _showResponse,
)

// Total: ~15 lines + 1 shared component (~400 lines)
// Saved: ~450 lines of duplication
```

## Best Practices

### ✅ DO

```dart
// Clear state management
Map<String, dynamic>? _response;
bool _showResponse = false;

setState(() {
  _response = apiResponse;
  _showResponse = true;
});

// Use with visible flag
ResponseMessagesCard(
  response: _response,
  visible: _showResponse,
)
```

### ✅ DO

```dart
// Provide meaningful titles
ResponseMessagesCard(
  response: _response,
  title: 'Validation Results',  // Context-specific
)
```

### ✅ DO

```dart
// Handle errors gracefully
try {
  final response = await api.submit();
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
```

### ❌ DON'T

```dart
// Don't use without visible flag
ResponseMessagesCard(response: null)  // Shows nothing but takes space
```

### ❌ DON'T

```dart
// Don't directly modify response structure
_response['RegistrationData']['Messages'] = newMessages;  // Fragile

// Instead, create new response
_response = {...};
```

### ❌ DON'T

```dart
// Don't forget to set visibility flag
setState(() {
  _response = apiResponse;
  // Missing: _showResponse = true;
});
```

## Testing

### Unit Test Example

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mpi/core/forms/response_messages_card.dart';

void main() {
  group('ResponseMessagesCard.extractMessages', () {
    test('extracts information messages', () {
      final response = {
        'RegistrationData': {
          'RegistrationSubmit': {
            'Messages': {
              'Information': [
                {'#text': 'Success'},
                {'#text': 'Complete'},
              ],
            },
          },
        },
      };

      final messages = ResponseMessagesCard.extractMessages(response);

      expect(messages.length, 2);
      expect(messages[0].type, 'info');
      expect(messages[0].message, 'Success');
      expect(messages[1].message, 'Complete');
    });

    test('handles mixed message types', () {
      final response = {
        'RegistrationData': {
          'RegistrationSubmit': {
            'Messages': {
              'Information': {'#text': 'Info'},
              'Warning': {'#text': 'Warning'},
              'Error': {'#text': 'Error'},
            },
          },
        },
      };

      final messages = ResponseMessagesCard.extractMessages(response);

      expect(messages.length, 3);
      expect(messages.any((m) => m.type == 'info'), true);
      expect(messages.any((m) => m.type == 'warn'), true);
      expect(messages.any((m) => m.type == 'error'), true);
    });

    test('returns empty list for null response', () {
      final messages = ResponseMessagesCard.extractMessages(null);
      expect(messages, isEmpty);
    });
  });

  group('ResponseMessagesCard.extractStatistics', () {
    test('extracts processing statistics', () {
      final response = {
        'RegistrationData': {
          'ProcessingStatistics': {
            '@Received': '10',
            '@Valid': '8',
            '@Successful': '7',
          },
        },
      };

      final stats = ResponseMessagesCard.extractStatistics(response);

      expect(stats, isNotNull);
      expect(stats!.received, '10');
      expect(stats.valid, '8');
      expect(stats.successful, '7');
    });

    test('returns null for missing statistics', () {
      final stats = ResponseMessagesCard.extractStatistics({});
      expect(stats, isNull);
    });
  });
}
```

### Widget Test Example

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mpi/core/forms/response_messages_card.dart';

void main() {
  testWidgets('displays messages', (tester) async {
    final response = {
      'RegistrationData': {
        'RegistrationSubmit': {
          'Messages': {
            'Information': {'#text': 'Test message'},
          },
        },
      },
    };

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ResponseMessagesCard(
            response: response,
            visible: true,
          ),
        ),
      ),
    );

    expect(find.text('Messages'), findsOneWidget);
    expect(find.text('Test message'), findsOneWidget);
  });

  testWidgets('can be collapsed and expanded', (tester) async {
    final response = {
      'RegistrationData': {
        'RegistrationSubmit': {
          'Messages': {
            'Information': {'#text': 'Test'},
          },
        },
      },
    };

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ResponseMessagesCard(
            response: response,
            visible: true,
          ),
        ),
      ),
    );

    // Initially expanded
    expect(find.text('Test'), findsOneWidget);

    // Collapse
    await tester.tap(find.byIcon(Icons.expand_less));
    await tester.pumpAndSettle();
    expect(find.text('Test'), findsNothing);

    // Expand
    await tester.tap(find.byIcon(Icons.expand_more));
    await tester.pumpAndSettle();
    expect(find.text('Test'), findsOneWidget);
  });
}
```

## Troubleshooting

### Issue: Messages not showing

**Solution:** Check that:
1. `visible` is set to `true`
2. `response` is not `null`
3. Response has correct structure
4. Messages are not empty strings

```dart
// Debug
debugPrint('Response: $_response');
debugPrint('Visible: $_showResponse');
final messages = ResponseMessagesCard.extractMessages(_response);
debugPrint('Extracted messages: ${messages.length}');
```

### Issue: Statistics not appearing

**Solution:** Ensure `ProcessingStatistics` is in response:

```dart
final stats = ResponseMessagesCard.extractStatistics(_response);
if (stats == null) {
  debugPrint('No statistics in response');
  debugPrint('Response structure: ${_response?.keys}');
}
```

### Issue: Wrong message colors

**Solution:** Check message type mapping:

```dart
// Messages should be categorized as:
// 'Information' → 'info' (blue)
// 'Warning' → 'warn' (orange)
// 'Error' → 'error' (red)
```

## Migration Guide

### From Old Code

**Before:**
```dart
// participant_detail_screen.dart
Widget _buildResponseGrid() {
  if (!_showResponse || _submissionResponse == null) 
    return SizedBox.shrink();
  
  // 150+ lines of code...
  return Card(...);
}
```

**After:**
```dart
ResponseMessagesCard(
  response: _submissionResponse,
  visible: _showResponse,
  title: 'Messages',
)
```

### Migration Steps

1. **Add import**
   ```dart
   import 'package:mpi/core/forms/forms.dart';
   ```

2. **Add state variables** (if not present)
   ```dart
   Map<String, dynamic>? _response;
   bool _showResponse = false;
   ```

3. **Replace custom message widget**
   ```dart
   // Delete _buildResponseGrid() method
   
   // Replace with
   ResponseMessagesCard(
     response: _response,
     visible: _showResponse,
   )
   ```

4. **Update API call handler**
   ```dart
   final response = await api.submit();
   setState(() {
     _response = response;
     _showResponse = true;
   });
   ```

## Roadmap

Future enhancements:

- [ ] Add message filtering by type
- [ ] Add search functionality for messages
- [ ] Export messages to clipboard/file
- [ ] Add message timestamps
- [ ] Support custom message renderers
- [ ] Add animation options
- [ ] Support dark mode customization
- [ ] Add accessibility improvements

## Related Components

- **FormFieldBuilder** - Build form fields from configuration
- **FormControllerHelper** - Manage form controllers and validation
- **FormFieldConfig** - Define form field configurations
- **FormSectionConfig** - Group fields into sections

## Summary

The `ResponseMessagesCard` component provides a consistent, reusable way to display API response messages and statistics across your Flutter application. It eliminates code duplication, ensures consistent UX, and makes it easy to display backend feedback to users.

**Key advantages:**
- ✅ Zero code duplication
- ✅ Consistent UI/UX
- ✅ Type-safe models
- ✅ Theme-aware styling
- ✅ Easy integration
- ✅ Comprehensive features

For questions or contributions, see the main forms library documentation.
