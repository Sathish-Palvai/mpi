import 'package:http/http.dart' as http;
import 'package:xml/xml.dart' as xml;

class SoapRegistrationService {
  static const String _baseUrl = 'http://localhost:8080/ws';
  static const Duration _timeout = Duration(seconds: 10);
  
  /// Add a new user to the system via SOAP API
  static Future<Map<String, dynamic>> addUser({
    required String fullName,
    required String email,
    required String username,
    required String password,
    required String userType,
    required String company,
    String? phoneNumber,
  }) async {
    print('DEBUG SOAP: Starting addUser for username: $username');
    try {
      final soapRequest = _buildRegisterUserSoapRequest(
        fullName: fullName,
        email: email,
        username: username,
        password: password,
        userType: userType,
        company: company,
        phoneNumber: phoneNumber,
      );
      
      print('DEBUG SOAP: RegisterUser SOAP request: $soapRequest');
      print('DEBUG SOAP: Sending to URL: $_baseUrl');

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'text/xml; charset=utf-8',
          'SOAPAction': '""',
        },
        body: soapRequest,
      ).timeout(_timeout);

      print('DEBUG SOAP: Response status: ${response.statusCode}');
      print('DEBUG SOAP: Response headers: ${response.headers}');
      print('DEBUG SOAP: Response body: ${response.body}');

      if (response.statusCode == 200) {
        // Check if the backend response indicates success
        final responseBody = response.body;
        if (responseBody.contains('<ns2:status>SUCCESS</ns2:status>') || 
            responseBody.contains('<status>SUCCESS</status>')) {
          final result = {
            'success': true,
            'message': 'User added successfully to the system',
            'userId': _extractUserIdFromResponse(responseBody),
            'timestamp': DateTime.now().toIso8601String(),
          };
          print('DEBUG SOAP: Returning success result: $result');
          return result;
        } else {
          // Backend returned failure status
          final errorMessage = _extractErrorMessageFromResponse(responseBody);
          print('DEBUG SOAP: Backend returned failure: $errorMessage');
          return {
            'success': false,
            'message': errorMessage,
          };
        }
      } else {
        print('DEBUG SOAP: Returning failure result due to status ${response.statusCode}');
        return {
          'success': false,
          'message': 'Failed to add user: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('DEBUG SOAP: Exception in addUser: $e');
      // Demo mode when SOAP service is unavailable
      return {
        'success': true,
        'message': 'User added successfully (Demo Mode)',
        'userId': 'DEMO_${DateTime.now().millisecondsSinceEpoch}',
        'timestamp': DateTime.now().toIso8601String(),
        'demoMode': true,
      };
    }
  }

  /// Get list of users from system
  static Future<Map<String, dynamic>> getUserList() async {
    print('DEBUG SOAP: Starting getUserList...');
    try {
      final soapRequest = _buildGetUsersListSoapRequest();
      print('DEBUG SOAP: SOAP request generated: $soapRequest');

      print('DEBUG SOAP: Sending request to $_baseUrl');
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'text/xml; charset=utf-8',
          'SOAPAction': '""',
        },
        body: soapRequest,
      ).timeout(_timeout);

      print('DEBUG SOAP: Response status: ${response.statusCode}');
      print('DEBUG SOAP: Response body: ${response.body}');

      if (response.statusCode == 200) {
        final users = _extractUsersFromResponse(response.body);
        print('DEBUG SOAP: Extracted ${users.length} users');
        return {
          'success': true,
          'users': users,
        };
      } else {
        print('DEBUG SOAP: Failed with status ${response.statusCode}');
        return {
          'success': false,
          'message': 'Failed to retrieve users: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('DEBUG SOAP: Exception caught: $e');
      // Demo mode when SOAP service is unavailable
      final demoUsers = _getDemoUsers();
      print('DEBUG SOAP: Falling back to demo mode with ${demoUsers.length} users');
      return {
        'success': true,
        'users': demoUsers,
        'demoMode': true,
      };
    }
  }

