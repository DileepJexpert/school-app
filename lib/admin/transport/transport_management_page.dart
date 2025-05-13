// lib/admin/pages/transport_management_page.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TransportManagementPage extends StatelessWidget {
  const TransportManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.directions_bus_filled_outlined, size: 80, color: Colors.grey.shade400),
          SizedBox(height: 20),
          Text(
            'Transport Management Section',
            style: GoogleFonts.lato(fontSize: 22, color: Colors.grey.shade700),
          ),
          SizedBox(height: 20),
          ElevatedButton.icon(
            icon: Icon(Icons.add_road_outlined),
            label: Text('Manage Routes & Vehicles'),
            onPressed: () {
              // Navigate to Manage Routes Page
            },
          ),
        ],
      ),
    );
  }
}
