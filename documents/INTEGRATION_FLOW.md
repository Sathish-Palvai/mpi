# Resource Detail Integration Flow

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         USER INTERACTION FLOW                            │
└─────────────────────────────────────────────────────────────────────────┘

1. User clicks on Dashboard
         │
         ▼
2. Selects "Resources" Tab
         │
         ▼
3. Views Resource List (from resources.json)
   ┌────────────────────────────────────┐
   │  📋 RESOURCE1 - VPP_DEM           │
   │  📋 RESOURCE2 - BATTERY            │
   │  📋 RESOURCE3 - VPP_DEM            │
   └────────────────────────────────────┘
         │
         ▼
4. Clicks on a Resource Card
         │
         ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                          BACKEND API CALL                                │
└─────────────────────────────────────────────────────────────────────────┘

Frontend (resource_tab.dart)
    ↓
    │ HTTP GET Request
    │ http://localhost:3000/api/resources/detail/RESOURCE1
    │
    ▼
Backend (routes/resources.js)
    ↓
    │ 1. Receive request
    │ 2. Load resourceSubmit.json
    │ 3. Extract Resource object
    │ 4. Update ResourceName to match request
    │
    ▼
Response JSON:
{
  "success": true,
  "data": {
    "ParticipantName": "D001",
    "ResourceName": "RESOURCE1",
    "ResourceType": "01",
    "Area": "03",
    "SystemCode": "SYSC1",
    ... (50+ fields)
    "OutputBand": {...},
    "SwitchOutput": {...},
    "StartupPattern": {...},
    "StopPattern": {...}
  },
  "messages": {...},
  "processingStats": {...}
}

┌─────────────────────────────────────────────────────────────────────────┐
│                        FRONTEND PROCESSING                               │
└─────────────────────────────────────────────────────────────────────────┘

resource_tab.dart
    ↓
    │ 1. Parse JSON response
    │ 2. Check success status
    │ 3. Extract data object
    │
    ▼
context.push('/resource-detail', extra: data)
    ↓
main.dart (Router)
    ↓
    │ Route: /resource-detail
    │ Widget: ResourceDetailScreen
    │ Props: resource = data
    │
    ▼
resource_detail_screen.dart
    ↓
    │ initState()
    │   ↓
    │   _initializeTabController()
    │   _initializeFields()
    │       ↓
    │       - Set all TextEditingControllers
    │       - Set dropdown values
    │       - Set state variables
    │
    ▼
build()
    ↓
    │ Scaffold with:
    │  - AppBar (title, back button, notifications)
    │  - Body (Stepper with multiple tabs)
    │      ↓
    │      Tab 0: General Details
    │          - Key Fields Section
    │          - Basic Information Section
    │          - Technical Specifications Section
    │          - Output Parameters Section
    │          - Contact Information Section
    │      
    │      Tab 1: Output Band (if ResourceType = 01/02/03)
    │      Tab 2: Switch Output (if ResourceType = 01/02/03)
    │      Tab 3: AFC (if ResourceType = 01/02/03)
    │      Tab 4: Startup Pattern (if ResourceType = 01/02/03)
    │      Tab 5: Stop Pattern (if ResourceType = 01/02/03)
    │
    ▼
DISPLAY POPULATED FORM

┌─────────────────────────────────────────────────────────────────────────┐
│                         DATA STRUCTURE MAPPING                           │
└─────────────────────────────────────────────────────────────────────────┘

API Response Field          →    UI Controller/Widget
─────────────────────────────────────────────────────────────────────────
ParticipantName             →    _participantNameController
ResourceName                →    _resourceNameController
SystemCode                  →    _systemCodeController
ResourceShortName           →    _resourceShortNameController
ResourceLongName            →    _resourceLongNameController
BgCode                      →    _bgCodeController
StartDate                   →    _startDateController
EndDate                     →    _endDateController
Area                        →    _selectedArea (Dropdown)
ResourceType                →    _selectedResourceType (Dropdown)
ThermalType                 →    _selectedThermalType (Dropdown)
ContractType                →    _selectedContractType (Dropdown)
ModelName                   →    _modelNameController
RatedCapacity               →    _ratedCapacityController
RatedVoltage                →    _ratedVoltageController
Frequency                   →    _frequencyController
RatedOutput                 →    _ratedOutputController
MinimumOutput               →    _minimumOutputController
AuthorizedMaximumOutput     →    _authorizedMaximumOutputController
AfcMinimumOutput            →    _afcMinimumOutputController
Address                     →    _addressController
PayeePhonePart1/2/3         →    _phonePart1/2/3Controller
OutputBand                  →    [Future: Grid Component]
SwitchOutput                →    [Future: Grid Component]
StartupPattern              →    [Future: Grid Component]
StopPattern                 →    [Future: Grid Component]

