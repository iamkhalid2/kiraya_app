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
  String _sortBy = 'name'; // Add this field

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Sort by Name'),
              leading: const Icon(Icons.sort_by_alpha),
              onTap: () {
                setState(() => _sortBy = 'name');
                Navigator.pop(context);
              },
              trailing: _sortBy == 'name' ? const Icon(Icons.check) : null,
            ),
            ListTile(
              title: const Text('Sort by Due Date'),
              leading: const Icon(Icons.calendar_today),
              onTap: () {
                setState(() => _sortBy = 'due_date');
                Navigator.pop(context);
              },
              trailing: _sortBy == 'due_date' ? const Icon(Icons.check) : null,
            ),
            ListTile(
              title: const Text('Sort by Payment Status'),
              leading: const Icon(Icons.payments),
              onTap: () {
                setState(() => _sortBy = 'status');
                Navigator.pop(context);
              },
              trailing: _sortBy == 'status' ? const Icon(Icons.check) : null,
            ),
          ],
        ),
      ),
    );
  }

  List<Tenant> _sortTenants(List<Tenant> tenants) {
    switch (_sortBy) {
      case 'name':
        return List.from(tenants)..sort((a, b) => a.name.compareTo(b.name));
      case 'due_date':
        return List.from(tenants)..sort((a, b) => a.nextDueDate.compareTo(b.nextDueDate));
      case 'status':
        return List.from(tenants)..sort((a, b) => b.paymentStatus.compareTo(a.paymentStatus));
      default:
        return tenants;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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

        final allTenants = tenantProvider.tenants;
        final tenants = _searchQuery.isEmpty
            ? allTenants
            : allTenants.where((tenant) =>
                tenant.name.toLowerCase().contains(_searchQuery) ||
                tenant.phoneNumber.contains(_searchQuery) ||
                tenant.paymentStatus.toLowerCase().contains(_searchQuery)).toList();

        return Scaffold(
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(80),
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
                            'Tenant Management',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${tenants.length} Active ${tenants.length == 1 ? 'Tenant' : 'Tenants'}',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.primary.withOpacity(0.8),
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
                        icon: const Icon(Icons.add),
                        tooltip: 'Add Tenant',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search tenants...',
                          prefixIcon: const Icon(Icons.search, size: 20),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Theme.of(context).colorScheme.surface,
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
                    const SizedBox(width: 8),
                    IconButton.filled(
                      onPressed: _showSortOptions,
                      icon: const Icon(Icons.sort, size: 20),
                      tooltip: 'Sort tenants',
                    ),
                  ],
                ),
              ),
              Expanded(
                child: allTenants.isEmpty
                    ? _buildEmptyState()
                    : tenants.isEmpty
                        ? _buildNoSearchResults()
                        : ListView.builder(
                            padding: const EdgeInsets.only(top: 8),
                            itemCount: tenants.length,
                            itemBuilder: (context, index) {
                              final sortedTenants = _sortTenants(tenants);
                              return _buildTenantCard(context, sortedTenants[index]);
                            },
                          ),
              ),
            ],
          ),
        );
      },
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
