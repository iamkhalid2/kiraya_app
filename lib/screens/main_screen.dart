import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:provider/provider.dart';
import '../providers/navigation_provider.dart';
import 'dashboard/dashboard_screen.dart';
import 'rooms/room_grid_screen.dart';
import 'tenant_list_screen.dart';
import 'settings/settings_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final List<Widget> _screens = [
    const DashboardScreen(),
    const RoomGridScreen(),
    const TenantListScreen(),
    const SettingsScreen(),
  ];

  final List<String> _titles = [
    'Dashboard',
    'Rooms',
    'Tenants',
    'Settings',
  ];

  @override
  void initState() {
    super.initState();
    // No initialization needed - using streams
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NavigationProvider>(
      builder: (context, navigationProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(_titles[navigationProvider.currentIndex]),
          ),
          body: IndexedStack(
            index: navigationProvider.currentIndex,
            children: _screens,
          ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  blurRadius: 20,
                  color: Colors.black.withOpacity(0.1),
                ),
              ],
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8),
                child: GNav(
                  rippleColor: Colors.grey[300]!,
                  hoverColor: Colors.grey[100]!,
                  gap: 8,
                  activeColor: Colors.white,
                  iconSize: 24,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  duration: const Duration(milliseconds: 400),
                  tabBackgroundColor: Theme.of(context).primaryColor,
                  color: Colors.grey[600],
                  tabs: const [
                    GButton(
                      icon: Icons.dashboard,
                      text: 'Dashboard',
                    ),
                    GButton(
                      icon: Icons.meeting_room,
                      text: 'Rooms',
                    ),
                    GButton(
                      icon: Icons.people,
                      text: 'Tenants',
                    ),
                    GButton(
                      icon: Icons.settings,
                      text: 'Settings',
                    ),
                  ],
                  selectedIndex: navigationProvider.currentIndex,
                  onTabChange: (index) {
                    navigationProvider.setIndex(index);
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
