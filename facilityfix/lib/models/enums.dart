// Enum based on FacilityFix project requirements
enum UserRole { admin, tenant, staff }

enum UserStatus { active, inactive, suspended }

enum OccupancyStatus { occupied, vacant, underMaintenance, reserved }

enum EquipmentStatus { active, underRepair, outOfService, retired }

enum RepairRequestClassification {
  carpentry,
  masonry,
  technical,
  maintenance,
  poolAttendant,
  electrical,
  plumbing,
  hvac,
  appliance,
  structural,
  other,
}

enum RepairRequestPriority { low, medium, high, critical }

enum RepairRequestStatus {
  open,
  pending,
  approved,
  rejected,
  inProgress,
  resolved,
  closed,
  //onHold
}

enum MaintenanceTaskStatus {
  scheduled,
  inProgress,
  completed,
  onHold,
  cancelled,
}

enum RecurrenceType {
  none,
  daily,
  weekly,
  monthly,
  quarterly,
  annually,
  usageBased,
  equipmentAgeBased,
}

enum AnnouncementType { maintenance, reminder, event, general, emergency }

enum AnnouncementAudience { tenants, staff, all }

enum WorkOrderPermitAccountType { owner, tenant, contractor }

enum WorkOrderPermitStatus {
  pending,
  approved,
  denied,
  completed,
  cancelled,
  expired,
}
