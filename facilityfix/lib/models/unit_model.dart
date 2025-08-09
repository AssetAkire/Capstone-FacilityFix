import 'package:cloud_firestore/cloud_firestore.dart';
import 'database_schema.dart';
import 'enums.dart';

class UnitModel {
  final String? id;
  final String buildingId;
  final String unitNumber;
  final int floorNumber;
  final OccupancyStatus occupancyStatus;
  final DateTime createdAt;

  UnitModel({
    required this.id,
    required this.buildingId,
    required this.unitNumber,
    required this.floorNumber,
    required this.occupancyStatus,
    required this.createdAt,
  });

  factory UnitModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UnitModel(
      id: doc.id,
      buildingId: data[FieldNames.BUILDING_ID] ?? '',
      unitNumber: data[FieldNames.UNIT_NUMBER] ?? '',
      floorNumber: data[FieldNames.FLOOR_NUMBER] ?? 0,
      occupancyStatus: OccupancyStatus.values.firstWhere(
        (e) =>
            e.toString().split('.').last == data[FieldNames.OCCUPANCY_STATUS],
        orElse: () => OccupancyStatus.vacant,
      ),
      createdAt: (data[FieldNames.CREATED_AT] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      FieldNames.BUILDING_ID: buildingId,
      FieldNames.UNIT_NUMBER: unitNumber,
      FieldNames.FLOOR_NUMBER: floorNumber,
      FieldNames.OCCUPANCY_STATUS: occupancyStatus.toString().split('.').last,
      FieldNames.CREATED_AT: Timestamp.fromDate(createdAt),
    };
  }

  @override
  String toString() {
    return 'UnitModel(id: $id, unitNumber: $unitNumber, floor: $floorNumber, status: $occupancyStatus)';
  }
}
