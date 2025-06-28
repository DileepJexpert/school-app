import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:school_website/admin/admission/student_detail_page.dart';


// Make sure these paths are correct for your project
import '../../../services/student_api_service.dart';
import '../../../models/admission_data.dart';
import 'new_admission_page.dart';

class StudentListPage extends StatefulWidget {
  const StudentListPage({super.key});

  @override
  State<StudentListPage> createState() => _StudentListPageState();
}

class _StudentListPageState extends State<StudentListPage> {
  List<Student>? _allStudents;
  List<Student>? _filteredStudents;
  bool _isLoading = true;
  String _error = '';

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchStudents();
    _searchController.addListener(_filterStudents);
  }

  Future<void> _fetchStudents() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });
    try {
      final students = await StudentApiService.getStudents();
      setState(() {
        _allStudents = students;
        _filteredStudents = students;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = "Failed to load students: $e";
        _isLoading = false;
      });
    }
  }

  void _filterStudents() {
    final query = _searchController.text.toLowerCase();
    if (query.isEmpty) {
      setState(() => _filteredStudents = _allStudents);
    } else {
      setState(() {
        _filteredStudents = _allStudents?.where((student) {
          return student.fullName.toLowerCase().contains(query) ||
              student.admissionNumber.toLowerCase().contains(query) ||
              student.classForAdmission.toLowerCase().contains(query);
        }).toList();
      });
    }
  }

  // --- FIX 1: Navigation logic is now in the State class ---
  /// Navigates to the admission page for either creating a new student
  /// or editing an existing one.
  void _navigateToAdmissionPage({String? studentId}) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        // If a studentId is passed, open in Edit Mode.
        // Otherwise, open in Create Mode.
        builder: (context) => NewAdmissionPage(studentId: studentId),
      ),
    );

    // If the page was popped with 'true', it means a save was successful.
    if (result == true) {
      _fetchStudents(); // Refresh the list
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
          ? _buildErrorWidget()
          : _buildStudentDataTable(),
      floatingActionButton: FloatingActionButton.extended(
        // This button always calls the navigation method without an ID to create a new student.
        onPressed: () => _navigateToAdmissionPage(),
        tooltip: 'Add New Student',
        icon: const Icon(Icons.add),
        label: const Text("New Admission"),
      ),
    );
  }

  Widget _buildErrorWidget() {
    // ... (This method remains the same)
    return Center(/* ... */);
  }

  Widget _buildStudentDataTable() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: PaginatedDataTable(
                  header: Text('All Students (${_filteredStudents?.length ?? 0})'),
                  rowsPerPage: 10,
                  columns: const [
                    DataColumn(label: Text('Adm No.')),
                    DataColumn(label: Text('Student Name')),
                    DataColumn(label: Text('Class')),
                    DataColumn(label: Text('Father\'s Name')),
                    DataColumn(label: Text('Actions')),
                  ],
                  // --- FIX 2: Pass the navigation method to the data source ---
                  source: StudentDataSource(
                    students: _filteredStudents,
                    context: context,
                    onEdit: (studentId) => _navigateToAdmissionPage(studentId: studentId),
                    // You can add onDelete here in the future
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    // ... (This method remains the same)
    return Column(/* ... */);
  }
}


// Data source for the PaginatedDataTable
class StudentDataSource extends DataTableSource {
  final List<Student>? students;
  final BuildContext context;
  // --- FIX 3: Accept callbacks for actions ---
  final Function(String) onEdit;
  // final Function(String) onDelete; // For future use

  StudentDataSource({
    required this.students,
    required this.context,
    required this.onEdit,
    // required this.onDelete,
  });

  @override
  DataRow? getRow(int index) {
    if (students == null || index >= students!.length) {
      return null;
    }
    final student = students![index];

    return DataRow.byIndex(
      index: index,
      cells: [
        DataCell(Text(student.admissionNumber)),
        DataCell(Row(
          children: [
            CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Text(student.fullName.substring(0, 1).toUpperCase()),
            ),
            const SizedBox(width: 8),
            Text(student.fullName),
          ],
        )),
        DataCell(Text(student.classForAdmission)),
        DataCell(Text(student.parentDetails.fatherName)),
        DataCell(Row(
          children: [
            IconButton(
              icon: const Icon(Icons.visibility_outlined),
              color: Colors.blue.shade700,
              tooltip: 'View Details',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => StudentDetailPage(studentId: student.id!),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              color: Colors.orange.shade700,
              tooltip: 'Edit Student',
              // --- FIX 4: Call the onEdit callback ---
              onPressed: () {
                onEdit(student.id!);
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              color: Colors.red.shade700,
              tooltip: 'Delete Student',
              onPressed: () {
                // onDelete(student.id!); // For future use
              },
            ),
          ],
        )),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => students?.length ?? 0;

  @override
  int get selectedRowCount => 0;
}