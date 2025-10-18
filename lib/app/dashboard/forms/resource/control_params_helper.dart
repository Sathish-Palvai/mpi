import 'dart:convert';
import 'package:flutter/services.dart';

/// Helper class to load and query control parameters for resource types
class ControlParamsHelper {
  static Map<String, dynamic>? _controlParams;
  
  /// Load control parameters from JSON file
  static Future<void> loadControlParams() async {
    if (_controlParams != null) return; // Already loaded
    
    try {
      final String jsonString = await rootBundle.loadString(
        'lib/app/dashboard/forms/controlParams.json',
      );
      final Map<String, dynamic> data = json.decode(jsonString);
      _controlParams = data['controlParams'] as Map<String, dynamic>;
    } catch (e) {
      print('Error loading controlParams.json: $e');
      _controlParams = {};
    }
  }
  
  /// Map ResourceType value to controlParams key
  /// If contractType is '4', returns 'OPSI_PRIME' regardless of resourceType
  static String _mapResourceTypeToKey(String resourceTypeValue, {String? contractTypeValue}) {
    // If ContractType is '4' (ONLY_POWER_SUPPLY_I), use OPSI_PRIME configuration
    if (contractTypeValue == '4') {
      print('🔑 ContractType is 4 (ONLY_POWER_SUPPLY_I) → Using OPSI_PRIME configuration');
      return 'OPSI_PRIME';
    }
    
    String key;
    switch (resourceTypeValue) {
      case '01':
        key = 'THERMAL';
        break;
      case '02':
        key = 'HYDRO';
        break;
      case '03':
        key = 'PUMP';
        break;
      case '04':
        key = 'BATTERY';
        break;
      case '05': // VPP_GEN
      case '06': // VPP_GEN_AND_DEM
      case '07': // VPP_DEM
        key = 'VPP';
        break;
      default:
        key = 'THERMAL'; // Default fallback
    }
    
    print('🔑 ResourceType: $resourceTypeValue, ContractType: $contractTypeValue → Using $key configuration');
    return key;
  }
  
  /// Get field configuration for a specific field and resource type
  /// Returns:
  ///   1 = Required (visible + required)
  ///   0 = Optional (visible + not required)
  ///  -1 = Not applicable (hidden)
  static int getFieldConfig(String resourceTypeValue, String fieldId, {String? contractTypeValue}) {
    if (_controlParams == null) {
      print('Warning: controlParams not loaded yet');
      return 1; // Default to required if not loaded
    }
    
    final resourceTypeKey = _mapResourceTypeToKey(resourceTypeValue, contractTypeValue: contractTypeValue);
    final resourceConfig = _controlParams![resourceTypeKey] as Map<String, dynamic>?;
    
    if (resourceConfig == null) {
      print('Warning: No config found for resource type: $resourceTypeKey');
      return 1; // Default to required
    }
    
    return resourceConfig[fieldId] as int? ?? 1; // Default to required if field not found
  }
  
  /// Check if a field should be visible for the given resource type
  static bool isFieldVisible(String resourceTypeValue, String fieldId, {String? contractTypeValue}) {
    final config = getFieldConfig(resourceTypeValue, fieldId, contractTypeValue: contractTypeValue);
    return config != -1; // Visible if not -1
  }
  
  /// Check if a field should be required for the given resource type
  static bool isFieldRequired(String resourceTypeValue, String fieldId, {String? contractTypeValue}) {
    final config = getFieldConfig(resourceTypeValue, fieldId, contractTypeValue: contractTypeValue);
    return config == 1; // Required only if 1
  }
  
  /// Get list of all field IDs that should be hidden for a resource type
  static List<String> getHiddenFields(String resourceTypeValue, {String? contractTypeValue}) {
    if (_controlParams == null) return [];
    
    final resourceTypeKey = _mapResourceTypeToKey(resourceTypeValue, contractTypeValue: contractTypeValue);
    final resourceConfig = _controlParams![resourceTypeKey] as Map<String, dynamic>?;
    
    if (resourceConfig == null) return [];
    
    final hiddenFields = <String>[];
    resourceConfig.forEach((fieldId, value) {
      if (value == -1) {
        hiddenFields.add(fieldId);
      }
    });
    
    return hiddenFields;
  }
}
