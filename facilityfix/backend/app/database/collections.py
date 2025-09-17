# Collection Names
COLLECTIONS = {
    'buildings': 'buildings',
    'units': 'units',
    'users': 'users',
    'user_profiles': 'user_profiles',
    'equipment': 'equipment',
    'inventory': 'inventory',
    'concern_slips': 'concern_slips',
    'job_services': 'job_services',
    'work_order_permits': 'work_order_permits',
    'maintenance_tasks': 'maintenance_tasks',
    'announcements': 'announcements',
    'notifications': 'notifications',
    'status_history': 'status_history',
    'feedback': 'feedback',
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
    'user_profiles': {
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
    'concern_slips': {
        'fields': ['reported_by', 'unit_id', 'title', 'description', 'location', 'category', 'priority', 'status', 'resolution_type', 'evaluated_by'],
        'required': ['reported_by', 'title', 'description', 'location', 'category'],
        'indexes': ['status', 'priority', 'reported_by', 'category', 'resolution_type']
    },
    'job_services': {
        'fields': ['concern_slip_id', 'created_by', 'assigned_to', 'title', 'description', 'location', 'category', 'priority', 'status', 'scheduled_date', 'completed_at'],
        'required': ['concern_slip_id', 'created_by', 'title', 'description', 'location', 'category'],
        'indexes': ['status', 'assigned_to', 'created_by', 'concern_slip_id', 'priority']
    },
    'work_order_permits': {
        'fields': ['concern_slip_id', 'requested_by', 'unit_id', 'contractor_name', 'contractor_contact', 'work_description', 'status', 'approved_by', 'proposed_start_date'],
        'required': ['concern_slip_id', 'requested_by', 'unit_id', 'contractor_name', 'contractor_contact', 'work_description'],
        'indexes': ['status', 'requested_by', 'unit_id', 'approved_by']
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
    'notifications': {
        'fields': ['recipient_id', 'sender_id', 'title', 'message', 'notification_type', 'related_id', 'is_read'],
        'required': ['recipient_id', 'title', 'message', 'notification_type'],
        'indexes': ['recipient_id', 'is_read', 'notification_type', 'related_id']
    },
    'status_history': {
        'fields': ['work_order_id', 'previous_status', 'new_status', 'updated_by', 'remarks', 'timestamp'],
        'required': ['work_order_id', 'new_status', 'updated_by'],
        'indexes': ['work_order_id', 'timestamp']
    },
    'feedback': {
        'fields': ['work_order_id', 'request_id', 'submitted_by', 'rating', 'comments', 'service_quality', 'timeliness'],
        'required': ['work_order_id', 'request_id', 'submitted_by', 'rating'],
        'indexes': ['work_order_id', 'submitted_by', 'rating']
    }
}