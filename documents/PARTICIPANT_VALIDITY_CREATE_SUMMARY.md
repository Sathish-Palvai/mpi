# Participant Validity Create Screen - Implementation Summary

## Overview
Created a new participant validity create screen following the same pattern as the participant_create_screen, using the config-driven forms library.

## Files Created

### 1. Schema Definition
**File:** `lib/app/dashboard/forms/participant_validity/schemas/participant_validity_create_schema.dart`

**Fields Configured:**
- `ParticipantName` (text, readonly, required, 1-10 chars)
- `ParticipantState` (text, readonly, required) 
- `StartDate` (date, required, 10 chars)
- `TransactionId` (text, readonly, hidden, optional, 2-10 chars)

**Key Features:**
- Uses config-driven forms pattern
- Declarative field definitions with validation
- Translation-ready labels using easy_localization

### 2. Create Screen
**File:** `lib/app/dashboard/forms/participant_validity/participant_validity_create_screen.dart`

**Features:**
- Accepts optional `participantName` parameter for pre-filling
- Form validation using FormControllerHelper
- Auto-fills `ParticipantState` to 'REGISTERED' by default
- ResponseMessagesCard for displaying submission results
- Reset and Create buttons
- Dashboard data refresh on successful creation
- Error handling with user feedback

**API Integration:**
- Endpoint: `POST /participants/validity`
- Payload structure:
```json
{
  "RegistrationData": {
    "RegistrationSubmit": {
      "ParticipantValidity": {
        "ParticipantName": "...",
        "ParticipantState": "REGISTERED",
        "StartDate": "..."
      }
    }
  }
}
```

**UI Components:**
- AppBar with back navigation and notification icon
- AppDrawer for navigation
- Card layout with blue header matching app theme
- Form fields built using FormFieldBuilder
- Action buttons (Reset, Create)
- Loading states during submission
- ResponseMessagesCard for transaction feedback

### 3. Export File Update
**File:** `lib/app/dashboard/forms/participant_validity/participant_validity.dart`

Added exports:
- `participant_validity_create_screen.dart`
- `schemas/participant_validity_create_schema.dart`

### 4. Translations

#### English (en.json)
Added:
- `participantValidity.header.newTitle`: "Add New Participant Validity"
- `participantValidity.placeholders.ParticipantName`: "Auto-generated"
- `participantValidity.placeholders.ParticipantState`: "Default: REGISTERED"

#### Spanish (es.json)
Added complete `participantValidity` section with:
- Header translations
- Grid column labels
- Placeholder text
- RegistrationQuery fields
- RegistrationSubmit fields

## Field Mapping (JSON to Schema)

Based on the provided JSON structure:

| JSON Property | Schema Field | Type | Required | Readonly |
|--------------|--------------|------|----------|----------|
| ParticipantName | ParticipantName | text | Yes | Yes |
| ParticipantState | ParticipantState | text | Yes | Yes |
| StartDate | StartDate | date | Yes | No |
| TransactionId | TransactionId | text | No | Yes |

## Usage

### Navigation
The screen can be accessed by navigating to the route (needs to be added to routing configuration):

```dart
context.go('/participant-validity/create');
```

### With Participant Name Pre-filled
```dart
ParticipantValidityCreateScreen(
  participantName: 'D027',
)
```

### Standalone
```dart
ParticipantValidityCreateScreen()
```

## Design Patterns Used

1. **Config-Driven Forms**: All fields defined declaratively in schema
2. **BLoC Pattern**: Dashboard refresh using DashboardBloc
3. **Repository Pattern**: API calls through ApiService
4. **Responsive Layout**: Flex-based field sizing
5. **State Management**: Local state with setState
6. **Error Handling**: Try-catch with user feedback
7. **Internationalization**: easy_localization for translations

## Next Steps

To complete the integration:

1. **Add Route**: Add route configuration in router
2. **Backend Endpoint**: Ensure `POST /participants/validity` endpoint exists
3. **Navigation Link**: Add "Create Validity" button in appropriate screens
4. **Testing**: Test form validation and submission
5. **Backend Response**: Verify backend returns TransactionId in response

## Screen Preview Structure

```
┌─────────────────────────────────────┐
│ ← Add New Participant Validity   🔔 │
├─────────────────────────────────────┤
│                                     │
│ ┌─ Messages ───────────────────┐   │
│ │ (ResponseMessagesCard)       │   │
│ └──────────────────────────────┘   │
│                                     │
│ ┌─ Participant Validity Details ─┐ │
│ │                                 │ │
│ │  Participant Name *  [D027    ]│ │
│ │  Participant State * [REGISTER]│ │
│ │                                 │ │
│ │  Start Date *        [Pick Date]│ │
│ │  Transaction Id      [Hidden  ]│ │
│ │                                 │ │
│ └─────────────────────────────────┘ │
│                                     │
│ [ Reset ]          [ Create ]       │
│                                     │
└─────────────────────────────────────┘
```

## Key Differences from Participant Create Screen

1. **Simpler Form**: Only 4 fields vs 8+ fields
2. **Pre-filled Fields**: ParticipantName and ParticipantState are readonly
3. **Different Endpoint**: Uses `/participants/validity` endpoint
4. **No Phone Fields**: Validity records don't have phone information
5. **Different Payload Structure**: Nested under ParticipantValidity key

## Validation Rules

- **ParticipantName**: 1-10 characters, readonly, required
- **ParticipantState**: Readonly, required, defaults to 'REGISTERED'
- **StartDate**: Date format (10 chars), required
- **TransactionId**: 2-10 characters, hidden, optional, readonly

## Success Flow

1. User opens create screen (optionally with participant name)
2. User fills in StartDate (other fields pre-filled)
3. User clicks Create button
4. Form validates
5. API POST request sent
6. Backend returns response with TransactionId
7. ResponseMessagesCard displays success message
8. Dashboard data refreshed
9. Success snackbar shown

## Error Flow

1. Validation fails → Show validation errors
2. API call fails → Show error in ResponseMessagesCard
3. Network error → Show snackbar with error message
4. Backend validation → Display backend messages
