import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';

class ResultUploadPage extends StatefulWidget {
  @override
  _ResultUploadPageState createState() => _ResultUploadPageState();
}

class _ResultUploadPageState extends State<ResultUploadPage> {
  File? _selectedFile;
  String _fileName = "";
  String _selectedClass = "Class 10";
  bool _isUploading = false;
  final List<String> _classes = [
    "Class 10",
    "Class 11 Science",
    "Class 11 Commerce",
    "Class 12 Science",
    "Class 12 Commerce"
  ];

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    if (result != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
        _fileName = result.files.single.name;
      });
    }
  }

  Future<void> _uploadResult() async {
    if (_selectedFile == null) return;

    setState(() {
      _isUploading = true;
    });

    try {
      // Read the JSON file
      String jsonString = await _selectedFile!.readAsString();
      final jsonData = json.decode(jsonString);

      // Validate JSON structure
      if (!_validateResultJson(jsonData)) {
        throw FormatException("Invalid result format");
      }

      // Get application documents directory
      final Directory appDocDir = await getApplicationDocumentsDirectory();
      final String classDirPath = '${appDocDir.path}/results/$_selectedClass';

      // Create directory if not exists
      await Directory(classDirPath).create(recursive: true);

      // Save the file
      final String filePath = '$classDirPath/${DateTime.now().millisecondsSinceEpoch}.json';
      await _selectedFile!.copy(filePath);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Results uploaded successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  bool _validateResultJson(Map<String, dynamic> jsonData) {
    // Basic validation - adjust according to your JSON structure
    return jsonData.containsKey('className') &&
        jsonData.containsKey('year') &&
        jsonData.containsKey('students') &&
        jsonData['students'] is List;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upload Class Results'),
        backgroundColor: Colors.teal.shade700,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Upload Class Results',
              style: GoogleFonts.oswald(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.teal.shade800,
              ),
            ),
            SizedBox(height: 20),

            // Class Selection Dropdown
            DropdownButtonFormField<String>(
              value: _selectedClass,
              decoration: InputDecoration(
                labelText: 'Select Class',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.school),
              ),
              items: _classes.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedClass = value!;
                });
              },
            ),
            SizedBox(height: 20),

            // File Selection
            ElevatedButton.icon(
              onPressed: _pickFile,
              icon: Icon(Icons.attach_file),
              label: Text('Select JSON File'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            SizedBox(height: 10),

            // Selected File Info
            if (_selectedFile != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      Icon(Icons.insert_drive_file, color: Colors.teal),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _fileName,
                          style: GoogleFonts.roboto(),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            _selectedFile = null;
                            _fileName = "";
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
            SizedBox(height: 20),

            // Upload Button
            if (_selectedFile != null)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isUploading ? null : _uploadResult,
                  icon: _isUploading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Icon(Icons.cloud_upload),
                  label: Text(_isUploading ? 'Uploading...' : 'Upload Results'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.teal.shade600,
                  ),
                ),
              ),

            // JSON Format Help
            SizedBox(height: 30),
            ExpansionTile(
              title: Text('JSON Format Requirements',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Your JSON file should follow this structure:',
                          style: GoogleFonts.roboto()),
                      SizedBox(height: 10),
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '''{
  "className": "Class 10",
  "year": "2023-2024",
  "students": [
    {
      "id": "101",
      "name": "Student Name",
      "marks": {
        "Math": 85,
        "Science": 92,
        "English": 78
      },
      "total": 255,
      "percentage": 85.0,
      "grade": "A"
    }
  ]
}''',
                          style: GoogleFonts.robotoMono(),
                        ),
                      ),
                      SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () {
                          // Generate and download a sample JSON
                          _downloadSampleJson();
                        },
                        child: Text('Download Sample JSON'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade50,
                          foregroundColor: Colors.blue.shade800,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _downloadSampleJson() async {
    final sampleJson = {
      "className": "Class 10",
      "year": "2023-2024",
      "students": [
        {
          "id": "101",
          "name": "Student Name",
          "marks": {
            "Math": 85,
            "Science": 92,
            "English": 78
          },
          "total": 255,
          "percentage": 85.0,
          "grade": "A"
        }
      ]
    };

    final Directory? downloadsDir = await getDownloadsDirectory();
    if (downloadsDir != null) {
      final file = File('${downloadsDir.path}/sample_result_format.json');
      await file.writeAsString(jsonEncode(sampleJson));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sample JSON downloaded to Downloads folder'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}