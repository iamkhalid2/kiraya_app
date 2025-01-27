import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/tenant.dart';
import '../providers/tenant_provider.dart';
import 'package:intl/intl.dart';

class TenantFormScreen extends StatefulWidget {
  final Tenant? tenant;

  const TenantFormScreen({super.key, this.tenant});

  @override
  State<TenantFormScreen> createState() => _TenantFormScreenState();
}

class _TenantFormScreenState extends State<TenantFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _roomNumberController = TextEditingController();
  final _rentAmountController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  DateTime _lastPaymentDate = DateTime.now();
  String _paymentStatus = 'Paid';

  @override
  void initState() {
    super.initState();
    if (widget.tenant != null) {
      _nameController.text = widget.tenant!.name;
      _roomNumberController.text = widget.tenant!.roomNumber;
      _rentAmountController.text = widget.tenant!.rentAmount.toString();
      _phoneNumberController.text = widget.tenant!.phoneNumber;
      _lastPaymentDate = widget.tenant!.lastPaymentDate;
      _paymentStatus = widget.tenant!.paymentStatus;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _roomNumberController.dispose();
    _rentAmountController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _lastPaymentDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _lastPaymentDate) {
      setState(() {
        _lastPaymentDate = picked;
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final tenant = Tenant(
        id: widget.tenant?.id,
        name: _nameController.text,
        roomNumber: _roomNumberController.text,
        rentAmount: double.parse(_rentAmountController.text),
        paymentStatus: _paymentStatus,
        phoneNumber: _phoneNumberController.text,
        lastPaymentDate: _lastPaymentDate,
      );

      final tenantProvider = Provider.of<TenantProvider>(context, listen: false);
      
      if (widget.tenant == null) {
        tenantProvider.addTenant(tenant);
      } else {
        tenantProvider.updateTenant(tenant);
      }

      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.tenant == null ? 'Add Tenant' : 'Edit Tenant'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Tenant Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter tenant name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _roomNumberController,
                decoration: const InputDecoration(
                  labelText: 'Room Number',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter room number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _rentAmountController,
                decoration: const InputDecoration(
                  labelText: 'Rent Amount',
                  border: OutlineInputBorder(),
                  prefixText: '₹ ',
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter rent amount';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneNumberController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter phone number';
                  }
                  if (value.length != 10) {
                    return 'Phone number must be 10 digits';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _paymentStatus,
                decoration: const InputDecoration(
                  labelText: 'Payment Status',
                  border: OutlineInputBorder(),
                ),
                items: ['Paid', 'Pending', 'Partial']
                    .map((status) => DropdownMenuItem(
                          value: status,
                          child: Text(status),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _paymentStatus = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Last Payment Date'),
                subtitle: Text(
                  DateFormat('dd/MM/yyyy').format(_lastPaymentDate),
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(context),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                ),
                child: Text(
                  widget.tenant == null ? 'Add Tenant' : 'Update Tenant',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
