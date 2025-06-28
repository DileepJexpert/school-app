import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/admission_data.dart';


class StudentApiService {
  static const String _baseUrl = "http://localhost:8080/api";

  // --- ADD THIS NEW METHOD ---
  static Future<List<Student>> getStudents() async {
    final response = await http.get(Uri.parse('$_baseUrl/students'));

    if (response.statusCode == 200) {
      // If the server returns a 200 OK response, parse the JSON.
      final List<dynamic> studentJsonList = jsonDecode(response.body);
      // Use the Student.fromJson constructor we created to map over the list.
      return studentJsonList.map((json) => Student.fromJson(json)).toList();
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load students');
    }
  }


  // Your existing submitAdmission method remains here
  static Future<void> submitAdmission(Student studentData) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/students/add'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(studentData.toJson()),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to submit admission. Status Code: ${response.statusCode}. Body: ${response.body}');
    }
  }


  // --- THIS IS THE NEW METHOD FOR THE VIEW FEATURE ---
  /// Fetches a single student by their unique ID.
  /// This is used for the "View Details" page.
  static Future<Student> getStudentById(String studentId) async {
    final response = await http.get(Uri.parse('$_baseUrl/students/$studentId'));

    if (response.statusCode == 200) {
      // If the server returns a 200 OK response, parse the single student JSON.
      return Student.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 404) {
      // Handle the case where the student is not found on the server.
      throw Exception('Student with ID $studentId not found.');
    } else {
      // Handle other potential errors.
      throw Exception('Failed to load student details. Status code: ${response.statusCode}');
    }
  }

  // ... inside student_api_service.dart

  /// Updates an existing student's data on the server.
  static Future<void> updateStudent(String studentId, Student studentData) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/students/$studentId'), // Uses PUT and includes the ID
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(studentData.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update student. Status Code: ${response.statusCode}. Body: ${response.body}');
    }
  }
}