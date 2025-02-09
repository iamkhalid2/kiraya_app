import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class PaymentDetailsSection extends StatelessWidget {
  final TextEditingController rentController;
  final TextEditingController depositController;
  final String paymentStatus;
  final DateTime joiningDate;
  final bool isSubmitting;
  final Function(String?) onPaymentStatusChanged;
  final void Function(DateTime) onJoiningDateChanged;

  const PaymentDetailsSection({
    super.key,
    required this.rentController,
    required this.depositController,
    required this.paymentStatus,
    required this.joiningDate,
    required this.isSubmitting,
    required this.onPaymentStatusChanged,
    required this.onJoiningDateChanged,
  });

  Future<void> _selectJoiningDate(BuildContext context) async {
    if (isSubmitting) return;

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: joiningDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != joiningDate) {
      onJoiningDateChanged(picked);
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
                controller: rentController,
                decoration: const InputDecoration(
                  labelText: 'Rent Amount',
                  border: OutlineInputBorder(),
                  prefixText: '₹ ',
                ),
                enabled: !isSubmitting,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
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
                controller: depositController,
                decoration: const InputDecoration(
                  labelText: 'Initial Deposit',
                  border: OutlineInputBorder(),
                  prefixText: '₹ ',
                ),
                enabled: !isSubmitting,
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
          value: paymentStatus,
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
          onChanged: isSubmitting ? null : (value) {
            if (value != null) onPaymentStatusChanged(value);
          },
        ),
        const SizedBox(height: 16),
        ListTile(
          enabled: !isSubmitting,
          title: const Text('Joining Date'),
          subtitle: Text(
            DateFormat('dd/MM/yyyy').format(joiningDate),
          ),
          trailing: const Icon(Icons.calendar_today),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
            side: BorderSide(color: Colors.grey[400]!),
          ),
          onTap: () => _selectJoiningDate(context),
        ),
      ],
    );
  }
}
