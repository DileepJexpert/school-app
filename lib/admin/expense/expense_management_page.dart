// lib/admin/pages/expense_management_page.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ExpenseManagementPage extends StatelessWidget {
  const ExpenseManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.paid_outlined, size: 80, color: Colors.grey.shade400),
          SizedBox(height: 20),
          Text(
            'Expense Management Section',
            style: GoogleFonts.lato(fontSize: 22, color: Colors.grey.shade700),
          ),
          SizedBox(height: 20),
          ElevatedButton.icon(
            icon: Icon(Icons.post_add_outlined),
            label: Text('Add New Expense'),
            onPressed: () {
              // Navigate to Add Expense Page
            },
          ),
        ],
      ),
    );
  }
}
