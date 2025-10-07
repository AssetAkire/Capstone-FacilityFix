import 'package:flutter/material.dart';
import '../popupwidgets/assignstaff_popup.dart';

class FireSafetyDialog extends StatefulWidget {
  final Map<String, dynamic> maintenanceData;

  const FireSafetyDialog({
    super.key,
    required this.maintenanceData,
  });

  @override
  State<FireSafetyDialog> createState() => _FireSafetyDialogState();

  static void show(BuildContext context, Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return FireSafetyDialog(maintenanceData: data);
      },
    );
  }
}

class _FireSafetyDialogState extends State<FireSafetyDialog> {
  bool isEditMode = false;
  int? selectedTaskIndex;
  late List<Map<String, dynamic>> tasks;

  // Width used by the new checkbox column to keep layout tidy
  static const double _checkColWidth = 40;

  @override
  void initState() {
    super.initState();
    // Initialize tasks from the maintenance data or use defaults
    tasks = List<Map<String, dynamic>>.from(
      widget.maintenanceData['tasks'] ?? _getDefaultTasks(),
    );
  }

  List<Map<String, dynamic>> _getDefaultTasks() {
    return [
      {
        'name': 'Fire Extinguishers Present And Fully Charged',
        'assigned': null,
        'rotation': 'Annually',
        'status': 'In Progress',
      },
      {
        'name': 'Fire Alarm System Functional And Tested',
        'assigned': 'Staff',
        'rotation': 'Semi-Annually',
        'status': null,
      },
      {
        'name': 'Emergency Exit Signs Visible And Illuminated',
        'assigned': null,
        'rotation': 'Monthly',
        'status': null,
      },
      {
        'name': 'Fire Exit Doors Unblocked And Operable',
        'assigned': null,
        'rotation': 'Monthly',
        'status': null,
      },
      {
        'name': 'Fire Sprinkler System Inspection',
        'assigned': null,
        'rotation': 'Annually',
        'status': null,
      },
    ];
  }

  void _addNewTask() {
    setState(() {
      tasks.add({
        'name': 'New Task',
        'assigned': null,
        'rotation': 'Monthly',
        'status': null,
      });
    });
  }

  void _deleteTask(int index) {
    setState(() {
      if (selectedTaskIndex == index) {
        selectedTaskIndex = null;
      } else if (selectedTaskIndex != null && selectedTaskIndex! > index) {
        selectedTaskIndex = selectedTaskIndex! - 1;
      }
      tasks.removeAt(index);
    });
  }

