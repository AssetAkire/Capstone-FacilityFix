import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/building_model.dart';
import '../models/unit_model.dart';
import '../models/user_model.dart';
import '../models/equipment_model.dart';
import '../models/inventory_model.dart';
import '../models/repair_request_model.dart';
import '../models/maintenance_task_model.dart';
import '../models/announcement_model.dart';
import '../models/work_order_permit_model.dart';
import '../models/enums.dart';
import 'database_service.dart';

class DatabaseSeeder {
  final DatabaseService _databaseService = DatabaseService();

  Future<void> seedDatabase() async {
    try {
      print('🌱 Starting FacilityFix database seeding...');

      // First, create the current user's profile if it doesn't exist
      await _createCurrentUserProfile();

      // Create test building
      await _createTestBuilding();

      // Create test units
      await _createTestUnits();

      // Create test users
      await _createTestUsers();

      // Create test equipment
      await _createTestEquipment();

      // Create test inventory
      await _createTestInventory();

      // Create test repair requests
      await _createTestRepairRequests();

      // Create test maintenance tasks
      await _createTestMaintenanceTasks();

      // Create test announcements
      await _createTestAnnouncements();

      // Create test work order permits
      await _createTestWorkOrderPermits();

      print('✅ FacilityFix database seeding completed successfully!');
    } catch (e) {
      print('❌ Error seeding database: $e');
      rethrow;
    }
  }

  Future<void> _createCurrentUserProfile() async {
    try {
      // Get current Firebase user
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('No authenticated user found');
      }

      // Check if user profile already exists
      final userDoc =
          await _databaseService.usersCollection.doc(currentUser.uid).get();

      if (!userDoc.exists) {
        // Create user profile for the current authenticated user
        UserModel currentUserProfile = UserModel(
          id: currentUser.uid,
          username: currentUser.email?.split('@')[0] ?? 'admin',
          email: currentUser.email ?? 'admin@facilityfix.com',
          passwordHash: 'firebase_auth_managed',
          firstName: 'Admin',
          lastName: 'User',
          phoneNumber: '+63-917-000-0000',
          userRole: UserRole.admin,
          department: 'System Administration',
          status: UserStatus.active,
          buildingId: 'building_001',
          unitId: null,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await _databaseService.createUser(currentUserProfile);
        print(
          '👤 Created current user profile: ${currentUserProfile.fullName}',
        );
      } else {
        print('👤 Current user profile already exists');
      }
    } catch (e) {
      print('❌ Error creating current user profile: $e');
      rethrow;
    }
  }

  Future<void> _createTestBuilding() async {
    BuildingModel building = BuildingModel(
      id: 'building_001',
      buildingName: 'Sunset Condominium',
      address: '123 Sunset Boulevard, Manila, Philippines',
      totalFloors: 15,
      totalUnits: 150,
      createdAt: DateTime.now().subtract(Duration(days: 365)),
    );
    await _databaseService.createBuilding(building);
    print('🏢 Created test building: ${building.buildingName}');
  }

  Future<void> _createTestUnits() async {
    List<UnitModel> testUnits = [
      UnitModel(
        id: 'unit_101',
        buildingId: 'building_001',
        unitNumber: '101',
        floorNumber: 1,
        occupancyStatus: OccupancyStatus.occupied,
        createdAt: DateTime.now().subtract(Duration(days: 300)),
      ),
    ];

    for (UnitModel unit in testUnits) {
      await _databaseService.createUnit(unit);
      print(
        '🏠 Created test unit: ${unit.unitNumber} (${unit.occupancyStatus.name})',
      );
    }
  }

  Future<void> _createTestUsers() async {
    List<UserModel> testUsers = [
      // Admin user
      UserModel(
        id: 'admin_001',
        username: 'admin_maria',
        email: 'admin@facilityfix.com',
        passwordHash: 'hashed_password_admin',
        firstName: 'Maria',
        lastName: 'Santos',
        phoneNumber: '+63-917-123-4567',
        userRole: UserRole.admin,
        department: 'Property Management',
        status: UserStatus.active,
        buildingId: 'building_001',
        unitId: null,
        createdAt: DateTime.now().subtract(Duration(days: 365)),
        updatedAt: DateTime.now().subtract(Duration(days: 1)),
      ),
    ];

    for (UserModel user in testUsers) {
      await _databaseService.createUser(user);
      print('👤 Created test user: ${user.fullName} (${user.userRole.name})');
    }
  }

  Future<void> _createTestEquipment() async {
    List<EquipmentModel> testEquipment = [
      EquipmentModel(
        id: 'equip_hvac_001',
        buildingId: 'building_001',
        equipmentName: 'Central HVAC Unit A',
        equipmentType: 'HVAC',
        modelNumber: 'CARRIER-30XA-080',
        serialNumber: 'SN-HVAC-2023-001',
        location: 'Rooftop - North Side',
        department: 'Engineering',
        status: EquipmentStatus.active,
        isCritical: true,
        dateAdded: DateTime.now().subtract(Duration(days: 365)),
        updatedAt: DateTime.now().subtract(Duration(days: 30)),
      ),
    ];

    for (EquipmentModel equip in testEquipment) {
      await _databaseService.createEquipment(equip);
      print(
        '⚙️ Created test equipment: ${equip.equipmentName} (${equip.equipmentType})',
      );
    }
  }

