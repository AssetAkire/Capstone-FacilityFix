import 'package:cloud_firestore/cloud_firestore.dart';
import 'database_schema.dart';
import 'enums.dart';

class MaintenanceTaskModel {
  final String id;
  final String? equipmentId;
  final String? assignedTo;
  final String location;
  final String issueDescription;
  final MaintenanceTaskStatus status;
  final DateTime scheduledDate;
  final RecurrenceType recurrenceType;
  final DateTime createdAt;
  final DateTime updatedAt;

  MaintenanceTaskModel({
    required this.id,
    this.equipmentId,
    this.assignedTo,
    required this.location,
    required this.issueDescription,
    required this.status,
    required this.scheduledDate,
    required this.recurrenceType,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isOverdue =>
      DateTime.now().isAfter(scheduledDate) &&
      status == MaintenanceTaskStatus.scheduled;

  factory MaintenanceTaskModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return MaintenanceTaskModel(
      id: doc.id,
      equipmentId: data[FieldNames.EQUIPMENT_FK],
      assignedTo: data[FieldNames.ASSIGNED_TO],
      location: data[FieldNames.LOCATION] ?? '',
      issueDescription: data[FieldNames.ISSUE_DESCRIPTION] ?? '',
      status: MaintenanceTaskStatus.values.firstWhere(
        (e) => e.toString().split('.').last == data[FieldNames.STATUS],
        orElse: () => MaintenanceTaskStatus.scheduled,
      ),
      scheduledDate: (data[FieldNames.SCHEDULED_DATE] as Timestamp).toDate(),
      recurrenceType: RecurrenceType.values.firstWhere(
        (e) => e.toString().split('.').last == data[FieldNames.RECURRENCE_TYPE],
        orElse: () => RecurrenceType.none,
      ),
      createdAt: (data[FieldNames.CREATED_AT] as Timestamp).toDate(),
      updatedAt: (data[FieldNames.UPDATED_AT] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      FieldNames.EQUIPMENT_FK: equipmentId,
      FieldNames.ASSIGNED_TO: assignedTo,
      FieldNames.LOCATION: location,
      FieldNames.ISSUE_DESCRIPTION: issueDescription,
      FieldNames.STATUS: status.toString().split('.').last,
      FieldNames.SCHEDULED_DATE: Timestamp.fromDate(scheduledDate),
      FieldNames.RECURRENCE_TYPE: recurrenceType.toString().split('.').last,
      FieldNames.CREATED_AT: Timestamp.fromDate(createdAt),
      FieldNames.UPDATED_AT: Timestamp.fromDate(updatedAt),
    };
  }

  @override
  String toString() {
    return 'MaintenanceTaskModel(id: $id, description: $issueDescription, status: $status, overdue: $isOverdue)';
  }
}
