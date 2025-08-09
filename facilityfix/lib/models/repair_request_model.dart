import 'package:cloud_firestore/cloud_firestore.dart';
import 'database_schema.dart';
import 'enums.dart';

class RepairRequestModel {
  final String id;
  final String reportedBy;
  final String unitId;
  final String? assignedTo;
  final String title;
  final String? description;
  final String location;
  final RepairRequestClassification classification;
  final RepairRequestPriority priority;
  final RepairRequestStatus status;
  final List<String>? attachments;
  final DateTime createdAt;
  final DateTime updatedAt;

  RepairRequestModel({
    required this.id,
    required this.reportedBy,
    required this.unitId,
    this.assignedTo,
    required this.title,
    this.description,
    required this.location,
    required this.classification,
    required this.priority,
    required this.status,
    this.attachments,
    required this.createdAt,
    required this.updatedAt,
  });

  factory RepairRequestModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return RepairRequestModel(
      id: doc.id,
      reportedBy: data[FieldNames.REPORTED_BY] ?? '',
      unitId: data[FieldNames.UNIT_ID] ?? '',
      assignedTo: data[FieldNames.ASSIGNED_TO],
      title: data[FieldNames.TITLE] ?? '',
      description: data[FieldNames.DESCRIPTION],
      location: data[FieldNames.LOCATION] ?? '',
      classification: RepairRequestClassification.values.firstWhere(
        (e) => e.toString().split('.').last == data[FieldNames.CLASSIFICATION],
        orElse: () => RepairRequestClassification.other,
      ),
      priority: RepairRequestPriority.values.firstWhere(
        (e) => e.toString().split('.').last == data[FieldNames.PRIORITY],
        orElse: () => RepairRequestPriority.medium,
      ),
      status: RepairRequestStatus.values.firstWhere(
        (e) => e.toString().split('.').last == data[FieldNames.STATUS],
        orElse: () => RepairRequestStatus.open,
      ),
      attachments: List<String>.from(data[FieldNames.ATTACHMENTS] ?? []),
      createdAt: (data[FieldNames.CREATED_AT] as Timestamp).toDate(),
      updatedAt: (data[FieldNames.UPDATED_AT] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      FieldNames.REPORTED_BY: reportedBy,
      FieldNames.UNIT_ID: unitId,
      FieldNames.ASSIGNED_TO: assignedTo,
      FieldNames.TITLE: title,
      FieldNames.DESCRIPTION: description,
      FieldNames.LOCATION: location,
      FieldNames.CLASSIFICATION: classification.toString().split('.').last,
      FieldNames.PRIORITY: priority.toString().split('.').last,
      FieldNames.STATUS: status.toString().split('.').last,
      FieldNames.ATTACHMENTS: attachments ?? [],
      FieldNames.CREATED_AT: Timestamp.fromDate(createdAt),
      FieldNames.UPDATED_AT: Timestamp.fromDate(updatedAt),
    };
  }

  @override
  String toString() {
    return 'RepairRequestModel(id: $id, title: $title, priority: $priority, status: $status)';
  }
}
