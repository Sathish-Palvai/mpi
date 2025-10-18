# Quick Reference: Grid Tabs CRUD Operations

## All Tabs Summary

| Tab | Fields | Max | Mobile View | Desktop View | Pattern Support |
|-----|--------|-----|-------------|--------------|-----------------|
| **Output Band** | 6 | 20 | Cards | Table | No |
| **Switch Output** | 2 | 20 | Cards | Table | No |
| **AFC** | 3 | 20 | Cards | Table | No |
| **Startup Pattern** | 3 events | 10 patterns<br>20 events/pattern | Cards | Table | Yes |
| **Stop Pattern** | 3 events | 10 patterns<br>20 events/pattern | Cards | Table | Yes |

## Common Features Across All Tabs

### ✅ Responsive Design
- **Breakpoint**: 768px
- **Mobile (<768px)**: Card view with icons and colored headers
- **Desktop (≥768px)**: Data table with actions column

### ✅ CRUD Operations
- **Create**: FAB (Floating Action Button) or "Add First" button
- **Read**: Formatted display with icons and labels
- **Update**: Modal dialog with pre-filled values
- **Delete**: Confirmation dialog with warning

### ✅ User Feedback
- **Success**: Green SnackBar on add/edit/delete
- **Error**: Red SnackBar on validation failure
- **Limits**: Warning chip when max reached
- **Counters**: "X of Y" display for all grids

## Tab-Specific Details

### 1. Output Band Tab
```
Fields:
├── Lower Limit (kW)          [Required, Numeric]
├── Upper Limit (kW)          [Required, Numeric]
├── Output (kW)               [Required, Numeric]
├── Minimum Operation Time    [Required, Numeric]
├── Standby Cost (¥/kW)      [Required, Numeric]
└── Startup Cost (¥/time)     [Required, Numeric]

Actions:
└── FAB (bottom-right) → Add new row (max 20)
```

### 2. Switch Output Tab
```
Fields:
├── Output (kW)               [Required, Numeric]
└── Switch Time (min)         [Required, Numeric]

Actions:
└── FAB (bottom-right) → Add new row (max 20)
```

### 3. AFC Tab
```
Fields:
├── Output (kW)                    [Required, Numeric]
├── Operation Time (min)           [Required, Numeric]
└── Output Variation Speed (kW/min) [Required, Numeric]

Actions:
└── FAB (bottom-right) → Add new row (max 20)
```

### 4. Startup Pattern Tab
```
Structure:
Pattern (max 10)
├── Pattern Name              [Required, Text]
└── Events (max 20)
    ├── Event Name            [Required, Text]
    ├── Change Time (min:sec) [Required, Format]
    └── Output (kW)           [Required, Numeric]

Actions:
├── Extended FAB (left) → Add new pattern (max 10)
├── FAB (right) → Add event to current pattern (max 20)
├── Chip icons → Edit/Delete pattern (inline)
└── Table/Card actions → Edit/Delete event
```

### 5. Stop Pattern Tab
```
Structure:
Pattern (max 10)
├── Pattern Name              [Required, Text]
└── Events (max 20)
    ├── Event Name            [Required, Text]
    ├── Change Time (min:sec) [Required, Format]
    └── Output (kW)           [Required, Numeric]

Actions:
├── Extended FAB (left) → Add new pattern (max 10)
├── FAB (right) → Add event to current pattern (max 20)
├── Chip icons → Edit/Delete pattern (inline)
└── Table/Card actions → Edit/Delete event
```

## UI Components Used

### Cards (Mobile View)
```
┌────────────────────────────────────┐
│ 🔷 Record #1              ✏️ 🗑️  │  ← Colored header
├────────────────────────────────────┤
│ ⚡ Label: Value  Unit              │
│ ──────────────────────────────────│  ← Divider
│ ⚡ Label: Value  Unit              │
│ ──────────────────────────────────│
│ ⚡ Label: Value  Unit              │
└────────────────────────────────────┘
```

