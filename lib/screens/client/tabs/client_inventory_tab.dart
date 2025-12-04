import 'package:flutter/material.dart';

import '../../../models/inventory_item.dart';
import '../../../services/firestore_service.dart';

class ClientInventoryTab extends StatelessWidget {
  final String projectId;
  const ClientInventoryTab({super.key, required this.projectId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<InventoryItem>>(
      stream: FirestoreService().listenInventory(projectId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final items = snapshot.data ?? [];
        final total = items.fold<double>(0, (sum, item) => sum + item.totalCost);
        if (items.isEmpty) {
          return const Center(child: Text('No hay materiales registrados'));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: items.length + 1,
          itemBuilder: (context, index) {
            if (index == items.length) {
              return Card(
                child: ListTile(
                  title: const Text('Total inventario', style: TextStyle(fontWeight: FontWeight.bold)),
                  trailing: Text('MXN ${total.toStringAsFixed(2)}'),
                ),
              );
            }
            final item = items[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                title: Text(item.name),
                subtitle: Text('${item.category} · ${item.quantity} ${item.unit} · MXN ${item.unitCost.toStringAsFixed(2)}'),
                trailing: Text('MXN ${item.totalCost.toStringAsFixed(2)}'),
              ),
            );
          },
        );
      },
    );
  }
}
