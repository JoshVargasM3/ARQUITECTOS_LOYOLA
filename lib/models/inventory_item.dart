import 'package:cloud_firestore/cloud_firestore.dart';

class InventoryItem {
  final String id;
  final String name;
  final String category;
  final String unit;
  final double quantity;
  final double unitCost;
  final double totalCost;
  final DateTime updatedAt;

  const InventoryItem({
    required this.id,
    required this.name,
    required this.category,
    required this.unit,
    required this.quantity,
    required this.unitCost,
    required this.totalCost,
    required this.updatedAt,
  });

  factory InventoryItem.fromMap(String id, Map<String, dynamic> data) {
    DateTime? _toDate(dynamic value) {
      if (value == null) return null;
      if (value is DateTime) return value;
      return (value as Timestamp?)?.toDate();
    }

    return InventoryItem(
      id: id,
      name: data['name'] ?? '',
      category: data['category'] ?? '',
      unit: data['unit'] ?? '',
      quantity: (data['quantity'] ?? 0).toDouble(),
      unitCost: (data['unitCost'] ?? 0).toDouble(),
      totalCost: (data['totalCost'] ?? 0).toDouble(),
      updatedAt: _toDate(data['updatedAt']) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    final calculatedTotal = quantity * unitCost;
    return {
      'name': name,
      'category': category,
      'unit': unit,
      'quantity': quantity,
      'unitCost': unitCost,
      'totalCost': calculatedTotal,
      'updatedAt': updatedAt,
    };
  }
}
