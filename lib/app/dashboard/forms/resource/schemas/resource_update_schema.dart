import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../../core/forms/forms.dart';

/// Resource update form schema definition
///
/// This class defines the form structure for resource update operations.
/// It uses the config-driven forms library to declaratively define
/// all fields, validation rules, and layout configuration.
class ResourceUpdateSchema {
  // Common patterns for validation
  static final participantNamePattern =
      RegExp(r'^[A-W]([0-9][0-9][1-9]|[0-9][1-9][0-9]|[1-9][0-9][0-9])$');
  static final resourceNamePattern = RegExp(r'^[A-Z_0-9\-/]*$');
  static final japaneseStringPattern =
      RegExp(r'^[\u3040-\u309F\u30A0-\u30FF\u4E00-\u9FAFa-zA-Z0-9\s]+$');
  static final asciiStringPattern = RegExp(r'^[\x20-\x7E]+$');
  static final asciiJapaneseStringPattern =
      RegExp(r'^[\x20-\x7E\u3040-\u309F\u30A0-\u30FF\u4E00-\u9FAF]+$');
  static final numberPattern = RegExp(r'^\d+$');
  static final timePattern = RegExp(r'^[0-9][0-9]:[0-5][0-9]:[0-5][0-9]$');
  static final decimalPattern = RegExp(r'^\d+\.?\d*$');

  /// Get key control fields (always visible)
  static List<FormSectionConfig> getKeyControlSections(BuildContext context) {
    return [
      FormSectionConfig(
        title: '',
        fields: [
          FormFieldConfig(
            id: 'ParticipantName',
            label: 'resource.RegistrationSubmit.Resource.ParticipantName'.tr(),
            flex: 2,
            minLength: 4,
            maxLength: 4,
            readonly: true,
            pattern: participantNamePattern,
            patternMessage: 'Invalid participant name format',
          ),
          FormFieldConfig(
            id: 'ResourceName',
            label: 'resource.RegistrationSubmit.Resource.ResourceName'.tr(),
            flex: 2,
            minLength: 1,
            maxLength: 10,
            placeholder: 'resource.placeholders.ResourceName'.tr(),
            pattern: resourceNamePattern,
            patternMessage: 'resource.messages.ResourceName'.tr(),
          ),
        ],
      ),
      FormSectionConfig(
        fields: [
          FormFieldConfig(
            id: 'Area',
            label: 'resource.RegistrationSubmit.Resource.Area'.tr(),
            type: FieldType.select,
            flex: 2,
            selectOptionsMap: {
              'HOKKAIDO': '01',
              'TOHOKU': '02',
              'TOKYO': '03',
              'CHUBU': '04',
              'HOKURIKU': '05',
              'KANSAI': '06',
              'CHUGOKU': '07',
              'SHIKOKU': '08',
              'KYUSHU': '09',
              'OKINAWA': '10',
            },
          ),
          FormFieldConfig(
            id: 'ContractType',
            label: 'resource.RegistrationSubmit.Resource.ContractType'.tr(),
            type: FieldType.select,
            flex: 2,
            isDynamic: true,
            dependsOn: ['Area'],
            dynamicOptionsBuilder: (values) {
              final areaValue = values['Area'];

              // If Area is OKINAWA (10), show only POWER_SUPPLY options
              if (areaValue == '10') {
                return {
                  'POWER_SUPPLY_II': '3',
                  'ONLY_POWER_SUPPLY_I': '4',
                };
              }

              // For all other areas, show MARKET options
              return {
                'MARKET': '1',
                'MARKET_AND_REMAINING_RESERVE_UTILIZATION': '5',
                'REMAINING_RESERVE_UTILIZATION': '6',
              };
            },
            selectOptionsMap: {},
          ),
        ],
      ),
      FormSectionConfig(
        showDividerAfter: true,
        fields: [
          FormFieldConfig(
            id: 'ResourceType',
            label: 'resource.RegistrationSubmit.Resource.ResourceType'.tr(),
            type: FieldType.select,
            flex: 2,
            selectOptionsMap: {
              'THERMAL': '01',
              'HYDRO': '02',
              'PUMP': '03',
              'BATTERY': '04',
              'VPP_GEN': '05',
              'VPP_GEN_AND_DEM': '06',
              'VPP_DEM': '07',
            },
          ),
        ],
      ),
    ];
  }

  /// Get upsert fields (basic resource information)
  static List<FormSectionConfig> getUpsertSections(BuildContext context) {
    return [
      FormSectionConfig(
        title: '',
        fields: [
          FormFieldConfig(
            id: 'StartDate',
            label: 'resource.RegistrationSubmit.Resource.StartDate'.tr(),
            type: FieldType.date,
            flex: 1,
            minLength: 10,
            maxLength: 10,
          ),
          FormFieldConfig(
            id: 'EndDate',
            label: 'resource.RegistrationSubmit.Resource.EndDate'.tr(),
            type: FieldType.date,
            flex: 1,
            minLength: 10,
            maxLength: 10,
            readonly: true,
            required: false,
          ),
        ],
      ),
      FormSectionConfig(
        fields: [
          FormFieldConfig(
            id: 'SystemCode',
            label: 'resource.RegistrationSubmit.Resource.SystemCode'.tr(),
            flex: 1,
            minLength: 5,
            maxLength: 5,
            pattern: RegExp(r'^[A-Z0-9]*$'),
            placeholder: 'resource.placeholders.SystemCode'.tr(),
          ),
          FormFieldConfig(
            id: 'ResourceShortName',
            label: 'resource.RegistrationSubmit.Resource.ResourceShortName'.tr(),
            flex: 2,
            minLength: 1,
            maxLength: 10,
            pattern: japaneseStringPattern,
            placeholder: 'resource.placeholders.ResourceShortName'.tr(),
          ),
        ],
      ),
      FormSectionConfig(
        fields: [
          FormFieldConfig(
            id: 'ResourceLongName',
            label: 'resource.RegistrationSubmit.Resource.ResourceLongName'.tr(),
            type: FieldType.multiline,
            flex: 3,
            minLength: 1,
            maxLength: 50,
            maxLines: 1,
            pattern: japaneseStringPattern,
            placeholder: 'resource.placeholders.ResourceLongName'.tr(),
          ),
        ],
      ),
      FormSectionConfig(
        showDividerAfter: true,
        fields: [
          FormFieldConfig(
            id: 'BgCode',
            label: 'resource.RegistrationSubmit.Resource.BgCode'.tr(),
            flex: 1,
            minLength: 5,
            maxLength: 5,
            required: false,
            pattern: RegExp(r'^[a-zA-Z0-9]*$'),
            placeholder: 'resource.placeholders.BgCode'.tr(),
          ),
        ],
      ),
    ];
  }

