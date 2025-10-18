# Resource Display Implementation Analysis

## Overview
The resource display implementation consists of a multi-step stepper interface with complex dependencies between fields, tabs, and different contract types, areas, and resource types. The implementation spans multiple components working together to provide a comprehensive resource management interface.

## Core Components Structure

### 1. Main Component (`resource.component.ts`)
- **Purpose**: Entry point for resource display
- **Structure**: Split layout with read panel (left) and upsert panel (right)
- **Save Types**: Different based on participant type
  - BSP: Query, Submit, Response, QueryTemplate, SubmitTemplate(Thermal/Pump/Hydro/Battery/Vpp/Opsi)
  - TSO: Query, Response, QueryTemplate

### 2. Resource Read Component (`resource.read.component.ts`)
- **Purpose**: Query and filter resources
- **Key Fields**:
  - Participant Name (auto-complete, readonly for BSP)
  - Resource Name (auto-complete, filtered by participant)
  - Date (optional)
  - Record Status (optional)

### 3. Resource Upsert Component (`resource.upsert.component.ts`)
- **Purpose**: Main form for creating/editing resources
- **Structure**: Multi-step stepper with conditional tabs

## Stepper Structure and Tab Dependencies

### Step 1: General Details (Always Visible)
**Key Fields Section:**
- Participant Name (4 chars, readonly, pattern: A-W + 3 digits)
- Resource Name (1-10 chars, pattern: A-Z_0-9\-/)
- Area (dropdown)
- Contract Type (dropdown, depends on Area)
- Resource Type (dropdown)

**Basic Information:**
- Start Date (required)
- End Date (readonly/disabled)
- System Code (5 chars, A-Z0-9)
- Resource Short Name (1-10 chars, Japanese)
- Resource Long Name (1-50 chars, Japanese)
- BG Code (5 chars, optional)

### Step 2: Output Band
**Visibility Conditions:**
```typescript
Resource Type === '01' (THERMAL) → Always shown
Resource Type === '02' || '03' (PUMP/HYDRO) → Always shown  
Resource Type === '04'|'05'|'06'|'07' → Hidden
```

### Step 3: Switch Output
**Visibility Conditions:**
```typescript
Resource Type === '01' (THERMAL) → Always shown
Resource Type === '02' || '03' (PUMP/HYDRO) → Always shown
Resource Type === '04'|'05'|'06'|'07' → Hidden
```

### Step 4: AFC (Automatic Frequency Control)
**Visibility Conditions:**
```typescript
Resource Type === '01' (THERMAL) → Always shown
Resource Type === '02' || '03' (PUMP/HYDRO) → Always shown
Resource Type === '04'|'05'|'06'|'07' → Hidden
```

### Step 5: Startup Pattern
**Visibility Conditions:**
```typescript
Resource Type === '01' (THERMAL) → Always shown
Resource Type === '02' || '03' (PUMP/HYDRO) → Always shown
Resource Type === '04'|'05'|'06'|'07' → Hidden
```

### Step 6: Stop Pattern
**Visibility Conditions:**
```typescript
Resource Type === '01' (THERMAL) → Always shown
Resource Type === '02' || '03' (PUMP/HYDRO) → Always shown
Resource Type === '04'|'05'|'06'|'07' → Hidden
```

### Step 7: Approval (Conditional)
**Visibility Conditions:**
```typescript
Participant Type === 'TSO' AND
Selected Resource Area === Participant Area AND
Access.REGISTRATION === 'WRITE' AND
(Record Status === 'SUBMITTED' OR 'APPROVED')
```

## Field Dependencies

### Area-Based Dependencies

#### OKINAWA Area (Area === '10')
- **Contract Types Available**: Limited set (OKINAWA enumeration)
- **Contract Existence**: 
  - Visible and required
  - For Contract Type 4: Automatically set to '1' and readonly
- **Declared Maximum Unit Price**: 
  - Visible when Contract Existence === '1'
  - Hidden otherwise
- **Frequency**: Set to '60'
- **Validation Rules**:
  - Contract Type 1 or 2 with OKINAWA area → Error message

#### NON-OKINAWA Area (Area !== '10')
- **Contract Types Available**: Full set (NON_OKINAWA enumeration)
- **Contract Existence**: Hidden and disabled
- **Declared Maximum Unit Price**: Hidden and disabled
- **Frequency**: 
  - Areas 01,02,03 → '50'
  - Other areas → '60'
- **Validation Rules**:
  - Contract Type 4 with non-OKINAWA area → Error message

### Contract Type Dependencies

#### Contract Type 1: MARKET
**Market Contract Sections Shown:**
- Primary Market Contract
- Secondary 1 Market Contract  
- Secondary 2 Market Contract
- Tertiary 1 Market Contract
- Tertiary 2 Market Contract

**Features:**
- Each section has checkbox to enable/disable
- Response Time and Continuous Time required when enabled
- Maximum Supply Quantity (auto-calculated or manual)
- Remaining Reserve Utilization (0-100%)
- Command Operation Method selections

