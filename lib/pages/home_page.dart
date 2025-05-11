import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:school_website/pages/results_landing_page.dart';
import 'package:school_website/pages/fee_details_page.dart';
import 'package:school_website/pages/academics_page.dart';
import 'package:school_website/pages/admission_form_page.dart';
import 'package:school_website/pages/enquiry_page.dart';
import 'package:school_website/pages/gallery_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Widget _currentPage = DefaultLandingContent();
// Add this variable to track admin status (you'll replace this with your actual auth logic)
  bool _isAdmin = true; // Set to false for non-admin users
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

  void _navigateTo(String routeName) {
    setState(() {
      if (routeName == '/admissions') {
        _currentPage = AdmissionsPage();
      } else if (routeName == '/campus') {
        _currentPage = CampusPage();
      } else if (routeName == '/results') {
        _currentPage = ResultsLandingPage();
      } else if (routeName == '/contact') {
        _currentPage = ContactPage();
      } else if (routeName == '/gallery') {
        _currentPage = GalleryPage();
      } else if (routeName == '/fee-details') {
        _currentPage = FeeDetailsPage();
      } else if (routeName == '/academics') {
        _currentPage = AcademicsPage();
      } else if (routeName == '/admission-form') {
        _currentPage = AdmissionFormPage();
      } else if (routeName == '/enquiry') {
        _currentPage = EnquiryPage();
      } else {
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
          // Add Admin Dropdown Menu
          if (_isAdmin) _buildAdminDropdown(context),


          SizedBox(width: 20),
        ],
      ),
      body: _currentPage,
    );
  }
  Widget _buildAdminDropdown(BuildContext context) {
    return PopupMenuButton<String>(
      icon: Icon(Icons.admin_panel_settings, color: Colors.white),
      onSelected: (value) {
        if (value == 'upload_results') {
          Navigator.pushNamed(context, '/result-upload');
        } else if (value == 'upload_gallery') {
          Navigator.pushNamed(context, '/result-gallery-upload');
        }
      },
      itemBuilder: (BuildContext context) {
        return [
          PopupMenuItem<String>(
            value: 'upload_results',
            child: Row(
              children: [
                Icon(Icons.upload_file, color: Colors.teal),
                SizedBox(width: 8),
                Text('Upload Results'),
              ],
            ),
          ),
          PopupMenuItem<String>(
            value: 'upload_gallery',
            child: Row(
              children: [
                Icon(Icons.photo_library, color: Colors.teal),
                SizedBox(width: 8),
                Text('Upload Gallery'),
              ],
            ),
          ),
          PopupMenuDivider(),
          PopupMenuItem<String>(
            value: 'admin_dashboard',
            child: Row(
              children: [
                Icon(Icons.dashboard, color: Colors.teal),
                SizedBox(width: 8),
                Text('Admin Dashboard'),
              ],
            ),
          ),
        ];
      },
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
        style: TextButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))
        ),
      ),
    );
  }
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
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome to Our School',
              style: GoogleFonts.oswald(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.teal.shade800,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Please select an option below',
              style: GoogleFonts.roboto(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
            SizedBox(height: 24),
            GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: MediaQuery.of(context).size.width > 600 ? 4 : 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.9,
              ),
              itemCount: features.length,
              itemBuilder: (context, index) {
                return FeatureCard(
                  icon: features[index].icon,
                  label: features[index].label,
                  description: features[index].description,
                  color: features[index].color,
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => _getPageForRoute(features[index].route),
                    ));
                  },
                );
              },
            ),
            SizedBox(height: 40),
            // Keep your existing welcome content if needed
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Explore our offerings using the menu above.',
                      style: Theme.of(context).textTheme.titleLarge),
                  SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => AdmissionFormPage())),
                    child: Text('Apply Now'),
                  )
                ],
              ),
            ),
          ],
        ),
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 30,
                  color: color,
                ),
              ),
              SizedBox(height: 12),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 8),
              Text(
                description,
                textAlign: TextAlign.center,
                style: GoogleFonts.roboto(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Placeholder pages (keep your existing ones and add new ones)
class AdmissionsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Center(child: Text("Admissions Page", style: Theme.of(context).textTheme.headlineMedium));
}

class CampusPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Center(child: Text("Campus Page", style: Theme.of(context).textTheme.headlineMedium));
}

class ContactPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Center(child: Text("Contact Us Page", style: Theme.of(context).textTheme.headlineMedium));
}