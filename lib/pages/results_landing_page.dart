import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:school_website/pages/results_page.dart';
import 'results_landing_page.dart';

class ResultsLandingPage extends StatelessWidget {
  final List<ClassOption> classOptions = [
    ClassOption('Class 10', 'class_10_results.json', 2025),
    ClassOption('Class 12 Science', 'class_12_science_results.json', 2025),
    ClassOption('Class 12 Commerce', 'class_12_commerce_results.json', 2025),
    ClassOption('Class 12 Arts', 'class_12_arts_results.json', 2025),
  ];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Results Section'),
        backgroundColor: Colors.teal.shade700,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Class to View Results',
              style: GoogleFonts.oswald(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: Colors.teal.shade800,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Choose a class below to view student results.',
              style: GoogleFonts.roboto(
                fontSize: 14,
                color: Colors.grey.shade700,
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: MediaQuery.of(context).size.width > 600 ? 2 : 1,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 2.8,
                ),
                itemCount: classOptions.length,
                itemBuilder: (context, index) {
                  return _buildClassCard(context, classOptions[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClassCard(BuildContext context, ClassOption option) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AllResultsPage(classOption: option),
              ),
            );
          },

          child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(Icons.school, size: 28, color: Colors.teal.shade700),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      option.className,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'View Results',
                      style: GoogleFonts.roboto(
                        fontSize: 13,
                        color: Colors.teal.shade600,
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class ClassOption {
  final String className;
  final String fileName;
  final int year;

  ClassOption(this.className, this.fileName, this.year);

  String get fullPath => 'assets/data/result/$year/$fileName';
}

