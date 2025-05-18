// lib/admin/pages/fee/fee_collection_page.dart
import 'dart:async'; // For Timer (debouncing)
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart'; // For date formatting

// --- Mock Data Models (Same as before) ---
class PaymentTransaction {
  final String receiptNumber;
  final DateTime paymentDate;
  final double amountPaid;
  final String paymentMode;
  final List<String> paidForMonths;
  final String remarks;

  PaymentTransaction({
    required this.receiptNumber,
    required this.paymentDate,
    required this.amountPaid,
    required this.paymentMode,
    required this.paidForMonths,
    this.remarks = "",
  });
}

class StudentFeeProfile {
  final String id;
  final String name;
  final String className; // e.g., "Class 10 A"
  final String rollNumber;
  final String parentName;
  final List<FeeMonthEntry> monthlyFees;
  final PaymentTransaction? lastPayment;

  StudentFeeProfile({
    required this.id,
    required this.name,
    required this.className,
    required this.rollNumber,
    required this.parentName,
    required this.monthlyFees,
    this.lastPayment,
  });

  double get totalAnnualFeeEstimate => monthlyFees.fold(0.0, (sum, item) => sum + item.totalMonthlyFeeOriginal);
  double get totalPaidInSession => monthlyFees.where((m) => m.isPaid).fold(0.0, (sum, item) => sum + item.totalMonthlyFeeOriginal);
  double get currentSessionOutstanding => totalAnnualFeeEstimate - totalPaidInSession;
}

class FeeMonthEntry {
  final String monthYear; // e.g., "April 2024"
  final double tuitionFee;
  final double transportFee;
  final double otherCharges;
  bool isPaid;
  bool isSelectedForPayment; // Used to select UNPAID months for current transaction
  double lateFineApplied;

  FeeMonthEntry({
    required this.monthYear,
    required this.tuitionFee,
    this.transportFee = 0.0,
    this.otherCharges = 0.0,
    this.isPaid = false,
    this.isSelectedForPayment = false,
    this.lateFineApplied = 0.0,
  });

  double get totalMonthlyFeeOriginal => tuitionFee + transportFee + otherCharges;
  double get totalMonthlyFeeWithFine => totalMonthlyFeeOriginal + lateFineApplied;
}

// --- Fee Collection Page ---
class FeeCollectionPage extends StatefulWidget {
  const FeeCollectionPage({super.key});

  @override
  State<FeeCollectionPage> createState() => _FeeCollectionPageState();
}

class _FeeCollectionPageState extends State<FeeCollectionPage> {
  final TextEditingController _searchNameOrIdController = TextEditingController();
  final TextEditingController _searchRollNoController = TextEditingController();
  String? _selectedClassFilter;

  StudentFeeProfile? _selectedStudent;
  List<FeeMonthEntry> _feeMonthsToPay = [];
  bool _searchAttempted = false;
  Timer? _debounce;

  double _discountAmount = 0.0;
  final TextEditingController _discountController = TextEditingController(text: "0.00");

  DateTime _paymentDate = DateTime.now();
  String? _selectedPaymentMode;
  final TextEditingController _remarksController = TextEditingController();
  final TextEditingController _chequeDetailsController = TextEditingController();
  final TextEditingController _transactionIdController = TextEditingController();

  final List<String> _paymentModes = ['Cash', 'Cheque', 'Digital Payment', 'Challan'];
  final List<String> _classListForFilter = [
    "Class 9 A", "Class 9 B", "Class 10 A", "Class 10 B", "Class 11 Science", "Class 11 Commerce", "Class 12 Science", "Class 12 Commerce"
  ];


