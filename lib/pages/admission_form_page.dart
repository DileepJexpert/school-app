import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class AdmissionFormPage extends StatefulWidget {
  @override
  _AdmissionFormPageState createState() => _AdmissionFormPageState();
}

class _AdmissionFormPageState extends State<AdmissionFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  // Form fields
  String _firstName = '';
  String _lastName = '';
  DateTime? _birthDate;
  String _gender = 'Male';
  String _gradeApplyingFor = 'Grade 1';
  String _parentName = '';
  String _parentEmail = '';
  String _parentPhone = '';
  String _currentSchool = '';
  bool _agreementChecked = false;

  final List<String> _gradeOptions = [
    'Grade 1', 'Grade 2', 'Grade 3', 'Grade 4', 'Grade 5',
    'Grade 6', 'Grade 7', 'Grade 8', 'Grade 9', 'Grade 10',
    'Grade 11', 'Grade 12'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Admission Application'),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStudentSection(),
                  SizedBox(height: 24),
                  _buildParentSection(),
                  SizedBox(height: 24),
                  _buildAgreementSection(),
                  SizedBox(height: 32),
                  _buildSubmitButton(),
                ],
              ),
            ),
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
          'Admission Application Form',
          style: GoogleFonts.oswald(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.teal.shade800,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Please complete all sections of this form to apply for admission.',
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

  Widget _buildStudentSection() {
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
              'Student Information',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.teal.shade700,
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    decoration: InputDecoration(
                      labelText: 'First Name',
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter first name';
                      }
                      return null;
                    },
                    onSaved: (value) => _firstName = value!,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Last Name',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter last name';
                      }
                      return null;
                    },
                    onSaved: (value) => _lastName = value!,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => _selectBirthDate(context),
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Date of Birth',
                        prefixIcon: Icon(Icons.calendar_today),
                      ),
                      child: Text(
                        _birthDate != null
                            ? DateFormat('MM/dd/yyyy').format(_birthDate!)
                            : 'Select date',
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _gender,
                    decoration: InputDecoration(
                      labelText: 'Gender',
                      prefixIcon: Icon(Icons.transgender),
                    ),
                    items: ['Male', 'Female', 'Other'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _gender = value!;
                      });
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _gradeApplyingFor,
              decoration: InputDecoration(
                labelText: 'Grade Applying For',
                prefixIcon: Icon(Icons.school),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select grade';
                }
                return null;
              },
              items: _gradeOptions.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _gradeApplyingFor = value!;
                });
              },
            ),
            SizedBox(height: 16),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Current School (if applicable)',
                prefixIcon: Icon(Icons.school),
              ),
              onSaved: (value) => _currentSchool = value ?? '',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParentSection() {
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
              'Parent/Guardian Information',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.teal.shade700,
              ),
            ),
            SizedBox(height: 16),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Parent/Guardian Name',
                prefixIcon: Icon(Icons.person_outline),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter parent name';
                }
                return null;
              },
              onSaved: (value) => _parentName = value!,
            ),
            SizedBox(height: 16),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Email Address',
                prefixIcon: Icon(Icons.email),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter email';
                }
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                  return 'Please enter a valid email';
                }
                return null;
              },
              onSaved: (value) => _parentEmail = value!,
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 16),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Phone Number',
                prefixIcon: Icon(Icons.phone),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter phone number';
                }
                return null;
              },
              onSaved: (value) => _parentPhone = value!,
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAgreementSection() {
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
              'Terms & Conditions',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.teal.shade700,
              ),
            ),
            SizedBox(height: 16),
            Text(
              '• I certify that all information provided is accurate and complete.\n'
                  '• I understand that submission of this form does not guarantee admission.\n'
                  '• I agree to the school\'s privacy policy and terms of service.',
              style: GoogleFonts.roboto(fontSize: 14),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Checkbox(
                  value: _agreementChecked,
                  onChanged: (value) {
                    setState(() {
                      _agreementChecked = value!;
                    });
                  },
                  activeColor: Colors.teal,
                ),
                Expanded(
                  child: Text(
                    'I agree to the terms and conditions above',
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
          'SUBMIT APPLICATION',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Future<void> _selectBirthDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(Duration(days: 365 * 5)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.teal,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.teal,
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _birthDate) {
      setState(() {
        _birthDate = picked;
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate() && _agreementChecked) {
      _formKey.currentState!.save();

      // Here you would typically send the data to your server
      // For now, we'll just show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Application submitted successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      // Reset form after submission
      _formKey.currentState!.reset();
      setState(() {
        _birthDate = null;
        _agreementChecked = false;
      });
    } else if (!_agreementChecked) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please agree to the terms and conditions'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}