┌─────────────────────────────────────────────────────────────────────────┐
│                            FILE CHANGES                                  │
└─────────────────────────────────────────────────────────────────────────┘

NEW/MODIFIED FILES:

backend/routes/resources.js
    + loadResourceDetail() function
    + GET /api/resources/detail/:resourceName endpoint

lib/app/dashboard/widgets/resource_tab.dart
    + import go_router, http, dart:convert
    + InkWell wrapper on ExpansionTile
    + _navigateToResourceDetail() method
    + _showErrorSnackBar() method

lib/main.dart
    + import resource_detail_screen.dart
    + GoRoute('/resource-detail') with state.extra

lib/app/dashboard/resource_detail_screen.dart
    [Already existed, uses data from widget.resource]
    + _selectedContractType field
    + initialization from widget.resource

┌─────────────────────────────────────────────────────────────────────────┐
│                          ERROR HANDLING                                  │
└─────────────────────────────────────────────────────────────────────────┘

Scenario                        Action
─────────────────────────────────────────────────────────────────────────
API Request Fails              → Show red SnackBar with error message
                               → Close loading indicator
                               → Stay on current screen

Invalid Response               → Show "Failed to load resource details"
                               → Close loading indicator

Network Timeout                → Show "Error: <exception message>"
                               → Close loading indicator

Server Error (500)             → Show "Server error: 500"
                               → Close loading indicator

Resource Not Found (404)       → Backend returns 404 JSON response
                               → Frontend shows error message

┌─────────────────────────────────────────────────────────────────────────┐
│                      CONDITIONAL UI LOGIC                                │
└─────────────────────────────────────────────────────────────────────────┘

Tab Visibility Rules:
─────────────────────────────────────────────────────────────────────────
if ResourceType = '01' (THERMAL)     → Show all 6 tabs
if ResourceType = '02' (PUMP)        → Show all 6 tabs
if ResourceType = '03' (HYDRO)       → Show all 6 tabs
if ResourceType = '04' (BATTERY)     → Show only General Details tab
if ResourceType = '05' (VPP)         → Show only General Details tab
if ResourceType = '06' (OPSI)        → Show only General Details tab
if ResourceType = '07' (DSS)         → Show only General Details tab

Field Visibility Rules:
─────────────────────────────────────────────────────────────────────────
_shouldShowField('ThermalType')      → Only for THERMAL resources
_shouldShowField('RatedCapacity')    → THERMAL, PUMP, HYDRO
_shouldShowField('RatedVoltage')     → THERMAL, PUMP, HYDRO
_shouldShowField('Frequency')        → THERMAL, PUMP, HYDRO
_shouldShowField('RatedOutput')      → THERMAL, PUMP, HYDRO

┌─────────────────────────────────────────────────────────────────────────┐
│                        TESTING SCENARIOS                                 │
└─────────────────────────────────────────────────────────────────────────┘

✅ Happy Path:
   1. Backend running on port 3000
   2. User clicks RESOURCE1
   3. API call succeeds
   4. Navigation happens
   5. Screen displays with all fields populated
   6. Back button returns to dashboard

❌ Error Path:
   1. Backend is down
   2. User clicks resource
   3. Loading indicator shows
   4. API call fails after timeout
   5. Error SnackBar appears
   6. User stays on resources list

⚠️  Edge Cases:
   - Empty resource name → Backend handles gracefully
   - Missing fields in response → Controllers default to empty
   - Invalid ResourceType → Defaults to showing only General Details

┌─────────────────────────────────────────────────────────────────────────┐
│                          FUTURE ENHANCEMENTS                             │
└─────────────────────────────────────────────────────────────────────────┘

1. DATABASE INTEGRATION
   - Create resources table in SQLite
   - Seed with actual resource data
   - Update API to query database

2. GRID COMPONENTS
   - Implement OutputBand grid (add/edit/delete rows)
   - Implement SwitchOutput grid
   - Implement AFC grid
   - Implement Startup/Stop Pattern grids

3. FORM SUBMISSION
   - Implement save button functionality
   - POST updated data to backend
   - Update database
   - Show success/error messages

4. FIELD VALIDATION
   - Implement complex validation rules
   - Area-specific validation (OKINAWA vs NON-OKINAWA)
   - Contract-type-specific validation
   - Cross-field validation

5. ADVANCED FEATURES
   - Query resource by different criteria
   - Real-time updates via WebSocket
   - Export resource data
   - Resource history/audit log
