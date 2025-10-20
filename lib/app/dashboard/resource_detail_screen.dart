import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../shared/widgets/app_drawer.dart';
import '../../widgets/notification_icon.dart';

class ResourceDetailScreen extends StatefulWidget {
  final Map<String, dynamic> resource;

  const ResourceDetailScreen({
    super.key,
    required this.resource,
  });

  @override
  State<ResourceDetailScreen> createState() => _ResourceDetailScreenState();
}

class _ResourceDetailScreenState extends State<ResourceDetailScreen>
    with SingleTickerProviderStateMixin {
  static const double _fieldSpacing = 18.0;
  static const double _labelFontDelta = 3.0;

  final _formKey = GlobalKey<FormState>();
  late TabController _tabController;

  // General Details Controllers
  final _participantNameController = TextEditingController();
  final _resourceNameController = TextEditingController();
  final _systemCodeController = TextEditingController();
  final _resourceShortNameController = TextEditingController();
  final _resourceLongNameController = TextEditingController();
  final _bgCodeController = TextEditingController();
  // Primary commodity controllers
  final _priResponseTimeController = TextEditingController();
  final _priContinuousTimeController = TextEditingController();
  final _priMaximumSupplyQuantityController = TextEditingController();
  // Pri remaining reserve maximum quantity (conditional)
  final _priRemResvMaximumSupplyQuantityController = TextEditingController();
  // Secondary controllers removed (handled later)
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();

  // Technical Specifications Controllers
  final _modelNameController = TextEditingController();
  final _ratedCapacityController = TextEditingController();
  final _ratedVoltageController = TextEditingController();
  final _continuousOperationVoltageController = TextEditingController();
  final _ratedPowerFactorController = TextEditingController();
  final _frequencyController = TextEditingController();
  final _inPlantRateController = TextEditingController();

  // Additional frequency range and operational controllers
  final _continuousOperationFrequencyLowerController = TextEditingController();
  final _continuousOperationFrequencyUpperController = TextEditingController();
  final _blackStartController = TextEditingController();
  final _thermalTypeController = TextEditingController();

  // Output Controllers
  final _ratedOutputController = TextEditingController();
  final _minimumOutputController = TextEditingController();
  final _authorizedMaximumOutputController = TextEditingController();
  final _afcMinimumOutputController = TextEditingController();

  // Contact Information Controllers
  final _addressController = TextEditingController();
  final _phonePart1Controller = TextEditingController();
  final _phonePart2Controller = TextEditingController();
  final _phonePart3Controller = TextEditingController();
  final _venIdController = TextEditingController();

  // State Variables
  String? _selectedArea;
  String? _selectedResourceType;
  // Thermal type removed from UI
  String? _selectedContractType;
  bool _isSubmitting = false;
  int _selectedStartupPatternIndex = 0;
  int _selectedStopPatternIndex = 0;
  bool _priEnabled = false;
  String? _priRemResvUtilization;
  // New command operation method selections
  String? _priSec1CommandOperationMethod;
  String? _sec2Ter1Ter2CommandOperationMethod;
  // Signal type and voltage adjustment selections
  String? _signalType;
  String? _voltageAdjustment;
  // New operational flags (0 = NO, 1 = YES)
  String? _continuousOperationTimeLimited;
  String? _fcbOperation;
  String? _overPowerOperation;
  String? _peakModeOperation;
  String? _dss;
  // Secondary state removed until implemented

  // Resource Type Codes (file-based names)
  static const String THERMAL = 'THERMAL';
  static const String PUMP = 'PUMP';
  static const String HYDRO = 'HYDRO';
  static const String VPP_DEM = 'VPP_DEM';
  static const String VPP_GEN = 'VPP_GEN';
  static const String VPP_GEN_AND_DEM = 'VPP_GEN_AND_DEM';

  @override
  void initState() {
    super.initState();
    _initializeFields();
    _initializeTabController();
  }

  void _initializeTabController() {
    // Determine number of tabs based on actual tabs built
    final tabCount = _buildTabs().length;
    _tabController = TabController(length: tabCount, vsync: this);

    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        return;
      }
      if (mounted) {
        setState(() {});
      }
    });
  }

  void _initializeFields() {
    _participantNameController.text = widget.resource['ParticipantName'] ?? '';
    _resourceNameController.text = widget.resource['ResourceName'] ?? '';
    _systemCodeController.text = widget.resource['SystemCode'] ?? '';
    _resourceShortNameController.text =
        widget.resource['ResourceShortName'] ?? '';
    _resourceLongNameController.text =
        widget.resource['ResourceLongName'] ?? '';
    _bgCodeController.text = widget.resource['BgCode'] ?? '';
    // Primary commodity
    _priResponseTimeController.text = widget.resource['PriResponseTime'] ?? '';
    _priContinuousTimeController.text =
        widget.resource['PriContinuousTime'] ?? '';
    _priMaximumSupplyQuantityController.text =
        widget.resource['PriMaximumSupplyQuantity']?.toString() ?? '';
    _priRemResvMaximumSupplyQuantityController.text =
        widget.resource['PriRemResvMaximumSupplyQuantity']?.toString() ?? '';
    _priRemResvUtilization =
        widget.resource['PriRemResvUtilization']?.toString() ?? '0';
    _priEnabled =
        (widget.resource['Pri']?.toString().toLowerCase() ?? 'false') == 'true';
    // Secondary 1
    // Secondary 1 initialization removed
    // Secondary 2
    // Secondary 2 initialization removed
    _startDateController.text = widget.resource['StartDate'] ?? '';
    _endDateController.text = widget.resource['EndDate'] ?? '';

    _selectedArea = widget.resource['Area'];
    _selectedResourceType = widget.resource['ResourceType'];
  // Thermal type removed from UI
    _selectedContractType = widget.resource['ContractType'];

  _priSec1CommandOperationMethod = (widget.resource['PriSec1CommandOperationMethod']?.toString()) ?? '0';
  _sec2Ter1Ter2CommandOperationMethod = (widget.resource['Sec2Ter1Ter2CommandOperationMethod']?.toString()) ?? '0';
  _signalType = (widget.resource['SignalType']?.toString()) ?? '0';
  _voltageAdjustment = (widget.resource['VoltageAdjustment']?.toString()) ?? '0';
  _continuousOperationTimeLimited = (widget.resource['ContinuousOperationTimeLimited']?.toString()) ?? '0';
  _fcbOperation = (widget.resource['FcbOperation']?.toString()) ?? '0';
  _overPowerOperation = (widget.resource['OverPowerOperation']?.toString()) ?? '0';
  _peakModeOperation = (widget.resource['PeakModeOperation']?.toString()) ?? '0';
  _dss = (widget.resource['Dss']?.toString()) ?? '0';

    // If Primary maximum is not applicable for this resource type, clear it
    if (!_isPriMaximumApplicable()) {
      _priMaximumSupplyQuantityController.text = '';
    }

    // Technical specifications
    _modelNameController.text = widget.resource['ModelName'] ?? '';
    _ratedCapacityController.text =
        widget.resource['RatedCapacity']?.toString() ?? '';
    _ratedVoltageController.text =
        widget.resource['RatedVoltage']?.toString() ?? '';
    _continuousOperationVoltageController.text =
        widget.resource['ContinuousOperationVoltage']?.toString() ?? '';
    _ratedPowerFactorController.text =
        widget.resource['RatedPowerFactor']?.toString() ?? '';
    final freqRaw = widget.resource['Frequency']?.toString();
    if (freqRaw == '50') {
      _frequencyController.text = '50:50';
    } else if (freqRaw == '60') {
      _frequencyController.text = '60:60';
    } else {
      _frequencyController.text = freqRaw ?? '';
    }
    _inPlantRateController.text =
        widget.resource['InPlantRate']?.toString() ?? '';
  _continuousOperationFrequencyLowerController.text =
    widget.resource['ContinuousOperationFrequencyLower']?.toString() ?? '';
  _continuousOperationFrequencyUpperController.text =
    widget.resource['ContinuousOperationFrequencyUpper']?.toString() ?? '';
  _blackStartController.text = widget.resource['BlackStart']?.toString() ?? '';
  _thermalTypeController.text = widget.resource['ThermalType']?.toString() ?? '';

    // Output
    _ratedOutputController.text =
        widget.resource['RatedOutput']?.toString() ?? '';
    _minimumOutputController.text =
        widget.resource['MinimumOutput']?.toString() ?? '';
    _authorizedMaximumOutputController.text =
        widget.resource['AuthorizedMaximumOutput']?.toString() ?? '';
    _afcMinimumOutputController.text =
        widget.resource['AfcMinimumOutput']?.toString() ?? '';

    // Contact
    _addressController.text = widget.resource['Address'] ?? '';
    _phonePart1Controller.text = widget.resource['PayeePhonePart1'] ?? '';
    _phonePart2Controller.text = widget.resource['PayeePhonePart2'] ?? '';
    _phonePart3Controller.text = widget.resource['PayeePhonePart3'] ?? '';
    _venIdController.text = widget.resource['VenId'] ?? '';
  }

  @override
  void dispose() {
    _tabController.dispose();
    _participantNameController.dispose();
    _resourceNameController.dispose();
    _systemCodeController.dispose();
    _resourceShortNameController.dispose();
    _resourceLongNameController.dispose();
    _bgCodeController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _modelNameController.dispose();
    _ratedCapacityController.dispose();
    _ratedVoltageController.dispose();
    _continuousOperationVoltageController.dispose();
    _ratedPowerFactorController.dispose();
    _frequencyController.dispose();
    _inPlantRateController.dispose();
    _ratedOutputController.dispose();
    _minimumOutputController.dispose();
    _authorizedMaximumOutputController.dispose();
    _afcMinimumOutputController.dispose();
    _addressController.dispose();
    _phonePart1Controller.dispose();
    _phonePart2Controller.dispose();
    _continuousOperationFrequencyLowerController.dispose();
    _continuousOperationFrequencyUpperController.dispose();
    _blackStartController.dispose();
    _thermalTypeController.dispose();
    _phonePart3Controller.dispose();
  _venIdController.dispose();
    _priResponseTimeController.dispose();
    _priContinuousTimeController.dispose();
    _priMaximumSupplyQuantityController.dispose();
    _priRemResvMaximumSupplyQuantityController.dispose();
    // Secondary controller disposals removed
    super.dispose();
  }

  bool _shouldShowTab(String tabName) {
    if (_selectedResourceType == null) return false;

    switch (tabName) {
      case 'OutputBand':
      case 'SwitchOutput':
      case 'AFC':
      case 'StartupPattern':
      case 'StopPattern':
        return _selectedResourceType == THERMAL ||
            _selectedResourceType == PUMP ||
            _selectedResourceType == HYDRO;
      default:
        return true;
    }
  }

  InputDecoration _inputDecoration({
    required String labelText,
    String? hintText,
    String? helperText,
    bool enabled = true,
  }) {
    final theme = Theme.of(context);
    final baseLabelStyle =
        theme.inputDecorationTheme.labelStyle ?? theme.textTheme.labelMedium;
    final double targetSize =
        ((baseLabelStyle?.fontSize) ?? 14) + _labelFontDelta;
    final labelStyle = baseLabelStyle?.copyWith(fontSize: targetSize) ??
        TextStyle(fontSize: targetSize);
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      floatingLabelBehavior: FloatingLabelBehavior.always,
      labelStyle: labelStyle,
      floatingLabelStyle: labelStyle.copyWith(fontWeight: FontWeight.w600),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      filled: true,
      fillColor: enabled
          ? theme.colorScheme.surfaceVariant.withOpacity(.6)
          : theme.colorScheme.surfaceVariant.withOpacity(.3),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      helperText: helperText,
      enabled: enabled,
    );
  }

  // Validator for HH:MM:SS time strings. Accepts empty as valid (use required elsewhere).
  String? _validateTime(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    // Simple regex for HH:MM:SS where HH is 00-23, MM/SS 00-59
    final reg = RegExp(r'^(?:[01]\d|2[0-3]):[0-5]\d:[0-5]\d$');
    if (!reg.hasMatch(value.trim())) {
      return 'Enter time as HH:MM:SS (00:00:00 - 23:59:59)';
    }
    return null;
  }

  // Input formatter to allow only digits and colon and limit length to 8 (HH:MM:SS)
  List<TextInputFormatter> _timeInputFormatters() {
    return [
      FilteringTextInputFormatter.allow(RegExp(r'[0-9:]')),
      LengthLimitingTextInputFormatter(8),
    ];
  }

  // Returns true when the Primary Maximum Supply Quantity field is applicable
  // Check if Pri Maximum Supply Quantity field is applicable
  // for the currently selected resource type. It's NOT applicable for VPP types.
  bool _isPriMaximumApplicable() {
    return !(_selectedResourceType == VPP_DEM ||
        _selectedResourceType == VPP_GEN ||
        _selectedResourceType == VPP_GEN_AND_DEM);
  }

  Future<void> _pickDate(TextEditingController controller) async {
    final now = DateTime.now();
    final initial = controller.text.isNotEmpty
        ? DateTime.tryParse(controller.text) ?? now
        : now;
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(now.year - 5, 1, 1),
      lastDate: DateTime(now.year + 5, 12, 31),
      initialDate: initial,
      helpText: 'Select Date',
      fieldHintText: 'YYYY-MM-DD',
      initialEntryMode: DatePickerEntryMode.calendarOnly,
    );
    if (picked != null) {
      final value =
          '${picked.year.toString().padLeft(4, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      setState(() => controller.text = value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      drawer: const AppDrawer(),
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('Resource Details'),
        elevation: 0,
        backgroundColor: const Color(0xFF283593),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/dashboard'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Query feature coming soon')),
              );
            },
            tooltip: 'Query Resource',
          ),
          const SizedBox(width: 8),
          const Padding(
            padding: EdgeInsets.only(right: 8.0),
            child: SizedBox(width: 40, height: 40, child: NotificationIcon()),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: _buildTabs(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: _buildTabViews(),
      ),
    );
  }

  List<Tab> _buildTabs() {
    final List<Tab> tabs = [
      const Tab(text: 'General Details'),
    ];

    if (_shouldShowTab('OutputBand')) {
      tabs.add(const Tab(text: 'Output Band'));
    }
    if (_shouldShowTab('SwitchOutput')) {
      tabs.add(const Tab(text: 'Switch Output'));
    }
    if (_shouldShowTab('AFC')) {
      tabs.add(const Tab(text: 'AFC'));
    }
    if (_shouldShowTab('StartupPattern')) {
      tabs.add(const Tab(text: 'Startup Pattern'));
    }
    if (_shouldShowTab('StopPattern')) {
      tabs.add(const Tab(text: 'Stop Pattern'));
    }

    return tabs;
  }

  List<Widget> _buildTabViews() {
    final List<Widget> views = [
      _buildGeneralDetailsTab(),
    ];

    if (_shouldShowTab('OutputBand')) {
      views.add(_buildOutputBandTab());
    }
    if (_shouldShowTab('SwitchOutput')) {
      views.add(_buildSwitchOutputTab());
    }
    if (_shouldShowTab('AFC')) {
      views.add(_buildAfcTab());
    }
    if (_shouldShowTab('StartupPattern')) {
      views.add(_buildStartupPatternTab());
    }
    if (_shouldShowTab('StopPattern')) {
      views.add(_buildStopPatternTab());
    }

    return views;
  }

  Widget _buildGeneralDetailsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      child: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildKeyFieldsSection(),
            const SizedBox(height: 24),
            // Basic Information fields inlined (no separate title)
            _buildBasicInformationSection(),
            const SizedBox(height: 24),
            // Technical Specifications and Output Parameters sections removed
            // per request. Fields previously shown here (RatedCapacity,
            // RatedVoltage, RatedOutput, etc.) are no longer rendered.
            const SizedBox(height: 12),
            // Contact information (Address & Phone moved into Basic Information as requested)
            const SizedBox(height: 32),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  // _buildSectionTitle removed — section titles are no longer used

  Widget _buildKeyFieldsSection() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              flex: 1,
              child: TextFormField(
                controller: _participantNameController,
                decoration: _inputDecoration(
                  labelText: 'Participant Name',
                  hintText: 'e.g., A001',
                  enabled: false,
                ),
                readOnly: true,
                maxLength: 4,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 1,
              child: TextFormField(
                controller: _resourceNameController,
                decoration: _inputDecoration(
                  labelText: 'Resource Name',
                  hintText: 'e.g., RES_001',
                  enabled: false,
                ),
                readOnly: true,
                maxLength: 10,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              flex: 1,
              child: DropdownButtonFormField<String>(
                value: _selectedArea,
                decoration:
                    _inputDecoration(labelText: 'Area *', enabled: false),
                items: _getAreaOptions(),
                onChanged: null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 1,
              child: DropdownButtonFormField<String>(
                value: _selectedResourceType,
                decoration: _inputDecoration(
                    labelText: 'Resource Type *', enabled: false),
                items: _getResourceTypeOptions(),
                onChanged: null,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        DropdownButtonFormField<String>(
          value: _selectedContractType,
          decoration: _inputDecoration(labelText: 'Contract Type *'),
          items: _getContractTypeOptions(),
          onChanged: (value) {
            setState(() {
              _selectedContractType = value;
              // Always uncheck primary when contract type changes
              _priEnabled = false;
              // Clear all primary-related fields so previous values are not retained
              _priResponseTimeController.text = '';
              _priContinuousTimeController.text = '';
              // If contract type is MARKET (1) or MARKET_AND_REMAINING_RESERVE_UTILIZATION (5)
              // and primary is disabled, default the maximum possible supply to '0'
              if (value == '1' || value == '5') {
                _priMaximumSupplyQuantityController.text = '0';
              } else {
                _priMaximumSupplyQuantityController.text = '';
              }
              _priRemResvUtilization = '0';
              _priRemResvMaximumSupplyQuantityController.text = '';

              // Contract-specific logic can be customized here if any fields should be pre-populated
              // for certain contract types. For now we clear everything to meet the requirement
              // that fields should not retain previous values when contract type changes.
            });
          },
          validator: (value) =>
              value == null ? 'Contract type is required' : null,
        ),
      ],
    );
  }

  Widget _buildBasicInformationSection() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _startDateController,
                decoration: _inputDecoration(
                  labelText: 'Start Date *',
                  hintText: 'YYYY-MM-DD',
                ),
                readOnly: true,
                onTap: () => _pickDate(_startDateController),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Start date is required';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _endDateController,
                decoration: _inputDecoration(
                  labelText: 'End Date',
                  hintText: 'YYYY-MM-DD',
                  enabled: false,
                ),
                readOnly: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: _fieldSpacing),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _systemCodeController,
                decoration: _inputDecoration(
                  labelText: 'System Code *',
                  hintText: '5 characters A-Z0-9',
                ),
                maxLength: 5,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'System code is required';
                  }
                  if (!RegExp(r'^[A-Z0-9]{5}$').hasMatch(value)) {
                    return 'System code must be 5 uppercase alphanumeric characters';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _resourceShortNameController,
                decoration: _inputDecoration(
                  labelText: 'Resource Short Name *',
                  hintText: '1-10 characters',
                ),
                maxLength: 10,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Resource short name is required';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: _fieldSpacing),
        TextFormField(
          controller: _resourceLongNameController,
          decoration: _inputDecoration(
            labelText: 'Resource Long Name *',
            hintText: '1-50 characters',
          ),
          keyboardType: TextInputType.multiline,
          minLines: 2,
          maxLines: 4,
          maxLength: 50,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Resource long name is required';
            }
            return null;
          },
        ),
        const SizedBox(height: _fieldSpacing),
        TextFormField(
          controller: _bgCodeController,
          decoration: _inputDecoration(
            labelText: 'BG Code',
            hintText: '5 characters',
          ),
          maxLength: 5,
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Note: Check on the trading target of commodity, and provide input for required field.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontStyle: FontStyle.italic,
                ),
          ),
        ),
        const SizedBox(height: _fieldSpacing),
        // Primary Commodity fieldset
        if (_selectedContractType == '6') ...[
          // Special rendering for REMAINING_RESERVE_UTILIZATION: only show Max Possible Supply and Availability.
          Card(
            elevation: 0,
            color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(.3),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Primary Commodity',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: _fieldSpacing),
                  TextFormField(
                    controller: _priMaximumSupplyQuantityController,
                    decoration: _inputDecoration(
                      labelText:
                          'Maximum Possible Supply Quantity (Primary) [kW]',
                      // render disabled appearance when this field is not applicable for resource type
                      enabled: _isPriMaximumApplicable() &&
                          !(!_priEnabled &&
                              (_selectedContractType == '1' ||
                                  _selectedContractType == '5')),
                    ),
                    readOnly: !_isPriMaximumApplicable() ||
                        (!_priEnabled &&
                            (_selectedContractType == '1' ||
                                _selectedContractType == '5')),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: _fieldSpacing),
                  const Divider(height: 1),
                  const SizedBox(height: _fieldSpacing),
                  // For REMAINING_RESERVE_UTILIZATION contract we default to NOT_AVAILABLE
                  // and keep the field non-editable per requirement.
                  DropdownButtonFormField<String>(
                    value: '0',
                    decoration: _inputDecoration(
                        labelText:
                            'Availability Of Remaining Reserve Utilization (Primary)',
                        enabled: false),
                    items: const [
                      DropdownMenuItem(
                          value: '0', child: Text('NOT_AVAILABLE')),
                      DropdownMenuItem(
                          value: '1', child: Text('AVAILABLE_FOR_UP_ONLY')),
                      DropdownMenuItem(
                          value: '2', child: Text('AVAILABLE_FOR_DOWN_ONLY')),
                      DropdownMenuItem(
                          value: '3', child: Text('AVAILABLE_FOR_UP_AND_DOWN')),
                    ],
                    onChanged: null,
                  ),
                  if ((_priRemResvUtilization ?? '0') != '0') ...[
                    const SizedBox(height: _fieldSpacing),
                    TextFormField(
                      controller: _priRemResvMaximumSupplyQuantityController,
                      decoration: _inputDecoration(
                          labelText:
                              'Remaining Reserve Maximum Possible Supply Quantity (Primary) [kW]'),
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ] else ...[
          Card(
            elevation: 0,
            color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(.3),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Primary Commodity',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Checkbox(
                        value: _priEnabled,
                        onChanged: (v) {
                          setState(() {
                            final enabled = v ?? false;
                            // Toggle enabled state
                            _priEnabled = enabled;
                            // Always clear the primary-related fields when toggling so
                            // previous values are not retained between checks/unchecks.
                            _priResponseTimeController.text = '';
                            _priContinuousTimeController.text = '';
                            // If we're disabling primary and the contract type requires
                            // a default of 0 for maximum supply, set it to '0'.
                            if (!enabled &&
                                (_selectedContractType == '1' ||
                                    _selectedContractType == '5')) {
                              _priMaximumSupplyQuantityController.text = '0';
                            } else if (!enabled) {
                              _priMaximumSupplyQuantityController.text = '';
                            }
                            // Also clear remaining reserve maximum to avoid stale values
                            _priRemResvMaximumSupplyQuantityController.text =
                                '';
                            // Reset utilization to NOT_AVAILABLE by default when turning off
                            if (!enabled) {
                              _priRemResvUtilization = '0';
                            }
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: _fieldSpacing),
                  if (_priEnabled) ...[
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _priResponseTimeController,
                            decoration: _inputDecoration(
                                labelText: 'Primary Response',
                                hintText: 'HH:MM:SS'),
                            inputFormatters: _timeInputFormatters(),
                            validator: _validateTime,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _priContinuousTimeController,
                            decoration: _inputDecoration(
                                labelText: 'Primary Continuous',
                                hintText: 'HH:MM:SS'),
                            inputFormatters: _timeInputFormatters(),
                            validator: _validateTime,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: _fieldSpacing),
                    TextFormField(
                      controller: _priMaximumSupplyQuantityController,
                      decoration: _inputDecoration(
                        labelText:
                            'Maximum Possible Supply Quantity (Primary) [kW]',
                        enabled: _isPriMaximumApplicable(),
                      ),
                      readOnly: !_isPriMaximumApplicable(),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: _fieldSpacing),
                  ] else ...[
                    TextFormField(
                      controller: _priMaximumSupplyQuantityController,
                      decoration: _inputDecoration(
                        labelText:
                            'Maximum Possible Supply Quantity (Primary) [kW]',
                        // disabled when not applicable for resource type or when primary is not enabled and contract is 1 or 5
                        enabled: _isPriMaximumApplicable() &&
                            !(!_priEnabled &&
                                (_selectedContractType == '1' ||
                                    _selectedContractType == '5')),
                      ),
                      readOnly: !_isPriMaximumApplicable() ||
                          (!_priEnabled &&
                              (_selectedContractType == '1' ||
                                  _selectedContractType == '5')),
                      keyboardType: TextInputType.number,
                    ),
                  ],
                  // Availability of remaining reserve utilization (always visible)
                  const SizedBox(height: _fieldSpacing),
                  const Divider(height: 1),
                  const SizedBox(height: _fieldSpacing),
                  // Availability is editable only when Primary is enabled AND contract type is '5'.
                  DropdownButtonFormField<String>(
                    value: (_priRemResvUtilization ?? '0'),
                    decoration: _inputDecoration(
                        labelText:
                            'Availability Of Remaining Reserve Utilization (Primary)',
                        // Editable whenever the contract type is '5' regardless of primary enabled state
                        enabled: (_selectedContractType == '5')),
                    items: const [
                      DropdownMenuItem(
                          value: '0', child: Text('NOT_AVAILABLE')),
                      DropdownMenuItem(
                          value: '1', child: Text('AVAILABLE_FOR_UP_ONLY')),
                      DropdownMenuItem(
                          value: '2', child: Text('AVAILABLE_FOR_DOWN_ONLY')),
                      DropdownMenuItem(
                          value: '3', child: Text('AVAILABLE_FOR_UP_AND_DOWN')),
                    ],
                    onChanged: (_selectedContractType == '5')
                        ? (v) {
                            setState(() {
                              _priRemResvUtilization = v;
                            });
                          }
                        : null,
                  ),
                  if ((_priRemResvUtilization ?? '0') != '0') ...[
                    const SizedBox(height: _fieldSpacing),
                    TextFormField(
                      controller: _priRemResvMaximumSupplyQuantityController,
                      decoration: _inputDecoration(
                          labelText:
                              'Remaining Reserve Maximum Possible Supply Quantity (Primary) [kW]'),
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
        // Pri/Sec command operation method selectors (appear after Primary section)
        const SizedBox(height: _fieldSpacing),
        // First row: two command operation method selectors side-by-side
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                value: (_priSec1CommandOperationMethod ?? '0'),
                decoration: _inputDecoration(
                    labelText: 'PriSec1 Command Operation Method'),
                items: const [
                  DropdownMenuItem(value: '0', child: Text('DEDICATED_LINE')) ,
                  DropdownMenuItem(value: '1', child: Text('OFFLINE')),
                ],
                onChanged: (v) {
                  setState(() {
                    _priSec1CommandOperationMethod = v;
                  });
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: (_sec2Ter1Ter2CommandOperationMethod ?? '0'),
                decoration: _inputDecoration(
                    labelText: 'Sec2Ter1Ter2 Command Operation Method'),
                items: const [
                  DropdownMenuItem(value: '0', child: Text('DEDICATED_LINE')) ,
                  DropdownMenuItem(value: '1', child: Text('SIMPLE_COMMAND')),
                ],
                onChanged: (v) {
                  setState(() {
                    _sec2Ter1Ter2CommandOperationMethod = v;
                  });
                },
              ),
            ),
          ],
        ),

  const SizedBox(height: _fieldSpacing),
  // Second row: SignalType and VoltageAdjustment side-by-side
  Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                value: (_signalType ?? '0'),
                decoration: _inputDecoration(
                    labelText: 'Signal Type${_isFieldRequired('SignalType') ? ' *' : ''}'),
                items: const [
                  DropdownMenuItem(value: '0', child: Text('ACTUAL_OUTPUT_ORDER')),
                  DropdownMenuItem(value: '1', child: Text('DIFFERENTIAL_OUTPUT_ORDER')),
                ],
                onChanged: (v) {
                  setState(() {
                    _signalType = v;
                  });
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: (_voltageAdjustment ?? '0'),
                decoration: _inputDecoration(
                    labelText: 'Voltage Adjustment${_isFieldRequired('VoltageAdjustment') ? ' *' : ''}'),
                items: const [
                  DropdownMenuItem(value: '0', child: Text('NO')),
                  DropdownMenuItem(value: '1', child: Text('YES')),
                ],
                onChanged: (v) {
                  setState(() {
                    _voltageAdjustment = v;
                  });
                },
              ),
            ),
          ],
        ),
        
        // Address (moved here) and Phone parts
        const SizedBox(height: _fieldSpacing),
        TextFormField(
          controller: _addressController,
          decoration: _inputDecoration(
            labelText: 'Address *',
            hintText: 'Full address',
          ),
          keyboardType: TextInputType.multiline,
          minLines: 2,
          maxLines: 4,
          maxLength: 50,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Address is required';
            }
            if (value.trim().length > 50) {
              return 'Address must be 50 characters or less';
            }
            return null;
          },
        ),
        const SizedBox(height: _fieldSpacing),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _phonePart1Controller,
                decoration: _inputDecoration(
                  labelText: 'Phone Part 1 *',
                  hintText: '03',
                ),
                keyboardType: TextInputType.phone,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                maxLength: 3,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Phone part 1 is required';
                  }
                  if (!RegExp(r'^[0-9]+$').hasMatch(value.trim())) {
                    return 'Digits only';
                  }
                  return null;
                },
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Text('-', style: TextStyle(fontSize: 20)),
            ),
            Expanded(
              child: TextFormField(
                controller: _phonePart2Controller,
                decoration: _inputDecoration(
                  labelText: 'Phone Part 2 *',
                  hintText: '1234',
                ),
                keyboardType: TextInputType.phone,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                maxLength: 4,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Phone part 2 is required';
                  }
                  if (!RegExp(r'^[0-9]{1,4}$').hasMatch(value.trim())) {
                    return 'Enter up to 4 digits';
                  }
                  return null;
                },
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Text('-', style: TextStyle(fontSize: 20)),
            ),
            Expanded(
              child: TextFormField(
                controller: _phonePart3Controller,
                decoration: _inputDecoration(
                  labelText: 'Phone Part 3 *',
                  hintText: '5678',
                ),
                keyboardType: TextInputType.phone,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                maxLength: 4,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Phone part 3 is required';
                  }
                  if (!RegExp(r'^[0-9]{1,4}$').hasMatch(value.trim())) {
                    return 'Enter up to 4 digits';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),

        // VenId (only when Sec2Ter1Ter2CommandOperationMethod == SIMPLE_COMMAND (1))
        if ((_sec2Ter1Ter2CommandOperationMethod ?? '0') == '1') ...[
          const SizedBox(height: _fieldSpacing),
          TextFormField(
            controller: _venIdController,
            decoration: _inputDecoration(
              labelText:
                  'VenId',
              hintText: 'Up to 64 characters',
            ),
            keyboardType: TextInputType.multiline,
            minLines: 1,
            maxLines: 3,
            maxLength: 64,
          ),
        ],

        // ModelName (always shown after VenId) - multiline textarea up to 50 chars
        const SizedBox(height: _fieldSpacing),
        TextFormField(
          controller: _modelNameController,
          decoration: _inputDecoration(
            labelText: 'ModelName',
            hintText: 'Model name or identifier (max 50 chars)',
          ),
          keyboardType: TextInputType.multiline,
          minLines: 1,
          maxLines: 3,
          maxLength: 50,
          validator: (value) {
            if (_isFieldRequired('ModelName')) {
              if (value == null || value.trim().isEmpty) return 'Model name is required';
            }
            return null;
          },
        ),

        // Secondary sections removed as requested
        const SizedBox(height: _fieldSpacing),

        // Place Rated Capacity and Rated Voltage after ModelName (they may be shown/hidden independently)
        if (_shouldShowField('RatedCapacity') || _shouldShowField('RatedVoltage')) ...[
          const SizedBox(height: _fieldSpacing),
          if (_shouldShowField('RatedCapacity') && _shouldShowField('RatedVoltage'))
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _ratedCapacityController,
                    decoration: _inputDecoration(
                      labelText: 'Rated Capacity${_isFieldRequired('RatedCapacity') ? ' *' : ''}',
                      hintText: 'kW',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (_isFieldRequired('RatedCapacity') && (value == null || value.trim().isEmpty)) {
                        return 'Rated capacity is required';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _ratedVoltageController,
                    decoration: _inputDecoration(
                      labelText: 'Rated Voltage${_isFieldRequired('RatedVoltage') ? ' *' : ''}',
                      hintText: '0.0-1000.0 kV',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (_isFieldRequired('RatedVoltage') && (value == null || value.trim().isEmpty)) {
                        return 'Rated voltage is required';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            )
          else ...[
            if (_shouldShowField('RatedCapacity')) ...[
              TextFormField(
                controller: _ratedCapacityController,
                decoration: _inputDecoration(
                  labelText: 'Rated Capacity${_isFieldRequired('RatedCapacity') ? ' *' : ''}',
                  hintText: 'kW',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (_isFieldRequired('RatedCapacity') && (value == null || value.trim().isEmpty)) {
                    return 'Rated capacity is required';
                  }
                  return null;
                },
              ),
            ],
            if (_shouldShowField('RatedVoltage')) ...[
              TextFormField(
                controller: _ratedVoltageController,
                decoration: _inputDecoration(
                  labelText: 'Rated Voltage${_isFieldRequired('RatedVoltage') ? ' *' : ''}',
                  hintText: '0.0-1000.0 kV',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (_isFieldRequired('RatedVoltage') && (value == null || value.trim().isEmpty)) {
                    return 'Rated voltage is required';
                  }
                  return null;
                },
              ),
            ],
          ],
        ],
        
        if (_shouldShowField('ContinuousOperationVoltage')) ...[
          const SizedBox(height: _fieldSpacing),
          TextFormField(
            controller: _continuousOperationVoltageController,
            decoration: _inputDecoration(
              labelText:
                  'Continuous Operation Voltage${_isFieldRequired('ContinuousOperationVoltage') ? ' *' : ''}',
              hintText: 'kV',
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
              LengthLimitingTextInputFormatter(10),
            ],
            validator: (value) {
              if (_isFieldRequired('ContinuousOperationVoltage') &&
                  (value == null || value.trim().isEmpty)) {
                return 'Continuous operation voltage is required';
              }
              if (value != null && value.trim().isNotEmpty) {
                final parsed = double.tryParse(value);
                if (parsed == null) return 'Enter a valid number';
                if (parsed < 0) return 'Value must be zero or positive';
              }
              return null;
            },
          ),
        ],
        if (_shouldShowField('RatedPowerFactor')) ...[
          const SizedBox(height: _fieldSpacing),
          TextFormField(
            controller: _ratedPowerFactorController,
            decoration: _inputDecoration(
              labelText:
                  'Rated Power Factor${_isFieldRequired('RatedPowerFactor') ? ' *' : ''}',
              hintText: '0.0-1.0',
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
              LengthLimitingTextInputFormatter(6),
            ],
            validator: (value) {
              if (_isFieldRequired('RatedPowerFactor') &&
                  (value == null || value.trim().isEmpty)) {
                return 'Rated power factor is required';
              }
              if (value != null && value.trim().isNotEmpty) {
                final parsed = double.tryParse(value);
                if (parsed == null) return 'Enter a valid number';
                if (parsed < 0.0 || parsed > 1.0) return 'Must be between 0.0 and 1.0';
              }
              return null;
            },
          ),
        ],
        if (_shouldShowField('Frequency')) ...[
          const SizedBox(height: _fieldSpacing),
          DropdownButtonFormField<String>(
      value: _frequencyController.text.isNotEmpty
        ? _frequencyController.text
                : null,
            decoration: _inputDecoration(
              labelText:
                  'Frequency${_isFieldRequired('Frequency') ? ' *' : ''}',
            ),
            items: const [
              DropdownMenuItem(value: '50:50', child: Text('50:50')),
              DropdownMenuItem(value: '60:60', child: Text('60:60')),
            ],
            onChanged: (val) {
              setState(() {
                _frequencyController.text = val ?? '';
              });
            },
            validator: (value) {
              if (_isFieldRequired('Frequency') &&
                  (value == null || value.toString().trim().isEmpty)) {
                return 'Frequency is required';
              }
              return null;
            },
          ),
        ],
        if (_shouldShowField('InPlantRate')) ...[
          const SizedBox(height: _fieldSpacing),
          TextFormField(
            controller: _inPlantRateController,
            decoration: _inputDecoration(
              labelText:
                  'In-Plant Rate${_isFieldRequired('InPlantRate') ? ' *' : ''}',
              hintText: '%',
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (_isFieldRequired('InPlantRate') &&
                  (value == null || value.trim().isEmpty)) {
                return 'In-plant rate is required';
              }
              return null;
            },
          ),
        ],
        // Continuous operation frequency range (required)
        if (_shouldShowField('ContinuousOperationFrequencyLower')) ...[
          const SizedBox(height: _fieldSpacing),
          TextFormField(
            controller: _continuousOperationFrequencyLowerController,
            decoration: _inputDecoration(
              labelText: 'Continuous Operation Frequency Lower${_isFieldRequired('ContinuousOperationFrequencyLower') ? ' *' : ''}',
              hintText: 'Hz',
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
              LengthLimitingTextInputFormatter(6),
            ],
            validator: (value) {
              if (_isFieldRequired('ContinuousOperationFrequencyLower') &&
                  (value == null || value.trim().isEmpty)) {
                return 'Lower frequency is required';
              }
              if (value != null && value.trim().isNotEmpty) {
                if (double.tryParse(value) == null) return 'Enter a valid number';
              }
              return null;
            },
          ),
        ],
        if (_shouldShowField('ContinuousOperationFrequencyUpper')) ...[
          const SizedBox(height: _fieldSpacing),
          TextFormField(
            controller: _continuousOperationFrequencyUpperController,
            decoration: _inputDecoration(
              labelText: 'Continuous Operation Frequency Upper${_isFieldRequired('ContinuousOperationFrequencyUpper') ? ' *' : ''}',
              hintText: 'Hz',
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
              LengthLimitingTextInputFormatter(6),
            ],
            validator: (value) {
              if (_isFieldRequired('ContinuousOperationFrequencyUpper') &&
                  (value == null || value.trim().isEmpty)) {
                return 'Upper frequency is required';
              }
              if (value != null && value.trim().isNotEmpty) {
                if (double.tryParse(value) == null) return 'Enter a valid number';
              }
              return null;
            },
          ),
        ],
        // Mandatory fields added after frequency upper
        const SizedBox(height: _fieldSpacing),
        TextFormField(
          controller: _blackStartController,
          decoration: _inputDecoration(
            labelText: 'BlackStart *',
            hintText: 'Yes/No or description',
          ),
          keyboardType: TextInputType.text,
          validator: (value) {
            if (value == null || value.trim().isEmpty) return 'BlackStart is required';
            return null;
          },
        ),
        const SizedBox(height: _fieldSpacing),
        TextFormField(
          controller: _ratedOutputController,
          decoration: _inputDecoration(
            labelText: 'Rated Output *',
            hintText: 'kW',
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
            LengthLimitingTextInputFormatter(12),
          ],
          validator: (value) {
            if (value == null || value.trim().isEmpty) return 'Rated output is required';
            if (double.tryParse(value) == null) return 'Enter a valid number';
            return null;
          },
        ),
        const SizedBox(height: _fieldSpacing),
        TextFormField(
          controller: _minimumOutputController,
          decoration: _inputDecoration(
            labelText: 'Minimum Output *',
            hintText: 'kW',
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
            LengthLimitingTextInputFormatter(12),
          ],
          validator: (value) {
            if (value == null || value.trim().isEmpty) return 'Minimum output is required';
            if (double.tryParse(value) == null) return 'Enter a valid number';
            return null;
          },
        ),
        const SizedBox(height: _fieldSpacing),
        TextFormField(
          controller: _authorizedMaximumOutputController,
          decoration: _inputDecoration(
            labelText: 'Authorized Maximum Output *',
            hintText: 'kW',
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
            LengthLimitingTextInputFormatter(12),
          ],
          validator: (value) {
            if (value == null || value.trim().isEmpty) return 'Authorized maximum output is required';
            if (double.tryParse(value) == null) return 'Enter a valid number';
            return null;
          },
        ),
        const SizedBox(height: _fieldSpacing),
        TextFormField(
          controller: _thermalTypeController,
          decoration: _inputDecoration(
            labelText: 'ThermalType *',
            hintText: 'Thermal type code or description',
          ),
          keyboardType: TextInputType.text,
          validator: (value) {
            if (value == null || value.trim().isEmpty) return 'Thermal type is required';
            return null;
          },
        ),
        const SizedBox(height: _fieldSpacing),
        // Continuous Operation Time Limited - decimal input field
        TextFormField(
          initialValue: _continuousOperationTimeLimited,
          decoration: _inputDecoration(labelText: 'Continuous Operation Time Limited *'),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onChanged: (v) {
            setState(() => _continuousOperationTimeLimited = v);
          },
          validator: (value) {
            if (value == null || value.trim().isEmpty) return 'This field is required';
            // Validate that it's a valid decimal number
            if (double.tryParse(value) == null) return 'Must be a valid number';
            return null;
          },
        ),
        const SizedBox(height: _fieldSpacing),
        DropdownButtonFormField<String>(
          value: (_fcbOperation ?? '0'),
          decoration: _inputDecoration(labelText: 'Fcb Operation *'),
          items: const [
            DropdownMenuItem(value: '0', child: Text('NO')),
            DropdownMenuItem(value: '1', child: Text('YES')),
          ],
          onChanged: (v) {
            setState(() => _fcbOperation = v);
          },
          validator: (value) {
            if (value == null || value.trim().isEmpty) return 'This field is required';
            return null;
          },
        ),
        const SizedBox(height: _fieldSpacing),
        DropdownButtonFormField<String>(
          value: (_overPowerOperation ?? '0'),
          decoration: _inputDecoration(labelText: 'Over Power Operation *'),
          items: const [
            DropdownMenuItem(value: '0', child: Text('NO')),
            DropdownMenuItem(value: '1', child: Text('YES')),
          ],
          onChanged: (v) {
            setState(() => _overPowerOperation = v);
          },
          validator: (value) {
            if (value == null || value.trim().isEmpty) return 'This field is required';
            return null;
          },
        ),
        const SizedBox(height: _fieldSpacing),
        DropdownButtonFormField<String>(
          value: (_peakModeOperation ?? '0'),
          decoration: _inputDecoration(labelText: 'Peak Mode Operation *'),
          items: const [
            DropdownMenuItem(value: '0', child: Text('NO')),
            DropdownMenuItem(value: '1', child: Text('YES')),
          ],
          onChanged: (v) {
            setState(() => _peakModeOperation = v);
          },
          validator: (value) {
            if (value == null || value.trim().isEmpty) return 'This field is required';
            return null;
          },
        ),
        const SizedBox(height: _fieldSpacing),
        DropdownButtonFormField<String>(
          value: (_dss ?? '0'),
          decoration: _inputDecoration(labelText: 'Dss *'),
          items: const [
            DropdownMenuItem(value: '0', child: Text('NO')),
            DropdownMenuItem(value: '1', child: Text('YES')),
          ],
          onChanged: (v) {
            setState(() => _dss = v);
          },
          validator: (value) {
            if (value == null || value.trim().isEmpty) return 'This field is required';
            return null;
          },
        ),
      ],
    );
  }

  // Output parameters UI removed — handled elsewhere or not required.

  // Contact section removed - address and phone moved into Basic Information

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _isSubmitting
                ? null
                : () {
                    _formKey.currentState?.reset();
                    _initializeFields();
                  },
            icon: const Icon(Icons.refresh),
            label: const Text('Reset'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _isSubmitting ? null : _saveResource,
            icon: _isSubmitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save),
            label: Text(_isSubmitting ? 'Saving...' : 'Save'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOutputBandTab() {
    // Parse OutputBand data from resource
    final outputBandData = widget.resource['OutputBand'];
    final List<dynamic> outputBandInfo =
        outputBandData != null && outputBandData is Map
            ? (outputBandData['OutputBandInfo'] as List? ?? [])
            : [];

    const int maxRows = 20;
    final bool canAddMore = outputBandInfo.length < maxRows;

    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (outputBandInfo.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 48,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No output band data available',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () => _showOutputBandDialog(context),
                          icon: const Icon(Icons.add),
                          label: const Text('Add First Output Band'),
                        ),
                      ],
                    ),
                  ),
                )
              else
                LayoutBuilder(
                  builder: (context, constraints) {
                    // Use card view on small screens, table on large screens
                    final bool useCardView = constraints.maxWidth < 768;

                    return Column(
                      children: [
                        if (useCardView)
                          _buildCardView(outputBandInfo)
                        else
                          _buildTableView(outputBandInfo),
                        const SizedBox(height: 80), // Space for FAB
                      ],
                    );
                  },
                ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Records: ${outputBandInfo.length} of $maxRows',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (!canAddMore)
                    Chip(
                      label: const Text('Max limit reached'),
                      backgroundColor: Colors.orange[100],
                      avatar: const Icon(Icons.warning, size: 18),
                    ),
                ],
              ),
            ],
          ),
        ),
        // Floating Action Button
        if (canAddMore && outputBandInfo.isNotEmpty)
          Positioned(
            right: 20,
            bottom: 20,
            child: FloatingActionButton(
              onPressed: () => _showOutputBandDialog(context),
              tooltip: 'Add Output Band',
              child: const Icon(Icons.add),
            ),
          ),
      ],
    );
  }

  // Card view for mobile devices
  Widget _buildCardView(List<dynamic> outputBandInfo) {
    return Column(
      children: outputBandInfo.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value;

        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Card Header with Row Number and Actions
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .primaryContainer
                      .withOpacity(0.5),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.label,
                          size: 20,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Output Band #${index + 1}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, size: 20),
                          tooltip: 'Edit',
                          onPressed: () => _showOutputBandDialog(
                            context,
                            existingData: item,
                            index: index,
                          ),
                          color: Theme.of(context).colorScheme.primary,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.delete, size: 20),
                          tooltip: 'Delete',
                          onPressed: () =>
                              _confirmDeleteOutputBand(context, index),
                          color: Colors.red,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Card Content
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildCardRow('Output', item['Output']?.toString() ?? '-',
                        'kW', Icons.electric_bolt),
                    const Divider(height: 20),
                    _buildCardRow(
                        'GF Width',
                        item['GfWidth']?.toString() ?? '-',
                        'kW',
                        Icons.straighten),
                    const Divider(height: 20),
                    _buildCardRow('AFC Width',
                        item['AfcWidth']?.toString() ?? '-', 'kW', Icons.tune),
                    const Divider(height: 20),
                    _buildCardRow(
                        'AFC Variation Speed',
                        item['AfcVariationSpeed']?.toString() ?? '-',
                        'kW/min',
                        Icons.speed),
                    const Divider(height: 20),
                    _buildCardRow(
                        'OTM Variation Speed',
                        item['OtmVariationSpeed']?.toString() ?? '-',
                        'kW/min',
                        Icons.speed),
                    const Divider(height: 20),
                    _buildCardRow(
                        'AFC+OTM Variation Speed',
                        item['AfcOtmVariationSpeed']?.toString() ?? '-',
                        'kW/min',
                        Icons.speed),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // Helper to build card rows
  Widget _buildCardRow(String label, String value, String unit, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          flex: 3,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Flexible(
                child: Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.right,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                unit,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Table view for desktop/tablet
  Widget _buildTableView(List<dynamic> outputBandInfo) {
    return Card(
      elevation: 2,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: MaterialStateProperty.all(
            Theme.of(context).colorScheme.primaryContainer,
          ),
          columnSpacing: 20,
          columns: const [
            DataColumn(
              label: Text(
                '#',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                'Output\n(kW)',
                style: TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            DataColumn(
              label: Text(
                'GF Width\n(kW)',
                style: TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            DataColumn(
              label: Text(
                'AFC Width\n(kW)',
                style: TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            DataColumn(
              label: Text(
                'AFC Variation\nSpeed (kW/min)',
                style: TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            DataColumn(
              label: Text(
                'OTM Variation\nSpeed (kW/min)',
                style: TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            DataColumn(
              label: Text(
                'AFC+OTM Variation\nSpeed (kW/min)',
                style: TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            DataColumn(
              label: Text(
                'Actions',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
          rows: outputBandInfo.asMap().entries.map<DataRow>((entry) {
            final index = entry.key;
            final item = entry.value;

            return DataRow(
              cells: [
                DataCell(Text('${index + 1}')),
                DataCell(Text(item['Output']?.toString() ?? '-')),
                DataCell(Text(item['GfWidth']?.toString() ?? '-')),
                DataCell(Text(item['AfcWidth']?.toString() ?? '-')),
                DataCell(Text(item['AfcVariationSpeed']?.toString() ?? '-')),
                DataCell(Text(item['OtmVariationSpeed']?.toString() ?? '-')),
                DataCell(Text(item['AfcOtmVariationSpeed']?.toString() ?? '-')),
                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, size: 20),
                        tooltip: 'Edit',
                        onPressed: () => _showOutputBandDialog(
                          context,
                          existingData: item,
                          index: index,
                        ),
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, size: 20),
                        tooltip: 'Delete',
                        onPressed: () =>
                            _confirmDeleteOutputBand(context, index),
                        color: Colors.red,
                      ),
                    ],
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showOutputBandDialog(BuildContext context,
      {Map<String, dynamic>? existingData, int? index}) {
    final outputController =
        TextEditingController(text: existingData?['Output']?.toString() ?? '');
    final gfWidthController =
        TextEditingController(text: existingData?['GfWidth']?.toString() ?? '');
    final afcWidthController = TextEditingController(
        text: existingData?['AfcWidth']?.toString() ?? '');
    final afcVariationSpeedController = TextEditingController(
        text: existingData?['AfcVariationSpeed']?.toString() ?? '');
    final otmVariationSpeedController = TextEditingController(
        text: existingData?['OtmVariationSpeed']?.toString() ?? '');
    final afcOtmVariationSpeedController = TextEditingController(
        text: existingData?['AfcOtmVariationSpeed']?.toString() ?? '');

    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              index == null ? Icons.add_circle : Icons.edit,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 12),
            Text(index == null
                ? 'Add Output Band'
                : 'Edit Output Band #${index + 1}'),
          ],
        ),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: SizedBox(
              width: 500,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: outputController,
                    decoration: const InputDecoration(
                      labelText: 'Output (kW)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.electric_bolt),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter output value';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: gfWidthController,
                    decoration: const InputDecoration(
                      labelText: 'GF Width (kW)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.straighten),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter GF width';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: afcWidthController,
                    decoration: const InputDecoration(
                      labelText: 'AFC Width (kW)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.tune),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter AFC width';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: afcVariationSpeedController,
                    decoration: const InputDecoration(
                      labelText: 'AFC Variation Speed (kW/min)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.speed),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter AFC variation speed';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: otmVariationSpeedController,
                    decoration: const InputDecoration(
                      labelText: 'OTM Variation Speed (kW/min)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.speed),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter OTM variation speed';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: afcOtmVariationSpeedController,
                    decoration: const InputDecoration(
                      labelText: 'AFC+OTM Variation Speed (kW/min)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.speed),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter AFC+OTM variation speed';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                final newData = {
                  'Output': outputController.text,
                  'GfWidth': gfWidthController.text,
                  'AfcWidth': afcWidthController.text,
                  'AfcVariationSpeed': afcVariationSpeedController.text,
                  'OtmVariationSpeed': otmVariationSpeedController.text,
                  'AfcOtmVariationSpeed': afcOtmVariationSpeedController.text,
                };

                setState(() {
                  final outputBandData = widget.resource['OutputBand'] ?? {};
                  final List<dynamic> outputBandInfo =
                      outputBandData['OutputBandInfo'] ?? [];

                  if (index == null) {
                    // Add new
                    outputBandInfo.add(newData);
                  } else {
                    // Update existing
                    outputBandInfo[index] = newData;
                  }

                  widget.resource['OutputBand'] = {
                    'OutputBandInfo': outputBandInfo,
                  };
                });

                Navigator.of(context).pop();

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(index == null
                        ? 'Output band added successfully'
                        : 'Output band updated successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: Text(index == null ? 'Add' : 'Save'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteOutputBand(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.orange),
            SizedBox(width: 12),
            Text('Confirm Delete'),
          ],
        ),
        content:
            Text('Are you sure you want to delete Output Band #${index + 1}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                final outputBandData = widget.resource['OutputBand'];
                final List<dynamic> outputBandInfo =
                    outputBandData['OutputBandInfo'];
                outputBandInfo.removeAt(index);
              });

              Navigator.of(context).pop();

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Output band deleted successfully'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchOutputTab() {
    // Parse SwitchOutput data from resource
    final switchOutputData = widget.resource['SwitchOutput'];

    // Handle both single object and array formats
    List<dynamic> switchOutputInfo = [];
    if (switchOutputData != null && switchOutputData is Map) {
      final info = switchOutputData['SwitchOutputInfo'];
      if (info is List) {
        switchOutputInfo = info;
      } else if (info is Map) {
        switchOutputInfo = [info];
      }
    }

    const int maxRows = 20;
    final bool canAddMore = switchOutputInfo.length < maxRows;

    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (switchOutputInfo.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 48,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No switch output data available',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () => _showSwitchOutputDialog(context),
                          icon: const Icon(Icons.add),
                          label: const Text('Add First Switch Output'),
                        ),
                      ],
                    ),
                  ),
                )
              else
                LayoutBuilder(
                  builder: (context, constraints) {
                    final bool useCardView = constraints.maxWidth < 768;

                    return Column(
                      children: [
                        if (useCardView)
                          _buildSwitchOutputCardView(switchOutputInfo)
                        else
                          _buildSwitchOutputTableView(switchOutputInfo),
                        const SizedBox(height: 80),
                      ],
                    );
                  },
                ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Records: ${switchOutputInfo.length} of $maxRows',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (!canAddMore)
                    Chip(
                      label: const Text('Max limit reached'),
                      backgroundColor: Colors.orange[100],
                      avatar: const Icon(Icons.warning, size: 18),
                    ),
                ],
              ),
            ],
          ),
        ),
        if (canAddMore && switchOutputInfo.isNotEmpty)
          Positioned(
            right: 20,
            bottom: 20,
            child: FloatingActionButton(
              onPressed: () => _showSwitchOutputDialog(context),
              tooltip: 'Add Switch Output',
              child: const Icon(Icons.add),
            ),
          ),
      ],
    );
  }

  Widget _buildSwitchOutputCardView(List<dynamic> switchOutputInfo) {
    return Column(
      children: switchOutputInfo.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value;

        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .primaryContainer
                      .withOpacity(0.5),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.power_settings_new,
                            size: 20,
                            color: Theme.of(context).colorScheme.primary),
                        const SizedBox(width: 8),
                        Text(
                          'Switch Output #${index + 1}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, size: 20),
                          tooltip: 'Edit',
                          onPressed: () => _showSwitchOutputDialog(context,
                              existingData: item, index: index),
                          color: Theme.of(context).colorScheme.primary,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.delete, size: 20),
                          tooltip: 'Delete',
                          onPressed: () =>
                              _confirmDeleteSwitchOutput(context, index),
                          color: Colors.red,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildCardRow('Output', item['Output']?.toString() ?? '-',
                        'kW', Icons.electric_bolt),
                    const Divider(height: 20),
                    _buildCardRow(
                        'Switch Time',
                        item['SwitchTime']?.toString() ?? '-',
                        'min',
                        Icons.timer),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSwitchOutputTableView(List<dynamic> switchOutputInfo) {
    return Card(
      elevation: 2,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: MaterialStateProperty.all(
              Theme.of(context).colorScheme.primaryContainer),
          columnSpacing: 60,
          columns: const [
            DataColumn(
                label:
                    Text('#', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(
                label: Text('Output\n(kW)',
                    style: TextStyle(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center)),
            DataColumn(
                label: Text('Switch Time\n(min)',
                    style: TextStyle(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center)),
            DataColumn(
                label: Text('Actions',
                    style: TextStyle(fontWeight: FontWeight.bold))),
          ],
          rows: switchOutputInfo.asMap().entries.map<DataRow>((entry) {
            final index = entry.key;
            final item = entry.value;
            return DataRow(
              cells: [
                DataCell(Text('${index + 1}')),
                DataCell(Text(item['Output']?.toString() ?? '-')),
                DataCell(Text(item['SwitchTime']?.toString() ?? '-')),
                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, size: 20),
                        tooltip: 'Edit',
                        onPressed: () => _showSwitchOutputDialog(context,
                            existingData: item, index: index),
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, size: 20),
                        tooltip: 'Delete',
                        onPressed: () =>
                            _confirmDeleteSwitchOutput(context, index),
                        color: Colors.red,
                      ),
                    ],
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showSwitchOutputDialog(BuildContext context,
      {Map<String, dynamic>? existingData, int? index}) {
    final outputController =
        TextEditingController(text: existingData?['Output']?.toString() ?? '');
    final switchTimeController = TextEditingController(
        text: existingData?['SwitchTime']?.toString() ?? '');
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(index == null ? Icons.add_circle : Icons.edit,
                color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 12),
            Text(index == null
                ? 'Add Switch Output'
                : 'Edit Switch Output #${index + 1}'),
          ],
        ),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: outputController,
                decoration: const InputDecoration(
                  labelText: 'Output (kW)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.electric_bolt),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return 'Please enter output value';
                  if (double.tryParse(value) == null)
                    return 'Please enter a valid number';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: switchTimeController,
                decoration: const InputDecoration(
                  labelText: 'Switch Time (min)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.timer),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return 'Please enter switch time';
                  if (double.tryParse(value) == null)
                    return 'Please enter a valid number';
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                final newData = {
                  'Output': outputController.text,
                  'SwitchTime': switchTimeController.text,
                };
                setState(() {
                  final switchOutputData =
                      widget.resource['SwitchOutput'] ?? {};
                  var info = switchOutputData['SwitchOutputInfo'];
                  List<dynamic> switchOutputInfo;
                  if (info is List) {
                    switchOutputInfo = info;
                  } else if (info is Map) {
                    switchOutputInfo = [info];
                  } else {
                    switchOutputInfo = [];
                  }

                  if (index == null) {
                    switchOutputInfo.add(newData);
                  } else {
                    switchOutputInfo[index] = newData;
                  }
                  widget.resource['SwitchOutput'] = {
                    'SwitchOutputInfo': switchOutputInfo
                  };
                });
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(index == null
                        ? 'Switch output added successfully'
                        : 'Switch output updated successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: Text(index == null ? 'Add' : 'Save'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteSwitchOutput(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.orange),
            SizedBox(width: 12),
            Text('Confirm Delete')
          ],
        ),
        content: Text(
            'Are you sure you want to delete Switch Output #${index + 1}?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              setState(() {
                final switchOutputData = widget.resource['SwitchOutput'];
                var info = switchOutputData['SwitchOutputInfo'];
                if (info is List) {
                  info.removeAt(index);
                }
              });
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Switch output deleted successfully'),
                    backgroundColor: Colors.red),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Widget _buildAfcTab() {
    // Parse OutputRangeBelowAfc data from resource
    final afcData = widget.resource['OutputRangeBelowAfc'];

    // Handle both single object and array formats
    List<dynamic> afcInfo = [];
    if (afcData != null && afcData is Map) {
      final info = afcData['OutputRangeBelowAfcInfo'];
      if (info is List) {
        afcInfo = info;
      } else if (info is Map) {
        afcInfo = [info];
      }
    }

    const int maxRows = 20;
    final bool canAddMore = afcInfo.length < maxRows;

    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (afcInfo.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 48,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No AFC data available',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () => _showAfcDialog(context),
                          icon: const Icon(Icons.add),
                          label: const Text('Add First AFC Record'),
                        ),
                      ],
                    ),
                  ),
                )
              else
                LayoutBuilder(
                  builder: (context, constraints) {
                    final bool useCardView = constraints.maxWidth < 768;

                    return Column(
                      children: [
                        if (useCardView)
                          _buildAfcCardView(afcInfo)
                        else
                          _buildAfcTableView(afcInfo),
                        const SizedBox(height: 80),
                      ],
                    );
                  },
                ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Records: ${afcInfo.length} of $maxRows',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (!canAddMore)
                    Chip(
                      label: const Text('Max limit reached'),
                      backgroundColor: Colors.orange[100],
                      avatar: const Icon(Icons.warning, size: 18),
                    ),
                ],
              ),
            ],
          ),
        ),
        if (canAddMore && afcInfo.isNotEmpty)
          Positioned(
            right: 20,
            bottom: 20,
            child: FloatingActionButton(
              onPressed: () => _showAfcDialog(context),
              tooltip: 'Add AFC Record',
              child: const Icon(Icons.add),
            ),
          ),
      ],
    );
  }

  Widget _buildAfcCardView(List<dynamic> afcInfo) {
    return Column(
      children: afcInfo.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value;

        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .primaryContainer
                      .withOpacity(0.5),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.tune,
                            size: 20,
                            color: Theme.of(context).colorScheme.primary),
                        const SizedBox(width: 8),
                        Text(
                          'AFC Record #${index + 1}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, size: 20),
                          tooltip: 'Edit',
                          onPressed: () => _showAfcDialog(context,
                              existingData: item, index: index),
                          color: Theme.of(context).colorScheme.primary,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.delete, size: 20),
                          tooltip: 'Delete',
                          onPressed: () => _confirmDeleteAfc(context, index),
                          color: Colors.red,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildCardRow('Output', item['Output']?.toString() ?? '-',
                        'kW', Icons.electric_bolt),
                    const Divider(height: 20),
                    _buildCardRow(
                        'Operation Time',
                        item['OperationTime']?.toString() ?? '-',
                        'min',
                        Icons.timer),
                    const Divider(height: 20),
                    _buildCardRow(
                        'Output Variation Speed',
                        item['OutputVariationSpeed']?.toString() ?? '-',
                        'kW/min',
                        Icons.speed),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAfcTableView(List<dynamic> afcInfo) {
    return Card(
      elevation: 2,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: MaterialStateProperty.all(
              Theme.of(context).colorScheme.primaryContainer),
          columnSpacing: 40,
          columns: const [
            DataColumn(
                label:
                    Text('#', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(
                label: Text('Output\n(kW)',
                    style: TextStyle(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center)),
            DataColumn(
                label: Text('Operation Time\n(min)',
                    style: TextStyle(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center)),
            DataColumn(
                label: Text('Output Variation Speed\n(kW/min)',
                    style: TextStyle(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center)),
            DataColumn(
                label: Text('Actions',
                    style: TextStyle(fontWeight: FontWeight.bold))),
          ],
          rows: afcInfo.asMap().entries.map<DataRow>((entry) {
            final index = entry.key;
            final item = entry.value;
            return DataRow(
              cells: [
                DataCell(Text('${index + 1}')),
                DataCell(Text(item['Output']?.toString() ?? '-')),
                DataCell(Text(item['OperationTime']?.toString() ?? '-')),
                DataCell(Text(item['OutputVariationSpeed']?.toString() ?? '-')),
                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, size: 20),
                        tooltip: 'Edit',
                        onPressed: () => _showAfcDialog(context,
                            existingData: item, index: index),
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, size: 20),
                        tooltip: 'Delete',
                        onPressed: () => _confirmDeleteAfc(context, index),
                        color: Colors.red,
                      ),
                    ],
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showAfcDialog(BuildContext context,
      {Map<String, dynamic>? existingData, int? index}) {
    final outputController =
        TextEditingController(text: existingData?['Output']?.toString() ?? '');
    final operationTimeController = TextEditingController(
        text: existingData?['OperationTime']?.toString() ?? '');
    final outputVariationSpeedController = TextEditingController(
        text: existingData?['OutputVariationSpeed']?.toString() ?? '');
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(index == null ? Icons.add_circle : Icons.edit,
                color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 12),
            Text(index == null
                ? 'Add AFC Record'
                : 'Edit AFC Record #${index + 1}'),
          ],
        ),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: outputController,
                decoration: const InputDecoration(
                  labelText: 'Output (kW)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.electric_bolt),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return 'Please enter output value';
                  if (double.tryParse(value) == null)
                    return 'Please enter a valid number';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: operationTimeController,
                decoration: const InputDecoration(
                  labelText: 'Operation Time (min)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.timer),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return 'Please enter operation time';
                  if (double.tryParse(value) == null)
                    return 'Please enter a valid number';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: outputVariationSpeedController,
                decoration: const InputDecoration(
                  labelText: 'Output Variation Speed (kW/min)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.speed),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return 'Please enter output variation speed';
                  if (double.tryParse(value) == null)
                    return 'Please enter a valid number';
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                final newData = {
                  'Output': outputController.text,
                  'OperationTime': operationTimeController.text,
                  'OutputVariationSpeed': outputVariationSpeedController.text,
                };
                setState(() {
                  final afcData = widget.resource['OutputRangeBelowAfc'] ?? {};
                  var info = afcData['OutputRangeBelowAfcInfo'];
                  List<dynamic> afcInfo;
                  if (info is List) {
                    afcInfo = info;
                  } else if (info is Map) {
                    afcInfo = [info];
                  } else {
                    afcInfo = [];
                  }

                  if (index == null) {
                    afcInfo.add(newData);
                  } else {
                    afcInfo[index] = newData;
                  }
                  widget.resource['OutputRangeBelowAfc'] = {
                    'OutputRangeBelowAfcInfo': afcInfo
                  };
                });
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(index == null
                        ? 'AFC record added successfully'
                        : 'AFC record updated successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: Text(index == null ? 'Add' : 'Save'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteAfc(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.orange),
            SizedBox(width: 12),
            Text('Confirm Delete')
          ],
        ),
        content:
            Text('Are you sure you want to delete AFC Record #${index + 1}?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              setState(() {
                final afcData = widget.resource['OutputRangeBelowAfc'];
                var info = afcData['OutputRangeBelowAfcInfo'];
                if (info is List) {
                  info.removeAt(index);
                }
              });
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('AFC record deleted successfully'),
                    backgroundColor: Colors.red),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Widget _buildStartupPatternTab() {
    // Parse StartupPattern data from resource
    final startupPatternData = widget.resource['StartupPattern'];

    // Handle both single object and array formats
    List<dynamic> patterns = [];
    if (startupPatternData != null && startupPatternData is Map) {
      final info = startupPatternData['StartupPatternInfo'];
      if (info is List) {
        patterns = info;
      } else if (info is Map) {
        patterns = [info];
      }
    }

    // Ensure selected index is valid
    if (_selectedStartupPatternIndex >= patterns.length) {
      _selectedStartupPatternIndex = patterns.isNotEmpty ? 0 : 0;
    }

    // Get selected pattern data
    final selectedPattern =
        patterns.isNotEmpty && _selectedStartupPatternIndex < patterns.length
            ? patterns[_selectedStartupPatternIndex]
            : null;

    final String patternName =
        selectedPattern?['PatternName']?.toString() ?? '-';
    final List<dynamic> events =
        selectedPattern?['StartupPatternEvent'] as List? ?? [];

    const int maxPatterns = 10;
    const int maxEvents = 20;
    final bool canAddMorePatterns = patterns.length < maxPatterns;
    final bool canAddMoreEvents = events.length < maxEvents;

    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (patterns.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 48,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No startup patterns available',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () => _showStartupPatternDialog(context),
                          icon: const Icon(Icons.add),
                          label: const Text('Add First Pattern'),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Pattern selection chips with edit/delete
                    Row(
                      children: [
                        Expanded(
                          child: Wrap(
                            spacing: 8.0,
                            runSpacing: 8.0,
                            children: patterns.asMap().entries.map((entry) {
                              final index = entry.key;
                              final pattern = entry.value;
                              final name = pattern['PatternName']?.toString() ??
                                  'Pattern ${index + 1}';
                              final isSelected =
                                  index == _selectedStartupPatternIndex;

                              return FilterChip(
                                label: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(name),
                                    if (isSelected) ...[
                                      const SizedBox(width: 8),
                                      InkWell(
                                        onTap: () => _showStartupPatternDialog(
                                            context,
                                            existingData: pattern,
                                            index: index),
                                        child: const Icon(Icons.edit, size: 16),
                                      ),
                                      const SizedBox(width: 4),
                                      InkWell(
                                        onTap: () =>
                                            _confirmDeleteStartupPattern(
                                                context, index),
                                        child:
                                            const Icon(Icons.close, size: 16),
                                      ),
                                    ],
                                  ],
                                ),
                                selected: isSelected,
                                onSelected: (selected) {
                                  if (selected) {
                                    setState(() {
                                      _selectedStartupPatternIndex = index;
                                    });
                                  }
                                },
                                selectedColor: Theme.of(context)
                                    .colorScheme
                                    .primaryContainer,
                                checkmarkColor:
                                    Theme.of(context).colorScheme.primary,
                                labelStyle: TextStyle(
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Pattern ${_selectedStartupPatternIndex + 1} of ${patterns.length} (max $maxPatterns)',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        if (!canAddMorePatterns)
                          Chip(
                            label: const Text('Max patterns reached'),
                            backgroundColor: Colors.orange[100],
                            avatar: const Icon(Icons.warning, size: 16),
                            labelPadding:
                                const EdgeInsets.symmetric(horizontal: 4),
                            visualDensity: VisualDensity.compact,
                          ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Selected pattern details card
                    Card(
                      elevation: 1,
                      color: Theme.of(context)
                          .colorScheme
                          .primaryContainer
                          .withOpacity(0.3),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            const Icon(Icons.label, size: 20),
                            const SizedBox(width: 12),
                            Text(
                              'Pattern Name: ',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                patternName,
                                style: const TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Events section
                    Text(
                      'Events',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (events.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            children: [
                              Icon(
                                Icons.event_note,
                                size: 40,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'No events in this pattern',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 12),
                              ElevatedButton.icon(
                                onPressed: () =>
                                    _showStartupEventDialog(context),
                                icon: const Icon(Icons.add),
                                label: const Text('Add First Event'),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final bool useCardView = constraints.maxWidth < 768;

                          return Column(
                            children: [
                              if (useCardView)
                                _buildStartupEventsCardView(events)
                              else
                                _buildStartupEventsTableView(events),
                              const SizedBox(height: 80),
                            ],
                          );
                        },
                      ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total Events: ${events.length} of $maxEvents',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (!canAddMoreEvents)
                          Chip(
                            label: const Text('Max events reached'),
                            backgroundColor: Colors.orange[100],
                            avatar: const Icon(Icons.warning, size: 18),
                          ),
                      ],
                    ),
                  ],
                ),
            ],
          ),
        ),
        // FABs for adding patterns and events
        if (patterns.isNotEmpty && canAddMoreEvents && events.isNotEmpty)
          Positioned(
            right: 20,
            bottom: 20,
            child: FloatingActionButton(
              onPressed: () => _showStartupEventDialog(context),
              tooltip: 'Add Event',
              child: const Icon(Icons.add),
            ),
          ),
        if (canAddMorePatterns && patterns.isNotEmpty)
          Positioned(
            right: 90,
            bottom: 20,
            child: FloatingActionButton.extended(
              onPressed: () => _showStartupPatternDialog(context),
              tooltip: 'Add Pattern',
              icon: const Icon(Icons.playlist_add),
              label: const Text('Pattern'),
            ),
          ),
      ],
    );
  }

  Widget _buildStartupEventsCardView(List<dynamic> events) {
    return Column(
      children: events.asMap().entries.map((entry) {
        final index = entry.key;
        final event = entry.value;

        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .secondaryContainer
                      .withOpacity(0.5),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.event,
                            size: 20,
                            color: Theme.of(context).colorScheme.secondary),
                        const SizedBox(width: 8),
                        Text(
                          'Event #${index + 1}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, size: 20),
                          tooltip: 'Edit',
                          onPressed: () => _showStartupEventDialog(context,
                              existingData: event, index: index),
                          color: Theme.of(context).colorScheme.primary,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.delete, size: 20),
                          tooltip: 'Delete',
                          onPressed: () =>
                              _confirmDeleteStartupEvent(context, index),
                          color: Colors.red,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildCardRow('Event Name',
                        event['EventName']?.toString() ?? '-', '', Icons.label),
                    const Divider(height: 20),
                    _buildCardRow(
                        'Change Time',
                        event['ChangeTime']?.toString() ?? '-',
                        'min:sec',
                        Icons.timer),
                    const Divider(height: 20),
                    _buildCardRow('Output', event['Output']?.toString() ?? '-',
                        'kW', Icons.electric_bolt),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStartupEventsTableView(List<dynamic> events) {
    return Card(
      elevation: 2,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: MaterialStateProperty.all(
              Theme.of(context).colorScheme.secondaryContainer),
          columnSpacing: 40,
          columns: const [
            DataColumn(
                label:
                    Text('#', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(
                label: Text('Event Name',
                    style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(
                label: Text('Change Time\n(min:sec)',
                    style: TextStyle(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center)),
            DataColumn(
                label: Text('Output\n(kW)',
                    style: TextStyle(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center)),
            DataColumn(
                label: Text('Actions',
                    style: TextStyle(fontWeight: FontWeight.bold))),
          ],
          rows: events.asMap().entries.map<DataRow>((entry) {
            final index = entry.key;
            final event = entry.value;
            return DataRow(
              cells: [
                DataCell(Text('${index + 1}')),
                DataCell(Text(event['EventName']?.toString() ?? '-')),
                DataCell(Text(event['ChangeTime']?.toString() ?? '-')),
                DataCell(Text(event['Output']?.toString() ?? '-')),
                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, size: 20),
                        tooltip: 'Edit',
                        onPressed: () => _showStartupEventDialog(context,
                            existingData: event, index: index),
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, size: 20),
                        tooltip: 'Delete',
                        onPressed: () =>
                            _confirmDeleteStartupEvent(context, index),
                        color: Colors.red,
                      ),
                    ],
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showStartupPatternDialog(BuildContext context,
      {Map<String, dynamic>? existingData, int? index}) {
    final patternNameController = TextEditingController(
        text: existingData?['PatternName']?.toString() ?? '');
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(index == null ? Icons.add_circle : Icons.edit,
                color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 12),
            Text(index == null ? 'Add Startup Pattern' : 'Edit Pattern Name'),
          ],
        ),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: patternNameController,
            decoration: const InputDecoration(
              labelText: 'Pattern Name',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.label),
            ),
            validator: (value) {
              if (value == null || value.isEmpty)
                return 'Please enter pattern name';
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                setState(() {
                  final startupPatternData =
                      widget.resource['StartupPattern'] ?? {};
                  var info = startupPatternData['StartupPatternInfo'];
                  List<dynamic> patterns;
                  if (info is List) {
                    patterns = info;
                  } else if (info is Map) {
                    patterns = [info];
                  } else {
                    patterns = [];
                  }

                  if (index == null) {
                    // Add new pattern
                    patterns.add({
                      'PatternName': patternNameController.text,
                      'StartupPatternEvent': [],
                    });
                    _selectedStartupPatternIndex = patterns.length - 1;
                  } else {
                    // Edit existing pattern
                    patterns[index]['PatternName'] = patternNameController.text;
                  }
                  widget.resource['StartupPattern'] = {
                    'StartupPatternInfo': patterns
                  };
                });
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(index == null
                        ? 'Pattern added successfully'
                        : 'Pattern updated successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: Text(index == null ? 'Add' : 'Save'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteStartupPattern(BuildContext context, int index) {
    final patterns =
        (widget.resource['StartupPattern']?['StartupPatternInfo'] as List?) ??
            [];
    final patternName =
        patterns[index]['PatternName']?.toString() ?? 'Pattern ${index + 1}';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.orange),
            SizedBox(width: 12),
            Text('Confirm Delete')
          ],
        ),
        content: Text(
            'Are you sure you want to delete pattern "$patternName"? All events in this pattern will be deleted.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              setState(() {
                patterns.removeAt(index);
                if (_selectedStartupPatternIndex >= patterns.length) {
                  _selectedStartupPatternIndex =
                      patterns.isNotEmpty ? patterns.length - 1 : 0;
                }
              });
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Pattern deleted successfully'),
                    backgroundColor: Colors.red),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showStartupEventDialog(BuildContext context,
      {Map<String, dynamic>? existingData, int? index}) {
    final eventNameController = TextEditingController(
        text: existingData?['EventName']?.toString() ?? '');
    final changeTimeController = TextEditingController(
        text: existingData?['ChangeTime']?.toString() ?? '');
    final outputController =
        TextEditingController(text: existingData?['Output']?.toString() ?? '');
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(index == null ? Icons.add_circle : Icons.edit,
                color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 12),
            Text(index == null ? 'Add Event' : 'Edit Event #${index + 1}'),
          ],
        ),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: eventNameController,
                decoration: const InputDecoration(
                  labelText: 'Event Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.label),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return 'Please enter event name';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: changeTimeController,
                decoration: const InputDecoration(
                  labelText: 'Change Time (min:sec)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.timer),
                  hintText: 'e.g., 5:30',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return 'Please enter change time';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: outputController,
                decoration: const InputDecoration(
                  labelText: 'Output (kW)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.electric_bolt),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return 'Please enter output value';
                  if (double.tryParse(value) == null)
                    return 'Please enter a valid number';
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                final newEvent = {
                  'EventName': eventNameController.text,
                  'ChangeTime': changeTimeController.text,
                  'Output': outputController.text,
                };
                setState(() {
                  final patterns = (widget.resource['StartupPattern']
                          ?['StartupPatternInfo'] as List?) ??
                      [];
                  if (patterns.isNotEmpty &&
                      _selectedStartupPatternIndex < patterns.length) {
                    final selectedPattern =
                        patterns[_selectedStartupPatternIndex];
                    List<dynamic> events =
                        selectedPattern['StartupPatternEvent'] as List? ?? [];

                    if (index == null) {
                      events.add(newEvent);
                    } else {
                      events[index] = newEvent;
                    }
                    selectedPattern['StartupPatternEvent'] = events;
                  }
                });
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(index == null
                        ? 'Event added successfully'
                        : 'Event updated successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: Text(index == null ? 'Add' : 'Save'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteStartupEvent(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.orange),
            SizedBox(width: 12),
            Text('Confirm Delete')
          ],
        ),
        content: Text('Are you sure you want to delete Event #${index + 1}?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              setState(() {
                final patterns = (widget.resource['StartupPattern']
                        ?['StartupPatternInfo'] as List?) ??
                    [];
                if (patterns.isNotEmpty &&
                    _selectedStartupPatternIndex < patterns.length) {
                  final selectedPattern =
                      patterns[_selectedStartupPatternIndex];
                  List<dynamic> events =
                      selectedPattern['StartupPatternEvent'] as List? ?? [];
                  events.removeAt(index);
                }
              });
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Event deleted successfully'),
                    backgroundColor: Colors.red),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Widget _buildStopPatternTab() {
    // Parse StopPattern data from resource
    final stopPatternData = widget.resource['StopPattern'];

    // Handle both single object and array formats
    List<dynamic> patterns = [];
    if (stopPatternData != null && stopPatternData is Map) {
      final info = stopPatternData['StopPatternInfo'];
      if (info is List) {
        patterns = info;
      } else if (info is Map) {
        patterns = [info];
      }
    }

    // Ensure selected index is valid
    if (_selectedStopPatternIndex >= patterns.length) {
      _selectedStopPatternIndex = patterns.isNotEmpty ? 0 : 0;
    }

    // Get selected pattern data
    final selectedPattern =
        patterns.isNotEmpty && _selectedStopPatternIndex < patterns.length
            ? patterns[_selectedStopPatternIndex]
            : null;

    final String patternName =
        selectedPattern?['PatternName']?.toString() ?? '-';
    final List<dynamic> events =
        selectedPattern?['StopPatternEvent'] as List? ?? [];

    const int maxPatterns = 10;
    const int maxEvents = 20;
    final bool canAddMorePatterns = patterns.length < maxPatterns;
    final bool canAddMoreEvents = events.length < maxEvents;

    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (patterns.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 48,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No stop patterns available',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () => _showStopPatternDialog(context),
                          icon: const Icon(Icons.add),
                          label: const Text('Add First Pattern'),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Pattern selection chips with edit/delete
                    Row(
                      children: [
                        Expanded(
                          child: Wrap(
                            spacing: 8.0,
                            runSpacing: 8.0,
                            children: patterns.asMap().entries.map((entry) {
                              final index = entry.key;
                              final pattern = entry.value;
                              final name = pattern['PatternName']?.toString() ??
                                  'Pattern ${index + 1}';
                              final isSelected =
                                  index == _selectedStopPatternIndex;

                              return FilterChip(
                                label: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(name),
                                    if (isSelected) ...[
                                      const SizedBox(width: 8),
                                      InkWell(
                                        onTap: () => _showStopPatternDialog(
                                            context,
                                            existingData: pattern,
                                            index: index),
                                        child: const Icon(Icons.edit, size: 16),
                                      ),
                                      const SizedBox(width: 4),
                                      InkWell(
                                        onTap: () => _confirmDeleteStopPattern(
                                            context, index),
                                        child:
                                            const Icon(Icons.close, size: 16),
                                      ),
                                    ],
                                  ],
                                ),
                                selected: isSelected,
                                onSelected: (selected) {
                                  if (selected) {
                                    setState(() {
                                      _selectedStopPatternIndex = index;
                                    });
                                  }
                                },
                                selectedColor: Theme.of(context)
                                    .colorScheme
                                    .primaryContainer,
                                checkmarkColor:
                                    Theme.of(context).colorScheme.primary,
                                labelStyle: TextStyle(
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Pattern ${_selectedStopPatternIndex + 1} of ${patterns.length} (max $maxPatterns)',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        if (!canAddMorePatterns)
                          Chip(
                            label: const Text('Max patterns reached'),
                            backgroundColor: Colors.orange[100],
                            avatar: const Icon(Icons.warning, size: 16),
                            labelPadding:
                                const EdgeInsets.symmetric(horizontal: 4),
                            visualDensity: VisualDensity.compact,
                          ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Selected pattern details card
                    Card(
                      elevation: 1,
                      color: Theme.of(context)
                          .colorScheme
                          .primaryContainer
                          .withOpacity(0.3),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            const Icon(Icons.label, size: 20),
                            const SizedBox(width: 12),
                            Text(
                              'Pattern Name: ',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                patternName,
                                style: const TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Events section
                    Text(
                      'Events',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (events.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            children: [
                              Icon(
                                Icons.event_note,
                                size: 40,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'No events in this pattern',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 12),
                              ElevatedButton.icon(
                                onPressed: () => _showStopEventDialog(context),
                                icon: const Icon(Icons.add),
                                label: const Text('Add First Event'),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final bool useCardView = constraints.maxWidth < 768;

                          return Column(
                            children: [
                              if (useCardView)
                                _buildStopEventsCardView(events)
                              else
                                _buildStopEventsTableView(events),
                              const SizedBox(height: 80),
                            ],
                          );
                        },
                      ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total Events: ${events.length} of $maxEvents',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (!canAddMoreEvents)
                          Chip(
                            label: const Text('Max events reached'),
                            backgroundColor: Colors.orange[100],
                            avatar: const Icon(Icons.warning, size: 18),
                          ),
                      ],
                    ),
                  ],
                ),
            ],
          ),
        ),
        // FABs for adding patterns and events
        if (patterns.isNotEmpty && canAddMoreEvents && events.isNotEmpty)
          Positioned(
            right: 20,
            bottom: 20,
            child: FloatingActionButton(
              onPressed: () => _showStopEventDialog(context),
              tooltip: 'Add Event',
              child: const Icon(Icons.add),
            ),
          ),
        if (canAddMorePatterns && patterns.isNotEmpty)
          Positioned(
            right: 90,
            bottom: 20,
            child: FloatingActionButton.extended(
              onPressed: () => _showStopPatternDialog(context),
              tooltip: 'Add Pattern',
              icon: const Icon(Icons.playlist_add),
              label: const Text('Pattern'),
            ),
          ),
      ],
    );
  }

  Widget _buildStopEventsCardView(List<dynamic> events) {
    return Column(
      children: events.asMap().entries.map((entry) {
        final index = entry.key;
        final event = entry.value;

        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .errorContainer
                      .withOpacity(0.5),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.event,
                            size: 20,
                            color: Theme.of(context).colorScheme.error),
                        const SizedBox(width: 8),
                        Text(
                          'Event #${index + 1}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, size: 20),
                          tooltip: 'Edit',
                          onPressed: () => _showStopEventDialog(context,
                              existingData: event, index: index),
                          color: Theme.of(context).colorScheme.primary,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.delete, size: 20),
                          tooltip: 'Delete',
                          onPressed: () =>
                              _confirmDeleteStopEvent(context, index),
                          color: Colors.red,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildCardRow('Event Name',
                        event['EventName']?.toString() ?? '-', '', Icons.label),
                    const Divider(height: 20),
                    _buildCardRow(
                        'Change Time',
                        event['ChangeTime']?.toString() ?? '-',
                        'min:sec',
                        Icons.timer),
                    const Divider(height: 20),
                    _buildCardRow('Output', event['Output']?.toString() ?? '-',
                        'kW', Icons.electric_bolt),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStopEventsTableView(List<dynamic> events) {
    return Card(
      elevation: 2,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: MaterialStateProperty.all(
              Theme.of(context).colorScheme.errorContainer),
          columnSpacing: 40,
          columns: const [
            DataColumn(
                label:
                    Text('#', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(
                label: Text('Event Name',
                    style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(
                label: Text('Change Time\n(min:sec)',
                    style: TextStyle(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center)),
            DataColumn(
                label: Text('Output\n(kW)',
                    style: TextStyle(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center)),
            DataColumn(
                label: Text('Actions',
                    style: TextStyle(fontWeight: FontWeight.bold))),
          ],
          rows: events.asMap().entries.map<DataRow>((entry) {
            final index = entry.key;
            final event = entry.value;
            return DataRow(
              cells: [
                DataCell(Text('${index + 1}')),
                DataCell(Text(event['EventName']?.toString() ?? '-')),
                DataCell(Text(event['ChangeTime']?.toString() ?? '-')),
                DataCell(Text(event['Output']?.toString() ?? '-')),
                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, size: 20),
                        tooltip: 'Edit',
                        onPressed: () => _showStopEventDialog(context,
                            existingData: event, index: index),
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, size: 20),
                        tooltip: 'Delete',
                        onPressed: () =>
                            _confirmDeleteStopEvent(context, index),
                        color: Colors.red,
                      ),
                    ],
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showStopPatternDialog(BuildContext context,
      {Map<String, dynamic>? existingData, int? index}) {
    final patternNameController = TextEditingController(
        text: existingData?['PatternName']?.toString() ?? '');
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(index == null ? Icons.add_circle : Icons.edit,
                color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 12),
            Text(index == null ? 'Add Stop Pattern' : 'Edit Pattern Name'),
          ],
        ),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: patternNameController,
            decoration: const InputDecoration(
              labelText: 'Pattern Name',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.label),
            ),
            validator: (value) {
              if (value == null || value.isEmpty)
                return 'Please enter pattern name';
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                setState(() {
                  final stopPatternData = widget.resource['StopPattern'] ?? {};
                  var info = stopPatternData['StopPatternInfo'];
                  List<dynamic> patterns;
                  if (info is List) {
                    patterns = info;
                  } else if (info is Map) {
                    patterns = [info];
                  } else {
                    patterns = [];
                  }

                  if (index == null) {
                    // Add new pattern
                    patterns.add({
                      'PatternName': patternNameController.text,
                      'StopPatternEvent': [],
                    });
                    _selectedStopPatternIndex = patterns.length - 1;
                  } else {
                    // Edit existing pattern
                    patterns[index]['PatternName'] = patternNameController.text;
                  }
                  widget.resource['StopPattern'] = {
                    'StopPatternInfo': patterns
                  };
                });
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(index == null
                        ? 'Pattern added successfully'
                        : 'Pattern updated successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: Text(index == null ? 'Add' : 'Save'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteStopPattern(BuildContext context, int index) {
    final patterns =
        (widget.resource['StopPattern']?['StopPatternInfo'] as List?) ?? [];
    final patternName =
        patterns[index]['PatternName']?.toString() ?? 'Pattern ${index + 1}';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.orange),
            SizedBox(width: 12),
            Text('Confirm Delete')
          ],
        ),
        content: Text(
            'Are you sure you want to delete pattern "$patternName"? All events in this pattern will be deleted.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              setState(() {
                patterns.removeAt(index);
                if (_selectedStopPatternIndex >= patterns.length) {
                  _selectedStopPatternIndex =
                      patterns.isNotEmpty ? patterns.length - 1 : 0;
                }
              });
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Pattern deleted successfully'),
                    backgroundColor: Colors.red),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showStopEventDialog(BuildContext context,
      {Map<String, dynamic>? existingData, int? index}) {
    final eventNameController = TextEditingController(
        text: existingData?['EventName']?.toString() ?? '');
    final changeTimeController = TextEditingController(
        text: existingData?['ChangeTime']?.toString() ?? '');
    final outputController =
        TextEditingController(text: existingData?['Output']?.toString() ?? '');
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(index == null ? Icons.add_circle : Icons.edit,
                color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 12),
            Text(index == null ? 'Add Event' : 'Edit Event #${index + 1}'),
          ],
        ),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: eventNameController,
                decoration: const InputDecoration(
                  labelText: 'Event Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.label),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return 'Please enter event name';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: changeTimeController,
                decoration: const InputDecoration(
                  labelText: 'Change Time (min:sec)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.timer),
                  hintText: 'e.g., 5:30',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return 'Please enter change time';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: outputController,
                decoration: const InputDecoration(
                  labelText: 'Output (kW)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.electric_bolt),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return 'Please enter output value';
                  if (double.tryParse(value) == null)
                    return 'Please enter a valid number';
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                final newEvent = {
                  'EventName': eventNameController.text,
                  'ChangeTime': changeTimeController.text,
                  'Output': outputController.text,
                };
                setState(() {
                  final patterns = (widget.resource['StopPattern']
                          ?['StopPatternInfo'] as List?) ??
                      [];
                  if (patterns.isNotEmpty &&
                      _selectedStopPatternIndex < patterns.length) {
                    final selectedPattern = patterns[_selectedStopPatternIndex];
                    List<dynamic> events =
                        selectedPattern['StopPatternEvent'] as List? ?? [];

                    if (index == null) {
                      events.add(newEvent);
                    } else {
                      events[index] = newEvent;
                    }
                    selectedPattern['StopPatternEvent'] = events;
                  }
                });
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(index == null
                        ? 'Event added successfully'
                        : 'Event updated successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: Text(index == null ? 'Add' : 'Save'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteStopEvent(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.orange),
            SizedBox(width: 12),
            Text('Confirm Delete')
          ],
        ),
        content: Text('Are you sure you want to delete Event #${index + 1}?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              setState(() {
                final patterns = (widget.resource['StopPattern']
                        ?['StopPatternInfo'] as List?) ??
                    [];
                if (patterns.isNotEmpty &&
                    _selectedStopPatternIndex < patterns.length) {
                  final selectedPattern = patterns[_selectedStopPatternIndex];
                  List<dynamic> events =
                      selectedPattern['StopPatternEvent'] as List? ?? [];
                  events.removeAt(index);
                }
              });
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Event deleted successfully'),
                    backgroundColor: Colors.red),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  // Helper methods for field visibility and requirement based on en.json controlParams
  bool _shouldShowField(String fieldName) {
    if (_selectedResourceType == null) return true;

    // Get field visibility from THERMAL controlParams in en.json
    // -1 = hidden, 0 = optional, 1 = required
    final thermalControlParams = _getThermalControlParams();
    final visibility = thermalControlParams[fieldName];

    // If field not found in controlParams, show it by default
    if (visibility == null) return true;

    // Hide field if visibility is -1
    return visibility != -1;
  }

  bool _isFieldRequired(String fieldName) {
    if (_selectedResourceType == null) return false;

    // Based on en.json controlParams: 1 = required, 0 = optional, -1 = hidden
    final thermalControlParams = _getThermalControlParams();
    final visibility = thermalControlParams[fieldName];

    // Field is required if visibility is 1
    return visibility == 1;
  }

  // THERMAL controlParams from en.json
  Map<String, int> _getThermalControlParams() {
    return {
      "ParticipantName": 1,
      "ResourceName": 1,
      "Area": 1,
      "StartDate": 1,
      "EndDate": 0,
      "SystemCode": 1,
      "ResourceShortName": 1,
      "ResourceLongName": 1,
      "BgCode": 1,
      "Pri": 0,
      "PriResponseTime": 0,
      "PriContinuousTime": 0,
      "PriMaximumSupplyQuantity": 1,
      "PriRemResvUtilization": 1,
      "PriRemResvMaximumSupplyQuantity": 0,
      "Sec1": 0,
      "Sec1ResponseTime": 0,
      "Sec1ContinuousTime": 0,
      "Sec1MaximumSupplyQuantity": 1,
      "Sec1RemResvUtilization": 1,
      "Sec1RemResvMaximumSupplyQuantity": 0,
      "Sec2": 0,
      "Sec2ResponseTime": 0,
      "Sec2ContinuousTime": 0,
      "Sec2DownTime": 0,
      "Sec2MaximumSupplyQuantity": 1,
      "Sec2RemResvUtilization": 1,
      "Sec2RemResvMaximumSupplyQuantity": 0,
      "Ter1": 0,
      "Ter1ResponseTime": 0,
      "Ter1ContinuousTime": 0,
      "Ter1MaximumSupplyQuantity": 1,
      "Ter1RemResvUtilization": 1,
      "Ter1RemResvMaximumSupplyQuantity": 0,
      "Ter2": 0,
      "Ter2ResponseTime": 0,
      "Ter2ContinuousTime": 0,
      "Ter2MaximumSupplyQuantity": 1,
      "Ter2RemResvUtilization": 1,
      "Ter2RemResvMaximumSupplyQuantity": 0,
      "PriSec1CommandOperationMethod": 0,
      "Sec2Ter1Ter2CommandOperationMethod": 0,
      "SignalType": 1,
      "BaselineSettingMethod": -1,
      "ContractExistence": 0,
      "DeclaredMaximumUnitPrice": 0,
      "VoltageAdjustment": 1,
      "Address": 1,
      "PayeePhonePart1": 1,
      "PayeePhonePart2": 1,
      "PayeePhonePart3": 1,
      "VenId": 0,
      "MarketContext": 0,
      "ModelName": 0,
      "RatedCapacity": 1,
      "RatedVoltage": 1,
      "ContinuousOperationVoltage": 1,
      "RatedPowerFactor": 1,
      "Frequency": 1,
      "InPlantRate": 1,
      "ContinuousOperationFrequencyLower": 1,
      "ContinuousOperationFrequencyUpper": 1,
      "BlackStart": 1,
      "RatedOutput": 1,
      "MinimumOutput": 1,
      "AuthorizedMaximumOutput": 1,
      "ThermalType": 1,
      "BatteryCapacity": -1,
      "PumpCharging": -1,
      "VariableSpeedOperation": -1,
      "DischargingOutput": -1,
      "DischargingTime": -1,
      "ChargingOutput": -1,
      "ChargingTime": -1,
      "FullPowerGenerationTime": -1,
      "ContinuousOperationTime": -1,
      "ContinuousOperationTimeLimited": 0,
      "PhaseModifyingOperation": -1,
      "AmountOfWaterUsed": -1,
      "ReservoirCapacity": -1,
      "InflowAmount": -1,
      "ContinuousOperationOutput": -1,
      "PumpedSupply": -1,
      "FcbOperation": 1,
      "OverPowerOperation": 1,
      "PeakModeOperation": 1,
      "Dss": 1,
      "OverPowerOperationMaximumOutput": 0,
      "PeakModeOperationMaximumOutput": 0,
      "OperationTime": 1,
      "NumberOfStartups": 1,
      "AfcMinimumOutput": 1,
      "GfVariationRate": 0,
      "DeadBand": 0,
      "FrequencyMeasurementInterval": 0,
      "FrequencyMeasurementError": 0,
      "DelayTime": 0,
      "GfWidthOutOfRatedOutput": 0,
      "OutputBand": 1,
      "SwitchOutput": 1,
      "OutputRangeBelowAfc": 1,
      "StartupPattern": 1,
      "StopPattern": 1
    };
  }

  List<DropdownMenuItem<String>> _getAreaOptions() {
    return [
      const DropdownMenuItem(value: '01', child: Text('HOKKAIDO')),
      const DropdownMenuItem(value: '02', child: Text('TOHOKU')),
      const DropdownMenuItem(value: '03', child: Text('TOKYO')),
      const DropdownMenuItem(value: '04', child: Text('CHUBU')),
      const DropdownMenuItem(value: '05', child: Text('HOKURIKU')),
      const DropdownMenuItem(value: '06', child: Text('KANSAI')),
      const DropdownMenuItem(value: '07', child: Text('CHUGOKU')),
      const DropdownMenuItem(value: '08', child: Text('SHIKOKU')),
      const DropdownMenuItem(value: '09', child: Text('KYUSHU')),
      const DropdownMenuItem(value: '10', child: Text('OKINAWA')),
    ];
  }

  List<DropdownMenuItem<String>> _getResourceTypeOptions() {
    return [
      const DropdownMenuItem(value: 'THERMAL', child: Text('THERMAL')),
      const DropdownMenuItem(value: 'PUMP', child: Text('PUMP')),
      const DropdownMenuItem(value: 'HYDRO', child: Text('HYDRO')),
      const DropdownMenuItem(value: 'BATTERY', child: Text('BATTERY')),
      const DropdownMenuItem(value: 'VPP_DEM', child: Text('VPP_DEM')),
      const DropdownMenuItem(value: 'VPP_GEN', child: Text('VPP_GEN')),
      const DropdownMenuItem(value: 'VPP_GEN_AND_DEM', child: Text('VPP_GEN_AND_DEM')),
    ];
  }

  // Thermal type options removed - kept if needed in future

  List<DropdownMenuItem<String>> _getContractTypeOptions() {
    // If area is explicitly 'OKINAWA' (string), show the default set.
    // For all other areas (Non OKINAWA) return the restricted set.
    // Okinawa area is represented by code '10'
    if ((_selectedArea ?? '') == '10') {
      // OKINAWA-specific contract types
      return [
        const DropdownMenuItem(value: '3', child: Text('POWER_SUPPLY_II')),
        const DropdownMenuItem(value: '4', child: Text('ONLY_POWER_SUPPLY_I')),
      ];
    }

    // Non-OKINAWA contract types
    return [
      const DropdownMenuItem(value: '1', child: Text('MARKET')),
      const DropdownMenuItem(
          value: '5', child: Text('MARKET_AND_REMAINING_RESERVE_UTILIZATION')),
      const DropdownMenuItem(
          value: '6', child: Text('REMAINING_RESERVE_UTILIZATION')),
    ];
  }

  Future<void> _saveResource() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fix validation errors'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Build payload from form fields
      final Map<String, dynamic> payload = {
        'ParticipantName': _participantNameController.text,
        'ResourceName': _resourceNameController.text,
        'SystemCode': _systemCodeController.text,
        'ResourceShortName': _resourceShortNameController.text,
        'ResourceLongName': _resourceLongNameController.text,
        'BgCode': _bgCodeController.text,
        // Technical / newly added fields
        'VenId': _venIdController.text,
        'ModelName': _modelNameController.text,
        'RatedCapacity': _ratedCapacityController.text,
        'RatedVoltage': _ratedVoltageController.text,
        'ContinuousOperationVoltage': _continuousOperationVoltageController.text,
        'RatedPowerFactor': _ratedPowerFactorController.text,
        'Frequency': _frequencyController.text,
        'InPlantRate': _inPlantRateController.text,
        'ContinuousOperationFrequencyLower': _continuousOperationFrequencyLowerController.text,
        'ContinuousOperationFrequencyUpper': _continuousOperationFrequencyUpperController.text,
  'BlackStart': _blackStartController.text,
  'ThermalType': _thermalTypeController.text,
  'ContinuousOperationTimeLimited': _continuousOperationTimeLimited,
  'FcbOperation': _fcbOperation,
  'OverPowerOperation': _overPowerOperation,
  'PeakModeOperation': _peakModeOperation,
  'Dss': _dss,
        // Contact
        'Address': _addressController.text,
        'PayeePhonePart1': _phonePart1Controller.text,
        'PayeePhonePart2': _phonePart2Controller.text,
        'PayeePhonePart3': _phonePart3Controller.text,
      };

      // Simulate save operation (replace with API call)
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Resource saved successfully! Payload: ${payload.toString()}'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
          ),
        );

        // Refresh the dashboard data
       // context.read<DashboardBloc>().add(LoadDashboardData());
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save resource: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
}
