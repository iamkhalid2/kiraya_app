import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/tenant_provider.dart';
import '../providers/room_provider.dart';
import '../providers/auth_provider.dart';  // Add this import
import '../models/tenant.dart';
import '../models/room.dart';
import 'tenant_form/tenant_form_screen.dart';
import 'tenant_details_screen.dart';

class TenantListScreen extends StatefulWidget {
  const TenantListScreen({super.key});

  @override
  State<TenantListScreen> createState() => _TenantListScreenState();
}

class _TenantListScreenState extends State<TenantListScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Widget _buildTenantCard(BuildContext context, Tenant tenant) {
    Color statusColor;
    switch (tenant.paymentStatus.toLowerCase()) {
      case 'paid':
        statusColor = Colors.green;
        break;
      case 'pending':
        statusColor = Colors.red;
        break;
      case 'partial':
        statusColor = Colors.orange;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: const CircleAvatar(
          child: Icon(Icons.person),
        ),
        title: Text(tenant.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Consumer<RoomProvider>(
              builder: (context, roomProvider, _) {
                final room = roomProvider.rooms.firstWhere(
                  (room) => room.id == tenant.roomId,
                  orElse: () => Room(number: 'Unknown', occupantLimit: 1),
                );
                return Text('Room ${room.number} - Section ${tenant.section}');
              },
            ),
            Text(
              'Joined: ${DateFormat('dd/MM/yyyy').format(tenant.joiningDate)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Text(
              'Due: ${DateFormat('dd/MM/yyyy').format(tenant.nextDueDate)}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: tenant.nextDueDate.isBefore(DateTime.now())
                        ? Colors.red
                        : null,
                  ),
            ),
          ],
        ),
        trailing: SizedBox(
          width: 80,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '₹${tenant.rentAmount.toStringAsFixed(0)}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor.withAlpha(26),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  tenant.paymentStatus,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 11,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TenantDetailsScreen(tenant: tenant),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, TenantProvider>(
      builder: (context, authProvider, tenantProvider, child) {
        if (!authProvider.isAuthenticated) {
          return const Scaffold(
            body: Center(child: Text('Please log in to view tenants')),
          );
        }

        if (!tenantProvider.isInitialized) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final tenants = tenantProvider.tenants;

        if (tenants.isEmpty) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.person_outline,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No tenants found',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TenantFormScreen(),
                  ),
                );
              },
              child: const Icon(Icons.add),
            ),
          );
        }

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
                            'Tenant Management',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${tenants.length} Active Tenant${tenants.length != 1 ? 's' : ''}',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Theme.of(context).primaryColor.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                      IconButton.filled(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const TenantFormScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.person_add),
                        tooltip: 'Add Tenant',
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          body: ListView.builder(
            padding: const EdgeInsets.only(top: 8),
            itemCount: tenants.length,
            itemBuilder: (context, index) =>
                _buildTenantCard(context, tenants[index]),
          ),
        );
      },
    );
  }
}
