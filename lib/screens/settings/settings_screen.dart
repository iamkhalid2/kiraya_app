import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/navigation_provider.dart';
import '../../providers/user_settings_provider.dart';
import '../../providers/room_provider.dart';
import '../../utils/error_handler.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _roomsController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final settings = context.read<UserSettingsProvider>().settings;
    _roomsController.text = settings.totalRooms.toString();
  }

  @override
  void dispose() {
    _roomsController.dispose();
    super.dispose();
  }

  Future<void> _updateTotalRooms() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSaving = true);

    try {
      final totalRooms = int.parse(_roomsController.text);
      final currentRoomCount = context.read<RoomProvider>().rooms.length;

      await context.read<UserSettingsProvider>()
          .updateTotalRooms(totalRooms, currentRoomCount);
      
      if (mounted) {
        ErrorHandler.showSuccess(context, 'Room limit updated successfully');
      }
    } catch (e) {
      if (mounted) {
        ErrorHandler.showError(context, e.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _signOut() async {
    final authProvider = context.read<AuthProvider>();
    final navigationProvider = context.read<NavigationProvider>();
    
    try {
      // Reset navigation state before signing out
      navigationProvider.reset();
      await authProvider.signOut();
    } catch (e) {
      if (mounted) {
        ErrorHandler.showError(context, e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(120),
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 48, 16, 0),
          color: Theme.of(context).appBarTheme.backgroundColor,
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
                        'Settings',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Configure Your Property',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.primary.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.logout),
                    onPressed: _signOut,
                    tooltip: 'Sign Out',
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Form(
              key: _formKey,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Property Settings',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Consumer<RoomProvider>(
                        builder: (context, roomProvider, _) {
                          final currentRoomCount = roomProvider.rooms.length;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextFormField(
                                controller: _roomsController,
                                enabled: !_isSaving,
                                decoration: InputDecoration(
                                  labelText: 'Total Rooms',
                                  hintText: 'Enter total number of rooms',
                                  border: const OutlineInputBorder(),
                                  helperText: 'Current room count: $currentRoomCount',
                                ),
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter total rooms';
                                  }
                                  final rooms = int.tryParse(value);
                                  if (rooms == null) {
                                    return 'Please enter a valid number';
                                  }
                                  if (rooms <= 0) {
                                    return 'Total rooms must be greater than 0';
                                  }
                                  if (rooms < currentRoomCount) {
                                    return 'Cannot set limit below current room count ($currentRoomCount)';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isSaving ? null : _updateTotalRooms,
                          child: _isSaving
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Text('Save'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