### Tables (Desktop View)
```
┌─────┬──────────┬──────────┬──────────┬─────────┐
│  #  │  Field1  │  Field2  │  Field3  │ Actions │
├─────┼──────────┼──────────┼──────────┼─────────┤
│  1  │  Value   │  Value   │  Value   │  ✏️ 🗑️  │
│  2  │  Value   │  Value   │  Value   │  ✏️ 🗑️  │
└─────┴──────────┴──────────┴──────────┴─────────┘
```

### FAB Positions
```
Screen Layout:
┌────────────────────────────────────┐
│                                    │
│          Content Area              │
│                                    │
│                                    │
│                                    │
│                          ┌───────┐ │  ← Extended FAB (patterns)
│                          │Pattern│ │
│                          └───────┘ │
│                                 ⊕  │  ← FAB (events/records)
└────────────────────────────────────┘
```

### Modal Dialog
```
┌──────────────────────────────────┐
│ 🔷 Add/Edit Title                │
├──────────────────────────────────┤
│ ┌──────────────────────────────┐ │
│ │ 🔷 Field 1                   │ │
│ └──────────────────────────────┘ │
│                                  │
│ ┌──────────────────────────────┐ │
│ │ 🔷 Field 2                   │ │
│ └──────────────────────────────┘ │
│                                  │
│ ┌──────────────────────────────┐ │
│ │ 🔷 Field 3                   │ │
│ └──────────────────────────────┘ │
├──────────────────────────────────┤
│              [ Cancel ] [ Save ] │
└──────────────────────────────────┘
```

## Validation Rules

### Numeric Fields
- **Required**: Cannot be empty
- **Format**: Must be a valid number
- **Feedback**: Red text below field on error

### Text Fields
- **Required**: Cannot be empty
- **Format**: Any text accepted
- **Feedback**: Red text below field on error

### Time Fields (min:sec)
- **Required**: Cannot be empty
- **Format**: Hint text shows "e.g., 5:30"
- **Validation**: Text format (not strictly enforced)

## Empty States

### Grid Tabs (Output Band, Switch Output, AFC)
```
      🔘
   No data available
   ─────────────────
   [ Add First Record ]
```

### Pattern Tabs (Startup, Stop)
```
When no patterns:
      🔘
No patterns available
   ─────────────────
   [ Add First Pattern ]

When pattern has no events:
      📝
No events in this pattern
   ─────────────────
   [ Add First Event ]
```

## Keyboard Shortcuts
- **Tab**: Navigate between form fields
- **Enter**: Submit form (when focused on last field)
- **Escape**: Close dialog (when supported by platform)

## Color Coding

| Component | Color | Usage |
|-----------|-------|-------|
| Primary | Blue | Output Band, Switch Output, AFC headers |
| Secondary | Purple | Startup Pattern events |
| Error | Red | Stop Pattern events |
| Success | Green | Success messages |
| Warning | Orange | Max limit warnings, delete confirmations |
| Grey | Grey | Empty states, disabled states |

## Best Practices for Users

### Adding Records
1. Click FAB or "Add First" button
2. Fill all required fields
3. Click "Save"
4. Verify success message

### Editing Records
1. Click edit icon (✏️) on card or table row
2. Modify fields as needed
3. Click "Save"
4. Verify success message

### Deleting Records
1. Click delete icon (🗑️) on card or table row
2. Confirm deletion in dialog
3. Click "Delete"
4. Verify success message

### Pattern Management
1. **Select Pattern**: Click FilterChip
2. **Edit Pattern Name**: Click edit icon on selected chip
3. **Delete Pattern**: Click close icon on selected chip
4. **Add Pattern**: Click extended FAB
5. **Manage Events**: Use right FAB or table actions

---

**Quick Tip**: On mobile, swipe through cards. On desktop, use table sorting (if implemented).
