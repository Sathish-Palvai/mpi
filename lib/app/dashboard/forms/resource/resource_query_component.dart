import 'package:flutter/material.dart' hide FormFieldBuilder;
import '../../../../core/forms/forms.dart';
import '../../../../services/api_service.dart';
import 'schemas/resource_query_schema.dart';

/// Callback type for when query is completed
typedef OnResourceQueryComplete = void Function(Map<String, dynamic> response, Map<String, dynamic> resource);

/// Resource Query Component
/// 
/// A reusable bottom sheet component for querying resource data.
/// Uses config-driven forms library for consistent UI and validation.
class ResourceQueryComponent {
  /// Show the query bottom sheet
  static void show({
    required BuildContext context,
    required List<String> participantList,
    required List<String> resourceList,
    String? initialParticipant,
    String? initialResource,
    String? initialDate,
    String? initialRecordStatus,
    required OnResourceQueryComplete onQueryComplete,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) {
        return _QueryBottomSheetContent(
          participantList: participantList,
          resourceList: resourceList,
          initialParticipant: initialParticipant,
          initialResource: initialResource,
          initialDate: initialDate,
          initialRecordStatus: initialRecordStatus,
          onQueryComplete: onQueryComplete,
          parentContext: context,
        );
      },
    );
  }
}

class _QueryBottomSheetContent extends StatefulWidget {
  final List<String> participantList;
  final List<String> resourceList;
  final String? initialParticipant;
  final String? initialResource;
  final String? initialDate;
  final String? initialRecordStatus;
  final OnResourceQueryComplete onQueryComplete;
  final BuildContext parentContext;

  const _QueryBottomSheetContent({
    required this.participantList,
    required this.resourceList,
    this.initialParticipant,
    this.initialResource,
    this.initialDate,
    this.initialRecordStatus,
    required this.onQueryComplete,
    required this.parentContext,
  });

  @override
  State<_QueryBottomSheetContent> createState() => _QueryBottomSheetContentState();
}

class _QueryBottomSheetContentState extends State<_QueryBottomSheetContent> {
  final _formKey = GlobalKey<FormState>();
  late final Map<String, TextEditingController> _controllers;
  late final List<FormSectionConfig> _sections;
  bool _isQuerying = false;
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    if (!_isInitialized) {
      _isInitialized = true;
      
      // Get sections and update select options
      _sections = ResourceQuerySchema.getQuerySections(context);
      
      // Update the first section's fields with participant and resource lists
      if (_sections.isNotEmpty && _sections[0].fields.length >= 2) {
        // Update participantName field (first field)
        _sections[0].fields[0] = _sections[0].fields[0].copyWith(
          selectOptions: widget.participantList,
        );
        
        // Update resourceName field (second field)
        _sections[0].fields[1] = _sections[0].fields[1].copyWith(
          selectOptions: widget.resourceList,
        );
      }
      
      // Initialize controllers with initial values
      final initialData = <String, dynamic>{
        'participantName': widget.initialParticipant ?? '',
        'resourceName': widget.initialResource ?? '',
        'date': widget.initialDate ?? _getCurrentDate(),
        'recordStatus': widget.initialRecordStatus ?? '',
      };
      
      _controllers = FormControllerHelper.initializeControllers(
        _sections,
        initialData,
      );
    }
  }

  @override
  void dispose() {
    FormControllerHelper.disposeControllers(_controllers);
    super.dispose();
  }

  String _getCurrentDate() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  Future<void> _handleQuery() async {
    if (!FormControllerHelper.validateForm(_formKey)) {
      return;
    }

    setState(() => _isQuerying = true);

    try {
      final formData = FormControllerHelper.getFormData(_controllers);
      final queryData = _buildQueryStructure(
        formData['participantName'],
        formData['resourceName'],
        formData['date'],
        formData['recordStatus'],
      );

      final response = await ApiService.queryResource(queryData);

      if (mounted) {
        // Extract resource data from response
        final registrationData = response['RegistrationData'];
        final registrationQuery = registrationData?['RegistrationQuery'];
        final resource = registrationQuery?['Resource'];

        // Close the bottom sheet
        Navigator.of(context).pop();

        // Call the callback with both response and resource data
        if (resource != null) {
          widget.onQueryComplete(response, resource);
        } else {
          // Show error if no resource data found
          ScaffoldMessenger.of(widget.parentContext).showSnackBar(
            const SnackBar(
              content: Text('No resource data found'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isQuerying = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Query failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Map<String, dynamic> _buildQueryStructure(
    String participantName,
    String resourceName,
    String date,
    String recordStatus,
  ) {
    final resource = <String, dynamic>{
      "@ParticipantName": participantName,
      "@ResourceName": resourceName,
    };
    
    // Add optional fields only if they have values
    if (date.isNotEmpty) {
      resource["@Date"] = date;
    }
    
    if (recordStatus.isNotEmpty) {
      resource["@RecordStatus"] = recordStatus;
    }
    
    return {
      "RegistrationData": {
        "RegistrationQuery": {
          "Resource": resource,
        },
        "@xmlns:xsi": "http://www.w3.org/2001/XMLSchema-instance",
        "@xsi:noNamespaceSchemaLocation": "mpr.xsd"
      }
    };
  }

  void _pickDate(String fieldId) async {
    await FormFieldBuilder.pickDate(
      context: context,
      controller: _controllers[fieldId]!,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 500,
      decoration: BoxDecoration(
        color: theme.dialogBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Query Resource',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Form fields using config-driven library
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: _sections.map((section) {
                      return FormFieldBuilder.buildSection(
                        context: context,
                        section: section,
                        controllers: _controllers,
                        onDateFieldTap: _pickDate,
                      );
                    }).toList(),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Reset and Query Buttons
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: OutlinedButton.icon(
                        onPressed: _isQuerying ? null : () {
                          // Reset form fields
                          for (var controller in _controllers.values) {
                            controller.clear();
                          }
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Reset'),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: theme.cardColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: OutlinedButton.icon(
                        onPressed: _isQuerying ? null : _handleQuery,
                        icon: _isQuerying
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.search),
                        label: Text(_isQuerying ? 'Querying...' : 'Query'),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: theme.cardColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
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
