import 'package:flutter/material.dart' hide FormFieldBuilder;
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/forms/forms.dart';
import '../../../../services/api_service.dart';
import 'schemas/participant_validity_query_schema.dart';

/// Callback type for when validity query is completed
typedef OnValidityQueryComplete = void Function(Map<String, dynamic> response, List<dynamic> validityRecords);

/// Participant Validity Query Component
/// 
/// A reusable bottom sheet component for querying participant validity data.
/// Uses config-driven forms library for consistent UI and validation.
class ParticipantValidityQueryComponent {
  /// Show the query bottom sheet
  static void show({
    required BuildContext context,
    required List<String> participantList,
    String? initialParticipant,
    String? initialDate,
    required OnValidityQueryComplete onQueryComplete,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) {
        return _ValidityQueryBottomSheetContent(
          participantList: participantList,
          initialParticipant: initialParticipant,
          initialDate: initialDate,
          onQueryComplete: onQueryComplete,
          parentContext: context,
        );
      },
    );
  }
}

class _ValidityQueryBottomSheetContent extends StatefulWidget {
  final List<String> participantList;
  final String? initialParticipant;
  final String? initialDate;
  final OnValidityQueryComplete onQueryComplete;
  final BuildContext parentContext;

  const _ValidityQueryBottomSheetContent({
    required this.participantList,
    this.initialParticipant,
    this.initialDate,
    required this.onQueryComplete,
    required this.parentContext,
  });

  @override
  State<_ValidityQueryBottomSheetContent> createState() => _ValidityQueryBottomSheetContentState();
}

class _ValidityQueryBottomSheetContentState extends State<_ValidityQueryBottomSheetContent> {
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
      
      // Get sections and update select options with participant list
      _sections = ParticipantValidityQuerySchema.getQuerySections(context);
      
      // Update the first section's first field (qParticipantName) with the participant list
      if (_sections.isNotEmpty && _sections[0].fields.isNotEmpty) {
        _sections[0].fields[0] = _sections[0].fields[0].copyWith(
          selectOptions: widget.participantList,
        );
      }
      
      // Initialize controllers with initial values
      final initialData = <String, dynamic>{
        'qParticipantName': widget.initialParticipant ?? '',
        'qDate': widget.initialDate ?? _getCurrentDate(),
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
      final participantName = formData['qParticipantName'];
      final date = formData['qDate'];

      // Use the API endpoint for participant validity query
      final response = await ApiService.queryParticipantValidity(
        participantName,
        date: date,
      );

      if (mounted) {
        // Extract validity records from response
        final registrationData = response['RegistrationData'];
        final registrationSubmit = registrationData?['RegistrationSubmit'];
        final validityRecords = registrationSubmit?['ParticipantValidity'] ?? [];

        // Close the bottom sheet
        Navigator.of(context).pop();

        // Call the callback with both response and validity records
        if (validityRecords is List) {
          widget.onQueryComplete(response, validityRecords);
        } else {
          // Show error if no validity data found
          ScaffoldMessenger.of(widget.parentContext).showSnackBar(
            const SnackBar(
              content: Text('No participant validity data found'),
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
      height: 400,
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
                    'participantValidity.header.queryTitle'.tr(),
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
                        label: Text('participant.buttons.reset'.tr()),
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
                        label: Text(_isQuerying ? 'Querying...' : 'participant.buttons.query'.tr()),
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
