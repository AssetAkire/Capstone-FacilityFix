import 'package:cloud_firestore/cloud_firestore.dart';
import 'database_schema.dart';
import 'enums.dart';

class WorkOrderPermitModel {
  final String id;
  final String userId;
  final String unitId;
  final DateTime dateRequested;
  final String fullName;
  final WorkOrderPermitAccountType accountType;
  final String specificInstructions;
  final WorkOrderPermitStatus status;
  final String? approvedBy;
  final DateTime? approvalDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  WorkOrderPermitModel({
    required this.id,
    required this.userId,
    required this.unitId,
    required this.dateRequested,
    required this.fullName,
    required this.accountType,
    required this.specificInstructions,
    required this.status,
    this.approvedBy,
    this.approvalDate,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isPending => status == WorkOrderPermitStatus.pending;
  bool get isApproved => status == WorkOrderPermitStatus.approved;

  factory WorkOrderPermitModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return WorkOrderPermitModel(
      id: doc.id,
      userId: data[FieldNames.USER_FK] ?? '',
      unitId: data[FieldNames.UNIT_ID] ?? '',
      dateRequested: (data[FieldNames.DATE_REQUESTED] as Timestamp).toDate(),
      fullName: data[FieldNames.FULL_NAME] ?? '',
      accountType: WorkOrderPermitAccountType.values.firstWhere(
        (e) => e.toString().split('.').last == data[FieldNames.ACCOUNT_TYPE],
        orElse: () => WorkOrderPermitAccountType.tenant,
      ),
      specificInstructions: data[FieldNames.SPECIFIC_INSTRUCTIONS] ?? '',
      status: WorkOrderPermitStatus.values.firstWhere(
        (e) => e.toString().split('.').last == data[FieldNames.STATUS],
        orElse: () => WorkOrderPermitStatus.pending,
      ),
      approvedBy: data[FieldNames.APPROVED_BY],
      approvalDate:
          data[FieldNames.APPROVAL_DATE] != null
              ? (data[FieldNames.APPROVAL_DATE] as Timestamp).toDate()
              : null,
      createdAt: (data[FieldNames.CREATED_AT] as Timestamp).toDate(),
      updatedAt: (data[FieldNames.UPDATED_AT] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      FieldNames.USER_FK: userId,
      FieldNames.UNIT_ID: unitId,
      FieldNames.DATE_REQUESTED: Timestamp.fromDate(dateRequested),
      FieldNames.FULL_NAME: fullName,
      FieldNames.ACCOUNT_TYPE: accountType.toString().split('.').last,
      FieldNames.SPECIFIC_INSTRUCTIONS: specificInstructions,
      FieldNames.STATUS: status.toString().split('.').last,
      FieldNames.APPROVED_BY: approvedBy,
      FieldNames.APPROVAL_DATE:
          approvalDate != null ? Timestamp.fromDate(approvalDate!) : null,
      FieldNames.CREATED_AT: Timestamp.fromDate(createdAt),
      FieldNames.UPDATED_AT: Timestamp.fromDate(updatedAt),
    };
  }

  @override
  String toString() {
    return 'WorkOrderPermitModel(id: $id, requester: $fullName, status: $status, pending: $isPending)';
  }
}
