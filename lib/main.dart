import 'package:flutter/material.dart';

void main() {
  runApp(const RentManagementApp());
}

class RentManagementApp extends StatelessWidget {
  const RentManagementApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rent Management',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rent Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // Add new tenant logic
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // Filter tenants logic
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: 10, // Replace with actual tenant count
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: const CircleAvatar(
                child: Icon(Icons.person),
              ),
              title: Text('Tenant ${index + 1}'),
              subtitle: Text('Room ${index + 101}'),
              trailing: Chip(
                label: const Text('Paid'),
                backgroundColor: Colors.green.shade100,
              ),
              onTap: () {
                // Navigate to tenant details
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add new tenant logic
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}