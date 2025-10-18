import 'package:flutter/material.dart' hide FormFieldBuilder;
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../shared/widgets/app_drawer.dart';
import '../../../../widgets/notification_icon.dart';
import '../../../../core/forms/forms.dart';
import '../../../../services/api_service.dart';
import '../../bloc/dashboard_bloc.dart';
import '../../bloc/dashboard_event.dart';
import 'schemas/participant_create_schema.dart';
import '../../../../features/auth/bloc/auth_bloc.dart';
import '../../../../features/auth/bloc/auth_state.dart';
import '../../../../core/user_type.dart';

/// Participant create screen using config-driven form library
/// 
/// This screen demonstrates how to build forms using the config-driven approach.
/// All form fields, validation rules, and layouts are defined declaratively
/// in ParticipantCreateSchema, and the form library handles the rest.
class ParticipantCreateScreen extends StatefulWidget {
  const ParticipantCreateScreen({super.key});

  @override
  State<ParticipantCreateScreen> createState() =>
      _ParticipantCreateScreenState();
}

class _ParticipantCreateScreenState
    extends State<ParticipantCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  late final Map<String, TextEditingController> _controllers;
  late final List<FormSectionConfig> _allSections;

  bool _isSubmitting = false;
  Map<String, dynamic>? _submissionResponse;
  bool _showResponse = false;
  
  // Fixed domain values
  final String _participantType = 'BALANCING_SERVICE_PROVIDER';
  final String _area = '';
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    if (!_isInitialized) {
      _isInitialized = true;
      _allSections = ParticipantCreateSchema.getAllSections(context);
      _controllers = FormControllerHelper.initializeControllers(
        _allSections,
        {}, // Empty initial data for create
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
    
    // Clear all controllers except ParticipantType
    _controllers.forEach((key, controller) {
      if (key != 'ParticipantType') {
        controller.clear();
      }
    });
    
    setState(() {
      _submissionResponse = null;
      _showResponse = false;
    });
  }

  /// Handle date field tap
  void _pickDate(String fieldId) async {
    await FormFieldBuilder.pickDate(
      context: context,
      controller: _controllers[fieldId]!,
    );
  }

  /// Submit participant data to create new participant
  Future<void> _submitParticipant() async {
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
      
      // Build the proper structure for submission (without @ prefix for field names)
      final submitData = {
        "RegistrationData": {
          "RegistrationSubmit": {
            "Participant": {
              "ParticipantType": _participantType,
              "Area": _area,
              "StartDate": formData['StartDate'] ?? '',
              "Company": formData['CompanyShortName'] ?? '',
              "CompanyShortName": formData['CompanyShortName'] ?? '',
              "CompanyLongName": formData['CompanyLongName'] ?? '',
              "PhonePart1": formData['PhonePart1'] ?? '',
              "PhonePart2": formData['PhonePart2'] ?? '',
              "PhonePart3": formData['PhonePart3'] ?? '',
            }
          }
        }
      };

      debugPrint('Creating participant: $submitData');
      debugPrint('Form data: $formData');
      
      final response = await ApiService.post('/participants', submitData);

      if (mounted) {
        setState(() {
          _submissionResponse = response;
          _showResponse = true;
          
          // Extract and set the generated ParticipantName
          final generated = response['RegistrationData']?['RegistrationSubmit']?['Participant']?['@ParticipantName'];
          if (generated != null) {
            final sanitized = generated.length > 4 ? generated.substring(0, 4) : generated;
            _controllers['ParticipantName']!.text = sanitized;
            
            if (generated.length > 4) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Participant name trimmed to first 4 chars (max length = 4).'),
                  backgroundColor: Colors.orange.shade700,
                ),
              );
            }
          }
        });

        final pn = _controllers['ParticipantName']!.text.isEmpty 
            ? 'Unknown' 
            : _controllers['ParticipantName']!.text;
            
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Participant created successfully with name: $pn'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Refresh the dashboard data
        final authState = context.read<AuthBloc>().state;
        final userType = authState is AuthAuthenticated ? authState.userType : UserType.BSP;
        context.read<DashboardBloc>().add(LoadDashboardData(userType: userType));
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _submissionResponse = {
            'RegistrationData': {
              'RegistrationSubmit': {
                'Messages': {
                  'Error': {'#text': 'Error creating participant: $e'},
                },
              },
            },
          };
          _showResponse = true;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add participant: $e'),
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      drawer: const AppDrawer(),
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text('participant.header.newTitle'.tr()),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/dashboard'),
        ),
        actions: [
          const Padding(
            padding: EdgeInsets.only(right: 8.0),
            child: SizedBox(width: 40, height: 40, child: NotificationIcon()),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Response messages
              ResponseMessagesCard(
                response: _submissionResponse,
                visible: _showResponse,
                title: 'Messages',
              ),
              if (_showResponse) const SizedBox(height: 18),

              // General Details Card
              Card(
                elevation: 0.5,
                color: Theme.of(context).cardColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: Theme.of(context).dividerColor.withOpacity(0.5),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: theme.brightness == Brightness.dark 
                            ? const Color(0xFF2A2A2A)  // Lighter shade of black for dark mode
                            : const Color(0xFF283593), // Deep blue for light mode
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(11),
                          topRight: Radius.circular(11),
                        ),
                      ),
                      child: Text(
                        'General Details',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),
                          // Build all form sections using the library
                          ..._allSections.map((section) {
                            return FormFieldBuilder.buildSection(
                              context: context,
                              section: section,
                              controllers: _controllers,
                              onDateFieldTap: _pickDate,
                            );
                          }),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),
              
              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _isSubmitting ? null : _resetForm,
                      icon: const Icon(Icons.refresh),
                      label: Text('participant.buttons.reset'.tr()),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Theme.of(context).cardColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _isSubmitting ? null : _submitParticipant,
                      icon: _isSubmitting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.add),
                      label: Text(_isSubmitting ? 'participant.buttons.creating'.tr() : 'participant.buttons.create'.tr()),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Theme.of(context).cardColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
