// lib/admin/pages/fee/fee_setup_page.dart
import 'dart:async'; // For Future.delayed or API call simulation
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart'; // For TextInputFormatter

// Conceptual: You would create this service based on the API integration guide
// import '../../../services/fee_setup_api_service.dart';
// import '../../../models/fee_structure_dto.dart'; // For API communication

// Represents the fee data for a single class for UI management
class ClassFeeSetupData {
  final String className;
  Map<String, TextEditingController> feeComponentControllers = {};

  ClassFeeSetupData({required this.className, required List<String> allFeeHeads, Map<String, double>? existingFees}) {
    for (var head in allFeeHeads) {
      String initialValue = existingFees != null && existingFees.containsKey(head)
          ? existingFees[head]!.toStringAsFixed(2)
          : "0.00";
      feeComponentControllers[head] = TextEditingController(text: initialValue);
    }
  }

  void dispose() {
    for (var controller in feeComponentControllers.values) {
      controller.dispose();
    }
  }
}

class FeeSetupPage extends StatefulWidget {
  const FeeSetupPage({super.key});

  @override
  State<FeeSetupPage> createState() => _FeeSetupPageState();
}

class _FeeSetupPageState extends State<FeeSetupPage> {
  String? _selectedAcademicYear;
  List<String> _academicYears = [
    "2024-2025", "2025-2026", "2026-2027"
  ];
  bool _isFetchingYears = false;

  final List<String> _schoolClasses = [
    "Nursery", "LKG", "UKG", "Class 1", "Class 2", "Class 3", "Class 4", "Class 5",
    "Class 6", "Class 7", "Class 8", "Class 9", "Class 10",
    "Class 11 Science", "Class 11 Commerce", "Class 11 Arts",
    "Class 12 Science", "Class 12 Commerce", "Class 12 Arts",
  ];

  final List<String> _feeHeads = [
    "Tuition Fee (Monthly)", "Transport Fee (Monthly)", "Annual Fee (Yearly)",
    "Admission Fee (One Time)", "Exam Fee (Per Term/Year)", "Lab Fee (Yearly/Monthly)",
    "Library Fee (Yearly)", "Miscellaneous Fee (Yearly)",
  ];

  List<ClassFeeSetupData> _classFeeSetups = [];
  ClassFeeSetupData? _currentlySelectedClassSetup; // For Master-Detail view

