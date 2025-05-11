// lib/models/student_result.dart
class StudentResult {
  final String id;
  final String name;
  final Map<String, int> marks;
  final int total;
  final double percentage;
  final String grade;
  final String className; // <<< 1. ADD THIS FIELD to store the class name

  StudentResult({
    required this.id,
    required this.name,
    required this.marks,
    required this.total,
    required this.percentage,
    required this.grade,
    required this.className, // <<< 2. Ensure it's initialized
  });

  // Factory constructor to create a StudentResult from JSON.
  // It now requires the className to be passed, as student-specific JSON
  // might not contain the className directly.
  factory StudentResult.fromJson(Map<String, dynamic> json, String aClassName) { // <<< 3. Add className parameter
    return StudentResult(
      id: json['id'] as String,
      name: json['name'] as String,
      marks: Map<String, int>.from(json['marks'] as Map),
      total: json['total'] as int,
      percentage: (json['percentage'] as num).toDouble(),
      grade: json['grade'] as String,
      className: aClassName, // <<< 4. Use the passed className
    );
  }
}

class ClassResults {
  final String className;
  final int year;
  final List<String> subjects;
  final List<StudentResult> students;

  ClassResults({
    required this.className,
    required this.year,
    required this.subjects,
    required this.students,
  });

  factory ClassResults.fromJson(Map<String, dynamic> json) {
    var studentList = json['students'] as List;
    String currentClassName = json['className'] as String; // Get the class name for this ClassResults

    List<StudentResult> students = studentList
        .map((i) => StudentResult.fromJson(i as Map<String, dynamic>, currentClassName)) // <<< 5. Pass className here
        .toList();

    return ClassResults(
      className: currentClassName,
      year: json['year'] as int,
      subjects: List<String>.from(json['subjects'] as List),
      students: students,
    );
  }
}