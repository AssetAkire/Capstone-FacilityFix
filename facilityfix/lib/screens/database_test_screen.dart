import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../services/database_seeder.dart';
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

class DatabaseTestScreen extends StatefulWidget {
  @override
  _DatabaseTestScreenState createState() => _DatabaseTestScreenState();
}

class _DatabaseTestScreenState extends State<DatabaseTestScreen> {
  final DatabaseService _databaseService = DatabaseService();
  final DatabaseSeeder _seeder = DatabaseSeeder();

  bool _isLoading = false;
  String _message = '';
  Map<String, int> _dashboardCounts = {};

  // Data lists
  BuildingModel? _building;
  List<UnitModel> _units = [];
  List<UserModel> _users = [];
  List<EquipmentModel> _equipment = [];
  List<InventoryModel> _inventory = [];
  List<RepairRequestModel> _repairRequests = [];
  List<MaintenanceTaskModel> _maintenanceTasks = [];
  List<AnnouncementModel> _announcements = [];
  List<WorkOrderPermitModel> _workOrderPermits = [];

  // Form controllers for adding new records
  final _buildingNameController = TextEditingController();
  final _buildingAddressController = TextEditingController();
  final _unitNumberController = TextEditingController();
  final _userFirstNameController = TextEditingController();
  final _userLastNameController = TextEditingController();
  final _userEmailController = TextEditingController();
  final _repairTitleController = TextEditingController();
  final _repairDescriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  @override
  void dispose() {
    // Dispose controllers
    _buildingNameController.dispose();
    _buildingAddressController.dispose();
    _unitNumberController.dispose();
    _userFirstNameController.dispose();
    _userLastNameController.dispose();
    _userEmailController.dispose();
    _repairTitleController.dispose();
    _repairDescriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadAllData() async {
    setState(() {
      _isLoading = true;
      _message = 'Loading FacilityFix database...';
    });

    try {
      // Load building
      _building = await _databaseService.getBuilding('building_001');

      // Load all collections
      final futures = await Future.wait([
        _databaseService.unitsCollection.get(),
        _databaseService.usersCollection.get(),
        _databaseService.equipmentCollection.get(),
        _databaseService.inventoryCollection.get(),
        _databaseService.repairRequestsCollection.get(),
        _databaseService.maintenanceTasksCollection.get(),
        _databaseService.announcementsCollection.get(),
        _databaseService.workOrderPermitsCollection.get(),
      ]);

      _units =
          futures[0].docs.map((doc) => UnitModel.fromFirestore(doc)).toList();
      _users =
          futures[1].docs.map((doc) => UserModel.fromFirestore(doc)).toList();
      _equipment =
          futures[2].docs
              .map((doc) => EquipmentModel.fromFirestore(doc))
              .toList();
      _inventory =
          futures[3].docs
              .map((doc) => InventoryModel.fromFirestore(doc))
              .toList();
      _repairRequests =
          futures[4].docs
              .map((doc) => RepairRequestModel.fromFirestore(doc))
              .toList();
      _maintenanceTasks =
          futures[5].docs
              .map((doc) => MaintenanceTaskModel.fromFirestore(doc))
              .toList();
      _announcements =
          futures[6].docs
              .map((doc) => AnnouncementModel.fromFirestore(doc))
              .toList();
      _workOrderPermits =
          futures[7].docs
              .map((doc) => WorkOrderPermitModel.fromFirestore(doc))
              .toList();

      // Load dashboard counts
      _dashboardCounts = await _databaseService.getDashboardCounts();

      setState(() {
        _message = 'FacilityFix database loaded successfully!';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _message = 'Error loading database: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _seedDatabase() async {
    setState(() {
      _isLoading = true;
      _message = 'Seeding FacilityFix database...';
    });

    try {
      await _seeder.seedDatabase();
      await _loadAllData();
      setState(() {
        _message = 'FacilityFix database seeded successfully!';
      });
    } catch (e) {
      setState(() {
        _message = 'Error seeding database: $e';
        _isLoading = false;
      });
    }
  }

  // Add new building
  Future<void> _addNewBuilding() async {
    if (_buildingNameController.text.isEmpty ||
        _buildingAddressController.text.isEmpty) {
      setState(() {
        _message = 'Please fill in building name and address';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _message = 'Adding new building...';
    });

    try {
      String buildingId = 'building_${DateTime.now().millisecondsSinceEpoch}';
      BuildingModel newBuilding = BuildingModel(
        id: buildingId,
        buildingName: _buildingNameController.text.trim(),
        address: _buildingAddressController.text.trim(),
        totalFloors: 10, // Default value
        totalUnits: 100, // Default value
        createdAt: DateTime.now(),
      );

      await _databaseService.createBuilding(newBuilding);
      _buildingNameController.clear();
      _buildingAddressController.clear();
      await _loadAllData();
      setState(() {
        _message = 'Building "${newBuilding.buildingName}" added successfully!';
      });
    } catch (e) {
      setState(() {
        _message = 'Error adding building: $e';
        _isLoading = false;
      });
    }
  }

  // Add new unit
  Future<void> _addNewUnit() async {
    if (_unitNumberController.text.isEmpty) {
      setState(() {
        _message = 'Please enter unit number';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _message = 'Adding new unit...';
    });

    try {
      String unitId = 'unit_${DateTime.now().millisecondsSinceEpoch}';
      UnitModel newUnit = UnitModel(
        id: unitId,
        buildingId: 'building_001', // Default to first building
        unitNumber: _unitNumberController.text.trim(),
        floorNumber: 1, // Default value
        occupancyStatus: OccupancyStatus.vacant,
        createdAt: DateTime.now(),
      );

      await _databaseService.createUnit(newUnit);
      _unitNumberController.clear();
      await _loadAllData();
      setState(() {
        _message = 'Unit "${newUnit.unitNumber}" added successfully!';
      });
    } catch (e) {
      setState(() {
        _message = 'Error adding unit: $e';
        _isLoading = false;
      });
    }
  }

  // Add new user
  Future<void> _addNewUser() async {
    if (_userFirstNameController.text.isEmpty ||
        _userLastNameController.text.isEmpty ||
        _userEmailController.text.isEmpty) {
      setState(() {
        _message = 'Please fill in all user fields';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _message = 'Adding new user...';
    });

    try {
      String userId = 'user_${DateTime.now().millisecondsSinceEpoch}';
      UserModel newUser = UserModel(
        id: userId,
        username: _userEmailController.text.trim().split('@')[0],
        email: _userEmailController.text.trim(),
        passwordHash:
            'hashed_password_${DateTime.now().millisecondsSinceEpoch}',
        firstName: _userFirstNameController.text.trim(),
        lastName: _userLastNameController.text.trim(),
        userRole: UserRole.tenant,
        status: UserStatus.active,
        buildingId: 'building_001',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _databaseService.createUser(newUser);
      _userFirstNameController.clear();
      _userLastNameController.clear();
      _userEmailController.clear();
      await _loadAllData();
      setState(() {
        _message = 'User "${newUser.fullName}" added successfully!';
      });
    } catch (e) {
      setState(() {
        _message = 'Error adding user: $e';
        _isLoading = false;
      });
    }
  }

  // Add new repair request
  Future<void> _addNewRepairRequest() async {
    if (_repairTitleController.text.isEmpty) {
      setState(() {
        _message = 'Please enter repair request title';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _message = 'Adding new repair request...';
    });

    try {
      RepairRequestModel newRequest = RepairRequestModel(
        id: '',
        title: _repairTitleController.text.trim(),
        description: _repairDescriptionController.text.trim(),
        classification: RepairRequestClassification.maintenance,
        priority: RepairRequestPriority.medium,
        status: RepairRequestStatus.open,
        reportedBy: 'admin_001',
        unitId: 'unit_101',
        location: 'Test Location',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _databaseService.createRepairRequest(newRequest);
      _repairTitleController.clear();
      _repairDescriptionController.clear();
      await _loadAllData();
      setState(() {
        _message = 'Repair request "${newRequest.title}" added successfully!';
      });
    } catch (e) {
      setState(() {
        _message = 'Error adding repair request: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('FacilityFix Database Test'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Control buttons
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _seedDatabase,
                  icon: Icon(Icons.eco),
                  label: Text('Seed Database'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                ),
                SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _loadAllData,
                  icon: Icon(Icons.refresh),
                  label: Text('Refresh Data'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                ),
              ],
            ),

            SizedBox(height: 16),

            // Status message
            if (_message.isNotEmpty)
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color:
                      _message.contains('Error')
                          ? Colors.red.shade100
                          : Colors.green.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color:
                        _message.contains('Error') ? Colors.red : Colors.green,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _message.contains('Error')
                          ? Icons.error
                          : Icons.check_circle,
                      color:
                          _message.contains('Error')
                              ? Colors.red.shade800
                              : Colors.green.shade800,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _message,
                        style: TextStyle(
                          color:
                              _message.contains('Error')
                                  ? Colors.red.shade800
                                  : Colors.green.shade800,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            SizedBox(height: 16),

            // Dashboard counts
            if (_dashboardCounts.isNotEmpty) ...[
              Text(
                'Dashboard Overview',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
              SizedBox(height: 8),
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildCountCard(
                          'Buildings',
                          _building != null ? 1 : 0,
                          Colors.purple,
                        ),
                        _buildCountCard('Units', _units.length, Colors.blue),
                        _buildCountCard('Users', _users.length, Colors.green),
                      ],
                    ),
                    SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildCountCard(
                          'Equipment',
                          _equipment.length,
                          Colors.orange,
                        ),
                        _buildCountCard(
                          'Inventory',
                          _inventory.length,
                          Colors.teal,
                        ),
                        _buildCountCard(
                          'Requests',
                          _repairRequests.length,
                          Colors.red,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
            ],

            Expanded(
              child:
                  _isLoading
                      ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 16),
                            Text(_message),
                          ],
                        ),
                      )
                      : DefaultTabController(
                        length: 2,
                        child: Column(
                          children: [
                            TabBar(
                              labelColor: Colors.deepPurple,
                              unselectedLabelColor: Colors.grey,
                              indicatorColor: Colors.deepPurple,
                              tabs: [
                                Tab(text: 'View Data'),
                                Tab(text: 'Add New Records'),
                              ],
                            ),
                            Expanded(
                              child: TabBarView(
                                children: [
                                  _buildDataViewTab(),
                                  _buildAddRecordsTab(),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataViewTab() {
    return ListView(
      children: [
        SizedBox(height: 16),
        _buildSectionTitle('Building Information'),
        if (_building != null) _buildBuildingCard(_building!),
        SizedBox(height: 16),

        _buildSectionTitle('Units (${_units.length})'),
        if (_units.isNotEmpty)
          ..._units.take(3).map((unit) => _buildUnitCard(unit)).toList(),
        if (_units.length > 3) _buildShowMoreCard('units', _units.length - 3),
        SizedBox(height: 16),

        _buildSectionTitle('Users (${_users.length})'),
        if (_users.isNotEmpty)
          ..._users.take(3).map((user) => _buildUserCard(user)).toList(),
        if (_users.length > 3) _buildShowMoreCard('users', _users.length - 3),
        SizedBox(height: 16),

        _buildSectionTitle('Repair Requests (${_repairRequests.length})'),
        if (_repairRequests.isNotEmpty)
          ..._repairRequests
              .take(3)
              .map((req) => _buildRepairRequestCard(req))
              .toList(),
        if (_repairRequests.length > 3)
          _buildShowMoreCard('repair requests', _repairRequests.length - 3),
        SizedBox(height: 32),
      ],
    );
  }

  Widget _buildAddRecordsTab() {
    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        // Add Building Form
        _buildFormSection(
          title: 'Add New Building',
          icon: Icons.business,
          color: Colors.purple,
          children: [
            TextField(
              controller: _buildingNameController,
              decoration: InputDecoration(
                labelText: 'Building Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.business),
              ),
            ),
            SizedBox(height: 12),
            TextField(
              controller: _buildingAddressController,
              decoration: InputDecoration(
                labelText: 'Address',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_on),
              ),
            ),
            SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _addNewBuilding,
              icon: Icon(Icons.add),
              label: Text('Add Building'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
            ),
          ],
        ),

        SizedBox(height: 24),

        // Add Unit Form
        _buildFormSection(
          title: 'Add New Unit',
          icon: Icons.home,
          color: Colors.blue,
          children: [
            TextField(
              controller: _unitNumberController,
              decoration: InputDecoration(
                labelText: 'Unit Number',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.home),
              ),
            ),
            SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _addNewUnit,
              icon: Icon(Icons.add),
              label: Text('Add Unit'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            ),
          ],
        ),

        SizedBox(height: 24),

        // Add User Form
        _buildFormSection(
          title: 'Add New User',
          icon: Icons.person,
          color: Colors.green,
          children: [
            TextField(
              controller: _userFirstNameController,
              decoration: InputDecoration(
                labelText: 'First Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            SizedBox(height: 12),
            TextField(
              controller: _userLastNameController,
              decoration: InputDecoration(
                labelText: 'Last Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person_outline),
              ),
            ),
            SizedBox(height: 12),
            TextField(
              controller: _userEmailController,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _addNewUser,
              icon: Icon(Icons.add),
              label: Text('Add User'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            ),
          ],
        ),

        SizedBox(height: 24),

        // Add Repair Request Form
        _buildFormSection(
          title: 'Add New Repair Request',
          icon: Icons.build,
          color: Colors.red,
          children: [
            TextField(
              controller: _repairTitleController,
              decoration: InputDecoration(
                labelText: 'Repair Title',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.build),
              ),
            ),
            SizedBox(height: 12),
            TextField(
              controller: _repairDescriptionController,
              decoration: InputDecoration(
                labelText: 'Description (Optional)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 3,
            ),
            SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _addNewRepairRequest,
              icon: Icon(Icons.add),
              label: Text('Add Repair Request'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFormSection({
    required String title,
    required IconData icon,
    required Color color,
    required List<Widget> children,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color),
              SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildCountCard(String title, int count, Color color) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(fontSize: 12, color: color),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.deepPurple,
        ),
      ),
    );
  }

  Widget _buildShowMoreCard(String type, int remainingCount) {
    return Card(
      margin: EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Center(
          child: Text(
            '... and $remainingCount more $type',
            style: TextStyle(
              fontStyle: FontStyle.italic,
              color: Colors.grey.shade600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBuildingCard(BuildingModel building) {
    return Card(
      margin: EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '🏢 ${building.buildingName}',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            SizedBox(height: 4),
            Text('📍 ${building.address}'),
            Text(
              '🏗️ ${building.totalFloors} floors, ${building.totalUnits} units',
            ),
            Text('📅 Created: ${_formatDate(building.createdAt)}'),
          ],
        ),
      ),
    );
  }

  Widget _buildUnitCard(UnitModel unit) {
    return Card(
      margin: EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _getStatusColor(
                  unit.occupancyStatus.name,
                ).withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                unit.unitNumber,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Floor ${unit.floorNumber}'),
                  Text(
                    'Status: ${unit.occupancyStatus.name}',
                    style: TextStyle(
                      color: _getStatusColor(unit.occupancyStatus.name),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserCard(UserModel user) {
    return Card(
      margin: EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: _getRoleColor(user.userRole.name),
              child: Text(
                user.firstName[0] + user.lastName[0],
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${user.fullName}',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text('${user.userRole.name.toUpperCase()} • ${user.email}'),
                  if (user.department != null) Text('Dept: ${user.department}'),
                  if (user.unitId != null) Text('Unit: ${user.unitId}'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRepairRequestCard(RepairRequestModel req) {
    return Card(
      margin: EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getPriorityColor(
                      req.priority.name,
                    ).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    req.priority.name.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: _getPriorityColor(req.priority.name),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${req.title}',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            SizedBox(height: 4),
            Text('${req.location} • ${req.classification.name}'),
            Text('Status: ${req.status.name}'),
            if (req.description != null && req.description!.isNotEmpty)
              Text(
                '${req.description!.length > 100 ? req.description!.substring(0, 100) + '...' : req.description}',
              ),
            Text('Created: ${_formatDate(req.createdAt)}'),
          ],
        ),
      ),
    );
  }

  // Helper methods
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'occupied':
        return Colors.green;
      case 'vacant':
        return Colors.orange;
      case 'undermaintenance':
        return Colors.red;
      case 'reserved':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return Colors.purple;
      case 'staff':
        return Colors.blue;
      case 'tenant':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'low':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'high':
        return Colors.red;
      case 'critical':
        return Colors.red.shade900;
      default:
        return Colors.grey;
    }
  }
}
