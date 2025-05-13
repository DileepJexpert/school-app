// lib/admin/pages/admin_dashboard_page.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// --- Import Module Landing Pages ---
// Make sure these files exist in the specified paths or adjust paths accordingly.
import 'fee/fee_module_page.dart';
//import 'transport/transport_module_page.dart';
//import 'notification/notification_module_page.dart';
//import 'attendance/attendance_module_page.dart';
//import 'reports/reports_module_page.dart';
//import 'expense/expense_module_page.dart';

// --- Import Other Admin Pages ---
import 'settings/admin_settings_page.dart';
/*
import 'overview_page.dart';
import 'student_management_page.dart';
import 'staff_management_page.dart';
import 'class_management_page.dart';
import 'results_management_page.dart'; // This page will navigate to ResultUploadPage
import 'event_management_page.dart';
*/

// --- Import ResultUploadPage ---
// Adjust this path based on where ResultUploadPage is located in your project.
import '../../pages/result_upload_page.dart';


class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  _AdminDashboardPageState createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  int _selectedIndex = 0;
  String _currentPageTitle = "Overview";

  Widget _getSelectedPage() {
    switch (_selectedIndex) {
      case 0: _currentPageTitle = "Overview"; return const OverviewPage();
      case 1: _currentPageTitle = "Student Management"; return const StudentManagementPage();
      case 2: _currentPageTitle = "Staff Management"; return const StaffManagementPage();
      case 3: _currentPageTitle = "Class Management"; return const ClassManagementPage(); // This page will be shown

      case 4: _currentPageTitle = "Fee Management"; return const FeeModulePage();
      case 5: _currentPageTitle = "Transport Management"; return const TransportModulePage();
      case 6: _currentPageTitle = "Attendance Management"; return const AttendanceModulePage();
      case 7: _currentPageTitle = "Results Management";
      return ResultsManagementPage(
        navigateToUpload: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ResultUploadPage()),
          );
        },
      );
      case 8: _currentPageTitle = "Notification Management"; return const NotificationModulePage();
      case 9: _currentPageTitle = "Expense Management"; return const ExpenseModulePage();
      case 10: _currentPageTitle = "Reports"; return const ReportsModulePage();
      case 11: _currentPageTitle = "Event Management"; return const EventManagementPage();

      case 12: _currentPageTitle = "Admin Settings"; return const AdminSettingsPage();
      default: _currentPageTitle = "Overview"; return const OverviewPage();
    }
  }

  void _onSelectItem(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (MediaQuery.of(context).size.width < 700) {
      if (Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_currentPageTitle),
        centerTitle: true,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.indigo.shade700,),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.school_rounded, color: Colors.white, size: 40), // Changed icon
                  const SizedBox(height: 8),
                  Text('School Admin', style: GoogleFonts.lato(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                  Text('Management Dashboard', style: GoogleFonts.lato(color: Colors.white70, fontSize: 14)),
                ],
              ),
            ),
            _buildDrawerItem(icon: Icons.dashboard_outlined, text: 'Overview', index: 0),
            ExpansionTile(
              leading: Icon(Icons.manage_accounts_outlined, color: Colors.grey.shade700, size: 24),
              title: Text('Core Management', style: GoogleFonts.lato(fontSize: 16, color: Colors.grey.shade700)),
              childrenPadding: const EdgeInsets.only(left: 25),
              children: <Widget>[
                _buildDrawerItem(icon: Icons.people_alt_outlined, text: 'Students', index: 1),
                _buildDrawerItem(icon: Icons.badge_outlined, text: 'Staff', index: 2),
                _buildDrawerItem(icon: Icons.school_outlined, text: 'Classes', index: 3), // Changed icon
                _buildDrawerItem(icon: Icons.receipt_long_outlined, text: 'Fees', index: 4),
                _buildDrawerItem(icon: Icons.directions_bus_outlined, text: 'Transport', index: 5),
                _buildDrawerItem(icon: Icons.rule_folder_outlined, text: 'Attendance', index: 6),
              ],
            ),
            ExpansionTile(
              leading: Icon(Icons.miscellaneous_services_outlined, color: Colors.grey.shade700, size: 24),
              title: Text('Operations', style: GoogleFonts.lato(fontSize: 16, color: Colors.grey.shade700)),
              childrenPadding: const EdgeInsets.only(left: 25),
              children: <Widget>[
                _buildDrawerItem(icon: Icons.assessment_outlined, text: 'Results', index: 7),
                _buildDrawerItem(icon: Icons.notifications_active_outlined, text: 'Notifications', index: 8),
                _buildDrawerItem(icon: Icons.paid_outlined, text: 'Expenses', index: 9),
                _buildDrawerItem(icon: Icons.insert_chart_outlined, text: 'Reports', index: 10),
                _buildDrawerItem(icon: Icons.event_outlined, text: 'Events', index: 11),
              ],
            ),
            const Divider(height: 20, thickness: 1, indent: 16, endIndent: 16),
            _buildDrawerItem(icon: Icons.settings_outlined, text: 'Admin Settings', index: 12),
            _buildDrawerItem(icon: Icons.logout_outlined, text: 'Logout', index: 13,
              onTap: () {
                print("Logout tapped");
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Logout functionality not implemented yet.'))
                );
              },
            ),
          ],
        ),
      ),
      body: Row(
        children: [
          Expanded(
            child: _getSelectedPage(),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({required IconData icon, required String text, required int index, VoidCallback? onTap}) {
    final bool isSelected = _selectedIndex == index;
    final Color color = isSelected ? Theme.of(context).primaryColor : Colors.grey.shade700;
    final Color tileColor = isSelected ? Theme.of(context).primaryColor.withOpacity(0.1) : Colors.transparent;
    final FontWeight fontWeight = isSelected ? FontWeight.bold : FontWeight.normal;

    return Material(
      color: tileColor,
      child: ListTile(
        leading: Icon(icon, color: color, size: 22),
        title: Text(
          text,
          style: GoogleFonts.lato(fontSize: 15, fontWeight: fontWeight, color: color),
        ),
        selected: isSelected,
        onTap: onTap ?? () => _onSelectItem(index),
        dense: true,
        visualDensity: VisualDensity.compact,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.horizontal(right: Radius.circular(isSelected ? 20 : 0)),
        ),
        selectedTileColor: tileColor,
      ),
    );
  }
}

// --- Placeholder Module Pages (Create these in their respective subfolders) ---
class TransportModulePage extends StatelessWidget {
  const TransportModulePage({super.key});
  @override Widget build(BuildContext context) => Center(child: Text('Transport Module Hub - Build This Page!', style: GoogleFonts.lato(fontSize: 18, color: Colors.grey.shade600)));
}
class NotificationModulePage extends StatelessWidget {
  const NotificationModulePage({super.key});
  @override Widget build(BuildContext context) => Center(child: Text('Notification Module Hub - Build This Page!', style: GoogleFonts.lato(fontSize: 18, color: Colors.grey.shade600)));
}
class AttendanceModulePage extends StatelessWidget {
  const AttendanceModulePage({super.key});
  @override Widget build(BuildContext context) => Center(child: Text('Attendance Module Hub - Build This Page!', style: GoogleFonts.lato(fontSize: 18, color: Colors.grey.shade600)));
}
class ReportsModulePage extends StatelessWidget {
  const ReportsModulePage({super.key});
  @override Widget build(BuildContext context) => Center(child: Text('Reports Module Hub - Build This Page!', style: GoogleFonts.lato(fontSize: 18, color: Colors.grey.shade600)));
}
class ExpenseModulePage extends StatelessWidget {
  const ExpenseModulePage({super.key});
  @override Widget build(BuildContext context) => Center(child: Text('Expense Module Hub - Build This Page!', style: GoogleFonts.lato(fontSize: 18, color: Colors.grey.shade600)));
}

// --- Existing Placeholder Pages (from previous context or artifacts) ---
class OverviewPage extends StatelessWidget {
  const OverviewPage({super.key});
  @override
  Widget build(BuildContext context) {
    return GridView.count(
      padding: const EdgeInsets.all(16.0),
      crossAxisCount: MediaQuery.of(context).size.width > 900 ? 4 : (MediaQuery.of(context).size.width > 600 ? 2 : 1),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: MediaQuery.of(context).size.width > 600 ? 1.5 : 2.0,
      children: <Widget>[
        _buildStatCard(context, 'Total Students', '1250', Icons.people_alt_rounded, Colors.blue.shade600),
        _buildStatCard(context, 'Total Staff', '75', Icons.badge_rounded, Colors.green.shade600),
        _buildStatCard(context, 'Upcoming Events', '3', Icons.event_available_rounded, Colors.orange.shade600),
        _buildStatCard(context, 'Active Classes', '25', Icons.school_rounded, Colors.purple.shade600), // Changed icon
      ],
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            CircleAvatar(
              backgroundColor: color.withOpacity(0.15),
              radius: 28,
              child: Icon(icon, size: 30, color: color),
            ),
            const SizedBox(height: 16),
            Text(
              value,
              style: GoogleFonts.lato(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.titleLarge?.color ?? Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: GoogleFonts.lato(
                fontSize: 15,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class StudentManagementPage extends StatelessWidget {
  const StudentManagementPage({super.key});
  @override Widget build(BuildContext context) => Center(child: Text('Student Management - Build This Page!', style: GoogleFonts.lato(fontSize: 18, color: Colors.grey.shade600)));
}
class StaffManagementPage extends StatelessWidget {
  const StaffManagementPage({super.key});
  @override Widget build(BuildContext context) => Center(child: Text('Staff Management - Build This Page!', style: GoogleFonts.lato(fontSize: 18, color: Colors.grey.shade600)));
}
class ClassManagementPage extends StatelessWidget { // This is the page shown when "Classes" is selected in the drawer
  const ClassManagementPage({super.key});
  @override Widget build(BuildContext context) => Center(child: Text('Class Management Hub - Build This Page!', style: GoogleFonts.lato(fontSize: 18, color: Colors.grey.shade600)));
}

class ResultsManagementPage extends StatelessWidget {
  final VoidCallback navigateToUpload;
  const ResultsManagementPage({Key? key, required this.navigateToUpload}) : super(key: key);
  @override Widget build(BuildContext context) => Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.assessment_outlined, size: 80, color: Colors.grey),
          const SizedBox(height: 20),
          Text("Results Module Hub", style: GoogleFonts.lato(fontSize: 20, color: Colors.grey.shade700)),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            icon: const Icon(Icons.cloud_upload_outlined),
            label: const Text('Upload New Results'),
            onPressed: navigateToUpload,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.teal.shade600, foregroundColor: Colors.white),
          ),
          const SizedBox(height: 10),
          ElevatedButton.icon(
            icon: const Icon(Icons.bar_chart_outlined),
            label: const Text('View All Results'),
            onPressed: () { /* Navigate to view results page */ },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange.shade700, foregroundColor: Colors.white),
          ),
        ],
      )
  );
}
class EventManagementPage extends StatelessWidget {
  const EventManagementPage({super.key});
  @override Widget build(BuildContext context) => Center(child: Text('Event Management - Build This Page!', style: GoogleFonts.lato(fontSize: 18, color: Colors.grey.shade600)));
}