  /// Get Primary (Pri) control fields
  static List<FormSectionConfig> getPrimaryControlSections(
      BuildContext context) {
    return [
      FormSectionConfig(
        title: '',
        fields: [
          FormFieldConfig(
            id: 'Pri',
            label: 'resource.RegistrationSubmit.Resource.Pri'.tr(),
            type: FieldType.checkbox,
            required: false,
          ),
        ],
      ),
      FormSectionConfig(
        fields: [
          FormFieldConfig(
            id: 'PriResponseTime',
            label: 'resource.RegistrationSubmit.Resource.PriResponseTime'.tr(),
            flex: 1,
            minLength: 8,
            maxLength: 8,
            pattern: timePattern,
            placeholder: 'resource.placeholders.PriResponseTime'.tr(),
          ),
          FormFieldConfig(
            id: 'PriContinuousTime',
            label: 'resource.RegistrationSubmit.Resource.PriContinuousTime'.tr(),
            flex: 1,
            minLength: 8,
            maxLength: 8,
            pattern: timePattern,
            placeholder: 'resource.placeholders.PriContinuousTime'.tr(),
          ),
        ],
      ),
      FormSectionConfig(
        fields: [
          FormFieldConfig(
            id: 'PriMaximumSupplyQuantity',
            label: 'resource.RegistrationSubmit.Resource.PriMaximumSupplyQuantity'.tr(),
            flex: 2,
            minLength: 1,
            maxLength: 7,
            pattern: numberPattern,
            placeholder: 'resource.placeholders.PriMaximumSupplyQuantity'.tr(),
          ),
        ],
      ),
      FormSectionConfig(
        fields: [
          FormFieldConfig(
            id: 'PriRemResvUtilization',
            label: 'resource.RegistrationSubmit.Resource.PriRemResvUtilization'.tr(),
            type: FieldType.select,
            flex: 2,
            selectOptionsMap: {
              'NOT_AVAILABLE': '0',
              'AVAILABLE_FOR_UP_ONLY': '1',
              'AVAILABLE_FOR_DOWN_ONLY': '2',
              'AVAILABLE_FOR_UP_AND_DOWN': '3',
            },
          ),
        ],
      ),
      FormSectionConfig(
        showDividerAfter: true,
        fields: [
          FormFieldConfig(
            id: 'PriRemResvMaximumSupplyQuantity',
            label: 'resource.RegistrationSubmit.Resource.PriRemResvMaximumSupplyQuantity'.tr(),
            flex: 2,
            minLength: 1,
            maxLength: 7,
            pattern: numberPattern,
            placeholder: 'resource.placeholders.PriRemResvMaximumSupplyQuantity'.tr(),
          ),
        ],
      ),
    ];
  }

  /// Get Secondary 1 (Sec1) control fields
  static List<FormSectionConfig> getSecondary1ControlSections(
      BuildContext context) {
    return [
      FormSectionConfig(
        title: '',
        fields: [
          FormFieldConfig(
            id: 'Sec1',
            label: 'resource.RegistrationSubmit.Resource.Sec1'.tr(),
            type: FieldType.checkbox,
            required: false,
          ),
        ],
      ),
      FormSectionConfig(
        fields: [
          FormFieldConfig(
            id: 'Sec1ResponseTime',
            label: 'resource.RegistrationSubmit.Resource.Sec1ResponseTime'.tr(),
            flex: 1,
            minLength: 8,
            maxLength: 8,
            pattern: timePattern,
            placeholder: 'resource.placeholders.Sec1ResponseTime'.tr(),
          ),
          FormFieldConfig(
            id: 'Sec1ContinuousTime',
            label: 'resource.RegistrationSubmit.Resource.Sec1ContinuousTime'.tr(),
            flex: 1,
            minLength: 8,
            maxLength: 8,
            pattern: timePattern,
            placeholder: 'resource.placeholders.Sec1ContinuousTime'.tr(),
          ),
        ],
      ),
      FormSectionConfig(
        fields: [
          FormFieldConfig(
            id: 'Sec1MaximumSupplyQuantity',
            label: 'resource.RegistrationSubmit.Resource.Sec1MaximumSupplyQuantity'.tr(),
            flex: 2,
            minLength: 1,
            maxLength: 7,
            pattern: numberPattern,
            placeholder: 'resource.placeholders.Sec1MaximumSupplyQuantity'.tr(),
          ),
        ],
      ),
      FormSectionConfig(
        fields: [
          FormFieldConfig(
            id: 'Sec1RemResvUtilization',
            label: 'resource.RegistrationSubmit.Resource.Sec1RemResvUtilization'.tr(),
            type: FieldType.select,
            flex: 2,
            selectOptionsMap: {
              'NOT_AVAILABLE': '0',
              'AVAILABLE_FOR_UP_ONLY': '1',
              'AVAILABLE_FOR_DOWN_ONLY': '2',
              'AVAILABLE_FOR_UP_AND_DOWN': '3',
            },
          ),
        ],
      ),
      FormSectionConfig(
        showDividerAfter: true,
        fields: [
          FormFieldConfig(
            id: 'Sec1RemResvMaximumSupplyQuantity',
            label: 'resource.RegistrationSubmit.Resource.Sec1RemResvMaximumSupplyQuantity'.tr(),
            flex: 2,
            minLength: 1,
            maxLength: 7,
            pattern: numberPattern,
            placeholder: 'resource.placeholders.Sec1RemResvMaximumSupplyQuantity'.tr(),
          ),
        ],
      ),
    ];
  }

