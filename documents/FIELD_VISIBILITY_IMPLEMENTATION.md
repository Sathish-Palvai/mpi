# Resource Detail Screen Improvements - COMPLETED

## Summary of Changes

Implemented proper field visibility logic based on `en.json` THERMAL controlParams and added ContractType to the key fields section.

## Changes Made

### 1. Added Contract Type to Key Fields ✅

**Location:** Key Fields Section

**Before:** Only showed ParticipantName, ResourceName, Area, and ResourceType

**After:** Now includes ContractType dropdown

```dart
DropdownButtonFormField<String>(
  value: _selectedContractType,
  decoration: _inputDecoration(labelText: 'Contract Type *'),
  items: _getContractTypeOptions(),
  onChanged: (value) {
    setState(() {
      _selectedContractType = value;
    });
  },
  validator: (value) =>
      value == null ? 'Contract type is required' : null,
),
```

**Contract Type Options:**
- 1 = Market
- 2 = Power Supply I
- 3 = Only Power Supply I
- 4 = Power Supply II
- 5 = Power Supply III

### 2. Implemented THERMAL controlParams Logic ✅

**File:** `lib/app/dashboard/resource_detail_screen.dart`

Created `_getThermalControlParams()` method with all field visibility rules from `en.json`:

```dart
Map<String, int> _getThermalControlParams() {
  return {
    'ParticipantName': 1,     // Required
    'ResourceName': 1,         // Required
    'Area': 1,                 // Required
    'StartDate': 1,            // Required
    'EndDate': 0,              // Optional
    'SystemCode': 1,           // Required
    'ResourceShortName': 1,    // Required
    'ResourceLongName': 1,     // Required
    'BgCode': 1,               // Required
    'ModelName': 0,            // Optional
    'RatedCapacity': 1,        // Required
    'RatedVoltage': 1,         // Required
    'ContinuousOperationVoltage': 1,  // Required
    'RatedPowerFactor': 1,     // Required
    'Frequency': 1,            // Required
    'InPlantRate': 1,          // Required
    // ... (50+ more fields)
    'BatteryCapacity': -1,     // Hidden for THERMAL
    'PumpCharging': -1,        // Hidden for THERMAL
    // etc.
  };
}
```

