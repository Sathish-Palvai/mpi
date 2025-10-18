import 'package:flutter/material.dart';

/// Model representing a single message
class ResponseMessage {
  final String type; // 'info', 'warn', 'error'
  final String message;

  const ResponseMessage({
    required this.type,
    required this.message,
  });
}

/// Model representing processing statistics
class ProcessingStatistics {
  final String received;
  final String valid;
  final String invalid;
  final String successful;
  final String unsuccessful;
  final String processingTime;

  const ProcessingStatistics({
    required this.received,
    required this.valid,
    required this.invalid,
    required this.successful,
    required this.unsuccessful,
    required this.processingTime,
  });

  /// Create from API response
  factory ProcessingStatistics.fromJson(Map<String, dynamic> json) {
    return ProcessingStatistics(
      received: json['@Received']?.toString() ?? '-',
      valid: json['@Valid']?.toString() ?? '-',
      invalid: json['@Invalid']?.toString() ?? 
               json['@Unsuccessful']?.toString() ?? '-',
      successful: json['@Successful']?.toString() ?? '-',
      unsuccessful: json['@Unsuccessful']?.toString() ?? '-',
      processingTime: json['@ProcessingTimeMs']?.toString() ?? 
                      json['@ProcessingTime']?.toString() ?? '-',
    );
  }
}

/// Reusable card component for displaying API response messages and statistics
/// 
/// This component displays:
/// - A collapsible list of messages (Information, Warning, Error)
/// - Processing statistics in a popup menu
/// - Proper theming and color coding
/// 
/// Usage:
/// ```dart
/// ResponseMessagesCard(
///   response: apiResponse,
///   title: 'Messages',
///   initiallyCollapsed: false,
/// )
/// ```
class ResponseMessagesCard extends StatefulWidget {
  /// The API response containing messages and statistics
  final Map<String, dynamic>? response;

  /// Title to display in the header
  final String title;

  /// Whether to show the card (if false, returns empty widget)
  final bool visible;

  /// Whether messages are initially collapsed
  final bool initiallyCollapsed;

  /// Callback when collapse state changes
  final ValueChanged<bool>? onCollapsedChanged;

  const ResponseMessagesCard({
    super.key,
    required this.response,
    this.title = 'Messages',
    this.visible = true,
    this.initiallyCollapsed = false,
    this.onCollapsedChanged,
  });

  @override
  State<ResponseMessagesCard> createState() => _ResponseMessagesCardState();

  /// Extract messages from API response
  static List<ResponseMessage> extractMessages(Map<String, dynamic>? response) {
    if (response == null) return [];

    final registrationData = response['RegistrationData'];
    final registrationSubmit = registrationData?['RegistrationSubmit'];
    final messages = registrationSubmit?['Messages'];

    final List<ResponseMessage> result = [];

    void addMsg(String rawType, dynamic entry) {
      if (entry == null) return;
      String? text;
      if (entry is Map) {
        text = entry['#text']?.toString() ?? entry['\$t']?.toString();
      } else {
        text = entry.toString();
      }
      if (text == null || text.trim().isEmpty) return;

      final shortType = rawType == 'Information'
          ? 'info'
          : rawType == 'Warning'
              ? 'warn'
              : rawType == 'Error'
                  ? 'error'
                  : rawType.toLowerCase();

      result.add(ResponseMessage(type: shortType, message: text));
    }

    if (messages != null) {
      for (final key in ['Information', 'Warning', 'Error']) {
        final block = messages[key];
        if (block is List) {
          for (final item in block) {
            addMsg(key, item);
          }
        } else {
          addMsg(key, block);
        }
      }
    }

    return result;
  }

  /// Extract processing statistics from API response
  static ProcessingStatistics? extractStatistics(Map<String, dynamic>? response) {
    if (response == null) return null;

    final registrationData = response['RegistrationData'];
    final processingStats = registrationData?['ProcessingStatistics'] ??
        registrationData?['RegistrationSubmit']?['ProcessingStatistics'];

    if (processingStats == null) return null;

    return ProcessingStatistics.fromJson(processingStats);
  }
}

