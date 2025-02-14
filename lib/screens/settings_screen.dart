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
                ],
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // User Profile Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Consumer<AuthProvider>(
                  builder: (context, authProvider, _) {
                    final user = authProvider.user;
                    return Column(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundImage: user?.photoURL != null 
                              ? NetworkImage(user!.photoURL!)
                              : null,
                          child: user?.photoURL == null 
                              ? const Icon(Icons.person, size: 40)
                              : null,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          user?.displayName ?? 'User',
                          style: theme.textTheme.titleLarge,
                        ),
                        if (user?.email != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            user!.email!,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ],
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Room Management Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.apartment_outlined, color: theme.colorScheme.primary),
                          const SizedBox(width: 8),
                          const Text(
                            'Room Management',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Consumer<RoomProvider>(
                        builder: (context, roomProvider, _) {
                          final currentRoomCount = roomProvider.rooms.length;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              TextFormField(
                                controller: _roomLimitController,
                                decoration: InputDecoration(
                                  labelText: 'Total Rooms Limit',
                                  border: const OutlineInputBorder(),
                                  helperText: 'Current room count: $currentRoomCount',
                                  helperMaxLines: 2,
                                  suffixIcon: const Tooltip(
                                    message: 'Room limit cannot be less than current room count',
                                    child: Icon(Icons.info_outline),
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
                                  if (limit < currentRoomCount) {
                                    return 'Cannot set limit below current room count ($currentRoomCount).\nDelete some rooms first.';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _isSubmitting ? null : _saveSettings,
                                child: _isSubmitting
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      )
                                    : const Text('Save Changes'),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Appearance Card 
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.palette_outlined, color: theme.colorScheme.primary),
                        const SizedBox(width: 8),
                        const Text(
                          'Appearance',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Consumer<UserSettingsProvider>(
                      builder: (context, settings, _) => SwitchListTile(
                        title: const Text('Dark Mode'),
                        subtitle: const Text('Enable darker theme for better visibility at night'),
                        value: settings.settings.enableDarkMode,
                        onChanged: (value) {
                          final newSettings = settings.settings.copyWith(enableDarkMode: value);
                          settings.updateSettings(newSettings);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Logout Button at the bottom
            ElevatedButton.icon(
              onPressed: _signOut,
                icon: const Icon(Icons.logout, color: Colors.white),
              label: const Text('Sign Out'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade400,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
