import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/navigation_provider.dart';
import '../../providers/user_settings_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _roomsController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // Set initial value
    final settings = context.read<UserSettingsProvider>().settings;
    _roomsController.text = settings.totalRooms.toString();
  }

  @override
  void dispose() {
    _roomsController.dispose();
    super.dispose();
  }

  void _updateTotalRooms() {
    if (_formKey.currentState?.validate() ?? false) {
      final totalRooms = int.parse(_roomsController.text);
      context.read<UserSettingsProvider>().updateTotalRooms(totalRooms);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Total rooms updated')),
      );
    }
  }

  void _signOut() {
    final authProvider = context.read<AuthProvider>();
    final navigationProvider = context.read<NavigationProvider>();
    
    // Reset navigation state before signing out
    navigationProvider.reset();
    authProvider.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
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
                    TextFormField(
                      controller: _roomsController,
                      decoration: const InputDecoration(
                        labelText: 'Total Rooms',
                        hintText: 'Enter total number of rooms',
                        border: OutlineInputBorder(),
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
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _updateTotalRooms,
                        child: const Text('Save'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _signOut,
            icon: const Icon(Icons.logout),
            label: const Text('Sign Out'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ],
      ),
    );
  }
}
