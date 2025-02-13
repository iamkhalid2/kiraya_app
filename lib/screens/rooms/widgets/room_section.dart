import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/room.dart';
import '../../../models/tenant.dart';
import '../../../providers/tenant_provider.dart';

class RoomSection extends StatelessWidget {
  final Section section;
  final bool isSmall;

  const RoomSection({
    super.key,
    required this.section,
    this.isSmall = false,
  });

  Color _getBackgroundColor(BuildContext context) {
    if (!section.isOccupied) return Colors.grey.shade200;
    
    final tenant = Provider.of<TenantProvider>(context)
        .tenants
        .firstWhere(
          (t) => t.id == section.tenantId,
          orElse: () => Tenant(
            id: '', name: '', roomId: '', section: '',
            rentAmount: 0, initialDeposit: 0, paymentStatus: '',
            phoneNumber: '', joiningDate: DateTime.now(),
            nextDueDate: DateTime.now(),
          ),
        );
    
    return switch (tenant.paymentStatus.toLowerCase()) {
      'paid' => Colors.green.withOpacity(0.3),
      'pending' => Colors.red.withOpacity(0.3),
      'partial' => Colors.orange.withOpacity(0.3),
      _ => Colors.grey.shade200,
    };
  }

  Color _getTextColor(BuildContext context) {
    if (!section.isOccupied) return Colors.black54;
    
    final tenant = Provider.of<TenantProvider>(context)
        .tenants
        .firstWhere(
          (t) => t.id == section.tenantId,
          orElse: () => throw Exception('Tenant not found'),
        );

    return switch (tenant.paymentStatus.toLowerCase()) {
      'paid' => Colors.green.shade700,
      'pending' => Colors.red.shade700,
      'partial' => Colors.orange.shade700,
      _ => Colors.black54,
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AspectRatio(
      aspectRatio: 1,
      child: Material(
        color: _getBackgroundColor(context),
        shape: const CircleBorder(),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                section.id,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: _getTextColor(context),
                  fontSize: isSmall ? 14 : 18,
                ),
              ),
              if (section.isOccupied && section.tenantName != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    section.tenantName!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.black45,
                      fontSize: isSmall ? 9 : 11,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}