class _ResponseMessagesCardState extends State<ResponseMessagesCard> {
  late bool _collapsed;

  @override
  void initState() {
    super.initState();
    _collapsed = widget.initiallyCollapsed;
  }

  void _toggleCollapsed() {
    setState(() {
      _collapsed = !_collapsed;
    });
    widget.onCollapsedChanged?.call(_collapsed);
  }

  Color _colorForType(String type, ThemeData theme) {
    switch (type) {
      case 'error':
        return theme.colorScheme.error;
      case 'warn':
        return Colors.orange.shade700;
      case 'info':
      default:
        return theme.colorScheme.primary;
    }
  }

  Widget _buildStatRow(String label, String value, Color valueColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13)),
          const SizedBox(width: 16),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsPopup(ProcessingStatistics stats, ThemeData theme) {
    return PopupMenuButton<void>(
      tooltip: 'Show statistics',
      icon: const Icon(Icons.bar_chart, color: Colors.white),
      itemBuilder: (context) {
        return [
          PopupMenuItem<void>(
            enabled: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Processing Statistics',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Divider(),
                _buildStatRow('Received', stats.received, theme.colorScheme.onSurface),
                _buildStatRow('Valid', stats.valid, theme.colorScheme.primary),
                _buildStatRow('Invalid', stats.invalid, theme.colorScheme.error),
                _buildStatRow('Successful', stats.successful, Colors.green.shade700),
                _buildStatRow('Unsuccessful', stats.unsuccessful, theme.colorScheme.error),
                _buildStatRow('Processing Time', '${stats.processingTime}ms', theme.colorScheme.onSurface),
              ],
            ),
          ),
        ];
      },
    );
  }

  Widget _buildMessagesTable(List<ResponseMessage> messages, ThemeData theme) {
    if (messages.isEmpty) {
      return Text(
        'No messages',
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurface.withOpacity(.6),
        ),
      );
    }

    return Table(
      columnWidths: const {
        0: IntrinsicColumnWidth(),
        1: FlexColumnWidth(),
      },
      border: TableBorder.symmetric(
        inside: BorderSide(color: theme.dividerColor.withOpacity(.1)),
      ),
      defaultVerticalAlignment: TableCellVerticalAlignment.top,
      children: [
        // Header row
        TableRow(
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceVariant.withOpacity(.4),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Type',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Message',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        // Message rows
        ...messages.map((msg) => TableRow(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    msg.type,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: _colorForType(msg.type, theme),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SelectableText(
                    msg.message,
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ],
            )),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.visible || widget.response == null) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final messages = ResponseMessagesCard.extractMessages(widget.response);
    final statistics = ResponseMessagesCard.extractStatistics(widget.response);

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
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
            decoration: BoxDecoration(
              color: theme.brightness == Brightness.dark 
                  ? const Color(0xFF2A2A2A)  // Lighter shade of black for dark mode
                  : const Color(0xFF283593), // Deep blue for light mode
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(11),
                topRight: Radius.circular(11),
              ),
            ),
            child: Row(
              children: [
                Text(
                  widget.title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                if (messages.isNotEmpty)
                  Text(
                    '(${messages.length})',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                const Spacer(),
                if (statistics != null)
                  _buildStatisticsPopup(statistics, theme),
                IconButton(
                  tooltip: _collapsed ? 'Show messages' : 'Hide messages',
                  onPressed: _toggleCollapsed,
                  icon: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    transitionBuilder: (child, anim) => RotationTransition(
                      turns: Tween<double>(begin: .75, end: 1).animate(anim),
                      child: FadeTransition(opacity: anim, child: child),
                    ),
                    child: Icon(
                      _collapsed ? Icons.expand_more : Icons.expand_less,
                      key: ValueKey<bool>(_collapsed),
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Content
          if (!_collapsed)
            Padding(
              padding: const EdgeInsets.all(16),
              child: _buildMessagesTable(messages, theme),
            ),
        ],
      ),
    );
  }
}
