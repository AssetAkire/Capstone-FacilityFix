import 'package:cloud_firestore/cloud_firestore.dart';
import 'database_schema.dart';
import 'enums.dart';

class EquipmentModel {
  final String id;
  final String buildingId;
  final String equipmentName;
  final String equipmentType;
  final String modelNumber;
  final String serialNumber;
  final String location;
  final String? department;
  final EquipmentStatus status;
  final bool isCritical;
  final DateTime dateAdded;
  final DateTime updatedAt;

  EquipmentModel({
    required this.id,
    required this.buildingId,
    required this.equipmentName,
    required this.equipmentType,
    required this.modelNumber,
    required this.serialNumber,
    required this.location,
    required this.department,
    required this.status,
    required this.isCritical,
    required this.dateAdded,
    required this.updatedAt,
  });

  factory EquipmentModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return EquipmentModel(
      id: doc.id,
      buildingId: data[FieldNames.BUILDING_ID] ?? '',
      equipmentName: data[FieldNames.EQUIPMENT_NAME] ?? '',
      equipmentType: data[FieldNames.EQUIPMENT_TYPE] ?? '',
      modelNumber: data[FieldNames.MODEL_NUMBER] ?? '',
      serialNumber: data[FieldNames.SERIAL_NUMBER] ?? '',
      location: data[FieldNames.LOCATION] ?? '',
      department: data[FieldNames.DEPARTMENT] ?? '',
      status: EquipmentStatus.values.firstWhere(
        (e) => e.toString().split('.').last == data[FieldNames.STATUS],
        orElse: () => EquipmentStatus.active,
      ),
      isCritical: data[FieldNames.IS_CRITICAL] ?? false,
      dateAdded: (data[FieldNames.DATE_ADDED] as Timestamp).toDate(),
      updatedAt: (data[FieldNames.UPDATED_AT] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      FieldNames.BUILDING_ID: buildingId,
      FieldNames.EQUIPMENT_NAME: equipmentName,
      FieldNames.EQUIPMENT_TYPE: equipmentType,
      FieldNames.MODEL_NUMBER: modelNumber,
      FieldNames.SERIAL_NUMBER: serialNumber,
      FieldNames.LOCATION: location,
      FieldNames.DEPARTMENT: department,
      FieldNames.STATUS: status.toString().split('.').last,
      FieldNames.IS_CRITICAL: isCritical,
      FieldNames.DATE_ADDED: Timestamp.fromDate(dateAdded),
      FieldNames.UPDATED_AT: Timestamp.fromDate(updatedAt),
    };
  }

  @override
  String toString() {
    return 'EquipmentModel(id: $id, name: $equipmentName, type: $equipmentType, critical: $isCritical)';
  }
}
