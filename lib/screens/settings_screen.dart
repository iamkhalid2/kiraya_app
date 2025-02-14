import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/user_settings_provider.dart';
import '../providers/room_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _roomLimitController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _initializeSettings();
  }

  @override
  void dispose() {
    _roomLimitController.dispose();
    super.dispose();
  }

  void _initializeSettings() {
    final settings = Provider.of<UserSettingsProvider>(context, listen: false).settings;
    _roomLimitController.text = settings.totalRooms.toString();
  }

  Future<void> _signOut() async {
    try {
      await Provider.of<AuthProvider>(context, listen: false).signOut();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error signing out: $e')),
        );
      }
    }
  }

  Future<void> _saveSettings() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final currentRoomCount = Provider.of<RoomProvider>(context, listen: false).rooms.length;
      final newLimit = int.parse(_roomLimitController.text);

      if (newLimit < currentRoomCount) {
        throw Exception(
          'Cannot reduce room limit below current room count ($currentRoomCount). '
          'Please delete ${currentRoomCount - newLimit} room(s) first.',
        );
      }

      final settings = Provider.of<UserSettingsProvider>(context, listen: false);
      await settings.updateSettings(
        settings.settings.copyWith(totalRooms: newLimit),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Settings saved successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
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
                        'Settings',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Property Management',
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
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Room Management',
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    Consumer<RoomProvider>(
                      builder: (context, roomProvider, _) {
                        final currentRoomCount = roomProvider.rooms.length;
                        return TextFormField(
                          controller: _roomLimitController,
                          decoration: InputDecoration(
                            labelText: 'Total Rooms Limit',
                            border: const OutlineInputBorder(),
                            helperText: 'Current room usage: $currentRoomCount room(s)',
                            helperMaxLines: 2,
                            suffixIcon: Tooltip(
                              message: 'Room limit cannot be less than current room count',
                              child: const Icon(Icons.info_outline),
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          enabled: !_isSubmitting,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter room limit';
                            }
                            final limit = int.tryParse(value);
                            if (limit == null || limit < 1) {
                              return 'Room limit must be at least 1';
                            }
                            if (limit > 100) {
                              return 'Room limit cannot exceed 100';
                            }
                            if (limit < currentRoomCount) {
                              return 'Cannot set limit below current room count ($currentRoomCount).\nDelete some rooms first.';
                            }
                            return null;
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _saveSettings,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(50),
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: theme.colorScheme.onPrimary,
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Save Settings'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