  void _handleAssignTask() {
    if (selectedTaskIndex != null) {
      final selectedTask = tasks[selectedTaskIndex!];
      AssignScheduleWorkDialog.show(
        context,
        {
          'taskName': selectedTask['name'],
          'priority': widget.maintenanceData['priority'] ?? 'Medium',
          'rotation': selectedTask['rotation'],
          'status': selectedTask['status'] ?? 'Pending',
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a task first'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _saveChanges() {
    // TODO: Save changes to backend
    setState(() {
      isEditMode = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Changes saved successfully'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Helper: evaluate if a task is completed based on its status
  bool _isTaskCompleted(Map<String, dynamic> task) {
    final status = (task['status'] as String?)?.trim().toLowerCase();
    return status == 'completed';
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.75,
        constraints: const BoxConstraints(
          maxWidth: 1000,
          maxHeight: 700,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title + description container 
            Padding(
              padding: const EdgeInsets.fromLTRB(32, 24, 32, 0),
              child: _buildTitleSection(),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(32, 24, 32, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tasks table
                    _buildTasksTable(),
                    if (isEditMode) ...[
                      const SizedBox(height: 16),
                      _buildAddTaskButton(),
                    ],
                  ],
                ),
              ),
            ),
            
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey[300]!, width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title + description on the left
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'FIRE SAFETY',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Task Description',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  widget.maintenanceData['description'] ??
                      'Comprehensive fire safety inspection ensuring all fire protection systems, equipment, and emergency exits are functional and compliant with safety regulations. Regular checks include fire extinguishers, alarm systems, sprinklers, emergency lighting, and exit accessibility to maintain a safe environment for all occupants.',
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.6,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
          ),

          // Close button 
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(
              Icons.close,
              color: Colors.grey,
              size: 24,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildTasksTable() {
    return Column(
      children: [
        // Table Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
          ),
          child: Row(
            children: [
              // Spacer to align with delete icon when in edit mode 
              if (isEditMode) const SizedBox(width: 40),

              // checkbox column header 
              SizedBox(
                width: _checkColWidth,
                child: const Center(
                  child: Text(
                    '',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),

              // Details/Task
              Expanded(
                flex: 3,
                child: const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Details/Task',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
              // Assigned
              Expanded(
                flex: 1,
                child: const Center(
                  child: Text(
                    'Assigned',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              // Rotation
              Expanded(
                flex: 1,
                child: const Center(
                  child: Text(
                    'Rotation',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              // Status
              Expanded(
                flex: 1,
                child: const Center(
                  child: Text(
                    'Status',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
        // Table Rows
        ...List.generate(tasks.length, (index) {
          return _buildTaskRow(index);
        }),
      ],
    );
  }

  Widget _buildTaskRow(int index) {
    final task = tasks[index];
    final isSelected = selectedTaskIndex == index;
    final isCompleted = _isTaskCompleted(task);

    return InkWell(
      onTap: isEditMode
          ? null
          : () {
              setState(() {
                selectedTaskIndex = isSelected ? null : index;
              });
            },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE3F2FD) : Colors.white,
          border: Border(
            bottom: BorderSide(
              color: Colors.grey[300]!,
              width: 1,
            ),
            left: isSelected
                ? const BorderSide(color: Color(0xFF1976D2), width: 3)
                : BorderSide.none,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Keep delete button behavior/placement as-is
            if (isEditMode)
              IconButton(
                onPressed: () => _deleteTask(index),
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 40),
              ),

            // NEW: Auto-checking checkbox column linked to task status
            SizedBox(
              width: _checkColWidth,
              child: Center(
                child: Checkbox(
                  value: isCompleted,
                  // In view mode, it's read-only; in edit mode, toggling updates status.
                  onChanged: isEditMode
                      ? (bool? value) {
                          setState(() {
                            if (value == true) {
                              tasks[index]['status'] = 'Completed';
                            } else {
                              // Simple fallback when unchecked in edit mode
                              tasks[index]['status'] = 'Pending';
                            }
                          });
                        }
                      : null,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ),

            // Details/Task 
            Expanded(
              flex: 3,
              child: isEditMode
                  ? TextFormField(
                      initialValue: task['name'],
                      onChanged: (value) {
                        tasks[index]['name'] = value;
                      },
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                      decoration: const InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 8,
                        ),
                        border: OutlineInputBorder(),
                      ),
                    )
                  : Text(
                      task['name'],
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
            ),
            const SizedBox(width: 16),

            // Assigned 
            Expanded(
              flex: 1,
              child: isEditMode
                  ? TextFormField(
                      initialValue: task['assigned'] ?? '',
                      textAlign: TextAlign.center,
                      onChanged: (value) {
                        tasks[index]['assigned'] = value.isEmpty ? null : value;
                      },
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                      decoration: const InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 8,
                        ),
                        border: OutlineInputBorder(),
                        hintText: 'Null',
                      ),
                    )
                  : Center(
                      child: Text(
                        task['assigned'] ?? 'Null',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
            ),
            const SizedBox(width: 16),

            // Rotation 
            Expanded(
              flex: 1,
              child: isEditMode
                  ? Center(
                      child: DropdownButtonFormField<String>(
                        value: task['rotation'],
                        items: [
                          'Daily',
                          'Weekly',
                          'Monthly',
                          'Quarterly',
                          'Semi-Annually',
                          'Annually'
                        ]
                            .map((rotation) => DropdownMenuItem(
                                  value: rotation,
                                  child: Text(rotation),
                                ))
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              tasks[index]['rotation'] = value;
                            });
                          }
                        },
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                        decoration: const InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 8,
                          ),
                          border: OutlineInputBorder(),
                        ),
                      ),
                    )
                  : Center(
                      child: Text(
                        task['rotation'],
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
            ),
            const SizedBox(width: 16),

            // Status 
            Expanded(
              flex: 1,
              child: Center(
                child: task['status'] != null
                    ? _buildStatusChip(task['status'])
                    : const SizedBox(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color bgColor;
    Color textColor;
    switch (status.toLowerCase()) {
      case 'in progress':
        bgColor = const Color(0xFFFFE8E0);
        textColor = const Color(0xFFD84315);
        break;
      case 'pending':
        bgColor = const Color(0xFFFFEBEE);
        textColor = const Color(0xFFD32F2F);
        break;
      case 'completed':
        bgColor = const Color(0xFFE8F5E8);
        textColor = const Color(0xFF2E7D32);
        break;
      default:
        bgColor = const Color(0xFFE8F4FD);
        textColor = const Color(0xFF1976D2);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildAddTaskButton() {
    return InkWell(
      onTap: _addNewTask,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.grey[300]!,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_circle_outline,
              color: const Color(0xFF1976D2),
              size: 24,
            ),
            const SizedBox(width: 8),
            const Text(
              'Add New Task',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1976D2),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isEditMode)
            TextButton(
              onPressed: () {
                setState(() {
                  isEditMode = false;
                  // Reset tasks to original state if needed
                  tasks = List<Map<String, dynamic>>.from(
                    widget.maintenanceData['tasks'] ?? _getDefaultTasks(),
                  );
                });
              },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          if (isEditMode) const SizedBox(width: 16),
          ElevatedButton.icon(
            onPressed: isEditMode ? _saveChanges : _handleAssignTask,
            icon: Icon(
              isEditMode ? Icons.save_outlined : Icons.edit_outlined,
              size: 20,
            ),
            label: Text(
              isEditMode ? 'Save Changes' : 'Assign Task',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1976D2),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 32,
                vertical: 16,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
          ),
          const SizedBox(width: 16),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                if (isEditMode) {
                  _saveChanges();
                } else {
                  isEditMode = true;
                  selectedTaskIndex = null;
                }
              });
            },
            icon: Icon(
              isEditMode ? Icons.check : Icons.edit_outlined,
              size: 20,
            ),
            label: Text(
              isEditMode ? 'Done' : 'Edit Task',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1976D2),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 32,
                vertical: 16,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }
}
