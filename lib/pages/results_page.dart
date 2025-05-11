import 'package:flutter/material.dart';
import 'package:school_website/pages/results_landing_page.dart';
import '../services/results_service.dart';
import '../models/student_result.dart';

class AllResultsPage extends StatefulWidget {
  final ClassOption classOption;

  const AllResultsPage({super.key, required this.classOption});

  @override
  State<AllResultsPage> createState() => _AllResultsPageState();
}

class _AllResultsPageState extends State<AllResultsPage> {
  late Future<List<StudentResult>> _allResultsFuture;
  final ResultsService _resultsService = ResultsService();
  Map<String, List<StudentResult>> _groupedResults = {};
  List<StudentResult> _originalResults = [];

  String _searchTerm = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _loadData(
      year: widget.classOption.year,
      fileName: widget.classOption.fileName,
    );

    _searchController.addListener(() {
      setState(() {
        _searchTerm = _searchController.text.trim();
        _filterAndGroupResults(_originalResults);
      });
    });
  }

  void _loadData({required int year, required String fileName}) {
    _allResultsFuture = _resultsService.loadResultsForClassAndYear(
      year: year,
      fileName: fileName,
    );

    _allResultsFuture.then((results) {
      setState(() {
        _originalResults = results;
        _filterAndGroupResults(results);
      });
    }).catchError((error) {
      print("Error loading results: $error");
    });
  }

  void _filterAndGroupResults(List<StudentResult> results) {
    List<StudentResult> filteredResults = results;
    if (_searchTerm.isNotEmpty) {
      filteredResults = results.where((student) {
        return student.name.toLowerCase().contains(_searchTerm.toLowerCase()) ||
            student.id.toLowerCase().contains(_searchTerm.toLowerCase()) ||
            student.className.toLowerCase().contains(_searchTerm.toLowerCase());
      }).toList();
    }

    Map<String, List<StudentResult>> grouped = {};
    for (var student in filteredResults) {
      grouped.putIfAbsent(student.className, () => []).add(student);
    }

    grouped.forEach((key, value) {
      value.sort((a, b) => b.percentage.compareTo(a.percentage));
    });

    _groupedResults = grouped;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.classOption.className} Results'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search by Name, ID, or Class',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<StudentResult>>(
              future: _allResultsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Error loading results: ${snapshot.error}\nMake sure your asset paths and JSON files are correct.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Theme.of(context).colorScheme.error),
                      ),
                    ),
                  );
                } else if (snapshot.hasData && snapshot.data!.isEmpty && _searchTerm.isEmpty) {
                  return const Center(child: Text('No results found. Check your assets/data/result/ folder.'));
                } else if (_groupedResults.isEmpty && _searchTerm.isNotEmpty) {
                  return const Center(child: Text('No results match your search.'));
                }

                List<String> classNames = _groupedResults.keys.toList()..sort();

                return ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: classNames.length,
                  itemBuilder: (context, index) {
                    String className = classNames[index];
                    List<StudentResult> studentsInClass = _groupedResults[className]!;

                    return Card(
                      elevation: 3,
                      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ExpansionTile(
                        backgroundColor: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.1),
                        collapsedBackgroundColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                        shape: const Border(),
                        leading: CircleAvatar(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          child: Text(
                            '${studentsInClass.length}',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          _formatClassName(className),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        subtitle: Text('${studentsInClass.length} student(s)'),
                        children: studentsInClass.map((student) {
                          return _buildStudentResultCard(context, student);
                        }).toList(),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _formatClassName(String rawClassName) {
    return rawClassName
        .replaceAll('-', ' ')
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) => word.isNotEmpty ? word[0].toUpperCase() + word.substring(1) : '')
        .join(' ');
  }

  Widget _buildStudentResultCard(BuildContext context, StudentResult student) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    student.name,
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Chip(
                  label: Text(
                    student.grade,
                    style: textTheme.labelMedium?.copyWith(
                      color: colorScheme.onSecondaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  backgroundColor: _getGradeColor(student.grade, colorScheme),
                )
              ],
            ),
            const SizedBox(height: 4),
            Text('ID: ${student.id}', style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total: ${student.total}', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                Text('Percentage: ${student.percentage.toStringAsFixed(2)}%', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, color: colorScheme.tertiary)),
              ],
            ),
            const SizedBox(height: 10),
            Text('Marks:', style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            _buildMarksTable(student.marks, textTheme, colorScheme),
          ],
        ),
      ),
    );
  }

  Widget _buildMarksTable(Map<String, int> marks, TextTheme textTheme, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: marks.entries.map((entry) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 3.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(entry.key, style: textTheme.bodyMedium),
              Text(
                entry.value.toString(),
                style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Color _getGradeColor(String grade, ColorScheme colorScheme) {
    switch (grade.toUpperCase()) {
      case 'A+':
      case 'A':
        return Colors.green.shade100;
      case 'B+':
      case 'B':
        return Colors.blue.shade100;
      case 'C+':
      case 'C':
        return Colors.orange.shade100;
      case 'D':
        return Colors.yellow.shade200;
      default:
        return Colors.red.shade100;
    }
  }
}