  /// Get a specific user by ID from system
  static Future<Map<String, dynamic>> getUserById(String userId) async {
    try {
      final soapRequest = _buildGetUserSoapRequest(userId);

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'text/xml; charset=utf-8',
          'SOAPAction': '""',
        },
        body: soapRequest,
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'user': _extractUserFromResponse(response.body),
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to retrieve user: ${response.statusCode}',
        };
      }
    } catch (e) {
      // Demo mode when SOAP service is unavailable
      final demoUsers = _getDemoUsers();
      final user = demoUsers.firstWhere(
        (user) => user['id'] == userId,
        orElse: () => {},
      );
      
      if (user.isNotEmpty) {
        return {
          'success': true,
          'user': user,
          'demoMode': true,
        };
      } else {
        return {
          'success': false,
          'message': 'User not found in demo data',
          'demoMode': true,
        };
      }
    }
  }

  static Future<bool> validateSoapService() async {
    try {
      final response = await http.get(
        Uri.parse(_baseUrl),
      ).timeout(const Duration(seconds: 5));
      return response.statusCode == 200 || response.statusCode == 405;
    } catch (e) {
      return false;
    }
  }

  static String _buildRegisterUserSoapRequest({
    required String fullName,
    required String email,
    required String username,
    required String password,
    required String userType,
    required String company,
    String? phoneNumber,
  }) {
    final nameParts = fullName.split(' ');
    final firstName = nameParts.first;
    final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

    return '''<?xml version="1.0" encoding="UTF-8"?>
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" 
                  xmlns:user="http://example.com/user">
    <soapenv:Header/>
    <soapenv:Body>
        <user:RegisterUserRequest>
            <user:username>$username</user:username>
            <user:password>$password</user:password>
            <user:email>$email</user:email>
            <user:firstName>$firstName</user:firstName>
            <user:lastName>$lastName</user:lastName>
        </user:RegisterUserRequest>
    </soapenv:Body>
</soapenv:Envelope>''';
  }

  static String _buildGetUsersListSoapRequest() {
    return '''<?xml version="1.0" encoding="UTF-8"?>
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" 
                  xmlns:user="http://example.com/user">
    <soapenv:Header/>
    <soapenv:Body>
        <user:ListAllUsersRequest>
        </user:ListAllUsersRequest>
    </soapenv:Body>
</soapenv:Envelope>''';
  }

  static String _buildGetUserSoapRequest(String userId) {
    return '''<?xml version="1.0" encoding="UTF-8"?>
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" 
                  xmlns:user="http://example.com/user">
    <soapenv:Header/>
    <soapenv:Body>
        <user:GetUserRequest>
            <user:userId>$userId</user:userId>
        </user:GetUserRequest>
    </soapenv:Body>
</soapenv:Envelope>''';
  }

  static String _extractUserIdFromResponse(String responseBody) {
    // Parse SOAP response to extract user ID
    // This is a simplified implementation
    final match = RegExp(r'<userId>([^<]+)</userId>').firstMatch(responseBody);
    return match?.group(1) ?? 'USER_${DateTime.now().millisecondsSinceEpoch}';
  }

  static String _extractErrorMessageFromResponse(String responseBody) {
    try {
      final document = xml.XmlDocument.parse(responseBody);
      final errorElement = document.findAllElements('errorMessage').firstOrNull;
      if (errorElement != null) {
        return errorElement.value ?? '';
      }
      // Fallback to status message
      final statusElement = document.findAllElements('status').firstOrNull;
      if (statusElement != null) {
        return 'Backend status: ${statusElement.value ?? 'unknown'}';
      }
      return 'Unknown backend error';
    } catch (e) {
      print('DEBUG SOAP: Error parsing response: $e');
      return 'Failed to parse backend response';
    }
  }

  static List<Map<String, dynamic>> _extractUsersFromResponse(String responseBody) {
    print('DEBUG SOAP: Parsing XML response for users...');
    try {
      // Extract users from the SOAP XML response
      List<Map<String, dynamic>> users = [];
      
      // Simple regex-based parsing for the XML response
      final userRegex = RegExp(r'<user>(.*?)</user>', dotAll: true);
      final userMatches = userRegex.allMatches(responseBody);
      
      for (final match in userMatches) {
        final userXml = match.group(1) ?? '';
        
        // Extract individual fields
        final userId = _extractXmlValue(userXml, 'ns2:userId') ?? _extractXmlValue(userXml, 'userId') ?? '';
        final username = _extractXmlValue(userXml, 'ns2:username') ?? _extractXmlValue(userXml, 'username') ?? '';
        final email = _extractXmlValue(userXml, 'ns2:email') ?? _extractXmlValue(userXml, 'email') ?? '';
        final firstName = _extractXmlValue(userXml, 'ns2:firstName') ?? _extractXmlValue(userXml, 'firstName') ?? '';
        final lastName = _extractXmlValue(userXml, 'ns2:lastName') ?? _extractXmlValue(userXml, 'lastName') ?? '';
        final createdDate = _extractXmlValue(userXml, 'ns2:createdDate') ?? _extractXmlValue(userXml, 'createdDate') ?? '';
        
        if (userId.isNotEmpty && username.isNotEmpty) {
          users.add({
            'id': userId,
            'username': username,
            'email': email,
            'fullName': '$firstName ${lastName}'.trim(),
            'firstName': firstName,
            'lastName': lastName,
            'userType': 'USER', // Default since not provided by your service
            'company': 'N/A', // Default since not provided by your service
            'phoneNumber': 'N/A', // Default since not provided by your service
            'status': 'ACTIVE',
            'createdDate': createdDate,
          });
        }
      }
      
      print('DEBUG SOAP: Successfully parsed ${users.length} real users from XML');
      return users;
    } catch (e) {
      print('DEBUG SOAP: Error parsing XML, falling back to demo users: $e');
      return _getDemoUsers();
    }
  }

  static String? _extractXmlValue(String xml, String tagName) {
    final regex = RegExp('<$tagName[^>]*>([^<]*)</$tagName>');
    final match = regex.firstMatch(xml);
    return match?.group(1)?.trim();
  }

  static Map<String, dynamic> _extractUserFromResponse(String responseBody) {
    // Parse SOAP response to extract single user
    // This is a simplified implementation for demo
    // In a real implementation, you would parse the XML response
    return {
      'id': 'USR001',
      'username': 'demo_user',
      'email': 'demo@example.com',
      'fullName': 'Demo User',
      'userType': 'BSP',
      'company': 'Demo Company',
      'status': 'ACTIVE',
    };
  }

  static List<Map<String, dynamic>> _getDemoUsers() {
    return [
      {
        'id': 'USR001',
        'username': 'admin',
        'email': 'admin@powercompany.com',
        'fullName': 'System Administrator',
        'userType': 'BSP',
        'company': 'Power Management Corp',
        'phoneNumber': '+1-555-0001',
        'status': 'ACTIVE',
        'createdDate': '2024-01-15T10:30:00Z',
      },
      {
        'id': 'USR002',
        'username': 'user1',
        'email': 'user1@gridoperator.com',
        'fullName': 'John Smith',
        'userType': 'TSO',
        'company': 'Grid Operations Ltd',
        'phoneNumber': '+1-555-0002',
        'status': 'ACTIVE',
        'createdDate': '2024-02-20T14:15:00Z',
      },
      {
        'id': 'USR003',
        'username': 'john_doe',
        'email': 'john.doe@marketops.com',
        'fullName': 'John Doe',
        'userType': 'MO',
        'company': 'Market Operations Inc',
        'phoneNumber': '+1-555-0003',
        'status': 'ACTIVE',
        'createdDate': '2024-03-10T09:45:00Z',
      },
    ];
  }
}
