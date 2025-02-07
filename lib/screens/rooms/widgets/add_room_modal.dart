import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../providers/room_provider.dart';
import '../../../models/room.dart';

class AddRoomModal extends StatefulWidget {
  const AddRoomModal({super.key});

  @override
  State<AddRoomModal> createState() => _AddRoomModalState();
}

class _AddRoomModalState extends State<AddRoomModal> {
  final _formKey = GlobalKey<FormState>();
  final _roomNumberController = TextEditingController();
  int _occupantLimit = 1;

  @override
  void dispose() {
    _roomNumberController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        final roomProvider = Provider.of<RoomProvider>(context, listen: false);
        final room = Room(
          number: _roomNumberController.text,
          occupantLimit: _occupantLimit,
        );

        await roomProvider.addRoom(room);
        if (mounted) {
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error adding room: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get the keyboard height to adjust padding
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: bottomInset + 16,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Add New Room',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _roomNumberController,
              decoration: const InputDecoration(
                labelText: 'Room Number',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.next,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9A-Za-z-]')),
              ],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter room number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<int>(
              value: _occupantLimit,
              decoration: const InputDecoration(
                labelText: 'Room Type',
                border: OutlineInputBorder(),
              ),
              items: [
                DropdownMenuItem(
                  value: 1,
                  child: Row(
                    children: [
                      const Icon(Icons.person),
                      const SizedBox(width: 8),
                      const Text('Single Room'),
                    ],
                  ),
                ),
                DropdownMenuItem(
                  value: 2,
                  child: Row(
                    children: [
                      const Icon(Icons.people),
                      const SizedBox(width: 8),
                      const Text('Double Sharing'),
                    ],
                  ),
                ),
                DropdownMenuItem(
                  value: 3,
                  child: Row(
                    children: [
                      const Icon(Icons.people_outline),
                      const SizedBox(width: 8),
                      const Text('Triple Sharing'),
                    ],
                  ),
                ),
                DropdownMenuItem(
                  value: 4,
                  child: Row(
                    children: [
                      const Icon(Icons.groups),
                      const SizedBox(width: 8),
                      const Text('Four Sharing'),
                    ],
                  ),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _occupantLimit = value;
                  });
                }
              },
            ),
            const SizedBox(height: 24),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(_occupantLimit, (index) {
                  final sectionId = String.fromCharCode(65 + index); // A, B, C, D
                  return CircleAvatar(
                    backgroundColor: Theme.of(context).primaryColor,
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
              onPressed: _submitForm,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('Add Room'),
            ),
          ],
        ),
      ),
    );
  }
}
