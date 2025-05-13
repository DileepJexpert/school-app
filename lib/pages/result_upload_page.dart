import 'dart:convert'; // For jsonEncode, jsonDecode, utf8
import 'dart:io'; // For File, Directory (conditionally)
import 'package:flutter/foundation.dart'; // For kIsWeb
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Conditional import for dart:html for web-specific download
import 'dart:html' as html;

class ResultUploadPage extends StatefulWidget {
  @override
  _ResultUploadPageState createState() => _ResultUploadPageState();
}

class _ResultUploadPageState extends State<ResultUploadPage> {
  PlatformFile? _selectedPlatformFile;
  String _fileNameToDisplay = "";

  String _selectedClass = "Class 10";
  String _selectedYear = "2023-2024";
  bool _isUploading = false;

  // For configurable save path
  String? _configuredSavePath;
  static const String _savePathKey = 'configured_save_path';

  final List<String> _classes = [
    "Class 10", "Class 11 Science", "Class 11 Commerce", "Class 12 Science", "Class 12 Commerce"
  ];
  final List<String> _years = ["2021-2022", "2022-2023", "2023-2024", "2024-2025"];

  @override
  void initState() {
    super.initState();
    if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
      _loadConfiguredPath();
    }
  }

  Future<void> _loadConfiguredPath() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _configuredSavePath = prefs.getString(_savePathKey);
    });
    print("💾 Loaded configured save path: $_configuredSavePath");
  }

  Future<void> _saveConfiguredPath(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_savePathKey, path);
    setState(() {
      _configuredSavePath = path;
    });
    print("💾 Saved configured save path: $path");
  }

  Future<void> _pickSaveDirectory() async {
    if (kIsWeb || !(Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Custom save path is only supported on desktop platforms.")));
      return;
    }
    try {
      String? directoryPath = await FilePicker.platform.getDirectoryPath(
        dialogTitle: 'Please select a directory to save results',
      );

      if (directoryPath != null) {
        await _saveConfiguredPath(directoryPath);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Save location updated to: $directoryPath'),
            backgroundColor: Colors.green));
      }
    } catch (e) {
      print("⚠️ Error picking save directory: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error selecting directory: ${e.toString()}'),
          backgroundColor: Colors.redAccent));
    }
  }

  Future<void> _pickFile() async {
    // ... (existing _pickFile logic - no change needed here for path config)
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        withData: kIsWeb, // Crucial for web to get bytes
      );

      if (result != null && result.files.single != null) {
        setState(() {
          _selectedPlatformFile = result.files.single;
          _fileNameToDisplay = _selectedPlatformFile!.name;
        });
        print("📁 Selected file: $_fileNameToDisplay");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Selected file: $_fileNameToDisplay'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        setState(() {
          _selectedPlatformFile = null;
          _fileNameToDisplay = "";
        });
        print("🚫 File selection canceled or file was null.");
      }
    } catch (e) {
      print("⚠️ Error picking file: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking file: ${e.toString()}'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

// Inside the _ResultUploadPageState class

  Future<void> _uploadResult() async {
    if (_selectedPlatformFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Please select a JSON file first."),
          backgroundColor: Colors.orangeAccent));
      return;
    }

    setState(() { _isUploading = true; });

    try {
      String jsonString;
      String? mobileDesktopFilePath; // Path of the picked file on mobile/desktop

      if (kIsWeb) {
        final Uint8List? fileBytes = _selectedPlatformFile!.bytes;
        if (fileBytes == null) {
          throw Exception("File bytes not available for web. Please re-select the file.");
        }
        jsonString = utf8.decode(fileBytes);
      } else { // NOT kIsWeb (Mobile/Desktop)
        mobileDesktopFilePath = _selectedPlatformFile!.path;
        if (mobileDesktopFilePath == null) {
          throw Exception("File path not available for mobile/desktop.");
        }
        jsonString = await File(mobileDesktopFilePath).readAsString();
      }

      // --- JSON Decoding and Validation (remains the same) ---
      Map<String, dynamic> jsonData;
      try {
        jsonData = json.decode(jsonString) as Map<String, dynamic>;
      } on FormatException catch (e) {
        print("❌ LOG_ERROR: Invalid JSON format in file: $e");
        throw FormatException("The selected file does not contain valid JSON. Please check its content.");
      }

      if (!_validateResultJson(jsonData)) {
        print("❌ LOG_ERROR: JSON structure validation failed.");
        throw FormatException(
            "Invalid JSON structure. The file's content must include 'className', 'year', and a list of 'students'. Please check the sample format.");
      }
      // --- End of JSON Decoding and Validation ---


      if (!kIsWeb) { // This block handles file saving for Mobile/Desktop
        String baseSavePath;
        bool isDesktop = Platform.isWindows || Platform.isLinux || Platform.isMacOS;

        if (isDesktop && _configuredSavePath != null && _configuredSavePath!.isNotEmpty) {
          baseSavePath = _configuredSavePath!;
          print("ℹ️ LOG_INFO: Using configured desktop save path: $baseSavePath");
        } else {
          final Directory appDocDir = await getApplicationDocumentsDirectory();
          baseSavePath = appDocDir.path;
          if (isDesktop && (_configuredSavePath == null || _configuredSavePath!.isEmpty)) {
            print("ℹ️ LOG_INFO: Desktop save path not configured, using app documents directory: $baseSavePath");
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text("Desktop save path not configured. Using default app documents folder. Configure via 'Change Save Directory' button for custom path."),
              duration: Duration(seconds: 5),
              backgroundColor: Colors.amber.shade700,
            ));
          } else {
            print("ℹ️ LOG_INFO: Using mobile app documents directory: $baseSavePath");
          }
        }

        final String relativeDirPath = 'app_results/$_selectedYear/$_selectedClass';
        final String dirPath = '$baseSavePath/$relativeDirPath';
        print("ℹ️ LOG_INFO: Attempting to create/use directory: $dirPath");
        await Directory(dirPath).create(recursive: true);

        final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
        final String targetFileName = 'result_data_$timestamp.json';
        final String targetFilePath = '$dirPath/$targetFileName'; // This is the final save path

        print("ℹ️ LOG_INFO: Preparing to copy picked file from '$mobileDesktopFilePath' to '$targetFilePath'");
        await File(mobileDesktopFilePath!).copy(targetFilePath); // mobileDesktopFilePath is guaranteed non-null here for !kIsWeb

        // ****** THE REQUESTED LOGGER PRINT STATEMENT IS HERE ******
        print("✅✅✅ LOGGER: File successfully saved to: $targetFilePath ✅✅✅");
        // ****** END OF REQUESTED LOGGER PRINT STATEMENT ******

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Results saved to: $targetFilePath'), // Also shown to the user in UI
          backgroundColor: Colors.green,
          duration: Duration(seconds: 5), // Make it visible a bit longer
          showCloseIcon: true,
        ));

      } else if (kIsWeb) { // Web specific handling
        print("✅ LOG_SUCCESS: File validated successfully (Web). No local file system save occurs from this page.");
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('File validated successfully! (Web - data not saved to local file system)'),
            backgroundColor: Colors.blue));
      }

      // Clear selection after successful processing
      setState(() {
        _selectedPlatformFile = null;
        _fileNameToDisplay = "";
      });

    } catch (e) {
      print("❌ LOG_ERROR: Upload process failed: $e"); // General error in the process
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Upload failed: ${e.toString()}'),
          backgroundColor: Colors.redAccent));
    } finally {
      setState(() { _isUploading = false; });
    }
  }

  bool _validateResultJson(Map<String, dynamic> jsonData) {
    // ... (existing _validateResultJson logic - no change needed here)
    if (!jsonData.containsKey('className') ||
        !jsonData.containsKey('year') ||
        !jsonData.containsKey('students')) {
      print("Validation failed: Missing top-level keys (className, year, or students).");
      return false;
    }
    if (!(jsonData['students'] is List)) {
      print("Validation failed: 'students' is not a list.");
      return false;
    }
    print("JSON structure validation passed.");
    return true;
  }

  Future<void> _downloadSampleJson() async {
    // ... (existing _downloadSampleJson logic - no change needed here)
    final sampleData = {
      "className": "Class 10",
      "year": "2023-2024",
      "subjects": ["Math", "Science", "English"],
      "students": [
        {
          "id": "S1001",
          "name": "Jane Doe",
          "marks": {"Math": 85, "Science": 92, "English": 78},
          "total": 255,
          "percentage": 85.0,
          "grade": "A"
        },
      ]
    };
    final String sampleJsonString = jsonEncode(sampleData);

    try {
      if (kIsWeb) {
        // For web, use dart:html to trigger download
        final bytes = utf8.encode(sampleJsonString);
        final blob = html.Blob([bytes]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..setAttribute("download", "sample_result_format.json")
          ..click();
        html.Url.revokeObjectUrl(url);
        print("📥 Sample file download initiated for web.");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sample JSON download initiated! Check your browser downloads.'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        // For mobile/desktop
        final Directory? downloadsDir = await getDownloadsDirectory();
        if (downloadsDir != null) {
          final file = File('${downloadsDir.path}/sample_result_format.json');
          await file.writeAsString(sampleJsonString);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Sample JSON downloaded to: ${file.path}'),
              backgroundColor: Colors.green,
            ),
          );
          print("📥 Sample file downloaded: ${file.path}");
        } else {
          throw Exception("Could not access downloads directory.");
        }
      }
    } catch (e) {
      print("⚠️ Error downloading sample JSON: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error downloading sample: ${e.toString()}'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Widget _buildSavePathConfigurator(BuildContext context) {
    // Only show this configurator on Desktop platforms
    if (kIsWeb || !(Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
      return SizedBox.shrink(); // Empty widget if not on desktop
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Desktop Save Location:", style: GoogleFonts.lato(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blueGrey.shade700)),
          SizedBox(height: 8),
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey.shade50,
            ),
            child: Row(
              children: [
                Icon(Icons.folder_open_outlined, color: Colors.blueGrey.shade600, size: 20),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _configuredSavePath ?? 'Default: App Documents Folder',
                    style: GoogleFonts.robotoMono(fontSize: 13),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 8),
          ElevatedButton.icon(
            icon: Icon(Icons.drive_folder_upload_outlined, size: 18),
            label: Text('Change Save Directory'),
            onPressed: _pickSaveDirectory,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo.shade400,
              foregroundColor: Colors.white,
              textStyle: GoogleFonts.lato(fontWeight: FontWeight.w600),
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
          Divider(height: 30),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upload Class Results', style: GoogleFonts.lato(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.teal.shade700,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Upload Result Data',
              textAlign: TextAlign.center,
              style: GoogleFonts.oswald(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.teal.shade800),
            ),
            SizedBox(height: 15),

            // Show Save Path Configurator only on Desktop
            _buildSavePathConfigurator(context),

            Text("1. Select Target Details for File:", style: GoogleFonts.lato(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blueGrey.shade700)),
            SizedBox(height: 10),
            DropdownButtonFormField<String>(
              // ... (Class Dropdown - no changes)
              value: _selectedClass,
              decoration: InputDecoration(
                labelText: 'Select Class (for save path)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                prefixIcon: Icon(Icons.school_outlined, color: Colors.teal.shade700),
                filled: true,
                fillColor: Colors.teal.shade50,
              ),
              items: _classes.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value, style: GoogleFonts.poppins()),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedClass = value;
                  });
                }
              },
            ),
            SizedBox(height: 20),
            DropdownButtonFormField<String>(
              // ... (Year Dropdown - no changes)
              value: _selectedYear,
              decoration: InputDecoration(
                labelText: 'Select Year (for save path)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                prefixIcon: Icon(Icons.calendar_today_outlined, color: Colors.teal.shade700),
                filled: true,
                fillColor: Colors.teal.shade50,
              ),
              items: _years.map((String year) {
                return DropdownMenuItem<String>(
                  value: year,
                  child: Text(year, style: GoogleFonts.poppins()),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedYear = value;
                  });
                }
              },
            ),
            SizedBox(height: 25),

            Text("2. Choose JSON File:", style: GoogleFonts.lato(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blueGrey.shade700)),
            SizedBox(height: 10),
            ElevatedButton.icon(
              // ... (Select File Button - no changes)
              onPressed: _pickFile,
              icon: Icon(Icons.attach_file_outlined),
              label: Text('Select JSON Result File'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                textStyle: GoogleFonts.lato(fontSize: 16, fontWeight: FontWeight.bold),
                backgroundColor: Colors.blueGrey.shade600,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            SizedBox(height: 12),

            if (_selectedPlatformFile != null)
              Card(
                // ... (Selected File Card - no functional changes, only ensure path access is safe for size display)
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                child: ListTile(
                  leading: Icon(Icons.insert_drive_file_outlined, color: Colors.teal.shade700, size: 30),
                  title: Text(_fileNameToDisplay, style: GoogleFonts.lato(fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis),
                  subtitle: Text(
                          () {
                        if (_selectedPlatformFile == null) return 'N/A';
                        if (kIsWeb) {
                          return '${(_selectedPlatformFile!.size / 1024).toStringAsFixed(2)} KB';
                        } else {
                          final String? path = _selectedPlatformFile!.path;
                          if (path != null) {
                            try {
                              return '${(File(path).lengthSync() / 1024).toStringAsFixed(2)} KB';
                            } catch(e) { return 'Size N/A'; }
                          }
                          return 'Size N/A (path error)';
                        }
                      }(),
                      style: GoogleFonts.lato()
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.close_rounded, color: Colors.redAccent.shade200),
                    tooltip: 'Clear selection',
                    onPressed: () {
                      setState(() {
                        _selectedPlatformFile = null;
                        _fileNameToDisplay = "";
                      });
                    },
                  ),
                ),
              ),
            SizedBox(height: 25),

            Text("3. Process and Save:", style: GoogleFonts.lato(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blueGrey.shade700)),
            SizedBox(height: 10),
            ElevatedButton.icon(
              // ... (Upload Button - no changes)
              onPressed: (_selectedPlatformFile == null || _isUploading) ? null : _uploadResult,
              icon: _isUploading
                  ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 3, color: Colors.white70))
                  : Icon(Icons.cloud_upload_outlined),
              label: Text(_isUploading ? 'PROCESSING...' : 'PROCESS & SAVE FILE'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                textStyle: GoogleFonts.lato(fontSize: 16, fontWeight: FontWeight.bold),
                backgroundColor: Colors.teal.shade600,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey.shade400,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            SizedBox(height: 30),

            Theme(
              // ... (Help ExpansionTile - no changes)
              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                tilePadding: EdgeInsets.symmetric(horizontal: 8.0),
                leading: Icon(Icons.help_outline_rounded, color: Colors.blueGrey.shade700),
                title: Text(
                  'JSON Format & Sample',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.blueGrey.shade800),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8.0,0,8.0,8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Ensure your JSON file follows this structure for successful processing:', style: GoogleFonts.lato(fontSize: 14)),
                        SizedBox(height: 10),
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.04),
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '''{
  "className": "Class 10",
  "year": "2023-2024",
  "subjects": ["Math", "Science", "English"],
  "students": [
    {
      "id": "S1001",
      "name": "Student Name",
      "marks": {
        "Math": 85, "Science": 92, ...
      },
      "total": 255,
      "percentage": 85.0,
      "grade": "A"
    }
    // ... more students
  ]
}''',
                            style: GoogleFonts.robotoMono(fontSize: 12.5, color: Colors.black87),
                          ),
                        ),
                        SizedBox(height: 12),
                        Center(
                          child: TextButton.icon(
                            onPressed: _downloadSampleJson,
                            icon: Icon(Icons.download_for_offline_outlined, size: 20),
                            label: Text('Download Sample JSON'),
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              foregroundColor: Colors.teal.shade800,
                              textStyle: GoogleFonts.lato(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
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
}