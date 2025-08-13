import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/building_model.dart';
import '../models/unit_model.dart';
import '../models/user_model.dart';
import '../models/equipment_model.dart';
import '../models/inventory_model.dart';
import '../models/repair_request_model.dart';
import '../models/maintenance_task_model.dart';
import '../models/announcement_model.dart';
import '../models/work_order_permit_model.dart';
import '../models/database_schema.dart';
import '../models/enums.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Singleton pattern
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  // Collection references
  CollectionReference get buildingsCollection =>
      _firestore.collection(DatabaseSchema.BUILDINGS);
  CollectionReference get unitsCollection =>
      _firestore.collection(DatabaseSchema.UNITS);
  CollectionReference get usersCollection =>
      _firestore.collection(DatabaseSchema.USERS);
  CollectionReference get equipmentCollection =>
      _firestore.collection(DatabaseSchema.EQUIPMENT);
  CollectionReference get inventoryCollection =>
      _firestore.collection(DatabaseSchema.INVENTORY);
  CollectionReference get repairRequestsCollection =>
      _firestore.collection(DatabaseSchema.REPAIR_REQUESTS);
  CollectionReference get maintenanceTasksCollection =>
      _firestore.collection(DatabaseSchema.MAINTENANCE_TASKS);
  CollectionReference get announcementsCollection =>
      _firestore.collection(DatabaseSchema.ANNOUNCEMENTS);
  CollectionReference get workOrderPermitsCollection =>
      _firestore.collection(DatabaseSchema.WORK_ORDER_PERMITS);

  // --- Building Operations ---
  Future<void> createBuilding(BuildingModel building) async {
    await buildingsCollection.doc(building.id).set(building.toFirestore());
  }

  Future<BuildingModel?> getBuilding(String buildingId) async {
    DocumentSnapshot doc = await buildingsCollection.doc(buildingId).get();
    return doc.exists ? BuildingModel.fromFirestore(doc) : null;
  }

  Stream<List<BuildingModel>> getBuildingsStream() {
    return buildingsCollection.snapshots().map(
      (snapshot) =>
          snapshot.docs.map((doc) => BuildingModel.fromFirestore(doc)).toList(),
    );
  }

  // --- Unit Operations ---
  Future<void> createUnit(UnitModel unit) async {
    await unitsCollection.doc(unit.id).set(unit.toFirestore());
  }

  Future<UnitModel?> getUnit(String unitId) async {
    DocumentSnapshot doc = await unitsCollection.doc(unitId).get();
    return doc.exists ? UnitModel.fromFirestore(doc) : null;
  }

  Stream<List<UnitModel>> getUnitsStream({String? buildingId}) {
    Query query = unitsCollection.orderBy(FieldNames.UNIT_NUMBER);
    if (buildingId != null) {
      query = query.where(FieldNames.BUILDING_ID, isEqualTo: buildingId);
    }
    return query.snapshots().map(
      (snapshot) =>
          snapshot.docs.map((doc) => UnitModel.fromFirestore(doc)).toList(),
    );
  }

  // --- User Operations ---
  Future<void> createUser(UserModel user) async {
    await usersCollection.doc(user.id).set(user.toFirestore());
  }

  Future<UserModel?> getUser(String userId) async {
    DocumentSnapshot doc = await usersCollection.doc(userId).get();
    return doc.exists ? UserModel.fromFirestore(doc) : null;
  }

  Stream<List<UserModel>> getUsersStream({UserRole? role, String? buildingId}) {
    Query query = usersCollection.orderBy(FieldNames.FIRST_NAME);
    if (role != null) {
      query = query.where(
        FieldNames.USER_ROLE,
        isEqualTo: role.toString().split('.').last,
      );
    }
    if (buildingId != null) {
      query = query.where(FieldNames.BUILDING_ID, isEqualTo: buildingId);
    }
    return query.snapshots().map(
      (snapshot) =>
          snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList(),
    );
  }

  Future<void> updateUser(String userId, Map<String, dynamic> data) async {
    data[FieldNames.UPDATED_AT] = FieldValue.serverTimestamp();
    await usersCollection.doc(userId).update(data);
  }

  // --- Equipment Operations ---
  Future<void> createEquipment(EquipmentModel equipment) async {
    await equipmentCollection.doc(equipment.id).set(equipment.toFirestore());
  }

  Future<EquipmentModel?> getEquipment(String equipmentId) async {
    DocumentSnapshot doc = await equipmentCollection.doc(equipmentId).get();
    return doc.exists ? EquipmentModel.fromFirestore(doc) : null;
  }

  Stream<List<EquipmentModel>> getEquipmentStream({
    String? buildingId,
    String? type,
    bool? isCritical,
  }) {
    Query query = equipmentCollection.orderBy(FieldNames.EQUIPMENT_NAME);
    if (buildingId != null) {
      query = query.where(FieldNames.BUILDING_ID, isEqualTo: buildingId);
    }
    if (type != null) {
      query = query.where(FieldNames.EQUIPMENT_TYPE, isEqualTo: type);
    }
    if (isCritical != null) {
      query = query.where(FieldNames.IS_CRITICAL, isEqualTo: isCritical);
    }
    return query.snapshots().map(
      (snapshot) =>
          snapshot.docs
              .map((doc) => EquipmentModel.fromFirestore(doc))
              .toList(),
    );
  }

  Future<void> updateEquipment(
    String equipmentId,
    Map<String, dynamic> data,
  ) async {
    data[FieldNames.UPDATED_AT] = FieldValue.serverTimestamp();
    await equipmentCollection.doc(equipmentId).update(data);
  }

  // --- Inventory Operations ---
  Future<void> createInventoryItem(InventoryModel item) async {
    await inventoryCollection.doc(item.id).set(item.toFirestore());
  }

  Future<InventoryModel?> getInventoryItem(String itemId) async {
    DocumentSnapshot doc = await inventoryCollection.doc(itemId).get();
    return doc.exists ? InventoryModel.fromFirestore(doc) : null;
  }

  Stream<List<InventoryModel>> getInventoryStream({
    String? buildingId,
    bool? lowStockOnly,
  }) {
    Query query = inventoryCollection.orderBy(FieldNames.ITEM_NAME);
    if (buildingId != null) {
      query = query.where(FieldNames.BUILDING_ID, isEqualTo: buildingId);
    }
    return query.snapshots().map((snapshot) {
      List<InventoryModel> items =
          snapshot.docs
              .map((doc) => InventoryModel.fromFirestore(doc))
              .toList();
      if (lowStockOnly == true) {
        items = items.where((item) => item.isLowStock).toList();
      }
      return items;
    });
  }

  Future<void> updateInventoryItem(
    String itemId,
    Map<String, dynamic> data,
  ) async {
    data[FieldNames.UPDATED_AT] = FieldValue.serverTimestamp();
    await inventoryCollection.doc(itemId).update(data);
  }

  // --- Repair Request Operations ---
  Future<String> createRepairRequest(RepairRequestModel request) async {
    DocumentReference docRef = await repairRequestsCollection.add(
      request.toFirestore(),
    );
    return docRef.id;
  }

  Future<RepairRequestModel?> getRepairRequest(String requestId) async {
    DocumentSnapshot doc = await repairRequestsCollection.doc(requestId).get();
    return doc.exists ? RepairRequestModel.fromFirestore(doc) : null;
  }

  Stream<List<RepairRequestModel>> getRepairRequestsStream({
    String? unitId,
    String? reportedBy,
    String? assignedTo,
    RepairRequestStatus? status,
    RepairRequestPriority? priority,
    int limit = 50,
  }) {
    Query query = repairRequestsCollection.orderBy(
      FieldNames.CREATED_AT,
      descending: true,
    );

    if (unitId != null) {
      query = query.where(FieldNames.UNIT_ID, isEqualTo: unitId);
    }
    if (reportedBy != null) {
      query = query.where(FieldNames.REPORTED_BY, isEqualTo: reportedBy);
    }
    if (assignedTo != null) {
      query = query.where(FieldNames.ASSIGNED_TO, isEqualTo: assignedTo);
    }
    if (status != null) {
      query = query.where(
        FieldNames.STATUS,
        isEqualTo: status.toString().split('.').last,
      );
    }
    if (priority != null) {
      query = query.where(
        FieldNames.PRIORITY,
        isEqualTo: priority.toString().split('.').last,
      );
    }

    query = query.limit(limit);

    return query.snapshots().map(
      (snapshot) =>
          snapshot.docs
              .map((doc) => RepairRequestModel.fromFirestore(doc))
              .toList(),
    );
  }

  Future<void> updateRepairRequest(
    String requestId,
    Map<String, dynamic> data,
  ) async {
    await repairRequestsCollection.doc(requestId).update(data);
  }

  // --- Maintenance Task Operations ---
  Future<String> createMaintenanceTask(MaintenanceTaskModel task) async {
    DocumentReference docRef = await maintenanceTasksCollection.add(
      task.toFirestore(),
    );
    return docRef.id;
  }

  Future<MaintenanceTaskModel?> getMaintenanceTask(String taskId) async {
    DocumentSnapshot doc = await maintenanceTasksCollection.doc(taskId).get();
    return doc.exists ? MaintenanceTaskModel.fromFirestore(doc) : null;
  }

  Stream<List<MaintenanceTaskModel>> getMaintenanceTasksStream({
    String? equipmentId,
    String? assignedTo,
    MaintenanceTaskStatus? status,
    bool? overdueOnly,
    int limit = 50,
  }) {
    Query query = maintenanceTasksCollection.orderBy(FieldNames.SCHEDULED_DATE);

    if (equipmentId != null) {
      query = query.where(FieldNames.EQUIPMENT_FK, isEqualTo: equipmentId);
    }
    if (assignedTo != null) {
      query = query.where(FieldNames.ASSIGNED_TO, isEqualTo: assignedTo);
    }
    if (status != null) {
      query = query.where(
        FieldNames.STATUS,
        isEqualTo: status.toString().split('.').last,
      );
    }

    query = query.limit(limit);

    return query.snapshots().map((snapshot) {
      List<MaintenanceTaskModel> tasks =
          snapshot.docs
              .map((doc) => MaintenanceTaskModel.fromFirestore(doc))
              .toList();
      if (overdueOnly == true) {
        tasks = tasks.where((task) => task.isOverdue).toList();
      }
      return tasks;
    });
  }

  Future<void> updateMaintenanceTask(
    String taskId,
    Map<String, dynamic> data,
  ) async {
    await maintenanceTasksCollection.doc(taskId).update(data);
  }

  // --- Announcement Operations ---
  Future<String> createAnnouncement(AnnouncementModel announcement) async {
    DocumentReference docRef = await announcementsCollection.add(
      announcement.toFirestore(),
    );
    return docRef.id;
  }

  Future<AnnouncementModel?> getAnnouncement(String announcementId) async {
    DocumentSnapshot doc =
        await announcementsCollection.doc(announcementId).get();
    return doc.exists ? AnnouncementModel.fromFirestore(doc) : null;
  }

  Stream<List<AnnouncementModel>> getAnnouncementsStream({
    String? buildingId,
    AnnouncementAudience? audience,
    bool? activeOnly,
    int limit = 20,
  }) {
    Query query = announcementsCollection.orderBy(
      FieldNames.DATE_ADDED,
      descending: true,
    );

    if (buildingId != null) {
      query = query.where(FieldNames.BUILDING_ID, isEqualTo: buildingId);
    }
    if (audience != null) {
      query = query.where(
        FieldNames.AUDIENCE,
        isEqualTo: audience.toString().split('.').last,
      );
    }
    if (activeOnly == true) {
      query = query.where(FieldNames.IS_ACTIVE, isEqualTo: true);
    }

    query = query.limit(limit);

    return query.snapshots().map(
      (snapshot) =>
          snapshot.docs
              .map((doc) => AnnouncementModel.fromFirestore(doc))
              .toList(),
    );
  }

  Future<void> updateAnnouncement(
    String announcementId,
    Map<String, dynamic> data,
  ) async {
    data[FieldNames.UPDATED_AT] = FieldValue.serverTimestamp();
    await announcementsCollection.doc(announcementId).update(data);
  }

  // --- Work Order Permit Operations ---
  Future<String> createWorkOrderPermit(WorkOrderPermitModel permit) async {
    DocumentReference docRef = await workOrderPermitsCollection.add(
      permit.toFirestore(),
    );
    return docRef.id;
  }

  Future<WorkOrderPermitModel?> getWorkOrderPermit(String permitId) async {
    DocumentSnapshot doc = await workOrderPermitsCollection.doc(permitId).get();
    return doc.exists ? WorkOrderPermitModel.fromFirestore(doc) : null;
  }

  Stream<List<WorkOrderPermitModel>> getWorkOrderPermitsStream({
    String? userId,
    String? unitId,
    WorkOrderPermitStatus? status,
    bool? pendingOnly,
    int limit = 50,
  }) {
    Query query = workOrderPermitsCollection.orderBy(
      FieldNames.DATE_REQUESTED,
      descending: true,
    );

    if (userId != null) {
      query = query.where(FieldNames.USER_FK, isEqualTo: userId);
    }
    if (unitId != null) {
      query = query.where(FieldNames.UNIT_ID, isEqualTo: unitId);
    }
    if (status != null) {
      query = query.where(
        FieldNames.STATUS,
        isEqualTo: status.toString().split('.').last,
      );
    }

    query = query.limit(limit);

    return query.snapshots().map((snapshot) {
      List<WorkOrderPermitModel> permits =
          snapshot.docs
              .map((doc) => WorkOrderPermitModel.fromFirestore(doc))
              .toList();
      if (pendingOnly == true) {
        permits = permits.where((permit) => permit.isPending).toList();
      }
      return permits;
    });
  }

  Future<void> updateWorkOrderPermit(
    String permitId,
    Map<String, dynamic> data,
  ) async {
    await workOrderPermitsCollection.doc(permitId).update(data);
  }

  // --- Batch Operations ---
  Future<void> batchWrite(List<Map<String, dynamic>> operations) async {
    WriteBatch batch = _firestore.batch();

    for (var operation in operations) {
      DocumentReference docRef = operation['docRef'];
      Map<String, dynamic> data = operation['data'];
      String operationType = operation['type'];

      switch (operationType) {
        case 'set':
          batch.set(docRef, data);
          break;
        case 'update':
          batch.update(docRef, data);
          break;
        case 'delete':
          batch.delete(docRef);
          break;
      }
    }
    await batch.commit();
  }

  // --- Analytics and Reporting ---
  Future<Map<String, int>> getDashboardCounts({String? buildingId}) async {
    Map<String, int> counts = {};

    // Count repair requests by status
    QuerySnapshot openRequests =
        await repairRequestsCollection
            .where(FieldNames.STATUS, isEqualTo: 'open')
            .get();
    counts['openRequests'] = openRequests.docs.length;

    QuerySnapshot inProgressRequests =
        await repairRequestsCollection
            .where(FieldNames.STATUS, isEqualTo: 'inProgress')
            .get();
    counts['inProgressRequests'] = inProgressRequests.docs.length;

    // Count maintenance tasks
    QuerySnapshot scheduledTasks =
        await maintenanceTasksCollection
            .where(FieldNames.STATUS, isEqualTo: 'scheduled')
            .get();
    counts['scheduledTasks'] = scheduledTasks.docs.length;

    // Count low stock items
    QuerySnapshot allInventory = await inventoryCollection.get();
    int lowStockCount = 0;
    for (var doc in allInventory.docs) {
      InventoryModel item = InventoryModel.fromFirestore(doc);
      if (item.isLowStock) lowStockCount++;
    }
    counts['lowStockItems'] = lowStockCount;

    // Count pending permits
    QuerySnapshot pendingPermits =
        await workOrderPermitsCollection
            .where(FieldNames.STATUS, isEqualTo: 'pending')
            .get();
    counts['pendingPermits'] = pendingPermits.docs.length;

    return counts;
  }
}
