// fee_details_page.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FeeDetailsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Fee Details'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.account_balance_wallet,
                size: 60,
                color: Colors.blue,
              ),
              SizedBox(height: 20),
              Text(
                'Fee Details',
                style: GoogleFonts.oswald(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Here you can view and pay your school fees.',
                textAlign: TextAlign.center,
                style: GoogleFonts.roboto(
                  fontSize: 18,
                  color: Colors.grey.shade700,
                ),
              ),
              // Add your fee details content here
            ],
          ),
        ),
      ),
    );
  }
}