import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/room.dart';
import '../../providers/tenant_provider.dart';
import '../tenant_details_screen.dart';
import '../tenant_form/tenant_form_screen.dart';

class RoomDetailsScreen extends StatelessWidget {
  final Room room;

  const RoomDetailsScreen({
    super.key,
    required this.room,
  });

  Color _getStatusColor(String status) {
    return switch (status.toLowerCase()) {
      'paid' => Colors.green,
      'pending' => Colors.red,
      'partial' => Colors.orange,
      _ => Colors.grey,
    };
  }

  void _navigateToTenantForm(BuildContext context, String roomId, String sectionId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TenantFormScreen(
          preselectedRoomId: roomId,
          preselectedSection: sectionId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Room ${room.number}'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: theme.primaryColor.withOpacity(0.1),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Room Type',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.primaryColor.withOpacity(0.8),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            room.type.name.toUpperCase(),
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: room.isFull 
                              ? Colors.orange.withOpacity(0.1) 
                              : Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              room.isFull ? Icons.person_off : Icons.person_add,
                              size: 16,
                              color: room.isFull ? Colors.orange : Colors.green,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${room.occupiedCount}/${room.occupantLimit}',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: room.isFull ? Colors.orange : Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Room Sections',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Consumer<TenantProvider>(
                    builder: (context, tenantProvider, _) {
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: room.sections.length,
                        itemBuilder: (context, index) {
                          final section = room.sections[index];
                          final tenant = section.tenantId != null
                              ? tenantProvider.tenants.firstWhere(
                                  (t) => t.id == section.tenantId,
                                  orElse: () => throw Exception('Tenant not found'),
                                )
                              : null;

                          return Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            child: Column(
                              children: [
                                ListTile(
                                  title: Row(
                                    children: [
                                      Text(
                                        'Section ${section.id}',
                                        style: theme.textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: section.isOccupied
                                              ? Colors.orange.withOpacity(0.1)
                                              : Colors.green.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          section.isOccupied ? 'Occupied' : 'Vacant',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: section.isOccupied
                                                ? Colors.orange
                                                : Colors.green,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (tenant != null) ...[
                                  const Divider(),
                                  Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  tenant.name,
                                                  style: theme.textTheme.titleMedium?.copyWith(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  '₹${tenant.rentAmount}',
                                                  style: theme.textTheme.titleSmall?.copyWith(
                                                    color: theme.primaryColor,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            ElevatedButton.icon(
                                              onPressed: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) => TenantDetailsScreen(tenantId: tenant.id!),
                                                  ),
                                                );
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: theme.primaryColor,
                                                foregroundColor: Colors.white,
                                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                              ),
                                              icon: const Icon(Icons.visibility, size: 18),
                                              label: const Text('View Details'),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: _getStatusColor(tenant.paymentStatus).withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(16),
                                          ),
                                          child: Text(
                                            tenant.paymentStatus,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: _getStatusColor(tenant.paymentStatus),
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ] else ...[
                                  Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton.icon(
                                        onPressed: () => _navigateToTenantForm(context, room.id!, section.id),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(vertical: 12),
                                        ),
                                        icon: const Icon(Icons.person_add),
                                        label: const Text('Add Tenant'),
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}