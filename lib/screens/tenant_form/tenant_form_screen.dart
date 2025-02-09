import 'package:flutter/material.dart';
import '../../models/tenant.dart';
import 'widgets/tenant_form_content.dart';

class TenantFormScreen extends StatelessWidget {
  final Tenant? tenant;

  const TenantFormScreen({super.key, this.tenant});

  @override
  Widget build(BuildContext context) {
    final formState = TenantFormContent.of(context);
    return PopScope(
      canPop: formState == null || !formState.isSubmitting,
      child: Scaffold(
        appBar: AppBar(
          title: Text(tenant == null ? 'Add Tenant' : 'Edit Tenant'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: TenantFormContent(tenant: tenant),
        ),
      ),
    );
  }
}
