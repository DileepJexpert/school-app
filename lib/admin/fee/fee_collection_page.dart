// lib/admin/pages/fee/fee_collection_page.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart'; // For date formatting

// --- Mock Data Models (Replace with your actual data models and services) ---
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
  final String className;
  final String parentName;
  // outstandingBalance is now calculated based on monthlyFees for the session
  final List<FeeMonthEntry> monthlyFees; // Detailed breakdown for the current session
  final PaymentTransaction? lastPayment; // Details of the last payment made

  StudentFeeProfile({
    required this.id,
    required this.name,
    required this.className,
    required this.parentName,
    required this.monthlyFees,
    this.lastPayment,
  });

  double get totalAnnualFeeEstimate {
    return monthlyFees.fold(0.0, (sum, item) => sum + item.totalMonthlyFeeOriginal);
  }

  double get totalPaidInSession {
    return monthlyFees
        .where((m) => m.isPaid)
        .fold(0.0, (sum, item) => sum + item.totalMonthlyFeeOriginal); // Use original fee for paid amount
  }

  double get currentSessionOutstanding {
    return totalAnnualFeeEstimate - totalPaidInSession;
  }
}

class FeeMonthEntry {
  final String monthYear; // e.g., "April 2024"
  final double tuitionFee;
  final double transportFee;
  final double otherCharges;
  bool isPaid;
  bool isSelectedForPayment;
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

  // Original fee without late fine, for calculating total paid accurately
  double get totalMonthlyFeeOriginal => tuitionFee + transportFee + otherCharges;
  // Total fee including any late fine, for current payment calculation
  double get totalMonthlyFeeWithFine => totalMonthlyFeeOriginal + lateFineApplied;
}

// --- Fee Collection Page ---
class FeeCollectionPage extends StatefulWidget {
  const FeeCollectionPage({super.key});

  @override
  State<FeeCollectionPage> createState() => _FeeCollectionPageState();
}

class _FeeCollectionPageState extends State<FeeCollectionPage> {
  final TextEditingController _searchController = TextEditingController();
  StudentFeeProfile? _selectedStudent;
  List<FeeMonthEntry> _feeMonthsToPay = [];
  bool _searchAttempted = false;

  double _discountAmount = 0.0;
  final TextEditingController _discountController = TextEditingController(text: "0.00");

  DateTime _paymentDate = DateTime.now();
  String? _selectedPaymentMode;
  final TextEditingController _remarksController = TextEditingController();
  final TextEditingController _chequeDetailsController = TextEditingController();
  final TextEditingController _transactionIdController = TextEditingController();

  final List<String> _paymentModes = ['Cash', 'Cheque', 'Digital Payment', 'Challan'];

