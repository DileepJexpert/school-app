// main.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'pages/home_page.dart';
import 'pages/fee_details_page.dart'; // New import
import 'pages/academics_page.dart'; // New import
import 'pages/admission_form_page.dart'; // New import
import 'pages/enquiry_page.dart'; // New import
//import 'pages/result_gallery_upload_page.dart'; // Add this import
import 'pages/result_upload_page.dart'; // Add this import

// Import the Admin Dashboard Page
// Adjust the path if your AdminDashboardPage is located elsewhere
import 'admin/admin_dashboard_page.dart';

void main() {
  // If your admin dashboard (or ResultUploadPage) uses Firebase,
  // make sure to initialize Firebase here:
  // WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform, // From firebase_options.dart
  // );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'School Name',
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.blue, // This will be overridden by colorScheme if provided
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          // You can define brightness here too if you want it to affect the whole colorScheme
          // brightness: Brightness.light,
        ),
        fontFamily: GoogleFonts.lato().fontFamily,
        textTheme: TextTheme(
          displayLarge: GoogleFonts.montserrat(fontSize: 52, fontWeight: FontWeight.bold),
          titleLarge: GoogleFonts.oswald(fontSize: 28, fontStyle: FontStyle.normal),
          bodyMedium: GoogleFonts.roboto(fontSize: 16),
          labelLarge: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.white), // Used for ElevatedButton text by default
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.teal.shade700,
          elevation: 4.0,
          titleTextStyle: GoogleFonts.oswald(fontSize: 22, color: Colors.white),
          iconTheme: IconThemeData(color: Colors.white), // Ensures AppBar icons are white
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal.shade600,
            foregroundColor: Colors.white, // Text and icon color for ElevatedButton
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            textStyle: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: HomePage(), // Your main landing page
      // Define named routes for navigation
      routes: {
        '/fee-details': (context) => FeeDetailsPage(),
        '/academics': (context) => AcademicsPage(),
        '/admission-form': (context) => AdmissionFormPage(),
        '/enquiry': (context) => EnquiryPage(),
        '/result-upload': (context) =>  ResultUploadPage(), // StatefulWidget route
        // '/result-gallery-upload': (context) => ResultGalleryUploadPage(),

        // Add the route for the Admin Dashboard
        '/admin-dashboard': (context) => AdminDashboardPage(),
      },
    );
  }
}
