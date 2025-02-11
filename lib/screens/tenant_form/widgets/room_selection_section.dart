import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/room_provider.dart';
import '../../../utils/error_handler.dart';
import '../../../widgets/empty_state_widget.dart';

class RoomSelectionSection extends StatelessWidget {
  final String? selectedRoomId;
  final String? selectedSection;
  final String? oldRoomId;
  final String? oldSection;
  final bool isSubmitting;
  final Function(String?) onRoomSelected;
  final Function(String?) onSectionSelected;

  const RoomSelectionSection({
    super.key,
    required this.selectedRoomId,
    required this.selectedSection,
    this.oldRoomId,
    this.oldSection,
    required this.isSubmitting,
    required this.onRoomSelected,
    required this.onSectionSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<RoomProvider>(
      builder: (context, roomProvider, _) {
        final rooms = roomProvider.rooms;

        if (rooms.isEmpty) {
          return EmptyStateWidget.noRooms(
            onAddRoom: () {
              ErrorHandler.showError(
                context,
                'Please add rooms before adding tenants',
              );
              Navigator.pop(context);
            },
          );
        }

        // Get available rooms (either empty or the current tenant's room)
        final availableRooms = rooms.where((room) {
          if (room.id == oldRoomId) return true;
          return !room.isFull;
        }).toList();

        // Check if the selected room is still available
        final selectedRoomStillAvailable = selectedRoomId != null && 
          availableRooms.any((room) => room.id == selectedRoomId);

        // Get available sections for the selected room
        List<String> availableSections = [];
        if (selectedRoomId != null && selectedRoomStillAvailable) {
          final selectedRoom = rooms.firstWhere(
            (room) => room.id == selectedRoomId,
          );
          availableSections = selectedRoom.getAvailableSections(
            currentTenantId: oldRoomId == selectedRoomId ? oldSection : null,
          );
        }

        // Check if the selected section is still available
        final selectedSectionStillAvailable = selectedSection != null &&
            availableSections.contains(selectedSection);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Room Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedRoomStillAvailable ? selectedRoomId : null,
              decoration: const InputDecoration(
                labelText: 'Room Number',
                border: OutlineInputBorder(),
              ),
              items: availableRooms.map((room) {
                return DropdownMenuItem(
                  value: room.id,
                  child: Text('Room ${room.number} (${room.type.name})'),
                );
              }).toList(),
              onChanged: isSubmitting ? null : (value) {
                onRoomSelected(value);
                onSectionSelected(null); // Reset section when room changes
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select a room';
                }
                return null;
              },
            ),
            if (selectedRoomId != null && selectedRoomStillAvailable) ...[
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedSectionStillAvailable ? selectedSection : null,
                decoration: const InputDecoration(
                  labelText: 'Room Section',
                  border: OutlineInputBorder(),
                ),
                items: availableSections.map((section) {
                  return DropdownMenuItem(
                    value: section,
                    child: Text('Section $section'),
                  );
                }).toList(),
                onChanged: isSubmitting ? null : onSectionSelected,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a section';
                  }
                  return null;
                },
              ),
            ],
          ],
        );
      },
    );
  }
}
