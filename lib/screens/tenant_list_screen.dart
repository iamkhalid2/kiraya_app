import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/tenant_provider.dart';
import '../providers/room_provider.dart';
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
                  orElse: () => Room(number: 'Unknown', occupantLimit: 0),
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
    return Consumer<TenantProvider>(
      builder: (context, tenantProvider, child) {
        return Scaffold(
          body: StreamBuilder<List<Tenant>>(
            stream: tenantProvider.tenantsStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text('Error: ${snapshot.error}'),
                );
              }

              final tenants = snapshot.data ?? [];
              final filteredTenants = tenantProvider.tenants;

              if (tenants.isEmpty) {
                return Center(
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
                );
              }

              return ListView.builder(
                itemCount: filteredTenants.length,
                itemBuilder: (context, index) =>
                    _buildTenantCard(context, filteredTenants[index]),
              );
            },
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
      },
    );
  }
}
