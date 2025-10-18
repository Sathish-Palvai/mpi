/**
 * ROUTE CONFIGURATION FOR CONFIG-DRIVEN PARTICIPANT SCREEN
 * 
 * Add this route to your main.dart _createRouter() method
 */

// 1. Import the new screen (updated path)
import 'app/dashboard/config_driven_forms/config_driven_participant_screen.dart';

// 2. Add this route after the existing '/participant/:id' route

GoRoute(
  path: '/participant-config/:id',
  builder: (BuildContext context, GoRouterState state) {
    final id = state.pathParameters['id'];
    
    // Get participant data from your state or API
    // This is just an example - adjust based on your actual data source
    final participantData = {
      'id': id,
      'ParticipantName': id, // or fetch from somewhere
      'ParticipantType': 'BALANCING_SERVICE_PROVIDER',
      'StartDate': '2025-01-01',
      'CompanyShortName': 'Example Co',
      'CompanyLongName': 'Example Company Limited',
      'PhonePart1': '03',
      'PhonePart2': '1234',
      'PhonePart3': '5678',
    };
    
    return ConfigDrivenParticipantScreen(
      participant: participantData,
    );
  },
),

/**
 * ALTERNATIVE: If you want to test with empty/new participant
 */
GoRoute(
  path: '/participant-config-new',
  builder: (BuildContext context, GoRouterState state) {
    return const ConfigDrivenParticipantScreen(
      participant: {
        'ParticipantType': 'BALANCING_SERVICE_PROVIDER',
      },
    );
  },
),

/**
 * HOW TO NAVIGATE TO THE CONFIG SCREEN
 * 
 * From anywhere in your app:
 */

// Using context.go (replaces current screen)
context.go('/participant-config/TEST');

// Using context.push (adds to navigation stack)
context.push('/participant-config/TEST');

// Using Navigator
Navigator.of(context).push(
  MaterialPageRoute(
    builder: (context) => ConfigDrivenParticipantScreen(
      participant: {'ParticipantName': 'TEST'},
    ),
  ),
);

/**
 * TESTING THE SCREEN
 * 
 * Quick test steps:
 * 1. Add the route above to main.dart
 * 2. Hot restart your app (hot reload won't pick up route changes)
 * 3. Navigate to: /participant-config-new
 * 4. You should see the config-driven form
 */

/**
 * COMPARISON WITH ORIGINAL SCREEN
 * 
 * Original screen:  /participant/:id
 * Config screen:    /participant-config/:id
 * 
 * Both screens do the same thing, but config-driven is:
 * - More maintainable
 * - Easier to extend
 * - More consistent
 * - DRY (Don't Repeat Yourself)
 */
