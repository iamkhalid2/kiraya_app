import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/tenant.dart';
import '../../../providers/tenant_provider.dart';
import '../../../providers/room_provider.dart';
import 'personal_details_section.dart';
import 'room_selection_section.dart';
import 'payment_details_section.dart';
import 'kyc_documents_section.dart';

class TenantFormContent extends StatefulWidget {
  final Tenant? tenant;

  const TenantFormContent({super.key, this.tenant});

  static TenantFormContentState? of(BuildContext context) {
    return context.findAncestorStateOfType<TenantFormContentState>();
  }

  @override
  State<TenantFormContent> createState() => TenantFormContentState();
}

class TenantFormContentState extends State<TenantFormContent> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _rentAmountController = TextEditingController();
  final _initialDepositController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  String? _selectedRoomId;
  String? _selectedSection;
  DateTime _joiningDate = DateTime.now();
  String _paymentStatus = 'Paid';
  double? _paidAmount;
  String? _kycImage1;
  String? _kycImage2;
  String? _oldRoomId;
  String? _oldSection;
  bool _isSubmitting = false;

  bool get isSubmitting => _isSubmitting;

  @override
  void initState() {
    super.initState();
    if (widget.tenant != null) {
      _initializeFromTenant();
    }
  }

  void _initializeFromTenant() {
    final tenant = widget.tenant!;
    _nameController.text = tenant.name;
    _selectedRoomId = tenant.roomId;
    _oldRoomId = tenant.roomId;
    _selectedSection = tenant.section;
    _oldSection = tenant.section;
    _rentAmountController.text = tenant.rentAmount.toString();
    _phoneNumberController.text = tenant.phoneNumber;
    _joiningDate = tenant.joiningDate;
    _initialDepositController.text = tenant.initialDeposit.toString();
    _kycImage1 = tenant.kycImage1;
    _kycImage2 = tenant.kycImage2;
    _paymentStatus = tenant.paymentStatus;
    _paidAmount = tenant.paidAmount;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _rentAmountController.dispose();
    _initialDepositController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_isSubmitting) return;

    if (_formKey.currentState!.validate()) {
      setState(() => _isSubmitting = true);

      try {
        final tenant = _createTenant();
        if (!mounted) return;
        
        final navigatorContext = context;
        await _saveTenant(tenant, navigatorContext);
        
        if (!mounted) return;

        // Reset form state before navigation to prevent dropdown error
        setState(() {
          _selectedRoomId = null;
          _selectedSection = null;
        });
        
        Navigator.of(navigatorContext).pop();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        if (mounted) {
          setState(() => _isSubmitting = false);
        }
      }
    }
  }

  Tenant _createTenant() {
    return Tenant(
      id: widget.tenant?.id,
      name: _nameController.text,
      roomId: _selectedRoomId!,
      section: _selectedSection!,
      rentAmount: double.parse(_rentAmountController.text),
      initialDeposit: double.parse(_initialDepositController.text),
      paymentStatus: _paymentStatus,
      phoneNumber: _phoneNumberController.text,
      joiningDate: _joiningDate,
      nextDueDate: DateTime(_joiningDate.year, _joiningDate.month + 1, _joiningDate.day),
      kycImage1: _kycImage1,
      kycImage2: _kycImage2,
      paidAmount: _paymentStatus.toLowerCase() == 'partial' ? _paidAmount : null,
    );
  }

  Future<void> _saveTenant(Tenant tenant, BuildContext context) async {
    final tenantProvider = Provider.of<TenantProvider>(context, listen: false);
    final roomProvider = Provider.of<RoomProvider>(context, listen: false);

    try {
      if (widget.tenant != null) {
        // For existing tenant, let TenantProvider handle both room and tenant updates
        await tenantProvider.updateTenant(context, tenant);
      } else {
        // For new tenant, just add through TenantProvider which handles room assignment
        await tenantProvider.addTenant(context, tenant);
      }
    } catch (e) {
      // Re-throw the error to be handled by the form's error handler
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PersonalDetailsSection(
            nameController: _nameController,
            phoneController: _phoneNumberController,
            isSubmitting: _isSubmitting,
          ),
          const SizedBox(height: 24),
          RoomSelectionSection(
            selectedRoomId: _selectedRoomId,
            selectedSection: _selectedSection,
            oldRoomId: _oldRoomId,
            oldSection: _oldSection,
            isSubmitting: _isSubmitting,
            onRoomSelected: (roomId) {
              setState(() {
                _selectedRoomId = roomId;
                _selectedSection = null;
              });
            },
            onSectionSelected: (section) {
              setState(() {
                _selectedSection = section;
              });
            },
          ),
          const SizedBox(height: 24),
          PaymentDetailsSection(
            rentController: _rentAmountController,
            depositController: _initialDepositController,
            paymentStatus: _paymentStatus,
            joiningDate: _joiningDate,
            isSubmitting: _isSubmitting,
            paidAmount: _paidAmount,
            onPaymentStatusChanged: (status) {
              setState(() {
                _paymentStatus = status ?? 'Paid';
                if (_paymentStatus != 'Partial') {
                  _paidAmount = null;
                }
              });
            },
            onJoiningDateChanged: (date) {
              setState(() {
                _joiningDate = date;
              });
            },
            onPaidAmountChanged: (amount) {
              setState(() {
                _paidAmount = amount;
              });
            },
          ),
          const SizedBox(height: 24),
          KYCDocumentsSection(
            kycImage1: _kycImage1,
            kycImage2: _kycImage2,
            isSubmitting: _isSubmitting,
            onKYC1Selected: (path) {
              setState(() {
                _kycImage1 = path;
              });
            },
            onKYC2Selected: (path) {
              setState(() {
                _kycImage2 = path;
              });
            },
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _isSubmitting ? null : _submitForm,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
            ),
            child: _isSubmitting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    widget.tenant == null ? 'Add Tenant' : 'Update Tenant',
                  ),
          ),
        ],
      ),
    );
  }
}
