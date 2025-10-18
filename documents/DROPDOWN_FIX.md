# Fix: Dropdown Value Mismatch Error

## Error
```
There should be exactly one item with [DropdownButton]'s value: 1. 
Either zero or 2 or more [DropdownMenuItem]s were detected with the same value
```

## Root Cause

The `ThermalType` dropdown had a value mismatch:
- **API returns:** `"1"` (from resourceSubmit.json)
- **Dropdown expected:** `"01"`, `"02"`, `"03"`, etc.

When the screen tried to initialize with `_selectedThermalType = "1"`, the dropdown couldn't find a matching item because all items had values like `"01"`, `"02"`, etc.

## API Data Values

```json
{
  "Area": "03",           // ✅ Matches dropdown (01-10)
  "ResourceType": "01",   // ✅ Matches dropdown (01-07)
  "ThermalType": "1"      // ❌ Didn't match dropdown (was 01-05)
}
```

## Solution

Updated the `_getThermalTypeOptions()` method to use single-digit values matching the API response:

### Before (Broken)
```dart
List<DropdownMenuItem<String>> _getThermalTypeOptions() {
  return [
    const DropdownMenuItem(value: '01', child: Text('Coal')),
    const DropdownMenuItem(value: '02', child: Text('Oil')),
    const DropdownMenuItem(value: '03', child: Text('LNG')),
    const DropdownMenuItem(value: '04', child: Text('Nuclear')),
    const DropdownMenuItem(value: '05', child: Text('Other')),
  ];
}
```

### After (Fixed)
```dart
List<DropdownMenuItem<String>> _getThermalTypeOptions() {
  return [
    const DropdownMenuItem(value: '1', child: Text('Coal')),
    const DropdownMenuItem(value: '2', child: Text('Oil')),
    const DropdownMenuItem(value: '3', child: Text('LNG')),
    const DropdownMenuItem(value: '4', child: Text('Nuclear')),
    const DropdownMenuItem(value: '5', child: Text('Other')),
  ];
}
```

## File Changed
- `lib/app/dashboard/resource_detail_screen.dart`

## Verification

All dropdown values now match the API response:

| Field | API Value | Dropdown Values | Status |
|-------|-----------|-----------------|--------|
| Area | "03" | "01"-"10" | ✅ Match |
| ResourceType | "01" | "01"-"07" | ✅ Match |
| ThermalType | "1" | "1"-"5" | ✅ Match (Fixed) |

## Testing

The screen should now load without errors when:
1. Clicking "View Full Details" button on a resource
2. API returns data with ThermalType = "1"
3. Dropdown initializes with the correct value
4. No assertion errors

## Status
✅ **FIXED** - Dropdown values now match API response format
