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
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'School Name',
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.blue,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
        ),
        fontFamily: GoogleFonts.lato().fontFamily,
        textTheme: TextTheme(
          displayLarge: GoogleFonts.montserrat(fontSize: 52, fontWeight: FontWeight.bold),
          titleLarge: GoogleFonts.oswald(fontSize: 28, fontStyle: FontStyle.normal),
          bodyMedium: GoogleFonts.roboto(fontSize: 16),
          labelLarge: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.white),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.teal.shade700,
          elevation: 4.0,
          titleTextStyle: GoogleFonts.oswald(fontSize: 22, color: Colors.white),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal.shade600,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            textStyle: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: HomePage(),
      // Define named routes for navigation
      routes: {
        '/fee-details': (context) => FeeDetailsPage(),
        '/academics': (context) => AcademicsPage(),
        '/admission-form': (context) => AdmissionFormPage(),
        '/enquiry': (context) => EnquiryPage(),
        '/result-upload': (context) =>  ResultUploadPage(), // StatefulWidget route
        // '/result-gallery-upload': (context) => ResultGalleryUploadPage(),
      },
    );
  }
}