  /// Get Secondary 2 (Sec2) control fields
  static List<FormSectionConfig> getSecondary2ControlSections(
      BuildContext context) {
    return [
      FormSectionConfig(
        title: '',
        fields: [
          FormFieldConfig(
            id: 'Sec2',
            label: 'resource.RegistrationSubmit.Resource.Sec2'.tr(),
            type: FieldType.checkbox,
            required: false,
          ),
        ],
      ),
      FormSectionConfig(
        fields: [
          FormFieldConfig(
            id: 'Sec2ResponseTime',
            label: 'resource.RegistrationSubmit.Resource.Sec2ResponseTime'.tr(),
            flex: 1,
            minLength: 8,
            maxLength: 8,
            pattern: timePattern,
            placeholder: 'resource.placeholders.Sec2ResponseTime'.tr(),
          ),
          FormFieldConfig(
            id: 'Sec2ContinuousTime',
            label: 'resource.RegistrationSubmit.Resource.Sec2ContinuousTime'.tr(),
            flex: 1,
            minLength: 8,
            maxLength: 8,
            pattern: timePattern,
            placeholder: 'resource.placeholders.Sec2ResponseTime'.tr(),
          ),
        ],
      ),
      FormSectionConfig(
        fields: [
          FormFieldConfig(
            id: 'Sec2DownTime',
            label: 'resource.RegistrationSubmit.Resource.Sec2DownTime'.tr(),
            flex: 1,
            minLength: 8,
            maxLength: 8,
            pattern: timePattern,
            placeholder: 'resource.placeholders.Sec2ResponseTime'.tr(),
          ),
          FormFieldConfig(
            id: 'Sec2MaximumSupplyQuantity',
            label: 'resource.RegistrationSubmit.Resource.Sec2MaximumSupplyQuantity'.tr(),
            flex: 2,
            minLength: 1,
            maxLength: 7,
            pattern: numberPattern,
            placeholder: 'resource.placeholders.Sec2MaximumSupplyQuantity'.tr(),
          ),
        ],
      ),
      FormSectionConfig(
        fields: [
          FormFieldConfig(
            id: 'Sec2RemResvUtilization',
            label: 'resource.RegistrationSubmit.Resource.Sec2RemResvUtilization'.tr(),
            type: FieldType.select,
            flex: 2,
            selectOptionsMap: {
              'NOT_AVAILABLE': '0',
              'AVAILABLE_FOR_UP_ONLY': '1',
              'AVAILABLE_FOR_DOWN_ONLY': '2',
              'AVAILABLE_FOR_UP_AND_DOWN': '3',
            },
          ),
        ],
      ),
      FormSectionConfig(
        showDividerAfter: true,
        fields: [
          FormFieldConfig(
            id: 'Sec2RemResvMaximumSupplyQuantity',
            label: 'resource.RegistrationSubmit.Resource.Sec2RemResvMaximumSupplyQuantity'.tr(),
            flex: 2,
            minLength: 1,
            maxLength: 7,
            pattern: numberPattern,
            placeholder: 'resource.placeholders.Sec2RemResvMaximumSupplyQuantity'.tr(),
          ),
        ],
      ),
    ];
  }

  /// Get Tertiary 1 (Ter1) control fields
  static List<FormSectionConfig> getTertiary1ControlSections(
      BuildContext context) {
    return [
      FormSectionConfig(
        title: '',
        fields: [
          FormFieldConfig(
            id: 'Ter1',
            label: 'resource.RegistrationSubmit.Resource.Ter1'.tr(),
            type: FieldType.checkbox,
            required: false,
          ),
        ],
      ),
      FormSectionConfig(
        fields: [
          FormFieldConfig(
            id: 'Ter1ResponseTime',
            label: 'resource.RegistrationSubmit.Resource.Ter1ResponseTime'.tr(),
            flex: 1,
            minLength: 8,
            maxLength: 8,
            pattern: timePattern,
            placeholder: 'resource.placeholders.Sec2ResponseTime'.tr(),
          ),
          FormFieldConfig(
            id: 'Ter1ContinuousTime',
            label: 'resource.RegistrationSubmit.Resource.Ter1ContinuousTime'.tr(),
            flex: 1,
            minLength: 8,
            maxLength: 8,
            pattern: timePattern,
            placeholder: 'resource.placeholders.Sec2ResponseTime'.tr(),
          ),
        ],
      ),
      FormSectionConfig(
        fields: [
          FormFieldConfig(
            id: 'Ter1MaximumSupplyQuantity',
            label: 'resource.RegistrationSubmit.Resource.Ter1MaximumSupplyQuantity'.tr(),
            flex: 2,
            minLength: 1,
            maxLength: 7,
            pattern: numberPattern,
            placeholder: 'resource.placeholders.Ter1MaximumSupplyQuantity'.tr(),
          ),
        ],
      ),
      FormSectionConfig(
        fields: [
          FormFieldConfig(
            id: 'Ter1RemResvUtilization',
            label: 'resource.RegistrationSubmit.Resource.Ter1RemResvUtilization'.tr(),
            type: FieldType.select,
            flex: 2,
            selectOptionsMap: {
              'NOT_AVAILABLE': '0',
              'AVAILABLE_FOR_UP_ONLY': '1',
              'AVAILABLE_FOR_DOWN_ONLY': '2',
              'AVAILABLE_FOR_UP_AND_DOWN': '3',
            },
          ),
        ],
      ),
      FormSectionConfig(
        showDividerAfter: true,
        fields: [
          FormFieldConfig(
            id: 'Ter1RemResvMaximumSupplyQuantity',
            label: 'resource.RegistrationSubmit.Resource.Ter1RemResvMaximumSupplyQuantity'.tr(),
            flex: 2,
            minLength: 1,
            maxLength: 7,
            pattern: numberPattern,
            placeholder: 'resource.placeholders.Ter1RemResvMaximumSupplyQuantity'.tr(),
          ),
        ],
      ),
    ];
  }

