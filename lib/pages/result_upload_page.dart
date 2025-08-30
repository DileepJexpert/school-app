// lib/admin/pages/fee/result_upload_page.dart
import 'dart:convert'; // For jsonEncode, jsonDecode, utf8
import 'dart:io'; // For File, Directory
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, Uint8List; // Import kIsWeb and defaultTargetPlatform
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
  bool _isDesktop = false; // State variable to safely check for desktop platforms

  final List<String> _classes = [
    "Class 10", "Class 11 Science", "Class 11 Commerce", "Class 12 Science", "Class 12 Commerce"
  ];
  final List<String> _years = ["2021-2022", "2022-2023", "2023-2024", "2024-2025"];

  @override
  void initState() {
    super.initState();
    // Safely check for desktop platform using a web-safe method
    if (!kIsWeb) {
      // defaultTargetPlatform is available on all platforms and is safe for web builds
      if (defaultTargetPlatform == TargetPlatform.windows ||
          defaultTargetPlatform == TargetPlatform.linux ||
          defaultTargetPlatform == TargetPlatform.macOS) {
        setState(() {
          _isDesktop = true;
        });
        // We can now safely call methods that use dart:io internally
        _loadConfiguredPath();
      }
    }
  }

  Future<void> _loadConfiguredPath() async {
    // This method is now only called on desktop, so no kIsWeb check is needed here.
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
    // Use the safe _isDesktop flag
    if (!_isDesktop) {
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
      String? mobileDesktopFilePath;

      if (kIsWeb) {
        final Uint8List? fileBytes = _selectedPlatformFile!.bytes;
        if (fileBytes == null) {
          throw Exception("File bytes not available for web. Please re-select the file.");
        }
        jsonString = utf8.decode(fileBytes);
      } else {
        mobileDesktopFilePath = _selectedPlatformFile!.path;
        if (mobileDesktopFilePath == null) {
          throw Exception("File path not available for mobile/desktop.");
        }
        jsonString = await File(mobileDesktopFilePath).readAsString();
      }

      Map<String, dynamic> jsonData;
      try {
        jsonData = json.decode(jsonString) as Map<String, dynamic>;
      } on FormatException catch (e) {
        print("❌ LOG_ERROR: Invalid JSON format in file: $e");
        throw FormatException("The selected file does not contain valid JSON.");
      }

      if (!_validateResultJson(jsonData)) {
        print("❌ LOG_ERROR: JSON structure validation failed.");
        throw FormatException("Invalid JSON structure. See format requirements.");
      }

      if (!kIsWeb) {
        String baseSavePath;
        if (_isDesktop && _configuredSavePath != null && _configuredSavePath!.isNotEmpty) {
          baseSavePath = _configuredSavePath!;
          print("ℹ️ LOG_INFO: Using configured desktop save path: $baseSavePath");
        } else {
          final Directory appDocDir = await getApplicationDocumentsDirectory();
          baseSavePath = appDocDir.path;
          if (_isDesktop && (_configuredSavePath == null || _configuredSavePath!.isEmpty)) {
            print("ℹ️ LOG_INFO: Desktop save path not configured, using app documents directory.");
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text("Desktop save path not set. Using default app documents folder."),
              duration: Duration(seconds: 4),
              backgroundColor: Colors.amber,
            ));
          } else {
            print("ℹ️ LOG_INFO: Using mobile app documents directory: $baseSavePath");
          }
        }

        final String dirPath = '$baseSavePath/app_results/$_selectedYear/$_selectedClass';
        await Directory(dirPath).create(recursive: true);

        final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
        final String targetFileName = 'result_data_$timestamp.json';
        final String targetFilePath = '$dirPath/$targetFileName';

        await File(mobileDesktopFilePath!).copy(targetFilePath);

        print("✅✅✅ LOGGER: File successfully saved to: $targetFilePath ✅✅✅");

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Results saved to: $targetFilePath'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 5),
          showCloseIcon: true,
        ));

      } else { // Web specific handling
        print("✅ LOG_SUCCESS: File validated successfully (Web). No local file system save occurs.");
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('File validated successfully! (Web)'),
            backgroundColor: Colors.blue));
      }

      setState(() {
        _selectedPlatformFile = null;
        _fileNameToDisplay = "";
      });

    } catch (e) {
      print("❌ LOG_ERROR: Upload process failed: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Upload failed: ${e.toString()}'),
          backgroundColor: Colors.redAccent));
    } finally {
      setState(() { _isUploading = false; });
    }
  }

  bool _validateResultJson(Map<String, dynamic> jsonData) {
    if (!jsonData.containsKey('className') ||
        !jsonData.containsKey('year') ||
        !jsonData.containsKey('students')) {
      return false;
    }
    if (!(jsonData['students'] is List)) {
      return false;
    }
    return true;
  }

  Future<void> _downloadSampleJson() async {
    final sampleData = {
      "className": "Class 10", "year": "2023-2024", "subjects": ["Math", "Science", "English"],
      "students": [{"id": "S1001", "name": "Jane Doe", "marks": {"Math": 85, "Science": 92, "English": 78}, "total": 255, "percentage": 85.0, "grade": "A"}]
    };
    final String sampleJsonString = jsonEncode(sampleData);

    try {
      if (kIsWeb) {
        final bytes = utf8.encode(sampleJsonString);
        final blob = html.Blob([bytes]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..setAttribute("download", "sample_result_format.json")
          ..click();
        html.Url.revokeObjectUrl(url);
      } else {
        final Directory? downloadsDir = await getDownloadsDirectory();
        if (downloadsDir != null) {
          final file = File('${downloadsDir.path}/sample_result_format.json');
          await file.writeAsString(sampleJsonString);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Sample JSON downloaded to: ${file.path}')));
        } else {
          throw Exception("Could not access downloads directory.");
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error downloading sample: ${e.toString()}')));
    }
  }

  Widget _buildSavePathConfigurator(BuildContext context) {
    // Use the safe _isDesktop flag
    if (!_isDesktop) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Desktop Save Location:", style: GoogleFonts.lato(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blueGrey.shade700)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey.shade50,
            ),
            child: Row(
              children: [
                Icon(Icons.folder_open_outlined, color: Colors.blueGrey.shade600, size: 20),
                const SizedBox(width: 10),
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
          const SizedBox(height: 8),
          ElevatedButton.icon(
            icon: const Icon(Icons.drive_folder_upload_outlined, size: 18),
            label: const Text('Change Save Directory'),
            onPressed: _pickSaveDirectory,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo.shade400,
              foregroundColor: Colors.white,
              textStyle: GoogleFonts.lato(fontWeight: FontWeight.w600),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
          const Divider(height: 30),
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
            const SizedBox(height: 15),
            _buildSavePathConfigurator(context),
            Text("1. Select Target Details for File:", style: GoogleFonts.lato(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blueGrey.shade700)),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
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
                if (value != null) setState(() => _selectedClass = value);
              },
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
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
                if (value != null) setState(() => _selectedYear = value);
              },
            ),
            const SizedBox(height: 25),
            Text("2. Choose JSON File:", style: GoogleFonts.lato(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blueGrey.shade700)),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _pickFile,
              icon: const Icon(Icons.attach_file_outlined),
              label: const Text('Select JSON Result File'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                textStyle: GoogleFonts.lato(fontSize: 16, fontWeight: FontWeight.bold),
                backgroundColor: Colors.blueGrey.shade600,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 12),
            if (_selectedPlatformFile != null)
              Card(
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
                    icon: const Icon(Icons.close_rounded, color: Colors.redAccent),
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
            const SizedBox(height: 25),
            Text("3. Process and Save:", style: GoogleFonts.lato(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blueGrey.shade700)),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: (_selectedPlatformFile == null || _isUploading) ? null : _uploadResult,
              icon: _isUploading
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 3, color: Colors.white70))
                  : const Icon(Icons.cloud_upload_outlined),
              label: Text(_isUploading ? 'PROCESSING...' : 'PROCESS & SAVE FILE'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                textStyle: GoogleFonts.lato(fontSize: 16, fontWeight: FontWeight.bold),
                backgroundColor: Colors.teal.shade600,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey.shade400,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 30),
            Theme(
              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                tilePadding: const EdgeInsets.symmetric(horizontal: 8.0),
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
                        Text('Ensure your JSON file follows this structure:', style: GoogleFonts.lato(fontSize: 14)),
                        const SizedBox(height: 10),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
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
  ]
}''',
                            style: GoogleFonts.robotoMono(fontSize: 12.5, color: Colors.black87),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Center(
                          child: TextButton.icon(
                            onPressed: _downloadSampleJson,
                            icon: const Icon(Icons.download_for_offline_outlined, size: 20),
                            label: const Text('Download Sample JSON'),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