  @override
  void initState() {
    super.initState();
    _searchNameOrIdController.addListener(_onSearchChanged);
    _searchRollNoController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchNameOrIdController.removeListener(_onSearchChanged);
    _searchNameOrIdController.dispose();
    _searchRollNoController.removeListener(_onSearchChanged);
    _searchRollNoController.dispose();
    _discountController.dispose();
    _remarksController.dispose();
    _chequeDetailsController.dispose();
    _transactionIdController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _performSearch();
    });
  }

  void _performSearch() {
    _searchStudent(
        _searchNameOrIdController.text,
        _selectedClassFilter,
        _searchRollNoController.text
    );
  }

  void _searchStudent(String nameOrIdQuery, String? classFilter, String rollNoQuery) {
    setState(() { _searchAttempted = true; });
    if (nameOrIdQuery.isEmpty && (classFilter == null || classFilter.isEmpty) && rollNoQuery.isEmpty) {
      setState(() {
        _selectedStudent = null;
        _feeMonthsToPay.clear();
        _resetPaymentFields();
      });
      return;
    }
    List<StudentFeeProfile> mockStudents = [
      StudentFeeProfile(
          id: "S1001", name: "Rohan Sharma", className: "Class 10 A", rollNumber: "15", parentName: "Mr. Anil Sharma",
          monthlyFees: [
            FeeMonthEntry(monthYear: "April 2024", tuitionFee: 2500, transportFee: 800, isPaid: true),
            FeeMonthEntry(monthYear: "May 2024", tuitionFee: 2500, transportFee: 800, isPaid: true),
            FeeMonthEntry(monthYear: "June 2024", tuitionFee: 2500, transportFee: 800),
            FeeMonthEntry(monthYear: "July 2024", tuitionFee: 2500, transportFee: 800),
            FeeMonthEntry(monthYear: "August 2024", tuitionFee: 2500, transportFee: 800, lateFineApplied: 100),
            FeeMonthEntry(monthYear: "September 2024", tuitionFee: 2500, transportFee: 800),
            FeeMonthEntry(monthYear: "October 2024", tuitionFee: 2500, transportFee: 800),
            FeeMonthEntry(monthYear: "November 2024", tuitionFee: 2500, transportFee: 800),
            FeeMonthEntry(monthYear: "December 2024", tuitionFee: 2500, transportFee: 800),
            FeeMonthEntry(monthYear: "January 2025", tuitionFee: 2500, transportFee: 800),
            FeeMonthEntry(monthYear: "February 2025", tuitionFee: 2500, transportFee: 800),
            FeeMonthEntry(monthYear: "March 2025", tuitionFee: 2500, transportFee: 800),
          ],
          lastPayment: PaymentTransaction(receiptNumber: "RCPT12345", paymentDate: DateTime(2024, 5, 10), amountPaid: 6600.00, paymentMode: "Digital Payment", paidForMonths: ["April 2024", "May 2024"])
      ),
    ];
    StudentFeeProfile? foundStudent;
    for (var student in mockStudents) {
      bool nameMatch = nameOrIdQuery.isEmpty || student.name.toLowerCase().contains(nameOrIdQuery.toLowerCase()) || student.id.toLowerCase().contains(nameOrIdQuery.toLowerCase());
      bool classMatch = classFilter == null || classFilter.isEmpty || student.className == classFilter;
      bool rollNoMatch = rollNoQuery.isEmpty || student.rollNumber.toLowerCase() == rollNoQuery.toLowerCase();
      if (nameMatch && classMatch && rollNoMatch) {
        foundStudent = student;
        break;
      }
    }
    setState(() {
      _selectedStudent = foundStudent;
      if (_selectedStudent != null) {
        for (var month in _selectedStudent!.monthlyFees) {
          month.isSelectedForPayment = false;
        }
      } else {
        _feeMonthsToPay.clear();
      }
      _resetPaymentFields();
    });
  }

  void _resetPaymentFields() {
    _discountController.text = "0.00";
    _discountAmount = 0.0;
    _paymentDate = DateTime.now();
    _selectedPaymentMode = null;
    _remarksController.clear();
    _chequeDetailsController.clear();
    _transactionIdController.clear();
    if (_selectedStudent != null) {
      for (var monthEntry in _selectedStudent!.monthlyFees) {
        if (!monthEntry.isPaid) {
          monthEntry.isSelectedForPayment = false;
        }
      }
    }
  }

  double _calculateTotalSelectedFee() {
    double total = 0;
    if (_selectedStudent == null) return total;
    for (var monthEntry in _selectedStudent!.monthlyFees) {
      if (monthEntry.isSelectedForPayment && !monthEntry.isPaid) {
        total += monthEntry.totalMonthlyFeeWithFine;
      }
    }
    return total;
  }

  double _calculateNetPayable() {
    return _calculateTotalSelectedFee() - _discountAmount;
  }

  Future<void> _selectPaymentDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _paymentDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null && picked != _paymentDate) setState(() { _paymentDate = picked; });
  }

  void _processPayment() {
    if (_selectedStudent == null) { return; }
    final List<FeeMonthEntry> monthsToProcess = _selectedStudent!.monthlyFees
        .where((m) => m.isSelectedForPayment && !m.isPaid)
        .toList();
    if (monthsToProcess.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select at least one unpaid month for payment.')));
      return;
    }
    if (_selectedPaymentMode == null) { return; }
    if (_calculateNetPayable() < 0) { return; }

    final List<String> selectedMonthYears = monthsToProcess.map((m) => m.monthYear).toList();
    final double netAmountPaid = _calculateNetPayable();
    final String receiptNumber = "RCPT${DateTime.now().millisecondsSinceEpoch}";
    PaymentTransaction newPayment = PaymentTransaction(
      receiptNumber: receiptNumber, paymentDate: _paymentDate, amountPaid: netAmountPaid,
      paymentMode: _selectedPaymentMode!, paidForMonths: selectedMonthYears, remarks: _remarksController.text,
    );
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Payment of ₹$netAmountPaid processed! Receipt: $receiptNumber'),
      backgroundColor: Colors.green,
    ));
    setState(() {
      for (var monthEntry in _selectedStudent!.monthlyFees) {
        if (monthEntry.isSelectedForPayment && !monthEntry.isPaid) {
          monthEntry.isPaid = true;
          monthEntry.isSelectedForPayment = false;
        }
      }
      _selectedStudent = StudentFeeProfile(
        id: _selectedStudent!.id, name: _selectedStudent!.name, className: _selectedStudent!.className,
        rollNumber: _selectedStudent!.rollNumber, parentName: _selectedStudent!.parentName,
        monthlyFees: _selectedStudent!.monthlyFees, lastPayment: newPayment,
      );
      _feeMonthsToPay = _selectedStudent!.monthlyFees.where((m) => !m.isPaid).toList();
      _resetPaymentFields();
    });
    _showReceiptDialog(receiptNumber, netAmountPaid, selectedMonthYears);
  }

  void _showReceiptDialog(String receiptNumber, double amountPaid, List<String> monthsPaid) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Payment Receipt', style: GoogleFonts.lato(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Receipt No: $receiptNumber'), Text('Student: ${_selectedStudent?.name ?? 'N/A'}'),
                Text('Class: ${_selectedStudent?.className ?? 'N/A'}'), Text('Amount Paid: ₹${amountPaid.toStringAsFixed(2)}'),
                Text('Payment Date: ${DateFormat('dd MMM, yyyy').format(_paymentDate)}'), Text('Payment Mode: $_selectedPaymentMode'),
                Text('Months Paid: ${monthsPaid.join(", ")}'),
                if (_remarksController.text.isNotEmpty) Text('Remarks: ${_remarksController.text}'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(child: const Text('Print/Share (Simulated)'), onPressed: () { Navigator.of(context).pop(); }),
            TextButton(child: const Text('Close'), onPressed: () { Navigator.of(context).pop(); }),
          ],
        );
      },
    );
  }

  Widget _buildStudentDetailsCard(BuildContext context) {
    if (_selectedStudent == null) return const SizedBox.shrink();
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_selectedStudent!.name, style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: colorScheme.primary, fontSize: 18), overflow: TextOverflow.ellipsis),
            const SizedBox(height: 2),
            Text('Class: ${_selectedStudent!.className} | Roll: ${_selectedStudent!.rollNumber}', style: textTheme.bodyMedium?.copyWith(fontSize: 13)),
            Text('Parent: ${_selectedStudent!.parentName}', style: textTheme.bodyMedium?.copyWith(fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _buildFeeStatusOverviewCard(BuildContext context) {
    if (_selectedStudent == null) return const SizedBox.shrink();
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;
    String nextDueDate = "All Cleared";
    final firstUnpaidMonth = _selectedStudent!.monthlyFees.firstWhere((m) => !m.isPaid, orElse: () => FeeMonthEntry(monthYear: "N/A", tuitionFee: 0));
    if (firstUnpaidMonth.monthYear != "N/A") nextDueDate = firstUnpaidMonth.monthYear;
    return Card(
      elevation: 2, margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Fee Status Overview", style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: colorScheme.secondary)),
            const Divider(height: 16),
            _buildStatusRow(context, "Total Annual Fee (Est.):", "₹${_selectedStudent!.totalAnnualFeeEstimate.toStringAsFixed(2)}"),
            _buildStatusRow(context, "Total Paid (Session):", "₹${_selectedStudent!.totalPaidInSession.toStringAsFixed(2)}", valueColor: Colors.green.shade700),
            _buildStatusRow(context, "Current Balance (Session):", "₹${_selectedStudent!.currentSessionOutstanding.toStringAsFixed(2)}", valueColor: _selectedStudent!.currentSessionOutstanding > 0 ? colorScheme.error : Colors.green.shade700),
            _buildStatusRow(context, "Next Due Date:", nextDueDate),
            if (_selectedStudent!.lastPayment != null) ...[
              const Divider(height: 16),
              Text("Last Payment Details:", style: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600)),
              _buildStatusRow(context, "  Date:", DateFormat('dd MMM, yyyy').format(_selectedStudent!.lastPayment!.paymentDate)),
              _buildStatusRow(context, "  Amount:", "₹${_selectedStudent!.lastPayment!.amountPaid.toStringAsFixed(2)}"),
              _buildStatusRow(context, "  Mode:", _selectedStudent!.lastPayment!.paymentMode),
              _buildStatusRow(context, "  Receipt:", _selectedStudent!.lastPayment!.receiptNumber),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildStatusRow(BuildContext context, String label, String value, {Color? valueColor}) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: textTheme.bodyMedium?.copyWith(color: Colors.grey.shade700)),
          Text(value, style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600, color: valueColor ?? textTheme.bodyMedium?.color)),
        ],
      ),
    );
  }

  Widget _buildCompactSummaryRow(String label, String value, TextTheme textTheme, {bool isBold = false, Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: textTheme.bodySmall),
          Text(value, style: textTheme.bodySmall?.copyWith(fontWeight: isBold ? FontWeight.bold : FontWeight.normal, color: valueColor)),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Search Student", style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.grey.shade700)),
                      const SizedBox(height: 6),
                      SizedBox(
                        height: 50,
                        child: TextField(
                          controller: _searchNameOrIdController,
                          decoration: InputDecoration(
                            hintText: 'Name or ID...',
                            prefixIcon: Icon(Icons.person_search_outlined, color: colorScheme.primary, size: 20),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                            filled: true,
                            fillColor: colorScheme.surfaceVariant.withOpacity(0.5),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 50,
                              child: DropdownButtonFormField<String>(
                                decoration: InputDecoration(
                                  hintText: 'Class',
                                  prefixIcon: Icon(Icons.school_outlined, color: colorScheme.primary, size: 20),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                                  filled: true,
                                  fillColor: colorScheme.surfaceVariant.withOpacity(0.5),
                                ),
                                value: _selectedClassFilter,
                                items: _classListForFilter.map((String className) {
                                  return DropdownMenuItem<String>(
                                    value: className,
                                    child: Text(className, style: textTheme.bodySmall, overflow: TextOverflow.ellipsis),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  setState(() { _selectedClassFilter = newValue; });
                                  _performSearch();
                                },
                                isExpanded: true,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: SizedBox(
                              height: 50,
                              child: TextField(
                                controller: _searchRollNoController,
                                decoration: InputDecoration(
                                  hintText: 'Roll No...',
                                  prefixIcon: Icon(Icons.onetwothree_outlined, color: colorScheme.primary, size: 20),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                                  filled: true,
                                  fillColor: colorScheme.surfaceVariant.withOpacity(0.5),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 3,
                  child: _selectedStudent != null
                      ? _buildStudentDetailsCard(context)
                      : (_searchAttempted
                      ? Container(height: 110, alignment: Alignment.center, child: Text("No student found.", style: textTheme.bodyMedium?.copyWith(color: Colors.grey)))
                      : const SizedBox(height: 110)
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: _selectedStudent == null && !_searchAttempted
                  ? Center(child: Text('Search for a student to collect fees.', style: textTheme.titleMedium?.copyWith(color: Colors.grey.shade600)))
                  : _selectedStudent != null
                  ? _buildFeeCollectionFormContent(context)
                  : Center(child: Text('No student matches your criteria.', style: textTheme.titleMedium?.copyWith(color: Colors.grey.shade600))),
            ),
          ],
        ),
      ),
    );
  }

  // Helper widget for individual month chip
  Widget _buildMonthChip(BuildContext context, FeeMonthEntry monthEntry) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final bool isActuallyPaid = monthEntry.isPaid;
    final bool isCurrentlySelectedForPayment = monthEntry.isSelectedForPayment;

    Color chipColor = isActuallyPaid
        ? Colors.green.shade50
        : (isCurrentlySelectedForPayment ? Colors.blue.shade100 : Colors.orange.shade50);
    Color borderColor = isActuallyPaid
        ? Colors.green.shade300
        : (isCurrentlySelectedForPayment ? colorScheme.primary : Colors.orange.shade300);
    Color contentColor = isActuallyPaid ? Colors.green.shade800 : Colors.black87;
    IconData? chipIconData = isActuallyPaid ? Icons.check_circle_outline : (isCurrentlySelectedForPayment ? Icons.check_box_outlined : null);


    return Tooltip(
      message: '${monthEntry.monthYear}\nFee: ₹${monthEntry.totalMonthlyFeeWithFine.toStringAsFixed(2)}${isActuallyPaid ? "\n(PAID)" : ""}',
      child: GestureDetector(
        onTap: isActuallyPaid ? null : () {
          setState(() {
            monthEntry.isSelectedForPayment = !monthEntry.isSelectedForPayment;
          });
        },
        child: Container(
          width: 65, // Fixed width for chip
          height: 65, // Fixed height for chip
          margin: const EdgeInsets.all(3.0),
          decoration: BoxDecoration(
              color: chipColor,
              // shape: BoxShape.circle, // Make it circular
              borderRadius: BorderRadius.circular(8), // Or slightly rounded rectangle
              border: Border.all(color: borderColor, width: 1.5),
              boxShadow: [
                if(isCurrentlySelectedForPayment && !isActuallyPaid)
                  BoxShadow(color: colorScheme.primary.withOpacity(0.3), blurRadius: 2, spreadRadius: 0.5)
              ]
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    monthEntry.monthYear.split(" ")[0].substring(0,3).toUpperCase(), // E.g., APR
                    style: textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                      color: contentColor,
                    ),
                  ),
                  Text(
                    monthEntry.monthYear.split(" ")[1], // Year
                    style: textTheme.labelSmall?.copyWith(fontSize: 9, color: contentColor.withOpacity(0.8)),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '₹${monthEntry.totalMonthlyFeeWithFine.toStringAsFixed(0)}',
                    style: textTheme.labelSmall?.copyWith(fontSize: 10, color: contentColor.withOpacity(0.9)),
                  ),
                ],
              ),
              if (chipIconData != null)
                Positioned(
                  top: 3,
                  right: 3,
                  child: Icon(
                    chipIconData,
                    color: isActuallyPaid ? Colors.green.shade700 : colorScheme.primary,
                    size: 14,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildFeeCollectionFormContent(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    Widget monthSelectionWidget = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Select Months for Payment:', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Container(
            constraints: const BoxConstraints(maxHeight: 160, minHeight: 70), // Adjusted maxHeight
            decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade200), // Lighter border
                borderRadius: BorderRadius.circular(8)
            ),
            child: _selectedStudent == null || _selectedStudent!.monthlyFees.isEmpty
                ? Center(child: Padding(padding: const EdgeInsets.all(16.0), child: Text("No fee structure found.", style: textTheme.titleSmall)))
                : Padding( // Add some padding around the Wrap
              padding: const EdgeInsets.all(4.0),
              child: Wrap(
                spacing: 6.0, // Horizontal space between chips
                runSpacing: 6.0, // Vertical space between lines of chips
                children: _selectedStudent!.monthlyFees.map((monthEntry) {
                  return _buildMonthChip(context, monthEntry);
                }).toList(),
              ),
            )
        ),
      ],
    );

    Widget feeSummaryWidget = Card( /* ... Fee Summary Card (same as before) ... */
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Fee Summary', style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
            const Divider(height: 12),
            _buildCompactSummaryRow('Total Selected:', '₹${_calculateTotalSelectedFee().toStringAsFixed(2)}', textTheme),
            const SizedBox(height: 6),
            Row(
              children: [
                Text('Discount (₹):', style: textTheme.bodySmall),
                const SizedBox(width: 8),
                Expanded(
                  child: SizedBox(
                    height: 35,
                    child: TextField(
                      controller: _discountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: textTheme.bodySmall,
                      decoration: InputDecoration(border: const OutlineInputBorder(), contentPadding: const EdgeInsets.symmetric(horizontal: 8)),
                      onChanged: (value) { setState(() { _discountAmount = double.tryParse(value) ?? 0.0; }); },
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 12),
            _buildCompactSummaryRow('Net Payable:', '₹${_calculateNetPayable().toStringAsFixed(2)}', textTheme, isBold: true, valueColor: colorScheme.primary),
          ],
        ),
      ),
    );

    Widget paymentInputWidget = Column( /* ... Payment Input Widget (same as before) ... */
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Payment Details:', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('Payment Date: ${DateFormat('dd MMM, yyyy').format(_paymentDate)}', style: textTheme.bodyMedium),
            const SizedBox(width: 8),
            SizedBox(
              height: 30,
              child: TextButton.icon(
                icon: Icon(Icons.calendar_today, size: 16, color: colorScheme.primary),
                label: Text('Change', style: TextStyle(color: colorScheme.primary, fontSize: 12)),
                onPressed: () => _selectPaymentDate(context),
                style: TextButton.styleFrom(padding: EdgeInsets.symmetric(horizontal: 6)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Align(
          alignment: Alignment.centerLeft,
          child: SizedBox(
            width: 250,
            child: DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Payment Mode',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                prefixIcon: Icon(Icons.payment_outlined, color: colorScheme.primary, size: 20),
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
              ),
              value: _selectedPaymentMode,
              items: _paymentModes.map((String mode) { return DropdownMenuItem<String>(value: mode, child: Text(mode, style: textTheme.bodyMedium)); }).toList(),
              onChanged: (String? newValue) { setState(() { _selectedPaymentMode = newValue; }); },
            ),
          ),
        ),
        if (_selectedPaymentMode == 'Cheque') ...[
          const SizedBox(height: 10),
          TextField(controller: _chequeDetailsController, decoration: InputDecoration(labelText: 'Cheque No. / Bank Name', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)), contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12))),
        ],
        if (_selectedPaymentMode == 'Digital Payment') ...[
          const SizedBox(height: 10),
          TextField(controller: _transactionIdController, decoration: InputDecoration(labelText: 'Transaction ID / Ref No.', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)), contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12))),
        ],
        const SizedBox(height: 10),
        TextField(controller: _remarksController, decoration: InputDecoration(labelText: 'Remarks (Optional)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)), contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12)), maxLines: 2),
      ],
    );

    Widget actionButtonsWidget = Column( /* ... Action Buttons Widget (same as before) ... */
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text('Quick Actions:', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          icon: Icon(Icons.receipt_long_outlined, color: colorScheme.secondary),
          label: Text('View Ledger', style: TextStyle(color: colorScheme.secondary)),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('View Ledger: Not implemented yet.')));
          },
          style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 36), alignment: Alignment.centerLeft),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          icon: Icon(Icons.history_edu_outlined, color: colorScheme.secondary),
          label: Text('Transaction History', style: TextStyle(color: colorScheme.secondary)),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Transaction History: Not implemented yet.')));
          },
          style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 36), alignment: Alignment.centerLeft),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          icon: Icon(Icons.download_for_offline_outlined, color: colorScheme.secondary),
          label: Text('Download Last Receipt', style: TextStyle(color: colorScheme.secondary)),
          onPressed: _selectedStudent?.lastPayment != null ? () {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Download Receipt: ${_selectedStudent!.lastPayment!.receiptNumber} (Not implemented yet.)')));
          } : null,
          style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 36), alignment: Alignment.centerLeft),
        ),
      ],
    );

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_selectedStudent != null) _buildFeeStatusOverviewCard(context),
          LayoutBuilder(
              builder: (context, constraints) {
                bool isWide = constraints.maxWidth > 800;
                return Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: constraints.maxWidth > 700 ? 3 : 1, child: monthSelectionWidget),
                        if (constraints.maxWidth > 700) const SizedBox(width: 16),
                        if (constraints.maxWidth > 700) Expanded(flex: 2, child: feeSummaryWidget),
                      ],
                    ),
                    if (constraints.maxWidth <= 700) ...[
                      const SizedBox(height: 16),
                      feeSummaryWidget,
                    ],
                    const SizedBox(height: 16),
                    if (isWide)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 3, child: paymentInputWidget),
                          const SizedBox(width: 24),
                          Expanded(flex: 2, child: Padding(
                            padding: const EdgeInsets.only(top: 28.0),
                            child: actionButtonsWidget,
                          )),
                        ],
                      )
                    else
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          paymentInputWidget,
                          const SizedBox(height: 20),
                          actionButtonsWidget,
                        ],
                      ),
                  ],
                );
              }
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            icon: const Icon(Icons.check_circle_outline),
            label: const Text('Process Payment & Generate Receipt'),
            onPressed: _processPayment,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              textStyle: textTheme.labelLarge?.copyWith(color: colorScheme.onPrimary, fontSize: 16),
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
