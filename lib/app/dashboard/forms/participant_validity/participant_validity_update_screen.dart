import 'package:flutter/material.dart' hide FormFieldBuilder;
import '../../../../services/api_service.dart';
import '../../../../core/forms/forms.dart';
import 'schemas/participant_validity_create_schema.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/dashboard_bloc.dart';
import '../../bloc/dashboard_event.dart';
import '../../../../features/auth/bloc/auth_bloc.dart';
import '../../../../features/auth/bloc/auth_state.dart';
import '../../../../core/user_type.dart';

/// Participant Validity Update Screen
/// 
/// Displays participant validity records in a grid/table format.
/// Multiple records can be displayed for a single participant.
/// Includes form to add new participant validity records.
class ParticipantValidityUpdateScreen extends StatefulWidget {
  final String? participantName;

  const ParticipantValidityUpdateScreen({
    super.key,
    this.participantName,
  });

  @override
  State<ParticipantValidityUpdateScreen> createState() => _ParticipantValidityUpdateScreenState();
}

class _ParticipantValidityUpdateScreenState extends State<ParticipantValidityUpdateScreen> {
  bool _isLoading = false;
  List<Map<String, dynamic>> _validityRecords = [];
  Map<String, dynamic>? _lastResponse;
  bool _showResponse = false;
  
  // Form-related state
  final _formKey = GlobalKey<FormState>();
  late final Map<String, TextEditingController> _controllers;
  late final List<FormSectionConfig> _allSections;
  bool _isSubmitting = false;
  Map<String, dynamic>? _submissionResponse;
  bool _showSubmitResponse = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    
    // Auto-query if participant name is provided
    if (widget.participantName != null && widget.participantName!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _queryValidity(widget.participantName!);
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    if (!_isInitialized) {
      _isInitialized = true;
      _allSections = ParticipantValidityCreateSchema.getAllSections(context);
      
      // Initialize with participant name if provided
      final initialData = widget.participantName != null
          ? {
              'ParticipantName': widget.participantName,
              'ParticipantState': 'DEREGISTERED', // Default state
            }
          : {
              'ParticipantState': 'DEREGISTERED', // Default state
            };
      
      _controllers = FormControllerHelper.initializeControllers(
        _allSections,
        initialData,
      );
    }
  }

  @override
  void dispose() {
    FormControllerHelper.disposeControllers(_controllers);
    super.dispose();
  }

  /// Reset the form to initial state
  void _resetForm() {
    _formKey.currentState?.reset();
    
    // Clear all controllers except readonly fields
    _controllers.forEach((key, controller) {
      if (key != 'ParticipantName' && key != 'ParticipantState' && key != 'TransactionId') {
        controller.clear();
      }
    });
    
    setState(() {
      _submissionResponse = null;
      _showSubmitResponse = false;
    });
  }

  /// Handle date field tap
  void _pickDate(String fieldId) async {
    await FormFieldBuilder.pickDate(
      context: context,
      controller: _controllers[fieldId]!,
    );
  }

