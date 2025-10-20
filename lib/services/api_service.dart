import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../core/user_type.dart';

class ApiService {
  // Use different base URLs for different platforms
  static String get baseUrl {
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:3000/api';  // Android emulator
    } else if (Platform.isIOS) {
      return 'http://localhost:3000/api';  // iOS simulator
    } else {
      return 'http://localhost:3000/api';  // Web/Desktop
    }
  }
  
  // GET request helper
  static Future<Map<String, dynamic>> get(String endpoint, {Map<String, String>? queryParams}) async {
    try {
      Uri uri = Uri.parse('$baseUrl$endpoint');
      if (queryParams != null) {
        uri = uri.replace(queryParameters: queryParams);
      }
      
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
  
  // POST request helper
  static Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> data) async {
    try {
      final url = '$baseUrl$endpoint';
      print('=== HTTP POST REQUEST ===');
      print('URL: $url');
      print('Request body: ${json.encode(data)}');
      
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(data),
      );
      
      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = json.decode(response.body);
        print('Decoded response: $decoded');
        return decoded;
      } else {
        print('HTTP error: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to post data: ${response.statusCode}');
      }
    } catch (e) {
      print('POST request error: $e');
      throw Exception('Network error: $e');
    }
  }

  // PUT request helper
  static Future<Map<String, dynamic>> put(String endpoint, Map<String, dynamic> data) async {
    try {
      final url = '$baseUrl$endpoint';
      print('=== HTTP PUT REQUEST ===');
      print('URL: $url');
      print('Request body: ${json.encode(data)}');
      
      final response = await http.put(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(data),
      );
      
      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = json.decode(response.body);
        print('Decoded response: $decoded');
        return decoded;
      } else {
        print('HTTP error: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to update data: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('PUT request error: $e');
      throw Exception('Network error: $e');
    }
  }
  
  // Participants endpoints
  static Future<List<Map<String, dynamic>>> getParticipants({
    String? search, 
    String? type, 
    String? area,
    UserType? userType,
  }) async {
    // If userType is provided, use the new dynamic info/lists endpoint
    if (userType != null) {
      final participantTypeStr = userType.name.toLowerCase(); // bsp, tso, or mo
      final key = 'registration.participant.$participantTypeStr';
      final response = await get('/info/lists/$key');
      
      // The response structure is: { "Rows": [ {...}, {...} ] }
      if (response.containsKey('Rows')) {
        return List<Map<String, dynamic>>.from(response['Rows']);
      } else if (response.containsKey('data')) {
        return List<Map<String, dynamic>>.from(response['data']);
      } else {
        // Return empty list if structure is unexpected
        return [];
      }
    }
    
    // Fallback to old endpoint with query params if no userType provided
    Map<String, String> queryParams = {};
    if (search != null) queryParams['search'] = search;
    if (type != null) queryParams['type'] = type;
    if (area != null) queryParams['area'] = area;
    
    final response = await get('/participants', queryParams: queryParams);
    return List<Map<String, dynamic>>.from(response['data']);
  }
  
  static Future<Map<String, dynamic>> getParticipant(String id) async {
    final response = await get('/participants/$id');
    return response['data'];
  }
  
  static Future<Map<String, dynamic>> queryParticipant(Map<String, dynamic> queryData) async {
    print('=== FLUTTER API SERVICE ===');
    print('Sending query data: ${json.encode(queryData)}');
    
    try {
      final result = await post('/participants/query', queryData);
      print('Query response received: $result');
      return result;
    } catch (e) {
      print('Query error: $e');
      rethrow;
    }
  }

  /// Query participant using REST-style API
  /// GET /api/registration/participant/:participantName?tradeDate=YYYY-MM-DD
  static Future<Map<String, dynamic>> queryParticipantByName(
    String participantName, {
    String? tradeDate,
  }) async {
    print('=== FLUTTER API SERVICE (REST) ===');
    print('Querying participant: $participantName');
    
    try {
      final queryParams = <String, String>{};
      if (tradeDate != null && tradeDate.isNotEmpty) {
        queryParams['tradeDate'] = tradeDate;
      }
      
      final result = await get(
        '/registration/participant/$participantName',
        queryParams: queryParams,
      );
      
      print('Query response received: $result');
      return result;
    } catch (e) {
      print('Query error: $e');
      rethrow;
    }
  }

  /// Query participant validity records
  /// POST /api/participants/query (ParticipantValidity)
  static Future<Map<String, dynamic>> queryParticipantValidity(
    String participantName, {
    String? date,
  }) async {
    print('=== FLUTTER API SERVICE (VALIDITY QUERY) ===');
    print('Querying participant validity: $participantName, date: $date');
    
    // Build the query structure for ParticipantValidity
    final queryData = {
      'RegistrationData': {
        'RegistrationQuery': {
          'ParticipantValidity': {
            '@ParticipantName': participantName,
            '@TradeDate': date ?? _getCurrentDate(),
          }
        },
        '@xmlns:xsi': 'http://www.w3.org/2001/XMLSchema-instance',
        '@xsi:noNamespaceSchemaLocation': 'mpr.xsd',
      }
    };
    
    try {
      final result = await post('/participants/query', queryData);
      print('Validity query response received: $result');
      return result;
    } catch (e) {
      print('Validity query error: $e');
      rethrow;
    }
  }

  static String _getCurrentDate() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  static Future<Map<String, dynamic>> updateParticipant(String id, Map<String, dynamic> participantData) async {
    return await put('/participants/$id', participantData);
  }
  
  // Users endpoints
  static Future<List<Map<String, dynamic>>> getUsers({String? search, String? status, String? role}) async {
    Map<String, String> queryParams = {};
    if (search != null) queryParams['search'] = search;
    if (status != null) queryParams['status'] = status;
    if (role != null) queryParams['role'] = role;
    
    final response = await get('/users', queryParams: queryParams);
    return List<Map<String, dynamic>>.from(response['data']);
  }

  /// Get users by user type from registration info endpoint
  static Future<List<Map<String, dynamic>>> getUsersByUserType(String userType) async {
    try {
      final userTypeKey = userType.toLowerCase();
      print('>>> Fetching users for userType: $userType (key: $userTypeKey)');
      final response = await get('/info/lists/registration.users.$userTypeKey');
      
      print('>>> Response keys: ${response.keys}');
      print('>>> Response: $response');
      
      // Response format: { "Rows": [...] }
      if (response.containsKey('Rows')) {
        final rows = response['Rows'];
        print('>>> Rows type: ${rows.runtimeType}, Count: ${rows is List ? rows.length : "N/A"}');
        if (rows is List) {
          final result = List<Map<String, dynamic>>.from(rows.map((item) => item as Map<String, dynamic>));
          print('>>> Successfully parsed ${result.length} users');
          return result;
        }
      }
      
      print('>>> No Rows key found in response or invalid format');
      return [];
    } catch (e) {
      print('>>> Error fetching users by type: $e');
      print('>>> Stack trace: ${StackTrace.current}');
      return [];
    }
  }
  
  // Resources endpoints
  static Future<List<Map<String, dynamic>>> getResources({String? search, String? type, String? status}) async {
    Map<String, String> queryParams = {};
    if (search != null) queryParams['search'] = search;
    if (type != null) queryParams['type'] = type;
    if (status != null) queryParams['status'] = status;
    
    final response = await get('/resources', queryParams: queryParams);
    return List<Map<String, dynamic>>.from(response['data']);
  }

  /// Get resources by user type from registration info endpoint
  static Future<List<Map<String, dynamic>>> getResourcesByUserType(String userType) async {
    try {
      final userTypeKey = userType.toLowerCase();
      print('>>> Fetching resources for userType: $userType (key: $userTypeKey)');
      final response = await get('/info/lists/registration.resource.$userTypeKey');
      
      print('>>> Response keys: ${response.keys}');
      print('>>> Response: $response');
      
      // Response format: { "Rows": [...] }
      if (response.containsKey('Rows')) {
        final rows = response['Rows'];
        print('>>> Rows type: ${rows.runtimeType}, Count: ${rows is List ? rows.length : "N/A"}');
        if (rows is List) {
          final result = List<Map<String, dynamic>>.from(rows.map((item) => item as Map<String, dynamic>));
          print('>>> Successfully parsed ${result.length} resources');
          return result;
        }
      }
      
      print('>>> No Rows key found in response or invalid format');
      return [];
    } catch (e) {
      print('>>> Error fetching resources by type: $e');
      print('>>> Stack trace: ${StackTrace.current}');
      return [];
    }
  }
  
  static Future<Map<String, dynamic>> queryResource(Map<String, dynamic> queryData) async {
    print('=== FLUTTER API SERVICE - RESOURCE QUERY ===');
    print('Sending query data: ${json.encode(queryData)}');
    
    try {
      final result = await post('/resources/query', queryData);
      print('Query response received: $result');
      return result;
    } catch (e) {
      print('Query error: $e');
      rethrow;
    }
  }
  
  static Future<Map<String, dynamic>> updateResource(String id, Map<String, dynamic> resourceData) async {
    return await put('/resources/$id', resourceData);
  }
  
  // Registration endpoints
  static Future<Map<String, dynamic>> registrationQuery(Map<String, dynamic> queryData) async {
    return await post('/registration/query', queryData);
  }
  
  static Future<Map<String, dynamic>> registrationSubmit(Map<String, dynamic> submitData) async {
    return await post('/registration/submit', submitData);
  }
  
  // Health check
  static Future<Map<String, dynamic>> healthCheck() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:3000/health'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Health check failed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Health check error: $e');
    }
  }
}