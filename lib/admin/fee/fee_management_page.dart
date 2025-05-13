// lib/admin/pages/fee_management_page.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FeeManagementPage extends StatelessWidget {
  const FeeManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar can be part of the main dashboard, or each page can have its own
      // For simplicity here, assuming the main dashboard handles the AppBar title.
      // If you want individual AppBar titles, uncomment the AppBar below.
      // appBar: AppBar(
      //   title: Text('Fee Management', style: GoogleFonts.lato()),
      //   backgroundColor: Theme.of(context).primaryColor,
      // ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long_outlined, size: 80, color: Colors.grey.shade400),
            SizedBox(height: 20),
            Text(
              'Fee Management Section',
              style: GoogleFonts.lato(fontSize: 22, color: Colors.grey.shade700),
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              icon: Icon(Icons.add_card_outlined),
              label: Text('Record New Fee Payment'),
              onPressed: () {
                // Navigate to Record Fee Payment Page
              },
            ),
            SizedBox(height: 10),
            ElevatedButton.icon(
              icon: Icon(Icons.summarize_outlined),
              label: Text('View Fee Reports'),
              onPressed: () {
                // Navigate to Fee Reports Page
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey.shade500),
            ),
          ],
        ),
      ),
    );
  }
}
