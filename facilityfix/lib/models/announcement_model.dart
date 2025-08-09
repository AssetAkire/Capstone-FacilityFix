import 'package:cloud_firestore/cloud_firestore.dart';
import 'database_schema.dart';
import 'enums.dart';

class AnnouncementModel {
  final String? id;
  final String createdBy;
  final String buildingId;
  final String title;
  final AnnouncementType type;
  final AnnouncementAudience audience;
  final String content;
  final String? locationAffected;
  final bool isActive;
  final DateTime dateAdded;
  final DateTime updatedAt;

  AnnouncementModel({
    required this.id,
    required this.createdBy,
    required this.buildingId,
    required this.title,
    required this.type,
    required this.audience,
    required this.content,
    this.locationAffected,
    required this.isActive,
    required this.dateAdded,
    required this.updatedAt,
  });

  factory AnnouncementModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return AnnouncementModel(
      id: doc.id,
      createdBy: data[FieldNames.CREATED_BY] ?? '',
      buildingId: data[FieldNames.BUILDING_ID] ?? '',
      title: data[FieldNames.TITLE] ?? '',
      type: AnnouncementType.values.firstWhere(
        (e) => e.toString().split('.').last == data[FieldNames.TYPE],
        orElse: () => AnnouncementType.general,
      ),
      audience: AnnouncementAudience.values.firstWhere(
        (e) => e.toString().split('.').last == data[FieldNames.AUDIENCE],
        orElse: () => AnnouncementAudience.all,
      ),
      content: data[FieldNames.CONTENT] ?? '',
      locationAffected: data[FieldNames.LOCATION_AFFECTED],
      isActive: data[FieldNames.IS_ACTIVE] ?? false,
      dateAdded: (data[FieldNames.DATE_ADDED] as Timestamp).toDate(),
      updatedAt: (data[FieldNames.UPDATED_AT] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      FieldNames.CREATED_BY: createdBy,
      FieldNames.BUILDING_ID: buildingId,
      FieldNames.TITLE: title,
      FieldNames.TYPE: type.toString().split('.').last,
      FieldNames.AUDIENCE: audience.toString().split('.').last,
      FieldNames.CONTENT: content,
      FieldNames.LOCATION_AFFECTED: locationAffected,
      FieldNames.IS_ACTIVE: isActive,
      FieldNames.DATE_ADDED: Timestamp.fromDate(dateAdded),
      FieldNames.UPDATED_AT: Timestamp.fromDate(updatedAt),
    };
  }

  @override
  String toString() {
    return 'AnnouncementModel(id: $id, title: $title, type: $type, active: $isActive)';
  }
}
