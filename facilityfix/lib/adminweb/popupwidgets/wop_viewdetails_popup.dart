import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class WorkOrderConcernSlipDialog extends StatelessWidget {
  final Map<String, dynamic> task;

  const WorkOrderConcernSlipDialog({
    super.key,
    required this.task,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.6,
        constraints: const BoxConstraints(
          maxWidth: 800,
          maxHeight: 800,
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
            // Header Section
            _buildHeader(context),

            // Content Section
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      task['title'] ?? 'Aircon is not cooling properly',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Details Grid
                    _buildDetailsGrid(),
                    const SizedBox(height: 32),

                    // Work Description Section
                    _buildWorkDescription(),
                    const SizedBox(height: 32),

                    // Assessment and Recommendation Section
                    _buildAssessmentRecommendation(),
                  ],
                ),
              ),
            ),
            
            Divider(
              color: Colors.grey[300],
              thickness: 1,
              height: 1,
            ),

            // Footer with Next Button
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 32, right: 24, top: 24, bottom: 16),
      child: Row(
        children: [
          const Text(
            'Concern Slip',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const Spacer(),
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

  Widget _buildDetailsGrid() {
    return Column(
      children: [
        // First Row - Concern ID and Date Requested
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildDetailItem(
                'CONCERN ID',
                task['concernId'] ?? task['id'] ?? 'CS-2025-00412',
              ),
            ),
            const SizedBox(width: 48),
            Expanded(
              child: _buildDetailItem(
                'DATE REQUESTED',
                task['dateRequested'] ?? '2025-08-16',
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Divider(
          color: Colors.grey[300],
          thickness: 1,
          height: 1,
        ),
        const SizedBox(height: 16),

        // Priority and Status Section
        Row(
          children: [
            _buildPriorityChip(task['priority'] ?? 'High'),
            const SizedBox(width: 16),
            _buildStatusChip(task['status'] ?? 'Pending Review'),
            const Spacer(),
          ],
        ),
        const SizedBox(height: 24),

        // Second Row - Requested By and Account Type
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildDetailItem(
                'REQUESTED BY',
                task['requestedBy'] ?? 'Erika De Guzman',
              ),
            ),
            const SizedBox(width: 48),
            Expanded(
              child: _buildDetailItem(
                'ACCOUNT TYPE',
                task['accountType'] ?? task['department'] ?? 'Air Conditioning',
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Third Row - Building & Unit No.
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildDetailItem(
                'BLDG & UNIT NO.',
                task['buildingUnit'] ?? 'A - 1010',
              ),
            ),
            const SizedBox(width: 48),
            const Expanded(child: SizedBox()), // Empty space for alignment
          ],
        ),
      ],
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.grey[600],
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildWorkDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(
          color: Colors.grey[300],
          thickness: 1,
          height: 1,
        ),
        const SizedBox(height: 16),
        const Text(
          'Work Description',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          task['description'] ?? 
          'Air conditioner is no longer cooling properly. The unit is making unusual noises and leaks water occasionally.',
          style: TextStyle(
            fontSize: 15,
            height: 1.6,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 16),
        Divider(
          color: Colors.grey[300],
          thickness: 1,
          height: 1,
        ),
      ],
    );
  }

  Widget _buildAssessmentRecommendation() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Assessment Section
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Assessment',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                task['assessment'] ?? 
                'Unit is low on refrigerant and fan motor is worn out. Needs replacement and refill.',
                style: TextStyle(
                  fontSize: 15,
                  height: 1.6,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 48),
        
        // Recommendation Section
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Recommendation',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                task['recommendation'] ?? 
                'Must be serviced by certified external contractor. Issue beyond in-house team scope.',
                style: TextStyle(
                  fontSize: 15,
                  height: 1.6,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          ElevatedButton(
            onPressed: () {
              // Handle next action for work order permit
              Navigator.of(context).pop();
              WorkOrderPermitDialog.show(context, task);
            },
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
            child: const Text(
              'Next',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriorityChip(String priority) {
    Color bgColor;
    Color textColor;
    switch (priority.toLowerCase()) {
      case 'high':
        bgColor = const Color(0xFFFFEBEE);
        textColor = const Color(0xFFD32F2F);
        break;
      case 'medium':
        bgColor = const Color(0xFFFFF3E0);
        textColor = const Color(0xFFFF8F00);
        break;
      case 'low':
        bgColor = const Color(0xFFE8F5E8);
        textColor = const Color(0xFF2E7D32);
        break;
      default:
        bgColor = const Color(0xFFFFF3E0);
        textColor = const Color(0xFFFF8F00);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        '${priority} Priority',
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: Colors.grey[700],
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  // Static method to show the dialog
  static void show(BuildContext context, Map<String, dynamic> task) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return WorkOrderConcernSlipDialog(task: task);
      },
    );
  }
}

class WorkOrderPermitDialog extends StatelessWidget {
  final Map<String, dynamic> task;

  const WorkOrderPermitDialog({
    super.key,
    required this.task,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.6,
        constraints: const BoxConstraints(
          maxWidth: 800,
          maxHeight: 900,
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
            // Header Section
            _buildHeader(context),

            // Content Section
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      task['title'] ?? 'Aircon is not cooling properly',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Details Grid
                    _buildDetailsGrid(),
                    const SizedBox(height: 32),

                    // Specific Instructions Section
                    _buildSpecificInstructions(),
                    const SizedBox(height: 32),

                    // Permit Validation Section
                    _buildPermitValidation(),
                    const SizedBox(height: 32),

                    // Contractor's Side Section
                    _buildContractorSide(),
                  ],
                ),
              ),
            ),
            
            Divider(
              color: Colors.grey[300],
              thickness: 1,
              height: 1,
            ),

            // Footer with Action Buttons
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 32, right: 24, top: 24, bottom: 16),
      child: Row(
        children: [
          const Text(
            'Work Order Permit',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const Spacer(),
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

  Widget _buildDetailsGrid() {
    return Column(
      children: [
        // First Row - Work Order ID and Date Requested
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildDetailItem(
                'WORK ORDER ID',
                task['workOrderId'] ?? 'WO-2025-00060',
              ),
            ),
            const SizedBox(width: 48),
            Expanded(
              child: _buildDetailItem(
                'DATE REQUESTED',
                task['dateRequested'] ?? 'June 15, 2025',
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Divider(
          color: Colors.grey[300],
          thickness: 1,
          height: 1,
        ),
        const SizedBox(height: 16),

        // Urgency Section
        Row(
          children: [
            _buildUrgencyChip(task['urgency'] ?? 'Medium'),
            const Spacer(),
          ],
        ),
        const SizedBox(height: 24),

        // Second Row - Requested By and Account Type
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildDetailItem(
                'REQUESTED BY',
                task['requestedBy'] ?? 'Erika De Guzman',
              ),
            ),
            const SizedBox(width: 48),
            Expanded(
              child: _buildDetailItem(
                'ACCOUNT TYPE',
                task['accountType'] ?? 'Air Conditioning',
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Third Row - Building & Unit No.
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildDetailItem(
                'BLDG & UNIT NO.',
                task['buildingUnit'] ?? 'A - 1010',
              ),
            ),
            const SizedBox(width: 48),
            const Expanded(child: SizedBox()), // Empty space for alignment
          ],
        ),
      ],
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.grey[600],
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildSpecificInstructions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(
          color: Colors.grey[300],
          thickness: 1,
          height: 1,
        ),
        const SizedBox(height: 16),
        const Text(
          'Specific Instructions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          task['specificInstructions'] ?? 
          'Replace fan motor and refill refrigerant. Indoor and outdoor access needed. Power shutdown may be required. Coordinate with admin.',
          style: TextStyle(
            fontSize: 15,
            height: 1.6,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 16),
        Divider(
          color: Colors.grey[300],
          thickness: 1,
          height: 1,
        ),
      ],
    );
  }

  Widget _buildPermitValidation() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Permit Validation',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        _buildDetailItem(
          'SCHEDULE VISIBILITY',
          task['scheduleVisibility'] ?? 'July 21, 2025 – From 9:00 AM to 11:30 AM',
        ),
        const SizedBox(height: 16),
        Divider(
          color: Colors.grey[300],
          thickness: 1,
          height: 1,
        ),
      ],
    );
  }

  Widget _buildContractorSide() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Contractor\'s Side',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 24),
        
        // Contractor Details Row
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildDetailItem(
                'NAME',
                task['contractorName'] ?? 'Leo Fernandez',
              ),
            ),
            const SizedBox(width: 32),
            Expanded(
              child: _buildDetailItem(
                'COMPANY NAME',
                task['companyName'] ?? 'AC Pro Services',
              ),
            ),
            const SizedBox(width: 32),
            Expanded(
              child: _buildDetailItem(
                'PHONE NUMBER',
                task['phoneNumber'] ?? '0917-456-7890',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Cancel Request Button
          ElevatedButton(
            onPressed: () {
              // Handle cancel request
              _showCancelConfirmation(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE53E3E),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 16,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.cancel_outlined,
                  size: 18,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Cancel Request',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          
          // Approved Button
          ElevatedButton(
            onPressed: () {
              // Handle approval
              _handleApproval(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF38A169),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 16,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check,
                  size: 18,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Approved',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUrgencyChip(String urgency) {
    Color bgColor;
    Color textColor;
    switch (urgency.toLowerCase()) {
      case 'high':
        bgColor = const Color(0xFFFFEBEE);
        textColor = const Color(0xFFD32F2F);
        break;
      case 'medium':
        bgColor = const Color(0xFFFFF3E0);
        textColor = const Color(0xFFFF8F00);
        break;
      case 'low':
        bgColor = const Color(0xFFE8F5E8);
        textColor = const Color(0xFF2E7D32);
        break;
      default:
        bgColor = const Color(0xFFFFF3E0);
        textColor = const Color(0xFFFF8F00);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        '${urgency} Urgency',
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  void _showCancelConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cancel Request'),
          content: const Text('Are you sure you want to cancel this work order permit request?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close confirmation
                Navigator.of(context).pop(); // Close work order dialog
                // Add your cancel logic here
              },
              child: const Text('Yes, Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _handleApproval(BuildContext context) {
    // Add your approval logic here
    Navigator.of(context).pop();
    // Show success message or navigate to next screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Work order permit approved successfully!'),
        backgroundColor: Color(0xFF38A169),
      ),
    );
  }

  // Static method to show the dialog
  static void show(BuildContext context, Map<String, dynamic> task) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return WorkOrderPermitDialog(task: task);
      },
    );
  }
}