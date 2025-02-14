import 'package:flutter/material.dart';
import '../../models/tenant.dart';
import 'widgets/tenant_form_content.dart';

class TenantFormScreen extends StatelessWidget {
  final Tenant? tenant;
  final String? preselectedRoomId;
  final String? preselectedSection;

  const TenantFormScreen({
    super.key, 
    this.tenant,
    this.preselectedRoomId,
    this.preselectedSection,
  });

  @override
  Widget build(BuildContext context) {
    final formState = TenantFormContent.of(context);
    return PopScope(
      canPop: formState == null || !formState.isSubmitting,
      child: Scaffold(
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
                          tenant == null ? 'Add New Tenant' : 'Edit Tenant',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          tenant == null ? 'Enter tenant details' : 'Update tenant information',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.8),
                          ),
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
          padding: const EdgeInsets.all(16),
          child: TenantFormContent(
            tenant: tenant,
            preselectedRoomId: preselectedRoomId,
            preselectedSection: preselectedSection,
          ),
        ),
      ),
    );
  }
}
