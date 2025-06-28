// lib/models/admission_data.dart
// This is the single source of truth for all student-related data models.

class ParentDetails {
  final String fatherName;
  final String fatherOccupation;
  final String fatherMobile;
  final String fatherEmail;
  final String motherName;
  final String motherOccupation;
  final String motherMobile;
  final String motherEmail;

  ParentDetails({
    required this.fatherName,
    required this.fatherOccupation,
    required this.fatherMobile,
    required this.fatherEmail,
    required this.motherName,
    required this.motherOccupation,
    required this.motherMobile,
    required this.motherEmail,
  });

  factory ParentDetails.fromJson(Map<String, dynamic> json) {
    return ParentDetails(
      fatherName: json['fatherName'] ?? '',
      fatherOccupation: json['fatherOccupation'] ?? '',
      fatherMobile: json['fatherMobile'] ?? '',
      fatherEmail: json['fatherEmail'] ?? '',
      motherName: json['motherName'] ?? '',
      motherOccupation: json['motherOccupation'] ?? '',
      motherMobile: json['motherMobile'] ?? '',
      motherEmail: json['motherEmail'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'fatherName': fatherName,
    'fatherOccupation': fatherOccupation,
    'fatherMobile': fatherMobile,
    'fatherEmail': fatherEmail,
    'motherName': motherName,
    'motherOccupation': motherOccupation,
    'motherMobile': motherMobile,
    'motherEmail': motherEmail,
  };
}

class ContactDetails {
  final String permanentAddress;
  final String correspondenceAddress;
  final String primaryContactNumber;

  ContactDetails({
    required this.permanentAddress,
    required this.correspondenceAddress,
    required this.primaryContactNumber,
  });

  factory ContactDetails.fromJson(Map<String, dynamic> json) {
    return ContactDetails(
      permanentAddress: json['permanentAddress'] ?? '',
      correspondenceAddress: json['correspondenceAddress'] ?? '',
      primaryContactNumber: json['primaryContactNumber'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'permanentAddress': permanentAddress,
    'correspondenceAddress': correspondenceAddress,
    'primaryContactNumber': primaryContactNumber,
  };
}

class PreviousSchoolDetails {
  final String schoolName;
  final String lastClass;
  final String board;

  PreviousSchoolDetails({
    required this.schoolName,
    required this.lastClass,
    required this.board,
  });

  factory PreviousSchoolDetails.fromJson(Map<String, dynamic> json) {
    return PreviousSchoolDetails(
      schoolName: json['schoolName'] ?? '',
      lastClass: json['lastClass'] ?? '',
      board: json['board'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'schoolName': schoolName,
    'lastClass': lastClass,
    'board': board,
  };
}

class Student {
  final String? id;
  final String fullName;
  final DateTime dateOfBirth;
  final String gender;
  final String bloodGroup;
  final String nationality;
  final String religion;
  final String motherTongue;
  final String aadharNumber;
  final String classForAdmission;
  final String academicYear;
  final DateTime dateOfAdmission;
  final String admissionNumber;

  // --- THIS IS THE FIX ---
  final String status; // Added the missing status field

  final ParentDetails parentDetails;
  final ContactDetails contactDetails;
  final PreviousSchoolDetails previousSchoolDetails;

  Student({
    this.id,
    required this.fullName,
    required this.dateOfBirth,
    required this.gender,
    required this.bloodGroup,
    required this.nationality,
    required this.religion,
    required this.motherTongue,
    required this.aadharNumber,
    required this.classForAdmission,
    required this.academicYear,
    required this.dateOfAdmission,
    required this.admissionNumber,
    required this.status, // Added to the constructor
    required this.parentDetails,
    required this.contactDetails,
    required this.previousSchoolDetails,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    DateTime? safeParse(String? dateStr) {
      return dateStr != null ? DateTime.tryParse(dateStr) : null;
    }

    return Student(
      id: json['id'],
      fullName: json['fullName'] ?? 'N/A',
      dateOfBirth: safeParse(json['dateOfBirth']) ?? DateTime.now(),
      gender: json['gender'] ?? 'N/A',
      bloodGroup: json['bloodGroup'] ?? '',
      nationality: json['nationality'] ?? '',
      religion: json['religion'] ?? '',
      motherTongue: json['motherTongue'] ?? '',
      aadharNumber: json['aadharNumber'] ?? '',
      classForAdmission: json['classForAdmission'] ?? 'N/A',
      academicYear: json['academicYear'] ?? 'N/A',
      dateOfAdmission: safeParse(json['dateOfAdmission']) ?? DateTime.now(),
      admissionNumber: json['admissionNumber'] ?? '',
      status: json['status'] ?? 'Active', // Added here with a default value
      parentDetails: ParentDetails.fromJson(json['parentDetails'] ?? {}),
      contactDetails: ContactDetails.fromJson(json['contactDetails'] ?? {}),
      previousSchoolDetails: PreviousSchoolDetails.fromJson(json['previousSchoolDetails'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'dateOfBirth': dateOfBirth.toIso8601String().substring(0, 10),
      'gender': gender,
      'bloodGroup': bloodGroup,
      'nationality': nationality,
      'religion': religion,
      'motherTongue': motherTongue,
      'aadharNumber': aadharNumber,
      'classForAdmission': classForAdmission,
      'academicYear': academicYear,
      'dateOfAdmission': dateOfAdmission.toIso8601String().substring(0, 10),
      'admissionNumber': admissionNumber,
      'status': status, // Added to the JSON sent to the server
      'parentDetails': parentDetails.toJson(),
      'contactDetails': contactDetails.toJson(),
      'previousSchoolDetails': previousSchoolDetails.toJson(),
    };
  }
}