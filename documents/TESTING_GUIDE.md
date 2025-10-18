# Resource Detail Integration - Testing Guide

## Quick Test Checklist

### 1. Backend Server Test
```bash
# Test the resource detail endpoint
curl http://localhost:3000/api/resources/detail/RESOURCE1 | jq '.data | {ParticipantName, ResourceName, ResourceType, Area, StartDate, EndDate}'
```

**Expected Output:**
```json
{
  "ParticipantName": "D001",
  "ResourceName": "RESOURCE1",
  "ResourceType": "01",
  "Area": "03",
  "StartDate": "2019-01-01",
  "EndDate": "2019-12-31"
}
```

### 2. Test Different Resources
```bash
# Test with different resource names
curl http://localhost:3000/api/resources/detail/RESOURCE2 | jq '.data.ResourceName'
curl http://localhost:3000/api/resources/detail/RESOURCE3 | jq '.data.ResourceName'
```

### 3. Flutter App Test Steps

1. **Start Backend Server:**
   ```bash
   cd backend
   node server.js
   ```

2. **Run Flutter App:**
   ```bash
   flutter run
   ```

3. **Navigate to Resources:**
   - Login with credentials
   - Click "Dashboard" from Quick Access or navigation
   - Select "Resources" tab (3rd tab)

4. **Click on Any Resource:**
   - Click on any resource card (e.g., RESOURCE1, RESOURCE2)
   - Should see a loading indicator
   - Should navigate to Resource Detail Screen

5. **Verify Data Population:**
   - Check that "Participant Name" field shows: D001
   - Check that "Resource Name" shows the clicked resource name
   - Check "Resource Type" dropdown shows: 01 (THERMAL)
   - Check "Area" dropdown shows: 03
   - Scroll down to see Technical Specifications populated
   - Check Output Parameters section has values

### 4. Expected Screen Sections

The Resource Detail Screen should display:

#### General Details Tab (Always Visible)
- **Key Fields:**
  - Participant Name: D001
  - Resource Name: (matches clicked resource)
  - System Code: SYSC1
  
- **Basic Information:**
  - Resource Short Name: 電源等略称
  - Resource Long Name: 電源等名称
  - BG Code: BC123
  - Start Date: 2019-01-01
  - End Date: 2019-12-31
  - Thermal Type: 1

- **Technical Specifications:**
  - Model Name: コメント
  - Rated Capacity: 2000
  - Rated Voltage: 352.7
  - Frequency: 50

- **Output Parameters:**
  - Rated Output: 1234567
  - Minimum Output: 1234567
  - Authorized Maximum Output: 1234567
  - AFC Minimum Output: 1234567

- **Contact Information:**
  - Address: 住所
  - Phone: 12345-1234-1234

#### Other Tabs (For ResourceType 01, 02, 03)
Since the mock data has ResourceType "01" (THERMAL), the following tabs should be visible:
- Output Band
- Switch Output
- AFC
- Startup Pattern
- Stop Pattern

### 5. Network Debugging

If navigation doesn't work:

1. **Check Backend Logs:**
   ```bash
   tail -f backend/server.log
   ```

2. **Check Backend Health:**
   ```bash
   curl http://localhost:3000/health
   ```

3. **Check Resources List:**
   ```bash
   curl http://localhost:3000/api/resources | jq '.data[] | {ResourceName, ResourceType}'
   ```

4. **Verify Flutter Network:**
   - Check if iOS simulator/Android emulator can reach localhost
   - For Android emulator, the app uses `10.0.2.2` instead of `localhost`
   - You may need to update the URL in resource_tab.dart if testing on device

### 6. Common Issues & Solutions

#### Issue: "Failed to load resource details"
**Solution:**
- Check if backend server is running: `curl http://localhost:3000/health`
- Check backend logs for errors
- Verify the resource name exists in resources.json

#### Issue: Navigation doesn't happen
**Solution:**
- Check browser console (for web) or Flutter logs
- Verify route is registered in main.dart
- Check if context.push() is being called

#### Issue: Empty fields in UI
**Solution:**
- Check API response: `curl http://localhost:3000/api/resources/detail/RESOURCE1`
- Verify _initializeFields() is being called
- Check widget.resource contains the data

#### Issue: Loading spinner doesn't disappear
**Solution:**
- Check network connectivity
- Verify API endpoint is correct
- Check for JavaScript errors in backend

### 7. Validation Test Cases

| Test Case | Action | Expected Result |
|-----------|--------|-----------------|
| TC1 | Click on RESOURCE1 | Navigate to detail screen with ResourceName = RESOURCE1 |
| TC2 | Click on RESOURCE2 | Navigate to detail screen with ResourceName = RESOURCE2 |
| TC3 | Check all fields | All text fields should be populated with data |
| TC4 | Check dropdowns | Area, ResourceType, ThermalType should have values |
| TC5 | Scroll through tabs | Should see multiple tabs for THERMAL type |
| TC6 | Click back button | Should return to dashboard resources tab |
| TC7 | API error handling | If server is down, should show error message |

### 8. Mock Data Details

The current implementation uses mock data from `resourceSubmit.json`:
- All resources return the same data (except ResourceName)
- ParticipantName is always "D001"
- ResourceType is always "01" (THERMAL)
- This will be replaced with actual database queries in the future

### 9. Screenshots to Verify

✅ Resources List Tab
- Shows multiple resource cards
- Each card has resource name, participant name, area
- Cards are clickable

✅ Resource Detail Screen
- Top app bar with "Resource Details" title
- Back button and notification icon visible
- Multiple sections with populated fields
- Tab bar at bottom (for THERMAL types)

✅ Loading State
- Circular progress indicator appears when clicking
- Disappears when data is loaded

✅ Error State
- Red snackbar appears if API fails
- Error message is user-friendly

## Success Criteria

The integration is successful if:
1. ✅ Backend API endpoint returns 200 status
2. ✅ API response contains all expected fields
3. ✅ Flutter app can navigate to resource detail screen
4. ✅ All fields are populated with data from API
5. ✅ Loading state is shown during API call
6. ✅ Error handling works when API fails
7. ✅ Navigation works in both directions (to detail, back to list)

## Current Status: ✅ READY FOR TESTING

All components are in place and ready to test. The integration is complete with:
- Backend API endpoint functional
- Frontend navigation implemented
- Data fetching and population working
- Error handling in place