  /// Get Tertiary 2 (Ter2) control fields
  static List<FormSectionConfig> getTertiary2ControlSections(
      BuildContext context) {
    return [
      FormSectionConfig(
        title: '',
        fields: [
          FormFieldConfig(
            id: 'Ter2',
            label: 'resource.RegistrationSubmit.Resource.Ter2'.tr(),
            type: FieldType.checkbox,
            required: false,
          ),
        ],
      ),
      FormSectionConfig(
        fields: [
          FormFieldConfig(
            id: 'Ter2ResponseTime',
            label: 'resource.RegistrationSubmit.Resource.Ter2ResponseTime'.tr(),
            flex: 1,
            minLength: 8,
            maxLength: 8,
            pattern: timePattern,
            placeholder: 'resource.placeholders.Sec2ResponseTime'.tr(),
          ),
          FormFieldConfig(
            id: 'Ter2ContinuousTime',
            label: 'resource.RegistrationSubmit.Resource.Ter2ContinuousTime'.tr(),
            flex: 1,
            minLength: 8,
            maxLength: 8,
            pattern: timePattern,
            placeholder: 'resource.placeholders.Sec2ResponseTime'.tr(),
          ),
        ],
      ),
      FormSectionConfig(
        fields: [
          FormFieldConfig(
            id: 'Ter2MaximumSupplyQuantity',
            label: 'resource.RegistrationSubmit.Resource.Ter2MaximumSupplyQuantity'.tr(),
            flex: 2,
            minLength: 1,
            maxLength: 7,
            pattern: numberPattern,
            placeholder: 'resource.placeholders.Ter2MaximumSupplyQuantity'.tr(),
          ),
        ],
      ),
      FormSectionConfig(
        fields: [
          FormFieldConfig(
            id: 'Ter2RemResvUtilization',
            label: 'resource.RegistrationSubmit.Resource.Ter2RemResvUtilization'.tr(),
            type: FieldType.select,
            flex: 2,
            selectOptionsMap: {
              'NOT_AVAILABLE': '0',
              'AVAILABLE_FOR_UP_ONLY': '1',
              'AVAILABLE_FOR_DOWN_ONLY': '2',
              'AVAILABLE_FOR_UP_AND_DOWN': '3',
            },
          ),
        ],
      ),
      FormSectionConfig(
        showDividerAfter: true,
        fields: [
          FormFieldConfig(
            id: 'Ter2RemResvMaximumSupplyQuantity',
            label: 'resource.RegistrationSubmit.Resource.Ter2RemResvMaximumSupplyQuantity'.tr(),
            flex: 2,
            minLength: 1,
            maxLength: 7,
            pattern: numberPattern,
            placeholder: 'resource.placeholders.Ter2RemResvMaximumSupplyQuantity'.tr(),
          ),
        ],
      ),
    ];
  }

  /// Get remaining control fields
  static List<FormSectionConfig> getRemainingControlSections(
      BuildContext context) {
    return [
      FormSectionConfig(
        title: 'Additional Controls',
        fields: [
          FormFieldConfig(
            id: 'PriSec1CommandOperationMethod',
            label: 'resource.RegistrationSubmit.Resource.PriSec1CommandOperationMethod'.tr(),
            type: FieldType.select,
            flex: 1,
            required: false,
            selectOptionsMap: {
              'DEDICATED_LINE': '1',
              'OFFLINE': '3',
            },
          ),
          FormFieldConfig(
            id: 'Sec2Ter1Ter2CommandOperationMethod',
            label: 'resource.RegistrationSubmit.Resource.Sec2Ter1Ter2CommandOperationMethod'.tr(),
            type: FieldType.select,
            flex: 1,
            required: false,
            selectOptionsMap: {'DEDICATED_LINE': '1', 'SIMPLE_COMMAND': '2'},
          ),
        ],
      ),
      FormSectionConfig(
        fields: [
          FormFieldConfig(
            id: 'SignalType',
            label: 'resource.RegistrationSubmit.Resource.SignalType'.tr(),
            type: FieldType.select,
            flex: 1,
            selectOptionsMap: {
              'ACTUAL_OUTPUT_ORDER': '1',
              'DIFFERENTIAL_OUTPUT_ORDER': '2'
            },
          ),
          FormFieldConfig(
            id: 'ContractExistence',
            label: 'resource.RegistrationSubmit.Resource.ContractExistence'.tr(),
            type: FieldType.select,
            flex: 1,
            selectOptionsMap: {'NO': '0', 'YES': '1'},
          ),
        ],
      ),
      FormSectionConfig(
        showDividerAfter: true,
        fields: [
          FormFieldConfig(
            id: 'DeclaredMaximumUnitPrice',
            label: 'resource.RegistrationSubmit.Resource.DeclaredMaximumUnitPrice'.tr(),
            flex: 1,
            minLength: 1,
            maxLength: 7,
            visible: false,
            pattern: decimalPattern,
            placeholder: 'resource.placeholders.DeclaredMaximumUnitPrice'.tr(),
          ),
          FormFieldConfig(
            id: 'VoltageAdjustment',
            label: 'resource.RegistrationSubmit.Resource.VoltageAdjustment'.tr(),
            type: FieldType.select,
            flex: 1,
            selectOptionsMap: {'NO': '0', 'YES': '1'},
          ),
        ],
      ),
    ];
  }

