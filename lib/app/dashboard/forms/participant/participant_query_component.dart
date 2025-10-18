import 'package:flutter/material.dart' hide FormFieldBuilder;
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/forms/forms.dart';
import '../../../../services/api_service.dart';
import 'schemas/participant_query_schema.dart';

/// Callback type for when query is completed
typedef OnQueryComplete = void Function(Map<String, dynamic> response, Map<String, dynamic> participant);

/// Participant Query Component
/// 
/// A reusable bottom sheet component for querying participant data.
/// Uses config-driven forms library for consistent UI and validation.
class ParticipantQueryComponent {
  /// Show the query bottom sheet
  static void show({
    required BuildContext context,
    required List<String> participantList,
    String? initialParticipant,
    String? initialTradeDate,
    required OnQueryComplete onQueryComplete,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) {
        return _QueryBottomSheetContent(
          participantList: participantList,
          initialParticipant: initialParticipant,
          initialTradeDate: initialTradeDate,
          onQueryComplete: onQueryComplete,
          parentContext: context,
        );
      },
    );
  }
}

class _QueryBottomSheetContent extends StatefulWidget {
  final List<String> participantList;
  final String? initialParticipant;
  final String? initialTradeDate;
  final OnQueryComplete onQueryComplete;
  final BuildContext parentContext;

  const _QueryBottomSheetContent({
    required this.participantList,
    this.initialParticipant,
    this.initialTradeDate,
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
      
      // Get sections and update select options with participant list
      _sections = ParticipantQuerySchema.getQuerySections(context);
      
      // Update the first section's first field (participantName) with the participant list
      if (_sections.isNotEmpty && _sections[0].fields.isNotEmpty) {
        _sections[0].fields[0] = _sections[0].fields[0].copyWith(
          selectOptions: widget.participantList,
        );
      }
      
      // Initialize controllers with initial values
      final initialData = <String, dynamic>{
        'participantName': widget.initialParticipant ?? '',
        'tradeDate': widget.initialTradeDate ?? '',
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

  Future<void> _handleQuery() async {
    if (!FormControllerHelper.validateForm(_formKey)) {
      return;
    }

    setState(() => _isQuerying = true);

    try {
      final formData = FormControllerHelper.getFormData(_controllers);
      final participantName = formData['participantName'];
      final tradeDate = formData['tradeDate'];

      // Only send tradeDate if it's not empty
      final response = await ApiService.queryParticipantByName(
        participantName,
        tradeDate: tradeDate?.isNotEmpty == true ? tradeDate : null,
      );

      if (mounted) {
        // Extract participant data from response
        final registrationData = response['RegistrationData'];
        final registrationSubmit = registrationData?['RegistrationSubmit'];
        final participant = registrationSubmit?['Participant'];

        // Close the bottom sheet
        Navigator.of(context).pop();

        // Call the callback with both response and participant data
        if (participant != null) {
          widget.onQueryComplete(response, participant);
        } else {
          // Show error if no participant data found
          ScaffoldMessenger.of(widget.parentContext).showSnackBar(
            const SnackBar(
              content: Text('No participant data found'),
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
                    'participant.header.queryTitle'.tr(),
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
