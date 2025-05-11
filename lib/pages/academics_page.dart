import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AcademicsPage extends StatelessWidget {
  final List<AcademicProgram> programs = [
    AcademicProgram(
      title: 'Primary School',
      description: 'Our primary program focuses on foundational skills in literacy, numeracy, and social development for grades 1-5.',
      icon: Icons.school,
      color: Colors.blue.shade700,
    ),
    AcademicProgram(
      title: 'Middle School',
      description: 'The middle school curriculum challenges students with advanced subjects while developing critical thinking skills for grades 6-8.',
      icon: Icons.auto_stories,
      color: Colors.green.shade700,
    ),
    AcademicProgram(
      title: 'High School',
      description: 'Our comprehensive high school program prepares students for college and careers with diverse course offerings for grades 9-12.',
      icon: Icons.science,
      color: Colors.orange.shade700,
    ),
    AcademicProgram(
      title: 'Advanced Placement',
      description: 'College-level courses that allow students to earn credit and stand out in the admissions process.',
      icon: Icons.star,
      color: Colors.purple.shade700,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Academics'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Our Academic Programs',
              style: GoogleFonts.oswald(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.teal.shade800,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Discover our comprehensive curriculum designed to inspire and challenge students at every level.',
              style: GoogleFonts.roboto(
                fontSize: 16,
                color: Colors.grey.shade700,
              ),
            ),
            SizedBox(height: 24),
            GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: MediaQuery.of(context).size.width > 800 ? 2 : 1,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 3,
              ),
              itemCount: programs.length,
              itemBuilder: (context, index) {
                return _buildProgramCard(programs[index]);
              },
            ),
            SizedBox(height: 32),
            Text(
              'Academic Calendar',
              style: GoogleFonts.oswald(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.teal.shade800,
              ),
            ),
            SizedBox(height: 16),
            _buildCalendarEvents(),
            SizedBox(height: 32),
            Text(
              'Faculty & Resources',
              style: GoogleFonts.oswald(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.teal.shade800,
              ),
            ),
            SizedBox(height: 16),
            _buildFacultySection(),
          ],
        ),
      ),
    );
  }

  Widget _buildProgramCard(AcademicProgram program) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: program.color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                program.icon,
                size: 30,
                color: program.color,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    program.title,
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    program.description,
                    style: GoogleFonts.roboto(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarEvents() {
    final events = [
      {'date': 'Aug 15', 'title': 'First Day of School', 'description': 'School begins for all students'},
      {'date': 'Sep 5', 'title': 'Curriculum Night', 'description': 'Parents invited to learn about academic programs'},
      {'date': 'Oct 14-18', 'title': 'Fall Break', 'description': 'No classes'},
      {'date': 'Dec 20', 'title': 'Winter Break Begins', 'description': 'Last day before winter vacation'},
    ];

    return Column(
      children: events.map((event) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: ListTile(
          leading: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.teal.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                event['date']!,
                style: GoogleFonts.oswald(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal.shade800,
                ),
              ),
            ),
          ),
          title: Text(
            event['title']!,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text(
            event['description']!,
            style: GoogleFonts.roboto(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          trailing: Icon(Icons.chevron_right, color: Colors.teal),
        ),
      )).toList(),
    );
  }

  Widget _buildFacultySection() {
    return Column(
      children: [
        ListTile(
          leading: Icon(Icons.library_books, color: Colors.teal),
          title: Text('Curriculum Guides', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          subtitle: Text('Download detailed curriculum information for each grade level'),
          trailing: Icon(Icons.download, color: Colors.teal),
          onTap: () {
            // Handle download action
          },
        ),
        Divider(),
        ListTile(
          leading: Icon(Icons.people, color: Colors.teal),
          title: Text('Meet Our Faculty', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          subtitle: Text('Learn about our experienced teaching staff'),
          trailing: Icon(Icons.chevron_right, color: Colors.teal),
          onTap: () {
            // Navigate to faculty page
          },
        ),
        Divider(),
        ListTile(
          leading: Icon(Icons.computer, color: Colors.teal),
          title: Text('Learning Resources', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          subtitle: Text('Access online learning tools and materials'),
          trailing: Icon(Icons.chevron_right, color: Colors.teal),
          onTap: () {
            // Navigate to resources page
          },
        ),
      ],
    );
  }
}

class AcademicProgram {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  AcademicProgram({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}// TODO Implement this library.