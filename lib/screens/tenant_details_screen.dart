import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import '../models/tenant.dart';
import '../models/room.dart';
import '../providers/tenant_provider.dart';
import '../providers/room_provider.dart';
import 'tenant_form/tenant_form_screen.dart';

class TenantDetailsScreen extends StatelessWidget {
  final String tenantId;

  const TenantDetailsScreen({
    super.key,
    required this.tenantId,
  });

  Future<void> _makePhoneCall(BuildContext context, String phoneNumber) async {
    try {
      final Uri launchUri = Uri(
        scheme: 'tel',
        path: phoneNumber,
      );
      await launchUrl(launchUri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('Could not launch phone call: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not make phone call')),
        );
      }
    }
  }

  Future<void> _sendSMS(BuildContext context, String phoneNumber) async {
    try {
      final Uri launchUri = Uri(
        scheme: 'sms',
        path: phoneNumber,
      );
      await launchUrl(launchUri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('Could not launch SMS: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not send message')),
        );
      }
    }
  }

  Future<void> _markAsPaid(BuildContext context, Tenant tenant) async {
    try {
      final tenantProvider = Provider.of<TenantProvider>(context, listen: false);
      final now = DateTime.now();
      
      // Calculate next due date based on the tenant's joining day
      final nextDueDate = now.day > tenant.joiningDate.day
          ? DateTime(now.year, now.month + 1, tenant.joiningDate.day)  // Next month if we've passed the day
          : DateTime(now.year, now.month, tenant.joiningDate.day);     // This month if we haven't reached the day yet

      final updatedTenant = tenant.copyWith(
        paymentStatus: 'Paid',
        paidAmount: null, // Clear partial payment amount
        nextDueDate: nextDueDate,
      );

      await tenantProvider.updateTenant(context, updatedTenant);
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Marked as paid successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _showDeleteConfirmation(BuildContext context, Tenant tenant) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Tenant'),
        content: const Text(
          'Are you sure you want to delete this tenant? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () async {
              try {
                Navigator.of(ctx).pop(); // Close dialog first
                await Provider.of<TenantProvider>(context, listen: false)
                    .deleteTenant(context, tenant.id!);
                if (context.mounted) {
                  Navigator.of(context).pop(); // Then pop the details screen
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error deleting tenant: $e')),
                  );
                }
              }
            },
            child: const Text('DELETE'),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    return switch (status.toLowerCase()) {
      'paid' => Colors.green,
      'pending' => Colors.red,
      'partial' => Colors.orange,
      _ => Colors.grey,
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Consumer<TenantProvider>(
      builder: (context, tenantProvider, _) {
        final tenant = tenantProvider.tenants.firstWhere(
          (t) => t.id == tenantId,
          orElse: () => Tenant(
            id: tenantId,
            name: 'Loading...',
            roomId: '',
            section: '',
            rentAmount: 0,
            initialDeposit: 0,
            paymentStatus: '',
            phoneNumber: '',
            joiningDate: DateTime.now(),
            nextDueDate: DateTime.now(),
          ),
        );

        if (tenant.name == 'Loading...') {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

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
                            tenant.name,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Consumer<RoomProvider>(
                            builder: (context, roomProvider, _) {
                              final room = roomProvider.rooms.firstWhere(
                                (room) => room.id == tenant.roomId,
                                orElse: () => Room(number: 'Unknown', occupantLimit: 0),
                              );
                              return Text(
                                'Room ${room.number} - Section ${tenant.section}',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: theme.colorScheme.primary.withOpacity(0.8),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => TenantFormScreen(tenant: tenant),
                                ),
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => _showDeleteConfirmation(context, tenant),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                Card(
                  margin: const EdgeInsets.all(16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListTile(
                          title: const Text('Payment Status'),
                          trailing: Chip(
                            label: Text(tenant.paymentStatus),
                            backgroundColor: _getStatusColor(tenant.paymentStatus).withOpacity(0.2),
                            labelStyle: TextStyle(
                              color: _getStatusColor(tenant.paymentStatus),
                            ),
                          ),
                        ),
                        if (tenant.paymentStatus.toLowerCase() != 'paid') ...[
                          const Divider(),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () => _markAsPaid(context, tenant),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                                icon: const Icon(Icons.check_circle, color: Colors.white),
                                label: const Text('Mark as Paid'),
                              ),
                            ),
                          ),
                        ],
                        const Divider(),
                        ListTile(
                          title: const Text('Rent Amount'),
                          trailing: Text(
                            '₹${tenant.rentAmount.toStringAsFixed(2)}',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                        if (tenant.paymentStatus.toLowerCase() == 'partial') ...[
                          const Divider(),
                          ListTile(
                            title: const Text('Paid Amount'),
                            trailing: Text(
                              '₹${tenant.paidAmount?.toStringAsFixed(2) ?? "0.00"}',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Colors.green,
                              ),
                            ),
                          ),
                          ListTile(
                            title: const Text('Due Amount'),
                            trailing: Text(
                              '₹${tenant.dueAmount.toStringAsFixed(2)}',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Theme.of(context).colorScheme.error,
                              ),
                            ),
                          ),
                        ],
                        const Divider(),
                        ListTile(
                          title: const Text('Initial Deposit'),
                          trailing: Text(
                            '₹${tenant.initialDeposit.toStringAsFixed(2)}',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        const Divider(),
                        ListTile(
                          title: const Text('Joining Date'),
                          trailing: Text(
                            DateFormat('dd/MM/yyyy').format(tenant.joiningDate),
                          ),
                        ),
                        const Divider(),
                        ListTile(
                          title: const Text('Next Due Date'),
                          trailing: Text(
                            DateFormat('dd/MM/yyyy').format(tenant.nextDueDate),
                            style: TextStyle(
                              color: tenant.nextDueDate.isBefore(DateTime.now())
                                  ? Colors.red
                                  : null,
                            ),
                          ),
                        ),
                        const Divider(),
                        ListTile(
                          title: const Text('Phone Number'),
                          trailing: Text(tenant.phoneNumber),
                          onTap: () => _makePhoneCall(context, tenant.phoneNumber),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _makePhoneCall(context, tenant.phoneNumber),
                          icon: const Icon(Icons.phone),
                          label: const Text('Call'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _sendSMS(context, tenant.phoneNumber),
                          icon: const Icon(Icons.message),
                          label: const Text('Message'),
                        ),
                      ),
                    ],
                  ),
                ),
                Card(
                  margin: const EdgeInsets.all(16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'KYC Documents',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                children: [
                                  const Text('ID Proof 1'),
                                  const SizedBox(height: 8),
                                  Icon(
                                    tenant.kycImage1 != null
                                        ? Icons.check_circle
                                        : Icons.cancel,
                                    color: tenant.kycImage1 != null
                                        ? Colors.green
                                        : Colors.red,
                                    size: 32,
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                children: [
                                  const Text('ID Proof 2'),
                                  const SizedBox(height: 8),
                                  Icon(
                                    tenant.kycImage2 != null
                                        ? Icons.check_circle
                                        : Icons.cancel,
                                    color: tenant.kycImage2 != null
                                        ? Colors.green
                                        : Colors.red,
                                    size: 32,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }
}
