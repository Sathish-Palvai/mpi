import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/user_type.dart';

class ParticipantTab extends StatelessWidget {
  final List<Map<String, dynamic>> participants;
  final UserType? userType;

  const ParticipantTab({
    super.key, 
    required this.participants,
    this.userType,
  });

  @override
  Widget build(BuildContext context) {
    // For BSP users, show the first participant as readonly form fields
    if (userType == UserType.BSP && participants.isNotEmpty) {
      final participant = participants.first;
      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 0.5,
          color: Theme.of(context).cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: Theme.of(context).dividerColor.withOpacity(0.5),
              width: 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Participant Information',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 4),
                          
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),
                // Readonly Fields
                _buildReadOnlyField(
                  context,
                  label: 'Participant Name',
                  value: participant['ParticipantName']?.toString() ?? 'N/A',
                  icon: Icons.badge,
                ),
                const SizedBox(height: 16),
                _buildReadOnlyField(
                  context,
                  label: 'Participant Type',
                  value: participant['ParticipantType']?.toString() ?? 'N/A',
                  icon: Icons.category,
                ),
                const SizedBox(height: 16),
                _buildReadOnlyField(
                  context,
                  label: 'Company Name',
                  value: participant['Company']?.toString() ?? 'N/A',
                  icon: Icons.business,
                ),
                const SizedBox(height: 16),
                if (participant['Area'] != null && participant['Area'].toString().trim().isNotEmpty)
                  _buildReadOnlyField(
                    context,
                    label: 'Area',
                    value: participant['Area'].toString(),
                    icon: Icons.location_on,
                  ),
                if (participant['StartDate'] != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: _buildReadOnlyField(
                      context,
                      label: 'Start Date',
                      value: participant['StartDate'].toString(),
                      icon: Icons.calendar_today,
                    ),
                  ),
                if (participant['EndDate'] != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: _buildReadOnlyField(
                      context,
                      label: 'End Date',
                      value: participant['EndDate'].toString(),
                      icon: Icons.event,
                    ),
                  ),
                const SizedBox(height: 24),
                // Action Button
                Align(
                  alignment: Alignment.centerRight,
                  child: SizedBox(
                    width: 220,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        context.go('/participant-config', extra: participant);
                      },
                      icon: const Icon(Icons.edit),
                      label: const Text('View/Edit Details'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    
    // Original list view for non-BSP users or when no participants
    if (participants.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No participants found',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Try adjusting your search criteria',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: participants.length,
      itemBuilder: (context, index) {
        final participant = participants[index];
        return Card(
          elevation: 0,
          color: Theme.of(context).cardColor,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: Theme.of(context).dividerColor.withOpacity(0.5),
              width: 1,
            ),
          ),
          child: InkWell(
            onDoubleTap: () {
              context.go('/participant-config', extra: participant);
            },
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: CircleAvatar(
                backgroundColor:
                    _getParticipantTypeColor(participant['ParticipantType']),
                child: Text(
                  participant['ParticipantName']
                          ?.toString()
                          .substring(0, 1)
                          .toUpperCase() ??
                      'P',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: Text(
                participant['ParticipantName'] ?? 'Unknown',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.business, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(participant['Company'] ?? 'N/A'),
                    ],
                  ),
                  if (participant['Area'] != null &&
                      participant['Area'].toString().trim().isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.location_on,
                            size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(participant['Area'].toString().trim()),
                      ],
                    ),
                  ],
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Participant Type Badge
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color:
                          _getParticipantTypeColor(participant['ParticipantType'])
                              .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color:
                            _getParticipantTypeColor(participant['ParticipantType'])
                                .withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      participant['ParticipantType'] ?? 'Unknown',
                      style: TextStyle(
                        color: _getParticipantTypeColor(
                            participant['ParticipantType']),
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  // Add User Button (only for MO users)
                  if (userType == UserType.MO) ...[
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.person_add, color: Colors.orange),
                      tooltip: 'Add User to ${participant['ParticipantName']}',
                      onPressed: () {
                        // Navigate to user creation screen with participant context
                        context.push('/user-create', extra: {
                          'participantName': participant['ParticipantName'],
                          'participantType': participant['ParticipantType'],
                        });
                      },
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Color _getParticipantTypeColor(String? type) {
    switch (type) {
      case 'BSP':
        return Colors.blue;
      case 'TSO':
        return Colors.green;
      case 'MO':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Widget _buildReadOnlyField(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Theme.of(context).dividerColor.withOpacity(0.5),
            ),
          ),
          child: Row(
            children: [
              Icon(icon, size: 20, color: Colors.grey[600]),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  value,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
