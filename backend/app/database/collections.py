"""
Firestore Collection Names and Structure
Based on FacilityFix Database Schema
"""

# Collection Names
COLLECTIONS = {
    'buildings': 'buildings',
    'units': 'units',
    'users': 'users',
    'equipment': 'equipment',
    'inventory': 'inventory',
    'repair_requests': 'repair_requests',
    'maintenance_tasks': 'maintenance_tasks',
    'announcements': 'announcements',
    'work_order_permits': 'work_order_permits',
}

# Collection Structure Documentation
COLLECTION_SCHEMAS = {
    'buildings': {
        'fields': ['building_name', 'address', 'total_floors', 'total_units'],
        'required': ['building_name', 'address', 'total_floors', 'total_units'],
        'indexes': ['building_name']
    },
    'units': {
        'fields': ['building_id', 'unit_number', 'floor_number', 'occupancy_status'],
        'required': ['building_id', 'unit_number', 'floor_number'],
        'indexes': ['building_id', 'unit_number']
    },
    'users':{
        'fields': ['building_id', 'unit_id', 'first_name', 'last_name', 'phone_number', 'department', 'role', 'status'],
        'required': ['first_name', 'last_name', 'role'],
        'indexes': ['role', 'building_id', 'status']
    },
    'equipment': {
        'fields': ['building_id', 'equipment_name', 'equipment_type', 'location', 'status', 'is_critical'],
        'required': ['building_id', 'equipment_name', 'equipment_type', 'location'],
        'indexes': ['building_id', 'equipment_type', 'status']
    },
    'inventory': {
        'fields': ['building_id', 'item_name', 'department', 'classification', 'current_stock', 'reorder_level'],
        'required': ['building_id', 'item_name', 'department', 'current_stock'],
        'indexes': ['building_id', 'department', 'current_stock']
    },
    'repair_requests': {
        'fields': ['reported_by', 'unit_id', 'assigned_to', 'title', 'location', 'classification', 'priority', 'status'],
        'required': ['reported_by', 'title', 'location', 'classification'],
        'indexes': ['status', 'priority', 'assigned_to', 'reported_by']
    },
    'maintenance_tasks': {
        'fields': ['equipment_id', 'assigned_to', 'location', 'task_description', 'status', 'scheduled_date', 'recurrence_type'],
        'required': ['assigned_to', 'location', 'task_description', 'scheduled_date'],
        'indexes': ['status', 'assigned_to', 'scheduled_date']
    },
    'announcements': {
        'fields': ['created_by', 'building_id', 'title', 'content', 'type', 'audience', 'is_active'],
        'required': ['created_by', 'building_id', 'title', 'content'],
        'indexes': ['building_id', 'type', 'is_active']
    },
    'work_order_permits': {
        'fields': ['user_id', 'unit_id', 'full_name', 'account_type', 'specific_instructions', 'status'],
        'required': ['user_id', 'unit_id', 'full_name', 'account_type', 'specific_instructions'],
        'indexes': ['status', 'user_id', 'unit_id']
    }
}