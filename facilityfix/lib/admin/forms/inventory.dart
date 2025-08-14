import 'package:facilityfix/admin/announcement.dart';
import 'package:facilityfix/admin/calendar.dart';
import 'package:facilityfix/admin/home.dart';
import 'package:facilityfix/admin/inventory.dart';
import 'package:facilityfix/admin/workorder.dart';
import 'package:facilityfix/widgets/buttons.dart';
import 'package:facilityfix/widgets/forms.dart' hide DropdownField;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart' hide FilledButton;
import 'package:facilityfix/widgets/app&nav_bar.dart';

class InventoryForm extends StatefulWidget {
  final String requestType;

  const InventoryForm({
    super.key,
    required this.requestType,
  });

  @override
  State<InventoryForm> createState() => _InventoryFormState();
}

class _InventoryFormState extends State<InventoryForm> {
  int _selectedIndex = 2;

  final List<NavItem> _navItems = const [
    NavItem(icon: Icons.home),
    NavItem(icon: Icons.work),
    NavItem(icon: Icons.announcement_rounded),
    NavItem(icon: Icons.calendar_month),
    NavItem(icon: Icons.inventory),
  ];

  void _onTabTapped(int index) {
    final destinations = [
      const HomePage(),
      const WorkOrderPage(),
      const AnnouncementPage(),
      const CalendarPage(),
      const InventoryPage(),
    ];

    if (index != _selectedIndex) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => destinations[index]),
      );
    }
  }

  Future<void> _selectDateTime(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime != null) {
        final formattedDate =
            "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
        final formattedTime = pickedTime.format(context);
        availabilityController.text = "$formattedDate at $formattedTime";
      }
    }
  }

  // Controllers
  final TextEditingController taskNameController = TextEditingController();
  final TextEditingController idController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController dateCreatedController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  final TextEditingController unitController = TextEditingController();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController availabilityController = TextEditingController();
  final TextEditingController priorityController = TextEditingController();
  final TextEditingController statusController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController hoursController = TextEditingController();
  final TextEditingController dateStartedController = TextEditingController();
  final TextEditingController dueDateController = TextEditingController();
  final TextEditingController adminNotificationController = TextEditingController();
  final TextEditingController staffNotificationController = TextEditingController();
  final TextEditingController otherPriorityController = TextEditingController();
  final TextEditingController remarksController = TextEditingController();

  final List<TextEditingController> checklistControllers = [];

  PlatformFile? selectedFile;

  // For dropdowns
  String? recurringValue;
  String? departmentValue;
  String? staffValue;
  String? priorityValue;
  String? locationValue; 

  final List<String> notificationOptions = [
    'Same Day',
    '1 Day Before',
    '2 Days Before',  
    '3 Days Before',
    '1 Week Before',
    '1 Month Before',
    '3 Months Before',
  ];

  List<String> adminNotifTime = [];
  List<String> staffNotifTime = [];

  void addChecklistItem() {
    setState(() => checklistControllers.add(TextEditingController()));
  }

  void removeChecklistItem(int index) {
    setState(() => checklistControllers.removeAt(index));
  }

  List<Widget> getFormFields() {
    switch (widget.requestType) {
      case 'Inventory From':
        return [
          const Text('Basic Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),

          InputField(label: 'Task Title', controller: idController, hintText: 'Enter Task Title', isRequired: true, readOnly: false),
          InputField(label: 'Task Id', controller: idController, hintText: 'Auto-filled', isRequired: true, readOnly: true),
          InputField(label: 'Created By', controller: taskNameController, hintText: 'Auto-filled', isRequired: true, readOnly: true),
          InputField(label: 'Date Created', controller: dateCreatedController, hintText: 'Auto-filled', isRequired: true, readOnly: true),
          
          DropdownField<String>(
            label: 'Priority',
            value: priorityValue,
            items: ['Low', 'Medium', 'High'],
            onChanged: (newValue) {
              setState(() => priorityValue = newValue);
            },
            isRequired: true,
            otherController: otherPriorityController,
          ),

          DropdownField<String>(
            label: 'Location',
            value: locationValue,
            items: ['Lobby', 'Gate', 'Pool'],
            onChanged: (newValue) {
              setState(() => locationValue = newValue);
            },
            isRequired: true,
            otherController: otherPriorityController,
          ),

          InputField(label: 'Description', controller: descriptionController, hintText: 'Enter task description', isRequired: true),

          const SizedBox(height: 8),
          const Text('Task Checklist', style: TextStyle(fontWeight: FontWeight.bold)),
          ...List.generate(
            checklistControllers.length,
            (index) => Row(
              children: [
                Expanded(
                  child: InputField(
                    label: 'Checklist ${index + 1}',
                    controller: checklistControllers[index],
                    hintText: 'Enter checklist item',
                    isRequired: true,
                  ),
                ),
                IconButton(
                  onPressed: () => removeChecklistItem(index),
                  icon: const Icon(Icons.delete, color: Colors.red),
                )
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: addChecklistItem,
            icon: const Icon(Icons.add),
            label: const Text('Add Checklist Item'),
          ),
        ];

      case 'Assign & Schedule Work':
        return [
          const SizedBox(height: 8),
          const Text('Schedule & Assignment', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),

          DropdownField<String>(
            label: 'Recurring Interval',
            value: recurringValue,
            items: ['1 week', '1 month', '3 months', '1 year', 'Others'],
            onChanged: (value) => setState(() => recurringValue = value),
            otherController: otherPriorityController,
            isRequired: true,
          ),

          InputField(label: 'Estimated Duration', controller: hoursController, hintText: 'In hours', isRequired: true,),
          InputField(
            controller: dateStartedController,
            readOnly: true,
              label: 'Start Date',
              hintText: 'Pick start date',
              suffixIcon: const Icon(Icons.calendar_today),
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(1900),
                  lastDate: DateTime.now(),
                );
                if (pickedDate != null) {
                  dateStartedController.text =
                      "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
                }
              },  
            ),
          InputField(label: 'Due Date', controller: dueDateController, hintText: 'Auto-calculated', readOnly: true),

          DropdownField<String>(
            label: 'Department',
            value: departmentValue,
            items: ['Maintenance', 'Plumbing', 'Electrical', 'Carpentry', 'Others'],
            onChanged: (value) => setState(() => departmentValue = value),
            otherController: otherPriorityController,
            isRequired: true,
          ),

          DropdownField<String>(
            label: 'Assign Staff',
            value: staffValue,
            items: ['Juan Dela Cruz', 'Anna Marie', 'Pedro Santos'],
            onChanged: (value) => setState(() => staffValue = value),
            isRequired: true,
          ),

          FileAttachmentPicker(label: 'Upload Attachment'),

          const SizedBox(height: 8),
          const Text('Remarks', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),

          InputField(label: 'Remarks / Notes', controller: remarksController, hintText: 'Enter remarks', isRequired: false),

          const Text('Notifications', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

          DropdownField<String>(
            label: 'Admin Notifications',
            items: notificationOptions,
            values: adminNotifTime,
            onChangedMulti: (vals) => setState(() => adminNotifTime = vals),
            isMultiSelect: true,
            isRequired: true,
          ),

          DropdownField<String>(
            label: 'Staff Notifications',
            items: notificationOptions,
            values: staffNotifTime, 
            onChangedMulti: (vals) => setState(() => staffNotifTime = vals),
            isMultiSelect: true,
            isRequired: true,
          ),

          InputField(
            label: 'Availability',
            controller: availabilityController,
            hintText: 'Select preferred date & time',
            readOnly: true,
            suffixIcon: const Icon(Icons.calendar_today),
            onTap: () => _selectDateTime(context),
          ),
        ];

      default:
        return [const Text('Invalid request type')];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        leading: Row(
          children: const [
            BackButton(),
            SizedBox(width: 8),
            Text('New Announcement'),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ...getFormFields(),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
              FilledButton(
              label: widget.requestType == 'Assign & Schedule Work' ? "Submit" : "Next",
              onPressed: () {
                if (widget.requestType == 'Assign & Schedule Work') {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Form submitted successfully!')),
                  );
                  Navigator.pop(context);
                } else {
                  // Go to Assign & Schedule Work page
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => InventoryForm(requestType: 'Assign & Schedule Work'),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: NavBar(
        items: _navItems,
        currentIndex: _selectedIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}
