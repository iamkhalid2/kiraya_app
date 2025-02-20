import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../setup/test_setup.dart';

// Test widgets
class TenantListItem extends StatelessWidget {
  final String name;
  final String roomNumber;
  final double rentAmount;
  final VoidCallback onTap;

  const TenantListItem({
    Key? key,
    required this.name,
    required this.roomNumber,
    required this.rentAmount,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(name),
      subtitle: Text('Room $roomNumber'),
      trailing: Text('\$${rentAmount.toStringAsFixed(2)}'),
      onTap: onTap,
    );
  }
}

class TenantForm extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController roomController;
  final TextEditingController rentController;
  final VoidCallback onSubmit;

  const TenantForm({
    Key? key,
    required this.nameController,
    required this.roomController,
    required this.rentController,
    required this.onSubmit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: nameController,
          decoration: const InputDecoration(labelText: 'Name'),
        ),
        TextField(
          controller: roomController,
          decoration: const InputDecoration(labelText: 'Room Number'),
        ),
        TextField(
          controller: rentController,
          decoration: const InputDecoration(labelText: 'Rent Amount'),
          keyboardType: TextInputType.number,
        ),
        ElevatedButton(
          onPressed: onSubmit,
          child: const Text('Submit'),
        ),
      ],
    );
  }
}

class PaymentForm extends StatelessWidget {
  final TextEditingController amountController;
  final String selectedMethod;
  final ValueChanged<String?> onMethodChanged;
  final VoidCallback onSubmit;

  const PaymentForm({
    Key? key,
    required this.amountController,
    required this.selectedMethod,
    required this.onMethodChanged,
    required this.onSubmit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: amountController,
          decoration: const InputDecoration(labelText: 'Amount'),
          keyboardType: TextInputType.number,
        ),
        DropdownButton<String>(
          value: selectedMethod,
          items: const [
            DropdownMenuItem(value: 'cash', child: Text('Cash')),
            DropdownMenuItem(value: 'bank_transfer', child: Text('Bank Transfer')),
            DropdownMenuItem(value: 'online', child: Text('Online')),
          ],
          onChanged: onMethodChanged,
        ),
        ElevatedButton(
          onPressed: onSubmit,
          child: const Text('Submit Payment'),
        ),
      ],
    );
  }
}

void main() {
  group('Tenant Widgets Tests', () {
    testWidgets('should render tenant list item', (WidgetTester tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        TestSetup.wrapWithMaterialApp(
          TenantListItem(
            name: 'John Doe',
            roomNumber: '101',
            rentAmount: 1000,
            onTap: () => tapped = true,
          ),
        ),
      );

      expect(find.text('John Doe'), findsOneWidget);
      expect(find.text('Room 101'), findsOneWidget);
      expect(find.text('\$1000.00'), findsOneWidget);

      await tester.tap(find.byType(ListTile));
      expect(tapped, isTrue);
    });

    testWidgets('should handle tenant form input', (WidgetTester tester) async {
      final nameController = TextEditingController();
      final roomController = TextEditingController();
      final rentController = TextEditingController();
      bool submitted = false;

      await tester.pumpWidget(
        TestSetup.wrapWithMaterialApp(
          TenantForm(
            nameController: nameController,
            roomController: roomController,
            rentController: rentController,
            onSubmit: () => submitted = true,
          ),
        ),
      );

      await tester.enterText(find.widgetWithText(TextField, 'Name'), 'Jane Smith');
      await tester.enterText(find.widgetWithText(TextField, 'Room Number'), '102');
      await tester.enterText(find.widgetWithText(TextField, 'Rent Amount'), '1200');

      expect(nameController.text, equals('Jane Smith'));
      expect(roomController.text, equals('102'));
      expect(rentController.text, equals('1200'));

      await tester.tap(find.byType(ElevatedButton));
      expect(submitted, isTrue);
    });

    testWidgets('should handle payment form input', (WidgetTester tester) async {
      final amountController = TextEditingController();
      String selectedMethod = 'cash';
      bool submitted = false;

      await tester.pumpWidget(
        TestSetup.wrapWithMaterialApp(
          PaymentForm(
            amountController: amountController,
            selectedMethod: selectedMethod,
            onMethodChanged: (value) => selectedMethod = value ?? selectedMethod,
            onSubmit: () => submitted = true,
          ),
        ),
      );

      await tester.enterText(find.widgetWithText(TextField, 'Amount'), '1000');
      expect(amountController.text, equals('1000'));

      await tester.tap(find.byType(DropdownButton<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Bank Transfer').last);
      await tester.pumpAndSettle();

      expect(selectedMethod, equals('bank_transfer'));

      await tester.tap(find.text('Submit Payment'));
      expect(submitted, isTrue);
    });
  });
}