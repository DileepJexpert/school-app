import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:school_website/pages/results_landing_page.dart';
import 'package:school_website/pages/fee_details_page.dart';
import 'package:school_website/pages/academics_page.dart';
import 'package:school_website/pages/admission_form_page.dart';
import 'package:school_website/pages/enquiry_page.dart';
import 'package:school_website/pages/gallery_page.dart';
import 'package:school_website/pages/admissions_page.dart';
import 'package:school_website/pages/campus_page.dart';
import 'package:school_website/pages/contact_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Widget _currentPage = DefaultLandingContent();
  bool _isAdmin = true;

  void _navigateTo(String routeName) {
    setState(() {
      switch (routeName) {
        case '/admissions':
          _currentPage = AdmissionsPage();
          break;
        case '/campus':
          _currentPage = CampusPage();
          break;
        case '/results':
          _currentPage = ResultsLandingPage();
          break;
        case '/contact':
          _currentPage = ContactPage();
          break;
        case '/gallery':
          _currentPage = GalleryPage();
          break;
        case '/fee-details':
          _currentPage = FeeDetailsPage();
          break;
        case '/academics':
          _currentPage = AcademicsPage();
          break;
        case '/admission-form':
          _currentPage = AdmissionFormPage();
          break;
        case '/enquiry':
          _currentPage = EnquiryPage();
          break;
        default:
          _currentPage = DefaultLandingContent();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isWideScreen = MediaQuery.of(context).size.width > 700;

    return Scaffold(
      appBar: AppBar(
        leadingWidth: isWideScreen ? 200 : 100,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset('assets/images/school_logo.png', fit: BoxFit.contain),
        ),
        title: isWideScreen ? Text("School Name") : null,
        actions: <Widget>[
          _buildMenuButton(context, 'Home', () => _navigateTo('/home')),
          _buildMenuButton(context, 'Admissions', () => _navigateTo('/admissions')),
          _buildMenuButton(context, 'Campus', () => _navigateTo('/campus')),
          _buildMenuButton(context, 'Gallery', () => _navigateTo('/gallery')),
          _buildMenuButton(context, 'Results', () => _navigateTo('/results')),
          _buildMenuButton(context, 'Contact Us', () => _navigateTo('/contact')),
          if (_isAdmin) _buildAdminDropdown(context),
          SizedBox(width: 20),
        ],
      ),
      body: _currentPage,
    );
  }

  Widget _buildMenuButton(BuildContext context, String title, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: TextButton(
        onPressed: onPressed,
        child: Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontSize: Theme.of(context).textTheme.labelLarge?.fontSize ?? 16,
          ),
        ),
      ),
    );
  }

  // Helper method to build the admin dropdown menu
  Widget _buildAdminDropdown(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.admin_panel_settings_rounded, color: Colors.white), // Ensure icon color matches AppBar
      tooltip: "Admin Actions",
      onSelected: (value) {
        if (value == 'upload_results') {
          Navigator.pushNamed(context, '/result-upload');
        } else if (value == 'upload_gallery') {
          // Make sure '/result-gallery-upload' route is defined in main.dart
          // For now, let's assume it exists or show a placeholder
          if (ModalRoute.of(context)?.settings.name != '/result-gallery-upload') { // Avoid pushing if already there (optional)
            Navigator.pushNamed(context, '/result-gallery-upload');
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Result Gallery Upload page not yet implemented or route missing.'))
            );
          }
        } else if (value == 'full_admin_dashboard') {
          Navigator.pushNamed(context, '/admin-dashboard');
        }
      },
      itemBuilder: (BuildContext context) {
        return [
          PopupMenuItem<String>(
            value: 'upload_results',
            child: Row(children: const [
              Icon(Icons.upload_file_outlined, color: Colors.black54),
              SizedBox(width: 10),
              Text('Upload Results')
            ]),
          ),
          PopupMenuItem<String>(
            value: 'upload_gallery',
            child: Row(children: const [
              Icon(Icons.photo_library_outlined, color: Colors.black54),
              SizedBox(width: 10),
              Text('Upload Gallery')
            ]),
          ),
          const PopupMenuDivider(),
          PopupMenuItem<String>(
            value: 'full_admin_dashboard',
            child: Row(children: const [
              Icon(Icons.dashboard_customize_outlined, color: Colors.black54),
              SizedBox(width: 10),
              Text('Full Admin Dashboard')
            ]),
          ),
        ];
      },
    );
  }
}

class FeatureItem {
  final IconData icon;
  final String label;
  final String route;
  final Color color;
  final String description;

  FeatureItem({
    required this.icon,
    required this.label,
    required this.route,
    required this.color,
    required this.description,
  });
}

class DefaultLandingContent extends StatelessWidget {
  final List<FeatureItem> features = [
    FeatureItem(
      icon: Icons.account_balance_wallet,
      label: 'Fee Details',
      route: '/fee-details',
      color: Colors.blue,
      description: 'View and pay school fees online',
    ),
    FeatureItem(
      icon: Icons.school,
      label: 'Academics',
      route: '/academics',
      color: Colors.green,
      description: 'Curriculum, syllabus and academic calendar',
    ),
    FeatureItem(
      icon: Icons.assignment,
      label: 'Admission Form',
      route: '/admission-form',
      color: Colors.orange,
      description: 'Apply for new admissions',
    ),
    FeatureItem(
      icon: Icons.help_outline,
      label: 'Enquiry',
      route: '/enquiry',
      color: Colors.purple,
      description: 'Have questions? Contact us',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text('Welcome to Our School',
              style: GoogleFonts.oswald(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.teal.shade800)),
          SizedBox(height: 8),
          Text('Please select an option below',
              style: GoogleFonts.roboto(fontSize: 16, color: Colors.grey.shade600)),
          SizedBox(height: 24),
          GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: features.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: MediaQuery.of(context).size.width > 600 ? 4 : 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.9,
            ),
            itemBuilder: (context, index) {
              final feature = features[index];
              return FeatureCard(
                icon: feature.icon,
                label: feature.label,
                description: feature.description,
                color: feature.color,
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => _getPageForRoute(feature.route),
                  ));
                },
              );
            },
          ),
          SizedBox(height: 30),
          ElevatedButton(
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => AdmissionFormPage())),
            child: Text('Apply Now'),
          )
        ],
      ),
    );
  }

  Widget _getPageForRoute(String route) {
    switch (route) {
      case '/fee-details':
        return FeeDetailsPage();
      case '/academics':
        return AcademicsPage();
      case '/admission-form':
        return AdmissionFormPage();
      case '/enquiry':
        return EnquiryPage();
      default:
        return DefaultLandingContent();
    }
  }
}

class FeatureCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String description;
  final Color color;
  final VoidCallback onTap;

  const FeatureCard({
    required this.icon,
    required this.label,
    required this.description,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(color: color.withOpacity(0.2), shape: BoxShape.circle),
                child: Icon(icon, size: 30, color: color),
              ),
              SizedBox(height: 12),
              Text(label,
                  style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black87)),
              SizedBox(height: 8),
              Text(description,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.roboto(fontSize: 14, color: Colors.grey.shade600)),
            ],
          ),
        ),
      ),
    );
  }
}