  /// Get address control fields
  static List<FormSectionConfig> getAddressControlSections(
      BuildContext context) {
    return [
      FormSectionConfig(
        title: 'Address Information',
        fields: [
          FormFieldConfig(
            id: 'Address',
            label: 'resource.RegistrationSubmit.Resource.Address'.tr(),
            type: FieldType.multiline,
            flex: 3,
            minLength: 1,
            maxLength: 50,
            maxLines: 2,
            pattern: japaneseStringPattern,
            placeholder: 'resource.placeholders.Address'.tr(),
          ),
        ],
      ),
      FormSectionConfig(
        showDividerAfter: true,
        fields: [
          FormFieldConfig(
            id: 'PayeePhonePart1',
            label: 'resource.RegistrationSubmit.Resource.PayeePhonePart1'.tr(),
            type: FieldType.phone,
            flex: 3,
            minLength: 1,
            maxLength: 5,
            pattern: numberPattern,
            placeholder: 'resource.placeholders.PayeePhonePart1'.tr(),
            alias: 'resource.RegistrationSubmit.Resource.PayeePhonePart1Alias'.tr(),
          ),
          FormFieldConfig(
            id: 'PayeePhonePart2',
            label: 'resource.RegistrationSubmit.Resource.PayeePhonePart2'.tr(),
            type: FieldType.phone,
            flex: 3,
            minLength: 1,
            maxLength: 4,
            pattern: numberPattern,
            placeholder: 'resource.placeholders.PayeePhonePart2'.tr(),
            showLabel: false,
          ),
          FormFieldConfig(
            id: 'PayeePhonePart3',
            label: 'resource.RegistrationSubmit.Resource.PayeePhonePart3'.tr(),
            type: FieldType.phone,
            flex: 3,
            minLength: 1,
            maxLength: 4,
            pattern: numberPattern,
            placeholder: 'resource.placeholders.PayeePhonePart3'.tr(),
            showLabel: false,
          ),
        ],
      ),
    ];
  }

