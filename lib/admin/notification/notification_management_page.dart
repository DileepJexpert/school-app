// lib/admin/pages/notification_management_page.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NotificationManagementPage extends StatelessWidget {
  const NotificationManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_active_outlined, size: 80, color: Colors.grey.shade400),
          SizedBox(height: 20),
          Text(
            'Notification Management Section',
            style: GoogleFonts.lato(fontSize: 22, color: Colors.grey.shade700),
          ),
          SizedBox(height: 20),
          ElevatedButton.icon(
            icon: Icon(Icons.send_outlined),
            label: Text('Send New Notification'),
            onPressed: () {
              // Navigate to Send Notification Page
            },
          ),
        ],
      ),
    );
  }
}
