import 'package:cloud_firestore/cloud_firestore.dart';
import 'database_schema.dart';
import 'enums.dart';

class UserModel {
  final String id;
  final String? buildingId;
  final String? unitId;
  final String username;
  final String email;
  final String passwordHash;
  final String firstName;
  final String lastName;
  final String? phoneNumber;
  final UserRole userRole;
  final String? department;
  final UserStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    required this.id,
    this.buildingId,
    this.unitId,
    required this.username,
    required this.email,
    required this.passwordHash,
    required this.firstName,
    required this.lastName,
    this.phoneNumber,
    required this.userRole,
    this.department,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  // Get full name
  String get fullName => '$firstName $lastName';

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      buildingId: data[FieldNames.BUILDING_ID],
      unitId: data[FieldNames.UNIT_ID],
      username: data[FieldNames.USERNAME] ?? '',
      email: data[FieldNames.EMAIL] ?? '',
      passwordHash: data[FieldNames.PASSWORD_HASH] ?? '',
      firstName: data[FieldNames.FIRST_NAME] ?? '',
      lastName: data[FieldNames.LAST_NAME] ?? '',
      phoneNumber: data[FieldNames.PHONE_NUMBER],
      userRole: UserRole.values.firstWhere(
        (e) => e.toString().split('.').last == data[FieldNames.USER_ROLE],
        orElse: () => UserRole.tenant,
      ),
      department: data[FieldNames.DEPARTMENT],
      status: UserStatus.values.firstWhere(
        (e) => e.toString().split('.').last == data[FieldNames.STATUS],
        orElse: () => UserStatus.active,
      ),
      createdAt: (data[FieldNames.CREATED_AT] as Timestamp).toDate(),
      updatedAt: (data[FieldNames.UPDATED_AT] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      FieldNames.BUILDING_ID: buildingId,
      FieldNames.UNIT_ID: unitId,
      FieldNames.USERNAME: username,
      FieldNames.EMAIL: email,
      FieldNames.PASSWORD_HASH: passwordHash,
      FieldNames.FIRST_NAME: firstName,
      FieldNames.LAST_NAME: lastName,
      FieldNames.PHONE_NUMBER: phoneNumber,
      FieldNames.USER_ROLE: userRole.toString().split('.').last,
      FieldNames.DEPARTMENT: department,
      FieldNames.STATUS: status.toString().split('.').last,
      FieldNames.CREATED_AT: Timestamp.fromDate(createdAt),
      FieldNames.UPDATED_AT: Timestamp.fromDate(updatedAt),
    };
  }

  @override
  String toString() {
    return 'UserModel(id: $id, name: $fullName, role: $userRole, email: $email)';
  }
}
