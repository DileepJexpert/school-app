// lib/admin/pages/fee/view_fee_reports_page.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ViewFeeReportsPage extends StatelessWidget {
  const ViewFeeReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('View Fee Reports', style: GoogleFonts.lato()),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Center(
        child: Text(
          'Display Fee Reports Here',
          style: GoogleFonts.lato(fontSize: 18),
        ),
        // Implement your reports display here
      ),
    );
  }
}
