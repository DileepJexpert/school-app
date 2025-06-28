import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

// Ensure these paths are correct for your project structure
import '../../../services/student_api_service.dart';
import '../../models/admission_data.dart';

class StudentDetailPage extends StatefulWidget {
  final String studentId;

  const StudentDetailPage({
    super.key,
    required this.studentId,
  });

  @override
  State<StudentDetailPage> createState() => _StudentDetailPageState();
}

// Use a TickerProviderStateMixin for the TabController animation
class _StudentDetailPageState extends State<StudentDetailPage> with TickerProviderStateMixin {
  late Future<Student> _studentFuture;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _studentFuture = StudentApiService.getStudentById(widget.studentId);
    // Initialize the TabController with 3 tabs
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Student Profile"),
        actions: [
          // Add action buttons for editing or other tasks in the future
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit Student',
            onPressed: () { /* TODO: Implement Edit Functionality */ },
          ),
          IconButton(
            icon: const Icon(Icons.print_outlined),
            tooltip: 'Print Profile',
            onPressed: () { /* TODO: Implement Print Functionality */ },
          ),
        ],
      ),
      body: FutureBuilder<Student>(
        future: _studentFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}", style: const TextStyle(color: Colors.red)));
          }
          if (!snapshot.hasData) {
            return const Center(child: Text("Student not found."));
          }

          final student = snapshot.data!;
          return Column(
            children: [
              // --- Main Profile Header ---
              _buildProfileHeader(context, student),
              // --- Tab Bar for Sections ---
              _buildTabBar(context),
              // --- Tab Bar View for Content ---
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildProfileTabView(context, student),
                    _buildParentTabView(context, student),
                    _buildHistoryTabView(context, student),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // --- Main Header Widget ---
  Widget _buildProfileHeader(BuildContext context, Student student) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      color: theme.cardColor,
      padding: const EdgeInsets.all(24.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: theme.colorScheme.primaryContainer,
            child: Text(
              student.fullName.isNotEmpty ? student.fullName.substring(0, 1).toUpperCase() : '?',
              style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student.fullName,
                  style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                if (student.id != null)
                  Text("Student ID: ${student.id}", style: theme.textTheme.bodyLarge?.copyWith(color: Colors.grey.shade600)),
                const SizedBox(height: 4),
                Chip(
                  label: Text(student.status, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  backgroundColor: theme.colorScheme.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  // --- Tab Bar Widget ---
  Widget _buildTabBar(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      color: theme.cardColor,
      child: TabBar(
        controller: _tabController,
        labelColor: theme.colorScheme.primary,
        unselectedLabelColor: Colors.grey.shade600,
        indicatorColor: theme.colorScheme.primary,
        indicatorWeight: 3.0,
        tabs: const [
          Tab(icon: Icon(Icons.person_outline), text: "Profile"),
          Tab(icon: Icon(Icons.family_restroom_outlined), text: "Parent Details"),
          Tab(icon: Icon(Icons.history_edu_outlined), text: "Academic History"),
        ],
      ),
    );
  }

  // --- Content for "Profile" Tab ---
  Widget _buildProfileTabView(BuildContext context, Student student) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow(context, "Admission Number", student.admissionNumber),
              _buildDetailRow(context, "Academic Year", student.academicYear),
              _buildDetailRow(context, "Admission Date", DateFormat('dd MMMM, yyyy').format(student.dateOfAdmission)),
              _buildDetailRow(context, "Current Class", student.classForAdmission),
              const Divider(height: 30),
              _buildDetailRow(context, "Date of Birth", DateFormat('dd MMMM, yyyy').format(student.dateOfBirth)),
              _buildDetailRow(context, "Gender", student.gender),
              _buildDetailRow(context, "Blood Group", student.bloodGroup.isEmpty ? 'N/A' : student.bloodGroup),
              _buildDetailRow(context, "Nationality", student.nationality),
              _buildDetailRow(context, "Religion", student.religion.isEmpty ? 'N/A' : student.religion),
              _buildDetailRow(context, "Aadhar Number", student.aadharNumber.isEmpty ? 'N/A' : student.aadharNumber),
            ],
          ),
        ),
      ),
    );
  }

  // --- Content for "Parent Details" Tab ---
  Widget _buildParentTabView(BuildContext context, Student student) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Card(
            child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Father's Details", style: Theme.of(context).textTheme.titleLarge),
                    const Divider(height: 20),
                    _buildDetailRow(context, "Name", student.parentDetails.fatherName),
                    _buildDetailRow(context, "Mobile", student.parentDetails.fatherMobile),
                    _buildDetailRow(context, "Occupation", student.parentDetails.fatherOccupation),
                    _buildDetailRow(context, "Email", student.parentDetails.fatherEmail.isEmpty ? 'N/A' : student.parentDetails.fatherEmail),
                  ],
                )
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Mother's Details", style: Theme.of(context).textTheme.titleLarge),
                    const Divider(height: 20),
                    _buildDetailRow(context, "Name", student.parentDetails.motherName),
                    _buildDetailRow(context, "Mobile", student.parentDetails.motherMobile),
                    _buildDetailRow(context, "Occupation", student.parentDetails.motherOccupation),
                    _buildDetailRow(context, "Email", student.parentDetails.motherEmail.isEmpty ? 'N/A' : student.parentDetails.motherEmail),
                  ],
                )
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Contact Information", style: Theme.of(context).textTheme.titleLarge),
                    const Divider(height: 20),
                    _buildDetailRow(context, "Primary Contact", student.contactDetails.primaryContactNumber),
                    _buildDetailRow(context, "Permanent Address", student.contactDetails.permanentAddress, isMultiLine: true),
                    _buildDetailRow(context, "Correspondence Address", student.contactDetails.correspondenceAddress, isMultiLine: true),
                  ],
                )
            ),
          ),
        ],
      ),
    );
  }

  // --- Content for "Academic History" Tab ---
  Widget _buildHistoryTabView(BuildContext context, Student student) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Previous School Details", style: Theme.of(context).textTheme.titleLarge),
              const Divider(height: 20),
              _buildDetailRow(context, "School Name", student.previousSchoolDetails.schoolName.isEmpty ? 'N/A' : student.previousSchoolDetails.schoolName),
              _buildDetailRow(context, "Last Class Attended", student.previousSchoolDetails.lastClass.isEmpty ? 'N/A' : student.previousSchoolDetails.lastClass),
              _buildDetailRow(context, "Board", student.previousSchoolDetails.board.isEmpty ? 'N/A' : student.previousSchoolDetails.board),
              // You can add more academic history information here in the future
            ],
          ),
        ),
      ),
    );
  }

  // --- Reusable Helper Widget for Detail Rows ---
  Widget _buildDetailRow(BuildContext context, String label, String value, {bool isMultiLine = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey.shade700),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}