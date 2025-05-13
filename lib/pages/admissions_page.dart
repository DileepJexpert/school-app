import 'package:flutter/material.dart';

class AdmissionsPage extends StatelessWidget {
  const AdmissionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Admissions Open - Academic Year 2025-26",
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.teal.shade700,
              )),
          SizedBox(height: 16),

          Text("Available Classes",
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
          SizedBox(height: 8),
          _buildBulletList([
            "Pre-Nursery",
            "Nursery",
            "LKG & UKG",
            "Classes 1 to 8",
          ]),

          SizedBox(height: 24),

          Text("Admission Process",
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
          SizedBox(height: 8),
          Text(
            "1. Fill out the online admission form under the 'Admission Form' section.\n"
                "2. Submit scanned copies of the child’s birth certificate and previous academic records (if applicable).\n"
                "3. A confirmation call/email will be sent by the school admin within 3–5 working days.\n"
                "4. An informal interaction session (for classes Nursery to 1) or a basic entrance test (for classes 2 and above) will be conducted.\n"
                "5. Upon selection, fee payment and document verification will finalize the admission.",
            style: Theme.of(context).textTheme.bodyLarge,
          ),

          SizedBox(height: 24),

          Text("Rules & Regulations",
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
          SizedBox(height: 8),
          _buildBulletList([
            "Admissions are granted purely on merit and seat availability.",
            "Submission of false documents will lead to cancellation of admission.",
            "Parents must ensure the child meets age criteria: 3+ years for Nursery, 4+ years for LKG, etc.",
            "Admission once confirmed is non-transferable.",
          ]),

          SizedBox(height: 24),

          Text("Required Documents",
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
          SizedBox(height: 8),
          _buildBulletList([
            "Birth certificate of the child",
            "Recent passport-size photographs (4 copies)",
            "Aadhar card (student and parents)",
            "Transfer Certificate (if applicable)",
            "Previous year’s report card (for Class 2 and above)",
          ]),

          SizedBox(height: 32),
          Center(
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/admission-form');
              },
              icon: Icon(Icons.edit_document),
              label: Text("Fill Admission Form"),
              style: ElevatedButton.styleFrom(padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBulletList(List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items
          .map((item) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("• ", style: TextStyle(fontSize: 18)),
            Expanded(child: Text(item, style: TextStyle(fontSize: 16))),
          ],
        ),
      ))
          .toList(),
    );
  }
}
