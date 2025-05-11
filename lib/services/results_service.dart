import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/student_result.dart';

class ResultsService {
  Future<List<StudentResult>> loadResultsForClassAndYear({
    required int year,
    required String fileName,
  }) async {
    try {
      final filePath = 'assets/data/result/$year/$fileName';
      final data = await rootBundle.loadString(filePath);
      final jsonData = json.decode(data) as Map<String, dynamic>;

      final List<dynamic> studentsJson = jsonData['students'];
      final classResults = studentsJson.map((student) => StudentResult(
        id: student['id'],
        name: student['name'],
        marks: Map<String, int>.from(student['marks']),
        total: student['total'],
        percentage: student['percentage'],
        grade: student['grade'],
        className: jsonData['className'] ?? 'Unknown',
      )).toList();

      return classResults;
    } catch (e) {
      throw Exception('Failed to load results: $e');
    }
  }
}