  void _searchStudent(String query) {
    setState(() { _searchAttempted = true; });
    if (query.isEmpty) {
      setState(() {
        _selectedStudent = null;
        _feeMonthsToPay.clear();
        _resetPaymentFields();
      });
      return;
    }
    setState(() {
      if (query.toLowerCase().contains("rohan") || query == "S1001") {
        _selectedStudent = StudentFeeProfile(
            id: "S1001",
            name: "Rohan Sharma",
            className: "Class 10 A",
            parentName: "Mr. Anil Sharma",
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
            lastPayment: PaymentTransaction(
              receiptNumber: "RCPT12345",
              paymentDate: DateTime(2024, 5, 10),
              amountPaid: 6600.00,
              paymentMode: "Digital Payment",
              paidForMonths: ["April 2024", "May 2024"],
            )
        );
        _feeMonthsToPay = _selectedStudent!.monthlyFees.where((m) => !m.isPaid).toList();
      } else {
        _selectedStudent = null;
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
      _feeMonthsToPay.forEach((m) => m.isSelectedForPayment = false);
    }
  }

  double _calculateTotalSelectedFee() {
    double total = 0;
    if (_selectedStudent == null) return total;
    for (var monthEntry in _feeMonthsToPay) {
      if (monthEntry.isSelectedForPayment) {
        total += monthEntry.totalMonthlyFeeWithFine; // Use fee with fine for current payment
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
    if (_selectedStudent == null || _feeMonthsToPay.where((m) => m.isSelectedForPayment).isEmpty || _selectedPaymentMode == null || _calculateNetPayable() < 0) {
      String message = "Please correct the form.";
      if(_selectedStudent == null) message = "Please search and select a student.";
      else if(_feeMonthsToPay.where((m) => m.isSelectedForPayment).isEmpty) message = "Please select at least one month.";
      else if(_selectedPaymentMode == null) message = "Please select a payment mode.";
      else if(_calculateNetPayable() < 0) message = "Net payable cannot be negative.";
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      return;
    }

    final List<String> selectedMonths = _feeMonthsToPay.where((m) => m.isSelectedForPayment).map((m) => m.monthYear).toList();
    final double netAmountPaid = _calculateNetPayable();
    final String receiptNumber = "RCPT${DateTime.now().millisecondsSinceEpoch}";

    // --- Simulate Backend Update ---
    PaymentTransaction newPayment = PaymentTransaction(
      receiptNumber: receiptNumber,
      paymentDate: _paymentDate,
      amountPaid: netAmountPaid,
      paymentMode: _selectedPaymentMode!,
      paidForMonths: selectedMonths,
      remarks: _remarksController.text,
    );

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Payment of ₹$netAmountPaid processed! Receipt: $receiptNumber'),
      backgroundColor: Colors.green,
    ));

    setState(() {
      for (var monthEntry in _selectedStudent!.monthlyFees) {
        if (monthEntry.isSelectedForPayment) monthEntry.isPaid = true;
      }
      // Update _selectedStudent with the new last payment
      _selectedStudent = StudentFeeProfile(
        id: _selectedStudent!.id,
        name: _selectedStudent!.name,
        className: _selectedStudent!.className,
        parentName: _selectedStudent!.parentName,
        monthlyFees: _selectedStudent!.monthlyFees, // This list has updated isPaid flags
        lastPayment: newPayment, // Set the new payment as the last one
      );
      _feeMonthsToPay = _selectedStudent!.monthlyFees.where((m) => !m.isPaid).toList();
      _resetPaymentFields();
    });
    _showReceiptDialog(receiptNumber, netAmountPaid, selectedMonths);
  }

  void _showReceiptDialog(String receiptNumber, double amountPaid, List<String> monthsPaid) {
    showDialog(
      context: context,
      builder: (BuildContext context) { /* ... Receipt Dialog (same as before) ... */
        return AlertDialog(
          title: Text('Payment Receipt', style: GoogleFonts.lato(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Receipt No: $receiptNumber'),
                Text('Student: ${_selectedStudent?.name ?? 'N/A'}'),
                Text('Class: ${_selectedStudent?.className ?? 'N/A'}'),
                Text('Amount Paid: ₹${amountPaid.toStringAsFixed(2)}'),
                Text('Payment Date: ${DateFormat('dd MMM, yyyy').format(_paymentDate)}'),
                Text('Payment Mode: $_selectedPaymentMode'),
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
            Text('Class: ${_selectedStudent!.className}', style: textTheme.bodyMedium?.copyWith(fontSize: 13)),
            Text('Parent: ${_selectedStudent!.parentName}', style: textTheme.bodyMedium?.copyWith(fontSize: 13)),
            // Outstanding balance is now shown in the Fee Status Overview card
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
    final firstUnpaidMonth = _selectedStudent!.monthlyFees.firstWhere((m) => !m.isPaid, orElse: () => FeeMonthEntry(monthYear: "N/A", tuitionFee: 0)); // Handle if all paid
    if (firstUnpaidMonth.monthYear != "N/A") {
      nextDueDate = firstUnpaidMonth.monthYear;
    }

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(top: 0, bottom: 16), // No top margin if it's below student details
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
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'ID or Name...',
                            prefixIcon: Icon(Icons.search, color: colorScheme.primary, size: 20),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(icon: Icon(Icons.clear, color: Colors.grey, size: 20), onPressed: () { _searchController.clear(); _searchStudent("");})
                                : IconButton(icon: Icon(Icons.search_outlined, color: colorScheme.primary, size: 20), onPressed: () => _searchStudent(_searchController.text)),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                            filled: true,
                            fillColor: colorScheme.surfaceVariant.withOpacity(0.5),
                          ),
                          onSubmitted: _searchStudent,
                        ),
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
                      ? Container(height: 90, alignment: Alignment.center, child: Text("No student found.", style: textTheme.bodyMedium?.copyWith(color: Colors.grey)))
                      : const SizedBox(height: 90)
                  ),
                ),
              ],
            ),
            // The Fee Status Overview Card is now part of the main scrollable content if a student is selected
            // It will appear below the student details card (which is now shorter)

            Expanded(
              child: _selectedStudent == null && !_searchAttempted
                  ? Center(child: Text('Search for a student to collect fees.', style: textTheme.titleMedium?.copyWith(color: Colors.grey.shade600)))
                  : _selectedStudent != null
                  ? _buildFeeCollectionFormContent(context)
                  : Center(child: Text('Select a student to proceed.', style: textTheme.titleMedium?.copyWith(color: Colors.grey.shade600))),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeeCollectionFormContent(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return LayoutBuilder( // Use LayoutBuilder for potential responsiveness
        builder: (context, constraints) {
          // bool isWide = constraints.maxWidth > 600; // Example breakpoint for two-column layout
          // For now, keeping single column for simplicity, but structure allows for Row later.

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_selectedStudent != null) _buildFeeStatusOverviewCard(context), // Display fee status overview

                // --- Month Selection ---
                Text('Select Months for Payment:', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Container(
                  constraints: const BoxConstraints(maxHeight: 180),
                  decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)),
                  child: _feeMonthsToPay.isEmpty
                      ? Center(child: Padding(padding: const EdgeInsets.all(16.0), child: Text(_selectedStudent?.currentSessionOutstanding == 0 ? "All dues cleared." : "No pending fee months found.", style: textTheme.titleSmall?.copyWith(color: Colors.green.shade700))))
                      : ListView.builder(
                    shrinkWrap: true,
                    itemCount: _feeMonthsToPay.length,
                    itemBuilder: (context, index) { /* ... CheckboxListTile (same as before) ... */
                      final monthEntry = _feeMonthsToPay[index];
                      return CheckboxListTile(
                        title: Text('${monthEntry.monthYear} (₹${monthEntry.totalMonthlyFeeWithFine.toStringAsFixed(2)})', style: textTheme.bodyMedium),
                        value: monthEntry.isSelectedForPayment,
                        onChanged: (bool? value) { setState(() { monthEntry.isSelectedForPayment = value ?? false; }); },
                        controlAffinity: ListTileControlAffinity.leading,
                        activeColor: colorScheme.primary,
                        dense: true,
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),

                // --- Fee Summary (More Compact) ---
                Card(
                  elevation: 1, // Reduced elevation
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0), // Reduced padding
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
                                height: 35, // More compact
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
                ),

                // --- Payment Details ---
                Text('Payment Details:', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 10),
                Row( // Tighter layout for date and button
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text('Payment Date: ${DateFormat('dd MMM, yyyy').format(_paymentDate)}', style: textTheme.bodyMedium),
                    const SizedBox(width: 8), // Reduced space
                    SizedBox( // Constrain button size
                      height: 30,
                      child: TextButton.icon(
                        icon: Icon(Icons.calendar_today, size: 16, color: colorScheme.primary), // Smaller icon
                        label: Text('Change', style: TextStyle(color: colorScheme.primary, fontSize: 12)), // Smaller text
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
                    child: DropdownButtonFormField<String>( /* ... Payment Mode Dropdown (same as before) ... */
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
                if (_selectedPaymentMode == 'Cheque') ...[ /* ... Cheque Details (same as before) ... */
                  const SizedBox(height: 10),
                  TextField(controller: _chequeDetailsController, decoration: InputDecoration(labelText: 'Cheque No. / Bank Name', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)), contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12))),
                ],
                if (_selectedPaymentMode == 'Digital Payment') ...[ /* ... Transaction ID (same as before) ... */
                  const SizedBox(height: 10),
                  TextField(controller: _transactionIdController, decoration: InputDecoration(labelText: 'Transaction ID / Ref No.', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)), contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12))),
                ],
                const SizedBox(height: 10),
                TextField(controller: _remarksController, decoration: InputDecoration(labelText: 'Remarks (Optional)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)), contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12)), maxLines: 2),
                const SizedBox(height: 24),

                ElevatedButton.icon( /* ... Process Payment Button (same as before) ... */
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
    );
  }

  Widget _buildCompactSummaryRow(String label, String value, TextTheme textTheme, {bool isBold = false, Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: textTheme.bodySmall),
          Text(
            value,
            style: textTheme.bodySmall?.copyWith(
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                color: valueColor
            ),
          ),
        ],
      ),
    );
  }
}
