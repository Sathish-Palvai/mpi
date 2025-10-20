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
        'tradeDate': '', // Always start blank
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

  /// Build query structure matching participant_update_screen format
  Map<String, dynamic> _buildQueryStructure(String participantName, String tradeDate) {
    final participant = <String, dynamic>{
      "@ParticipantName": participantName,
    };
    
    // Only add TradeDate if it's not empty
    if (tradeDate.isNotEmpty) {
      participant["@TradeDate"] = tradeDate;
    }
    
    return {
      "RegistrationData": {
        "RegistrationQuery": {
          "Participant": participant,
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

  Future<void> _handleQuery({bool includeTradeDate = true}) async {
    if (!FormControllerHelper.validateForm(_formKey)) {
      return;
    }

    setState(() => _isQuerying = true);

    try {
      final formData = FormControllerHelper.getFormData(_controllers);
      final participantName = formData['participantName'];
      final tradeDate = formData['tradeDate']?.isNotEmpty == true 
          ? formData['tradeDate'] 
          : (includeTradeDate ? _getCurrentDate() : ''); // Only use current date if includeTradeDate is true

      // Build query with same structure as participant_update_screen
      final queryData = _buildQueryStructure(participantName, tradeDate);

      final response = await ApiService.queryParticipant(queryData);

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

  void _resetForm() {
    // Clear only trade date, keep participant name
    _controllers['tradeDate']?.clear();
    setState(() {});
  }

  void _handleReset() async {
    _resetForm();
    // Re-issue the query with only participant name (without trade date)
    await _handleQuery(includeTradeDate: false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 450,
      decoration: BoxDecoration(
        color: theme.dialogBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Criteria Header with blue background
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: theme.brightness == Brightness.dark 
                  ? const Color(0xFF2A2A2A)
                  : const Color(0xFF283593),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Criteria',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
          
          // Form content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                              onPressed: _isQuerying ? null : _handleReset,
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
          ),
        ],
      ),
    );
  }
}
