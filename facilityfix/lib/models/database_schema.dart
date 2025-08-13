// FacilityFix Database Schema

class DatabaseSchema {
  // Collection names from Data Dictionary
  static const String BUILDINGS = 'buildings';
  static const String UNITS = 'units';
  static const String USERS = 'users';
  static const String EQUIPMENT = 'equipment';
  static const String INVENTORY = 'inventory';
  static const String REPAIR_REQUESTS = 'repair_requests';
  static const String MAINTENANCE_TASKS = 'maintenance_tasks';
  static const String ANNOUNCEMENTS = 'announcements';
  static const String WORK_ORDER_PERMITS = 'work_order_permits';
}

// Field names for consistent reference across models
class FieldNames {
  // Common fields
  static const String ID = 'id';
  static const String CREATED_AT = 'created_at';
  static const String UPDATED_AT = 'updated';
  static const String STATUS = 'status';

  // Building table fields
  static const String BUILDING_ID = 'building_id';
  static const String BUILDING_NAME = 'building_name';
  static const String ADDRESS = 'address';
  static const String TOTAL_FLOORS = 'total_floors';
  static const String TOTAL_UNITS = 'total_units';

  // Unit table fields
  static const String UNIT_ID = 'unit_id';
  static const String UNIT_NUMBER = 'unit_number';
  static const String FLOOR_NUMBER = 'floor_number';
  static const String OCCUPANCY_STATUS = 'occupancy_status';

  // User table fields
  static const String USER_ID = 'user_id';
  static const String USERNAME = 'username';
  static const String EMAIL = 'email';
  static const String PASSWORD_HASH = 'password_hash';
  static const String FIRST_NAME = 'first_name';
  static const String LAST_NAME = 'last_name';
  static const String PHONE_NUMBER = 'phone_number';
  static const String USER_ROLE = 'user_role';
  static const String DEPARTMENT = 'department';

  // Equipment table fields
  static const String EQUIPMENT_ID = 'equipment_id';
  static const String EQUIPMENT_NAME = 'equipment_name';
  static const String EQUIPMENT_TYPE = 'equipment_type';
  static const String MODEL_NUMBER = 'model_number';
  static const String SERIAL_NUMBER = 'serial_number';
  static const String LOCATION = 'location';
  static const String IS_CRITICAL = 'is_critical';
  static const String DATE_ADDED = 'date_added';

  // Inventory table fields
  static const String INVENTORY_ID = 'inventory_id';
  static const String ITEM_NAME = 'item_name';
  static const String CLASSIFICATION = 'classification';
  static const String CURRENT_STOCK = 'current_stock';
  static const String REORDER_LEVEL = 'reorder_level';
  static const String UNIT_OF_MEASURE = 'unit_of_measure';

  // Repair Request table fields
  static const String REQUEST_ID = 'request_id';
  static const String REPORTED_BY = 'reported_by';
  static const String ASSIGNED_TO = 'assigned_to';
  static const String TITLE = 'title';
  static const String DESCRIPTION = 'description';
  static const String PRIORITY = 'priority';
  static const String ATTACHMENTS = 'attachments';

  // Maintenance Task table fields
  static const String MAINTENANCE_ID = 'maintenance_id';
  static const String EQUIPMENT_FK = 'equipment';
  static const String ISSUE_DESCRIPTION = 'issue_description';
  static const String SCHEDULED_DATE = 'scheduled_date';
  static const String RECURRENCE_TYPE = 'recurrence_type';

  // Announcement table fields
  static const String ANNOUNCEMENT_ID = 'announcement_id';
  static const String CREATED_BY = 'created_by';
  static const String TYPE = 'type';
  static const String AUDIENCE = 'audience';
  static const String CONTENT = 'content';
  static const String LOCATION_AFFECTED = 'location_affected';
  static const String IS_ACTIVE = 'is_active';

  // Work Order Permit table fields
  static const String PERMIT_ID = 'permit_id';
  static const String USER_FK = 'user_id';
  static const String DATE_REQUESTED = 'date_requested';
  static const String FULL_NAME = 'full_name';
  static const String ACCOUNT_TYPE = 'account_type';
  static const String SPECIFIC_INSTRUCTIONS = 'specific_instructions';
  static const String APPROVED_BY = 'approved_by';
  static const String APPROVAL_DATE = 'approval_date';
}