**Visibility Rules:**
- `-1` = Hidden (don't show the field)
- `0` = Optional (show but not required)
- `1` = Required (show with asterisk *)

### 3. Updated Field Visibility Logic ✅

**Updated Methods:**

#### `_shouldShowField(String fieldName)`
```dart
bool _shouldShowField(String fieldName) {
  if (_selectedResourceType == null) return true;
  
  final thermalControlParams = _getThermalControlParams();
  final visibility = thermalControlParams[fieldName];
  
  if (visibility == null) return true;
  
  // Hide field if visibility is -1
  return visibility != -1;
}
```

#### `_isFieldRequired(String fieldName)`
```dart
bool _isFieldRequired(String fieldName) {
  if (_selectedResourceType == null) return false;
  
  final thermalControlParams = _getThermalControlParams();
  final visibility = thermalControlParams[fieldName];
  
  // Field is required if visibility is 1
  return visibility == 1;
}
```

### 4. Enhanced Technical Specifications Section ✅

Added more fields with proper visibility control:

**Fields Now Included:**
- ✅ Model Name (Optional)
- ✅ Rated Capacity (Required for THERMAL)
- ✅ Rated Voltage (Required for THERMAL)
- ✅ **Continuous Operation Voltage (NEW)** (Required for THERMAL)
- ✅ **Rated Power Factor (NEW)** (Required for THERMAL)
- ✅ Frequency (Required for THERMAL)
- ✅ **In-Plant Rate (NEW)** (Required for THERMAL)

**Fields Hidden for THERMAL:**
- ❌ Battery Capacity (visibility = -1)
- ❌ Pump Charging (visibility = -1)
- ❌ Variable Speed Operation (visibility = -1)
- ❌ Phase Modifying Operation (visibility = -1)
- ❌ And other non-THERMAL specific fields

### 5. Dynamic Field Labels ✅

All fields now show dynamic labels based on requirement status:

```dart
decoration: _inputDecoration(
  labelText: 'Rated Capacity${_isFieldRequired('RatedCapacity') ? ' *' : ''}',
  hintText: 'kW',
),
```

- Required fields show with `*`
- Optional fields show without `*`
- Hidden fields don't show at all

## Field Visibility for THERMAL Resources

Based on `en.json` THERMAL controlParams:

### ✅ Visible & Required (value = 1)
- Participant Name
- Resource Name
- Area
- Start Date
- System Code
- Resource Short Name
- Resource Long Name
- BG Code
- Rated Capacity
- Rated Voltage
- Continuous Operation Voltage
- Rated Power Factor
- Frequency
- In-Plant Rate
- Continuous Operation Frequency (Lower/Upper)
- Black Start
- Rated Output
- Minimum Output
- Authorized Maximum Output
- Thermal Type
- FCB Operation
- Over Power Operation
- Peak Mode Operation
- DSS
- Operation Time
- Number Of Startups
- AFC Minimum Output
- Address
- Phone Parts (1, 2, 3)

### ⚪ Visible & Optional (value = 0)
- End Date
- Model Name
- Continuous Operation Time Limited
- Over Power Operation Maximum Output
- Peak Mode Operation Maximum Output
- GF Variation Rate
- Dead Band
- Frequency Measurement Interval/Error
- Delay Time
- GF Width Out Of Rated Output
- VEN ID
- Market Context

### ❌ Hidden (value = -1)
- Battery Capacity
- Pump Charging
- Variable Speed Operation
- Discharging Output/Time
- Charging Output/Time
- Full Power Generation Time
- Continuous Operation Time
- Phase Modifying Operation
- Amount Of Water Used
- Reservoir Capacity
- Inflow Amount
- Continuous Operation Output
- Pumped Supply
- Baseline Setting Method

## Testing

### Test Scenario 1: THERMAL Resource Display
1. Navigate to Dashboard → Resources
2. Expand any resource
3. Click "View Full Details"
4. Verify:
   - ✅ Contract Type dropdown visible in Key Fields
   - ✅ Only THERMAL-appropriate fields are shown
   - ✅ Required fields marked with *
   - ✅ Optional fields shown without *
   - ✅ Battery/Pump specific fields are hidden
   - ✅ All visible fields populate from API data

### Test Scenario 2: Field Validation
1. Try to save without filling required fields
2. Verify validation errors appear for required fields only
3. Optional fields can be left empty

### API Data Structure

From `resourceSubmit.json`:
```json
{
  "ContractType": "1",
  "ThermalType": "1",
  "RatedCapacity": "2000",
  "RatedVoltage": "352.7",
  "ContinuousOperationVoltage": "16",
  "RatedPowerFactor": "10.3",
  "Frequency": "50",
  "InPlantRate": "所内率",
  ...
}
```

## Benefits

✅ **Accurate Field Visibility**: Only shows fields relevant to THERMAL resources
✅ **Better UX**: Users don't see irrelevant fields for battery, pump, etc.
✅ **Proper Validation**: Required fields enforce validation, optional don't
✅ **Maintainable**: Easy to add HYDRO, PUMP, VPP controlParams in the future
✅ **Follows Specification**: Exactly matches en.json controlParams structure

## Future Enhancements

1. **Add controlParams for other resource types:**
   - HYDRO
   - PUMP
   - VPP
   - BATTERY
   - DSS
   - OPSI

2. **Contract-type-specific visibility:**
   - Some fields may have different visibility based on ContractType
   - Implement multi-level visibility logic

3. **Area-specific rules:**
   - OKINAWA (Area='10') may have special requirements
   - Implement area-based visibility overrides

4. **Dynamic controlParams loading:**
   - Load controlParams from en.json file instead of hardcoding
   - Support runtime configuration changes

## Status

✅ **COMPLETE** - Resource detail screen now properly shows/hides fields based on THERMAL controlParams from en.json

**Files Modified:**
- `lib/app/dashboard/resource_detail_screen.dart`

**Key Methods Added:**
- `_getThermalControlParams()` - Returns THERMAL field visibility rules
- Updated `_shouldShowField()` - Uses controlParams for visibility
- Updated `_isFieldRequired()` - Uses controlParams for validation
- `_getContractTypeOptions()` - Contract type dropdown options

**Fields Added:**
- Contract Type (Key Fields)
- Continuous Operation Voltage (Technical Specs)
- Rated Power Factor (Technical Specs)
- In-Plant Rate (Technical Specs)

The resource detail screen now correctly implements the THERMAL resource type field visibility rules as specified in `en.json`! 🎉
