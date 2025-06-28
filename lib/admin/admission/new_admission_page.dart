import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'package:file_picker/file_picker.dart';

// --- Imports for models and services ---
import '../../../services/student_api_service.dart';
import '../../../models/admission_data.dart';


class NewAdmissionPage extends StatefulWidget {
  // Make studentId optional. If it's passed, we're in "Edit Mode".
  final String? studentId;

  const NewAdmissionPage({super.key, this.studentId});

  @override
  State<NewAdmissionPage> createState() => _NewAdmissionPageState();
}

class _NewAdmissionPageState extends State<NewAdmissionPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  int _currentStep = 0;
  bool _isLoading = false;

  // A simple getter to determine the mode
  bool get _isEditMode => widget.studentId != null;

  // --- All your state variables and controllers ---
  final TextEditingController _fullNameController = TextEditingController();
  DateTime? _dateOfBirth;
  String? _selectedGender;
  final TextEditingController _bloodGroupController = TextEditingController();
  final TextEditingController _nationalityController = TextEditingController(text: "Indian");
  final TextEditingController _religionController = TextEditingController();
  final TextEditingController _motherTongueController = TextEditingController();
  final TextEditingController _aadharController = TextEditingController();
  File? _studentPhoto;
  String? _selectedClassForAdmission;
  String? _selectedAcademicYear;
  DateTime? _dateOfAdmission;
  final TextEditingController _admissionNoController = TextEditingController();
  final TextEditingController _fatherNameController = TextEditingController();
  final TextEditingController _fatherOccupationController = TextEditingController();
  final TextEditingController _fatherMobileController = TextEditingController();
  final TextEditingController _fatherEmailController = TextEditingController();
  final TextEditingController _motherNameController = TextEditingController();
  final TextEditingController _motherOccupationController = TextEditingController();
  final TextEditingController _motherMobileController = TextEditingController();
  final TextEditingController _motherEmailController = TextEditingController();
  final TextEditingController _permanentAddressController = TextEditingController();
  final TextEditingController _correspondenceAddressController = TextEditingController();
  bool _usePermanentAsCorrespondence = false;
  final TextEditingController _primaryContactController = TextEditingController();
  final TextEditingController _prevSchoolNameController = TextEditingController();
  final TextEditingController _prevSchoolClassController = TextEditingController();
  final TextEditingController _prevSchoolBoardController = TextEditingController();
  File? _tcFile;
  File? _reportCardFile;

  // Your dropdown data
  final List<String> _genders = ['Male', 'Female', 'Other'];
  final List<String> _academicYears = ["2024-2025", "2025-2026", "2026-2027"];
  final List<String> _schoolClasses = [
    "Nursery", "LKG", "UKG", "Class 1", "Class 2", "Class 3", "Class 4", "Class 5",
    "Class 6", "Class 7", "Class 8", "Class 9", "Class 10"
  ];

  @override
  void initState() {
    super.initState();
    if (_isEditMode) {
      _loadStudentDataForEdit();
    }
  }

  Future<void> _loadStudentDataForEdit() async {
    setState(() => _isLoading = true);
    try {
      final student = await StudentApiService.getStudentById(widget.studentId!);
      // Populate all controllers and state variables
      _fullNameController.text = student.fullName;
      _dateOfBirth = student.dateOfBirth;
      _selectedGender = student.gender;
      _bloodGroupController.text = student.bloodGroup;
      _nationalityController.text = student.nationality;
      _religionController.text = student.religion;
      _motherTongueController.text = student.motherTongue;
      _aadharController.text = student.aadharNumber;
      _selectedClassForAdmission = student.classForAdmission;
      _selectedAcademicYear = student.academicYear;
      _dateOfAdmission = student.dateOfAdmission;
      _admissionNoController.text = student.admissionNumber;
      _fatherNameController.text = student.parentDetails.fatherName;
      _fatherOccupationController.text = student.parentDetails.fatherOccupation;
      _fatherMobileController.text = student.parentDetails.fatherMobile;
      _fatherEmailController.text = student.parentDetails.fatherEmail;
      _motherNameController.text = student.parentDetails.motherName;
      _motherOccupationController.text = student.parentDetails.motherOccupation;
      _motherMobileController.text = student.parentDetails.motherMobile;
      _motherEmailController.text = student.parentDetails.motherEmail;
      _permanentAddressController.text = student.contactDetails.permanentAddress;
      _correspondenceAddressController.text = student.contactDetails.correspondenceAddress;
      _primaryContactController.text = student.contactDetails.primaryContactNumber;
      _prevSchoolNameController.text = student.previousSchoolDetails.schoolName;
      _prevSchoolClassController.text = student.previousSchoolDetails.lastClass;
      _prevSchoolBoardController.text = student.previousSchoolDetails.board;

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load student data: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    // Your full dispose method
    _fullNameController.dispose();
    _bloodGroupController.dispose();
    _nationalityController.dispose();
    _religionController.dispose();
    _motherTongueController.dispose();
    _aadharController.dispose();
    _admissionNoController.dispose();
    _fatherNameController.dispose();
    _fatherOccupationController.dispose();
    _fatherMobileController.dispose();
    _fatherEmailController.dispose();
    _motherNameController.dispose();
    _motherOccupationController.dispose();
    _motherMobileController.dispose();
    _motherEmailController.dispose();
    _permanentAddressController.dispose();
    _correspondenceAddressController.dispose();
    _primaryContactController.dispose();
    _prevSchoolNameController.dispose();
    _prevSchoolClassController.dispose();
    _prevSchoolBoardController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, Function(DateTime) onDateSelected) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      onDateSelected(picked);
    }
  }

  Future<void> _pickFile(Function(File) onFilePicked, {List<String>? allowedExtensions}) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: allowedExtensions != null ? FileType.custom : FileType.any,
      allowedExtensions: allowedExtensions,
    );
    if (result != null && result.files.single.path != null) {
      onFilePicked(File(result.files.single.path!));
    }
  }

  Future<void> _submitAdmissionForm() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please correct all errors in the form.')),
      );
      return;
    }
    if (_dateOfBirth == null || _selectedGender == null || _selectedClassForAdmission == null || _selectedAcademicYear == null || _dateOfAdmission == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required (*) fields.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final parentDetails = ParentDetails(
      fatherName: _fatherNameController.text,
      fatherOccupation: _fatherOccupationController.text,
      fatherMobile: _fatherMobileController.text,
      fatherEmail: _fatherEmailController.text,
      motherName: _motherNameController.text,
      motherOccupation: _motherOccupationController.text,
      motherMobile: _motherMobileController.text,
      motherEmail: _motherEmailController.text,
    );

    final contactDetails = ContactDetails(
      permanentAddress: _permanentAddressController.text,
      correspondenceAddress: _usePermanentAsCorrespondence ? _permanentAddressController.text : _correspondenceAddressController.text,
      primaryContactNumber: _primaryContactController.text,
    );

    final previousSchoolDetails = PreviousSchoolDetails(
      schoolName: _prevSchoolNameController.text,
      lastClass: _prevSchoolClassController.text,
      board: _prevSchoolBoardController.text,
    );

    final studentData = Student(
      id: widget.studentId,
      fullName: _fullNameController.text,
      dateOfBirth: _dateOfBirth!,
      gender: _selectedGender!,
      bloodGroup: _bloodGroupController.text,
      nationality: _nationalityController.text,
      religion: _religionController.text,
      motherTongue: _motherTongueController.text,
      aadharNumber: _aadharController.text,
      classForAdmission: _selectedClassForAdmission!,
      academicYear: _selectedAcademicYear!,
      dateOfAdmission: _dateOfAdmission!,
      admissionNumber: _admissionNoController.text,
      parentDetails: parentDetails,
      contactDetails: contactDetails,
      previousSchoolDetails: previousSchoolDetails,
      status: 'ACTIVE',
    );

    try {
      if (_isEditMode) {
        await StudentApiService.updateStudent(widget.studentId!, studentData);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Student updated successfully!'), backgroundColor: Colors.green),
        );
      } else {
        await StudentApiService.submitAdmission(studentData);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Admission form submitted successfully!'), backgroundColor: Colors.green),
        );
      }

      if (mounted) Navigator.of(context).pop(true);

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.redAccent),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- FIX: RESTORED THE FULL IMPLEMENTATION ---
  List<Step> _getSteps(BuildContext context, ColorScheme colorScheme, TextTheme textTheme) {
    return [
      Step(
        title: Text('Student Details', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        content: Column(
          children: <Widget>[
            TextFormField(controller: _fullNameController, decoration: const InputDecoration(labelText: 'Full Name'), validator: (value) => value!.isEmpty ? 'Please enter full name' : null),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: Text(_dateOfBirth == null ? 'Date of Birth*' : 'DOB: ${DateFormat('dd MMM, yyyy').format(_dateOfBirth!)}')),
              TextButton.icon(icon: Icon(Icons.calendar_month_outlined, color: colorScheme.primary), label: Text(_dateOfBirth == null ? 'Select Date' : 'Change'), onPressed: () => _selectDate(context, (date) => setState(() => _dateOfBirth = date))),
            ]),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Gender*'), value: _selectedGender, items: _genders.map((String g) => DropdownMenuItem<String>(value: g, child: Text(g))).toList(),
              onChanged: (value) => setState(() => _selectedGender = value), validator: (value) => value == null ? 'Please select gender' : null,
            ),
            TextFormField(controller: _bloodGroupController, decoration: const InputDecoration(labelText: 'Blood Group')),
            TextFormField(controller: _nationalityController, decoration: const InputDecoration(labelText: 'Nationality')),
            TextFormField(controller: _religionController, decoration: const InputDecoration(labelText: 'Religion')),
            TextFormField(controller: _motherTongueController, decoration: const InputDecoration(labelText: 'Mother Tongue')),
            TextFormField(controller: _aadharController, decoration: const InputDecoration(labelText: 'Aadhar Number (Optional)'), keyboardType: TextInputType.number),
            const SizedBox(height: 12),
            Row(children: [
              if (_studentPhoto != null)
                Text('Photo: ${_studentPhoto!.path.split('/').last}')
              else
                const Text('Student Photo:'),
              const Spacer(),
              TextButton.icon(icon: const Icon(Icons.photo_camera_outlined), label: Text(_studentPhoto == null ? 'Upload' : 'Change'), onPressed: () => _pickFile((file) => setState(() => _studentPhoto = file), allowedExtensions: ['jpg', 'jpeg', 'png'])),
            ]),
          ],
        ),
        isActive: _currentStep >= 0,
        state: _currentStep > 0 ? StepState.complete : StepState.indexed,
      ),
      Step(
        title: Text('Admission Details', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        content: Column(children: <Widget>[
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(labelText: 'Class for Admission*'), value: _selectedClassForAdmission, items: _schoolClasses.map((String c) => DropdownMenuItem<String>(value: c, child: Text(c))).toList(),
            onChanged: (value) => setState(() => _selectedClassForAdmission = value), validator: (value) => value == null ? 'Please select class' : null,
          ),
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(labelText: 'Academic Year*'), value: _selectedAcademicYear, items: _academicYears.map((String y) => DropdownMenuItem<String>(value: y, child: Text(y))).toList(),
            onChanged: (value) => setState(() => _selectedAcademicYear = value), validator: (value) => value == null ? 'Please select year' : null,
          ),
          Row(children: [
            Expanded(child: Text(_dateOfAdmission == null ? 'Date of Admission*' : 'Admission Date: ${DateFormat('dd MMM, yyyy').format(_dateOfAdmission!)}')),
            TextButton.icon(icon: Icon(Icons.calendar_month_outlined, color: colorScheme.primary), label: Text(_dateOfAdmission == null ? 'Select Date' : 'Change'), onPressed: () => _selectDate(context, (date) => setState(() => _dateOfAdmission = date))),
          ]),
          TextFormField(controller: _admissionNoController, decoration: const InputDecoration(labelText: 'Admission Number (if pre-assigned)')),
        ]),
        isActive: _currentStep >= 1,
        state: _currentStep > 1 ? StepState.complete : StepState.indexed,
      ),
      Step(
        title: Text('Parent/Guardian Details', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        content: Column(children: <Widget>[
          TextFormField(controller: _fatherNameController, decoration: const InputDecoration(labelText: "Father's Name*"), validator: (v) => v!.isEmpty ? "Required" : null),
          TextFormField(controller: _fatherOccupationController, decoration: const InputDecoration(labelText: "Father's Occupation")),
          TextFormField(controller: _fatherMobileController, decoration: const InputDecoration(labelText: "Father's Mobile*", prefixText: "+91 "), keyboardType: TextInputType.phone, validator: (v) => v!.isEmpty ? "Required" : (v.length < 10 ? "Invalid mobile" : null)),
          TextFormField(controller: _fatherEmailController, decoration: const InputDecoration(labelText: "Father's Email"), keyboardType: TextInputType.emailAddress),
          const SizedBox(height: 12),
          TextFormField(controller: _motherNameController, decoration: const InputDecoration(labelText: "Mother's Name*"), validator: (v) => v!.isEmpty ? "Required" : null),
          TextFormField(controller: _motherOccupationController, decoration: const InputDecoration(labelText: "Mother's Occupation")),
          TextFormField(controller: _motherMobileController, decoration: const InputDecoration(labelText: "Mother's Mobile", prefixText: "+91 "), keyboardType: TextInputType.phone),
          TextFormField(controller: _motherEmailController, decoration: const InputDecoration(labelText: "Mother's Email"), keyboardType: TextInputType.emailAddress),
        ]),
        isActive: _currentStep >= 2,
        state: _currentStep > 2 ? StepState.complete : StepState.indexed,
      ),
      Step(
        title: Text('Contact Information', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        content: Column(children: <Widget>[
          TextFormField(controller: _permanentAddressController, decoration: const InputDecoration(labelText: 'Permanent Address*'), maxLines: 2, validator: (v) => v!.isEmpty ? "Required" : null),
          CheckboxListTile(
            title: const Text("Correspondence address same as permanent address"),
            value: _usePermanentAsCorrespondence,
            onChanged: (bool? value) {
              setState(() {
                _usePermanentAsCorrespondence = value ?? false;
                if (_usePermanentAsCorrespondence) {
                  _correspondenceAddressController.text = _permanentAddressController.text;
                }
              });
            },
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
          ),
          if (!_usePermanentAsCorrespondence)
            TextFormField(controller: _correspondenceAddressController, decoration: const InputDecoration(labelText: 'Correspondence Address*'), maxLines: 2, validator: (v) => v!.isEmpty ? "Required" : null),
          TextFormField(controller: _primaryContactController, decoration: const InputDecoration(labelText: 'Primary Contact Number*', prefixText: "+91 "), keyboardType: TextInputType.phone, validator: (v) => v!.isEmpty ? "Required" : (v.length < 10 ? "Invalid mobile" : null)),
        ]),
        isActive: _currentStep >= 3,
        state: _currentStep > 3 ? StepState.complete : StepState.indexed,
      ),
      Step(
        title: Text('Previous School (If Applicable)', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        content: Column(children: <Widget>[
          TextFormField(controller: _prevSchoolNameController, decoration: const InputDecoration(labelText: 'Previous School Name')),
          TextFormField(controller: _prevSchoolClassController, decoration: const InputDecoration(labelText: 'Last Class Attended')),
          TextFormField(controller: _prevSchoolBoardController, decoration: const InputDecoration(labelText: 'Board (e.g., CBSE, ICSE)')),
          const SizedBox(height: 12),
          Row(children: [
            if (_tcFile != null)
              Text('TC: ${_tcFile!.path.split('/').last}')
            else
              const Text('Transfer Certificate (TC):'),
            const Spacer(),
            TextButton.icon(icon: const Icon(Icons.attach_file_outlined), label: Text(_tcFile == null ? 'Upload' : 'Change'), onPressed: () => _pickFile((file) => setState(() => _tcFile = file), allowedExtensions: ['pdf', 'jpg', 'png'])),
          ]),
          Row(children: [
            if (_reportCardFile != null)
              Text('Report: ${_reportCardFile!.path.split('/').last}')
            else
              const Text('Previous Report Card:'),
            const Spacer(),
            TextButton.icon(icon: const Icon(Icons.attach_file_outlined), label: Text(_reportCardFile == null ? 'Upload' : 'Change'), onPressed: () => _pickFile((file) => setState(() => _reportCardFile = file), allowedExtensions: ['pdf', 'jpg', 'png'])),
          ]),
        ]),
        isActive: _currentStep >= 4,
        state: _currentStep > 4 ? StepState.complete : StepState.indexed,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Student Profile' : 'New Student Admission'),
      ),
      body: _isLoading && _isEditMode
          ? const Center(child: CircularProgressIndicator())
          : Form(
        key: _formKey,
        child: Stepper(
          currentStep: _currentStep,
          onStepContinue: () {
            if (_currentStep < _getSteps(context, colorScheme, textTheme).length - 1) {
              setState(() {
                _currentStep += 1;
              });
            } else {
              _submitAdmissionForm();
            }
          },
          onStepCancel: () {
            if (_currentStep > 0) {
              setState(() {
                _currentStep -= 1;
              });
            }
          },
          onStepTapped: (step) => setState(() => _currentStep = step),
          steps: _getSteps(context, colorScheme, textTheme),
          controlsBuilder: (BuildContext context, ControlsDetails details) {
            return Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Row(
                children: <Widget>[
                  if (_currentStep < _getSteps(context, colorScheme, textTheme).length - 1)
                    ElevatedButton(
                      onPressed: details.onStepContinue,
                      child: const Text('Next'),
                    )
                  else
                    ElevatedButton.icon(
                      icon: _isLoading ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5)) : Icon(_isEditMode ? Icons.save_as_outlined : Icons.person_add_alt_1_rounded),
                      label: Text(_isLoading ? 'Saving...' : (_isEditMode ? 'Update Student' : 'Submit Admission')),
                      onPressed: _isLoading ? null : _submitAdmissionForm,
                    ),
                  const SizedBox(width: 12),
                  if (_currentStep > 0)
                    TextButton(
                      onPressed: details.onStepCancel,
                      child: const Text('Back'),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}