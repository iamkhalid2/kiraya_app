import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class PaymentDetailsSection extends StatefulWidget {
  final TextEditingController rentController;
  final TextEditingController depositController;
  final String paymentStatus;
  final DateTime joiningDate;
  final bool isSubmitting;
  final Function(String?) onPaymentStatusChanged;
  final void Function(DateTime) onJoiningDateChanged;
  final void Function(double?)? onPaidAmountChanged;
  final double? paidAmount;

  const PaymentDetailsSection({
    super.key,
    required this.rentController,
    required this.depositController,
    required this.paymentStatus,
    required this.joiningDate,
    required this.isSubmitting,
    required this.onPaymentStatusChanged,
    required this.onJoiningDateChanged,
    this.onPaidAmountChanged,
    this.paidAmount,
  });

  @override
  State<PaymentDetailsSection> createState() => _PaymentDetailsSectionState();
}

class _PaymentDetailsSectionState extends State<PaymentDetailsSection> {
  final _paidAmountController = TextEditingController();
  double? _dueAmount;

  @override
  void initState() {
    super.initState();
    _paidAmountController.text = widget.paidAmount?.toString() ?? '';
    _updateDueAmount();
  }

  @override
  void dispose() {
    _paidAmountController.dispose();
    super.dispose();
  }

  void _updateDueAmount() {
    if (widget.paymentStatus.toLowerCase() == 'partial') {
      final rentAmount = double.tryParse(widget.rentController.text) ?? 0;
      final paidAmount = double.tryParse(_paidAmountController.text) ?? 0;
      setState(() {
        _dueAmount = rentAmount - paidAmount;
      });
    } else {
      setState(() {
        _dueAmount = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: widget.rentController,
                decoration: const InputDecoration(
                  labelText: 'Rent Amount',
                  border: OutlineInputBorder(),
                  prefixText: '₹ ',
                ),
                enabled: !widget.isSubmitting,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter rent amount';
                  }
                  return null;
                },
                onChanged: (_) => _updateDueAmount(),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: widget.depositController,
                decoration: const InputDecoration(
                  labelText: 'Initial Deposit',
                  border: OutlineInputBorder(),
                  prefixText: '₹ ',
                ),
                enabled: !widget.isSubmitting,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
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
        DropdownButtonFormField<String>(
          value: widget.paymentStatus,
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
          onChanged: widget.isSubmitting ? null : (value) {
            if (value != null) {
              widget.onPaymentStatusChanged(value);
              if (value != 'Partial') {
                _paidAmountController.clear();
                widget.onPaidAmountChanged?.call(null);
              }
              _updateDueAmount();
            }
          },
        ),
        if (widget.paymentStatus.toLowerCase() == 'partial') ...[
          const SizedBox(height: 16),
          TextFormField(
            controller: _paidAmountController,
            decoration: const InputDecoration(
              labelText: 'Paid Amount',
              border: OutlineInputBorder(),
              prefixText: '₹ ',
            ),
            enabled: !widget.isSubmitting,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.next,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter paid amount';
              }
              final paidAmount = double.tryParse(value);
              final rentAmount = double.tryParse(widget.rentController.text);
              if (paidAmount == null || rentAmount == null) {
                return 'Invalid amount';
              }
              if (paidAmount <= 0) {
                return 'Paid amount must be greater than 0';
              }
              if (paidAmount >= rentAmount) {
                return 'For full payment, select Paid status';
              }
              return null;
            },
            onChanged: (value) {
              _updateDueAmount();
              final amount = double.tryParse(value);
              widget.onPaidAmountChanged?.call(amount);
            },
          ),
          if (_dueAmount != null) ...[
            const SizedBox(height: 8),
            Text(
              'Due Amount: ₹${_dueAmount!.toStringAsFixed(2)}',
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ],
        const SizedBox(height: 16),
        ListTile(
          enabled: !widget.isSubmitting,
          title: const Text('Joining Date'),
          subtitle: Text(
            DateFormat('dd/MM/yyyy').format(widget.joiningDate),
          ),
          trailing: const Icon(Icons.calendar_today),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
            side: BorderSide(color: Colors.grey[400]!),
          ),
          onTap: () async {
            final DateTime? picked = await showDatePicker(
              context: context,
              initialDate: widget.joiningDate,
              firstDate: DateTime(2000),
              lastDate: DateTime.now(),
            );
            if (picked != null && picked != widget.joiningDate) {
              widget.onJoiningDateChanged(picked);
            }
          },
        ),
      ],
    );
  }
}
