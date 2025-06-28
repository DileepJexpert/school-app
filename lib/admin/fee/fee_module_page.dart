// lib/admin/pages/fee/fee_module_page.dart
// This page acts as a hub for various fee-related actions.
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:school_website/admin/fee/transaction_history_page.dart';

// Import the sub-pages
import 'fee_collection_page.dart'; // Assuming you have this for "Collect Fee"
// import 'record_fee_payment_page.dart'; // This might be replaced by FeeCollectionPage
// import 'view_fee_reports_page.dart'; // Placeholder for actual reports page

// Import the Fee Setup Page
import 'fee_setup_page.dart'; // Assuming fee_setup_page.dart is in the same folder
import 'fee_reports_page.dart';
import 'financial_management_info_page.dart'; // Assuming fee_setup_page.dart is in the same folder

class FeeModulePage extends StatelessWidget {
  const FeeModulePage({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    // This page's content will be shown in the main area of the dashboard
    // when "Fees" is selected from the main admin drawer.
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Fee Management Hub',
            style: GoogleFonts.oswald( // Using Oswald for titles as per your main theme
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: colorScheme.primary, // Using primary color from theme
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Manage all aspects of school fees from here.',
            style: textTheme.titleMedium?.copyWith(color: Colors.grey.shade700),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: GridView.count(
              crossAxisCount: MediaQuery.of(context).size.width > 700 ? 3 : 2, // Responsive columns
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.8, // Adjust for card content
              children: [
                _buildModuleActionCard(
                  context,
                  icon: Icons.point_of_sale_outlined,
                  title: 'Collect Fees',
                  subtitle: 'Process new fee payments from students.',
                  color: Colors.teal.shade600,
                  onTap: () {
                    // Navigate to your actual FeeCollectionPage
                    Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const FeeCollectionPage())
                    );
                    // ScaffoldMessenger.of(context).showSnackBar(
                    //     const SnackBar(content: Text('Navigate to Fee Collection Page (Placeholder)')));
                  },
                ),
                _buildModuleActionCard(
                  context,
                  icon: Icons.settings_applications_outlined,
                  title: 'Fee Structure Setup', // Updated title
                  subtitle: 'Define or update fee structures for classes.', // Updated subtitle
                  color: Colors.blue.shade700,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const FeeSetupPage()),
                    );
                  },
                ),
                _buildModuleActionCard(
                  context,
                  icon: Icons.summarize_outlined,
                  title: 'Fee Reports',
                  subtitle: 'View fee collection summaries and dues.',
                  color: Colors.orange.shade700,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const FeeReportsPage()),
                    );
                  },
                ),
                _buildModuleActionCard(
                  context,
                  icon: Icons.receipt_long_outlined,
                  title: 'View Transactions',
                  subtitle: 'Browse all fee payment transactions.',
                  color: Colors.purple.shade600,
                  onTap: () {
                    // TODO: Navigate to Transaction History Page
                    Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const TransactionHistoryPage()),
    );},
                ),
                _buildModuleActionCard(
                  context,
                  icon: Icons.discount_outlined,
                  title: 'Discounts & Waivers',
                  subtitle: 'Manage fee concessions and scholarships.',
                  color: Colors.red.shade400,
                  onTap: () {
                    // TODO: Navigate to Discounts Page
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Navigate to Discounts Page (Not Implemented Yet)')));
                  },
                ),
                // Add more fee-related actions as needed
              ],
            ),
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
      clipBehavior: Clip.antiAlias, // Ensures InkWell ripple effect respects border radius
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start, // Align content to the top
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: color.withOpacity(0.15),
                radius: 24, // Slightly larger avatar
                child: Icon(icon, size: 26, color: color),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: GoogleFonts.lato( // Consistent font
                  fontSize: 17, // Slightly larger title
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.titleLarge?.color,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              Expanded( // Allow subtitle to take available space and wrap
                child: Text(
                  subtitle,
                  style: GoogleFonts.lato(
                    fontSize: 13,
                    color: Colors.grey.shade700,
                  ),
                  // maxLines: 2, // Allow subtitle to wrap to 2 lines
                  // overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
