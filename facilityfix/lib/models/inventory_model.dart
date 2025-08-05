import 'package:cloud_firestore/cloud_firestore.dart';
import 'database_schema.dart';

class InventoryModel {
  final String id;
  final String buildingId;
  final String itemName;
  final String department;
  final String classification;
  final int currentStock;
  final int reorderLevel;
  final String unitOfMeasure;
  final DateTime dateAdded;
  final DateTime updatedAt;

  InventoryModel({
    required this.id,
    required this.buildingId,
    required this.itemName,
    required this.department,
    required this.classification,
    required this.currentStock,
    required this.reorderLevel,
    required this.unitOfMeasure,
    required this.dateAdded,
    required this.updatedAt,
  });

  bool get isLowStock => currentStock <= reorderLevel;

  factory InventoryModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return InventoryModel(
      id: doc.id,
      buildingId: data[FieldNames.BUILDING_ID] ?? '',
      itemName: data[FieldNames.ITEM_NAME] ?? '',
      department: data[FieldNames.DEPARTMENT] ?? '',
      classification: data[FieldNames.CLASSIFICATION] ?? '',
      currentStock: data[FieldNames.CURRENT_STOCK] ?? 0,
      reorderLevel: data[FieldNames.REORDER_LEVEL] ?? 0,
      unitOfMeasure: data[FieldNames.UNIT_OF_MEASURE] ?? '',
      dateAdded: (data[FieldNames.DATE_ADDED] as Timestamp).toDate(),
      updatedAt: (data[FieldNames.UPDATED_AT] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      FieldNames.BUILDING_ID: buildingId,
      FieldNames.ITEM_NAME: itemName,
      FieldNames.DEPARTMENT: department,
      FieldNames.CLASSIFICATION: classification,
      FieldNames.CURRENT_STOCK: currentStock,
      FieldNames.REORDER_LEVEL: reorderLevel,
      FieldNames.UNIT_OF_MEASURE: unitOfMeasure,
      FieldNames.DATE_ADDED: Timestamp.fromDate(dateAdded),
      FieldNames.UPDATED_AT: Timestamp.fromDate(updatedAt),
    };
  }

  @override
  String toString() {
    return 'InventoryModel(id: $id, item: $itemName, stock: $currentStock/$reorderLevel, lowStock: $isLowStock)';
  }
}