#### Contract Type 5: MARKET_AND_POWER_SUPPLY_II
**Market Remaining Reserve Utilization Sections:**
- Primary Market Rem Resv Util
- Secondary 1 Market Rem Resv Util
- Secondary 2 Market Rem Resv Util
- Tertiary 1 Market Rem Resv Util
- Tertiary 2 Market Rem Resv Util

**Features:**
- Similar to Contract Type 1 but with remaining reserve focus
- Baseline settings method dependencies
- GF width out of rated output requirements

#### Contract Type 6: REMAINING_RESERVE_UTILIZATION
**Sections Shown:**
- MSQ Contract (for Resource Types 01,02,03,04)
- Primary Rem Resv Util
- Secondary 1 Rem Resv Util
- Secondary 2 Rem Resv Util
- Tertiary 1 Rem Resv Util
- Tertiary 2 Rem Resv Util

**Features:**
- Maximum Supply Quantity editable for MSQ types
- Standard remaining reserve utilization controls

#### Contract Type 3: POWER_SUPPLY_I
**Power Supply Contract Section:**
- MSQ Controls (for Resource Types 01,02,03,04)
- RRU Controls
- Disables all market-related fields (Pri, Sec1, Sec2, Ter1, Ter2)
- Disables response time and continuous time fields
- Enables Maximum Supply Quantity for MSQ types

#### Contract Type 4: ONLY_POWER_SUPPLY_I
**OPSI Contract Section:**
- OPSI RRU Controls
- Specific validations for OKINAWA area
- Disables all market commodity selections
- Disables market-related timing fields

### Resource Type Dependencies

#### Resource Type 01 (THERMAL)
**Visible Fields:**
- Thermal Type (required if Contract Type !== 4)
- All stepper tabs (Output Band, Switch Output, AFC, Startup Pattern, Stop Pattern)
- Full power generation capabilities
- Black Start capability
- Rated Output, Minimum Output, Authorized Maximum Output
- Full Power Generation Time
- Continuous Operation Time and Limited Time

#### Resource Type 02 (PUMP)
**Visible Fields:**
- Pump-specific controls
- Battery Capacity, Pump Charging, Variable Speed Operation
- Discharging/Charging Output and Time
- AFC minimum output, GF variation rate
- Continuous Operation Output, Pumped Supply
- Selected stepper tabs only (Output Band, Switch Output, AFC, Startup/Stop Pattern)

#### Resource Type 03 (HYDRO)
**Visible Fields:**
- Hydro-specific controls
- Amount of Water Used, Reservoir Capacity, Inflow Amount
- Continuous Operation Output, Pumped Supply
- Selected stepper tabs only
- Phase Modifying Operation

#### Resource Type 04,05,06,07 (OTHER TYPES)
**Characteristics:**
- Limited stepper tabs (General Details only)
- Simplified field sets
- Specific validation rules per type
- FCB Operation, Over Power Operation, Peak Mode Operation
- DSS (Demand Side System) capabilities
- Operation Time, Number of Startups

### Command Operation Method Dependencies

**Primary/Secondary 1 Command Operation Method:**
- Controls VEN ID and Market Context visibility
- Required when Primary or Secondary 1 is selected
- Enables specific validation rules

**Secondary 2/Tertiary 1/Tertiary 2 Command Operation Method:**
- Independent selection
- Validates at least one command method is selected across all market types

### Market Contract Field Dependencies

Each market contract section (Primary, Sec1, Sec2, Ter1, Ter2) contains:
- **Checkbox**: Enables/disables the entire section
- **Response Time**: Required when enabled (pattern: HH:MM:SS)
- **Continuous Time**: Required when enabled (pattern: HH:MM:SS)
- **Down Time**: Only for Secondary 2 (pattern: HH:MM:SS)
- **Maximum Supply Quantity**: Auto-calculated or manual based on resource type
- **Remaining Reserve Utilization**: Dropdown (0-100%)
- **Remaining Reserve Maximum Supply Quantity**: Numeric input

### Transfer Resource Section

**Visibility**: 
```typescript
@Transfer === 'true'
```

**Fields:**
- Transfer (readonly display)
- Previous Participant Name (readonly, 1-4 chars)
- Previous Resource Name (readonly, 1-10 chars)

### Address and Contact Information

**Structure:**
- Address (full width, Japanese characters)
- Phone number (3 parts: PayeePhonePart1, PayeePhonePart2, PayeePhonePart3)
- Separators with "__" between phone parts
- All fields support Japanese character patterns

### Technical Specifications

**Electrical Parameters:**
- Model Name
- Rated Capacity
- Rated Voltage (0.0 to 1000.0)
- Continuous Operation Voltage (0.0 to 100.0)
- Rated Power Factor (0.0 to 100.0)
- Frequency (auto-set by area)
- In Plant Rate

**Frequency Control:**
- Continuous Operation Frequency Lower (40.0 to 70.0)
- Continuous Operation Frequency Upper (40.0 to 70.0)
- Dead Band
- Frequency Measurement Interval
- Frequency Measurement Error
- Delay Time
- GF Width Out of Rated Output

