import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EnquiryPage extends StatefulWidget {
  @override
  _EnquiryPageState createState() => _EnquiryPageState();
}

class _EnquiryPageState extends State<EnquiryPage> {
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  // Form fields
  String _name = '';
  String _email = '';
  String _phone = '';
  String _enquiryType = 'General';
  String _message = '';
  bool _newsletterOptIn = true;

  final List<String> _enquiryTypes = [
    'General',
    'Admissions',
    'Academics',
    'Fees',
    'Facilities',
    'Transportation',
    'Other'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Enquiry Form'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderSection(),
            SizedBox(height: 24),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildContactInfoSection(),
                  SizedBox(height: 24),
                  _buildEnquirySection(),
                  SizedBox(height: 24),
                  _buildSubmitButton(),
                ],
              ),
            ),
            SizedBox(height: 32),
            _buildContactDetailsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Contact Us',
          style: GoogleFonts.oswald(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.teal.shade800,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Have questions? Fill out the form below and we\'ll get back to you soon.',
          style: GoogleFonts.roboto(
            fontSize: 16,
            color: Colors.grey.shade700,
          ),
        ),
        SizedBox(height: 8),
        Container(
          height: 4,
          width: 80,
          color: Colors.teal,
        ),
      ],
    );
  }

  Widget _buildContactInfoSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Your Information',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.teal.shade700,
              ),
            ),
            SizedBox(height: 16),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Full Name',
                prefixIcon: Icon(Icons.person),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your name';
                }
                return null;
              },
              onSaved: (value) => _name = value!,
            ),
            SizedBox(height: 16),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Email Address',
                prefixIcon: Icon(Icons.email),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email';
                }
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                  return 'Please enter a valid email';
                }
                return null;
              },
              onSaved: (value) => _email = value!,
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 16),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Phone Number',
                prefixIcon: Icon(Icons.phone),
              ),
              onSaved: (value) => _phone = value ?? '',
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Checkbox(
                  value: _newsletterOptIn,
                  onChanged: (value) {
                    setState(() {
                      _newsletterOptIn = value!;
                    });
                  },
                  activeColor: Colors.teal,
                ),
                Expanded(
                  child: Text(
                    'Subscribe to our newsletter',
                    style: GoogleFonts.roboto(fontSize: 14),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnquirySection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Your Enquiry',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.teal.shade700,
              ),
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _enquiryType,
              decoration: InputDecoration(
                labelText: 'Enquiry Type',
                prefixIcon: Icon(Icons.category),
              ),
              items: _enquiryTypes.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _enquiryType = value!;
                });
              },
            ),
            SizedBox(height: 16),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Your Message',
                alignLabelWithHint: true,
                prefixIcon: Icon(Icons.message),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your message';
                }
                if (value.length < 10) {
                  return 'Please provide more details';
                }
                return null;
              },
              onSaved: (value) => _message = value!,
              maxLines: 5,
              keyboardType: TextInputType.multiline,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Center(
      child: ElevatedButton(
        onPressed: _submitForm,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          'SUBMIT ENQUIRY',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildContactDetailsSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Other Ways to Reach Us',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.teal.shade700,
              ),
            ),
            SizedBox(height: 16),
            _buildContactItem(
              icon: Icons.phone,
              title: 'Phone',
              value: '+1 (555) 123-4567',
            ),
            Divider(),
            _buildContactItem(
              icon: Icons.email,
              title: 'Email',
              value: 'info@schoolname.edu',
            ),
            Divider(),
            _buildContactItem(
              icon: Icons.location_on,
              title: 'Address',
              value: '123 School Street\nEducation City, EC 12345',
            ),
            Divider(),
            _buildContactItem(
              icon: Icons.access_time,
              title: 'Office Hours',
              value: 'Monday - Friday\n8:00 AM - 4:00 PM',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.teal),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  value,
                  style: GoogleFonts.roboto(fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Here you would typically send the data to your server
      // For now, we'll just show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Thank you! We\'ve received your enquiry.'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 4),
        ),
      );

      // Reset form after submission
      _formKey.currentState!.reset();
      setState(() {
        _enquiryType = 'General';
        _newsletterOptIn = true;
      });
    }
  }
}