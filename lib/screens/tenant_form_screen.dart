import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/tenant.dart';
import '../providers/tenant_provider.dart';
import '../providers/room_provider.dart';
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
  final _rentAmountController = TextEditingController();
  final _initialDepositController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  String? _selectedRoomId;
  String? _selectedSection;
  DateTime _joiningDate = DateTime.now();
  String _paymentStatus = 'Paid';
  String? _kycImage1;
  String? _kycImage2;

  @override
  void initState() {
    super.initState();
    if (widget.tenant != null) {
      _nameController.text = widget.tenant!.name;
      _selectedRoomId = widget.tenant!.roomId;
      _selectedSection = widget.tenant!.section;
      _rentAmountController.text = widget.tenant!.rentAmount.toString();
      _phoneNumberController.text = widget.tenant!.phoneNumber;
      _joiningDate = widget.tenant!.joiningDate;
      _initialDepositController.text = widget.tenant!.initialDeposit.toString();
      _kycImage1 = widget.tenant!.kycImage1;
      _kycImage2 = widget.tenant!.kycImage2;
      _paymentStatus = widget.tenant!.paymentStatus;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _rentAmountController.dispose();
    _initialDepositController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }

  Future<void> _selectJoiningDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _joiningDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _joiningDate) {
      setState(() {
        _joiningDate = picked;
      });
    }
  }

  DateTime _calculateNextDueDate(DateTime joiningDate) {
    return DateTime(joiningDate.year, joiningDate.month + 1, joiningDate.day);
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final joiningDate = _joiningDate;
      try {
        final tenant = Tenant(
          id: widget.tenant?.id,
          name: _nameController.text,
          roomId: _selectedRoomId!,
          section: _selectedSection!,
          rentAmount: double.parse(_rentAmountController.text),
          initialDeposit: double.parse(_initialDepositController.text),
          paymentStatus: _paymentStatus,
          phoneNumber: _phoneNumberController.text,
          joiningDate: joiningDate,
          nextDueDate: _calculateNextDueDate(joiningDate),
          kycImage1: _kycImage1,
          kycImage2: _kycImage2,
        );

        final tenantProvider = Provider.of<TenantProvider>(context, listen: false);
        
        if (widget.tenant == null) {
          await tenantProvider.addTenant(context, tenant);
        } else {
          await tenantProvider.updateTenant(context, tenant);
        }

        Navigator.of(context).pop();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
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
              Consumer<RoomProvider>(
                builder: (context, roomProvider, child) {
                  final availableRooms = widget.tenant != null 
                      ? roomProvider.rooms
                      : roomProvider.rooms.where((room) => !room.isFull()).toList();
                  final selectedRoom = _selectedRoomId != null 
                      ? roomProvider.rooms.firstWhere((room) => room.id == _selectedRoomId)
                      : null;

                  return Column(
                    children: [
                      DropdownButtonFormField<String>(
                        value: _selectedRoomId,
                        decoration: const InputDecoration(
                          labelText: 'Select Room',
                          border: OutlineInputBorder(),
                        ),
                        items: availableRooms.map((room) {
                          final occupancyText = switch (room.occupantLimit) {
                            1 => 'Single Room',
                            2 => 'Double Sharing',
                            3 => 'Triple Sharing',
                            _ => 'Four Sharing',
                          };
                          return DropdownMenuItem(
                            value: room.id,
                            child: Text('Room ${room.number} ($occupancyText)'),
                          );
                        }).toList(),
                        onChanged: widget.tenant != null ? null : (roomId) {
                          setState(() {
                            _selectedRoomId = roomId;
                            _selectedSection = null; // Reset section when room changes
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Please select a room';
                          }
                          return null;
                        },
                      ),
                      if (_selectedRoomId != null && selectedRoom != null) ...[
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: _selectedSection,
                          decoration: const InputDecoration(
                            labelText: 'Select Section',
                            border: OutlineInputBorder(),
                          ),
                          items: (widget.tenant != null 
                              ? [widget.tenant!.section]
                              : selectedRoom.getAvailableSections()
                          ).map((section) {
                            return DropdownMenuItem(
                              value: section,
                              child: Text('Section $section'),
                            );
                          }).toList(),
                          onChanged: widget.tenant != null ? null : (section) {
                            setState(() {
                              _selectedSection = section;
                            });
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Please select a section';
                            }
                            return null;
                          },
                        ),
                      ],
                    ],
                  );
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
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
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _initialDepositController,
                      decoration: const InputDecoration(
                        labelText: 'Initial Deposit',
                        border: OutlineInputBorder(),
                        prefixText: '₹ ',
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter initial deposit';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
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
                title: const Text('Joining Date'),
                subtitle: Text(
                  DateFormat('dd/MM/yyyy').format(_joiningDate),
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectJoiningDate(context),
              ),
              const SizedBox(height: 16),
              const Text(
                'KYC Documents',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Container(
                          height: 100,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Center(
                            child: _kycImage1 != null
                                ? const Icon(Icons.check_circle, color: Colors.green)
                                : const Text('No ID Proof 1'),
                          ),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                          onPressed: () {
                            // Will implement file picking later
                            setState(() => _kycImage1 = 'dummy_path');
                          },
                          icon: const Icon(Icons.upload_file),
                          label: const Text('ID Proof 1'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      children: [
                        Container(
                          height: 100,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Center(
                            child: _kycImage2 != null
                                ? const Icon(Icons.check_circle, color: Colors.green)
                                : const Text('No ID Proof 2'),
                          ),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                          onPressed: () {
                            // Will implement file picking later
                            setState(() => _kycImage2 = 'dummy_path');
                          },
                          icon: const Icon(Icons.upload_file),
                          label: const Text('ID Proof 2'),
                        ),
                      ],
                    ),
                  ),
                ],
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
