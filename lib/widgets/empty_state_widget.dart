import 'package:flutter/material.dart';

class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? actionButton;
  final Color? iconColor;
  final Color? textColor;

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionButton,
    this.iconColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: iconColor ?? Theme.of(context).colorScheme.secondary.withAlpha(128),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: textColor ?? Theme.of(context).colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 16,
                color: textColor?.withAlpha(179) ?? 
                      Theme.of(context).colorScheme.onSurface.withAlpha(179),
              ),
              textAlign: TextAlign.center,
            ),
            if (actionButton != null) ...[
              const SizedBox(height: 24),
              actionButton!,
            ],
          ],
        ),
      ),
    );
  }

  // Factory constructors for common empty states
  factory EmptyStateWidget.noRooms({
    required VoidCallback onAddRoom,
  }) {
    return EmptyStateWidget(
      icon: Icons.home_work_outlined,
      title: 'No Rooms Added',
      subtitle: 'Start by adding your first room',
      actionButton: ElevatedButton.icon(
        onPressed: onAddRoom,
        icon: const Icon(Icons.add),
        label: const Text('Add Room'),
      ),
    );
  }

  factory EmptyStateWidget.noTenants({
    required VoidCallback onAddTenant,
    required bool hasRooms,
  }) {
    return EmptyStateWidget(
      icon: Icons.people_outline,
      title: hasRooms ? 'No Tenants Added' : 'Add Rooms First',
      subtitle: hasRooms 
          ? 'Start by adding your first tenant'
          : 'You need to add rooms before adding tenants',
      actionButton: hasRooms 
          ? ElevatedButton.icon(
              onPressed: onAddTenant,
              icon: const Icon(Icons.person_add),
              label: const Text('Add Tenant'),
            )
          : null,
    );
  }

  factory EmptyStateWidget.noResults({
    String? customMessage,
  }) {
    return EmptyStateWidget(
      icon: Icons.search_off,
      title: 'No Results Found',
      subtitle: customMessage ?? 'Try adjusting your search criteria',
    );
  }
}
