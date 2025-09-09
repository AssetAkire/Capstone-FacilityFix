import 'package:facilityfix/tenant/announcement.dart';
import 'package:facilityfix/tenant/home.dart';
import 'package:facilityfix/tenant/profile.dart';
import 'package:facilityfix/tenant/view_details.dart';
import 'package:facilityfix/tenant/workorder.dart';
import 'package:facilityfix/widgets/view_details.dart';
import 'package:flutter/material.dart';
import 'package:facilityfix/widgets/app&nav_bar.dart';

class ReminderPage extends StatefulWidget {
  const ReminderPage({
    super.key,
    this.requestType = 'job service request', // or 'work order permit'
  });

  /// Controls which details screen to show.
  final String requestType;

  @override
  State<ReminderPage> createState() => _ReminderPageState();
}

class _ReminderPageState extends State<ReminderPage> {
  int _selectedIndex = 1;

  final List<NavItem> _navItems = const [
    NavItem(icon: Icons.home),
    NavItem(icon: Icons.work),
    NavItem(icon: Icons.announcement_rounded),
    NavItem(icon: Icons.person),
  ];

  void _onTabTapped(int index) {
    final destinations = [
      const HomePage(),
      const WorkOrderPage(),
      const AnnouncementPage(),
      const ProfilePage(),
    ];

    if (index != _selectedIndex) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => destinations[index]),
      );
    }
  }

  Widget _buildTabContent() {
    switch (widget.requestType.toLowerCase()) {
      case 'job service permit':
        // You can change headings at call-site via notesHeading / instructionsHeading
        return DetailsPermit(
          title: 'Job Service Request',
          sectionTitle: 'Notes and Instructions',
          notesHeading: 'Notes:',
          subHeading: 'Instructions:',
          notes:
              'Jobs beyond the capabilities of the service personnel shall not be accepted. '
              'The Property Management Office nor the Condominium Corporation shall in no way '
              'be responsible or liable for any services, nor guarantee or warrant the quality of such service. '
              'It is understood that the availment of the owner or tenant of the services performed by any employee '
              'of the Condominium Corporation on behalf of and at the request of the owner or tenant shall be solely at his own risk.',
          instructions: const [
            'Unit Owner/Tenant must secure a Job Service Request form from the Property Management Office for any services/repairs inside the unit.',
            'List down all concerns prior to any services and seek advice from the Property Management Office on Building services and their corresponding rates/costs.',
            'Pay the amount to the Cashier and present the Official Receipt to the Building Engineer and/or Technician on Duty.',
            'The Building Engineer accepts the request form, validates the scope, and schedules inspection and repair works.',
            'The Building Engineer advises the assigned technician and gives further instruction.',
            'The Technician on Duty informs the Building Engineer of the status; the unit owner/tenant acknowledges upon completion.',
          ],
          onNext: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => const ViewDetailsPage(requestType: 'job service permit details'),
              ),
            );
          },
        );

      case 'work order permit':
        return DetailsPermit(
          title: 'Work Order Permit',
          sectionTitle: 'Notes and Instructions',
          notesHeading: 'NON-LIABILITY OF THE MANAGEMENT:',
          subHeading: 'TERMS AND CONDITIONS:',
          notes:
              'The Management, its officers, staff, employees and affiliates, shall not be liable for any damages, loss, death or injury '
              'caused by/or arising from the acts and/or negligence of the unit owner, tenant, contractor and other persons in respect to '
              'the construction, renovation, repairs of facilities while in, or upon the premises where the activities are being conducted '
              'whether in the interior or exterior part of the building. Unit owner, its tenant (if any), and contractor, its officers and '
              'employees, shall be jointly and severally liable for any damages, loss, death or injury caused by/or arising from their acts and/or negligence.',
          instructions: const [
            'This permit is valid only on the dates and time specified above.',
            'Submit this permit to the Engineering Office for approval at least three (3) days BEFORE the actual work schedule, signed by the Unit Owner/Authorized Representative.',
            'Approval of Work Permit is during office hours and days only.',
            'Work permit must be presented to the Guard-on-Duty for access to any area.',
            'Post a copy of this work permit on the main door during the whole duration of work to inform neighboring units and the roving guard.',
            'Working days: Monday to Friday, 8:00 AM–5:00 PM. Noisy works: 10:00 AM–5:00 PM.',
            'Cutting of tiles inside the unit is not allowed. Use the designated area. Violations: ₱2,000 per offense (deducted from Construction Bond) plus immediate work stoppage.',
            'Contractors must give their valid ID to the basement guard in exchange for the Condo Corp. Contractor ID.',
            'Contractors must wear t-shirts. Workers wearing sleeveless shirts, shorts, sandals, or slippers are not allowed to enter.',
            'Loitering in common areas is prohibited.',
            'All debris must be placed in the designated area only. Violation fee: minimum ₱500 up to ₱2,000 for debris left in hallways/common areas.',
            'All contractors and service providers are REQUIRED to follow the governing House Rules and Regulations.',
          ],
          onNext: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => const ViewDetailsPage(requestType: 'work order permit details'),
              ),
            );
          },
        );

      default:
        return const Center(child: Text('No requests found.'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: 'Reminders',
        leading: Row(
          children: const [
            BackButton(),
            SizedBox(width: 8),
          ],
        ),
      ),
      body: SafeArea(
        child: _buildTabContent(),
      ),
      bottomNavigationBar: NavBar(
        items: _navItems,
        currentIndex: _selectedIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}
