import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import '../models/tenant.dart';
import '../providers/tenant_provider.dart';
import 'tenant_form_screen.dart';

class TenantDetailsScreen extends StatelessWidget {
  final Tenant tenant;

  const TenantDetailsScreen({super.key, required this.tenant});

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
          const SnackBar(content: Text('Could not send SMS')),
        );
      }
    }
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Tenant'),
        content: const Text('Are you sure you want to delete this tenant?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () async {
              try {
                if (tenant.id != null) {
                  await Provider.of<TenantProvider>(context, listen: false)
                      .deleteTenant(context, tenant.id!);
                  if (context.mounted) {
                    Navigator.of(ctx).pop();
                    Navigator.of(context).pop();
                  }
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.of(ctx).pop();
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
    switch (status.toLowerCase()) {
      case 'paid':
        return Colors.green;
      case 'pending':
        return Colors.red;
      case 'partial':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tenant Details'),
        actions: [
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
            onPressed: () => _showDeleteConfirmation(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 50,
                    child: Icon(Icons.person, size: 50),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    tenant.name,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Room ${tenant.roomNumber} - Section ${tenant.section}',
                    style: Theme.of(context).textTheme.titleLarge,
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
                    const Divider(),
                    ListTile(
                      title: const Text('Rent Amount'),
                      trailing: Text(
                        '₹${tenant.rentAmount.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
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
  }
}