  bool _isLoading = false; // For saving
  bool _isFetchingStructure = false;
  String? _errorMessage;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _fetchAcademicYears();
  }

  Future<void> _fetchAcademicYears() async {
    setState(() => _isFetchingYears = true);
    // Simulate API call
    // await Future.delayed(const Duration(milliseconds: 500));
    // In a real app, fetch from API:
    // try { _academicYears = await _apiService.getAcademicYears(); } catch (e) { ... }
    setState(() => _isFetchingYears = false);
  }

  Future<void> _fetchAndInitializeFeeStructureForYear(String academicYear) async {
    setState(() {
      _isFetchingStructure = true;
      _errorMessage = null;
      _currentlySelectedClassSetup = null;
      for (var setup in _classFeeSetups) {
        setup.dispose();
      }
      _classFeeSetups.clear();
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    List<Map<String,dynamic>> fetchedStructures = [];
    if (academicYear == "2024-2025") {
      fetchedStructures = [
        {"className": "Nursery", "feeComponents": {"Tuition Fee (Monthly)": 1500.0, "Annual Fee (Yearly)": 5000.0}},
        {"className": "Class 1", "feeComponents": {"Tuition Fee (Monthly)": 2000.0, "Transport Fee (Monthly)": 700.0, "Annual Fee (Yearly)": 6000.0}},
      ];
    }

    Map<String, Map<String, double>> existingFeesByClass = {};
    for (var structure in fetchedStructures) {
      existingFeesByClass[structure['className'] as String] = Map<String, double>.from(structure['feeComponents'] as Map);
    }

    setState(() {
      _classFeeSetups = _schoolClasses.map((className) {
        return ClassFeeSetupData(
          className: className,
          allFeeHeads: _feeHeads,
          existingFees: existingFeesByClass[className],
        );
      }).toList();
      _isFetchingStructure = false;
    });
  }

  void _initializeEmptyFeeSetups() {
    for (var setup in _classFeeSetups) {
      setup.dispose();
    }
    _classFeeSetups = _schoolClasses
        .map((className) => ClassFeeSetupData(className: className, allFeeHeads: _feeHeads))
        .toList();
    setState(() {});
  }

  @override
  void dispose() {
    for (var setup in _classFeeSetups) {
      setup.dispose();
    }
    super.dispose();
  }

  Future<void> _saveFeeStructure() async {
    if (_selectedAcademicYear == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select an academic year.')));
      return;
    }
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please correct errors before saving.')));
      return;
    }

    setState(() => _isLoading = true);
    List<Map<String, dynamic>> feeStructurePayload = _classFeeSetups.map((classSetup) {
      Map<String, double> components = {};
      classSetup.feeComponentControllers.forEach((head, controller) {
        components[head] = double.tryParse(controller.text) ?? 0.0;
      });
      return {"className": classSetup.className, "academicYear": _selectedAcademicYear!, "feeComponents": components};
    }).toList();

    print("--- Fee Structure to Save ---");
    print(feeStructurePayload);
    // TODO: API Call: await _apiService.saveFeeStructure(feeStructurePayload);
    await Future.delayed(const Duration(seconds: 2));

    setState(() => _isLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Fee structure for $_selectedAcademicYear saved! (Simulated)'), backgroundColor: Colors.green));
  }

  void _selectClassForEditing(ClassFeeSetupData classSetup) {
    setState(() {
      _currentlySelectedClassSetup = classSetup;
    });
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold( // Added Scaffold
      appBar: AppBar( // Added AppBar
        title: Text("Fee Structure Setup", style: GoogleFonts.lato()),
        // backgroundColor: colorScheme.primaryContainer, // Optional: customize AppBar color
        // elevation: 1, // Optional: customize elevation
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title is now in AppBar, this can be a subtitle or removed
              // Text("Set Up School Fee Structure", style: GoogleFonts.oswald(fontSize: 26, fontWeight: FontWeight.bold, color: colorScheme.primary)),
              // const SizedBox(height: 16),
              if (_errorMessage != null) Text(_errorMessage!, style: TextStyle(color: Colors.red, fontSize: 14)),

              Row(children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(labelText: 'Select Academic Year', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)), prefixIcon: Icon(Icons.calendar_today_outlined, color: colorScheme.primary)),
                    value: _selectedAcademicYear,
                    hint: const Text("Choose a session"),
                    items: _academicYears.map((String year) => DropdownMenuItem<String>(value: year, child: Text(year, style: textTheme.bodyLarge))).toList(),
                    onChanged: _isFetchingYears || _isFetchingStructure ? null : (String? newValue) {
                      if (newValue != null) {
                        setState(() => _selectedAcademicYear = newValue);
                        _fetchAndInitializeFeeStructureForYear(newValue);
                      }
                    },
                    validator: (value) => value == null ? 'Please select an academic year' : null,
                  ),
                ),
                if (_isFetchingYears) const Padding(padding: EdgeInsets.all(8.0), child: SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))),
              ]),
              const SizedBox(height: 16),

              if (_selectedAcademicYear != null && !_isFetchingStructure)
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      bool isWideScreen = constraints.maxWidth > 700;
                      if (isWideScreen) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 1,
                              child: _buildClassListPanel(colorScheme, textTheme),
                            ),
                            const VerticalDivider(width: 16, thickness: 1),
                            Expanded(
                              flex: 2,
                              child: _buildFeeInputPanel(colorScheme, textTheme),
                            ),
                          ],
                        );
                      } else {
                        return _buildStackedLayout(colorScheme, textTheme);
                      }
                    },
                  ),
                )
              else if (_isFetchingStructure)
                const Expanded(child: Center(child: CircularProgressIndicator()))
              else
                Expanded(child: Center(child: Text("Please select an academic year to proceed.", style: textTheme.titleMedium?.copyWith(color: Colors.grey.shade600)))),

              if (_selectedAcademicYear != null && !_isFetchingStructure) ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: _isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3)) : const Icon(Icons.save_alt_outlined),
                    label: Text(_isLoading ? 'SAVING...' : 'Save Fee Structure'),
                    onPressed: _isLoading ? null : _saveFeeStructure,
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                  ),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildClassListPanel(ColorScheme colorScheme, TextTheme textTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0, top: 0), // Adjusted top padding
          child: Text("Classes", style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        ),
        Expanded(
          child: _classFeeSetups.isEmpty
              ? Center(child: Text("No classes loaded for $_selectedAcademicYear.", style: textTheme.bodyMedium))
              : Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ListView.separated(
              itemCount: _classFeeSetups.length,
              itemBuilder: (context, index) {
                final classSetup = _classFeeSetups[index];
                final bool isSelected = _currentlySelectedClassSetup == classSetup;
                return ListTile(
                  title: Text(classSetup.className, style: textTheme.bodyLarge?.copyWith(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                  selected: isSelected,
                  selectedTileColor: colorScheme.primary.withOpacity(0.1),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  onTap: () => _selectClassForEditing(classSetup),
                  trailing: isSelected ? Icon(Icons.arrow_forward_ios_rounded, size: 16, color: colorScheme.primary) : null,
                  dense: true,
                );
              },
              separatorBuilder: (context, index) => const Divider(height: 1, thickness: 0.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFeeInputPanel(ColorScheme colorScheme, TextTheme textTheme) {
    if (_currentlySelectedClassSetup == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            "Select a class from the list to define its fee components.",
            style: textTheme.titleMedium?.copyWith(color: Colors.grey.shade700),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0, top: 0), // Adjusted top padding
          child: Text(
            "Fee Components for: ${_currentlySelectedClassSetup!.className}",
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: colorScheme.primary),
          ),
        ),
        Expanded(
          child: Card(
            elevation: 1,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: ListView(
                children: _feeHeads.map((feeHead) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      children: [
                        Expanded(flex: 3, child: Text(feeHead, style: textTheme.bodyMedium)),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 2,
                          child: SizedBox(
                            height: 45,
                            child: TextFormField(
                              controller: _currentlySelectedClassSetup!.feeComponentControllers[feeHead],
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
                              decoration: InputDecoration(
                                prefixText: "₹ ",
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                filled: true, fillColor: Colors.white,
                              ),
                              validator: (value) {
                                if (value != null && value.isNotEmpty) {
                                  if (double.tryParse(value) == null) return 'Invalid';
                                  if (double.parse(value) < 0) return '>= 0';
                                }
                                return null;
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStackedLayout(ColorScheme colorScheme, TextTheme textTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.3,
          child: _buildClassListPanel(colorScheme, textTheme),
        ),
        if (_currentlySelectedClassSetup != null) ...[
          const Divider(height: 20, thickness: 1),
          Expanded(
            child: _buildFeeInputPanel(colorScheme, textTheme),
          ),
        ] else ... [
          Expanded(child: Center(child: Text("Select a class to view/edit fees.", style: textTheme.titleMedium?.copyWith(color: Colors.grey.shade600)))),
        ]
      ],
    );
  }
}