  Future<void> _createTestInventory() async {
    List<InventoryModel> testInventory = [
      InventoryModel(
        id: 'inv_filter_001',
        buildingId: 'building_001',
        itemName: 'HVAC Air Filter (20x25x4)',
        department: 'Engineering',
        classification: 'Consumable',
        currentStock: 12,
        reorderLevel: 5,
        unitOfMeasure: 'pieces',
        dateAdded: DateTime.now().subtract(Duration(days: 90)),
        updatedAt: DateTime.now().subtract(Duration(days: 10)),
      ),
    ];

    for (InventoryModel item in testInventory) {
      await _databaseService.createInventoryItem(item);
      print(
        '📦 Created test inventory: ${item.itemName} (Stock: ${item.currentStock}/${item.reorderLevel})',
      );
    }
  }

  Future<void> _createTestRepairRequests() async {
    List<RepairRequestModel> testRequests = [
      RepairRequestModel(
        id: '',
        title: 'Kitchen Faucet Leaking',
        description:
            'The kitchen faucet in unit 101 has been dripping constantly for the past week. Water is pooling under the sink and causing damage to the cabinet.',
        classification: RepairRequestClassification.plumbing,
        priority: RepairRequestPriority.high,
        status: RepairRequestStatus.open,
        reportedBy: 'admin_001',
        unitId: 'unit_101',
        location: 'Unit 101 - Kitchen',
        assignedTo: null,
        createdAt: DateTime.now().subtract(Duration(days: 2)),
        updatedAt: DateTime.now().subtract(Duration(days: 2)),
      ),
    ];

    for (RepairRequestModel request in testRequests) {
      await _databaseService.createRepairRequest(request);
      print(
        '🔧 Created test repair request: ${request.title} (${request.priority.name} priority)',
      );
    }
  }

  Future<void> _createTestMaintenanceTasks() async {
    List<MaintenanceTaskModel> testTasks = [
      MaintenanceTaskModel(
        id: '',
        equipmentId: 'equip_hvac_001',
        assignedTo: 'admin_001',
        location: 'Rooftop - HVAC Unit A',
        issueDescription:
            'Monthly HVAC maintenance: Replace air filters, clean coils, check refrigerant levels, and inspect electrical connections.',
        status: MaintenanceTaskStatus.scheduled,
        scheduledDate: DateTime.now().add(Duration(days: 15)),
        recurrenceType: RecurrenceType.monthly,
        createdAt: DateTime.now().subtract(Duration(days: 30)),
        updatedAt: DateTime.now().subtract(Duration(days: 30)),
      ),
    ];

    for (MaintenanceTaskModel task in testTasks) {
      await _databaseService.createMaintenanceTask(task);
      print(
        '🗓️ Created test maintenance task: ${task.issueDescription.substring(0, 50)}... (${task.status.name})',
      );
    }
  }

  Future<void> _createTestAnnouncements() async {
    List<AnnouncementModel> testAnnouncements = [
      AnnouncementModel(
        id: '',
        createdBy: 'admin_001',
        buildingId: 'building_001',
        title: 'Scheduled Power Outage - August 15',
        type: AnnouncementType.maintenance,
        audience: AnnouncementAudience.all,
        content:
            'Dear Residents, please be advised that there will be a scheduled power outage on August 15, 2024, from 9:00 AM to 1:00 PM for electrical maintenance. Emergency generator will provide backup power for elevators and emergency lighting only. We apologize for any inconvenience.',
        locationAffected: 'Entire Building',
        isActive: true,
        dateAdded: DateTime.now().subtract(Duration(days: 5)),
        updatedAt: DateTime.now().subtract(Duration(days: 5)),
      ),
    ];

    for (AnnouncementModel ann in testAnnouncements) {
      await _databaseService.createAnnouncement(ann);
      print('📢 Created test announcement: ${ann.title} (${ann.type.name})');
    }
  }

  Future<void> _createTestWorkOrderPermits() async {
    List<WorkOrderPermitModel> testPermits = [
      WorkOrderPermitModel(
        id: '',
        userId: 'admin_001',
        unitId: 'unit_101',
        dateRequested: DateTime.now().subtract(Duration(days: 5)),
        fullName: 'Maria Santos',
        accountType: WorkOrderPermitAccountType.owner,
        specificInstructions:
            'Personal plumber needs access to Unit 101 on August 12, 2024, between 2:00 PM - 5:00 PM to repair kitchen faucet leak. Contractor: Manila Plumbing Services, Contact: +63-917-111-2222',
        status: WorkOrderPermitStatus.approved,
        approvedBy: 'Maria Santos',
        approvalDate: DateTime.now().subtract(Duration(days: 4)),
        createdAt: DateTime.now().subtract(Duration(days: 5)),
        updatedAt: DateTime.now().subtract(Duration(days: 4)),
      ),
    ];

    for (WorkOrderPermitModel permit in testPermits) {
      await _databaseService.createWorkOrderPermit(permit);
      print(
        '📄 Created test work order permit: ${permit.fullName} - ${permit.status.name}',
      );
    }
  }
}
