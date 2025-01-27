import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/tenant_provider.dart';
import '../models/tenant.dart';
import 'tenant_form_screen.dart';
import 'tenant_details_screen.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => Provider.of<TenantProvider>(context, listen: false).loadTenants(),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showFilterOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.all_inbox),
            title: const Text('All'),
            onTap: () {
              Provider.of<TenantProvider>(context, listen: false)
                  .clearSearchQuery();
              Navigator.pop(ctx);
            },
          ),
          ListTile(
            leading: const Icon(Icons.check_circle),
            title: const Text('Paid'),
            onTap: () {
              Provider.of<TenantProvider>(context, listen: false)
                  .setSearchQuery('Paid');
              Navigator.pop(ctx);
            },
          ),
          ListTile(
            leading: const Icon(Icons.pending),
            title: const Text('Pending'),
            onTap: () {
              Provider.of<TenantProvider>(context, listen: false)
                  .setSearchQuery('Pending');
              Navigator.pop(ctx);
            },
          ),
          ListTile(
            leading: const Icon(Icons.warning),
            title: const Text('Partial'),
            onTap: () {
              Provider.of<TenantProvider>(context, listen: false)
                  .setSearchQuery('Partial');
              Navigator.pop(ctx);
            },
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
            Text('Room ${tenant.roomNumber}'),
            Text(
              'Last Paid: ${DateFormat('dd/MM/yyyy').format(tenant.lastPaymentDate)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '₹${tenant.rentAmount.toStringAsFixed(0)}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Chip(
              label: Text(
                tenant.paymentStatus,
                style: TextStyle(
                  color: statusColor,
                  fontSize: 12,
                ),
              ),
              backgroundColor: statusColor.withOpacity(0.1),
              padding: EdgeInsets.zero,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ],
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
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search tenants...',
                  border: InputBorder.none,
                ),
                onChanged: (value) {
                  Provider.of<TenantProvider>(context, listen: false)
                      .setSearchQuery(value);
                },
              )
            : const Text('Rent Management'),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                if (_isSearching) {
                  _searchController.clear();
                  Provider.of<TenantProvider>(context, listen: false)
                      .clearSearchQuery();
                }
                _isSearching = !_isSearching;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterOptions(context),
          ),
        ],
      ),
      body: Consumer<TenantProvider>(
        builder: (context, tenantProvider, child) {
          if (tenantProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final tenants = tenantProvider.tenants;

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

          return RefreshIndicator(
            onRefresh: () => tenantProvider.loadTenants(),
            child: ListView.builder(
              itemCount: tenants.length,
              itemBuilder: (context, index) =>
                  _buildTenantCard(context, tenants[index]),
            ),
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
  }
}
