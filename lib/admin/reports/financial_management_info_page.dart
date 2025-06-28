// lib/pages/financial_management_info_page.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'package:url_launcher/url_launcher.dart'; // For launching URLs/email/phone

class FinancialManagementInfoPage extends StatelessWidget {
  const FinancialManagementInfoPage({super.key});

  // Helper to launch URLs (you'll need the url_launcher package)
  // Future<void> _launchURL(String urlString) async {
  //   final Uri url = Uri.parse(urlString);
  //   if (!await launchUrl(url)) {
  //     throw Exception('Could not launch $url');
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        // If this page is part of a larger app, the AppBar might be handled by a wrapper.
        // For a standalone info page, an AppBar is good.
        title: Text("Student Financial Management", style: GoogleFonts.oswald()),
        backgroundColor: colorScheme.primaryContainer, // Or your app's theme AppBar color
        elevation: 1,
        actions: [
          // Example navigation actions - adapt to your app's navigation
          TextButton(onPressed: () {/* Navigate to Home */}, child: Text("Home", style: TextStyle(color: textTheme.bodyMedium?.color))),
          TextButton(onPressed: () {/* Navigate to Features (could be this page or another) */}, child: Text("Features", style: TextStyle(color: textTheme.bodyMedium?.color))),
          TextButton(onPressed: () {/* Navigate to Help */}, child: Text("Help", style: TextStyle(color: textTheme.bodyMedium?.color))),
          TextButton(onPressed: () {/* Navigate to Contact */}, child: Text("Contact", style: TextStyle(color: textTheme.bodyMedium?.color))),
          const SizedBox(width: 10),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // b. Introduction Section
            _buildIntroductionSection(context, colorScheme, textTheme),

            // c. Ledger Management Overview
            _buildLedgerManagementOverview(context, colorScheme, textTheme),

            // d. Features Details
            _buildFeaturesDetailsSection(context, colorScheme, textTheme),

            // e. Support & Contact
            _buildSupportContactSection(context, colorScheme, textTheme),

            // f. Footer
            _buildFooter(context, colorScheme, textTheme),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, {IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 28, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.oswald(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIntroductionSection(BuildContext context, ColorScheme colorScheme, TextTheme textTheme) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      width: double.infinity,
      color: colorScheme.primary.withOpacity(0.05), // Light background color
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Your Logo - Placeholder
          Icon(Icons.account_balance_wallet_rounded, size: 60, color: colorScheme.primary),
          const SizedBox(height: 16),
          Text(
            "Streamline Your School's Finances",
            textAlign: TextAlign.center,
            style: GoogleFonts.oswald(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "Our platform simplifies student fee collection, ledger management, and financial tracking, empowering your institution with efficiency and clarity.",
            textAlign: TextAlign.center,
            style: textTheme.titleMedium?.copyWith(color: Colors.grey.shade700, height: 1.5),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 20,
            runSpacing: 15,
            alignment: WrapAlignment.center,
            children: [
              _buildFeatureHighlight(context, "Ledger Management", Icons.menu_book_outlined),
              _buildFeatureHighlight(context, "Transaction Control", Icons.edit_note_outlined),
              _buildFeatureHighlight(context, "Easy Receipts", Icons.receipt_long_outlined),
              _buildFeatureHighlight(context, "Transport Fees", Icons.directions_bus_outlined),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildFeatureHighlight(BuildContext context, String text, IconData icon) { // Added context parameter
    return Chip(
      avatar: Icon(icon, size: 18, color: Theme.of(context).colorScheme.secondary), // Used context here
      label: Text(text, style: TextStyle(fontWeight: FontWeight.w500)),
      backgroundColor: Theme.of(context).colorScheme.secondary.withOpacity(0.1), // Used context here
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
  }


  Widget _buildLedgerManagementOverview(BuildContext context, ColorScheme colorScheme, TextTheme textTheme) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(context, "Comprehensive Ledger Management", icon: Icons.account_balance_outlined),
          Text(
            "Gain complete visibility into your institution's finances with our detailed and categorized ledger system. Track every transaction and due with precision.",
            style: textTheme.bodyLarge?.copyWith(height: 1.6),
          ),
          const SizedBox(height: 20),
          _buildLedgerCategoryItem(
            context,
            icon: Icons.list_alt_outlined,
            title: "Non-Head Ledger",
            description: "Flexibly record payments or dues not tied to specific predefined fee heads, such as miscellaneous charges or unique financial items.",
          ),
          _buildLedgerCategoryItem(
            context,
            icon: Icons.category_outlined,
            title: "Headwise Ledger",
            description: "View financial transactions categorized under specific fee components (e.g., Tuition, Transport, Exam Fee) for clear income and due analysis.",
          ),
          _buildLedgerCategoryItem(
            context,
            icon: Icons.person_outline,
            title: "Individual Ledger",
            description: "Access a complete financial statement for any single student, showing all their dues, payments, discounts, and current balance.",
          ),
          _buildLedgerCategoryItem(
            context,
            icon: Icons.people_outline,
            title: "Family Ledger",
            description: "Consolidate financial information for siblings or family units, simplifying billing and providing a combined view of dues and payments.",
          ),
          const SizedBox(height: 12),
          Text(
            "Benefits: Our categorized ledgers enable improved financial tracking, accurate reporting, easier reconciliation, and enhanced transparency for both administration and parents.",
            style: textTheme.bodyMedium?.copyWith(fontStyle: FontStyle.italic, color: Colors.grey.shade700),
          ),
        ],
      ),
    );
  }

  Widget _buildLedgerCategoryItem(BuildContext context, {required IconData icon, required String title, required String description}) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 32, color: Theme.of(context).colorScheme.secondary),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600, fontSize: 18)),
                  const SizedBox(height: 4),
                  Text(description, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade800)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildFeaturesDetailsSection(BuildContext context, ColorScheme colorScheme, TextTheme textTheme) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(context, "Key Platform Features", icon: Icons.star_border_purple500_outlined),
          _buildFeatureDetailItem(
            context,
            title: "Adding Past Dues",
            description: "Easily input outstanding fees from previous sessions or unrecorded dues to ensure each student's ledger is complete and accurate. Specify amount, fee head, and due date for precise record-keeping.",
            icon: Icons.playlist_add_check_circle_outlined,
          ),
          _buildFeatureDetailItem(
            context,
            title: "Editing/Canceling Transactions",
            description: "Maintain control with the ability to modify or void transactions. Correct errors or update information with a controlled process, ensuring your financial data is always current. (Audit trails recommended for such actions).",
            icon: Icons.edit_calendar_outlined,
          ),
          _buildFeatureDetailItem(
            context,
            title: "Printing/Downloading Receipts",
            description: "Generate professional, detailed receipts for all payments instantly. Provide parents with clear records and maintain official documentation effortlessly. Receipts include student info, fee breakdown, and payment details.",
            icon: Icons.print_outlined,
          ),
          _buildFeatureDetailItem(
            context,
            title: "Managing Transport Fees",
            description: "Flexibly enable or disable transport fees for individual students based on their requirements, ensuring accurate and customized billing for optional services.",
            icon: Icons.emoji_transportation_outlined,
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureDetailItem(BuildContext context, {required String title, required String description, required IconData icon}) {
    return Card(
      elevation: 1.5,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 24, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(description, style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5)),
          ],
        ),
      ),
    );
  }

  Widget _buildSupportContactSection(BuildContext context, ColorScheme colorScheme, TextTheme textTheme) {
    // Mock support staff details
    final supportStaff = [
      {"name": "Support Team Lead: Anjali Sharma", "email": "support-lead@yourschool.com", "phone": "+91-9876543210"},
      {"name": "Technical Support: Vikram Singh", "email": "tech-support@yourschool.com", "phone": "+91-9876543211"},
    ];

    return Container(
      padding: const EdgeInsets.all(16.0),
      color: colorScheme.surfaceVariant.withOpacity(0.3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(context, "Support & Contact", icon: Icons.support_agent_outlined),
          Text(
            "Our dedicated support team is here to assist you with any queries or issues you might encounter.",
            style: textTheme.bodyLarge,
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: supportStaff.map((staff) => Card(
              elevation: 1,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: SizedBox(
                  width: 280, // Give cards a decent width
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(staff["name"]!, style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      TextButton.icon(
                        style: TextButton.styleFrom(padding: EdgeInsets.zero, alignment: Alignment.centerLeft),
                        icon: Icon(Icons.email_outlined, size: 16, color: colorScheme.primary),
                        label: Text(staff["email"]!, style: textTheme.bodyMedium?.copyWith(color: colorScheme.primary)),
                        onPressed: () { /* _launchURL('mailto:${staff["email"]}'); */ },
                      ),
                      TextButton.icon(
                        style: TextButton.styleFrom(padding: EdgeInsets.zero, alignment: Alignment.centerLeft),
                        icon: Icon(Icons.phone_outlined, size: 16, color: colorScheme.primary),
                        label: Text(staff["phone"]!, style: textTheme.bodyMedium?.copyWith(color: colorScheme.primary)),
                        onPressed: () { /* _launchURL('tel:${staff["phone"]}'); */ },
                      ),
                    ],
                  ),
                ),
              ),
            )).toList(),
          ),
          const SizedBox(height: 20),
          Center(
            child: ElevatedButton.icon(
              icon: const Icon(Icons.support_outlined),
              label: const Text("Raise a Support Ticket"),
              onPressed: () {
                // TODO: Implement navigation or modal for support ticket form
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Navigate to Support Ticket System (Placeholder)'))
                );
              },
              style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  backgroundColor: colorScheme.secondary,
                  foregroundColor: colorScheme.onSecondary
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context, ColorScheme colorScheme, TextTheme textTheme) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
      color: Colors.grey.shade800,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(onPressed: () {}, child: Text("Terms of Service", style: TextStyle(color: Colors.grey.shade300))),
              Text(" | ", style: TextStyle(color: Colors.grey.shade300)),
              TextButton(onPressed: () {}, child: Text("Privacy Policy", style: TextStyle(color: Colors.grey.shade300))),
              Text(" | ", style: TextStyle(color: Colors.grey.shade300)),
              TextButton(onPressed: () {}, child: Text("Help Center", style: TextStyle(color: Colors.grey.shade300))),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(icon: const Icon(Icons.facebook, color: Colors.white), onPressed: () {/* _launchURL('your-facebook-url'); */}),
              IconButton(icon: const Icon(Icons.camera_alt_outlined, color: Colors.white), onPressed: () {/* _launchURL('your-twitter-url'); */}), // Placeholder for Twitter/X
              IconButton(icon: const Icon(Icons.video_camera_back_outlined, color: Colors.white), onPressed: () {/* _launchURL('your-linkedin-url'); */}), // Placeholder for LinkedIn
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "© ${DateTime.now().year} Your School Name. All rights reserved.",
            style: textTheme.bodySmall?.copyWith(color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }
}

// Removed the problematic placeholder Get class
