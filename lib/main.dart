import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

// --- Your Page Imports ---
import 'pages/home_page.dart';
import 'pages/fee_details_page.dart';
import 'pages/academics_page.dart';
import 'pages/admission_form_page.dart';
import 'pages/enquiry_page.dart';
import 'pages/result_upload_page.dart';
import 'admin/admin_dashboard_page.dart';
import 'services/dio_client.dart';
/*void main() {
  usePathUrlStrategy(); // Optional: Removes '#' from URLs in web builds
  runApp(const MyApp());
}*/



void main() async { // Make main async
  // This line is needed to ensure bindings are initialized before async calls
  WidgetsFlutterBinding.ensureInitialized();

  usePathUrlStrategy(); // Optional: Removes '#' from URLs in web builds

  // Initialize your Dio client before running the app. This is the fix.
  DioClient.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Define a base text theme using Google Fonts for consistency
    final textTheme = GoogleFonts.latoTextTheme(Theme.of(context).textTheme);

    return MaterialApp(
      title: 'School Management System',
      debugShowCheckedModeBanner: false,

      // --- NEW: PROFESSIONAL SLATE & AMBER THEME ---
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF455A64), // Deep Slate Gray
          primary: const Color(0xFF37474F),   // A slightly darker slate for primary elements
          secondary: Colors.amber.shade700,    // Vibrant Amber for accents
          background: const Color(0xFFF5F5F5), // A clean, light gray background
          surface: Colors.white,
          onSurface: const Color(0xFF263238), // Very dark slate for text for high contrast
        ),
        useMaterial3: true,
        textTheme: textTheme.copyWith(
          displayLarge: textTheme.displayLarge?.copyWith(fontFamily: GoogleFonts.montserrat().fontFamily),
          titleLarge: textTheme.titleLarge?.copyWith(fontFamily: GoogleFonts.oswald().fontFamily),
          bodyMedium: textTheme.bodyMedium?.copyWith(color: const Color(0xFF37474F)), // Applying dark slate to body text
          labelLarge: textTheme.labelLarge?.copyWith(fontFamily: GoogleFonts.poppins().fontFamily),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: const Color(0xFF37474F), // Use the primary slate color
          foregroundColor: Colors.white,
          elevation: 2,
          titleTextStyle: textTheme.titleLarge?.copyWith(
            fontFamily: GoogleFonts.oswald().fontFamily,
            fontSize: 22,
            color: Colors.white,
          ),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          surfaceTintColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            // Use the amber accent color for primary buttons to make them stand out
            backgroundColor: Colors.amber.shade800,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            textStyle: textTheme.labelLarge?.copyWith(
              fontFamily: GoogleFonts.poppins().fontFamily,
              fontSize: 16,
            ),
          ),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: Colors.amber.shade800, // Use amber for the FAB
          foregroundColor: Colors.white,
        ),
      ),

      // Your routes and home page remain exactly the same.
      home: HomePage(),
      routes: {
        '/fee-details': (context) => FeeDetailsPage(),
        '/academics': (context) => AcademicsPage(),
        '/admission-form': (context) => AdmissionFormPage(),
        '/enquiry': (context) => EnquiryPage(),
        '/result-upload': (context) => ResultUploadPage(),
        '/admin-dashboard': (context) => const AdminDashboardPage(),
      },
    );
  }
}