import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/room_provider.dart';
import '../../../providers/user_settings_provider.dart';
import '../../../models/room.dart';
import '../../../utils/error_handler.dart';
import '../../../utils/validators.dart';

class AddRoomModal extends StatefulWidget {
  const AddRoomModal({super.key});

  @override
  State<AddRoomModal> createState() => _AddRoomModalState();
}

class _AddRoomModalState extends State<AddRoomModal> {
  final _formKey = GlobalKey<FormState>();
  final _roomNumberController = TextEditingController();
  RoomType _selectedType = RoomType.single;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _roomNumberController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final roomProvider = Provider.of<RoomProvider>(context, listen: false);
      final settingsProvider = Provider.of<UserSettingsProvider>(context, listen: false);
      
      // Check room limit
      final currentRooms = roomProvider.rooms.length;
      final totalRoomsLimit = settingsProvider.settings.totalRooms;
      
      if (currentRooms >= totalRoomsLimit) {
        throw Exception('Room limit ($totalRoomsLimit) reached');
      }

      final room = Room(
        number: _roomNumberController.text,
        occupantLimit: _selectedType.capacity,
      );

      await roomProvider.addRoom(room);
      
      if (mounted) {
        ErrorHandler.showSuccess(context, 'Room added successfully');
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ErrorHandler.showError(context, e.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final totalRooms = context.select<UserSettingsProvider, int>(
      (provider) => provider.settings.totalRooms
    );
    final currentRooms = context.watch<RoomProvider>().rooms.length;
    final roomsAvailable = totalRooms - currentRooms;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        16,
        16,
        16 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Add New Room',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Available: $roomsAvailable',
                  style: TextStyle(
                    color: roomsAvailable > 0 ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _roomNumberController,
              decoration: const InputDecoration(
                labelText: 'Room Number',
                border: OutlineInputBorder(),
                hintText: 'Enter room number',
              ),
              enabled: !_isSubmitting && roomsAvailable > 0,
              textInputAction: TextInputAction.next,
              validator: (value) => DataValidator.validateRoomNumber(
                value,
                Provider.of<RoomProvider>(context, listen: false).rooms,
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<RoomType>(
              value: _selectedType,
              decoration: const InputDecoration(
                labelText: 'Room Type',
                border: OutlineInputBorder(),
              ),
              items: [
                DropdownMenuItem(
                  value: RoomType.single,
                  child: Row(
                    children: [
                      Icon(Icons.person, color: theme.primaryColor),
                      const SizedBox(width: 8),
                      const Text('Single Room'),
                    ],
                  ),
                ),
                DropdownMenuItem(
                  value: RoomType.double,
                  child: Row(
                    children: [
                      Icon(Icons.people, color: theme.primaryColor),
                      const SizedBox(width: 8),
                      const Text('Double Sharing'),
                    ],
                  ),
                ),
                DropdownMenuItem(
                  value: RoomType.triple,
                  child: Row(
                    children: [
                      Icon(Icons.people_outline, color: theme.primaryColor),
                      const SizedBox(width: 8),
                      const Text('Triple Sharing'),
                    ],
                  ),
                ),
                DropdownMenuItem(
                  value: RoomType.quad,
                  child: Row(
                    children: [
                      Icon(Icons.groups, color: theme.primaryColor),
                      const SizedBox(width: 8),
                      const Text('Four Sharing'),
                    ],
                  ),
                ),
              ],
              onChanged: _isSubmitting || roomsAvailable <= 0
                ? null 
                : (value) {
                    if (value != null) {
                      setState(() => _selectedType = value);
                    }
                  },
            ),
            const SizedBox(height: 24),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: theme.dividerColor),
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(_selectedType.capacity, (index) {
                  final sectionId = String.fromCharCode(65 + index); // A, B, C, D
                  return CircleAvatar(
                    backgroundColor: theme.primaryColor.withAlpha(_isSubmitting ? 128 : 255),
                    child: Text(
                      sectionId,
                      style: const TextStyle(color: Colors.white),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: roomsAvailable > 0 ? (_isSubmitting ? null : _submitForm) : null,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
              child: _isSubmitting 
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(roomsAvailable > 0 ? 'Add Room' : 'Room Limit Reached'),
            ),
          ],
        ),
      ),
    );
  }
}
