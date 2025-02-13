import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/tenant_provider.dart';
import '../providers/room_provider.dart';
import '../providers/auth_provider.dart';
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
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, TenantProvider>(
      builder: (context, authProvider, tenantProvider, child) {
        if (!authProvider.isAuthenticated) {
          return Scaffold(
            appBar: _buildAppBar(context, 0),
            body: const Center(child: Text('Please log in to view tenants')),
          );
        }

        if (!tenantProvider.isInitialized) {
          return Scaffold(
            appBar: _buildAppBar(context, 0),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        final allTenants = tenantProvider.tenants;
        final tenants = _searchQuery.isEmpty
            ? allTenants
            : allTenants.where((tenant) =>
                tenant.name.toLowerCase().contains(_searchQuery) ||
                tenant.phoneNumber.contains(_searchQuery) ||
                tenant.paymentStatus.toLowerCase().contains(_searchQuery)).toList();

        return Scaffold(
          appBar: _buildAppBar(context, tenants.length),
          body: allTenants.isEmpty
              ? _buildEmptyState()
              : tenants.isEmpty
                  ? _buildNoSearchResults()
                  : ListView.builder(
                      padding: const EdgeInsets.only(top: 8),
                      itemCount: tenants.length,
                      itemBuilder: (context, index) => _buildTenantCard(context, tenants[index]),
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
            child: const Icon(Icons.person_add),
          ),
        );
      },
    );
  }

  PreferredSize _buildAppBar(BuildContext context, int tenantsCount) {
    final theme = Theme.of(context);
    
    return PreferredSize(
      preferredSize: const Size.fromHeight(140),
      child: Container(
        color: theme.primaryColor.withOpacity(0.1),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tenant Management',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.primaryColor,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$tenantsCount Active Tenant${tenantsCount != 1 ? 's' : ''}',
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: theme.primaryColor.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                    if (tenantsCount > 0)
                      Container(
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Consumer<TenantProvider>(
                          builder: (context, provider, _) => DropdownButtonHideUnderline(
                            child: DropdownButton<TenantSortBy>(
                              value: provider.sortBy,
                              isDense: true,
                              icon: const Icon(Icons.sort, size: 18),
                              style: theme.textTheme.bodyMedium,
                              items: [
                                DropdownMenuItem(
                                  value: TenantSortBy.name,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.sort_by_alpha, 
                                        size: 16,
                                        color: theme.primaryColor),
                                      const SizedBox(width: 4),
                                      Text('Name', style: theme.textTheme.bodyMedium),
                                    ],
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: TenantSortBy.paymentStatus,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.payment,
                                        size: 16,
                                        color: theme.primaryColor),
                                      const SizedBox(width: 4),
                                      Text('Status', style: theme.textTheme.bodyMedium),
                                    ],
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: TenantSortBy.roomNumber,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.meeting_room,
                                        size: 16,
                                        color: theme.primaryColor),
                                      const SizedBox(width: 4),
                                      Text('Room', style: theme.textTheme.bodyMedium),
                                    ],
                                  ),
                                ),
                              ],
                              onChanged: (value) {
                                if (value != null) {
                                  provider.setSortBy(value);
                                }
                              },
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: SizedBox(
                  height: 44,
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search tenants...',
                      hintStyle: theme.textTheme.bodyMedium,
                      prefixIcon: const Icon(Icons.search, size: 20),
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: EdgeInsets.zero,
                      isDense: true,
                    ),
                    style: theme.textTheme.bodyMedium,
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value.toLowerCase();
                      });
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
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

  Widget _buildNoSearchResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
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
          const SizedBox(height: 8),
          Text(
            'Try different search terms',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
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
          width: 100,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '₹${tenant.rentAmount.toStringAsFixed(0)}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              if (tenant.paymentStatus.toLowerCase() == 'partial')
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.arrow_downward, size: 12, color: statusColor),
                    Text(
                      '₹${tenant.dueAmount.toStringAsFixed(0)}',
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                )
              else
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
              builder: (context) => TenantDetailsScreen(tenantId: tenant.id!),
            ),
          );
        },
      ),
    );
  }
}
