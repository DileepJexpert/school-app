// lib/admin/pages/fee/record_fee_payment_page.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RecordFeePaymentPage extends StatelessWidget {
  const RecordFeePaymentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Record Fee Payment', style: GoogleFonts.lato()),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Center(
        child: Text(
          'Form to Record New Fee Payment',
          style: GoogleFonts.lato(fontSize: 18),
        ),
        // Implement your form here
      ),
    );
  }
}