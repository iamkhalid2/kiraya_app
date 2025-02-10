import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/room.dart';
import '../../providers/room_provider.dart';
import '../../providers/tenant_provider.dart';

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

  Future<void> _showDeleteConfirmation(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Room'),
        content: Text('Are you sure you want to delete Room ${room.number}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    try {
      await Provider.of<RoomProvider>(context, listen: false)
          .deleteRoom(room.id!);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Room deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Room ${room.number}'),
        actions: [
          if (room.isEmpty)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _showDeleteConfirmation(context),
              tooltip: 'Delete Room',
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              color: theme.primaryColor.withOpacity(0.1),
              child: Column(
                children: [
                  Icon(
                    room.type.name == 'single'
                        ? Icons.person
                        : room.type.name == 'double'
                            ? Icons.people
                            : room.type.name == 'triple'
                                ? Icons.people_outline
                                : Icons.groups,
                    size: 48,
                    color: theme.primaryColor,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${room.type.name.toUpperCase()} ROOM',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${room.occupiedCount}/${room.occupantLimit} Occupied',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.primaryColor.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Room Sections',
                style: theme.textTheme.titleLarge,
              ),
            ),
            Consumer<TenantProvider>(
              builder: (context, tenantProvider, _) {
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
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
                                Text('Section ${section.id}'),
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
                                      Text(
                                        'Tenant Details',
                                        style: theme.textTheme.titleMedium,
                                      ),
                                      Chip(
                                        label: Text(tenant.paymentStatus),
                                        backgroundColor: _getStatusColor(tenant.paymentStatus)
                                            .withOpacity(0.1),
                                        labelStyle: TextStyle(
                                          color: _getStatusColor(tenant.paymentStatus),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  _DetailRow(
                                    label: 'Name',
                                    value: tenant.name,
                                  ),
                                  _DetailRow(
                                    label: 'Phone',
                                    value: tenant.phoneNumber,
                                  ),
                                  _DetailRow(
                                    label: 'Rent',
                                    value: '₹${tenant.rentAmount}',
                                  ),
                                  _DetailRow(
                                    label: 'Next Due',
                                    value: tenant.nextDueDate.toString().split(' ')[0],
                                    isOverdue: tenant.nextDueDate.isBefore(DateTime.now()),
                                  ),
                                ],
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
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isOverdue;

  const _DetailRow({
    required this.label,
    required this.value,
    this.isOverdue = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.black54,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: isOverdue ? Colors.red : null,
            ),
          ),
        ],
      ),
    );
  }
}