**Output Parameters:**
- Rated Output
- Minimum Output
- Authorized Maximum Output
- AFC Minimum Output
- GF Variation Rate

**Resource-Specific Parameters:**

*Battery Resources:*
- Battery Capacity
- Discharging Output/Time
- Charging Output/Time

*Pump Resources:*
- Pump Charging
- Variable Speed Operation

*Hydro Resources:*
- Amount of Water Used
- Reservoir Capacity
- Inflow Amount
- Continuous Operation Output
- Pumped Supply

*Thermal Resources:*
- Thermal Type (mandatory for non-OPSI)
- Black Start capability
- Full Power Generation Time

## Grid Components

### Output Band Grid
**Purpose**: Define output bands for the resource
**Columns**: Band ranges, output values, operational parameters
**Validation**: Ensures proper band sequencing and values

### Switch Output Grid  
**Purpose**: Define switching output capabilities
**Columns**: Output ranges, switching parameters
**Validation**: Output range validations

### AFC Grid
**Purpose**: Automatic Frequency Control below AFC output ranges
**Columns**: Output ranges below AFC threshold
**Validation**: Range and value validations

### Startup Pattern Grid
**Purpose**: Define startup patterns with chips interface
**Features**: 
- Pattern name input (max 20 chars, Japanese)
- Chip-based pattern management
- Pattern-specific data grids

### Stop Pattern Grid
**Purpose**: Define stop patterns
**Features**: Similar to startup patterns but for shutdown sequences

## Validation Rules Summary

### Area/Contract Combination Rules
```typescript
// Invalid combinations that show error messages
OKINAWA + Contract Type 1/2 → "okinawa" error message
Non-OKINAWA + Contract Type 4 → "nonOkinawa" error message
```

### Required Field Dependencies
- Primary selection → GF Width Out of Rated Output required
- Market contracts → Response/Continuous times required when enabled
- OKINAWA → Contract Existence required
- Contract Existence = 1 → Declared Maximum Unit Price required
- Thermal Type → Required for Resource Type 01 when Contract Type !== 4

### Pattern Validations
- **Participant Name**: `[A-W]([0-9][0-9][1-9]|[0-9][1-9][0-9]|[1-9][0-9][0-9])`
- **Resource Name**: `[A-Z_0-9\\-/]*`
- **Japanese fields**: `([\u3000-\u30FF]|[\uFF00-\uFF60]|[\uFFA0-\uFFEF]|[\u4E00-\u9FEA])+`
- **Time fields**: `[0-9][0-9]:[0-5][0-9]:[0-5][0-9]`
- **System Code**: `[A-Z0-9]*`
- **BG Code**: `[a-zA-Z0-9]*`

### Numeric Validations
- **Declared Maximum Unit Price**: `^((\\d{1,4}(\\.\\d{1,2})?))$` (0 to 9999.99)
- **Rated Voltage**: `^(1000(\\.0{1,1})?|(\\d{1,3}(\\.\\d{1,1})?))$` (0.0 to 1000.0)
- **Voltage/Power Factor**: `^(100(\\.0{1,1})?|(\\d{1,2}(\\.\\d{1,1})?))$` (0.0 to 100.0)
- **Frequency Range**: `^(4[0-9](\\.\\d)?|5[0-9](\\.\\d)?|6[0-9](\\.\\d)?|70(\\.0)?)$` (40.0 to 70.0)
- **GF Pattern**: `^(100.0|[0-9]{1,2}(.[0-9])?|0(.[0-9])?)$` (0.0 to 100.0)
- **Operation Times**: `^(\\d{1,2}(\\.\\d{1,1})?)$` (0.0 to 99.9)

## Access Control

### BSP (Business Supplier Participant)
- Full read/write access to own resources
- Can submit and modify resources
- Resource evaluation capabilities
- Participant Name field readonly (auto-filled)
- All form controls enabled for editing

### TSO (Transmission System Operator)  
- Read access to all resources
- Approval capabilities for submitted resources
- Limited save types (Query, Response, QueryTemplate)
- All form controls readonly except approval fields
- Special approval step visible for submitted/approved resources

## Component Interaction Flow

1. **Initialization**: Resource component loads with hidden state data
2. **Read Panel**: User selects criteria and queries resources
3. **Data Loading**: Selected resource data populates the upsert form
4. **Dynamic Updates**: Field visibility and validation rules update based on selections
5. **Validation**: Real-time validation with step-level error indicators
6. **Submission**: Form validation and server submission with override options

## Error Handling

### Step-Level Validation
- Each stepper step tracks validation errors
- Error indicators shown in step labels with red coloring
- Error messages displayed at step level

### Field-Level Validation
- Real-time validation with pattern matching
- Required field validation
- Cross-field dependency validation
- Custom validators for specific business rules

### Server-Side Integration
- Override options for validation violations
- Transaction ID tracking
- Processing statistics display
- Success/failure message handling

This comprehensive analysis demonstrates the sophisticated nature of the resource display implementation, with intricate dependencies between multiple selection criteria, dynamic field management, and comprehensive validation rules that ensure data integrity across different resource types, contract combinations, and geographic areas.