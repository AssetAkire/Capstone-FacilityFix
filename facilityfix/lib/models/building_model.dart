import 'package:cloud_firestore/cloud_firestore.dart';
import 'database_schema.dart';

class BuildingModel {
  final String? id;
  final String buildingName;
  final String address;
  final int totalFloors;
  final int totalUnits;
  final DateTime createdAt;

  BuildingModel({
    required this.id,
    required this.buildingName,
    required this.address,
    required this.totalFloors,
    required this.totalUnits,
    required this.createdAt,
  });

  factory BuildingModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return BuildingModel(
      id: doc.id,
      buildingName: data[FieldNames.BUILDING_NAME] ?? '',
      address: data[FieldNames.ADDRESS] ?? '',
      totalFloors: data[FieldNames.TOTAL_FLOORS] ?? 0,
      totalUnits: data[FieldNames.TOTAL_UNITS] ?? 0,
      createdAt: (data[FieldNames.CREATED_AT] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      FieldNames.BUILDING_NAME: buildingName,
      FieldNames.ADDRESS: address,
      FieldNames.TOTAL_FLOORS: totalFloors,
      FieldNames.TOTAL_UNITS: totalUnits,
      FieldNames.CREATED_AT: Timestamp.fromDate(createdAt),
    };
  }

  @override
  String toString() {
    return 'BuildingModel(id: $id, name: $buildingName, address: $address, floors: $totalFloors, units: $totalUnits)';
  }
}