  /// Get technical specification fields
  static List<FormSectionConfig> getTechnicalSpecSections(
      BuildContext context) {
    return [
      FormSectionConfig(
        title: 'Technical Specifications',
        fields: [
          FormFieldConfig(
            id: 'BaselineSettingMethod',
            label: 'resource.RegistrationSubmit.Resource.BaselineSettingMethod'.tr(),
            type: FieldType.select,
            flex: 1,
            selectOptionsMap: const {
              'PREDICTION_BASE': '1',
              'MEASUREMENT_BASE': '2',
              'SEQUENTIAL_MEASUREMENT_BASE': '3',
            },
            placeholder: 'resource.placeholders.BaselineSettingMethod'.tr(),
          ),
          FormFieldConfig(
            id: 'VenId',
            label: 'resource.RegistrationSubmit.Resource.VenId'.tr(),
            flex: 3,
            minLength: 1,
            maxLength: 64,
            visible: false,
            pattern: asciiStringPattern,
            placeholder: 'resource.placeholders.VenId'.tr(),
            patternMessage: 'resource.messages.VenId'.tr(),
          ),
        ],
      ),
      FormSectionConfig(
        fields: [
          FormFieldConfig(
            id: 'ModelName',
            label: 'resource.RegistrationSubmit.Resource.ModelName'.tr(),
            flex: 2,
            minLength: 1,
            maxLength: 50,
            pattern: asciiJapaneseStringPattern,
            placeholder: 'resource.placeholders.ModelName'.tr(),
            patternMessage: 'resource.messages.ModelName'.tr(),
          ),
          FormFieldConfig(
            id: 'RatedCapacity',
            label: 'resource.RegistrationSubmit.Resource.RatedCapacity'.tr(),
            flex: 1,
            minLength: 1,
            maxLength: 7,
            pattern: numberPattern,
            placeholder: 'resource.placeholders.RatedCapacity'.tr(),
          ),
        ],
      ),
      FormSectionConfig(
        fields: [
          FormFieldConfig(
            id: 'RatedVoltage',
            label: 'resource.RegistrationSubmit.Resource.RatedVoltage'.tr(),
            flex: 1,
            minLength: 1,
            maxLength: 6,
            pattern: decimalPattern,
            placeholder: 'resource.placeholders.RatedVoltage'.tr(),
          ),
          FormFieldConfig(
            id: 'ContinuousOperationVoltage',
            label: 'resource.RegistrationSubmit.Resource.ContinuousOperationVoltage'.tr(),
            flex: 1,
            minLength: 1,
            maxLength: 5,
            pattern: decimalPattern,
            placeholder: 'resource.placeholders.ContinuousOperationVoltage'.tr(),
          ),
        ],
      ),
      FormSectionConfig(
        fields: [
          FormFieldConfig(
            id: 'RatedPowerFactor',
            label: 'resource.RegistrationSubmit.Resource.RatedPowerFactor'.tr(),
            flex: 1,
            minLength: 1,
            maxLength: 5,
            pattern: decimalPattern,
            placeholder: 'resource.placeholders.RatedPowerFactor'.tr(),
          ),
          FormFieldConfig(
            id: 'Frequency',
            label: 'resource.RegistrationSubmit.Resource.Frequency'.tr(),
            type: FieldType.select,
            flex: 1,
            selectOptionsMap: const {
              '50': '50',
              '60': '60',
            },
          ),
        ],
      ),
      FormSectionConfig(
        fields: [
          FormFieldConfig(
            id: 'InPlantRate',
            label: 'resource.RegistrationSubmit.Resource.InPlantRate'.tr(),
            flex: 3,
            minLength: 1,
            maxLength: 100,
            pattern: asciiJapaneseStringPattern,
            placeholder: 'resource.placeholders.InPlantRate'.tr(),
            patternMessage: 'resource.messages.InPlantRate'.tr(),
          ),
        ],
      ),
      FormSectionConfig(
        fields: [
          FormFieldConfig(
            id: 'ContinuousOperationFrequencyLower',
            label: 'resource.RegistrationSubmit.Resource.ContinuousOperationFrequencyLower'.tr(),
            flex: 1,
            minLength: 1,
            maxLength: 4,
            pattern: decimalPattern,
            placeholder: 'resource.placeholders.ContinuousOperationFrequencyLower'.tr(),
          ),
          FormFieldConfig(
            id: 'ContinuousOperationFrequencyUpper',
            label: 'resource.RegistrationSubmit.Resource.ContinuousOperationFrequencyUpper'.tr(),
            flex: 1,
            minLength: 1,
            maxLength: 4,
            pattern: decimalPattern,
            placeholder: 'resource.placeholders.ContinuousOperationFrequencyUpper'.tr(),
          ),
        ],
      ),
      FormSectionConfig(
        fields: [
          FormFieldConfig(
            id: 'BlackStart',
            label: 'resource.RegistrationSubmit.Resource.BlackStart'.tr(),
            type: FieldType.select,
            flex: 1,
            selectOptionsMap: const {
              'AVAILABLE': '1',
              'NOT_AVAILABLE': '0',
            },
          ),
          FormFieldConfig(
            id: 'RatedOutput',
            label: 'resource.RegistrationSubmit.Resource.RatedOutput'.tr(),
            flex: 1,
            minLength: 0,
            maxLength: 7,
            required: false,
            pattern: numberPattern,
            placeholder: 'resource.placeholders.RatedOutput'.tr(),
          ),
        ],
      ),
      FormSectionConfig(
        fields: [
          FormFieldConfig(
            id: 'MinimumOutput',
            label: 'resource.RegistrationSubmit.Resource.MinimumOutput'.tr(),
            flex: 1,
            minLength: 1,
            maxLength: 7,
            pattern: numberPattern,
            placeholder: 'resource.placeholders.MinimumOutput'.tr(),
          ),
          FormFieldConfig(
            id: 'AuthorizedMaximumOutput',
            label: 'resource.RegistrationSubmit.Resource.AuthorizedMaximumOutput'.tr(),
            flex: 1,
            minLength: 1,
            maxLength: 7,
            pattern: numberPattern,
            placeholder: 'resource.placeholders.AuthorizedMaximumOutput'.tr(),
          ),
        ],
      ),
      FormSectionConfig(
        fields: [
          FormFieldConfig(
            id: 'ThermalType',
            label: 'resource.RegistrationSubmit.Resource.ThermalType'.tr(),
            type: FieldType.select,
            flex: 1,
            selectOptionsMap: const {'GT': '1', 'GTCC': '2', 'OTHERS': '9'},
            placeholder: 'resource.placeholders.ThermalType'.tr(),
          ),
          FormFieldConfig(
            id: 'BatteryCapacity',
            label: 'resource.RegistrationSubmit.Resource.BatteryCapacity'.tr(),
            flex: 1,
            minLength: 1,
            maxLength: 7,
            pattern: numberPattern,
            placeholder: 'resource.placeholders.BatteryCapacity'.tr(),
          ),
        ],
      ),
      FormSectionConfig(
        fields: [
          FormFieldConfig(
            id: 'PumpCharging',
            label: 'resource.RegistrationSubmit.Resource.PumpCharging'.tr(),
            type: FieldType.select,
            flex: 1,
            selectOptionsMap: const {
              'AVAILABLE': '1',
              'NOT_AVAILABLE': '0',
            },
          ),
          FormFieldConfig(
            id: 'VariableSpeedOperation',
            label: 'resource.RegistrationSubmit.Resource.VariableSpeedOperation'.tr(),
            type: FieldType.select,
            flex: 1,
            selectOptionsMap: const {
              'AVAILABLE': '1',
              'NOT_AVAILABLE': '0',
            },
          ),
        ],
      ),
      FormSectionConfig(
        fields: [
          FormFieldConfig(
            id: 'DischargingOutput',
            label: 'resource.RegistrationSubmit.Resource.DischargingOutput'.tr(),
            flex: 1,
            minLength: 1,
            maxLength: 7,
            pattern: numberPattern,
            placeholder: 'resource.placeholders.DischargingOutput'.tr(),
          ),
          FormFieldConfig(
            id: 'DischargingTime',
            label: 'resource.RegistrationSubmit.Resource.DischargingTime'.tr(),
            flex: 1,
            minLength: 1,
            maxLength: 2,
            pattern: numberPattern,
            placeholder: 'resource.placeholders.DischargingTime'.tr(),
          ),
        ],
      ),
      FormSectionConfig(
        fields: [
          FormFieldConfig(
            id: 'ChargingOutput',
            label: 'resource.RegistrationSubmit.Resource.ChargingOutput'.tr(),
            flex: 1,
            minLength: 1,
            maxLength: 7,
            pattern: numberPattern,
            placeholder: 'resource.placeholders.ChargingOutput'.tr(),
          ),
          FormFieldConfig(
            id: 'ChargingTime',
            label: 'resource.RegistrationSubmit.Resource.ChargingTime'.tr(),
            flex: 1,
            minLength: 1,
            maxLength: 2,
            pattern: numberPattern,
            placeholder: 'resource.placeholders.ChargingTime'.tr(),
          ),
        ],
      ),
      FormSectionConfig(
        fields: [
          FormFieldConfig(
            id: 'FullPowerGenerationTime',
            label: 'resource.RegistrationSubmit.Resource.FullPowerGenerationTime'.tr(),
            flex: 1,
            minLength: 1,
            maxLength: 4,
            pattern: decimalPattern,
            placeholder: 'resource.placeholders.FullPowerGenerationTime'.tr(),
          ),
          FormFieldConfig(
            id: 'ContinuousOperationTime',
            label: 'resource.RegistrationSubmit.Resource.ContinuousOperationTime'.tr(),
            flex: 1,
            minLength: 1,
            maxLength: 4,
            pattern: decimalPattern,
            placeholder: 'resource.placeholders.ContinuousOperationTime'.tr(),
          ),
        ],
      ),
      FormSectionConfig(
        fields: [
          FormFieldConfig(
            id: 'ContinuousOperationTimeLimited',
            label: 'resource.RegistrationSubmit.Resource.ContinuousOperationTimeLimited'.tr(),
            flex: 1,
            minLength: 1,
            maxLength: 4,
            pattern: decimalPattern,
            placeholder: 'resource.placeholders.ContinuousOperationTimeLimited'.tr(),
          ),
          FormFieldConfig(
            id: 'PhaseModifyingOperation',
            label: 'resource.RegistrationSubmit.Resource.PhaseModifyingOperation'.tr(),
            type: FieldType.select,
            flex: 1,
            selectOptionsMap: const {
              'AVAILABLE': '1',
              'NOT_AVAILABLE': '0',
            },
          ),
        ],
      ),
      FormSectionConfig(
        fields: [
          FormFieldConfig(
            id: 'AmountOfWaterUsed',
            label: 'resource.RegistrationSubmit.Resource.AmountOfWaterUsed'.tr(),
            flex: 1,
            minLength: 1,
            maxLength: 7,
            pattern: numberPattern,
            placeholder: 'resource.placeholders.AmountOfWaterUsed'.tr(),
          ),
          FormFieldConfig(
            id: 'ReservoirCapacity',
            label: 'resource.RegistrationSubmit.Resource.ReservoirCapacity'.tr(),
            flex: 1,
            minLength: 1,
            maxLength: 7,
            pattern: numberPattern,
            placeholder: 'resource.placeholders.ReservoirCapacity'.tr(),
          ),
        ],
      ),
      FormSectionConfig(
        fields: [
          FormFieldConfig(
            id: 'InflowAmount',
            label: 'resource.RegistrationSubmit.Resource.InflowAmount'.tr(),
            flex: 1,
            minLength: 1,
            maxLength: 7,
            pattern: numberPattern,
            placeholder: 'resource.placeholders.InflowAmount'.tr(),
          ),
          FormFieldConfig(
            id: 'ContinuousOperationOutput',
            label: 'resource.RegistrationSubmit.Resource.ContinuousOperationOutput'.tr(),
            flex: 1,
            minLength: 1,
            maxLength: 7,
            pattern: numberPattern,
            placeholder: 'resource.placeholders.ContinuousOperationOutput'.tr(),
          ),
        ],
      ),
      FormSectionConfig(
        fields: [
          FormFieldConfig(
            id: 'PumpedSupply',
            label: 'resource.RegistrationSubmit.Resource.PumpedSupply'.tr(),
            flex: 1,
            minLength: 1,
            maxLength: 7,
            pattern: numberPattern,
            placeholder: 'resource.placeholders.PumpedSupply'.tr(),
          ),
          FormFieldConfig(
            id: 'FcbOperation',
            label: 'resource.RegistrationSubmit.Resource.FcbOperation'.tr(),
            type: FieldType.select,
            flex: 1,
            selectOptionsMap: const {
              'AVAILABLE': '1',
              'NOT_AVAILABLE': '0',
            },
          ),
        ],
      ),
      FormSectionConfig(
        fields: [
          FormFieldConfig(
            id: 'OverPowerOperation',
            label: 'resource.RegistrationSubmit.Resource.OverPowerOperation'.tr(),
            type: FieldType.select,
            flex: 1,
            selectOptionsMap: const {
              'AVAILABLE': '1',
              'NOT_AVAILABLE': '0',
            },
          ),
          FormFieldConfig(
            id: 'PeakModeOperation',
            label: 'resource.RegistrationSubmit.Resource.PeakModeOperation'.tr(),
            type: FieldType.select,
            flex: 1,
            selectOptionsMap: const {
              'AVAILABLE': '1',
              'NOT_AVAILABLE': '0',
            },
          ),
        ],
      ),
      FormSectionConfig(
        fields: [
          FormFieldConfig(
            id: 'Dss',
            label: 'resource.RegistrationSubmit.Resource.Dss'.tr(),
            type: FieldType.select,
            flex: 1,
            selectOptionsMap: const {
              'AVAILABLE': '1',
              'NOT_AVAILABLE': '0',
            },
          ),
          FormFieldConfig(
            id: 'OverPowerOperationMaximumOutput',
            label: 'resource.RegistrationSubmit.Resource.OverPowerOperationMaximumOutput'.tr(),
            flex: 1,
            minLength: 1,
            maxLength: 7,
            pattern: numberPattern,
            placeholder: 'resource.placeholders.OverPowerOperationMaximumOutput'.tr(),
          ),
        ],
      ),
      FormSectionConfig(
        fields: [
          FormFieldConfig(
            id: 'PeakModeOperationMaximumOutput',
            label: 'resource.RegistrationSubmit.Resource.PeakModeOperationMaximumOutput'.tr(),
            flex: 1,
            minLength: 1,
            maxLength: 7,
            pattern: numberPattern,
            placeholder: 'resource.placeholders.PeakModeOperationMaximumOutput'.tr(),
          ),
          FormFieldConfig(
            id: 'OperationTime',
            label: 'resource.RegistrationSubmit.Resource.OperationTime'.tr(),
            flex: 1,
            minLength: 1,
            maxLength: 4,
            pattern: decimalPattern,
            placeholder: 'resource.placeholders.OperationTime'.tr(),
          ),
        ],
      ),
      FormSectionConfig(
        fields: [
          FormFieldConfig(
            id: 'NumberOfStartups',
            label: 'resource.RegistrationSubmit.Resource.NumberOfStartups'.tr(),
            flex: 1,
            minLength: 1,
            maxLength: 4,
            visible: false,
            pattern: numberPattern,
            placeholder: 'resource.placeholders.NumberOfStartups'.tr(),
          ),
          FormFieldConfig(
            id: 'AfcMinimumOutput',
            label: 'resource.RegistrationSubmit.Resource.AfcMinimumOutput'.tr(),
            flex: 1,
            minLength: 1,
            maxLength: 7,
            pattern: numberPattern,
            placeholder: 'resource.placeholders.AfcMinimumOutput'.tr(),
          ),
        ],
      ),
      FormSectionConfig(
        fields: [
          FormFieldConfig(
            id: 'GfVariationRate',
            label: 'resource.RegistrationSubmit.Resource.GfVariationRate'.tr(),
            flex: 1,
            minLength: 1,
            maxLength: 5,
            pattern: decimalPattern,
            placeholder: 'resource.placeholders.GfVariationRate'.tr(),
          ),
          FormFieldConfig(
            id: 'DeadBand',
            label: 'resource.RegistrationSubmit.Resource.DeadBand'.tr(),
            flex: 1,
            minLength: 1,
            maxLength: 6,
            pattern: decimalPattern,
            placeholder: 'resource.placeholders.DeadBand'.tr(),
          ),
        ],
      ),
      FormSectionConfig(
        fields: [
          FormFieldConfig(
            id: 'FrequencyMeasurementInterval',
            label: 'resource.RegistrationSubmit.Resource.FrequencyMeasurementInterval'.tr(),
            flex: 1,
            minLength: 1,
            maxLength: 4,
            pattern: decimalPattern,
            placeholder: 'resource.placeholders.FrequencyMeasurementInterval'.tr(),
          ),
          FormFieldConfig(
            id: 'FrequencyMeasurementError',
            label: 'resource.RegistrationSubmit.Resource.FrequencyMeasurementError'.tr(),
            flex: 1,
            minLength: 1,
            maxLength: 5,
            pattern: decimalPattern,
            placeholder: 'resource.placeholders.FrequencyMeasurementError'.tr(),
          ),
        ],
      ),
      FormSectionConfig(
        fields: [
          FormFieldConfig(
            id: 'DelayTime',
            label: 'resource.RegistrationSubmit.Resource.DelayTime'.tr(),
            flex: 1,
            minLength: 1,
            maxLength: 3,
            pattern: decimalPattern,
            placeholder: 'resource.placeholders.DelayTime'.tr(),
          ),
          FormFieldConfig(
            id: 'GfWidthOutOfRatedOutput',
            label: 'resource.RegistrationSubmit.Resource.GfWidthOutOfRatedOutput'.tr(),
            flex: 1,
            minLength: 0,
            maxLength: 7,
            required: false,
            visible: false,
            pattern: numberPattern,
            placeholder: 'resource.placeholders.GfWidthOutOfRatedOutput'.tr(),
          ),
        ],
      ),
      FormSectionConfig(
        showDividerAfter: true,
        fields: [
          FormFieldConfig(
            id: 'MarketContext',
            label: 'resource.RegistrationSubmit.Resource.MarketContext'.tr(),
            flex: 4,
            minLength: 1,
            maxLength: 256,
            visible: false,
            pattern: asciiStringPattern,
            placeholder: 'resource.placeholders.MarketContext'.tr(),
            patternMessage: 'resource.messages.MarketContext'.tr(),
          ),
        ],
      ),
    ];
  }

