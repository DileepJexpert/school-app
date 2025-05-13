// lib/admin/pages/fee/fee_module_page.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Import the sub-pages
import 'fee_collection_page.dart';
import 'record_fee_payment_page.dart';
import 'view_fee_reports_page.dart';

class FeeModulePage extends StatelessWidget {
  const FeeModulePage({super.key});

  @override
  Widget build(BuildContext context) {
    // This page's content will be shown in the main area of the dashboard
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Fee Management Hub',
            style: GoogleFonts.lato(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColorDark,
            ),
          ),
          SizedBox(height: 20),
          Text(
            'Select an action for fee management:',
            style: GoogleFonts.lato(fontSize: 16),
          ),
          SizedBox(height: 20),
          GridView.count(
            shrinkWrap: true, // Important for GridView inside Column
            physics: NeverScrollableScrollPhysics(), // Disable GridView's scrolling
            crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 2.5, // Adjust for button-like appearance
            children: [
              _buildModuleActionCard(
                context,
                icon: Icons.add_card_outlined,
                title: 'Record Payment',
                subtitle: 'Log a new fee transaction.',
                color: Colors.green.shade600,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const RecordFeePaymentPage()),
                  );
                },
              ),
              _buildModuleActionCard(
                context,
                icon: Icons.summarize_outlined,
                title: 'View Reports',
                subtitle: 'Check fee collection & dues.',
                color: Colors.blue.shade600,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ViewFeeReportsPage()),
                  );
                },
              ),
              _buildModuleActionCard(
                context,
                icon: Icons.settings_applications_outlined,
                title: 'Fee Structures',
                subtitle: 'Define & manage fee types.',
                color: Colors.orange.shade600,
                onTap: () {
                  // Navigate to Fee Structures Page
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Navigate to Fee Structures (Placeholder)')));
                },
              ),
              // In FeeModulePage
              _buildModuleActionCard(
                context,
                icon: Icons.point_of_sale_outlined,
                title: 'Collect Fee',
                subtitle: 'Process new fee payments.',
                color: Colors.teal.shade600,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const FeeCollectionPage()),
                  );
                },
              ),
              // Add more actions as needed
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModuleActionCard(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String subtitle,
        required Color color,
        required VoidCallback onTap,
      }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: color.withOpacity(0.15),
                radius: 20,
                child: Icon(icon, size: 22, color: color),
              ),
              SizedBox(height: 12),
              Text(
                title,
                style: GoogleFonts.lato(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 4),
              Text(
                subtitle,
                style: GoogleFonts.lato(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
