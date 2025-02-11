import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/room_provider.dart';
import 'widgets/room_tile.dart';
import 'widgets/add_room_modal.dart';

class RoomGridScreen extends StatelessWidget {
  const RoomGridScreen({super.key});

  void _showAddRoomModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => const AddRoomModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(120),
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          color: Theme.of(context).primaryColor.withOpacity(0.1),
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
                        'Room Management',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Consumer<RoomProvider>(
                        builder: (context, roomProvider, _) {
                          final totalRooms = roomProvider.rooms.length;
                          return Text(
                            '$totalRooms Active Room${totalRooms != 1 ? 's' : ''}',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Theme.of(context).primaryColor.withOpacity(0.8),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  IconButton.filled(
                    onPressed: () => _showAddRoomModal(context),
                    icon: const Icon(Icons.add),
                    tooltip: 'Add Room',
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
      body: Consumer<RoomProvider>(
        builder: (context, roomProvider, child) {
          if (!roomProvider.isInitialized) {
            return const Center(child: CircularProgressIndicator());
          }

          if (roomProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final rooms = roomProvider.rooms;

          if (rooms.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.home_work_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No rooms added yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap + to add a new room',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: rooms.length,
            itemBuilder: (context, index) {
              final room = rooms[index];
              return RoomTile(room: room);
            },
          );
        },
      ),
    );
  }
}
