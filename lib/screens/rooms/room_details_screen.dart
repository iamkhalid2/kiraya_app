import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/room.dart';
import '../../providers/room_provider.dart';
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

  Future<void> _showDeleteConfirmation(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Room'),
        content: const Text(
          'Are you sure you want to delete this room? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () async {
              try {
                Navigator.of(ctx).pop();
                await Provider.of<RoomProvider>(context, listen: false)
                    .deleteRoom(room.id!);
                if (context.mounted) {
                  Navigator.of(context).pop(); // Pop room details screen
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('DELETE'),
          ),
        ],
      ),
    );
  }

  Future<void> _showConfigurationDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      builder: (ctx) => Consumer<RoomProvider>(
        builder: (context, roomProvider, _) {
          final updatedRoom = roomProvider.rooms.firstWhere(
            (r) => r.id == room.id,
            orElse: () => room,
          );
          final theme = Theme.of(context);
          
          return AlertDialog(
            title: Text('Configure Room ${updatedRoom.number}'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Current Configuration: ${updatedRoom.type.name} (${updatedRoom.sections.length} sections)',
                  style: theme.textTheme.bodyLarge,
                ),
                const SizedBox(height: 16),
                Text(
                  'Actions:',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                if (updatedRoom.type != RoomType.quad && updatedRoom.sections.every((s) => !s.isOccupied)) ...[
                  ListTile(
                    leading: const Icon(Icons.add_circle_outline),
                    title: const Text('Add Section'),
                    subtitle: Text('Convert to ${RoomType.values[updatedRoom.type.capacity].name}'),
                    onTap: () async {
                      try {
                        final provider = Provider.of<RoomProvider>(ctx, listen: false);
                        final newCapacity = updatedRoom.type.capacity + 1;
                        final newRoom = Room(
                          id: updatedRoom.id,
                          number: updatedRoom.number,
                          occupantLimit: newCapacity,
                        );
                        await provider.updateRoom(newRoom);
                        if (ctx.mounted) {
                          Navigator.of(ctx).pop();
                          ScaffoldMessenger.of(ctx).showSnackBar(
                            const SnackBar(
                              content: Text('Room configuration updated successfully'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      } catch (e) {
                        if (ctx.mounted) {
                          ScaffoldMessenger.of(ctx).showSnackBar(
                            SnackBar(
                              content: Text('Error: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                  ),
                ],
                if (updatedRoom.type != RoomType.single) ...[
                  ListTile(
                    leading: const Icon(Icons.remove_circle_outline),
                    title: const Text('Remove Section'),
                    subtitle: Text('Convert to ${RoomType.values[updatedRoom.type.capacity - 2].name}'),
                    enabled: updatedRoom.sections.last.isOccupied == false,
                    onTap: updatedRoom.sections.last.isOccupied ? null : () async {
                      try {
                        final provider = Provider.of<RoomProvider>(ctx, listen: false);
                        final newCapacity = updatedRoom.type.capacity - 1;
                        final newRoom = Room(
                          id: updatedRoom.id,
                          number: updatedRoom.number,
                          occupantLimit: newCapacity,
                        );
                        await provider.updateRoom(newRoom);
                        if (ctx.mounted) {
                          Navigator.of(ctx).pop();
                          ScaffoldMessenger.of(ctx).showSnackBar(
                            const SnackBar(
                              content: Text('Room configuration updated successfully'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      } catch (e) {
                        if (ctx.mounted) {
                          ScaffoldMessenger.of(ctx).showSnackBar(
                            SnackBar(
                              content: Text('Error: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                  ),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('CLOSE'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RoomProvider>(
      builder: (context, roomProvider, _) {
        final updatedRoom = roomProvider.rooms.firstWhere(
          (r) => r.id == room.id,
          orElse: () => room,
        );
        final theme = Theme.of(context);

        return Scaffold(
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(120),
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Room ${updatedRoom.number}',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${updatedRoom.type.name} - ${updatedRoom.sections.length} Sections',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.primary.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.settings),
                            onPressed: () => _showConfigurationDialog(context),
                            tooltip: 'Configure Room',
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: updatedRoom.isFull 
                                  ? Colors.orange.withOpacity(0.1) 
                                  : Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  updatedRoom.isFull ? Icons.person_off : Icons.person_add,
                                  size: 16,
                                  color: updatedRoom.isFull ? Colors.orange : Colors.green,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${updatedRoom.occupiedCount}/${updatedRoom.occupantLimit}',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: updatedRoom.isFull ? Colors.orange : Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (updatedRoom.isEmpty) ...[
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => _showDeleteConfirmation(context),
                              tooltip: 'Delete Room',
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                            itemCount: updatedRoom.sections.length,
                            itemBuilder: (context, index) {
                              final section = updatedRoom.sections[index];
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
                                                        color: theme.colorScheme.primary,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                IconButton.filled(
                                                  onPressed: () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) => TenantDetailsScreen(tenantId: tenant.id!),
                                                      ),
                                                    );
                                                  },
                                                  icon: const Icon(Icons.visibility),
                                                  tooltip: 'View Details',
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
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            IconButton.filled(
                                              onPressed: () => _navigateToTenantForm(context, updatedRoom.id!, section.id),
                                              icon: const Icon(Icons.person_add),
                                              tooltip: 'Add Tenant',
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
}