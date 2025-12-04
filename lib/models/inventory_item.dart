class InventoryItem {
  final String id;
  final String name;
  final String unit;
  final double quantity;
  final double unitCost;
  final DateTime updatedAt;

  const InventoryItem({
    required this.id,
    required this.name,
    required this.unit,
    required this.quantity,
    required this.unitCost,
    required this.updatedAt,
  });

  double get totalCost => unitCost * quantity;

  factory InventoryItem.fromMap(String id, Map<String, dynamic> data) {
    return InventoryItem(
      id: id,
      name: data['name'] ?? '',
      unit: data['unit'] ?? '',
      quantity: (data['quantity'] ?? 0).toDouble(),
      unitCost: (data['unitCost'] ?? 0).toDouble(),
      updatedAt: (data['updatedAt'] as DateTime?) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'unit': unit,
      'quantity': quantity,
      'unitCost': unitCost,
      'updatedAt': updatedAt,
      'totalCost': totalCost,
    };
  }
}
