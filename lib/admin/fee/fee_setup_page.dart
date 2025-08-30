// lib/admin/pages/fee/fee_setup_page.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';

// --- Import your new API service ---
import '../../../services/fee_api_service.dart';


// --- Helper class to manage fee heads and their frequency ---
class FeeHead {
  final String name;
  final String frequency; // "MONTHLY", "YEARLY", or "ONE_TIME"

  FeeHead({required this.name, required this.frequency});

  // A unique display name used as a key for controllers
  String get displayName => "$name ($frequency)";
}


// Represents the fee data for a single class for UI management
class ClassFeeSetupData {
  final String className;
  Map<String, TextEditingController> feeComponentControllers = {};

  ClassFeeSetupData({required this.className, required List<FeeHead> allFeeHeads, Map<String, double>? existingFees}) {
    for (var head in allFeeHeads) {
      String initialValue = existingFees != null && existingFees.containsKey(head.displayName)
          ? existingFees[head.displayName]!.toStringAsFixed(2)
          : "0.00";
      feeComponentControllers[head.displayName] = TextEditingController(text: initialValue);
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
  // --- Instantiate your API service ---
  final FeeApiService _apiService = FeeApiService();

  String? _selectedAcademicYear;
  final List<String> _academicYears = ["2024-2025", "2025-2026", "2026-2027"];
  bool _isFetchingYears = false;

  final List<String> _schoolClasses = [
    "Nursery", "LKG", "UKG", "Class 1", "Class 2", "Class 3", "Class 4", "Class 5",
    "Class 6", "Class 7", "Class 8", "Class 9", "Class 10",
    "Class 11 Science", "Class 11 Commerce", "Class 11 Arts",
    "Class 12 Science", "Class 12 Commerce", "Class 12 Arts",
  ];

  final List<FeeHead> _feeHeads = [
    FeeHead(name: "Tuition Fee", frequency: "MONTHLY"),
    FeeHead(name: "Transport Fee", frequency: "MONTHLY"),
    FeeHead(name: "Annual Fee", frequency: "YEARLY"),
    FeeHead(name: "Admission Fee", frequency: "ONE_TIME"),
    FeeHead(name: "Exam Fee", frequency: "YEARLY"),
    FeeHead(name: "Lab Fee", frequency: "YEARLY"),
    FeeHead(name: "Library Fee", frequency: "YEARLY"),
    FeeHead(name: "Miscellaneous Fee", frequency: "YEARLY"),
  ];

  List<ClassFeeSetupData> _classFeeSetups = [];
  ClassFeeSetupData? _currentlySelectedClassSetup;

  bool _isLoading = false;
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
    // In a real app, you would fetch this list from another API endpoint
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() => _isFetchingYears = false);
  }

  // --- UPDATED: Connects to the backend to fetch data ---
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

    try {
      // --- API CALL ---
      final fetchedStructures = await _apiService.getFeeStructureForYear(academicYear);

      Map<String, Map<String, double>> existingFeesByClass = {};
      for (var structure in fetchedStructures) {
        final className = structure['className'] as String;
        final List<dynamic> components = structure['feeComponents'] as List<dynamic>;
        existingFeesByClass[className] = {};
        for (var component in components) {
          final feeName = component['feeName'] as String;
          final frequency = component['frequency'] as String;
          final amount = (component['amount'] as num).toDouble();
          final displayName = "$feeName ($frequency)";
          existingFeesByClass[className]![displayName] = amount;
        }
      }

      setState(() {
        _classFeeSetups = _schoolClasses.map((className) {
          return ClassFeeSetupData(
            className: className,
            allFeeHeads: _feeHeads,
            existingFees: existingFeesByClass[className],
          );
        }).toList();
        if (_classFeeSetups.isNotEmpty) {
          _currentlySelectedClassSetup = _classFeeSetups.first;
        }
      });
    } catch (e) {
      setState(() => _errorMessage = "Error: ${e.toString()}");
    } finally {
      setState(() => _isFetchingStructure = false);
    }
  }

  @override
  void dispose() {
    for (var setup in _classFeeSetups) {
      setup.dispose();
    }
    super.dispose();
  }

  // --- UPDATED: Connects to the backend to save data ---
  Future<void> _saveFeeStructure() async {
    if (_selectedAcademicYear == null || !_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please correct errors before saving.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    List<Map<String, dynamic>> feeStructurePayload = _classFeeSetups.map((classSetup) {
      List<Map<String, dynamic>> components = [];
      _feeHeads.forEach((feeHead) {
        final controller = classSetup.feeComponentControllers[feeHead.displayName]!;
        final amount = double.tryParse(controller.text) ?? 0.0;
        if (amount > 0) {
          components.add({
            "feeName": feeHead.name,
            "amount": amount,
            "frequency": feeHead.frequency,
          });
        }
      });

      if (components.isEmpty) return null;

      return {
        "className": classSetup.className,
        "academicYear": _selectedAcademicYear!,
        "feeComponents": components
      };
    }).whereType<Map<String, dynamic>>().toList();

    try {
      // --- API CALL ---
      await _apiService.saveFeeStructure(feeStructurePayload);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Fee structure for $_selectedAcademicYear saved successfully!'),
          backgroundColor: Colors.green,
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error saving data: ${e.toString()}'),
          backgroundColor: Colors.red,
        ));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
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

    return Scaffold(
      appBar: AppBar(
        title: Text("Fee Structure Setup", style: GoogleFonts.lato()),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(_errorMessage!, style: const TextStyle(color: Colors.red, fontSize: 14)),
                ),

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
                if (_isFetchingYears || _isFetchingStructure) const Padding(padding: EdgeInsets.all(8.0), child: SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))),
              ]),
              const SizedBox(height: 16),

              if (_selectedAcademicYear != null)
                Expanded(
                  child: _isFetchingStructure
                      ? const Center(child: CircularProgressIndicator())
                      : LayoutBuilder(
                    builder: (context, constraints) {
                      bool isWideScreen = constraints.maxWidth > 700;
                      if (isWideScreen) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(flex: 1, child: _buildClassListPanel(colorScheme, textTheme)),
                            const VerticalDivider(width: 16, thickness: 1),
                            Expanded(flex: 2, child: _buildFeeInputPanel(colorScheme, textTheme)),
                          ],
                        );
                      } else {
                        return _buildStackedLayout(colorScheme, textTheme);
                      }
                    },
                  ),
                )
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
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text("Classes", style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        ),
        Expanded(
          child: Container(
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
          padding: const EdgeInsets.only(bottom: 8.0),
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
                        Expanded(flex: 3, child: Text(feeHead.displayName, style: textTheme.bodyMedium)),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 2,
                          child: SizedBox(
                            height: 45,
                            child: TextFormField(
                              controller: _currentlySelectedClassSetup!.feeComponentControllers[feeHead.displayName],
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
