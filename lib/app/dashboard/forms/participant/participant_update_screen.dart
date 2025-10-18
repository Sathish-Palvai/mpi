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
import '../../bloc/dashboard_state.dart';
import 'schemas/participant_update_schema.dart';
import 'participant_query_component.dart';
import '../../../../features/auth/bloc/auth_bloc.dart';
import '../../../../features/auth/bloc/auth_state.dart';
import '../../../../core/user_type.dart';
import '../participant_validity/participant_validity_update_screen.dart';

/// Participant update screen using config-driven form library
///
/// This screen demonstrates how to build forms using the config-driven approach.
/// All form fields, validation rules, and layouts are defined declaratively
/// in ParticipantUpdateSchema, and the form library handles the rest.
class ParticipantUpdateScreen extends StatefulWidget {
  final Map<String, dynamic> participant;

  const ParticipantUpdateScreen({
    super.key,
    required this.participant,
  });

  @override
  State<ParticipantUpdateScreen> createState() =>
      _ParticipantUpdateScreenState();
}

class _ParticipantUpdateScreenState extends State<ParticipantUpdateScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late Map<String, TextEditingController> _controllers;
  late List<FormSectionConfig> _allSections;
  late TabController _tabController;

  bool _isSubmitting = false;
  bool _isLoading = true;
  Map<String, dynamic>? _submissionResponse;
  bool _showResponse = false;

  // Query functionality
  List<String> _participantList = [];
  String? _selectedParticipant;
  bool _isInitialized = false;
  String? _participantType; // Track current participant type

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    // Initialize participant type from widget
    _participantType = widget.participant['@ParticipantType'] ??
        widget.participant['ParticipantType'];
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_isInitialized) {
      _isInitialized = true;
      _allSections = ParticipantUpdateSchema.getAllSections(context,
          participantType: _participantType);
      _controllers = FormControllerHelper.initializeControllers(
        _allSections,
        widget.participant,
      );

      // Load all participants for the dropdown
      _loadParticipantList();

      // Perform initial backend query to load participant data immediately
      _performInitialQuery();
    }
  }

  /// Rebuild sections when participant type changes
  void _rebuildSections(String? newParticipantType) {
    if (newParticipantType != _participantType) {
      setState(() {
        _participantType = newParticipantType;
        // Get current form data before rebuilding
        final currentData = FormControllerHelper.getFormData(_controllers);

        // Dispose old controllers
        FormControllerHelper.disposeControllers(_controllers);

        // Rebuild sections with new participant type
        _allSections = ParticipantUpdateSchema.getAllSections(context,
            participantType: _participantType);

        // Reinitialize controllers with current data
        _controllers = FormControllerHelper.initializeControllers(
          _allSections,
          currentData,
        );
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    FormControllerHelper.disposeControllers(_controllers);
    super.dispose();
  }

  /// Perform initial query to load participant data from backend
  Future<void> _performInitialQuery() async {
    try {
      final queryData = _buildQueryStructure(
        widget.participant['ParticipantName'] ?? widget.participant['id'],
        _getCurrentDate(),
      );

      // Use real backend API call
      final response = await ApiService.queryParticipant(queryData);

      if (mounted) {
        // Update form fields with the query response
        final registrationData = response['RegistrationData'];
        final registrationSubmit = registrationData?['RegistrationSubmit'];
        final participant = registrationSubmit?['Participant'];

        if (participant != null) {
          debugPrint(
              '✅ Initial query - participant data found, updating fields');
          _updateFieldsFromResponse(participant);
        } else {
          debugPrint('❌ Initial query - no participant data found');
        }

        // Set everything together in one setState
        setState(() {
          _submissionResponse = response;
          _showResponse = true;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Initial query error: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Build query structure for participant lookup
  Map<String, dynamic> _buildQueryStructure(
      String participantName, String tradeDate) {
    return {
      "RegistrationData": {
        "RegistrationQuery": {
          "Participant": {
            "@ParticipantName": participantName,
            "@TradeDate": tradeDate
          }
        },
        "@xmlns:xsi": "http://www.w3.org/2001/XMLSchema-instance",
        "@xsi:noNamespaceSchemaLocation": "mpr.xsd"
      }
    };
  }

  /// Get current date in yyyy-MM-dd format
  String _getCurrentDate() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  /// Update form fields from backend response
  void _updateFieldsFromResponse(Map<String, dynamic> participant) {
    debugPrint('=== UPDATING FORM FIELDS ===');
    debugPrint('Participant data: $participant');

    // Check if participant type changed and rebuild sections if needed
    final newParticipantType = participant['@ParticipantType'];
    if (newParticipantType != null) {
      _rebuildSections(newParticipantType);
    }

    // Update text controllers with backend data
    // Field IDs must match the schema exactly
    final fieldsToUpdate = {
      'ParticipantName': participant['@ParticipantName'],
      'ParticipantType': participant['@ParticipantType'],
      'Area': participant['@Area'],
      'StartDate': participant['@StartDate'],
      'EndDate': participant['@EndDate'],
      'CompanyShortName':
          participant['@CompanyShortName'] ?? participant['@Company'],
      'CompanyLongName': participant['@CompanyLongName'],
      'PhonePart1': participant['@PhonePart1'],
      'PhonePart2': participant['@PhonePart2'],
      'PhonePart3': participant['@PhonePart3'],
    };

    fieldsToUpdate.forEach((fieldId, value) {
      if (value != null && _controllers.containsKey(fieldId)) {
        _controllers[fieldId]!.text = value.toString();
        debugPrint('✅ Updated $fieldId: $value');
      } else if (value != null) {
        debugPrint('⚠️ Field $fieldId not found in controllers');
      }
    });

    setState(() {});
  }

  /// Load participant list from dashboard state
  void _loadParticipantList() {
    final dashboardBloc = context.read<DashboardBloc>();
    final state = dashboardBloc.state;
    if (state is DashboardLoaded) {
      setState(() {
        _participantList = state.allParticipants
            .map((p) => p['ParticipantName'] as String? ?? p['id'] as String)
            .toSet() // Remove duplicates
            .toList();

        // Pre-select current participant if available
        final currentParticipantName =
            widget.participant['ParticipantName'] ?? widget.participant['id'];
        if (_participantList.contains(currentParticipantName)) {
          _selectedParticipant = currentParticipantName;
        }
      });
    }
  }

  /// Show query bottom sheet using the query component
  void _showQueryBottomSheet() {
    ParticipantQueryComponent.show(
      context: context,
      participantList: _participantList,
      initialParticipant: _selectedParticipant,
      initialTradeDate: _getCurrentDate(),
      onQueryComplete: (response, participant) {
        // Handle query completion
        setState(() {
          _submissionResponse = response;
          _showResponse = true;
        });

        // Update form fields with participant data
        _updateFieldsFromResponse(participant);
      },
    );
  }

  /// Handle date field tap
  void _pickDate(String fieldId) async {
    await FormFieldBuilder.pickDate(
      context: context,
      controller: _controllers[fieldId]!,
    );
  }

  /// Save participant data
  Future<void> _saveParticipant() async {
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
              "ParticipantName": formData['ParticipantName'] ?? '',
              "ParticipantType": formData['ParticipantType'] ?? '',
              "Area": formData['Area'] ?? '',
              "StartDate": formData['StartDate'] ?? '',
              "EndDate": formData['EndDate'] ?? '',
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

      debugPrint('Saving participant data: $submitData');
      debugPrint('Form data: $formData');

      final response = await ApiService.updateParticipant(
          widget.participant['id'], submitData);

      if (mounted) {
        setState(() {
          _submissionResponse = response;
          _showResponse = true;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Participant saved successfully'),
            backgroundColor: Colors.green,
          ),
        );

        // Refresh the dashboard data
        final authState = context.read<AuthBloc>().state;
        final userType =
            authState is AuthAuthenticated ? authState.userType : UserType.BSP;
        context
            .read<DashboardBloc>()
            .add(LoadDashboardData(userType: userType));

        // Don't navigate back automatically - let user review the response
        // context.pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _submissionResponse = {
            'RegistrationData': {
              'RegistrationSubmit': {
                'Messages': {
                  'Error': {'#text': 'Error saving participant: $e'},
                },
              },
            },
          };
          _showResponse = true;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving participant: $e'),
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
        title: Text('participant.header.title'.tr()),
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
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Participant'),
            Tab(text: 'Participant Validity'),
            Tab(text: 'Bank Account'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showQueryBottomSheet,
        backgroundColor: theme.brightness == Brightness.dark
            ? const Color(0xFF2A2A2A) // Lighter shade of black for dark mode
            : theme.colorScheme.primary, // Primary color for light mode
        foregroundColor: Colors.white,
        tooltip: 'participant.header.queryTitle'.tr(),
        child: const Icon(Icons.search),
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Loading participant data...',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            )
          : TabBarView(
              controller: _tabController,
              children: [
                _buildParticipantTab(),
                ParticipantValidityUpdateScreen(
                  participantName: widget.participant['ParticipantName'] ??
                      widget.participant['id'],
                ),
                _buildPlaceholderTab('Bank Account'),
              ],
            ),
    );
  }

  Widget _buildParticipantTab() {
    final theme = Theme.of(context);

    return SingleChildScrollView(
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
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: theme.brightness == Brightness.dark
                          ? const Color(
                              0xFF2A2A2A) // Lighter shade of black for dark mode
                          : const Color(0xFF283593), // Deep blue for light mode
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(11),
                        topRight: Radius.circular(11),
                      ),
                    ),
                    child: Text(
                      'participant.tabs.generalTab'.tr(),
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

            // Submit button
            Center(
              child: SizedBox(
                height: 50,
                child: OutlinedButton(
                  onPressed: _isSubmitting ? null : _saveParticipant,
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Theme.of(context).cardColor,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_isSubmitting
                          ? 'participant.buttons.saving'.tr()
                          : 'participant.buttons.submit'.tr()),
                      const SizedBox(width: 8),
                      _isSubmitting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.send, size: 20),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Note about start date restriction
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.amber.shade200,
                  width: 1,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 20,
                    color: Colors.amber.shade700,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'participant.notes.startDateRestriction'.tr(),
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.amber.shade900,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderTab(String tabName) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.construction,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            '$tabName tab coming soon',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}