  /// Submit participant validity data to create new record
  Future<void> _submitParticipantValidity() async {
    if (!FormControllerHelper.validateForm(_formKey)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fix the errors in the form'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final formData = FormControllerHelper.getFormData(_controllers);
      
      // Build the proper structure for submission
      final submitData = {
        "RegistrationData": {
          "RegistrationSubmit": {
            "ParticipantValidity": {
              "ParticipantName": formData['ParticipantName'] ?? '',
              "ParticipantState": formData['ParticipantState'] ?? 'REGISTERED',
              "StartDate": formData['StartDate'] ?? '',
            }
          }
        }
      };

      debugPrint('Creating participant validity: $submitData');
      
      final response = await ApiService.post('/participants/validity', submitData);

      if (mounted) {
        setState(() {
          _submissionResponse = response;
          _showSubmitResponse = true;
          
          // Extract and set the generated TransactionId if present
          final transactionId = response['RegistrationData']?['RegistrationSubmit']?['ParticipantValidity']?['@TransactionId'];
          if (transactionId != null) {
            _controllers['TransactionId']?.text = transactionId.toString();
          }
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Participant validity created successfully'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Refresh the dashboard data
        final authState = context.read<AuthBloc>().state;
        final userType = authState is AuthAuthenticated ? authState.userType : UserType.BSP;
        context.read<DashboardBloc>().add(LoadDashboardData(userType: userType));
        
        // Re-query the validity records to show the newly added record
        if (widget.participantName != null && widget.participantName!.isNotEmpty) {
          await _queryValidity(widget.participantName!);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _submissionResponse = {
            'RegistrationData': {
              'RegistrationSubmit': {
                'Messages': {
                  'Error': {'#text': 'Error creating participant validity: $e'},
                },
              },
            },
          };
          _showSubmitResponse = true;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create participant validity: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }


  Future<void> _queryValidity(String participantName) async {
    setState(() => _isLoading = true);

    try {
      final response = await ApiService.queryParticipantValidity(participantName);
      
      if (mounted) {
        _handleQueryComplete(response, _extractValidityRecords(response));
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Query failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  List<dynamic> _extractValidityRecords(Map<String, dynamic> response) {
    final registrationData = response['RegistrationData'];
    final registrationSubmit = registrationData?['RegistrationSubmit'];
    final validityRecords = registrationSubmit?['ParticipantValidity'] ?? [];
    return validityRecords is List ? validityRecords : [];
  }

  void _handleQueryComplete(Map<String, dynamic> response, List<dynamic> validityRecords) {
    setState(() {
      _lastResponse = response;
      _isLoading = false;
      _showResponse = true;
      
      // Convert to list of maps for easier display
      _validityRecords = validityRecords.map((record) {
        return {
          'ParticipantName': record['ParticipantName']?.toString() ?? '',
          'StartDate': record['StartDate']?.toString() ?? '',
          'EndDate': record['EndDate']?.toString() ?? '',
          'ParticipantState': record['ParticipantState']?.toString() ?? '',
          'TransactionId': record['TransactionId']?.toString() ?? '',
        };
      }).toList();
    });

  }

  Widget _buildDataGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Blue Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF3949AB), // Blue color from image
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
          ),
          child: Text(
            'Participant Validity',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        
        // Table
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(Colors.white),
                border: TableBorder(
                  horizontalInside: BorderSide(color: Colors.grey[300]!, width: 1),
                  bottom: BorderSide(color: Colors.grey[300]!, width: 1),
                ),
                columnSpacing: 40,
                columns: const [
                  DataColumn(
                    label: Text(
                      '#',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Participant Name *',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Start Date *',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'End Date',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Participant State *',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Transaction Id',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
                rows: _validityRecords.asMap().entries.map((entry) {
                  final index = entry.key + 1;
                  final record = entry.value;
                  return DataRow(
                    cells: [
                      DataCell(Text(index.toString())),
                      DataCell(Text(record['ParticipantName'] ?? '')),
                      DataCell(Text(record['StartDate'] ?? '')),
                      DataCell(Text(record['EndDate'] ?? '')),
                      DataCell(Text(record['ParticipantState'] ?? '')),
                      DataCell(Text(record['TransactionId'] ?? '')),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNotesSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Notes',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'This is a validity note',
            style: TextStyle(
              fontSize: 14,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInitialState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search,
            size: 100,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 20),
          Text(
            'Click Query to search for participant validity records',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_validityRecords.isEmpty && _lastResponse == null) {
      return _buildInitialState();
    }

    // Get current user type
    final authState = context.watch<AuthBloc>().state;
    final userType = authState is AuthAuthenticated ? authState.userType : UserType.BSP;
    final isMOUser = userType == UserType.MO;

    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
              // Response messages for query
              ResponseMessagesCard(
                response: _lastResponse,
                visible: _showResponse,
                title: 'Query Messages',
              ),
              if (_showResponse) const SizedBox(height: 18),
              
              // Data grid - only show if we have records
              if (_validityRecords.isNotEmpty) ...[
                SizedBox(
                  height: 400, // Fixed height for the grid
                  child: _buildDataGrid(),
                ),
                const SizedBox(height: 24),
              ],
              
              // Response messages for submission
              ResponseMessagesCard(
                response: _submissionResponse,
                visible: _showSubmitResponse,
                title: 'Submission Messages',
              ),
              if (_showSubmitResponse) const SizedBox(height: 18),
              
              // Add New Participant Validity Form - Only for MO users
              if (isMOUser) ...[
                _buildCreateForm(),
                const SizedBox(height: 16),
              ],
              
              // Notes Section - After the form
              _buildNotesSection(),
            ],
          ),
        ),
      );
  }

  Widget _buildCreateForm() {
    final theme = Theme.of(context);
    
    return Card(
      elevation: 0.5,
      color: theme.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: theme.dividerColor.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with blue background
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: theme.brightness == Brightness.dark 
                  ? const Color(0xFF2A2A2A)
                  : const Color(0xFF283593),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(11),
                topRight: Radius.circular(11),
              ),
            ),
            child: Text(
              'Add New Participant Validity',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
          
          // Form fields
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                // Build all form sections using the library
                ..._allSections.map((section) {
                  return FormFieldBuilder.buildSection(
                    context: context,
                    section: section,
                    controllers: _controllers,
                    onDateFieldTap: _pickDate,
                  );
                }),
                const SizedBox(height: 20),
                
                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _isSubmitting ? null : _resetForm,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Reset'),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: theme.cardColor,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isSubmitting ? null : _submitParticipantValidity,
                        icon: _isSubmitting
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.send),
                        label: Text(_isSubmitting ? 'Submitting...' : 'Submit'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1976D2),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
