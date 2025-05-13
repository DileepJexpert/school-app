// lib/admin/pages/reports_management_page.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ReportsManagementPage extends StatelessWidget {
  const ReportsManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assessment_rounded, size: 80, color: Colors.grey.shade400),
          SizedBox(height: 20),
          Text(
            'Reports Generation Section',
            style: GoogleFonts.lato(fontSize: 22, color: Colors.grey.shade700),
          ),
          SizedBox(height: 20),
          ElevatedButton.icon(
            icon: Icon(Icons.picture_as_pdf_outlined),
            label: Text('Generate Student Reports'),
            onPressed: () {
              // Logic to generate/view student reports
            },
          ),
          SizedBox(height: 10),
          ElevatedButton.icon(
            icon: Icon(Icons.bar_chart_outlined),
            label: Text('Generate Financial Reports'),
            onPressed: () {
              // Logic to generate/view financial reports
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey.shade500),
          ),
        ],
      ),
    );
  }
}
