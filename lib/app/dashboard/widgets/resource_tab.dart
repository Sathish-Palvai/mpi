import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ResourceTab extends StatelessWidget {
  final List<Map<String, dynamic>> resources;

  const ResourceTab({super.key, required this.resources});

  @override
  Widget build(BuildContext context) {
    if (resources.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No resources found',
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
      itemCount: resources.length,
      itemBuilder: (context, index) {
        final resource = resources[index];
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
              _navigateToResourceUpdate(context, resource);
            },
            child: ExpansionTile(
              leading: CircleAvatar(
                backgroundColor: _getResourceTypeColor(resource['ResourceType']),
                child: Icon(
                  _getResourceTypeIcon(resource['ResourceType']),
                  color: Colors.white,
                  size: 20,
                ),
              ),
            title: Text(
              resource['ResourceName'] ?? 'Unknown Resource',
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
                    Text(resource['ParticipantName'] ?? 'N/A'),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(resource['Area'] ?? 'N/A'),
                  ],
                ),
              ],
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getResourceTypeColor(resource['ResourceType']).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _getResourceTypeColor(resource['ResourceType']).withOpacity(0.3),
                ),
              ),
              child: Text(
                _getResourceTypeShort(resource['ResourceType']),
                style: TextStyle(
                  color: _getResourceTypeColor(resource['ResourceType']),
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                ),
              ),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow('Full Type:', resource['ResourceType'] ?? 'N/A'),
                    _buildDetailRow('Short Name:', resource['ShortName'] ?? 'N/A'),
                    _buildDetailRow('Resource Status:', 
                      resource['ResourceSuspended'] == 'Y' ? 'Suspended' : 'Active'),
                    _buildDetailRow('DR Status:', 
                      resource['DrSuspended'] == 'Y' ? 'Suspended' : 'Active'),
                    const SizedBox(height: 16),
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: () => _navigateToResourceDetail(context, resource),
                        icon: const Icon(Icons.visibility),
                        label: const Text('View Full Details'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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
      },
    );
  }

  Future<void> _navigateToResourceDetail(BuildContext context, Map<String, dynamic> resource) async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Fetch full resource detail from backend
      final resourceName = resource['ResourceName'] ?? '';
      final resourceType = resource['ResourceType'] ?? 'PUMP';
      final response = await http.get(
        Uri.parse('http://localhost:3000/api/resources/detail/$resourceName?type=$resourceType'),
      );

      if (!context.mounted) return;
      
      // Close loading indicator
      Navigator.of(context).pop();

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          // Navigate to resource detail screen with full data
          context.push('/resource-detail', extra: data['data']);
        } else {
          _showErrorSnackBar(context, 'Failed to load resource details');
        }
      } else {
        _showErrorSnackBar(context, 'Server error: ${response.statusCode}');
      }
    } catch (e) {
      if (!context.mounted) return;
      Navigator.of(context).pop(); // Close loading indicator
      _showErrorSnackBar(context, 'Error: $e');
    }
  }

  Future<void> _navigateToResourceUpdate(BuildContext context, Map<String, dynamic> resource) async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Fetch full resource detail from backend
      final resourceName = resource['ResourceName'] ?? '';
      final resourceType = resource['ResourceType'] ?? 'PUMP';
      final response = await http.get(
        Uri.parse('http://localhost:3000/api/resources/detail/$resourceName?type=$resourceType'),
      );

      if (!context.mounted) return;
      
      // Close loading indicator
      Navigator.of(context).pop();

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          // Navigate to resource detail screen with full data for editing
          context.push('/resource-detail', extra: data['data']);
        } else {
          _showErrorSnackBar(context, 'Failed to load resource details');
        }
      } else {
        _showErrorSnackBar(context, 'Server error: ${response.statusCode}');
      }
    } catch (e) {
      if (!context.mounted) return;
      Navigator.of(context).pop(); // Close loading indicator
      _showErrorSnackBar(context, 'Error: $e');
    }
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w400),
            ),
          ),
        ],
      ),
    );
  }

  Color _getResourceTypeColor(String? type) {
    switch (type) {
      case 'VPP_DEM':
        return Colors.purple;
      case 'VPP_GEN':
        return Colors.green;
      case 'VPP_GEN_AND_DEM':
        return Colors.blue;
      case 'BATTERY':
        return Colors.orange;
      case 'HYDRO':
        return Colors.cyan;
      default:
        return Colors.grey;
    }
  }

  IconData _getResourceTypeIcon(String? type) {
    switch (type) {
      case 'VPP_DEM':
        return Icons.trending_down;
      case 'VPP_GEN':
        return Icons.trending_up;
      case 'VPP_GEN_AND_DEM':
        return Icons.swap_vert;
      case 'BATTERY':
        return Icons.battery_charging_full;
      case 'HYDRO':
        return Icons.water;
      default:
        return Icons.power;
    }
  }

  String _getResourceTypeShort(String? type) {
    switch (type) {
      case 'VPP_DEM':
        return 'VPP-D';
      case 'VPP_GEN':
        return 'VPP-G';
      case 'VPP_GEN_AND_DEM':
        return 'VPP-GD';
      case 'BATTERY':
        return 'BAT';
      case 'HYDRO':
        return 'HYDRO';
      default:
        if (type == null || type.isEmpty) return 'UNK';
        return type.length > 5 ? type.substring(0, 5) : type;
    }
  }
}
