import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:school_website/admin/admission/student_list_page.dart';

// --- Make sure all your page imports are correct ---
import 'fee/fee_module_page.dart';

import '../../pages/result_upload_page.dart';


class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  _AdminDashboardPageState createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  int _selectedIndex = 0;
  String _currentPageTitle = "Overview";
  Widget _currentContent = const OverviewContent();
  bool _isSideMenuVisible = true;

  void _onSelectItem(int index) {
    setState(() {
      _selectedIndex = index;
      switch (index) {
        case 0: _currentPageTitle = "Overview"; _currentContent = const OverviewContent(); break;
        case 1: _currentPageTitle = "Student Management"; _currentContent = const StudentListPage(); break;
        case 2: _currentPageTitle = "Staff Management"; _currentContent = const PlaceholderContent(pageTitle: "Staff Management"); break;
        case 3: _currentPageTitle = "Class Management"; _currentContent = const PlaceholderContent(pageTitle: "Class Management"); break;
        case 4: _currentPageTitle = "Fee Management"; _currentContent = const FeeModulePage(); break;
        case 5: _currentPageTitle = "Transport Management"; _currentContent = const PlaceholderContent(pageTitle: "Transport Management"); break;
        case 6: _currentPageTitle = "Attendance Management"; _currentContent = const PlaceholderContent(pageTitle: "Attendance Management"); break;
        case 7: _currentPageTitle = "Results Management"; _currentContent = ResultsManagementContent(navigateToUpload: () { Navigator.push(context, MaterialPageRoute(builder: (context) => ResultUploadPage())); }); break;
        case 8: _currentPageTitle = "Notification Management"; _currentContent = const PlaceholderContent(pageTitle: "Notification Management"); break;
        case 9: _currentPageTitle = "Expense Management"; _currentContent = const PlaceholderContent(pageTitle: "Expense Management"); break;
        case 10: _currentPageTitle = "Reports"; _currentContent = const PlaceholderContent(pageTitle: "Reports"); break;
        case 11: _currentPageTitle = "Event Management"; _currentContent = const PlaceholderContent(pageTitle: "Event Management"); break;
        case 12: _currentPageTitle = "Admin Settings"; _currentContent = const PlaceholderContent(pageTitle: "Admin Settings"); break;
        default: _currentPageTitle = "Overview"; _currentContent = const OverviewContent();
      }
    });

    if (MediaQuery.of(context).size.width < 700 && Navigator.canPop(context)) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = MediaQuery.of(context).size.width >= 700;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        leading: isDesktop
            ? IconButton(
          icon: const Icon(Icons.menu),
          tooltip: 'Toggle Menu',
          onPressed: () => setState(() => _isSideMenuVisible = !_isSideMenuVisible),
        )
            : null,
        title: Text(_currentPageTitle),
        centerTitle: true,
      ),
      drawer: isDesktop ? null : Drawer(child: _buildDrawerContent(context)),
      body: Row(
        children: [
          if (isDesktop && _isSideMenuVisible)
            _buildSideMenu(context),
          Expanded(
            child: _currentContent,
          ),
        ],
      ),
    );
  }

  Widget _buildSideMenu(BuildContext context) {
    return Material(
      elevation: 4.0,
      shadowColor: Colors.black26,
      child: Container(
        width: 250,
        color: Theme.of(context).cardColor,
        child: _buildDrawerContent(context),
      ),
    );
  }

  ListView _buildDrawerContent(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        DrawerHeader(
          decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.school_rounded, color: Colors.white, size: 40),
              const SizedBox(height: 8),
              Text('School Admin', style: GoogleFonts.lato(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
              Text('Management Dashboard', style: GoogleFonts.lato(color: Colors.white70, fontSize: 14)),
            ],
          ),
        ),
        _buildDrawerItem(icon: Icons.dashboard_outlined, text: 'Overview', index: 0),
        ExpansionTile(
          leading: const Icon(Icons.manage_accounts_outlined),
          title: const Text('Core Management'),
          initiallyExpanded: true,
          childrenPadding: const EdgeInsets.only(left: 25),
          children: <Widget>[
            _buildDrawerItem(icon: Icons.people_alt_outlined, text: 'Students', index: 1),
            _buildDrawerItem(icon: Icons.badge_outlined, text: 'Staff', index: 2),
            _buildDrawerItem(icon: Icons.school_outlined, text: 'Classes', index: 3),
            _buildDrawerItem(icon: Icons.receipt_long_outlined, text: 'Fees', index: 4),
            _buildDrawerItem(icon: Icons.directions_bus_outlined, text: 'Transport', index: 5),
            _buildDrawerItem(icon: Icons.rule_folder_outlined, text: 'Attendance', index: 6),
          ],
        ),
        ExpansionTile(
          leading: const Icon(Icons.miscellaneous_services_outlined),
          title: const Text('Operations'),
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
        _buildDrawerItem(icon: Icons.logout_outlined, text: 'Logout', index: 99,
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Logout functionality not implemented yet.'))
            );
          },
        ),
      ],
    );
  }

  Widget _buildDrawerItem({required IconData icon, required String text, required int index, VoidCallback? onTap}) {
    final bool isSelected = _selectedIndex == index;
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
      child: Material(
        color: isSelected ? theme.colorScheme.primary.withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onTap ?? () => _onSelectItem(index),
          borderRadius: BorderRadius.circular(8),
          hoverColor: theme.colorScheme.primary.withOpacity(0.05),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Icon(icon, color: isSelected ? theme.colorScheme.primary : Colors.grey.shade600, size: 22),
                const SizedBox(width: 16),
                Text(
                  text,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? theme.colorScheme.primary : theme.textTheme.bodyLarge?.color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// --- Placeholder and Content Widgets ---
class PlaceholderContent extends StatelessWidget {
  final String pageTitle;
  const PlaceholderContent({super.key, required this.pageTitle});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        '$pageTitle - Build This Page!',
        style: GoogleFonts.lato(fontSize: 18, color: Colors.grey.shade600),
      ),
    );
  }
}

class OverviewContent extends StatelessWidget {
  const OverviewContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Welcome Back, Admin!",
              style: GoogleFonts.lato(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.headlineMedium?.color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Here's a quick overview of your school's status.",
              style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: MediaQuery.of(context).size.width > 1200 ? 4 : (MediaQuery.of(context).size.width > 800 ? 2 : 1),
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
              childAspectRatio: 1.8,
              children: <Widget>[
                _buildStatCard(context, 'Total Students', '1,250', Icons.people_alt_rounded, Theme.of(context).colorScheme.primary),
                _buildStatCard(context, 'Total Staff', '75', Icons.badge_rounded, Colors.teal.shade600),
                _buildStatCard(context, 'Upcoming Events', '3', Icons.event_available_rounded, Colors.orange.shade700),
                _buildStatCard(context, 'Revenue (This Month)', '₹8.5L', Icons.monetization_on_rounded, Colors.pink.shade600),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon, Color color) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {},
        hoverColor: color.withOpacity(0.1),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: color.withOpacity(0.15),
                radius: 28,
                child: Icon(icon, size: 28, color: color),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      value,
                      style: GoogleFonts.lato(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      title,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade700),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ResultsManagementContent extends StatelessWidget {
  final VoidCallback navigateToUpload;
  const ResultsManagementContent({Key? key, required this.navigateToUpload}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
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
            // Style is now inherited from the global theme
          ),
        ],
      ),
    );
  }
}