  /// Get status and transaction fields
  static List<FormSectionConfig> getStatusSections(BuildContext context) {
    return [
      FormSectionConfig(
        title: 'Status & Transaction',
        fields: [
          FormFieldConfig(
            id: 'RecordStatus',
            label: 'resource.RegistrationSubmit.Resource.RecordStatus'.tr(),
            flex: 1,
            minLength: 1,
            maxLength: 12,
            required: false,
            readonly: true,
            visible: true,
            placeholder: 'RecordStatus',
          ),
          FormFieldConfig(
            id: 'TransactionId',
            label: 'resource.RegistrationSubmit.Resource.TransactionId'.tr(),
            flex: 1,
            minLength: 1,
            maxLength: 10,
            required: false,
            readonly: true,
            visible: true,
            placeholder: 'TransactionId',
          ),
        ],
      ),
      FormSectionConfig(
        fields: [
          FormFieldConfig(
            id: 'Comments',
            label: 'resource.RegistrationSubmit.Resource.Comments'.tr(),
            type: FieldType.multiline,
            flex: 4,
            minLength: 0,
            maxLength: 128,
            maxLines: 3,
            required: false,
            readonly: true,
            placeholder: '',
          ),
        ],
      ),
    ];
  }

  /// Get all sections combined
  static List<FormSectionConfig> getAllSections(BuildContext context) {
    return [
      ...getKeyControlSections(context),
      ...getUpsertSections(context),
      ...getPrimaryControlSections(context),
      ...getSecondary1ControlSections(context),
      ...getSecondary2ControlSections(context),
      ...getTertiary1ControlSections(context),
      ...getTertiary2ControlSections(context),
      ...getRemainingControlSections(context),
      ...getAddressControlSections(context),
      ...getTechnicalSpecSections(context),
      ...getStatusSections(context),
    ];
  }

  /// Get all field IDs
  static List<String> getAllFieldIds(BuildContext context) {
    final sections = getAllSections(context);
    final ids = <String>[];

    for (final section in sections) {
      for (final field in section.fields) {
        ids.add(field.id);
      }
    }

    return ids;
  }
}
