import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

// Import your data models and API service
import '../../../models/student_fee_profile.dart';
import '../../../models/fee_installment.dart';
import '../../../models/payment_record.dart';
import '../../../models/fee_payment_request.dart';
import '../../../services/fee_api_service.dart';
import '../../../exceptions/api_exception.dart';


class FeeCollectionPage extends StatefulWidget {
  const FeeCollectionPage({super.key});

  @override
  State<FeeCollectionPage> createState() => _FeeCollectionPageState();
}

class _FeeCollectionPageState extends State<FeeCollectionPage> {
  // API Service Instance
  final FeeApiService _feeApiService = FeeApiService();

  // State variables
  final TextEditingController _searchNameOrIdController = TextEditingController();
  final TextEditingController _searchRollNoController = TextEditingController();
  String? _selectedClassFilter;

  List<StudentFeeProfile> _searchResults = [];
  StudentFeeProfile? _selectedStudent;

  bool _isSearching = false;
  bool _isProcessingPayment = false;
  String? _errorMessage;
  Timer? _debounce;

  // Form field controllers
  double _discountAmount = 0.0;
  final TextEditingController _discountController = TextEditingController(text: "0.00");
  DateTime _paymentDate = DateTime.now();
  String? _selectedPaymentMode;
  final TextEditingController _remarksController = TextEditingController();
  final TextEditingController _chequeDetailsController = TextEditingController();
  final TextEditingController _transactionIdController = TextEditingController();

  final List<String> _paymentModes = ['CASH', 'CHEQUE', 'DIGITAL_PAYMENT', 'CHALLAN'];
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
    _debounce = Timer(const Duration(milliseconds: 600), _performSearch);
  }

  void _performSearch() async {
    final name = _searchNameOrIdController.text;
    final rollNo = _searchRollNoController.text;
    final className = _selectedClassFilter;

    if (name.isEmpty && rollNo.isEmpty && className == null) {
      setState(() {
        _searchResults = [];
        _selectedStudent = null;
        _errorMessage = null;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _errorMessage = null;
      _selectedStudent = null;
      _searchResults = [];
    });

    try {
      final results = await _feeApiService.searchStudents(
        name: name,
        className: className,
        rollNumber: rollNo,
      );

      if (results.isEmpty) {
        setState(() => _errorMessage = "No students found matching the criteria.");
      } else if (results.length == 1) {
        setState(() {
          _selectedStudent = results.first;
          _searchResults = [];
          _resetPaymentFields();
        });
      } else {
        setState(() => _searchResults = results);
      }
    } on ApiException catch (e) {
      setState(() => _errorMessage = e.message);
    } catch (e) {
      setState(() => _errorMessage = "An unexpected error occurred: $e");
    } finally {
      setState(() => _isSearching = false);
    }
  }

  Future<void> _loadStudentProfile(String studentId) async {
    setState(() {
      _isSearching = true;
      _errorMessage = null;
      _selectedStudent = null;
      _searchResults = [];
    });

    try {
      final studentProfile = await _feeApiService.getStudentFeeProfileById(studentId);
      setState(() {
        _selectedStudent = studentProfile;
        _resetPaymentFields();
      });
    } on ApiException catch (e) {
      setState(() => _errorMessage = e.message);
    } catch (e) {
      setState(() => _errorMessage = "An unexpected error occurred: $e");
    } finally {
      setState(() => _isSearching = false);
    }
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
      for (var installment in _selectedStudent!.feeInstallments) {
        installment.isSelectedForPayment = false;
      }
    }
  }

  double _calculateTotalSelectedFee() {
    if (_selectedStudent == null) return 0.0;
    return _selectedStudent!.feeInstallments
        .where((m) => m.isSelectedForPayment && m.status != 'PAID')
        .fold(0.0, (sum, item) => sum + item.amountDue);
  }

  double _calculateNetPayable() => _calculateTotalSelectedFee() - _discountAmount;

  Future<void> _selectPaymentDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _paymentDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null && picked != _paymentDate) {
      setState(() => _paymentDate = picked);
    }
  }

  Future<void> _processPayment() async {
    if (_selectedStudent == null) return;

    final List<String> installmentsToPay = _selectedStudent!.feeInstallments
        .where((m) => m.isSelectedForPayment && m.status != 'PAID')
        .map((m) => m.installmentName)
        .toList();

    if (installmentsToPay.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select at least one unpaid installment.')));
      return;
    }
    if (_selectedPaymentMode == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a payment mode.')));
      return;
    }

    setState(() => _isProcessingPayment = true);

    final paymentRequest = FeePaymentRequest(
      studentId: _selectedStudent!.id,
      amount: _calculateNetPayable(),
      discount: _discountAmount,
      installmentNames: installmentsToPay,
      paymentMode: _selectedPaymentMode!,
      remarks: _remarksController.text.isNotEmpty ? _remarksController.text : null,
      chequeDetails: _selectedPaymentMode == 'CHEQUE' ? _chequeDetailsController.text : null,
      transactionId: _selectedPaymentMode == 'DIGITAL_PAYMENT' ? _transactionIdController.text : null,
    );

    try {
      final paymentRecord = await _feeApiService.collectFee(paymentRequest);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Payment successful! Receipt No: ${paymentRecord.receiptNumber}'),
          backgroundColor: Colors.green,
        ));
        _showReceiptDialog(paymentRecord);
        _loadStudentProfile(_selectedStudent!.id);
      }
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Payment Failed: ${e.message}'),
          backgroundColor: Colors.redAccent,
        ));
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessingPayment = false);
      }
    }
  }

  void _showReceiptDialog(PaymentRecord record) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Payment Receipt', style: GoogleFonts.lato(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Receipt No: ${record.receiptNumber}'),
                Text('Student: ${record.studentName}'),
                Text('Amount Paid: ₹${record.amountPaid.toStringAsFixed(2)}'),
                if (record.discount > 0)
                  Text('Discount Given: ₹${record.discount.toStringAsFixed(2)}'),
                Text('Payment Date: ${DateFormat('dd MMM, yyyy').format(record.paymentDate)}'),
                Text('Payment Mode: ${record.paymentMode}'),
                Text('Installments Paid: ${record.paidForInstallments.join(", ")}'),
                if (record.remarks != null && record.remarks!.isNotEmpty)
                  Text('Remarks: ${record.remarks!}'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(child: const Text('Close'), onPressed: () => Navigator.of(context).pop()),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 2, child: _buildSearchFilters(context)),
                const SizedBox(width: 16),
                Expanded(flex: 3, child: _buildResultsArea(context)),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: _isSearching
                  ? const Center(child: CircularProgressIndicator())
                  : _selectedStudent != null
                  ? _buildFeeCollectionFormContent(context)
                  : Center(
                child: Text(
                  _errorMessage ?? 'Search for a student to view and collect fees.',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey.shade600),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchFilters(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Column(
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
                    setState(() => _selectedClassFilter = newValue);
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
    );
  }

  Widget _buildResultsArea(BuildContext context) {
    if (_isSearching) {
      return const Center(child: SizedBox(height: 110, child: Center(child: CircularProgressIndicator())));
    }
    if (_selectedStudent != null) {
      return _buildStudentDetailsCard(context);
    }
    if (_searchResults.isNotEmpty) {
      return _buildSearchResultsList(context);
    }
    return Container(
      height: 110,
      alignment: Alignment.center,
      child: Text(
        _errorMessage ?? "Search results will appear here.",
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: _errorMessage != null ? Colors.red : Colors.grey),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildSearchResultsList(BuildContext context) {
    return Card(
      elevation: 2,
      child: Container(
        constraints: const BoxConstraints(maxHeight: 110),
        child: ListView.builder(
          itemCount: _searchResults.length,
          itemBuilder: (context, index) {
            final student = _searchResults[index];
            return ListTile(
              title: Text(student.name),
              subtitle: Text("${student.className} | Roll: ${student.rollNumber}"),
              onTap: () => _loadStudentProfile(student.id),
              dense: true,
            );
          },
        ),
      ),
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

    final firstUnpaidInstallment = _selectedStudent!.feeInstallments.firstWhere(
          (m) => m.status != 'PAID',
      orElse: () => FeeInstallment(
        installmentName: "N/A",
        status: 'PAID',
        amountDue: 0,
      ),
    );

    if (firstUnpaidInstallment.installmentName != "N/A") {
      nextDueDate = firstUnpaidInstallment.installmentName;
    }

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Fee Status Overview", style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: colorScheme.secondary)),
            const Divider(height: 16),
            _buildStatusRow(context, "Total Annual Fee:", "₹${_selectedStudent!.totalFees.toStringAsFixed(2)}"),
            _buildStatusRow(context, "Total Paid:", "₹${_selectedStudent!.paidFees.toStringAsFixed(2)}", valueColor: Colors.green.shade700),
            _buildStatusRow(context, "Total Discount:", "₹${_selectedStudent!.totalDiscountGiven.toStringAsFixed(2)}", valueColor: Colors.blue.shade700),
            _buildStatusRow(context, "Total Due:", "₹${_selectedStudent!.dueFees.toStringAsFixed(2)}", valueColor: _selectedStudent!.dueFees > 0 ? colorScheme.error : Colors.green.shade700),
            _buildStatusRow(context, "Next Due:", nextDueDate),
            if (_selectedStudent!.lastPayment != null) ...[
              const Divider(height: 16),
              Text("Last Payment Details:", style: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600)),
              _buildStatusRow(context, "  Date:", DateFormat('dd MMM, yyyy').format(_selectedStudent!.lastPayment!.paymentDate)),
              _buildStatusRow(context, "  Amount:", "₹${_selectedStudent!.lastPayment!.amountPaid.toStringAsFixed(2)}"),
              if (_selectedStudent!.lastPayment!.discount > 0)
                _buildStatusRow(context, "  Discount:", "₹${_selectedStudent!.lastPayment!.discount.toStringAsFixed(2)}"),
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

  Widget _buildMonthChip(BuildContext context, FeeInstallment installment) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final bool isActuallyPaid = installment.status == 'PAID';
    final bool isCurrentlySelectedForPayment = installment.isSelectedForPayment;

    final parts = installment.installmentName.split(' - ');
    final String monthName = (parts.length > 1) ? parts[1].substring(0, 3).toUpperCase() : installment.installmentName.substring(0, 3).toUpperCase();
    final String feeType = parts[0];


    Color chipColor = isActuallyPaid
        ? Colors.green.shade50
        : (isCurrentlySelectedForPayment ? Colors.blue.shade100 : Colors.orange.shade50);
    Color borderColor = isActuallyPaid
        ? Colors.green.shade300
        : (isCurrentlySelectedForPayment ? colorScheme.primary : Colors.orange.shade300);
    Color contentColor = isActuallyPaid ? Colors.green.shade800 : Colors.black87;
    IconData? chipIconData = isActuallyPaid ? Icons.check_circle_outline : (isCurrentlySelectedForPayment ? Icons.check_box_outlined : null);


    return Tooltip(
      message: '${installment.installmentName}\nFee: ₹${installment.amountDue.toStringAsFixed(2)}${isActuallyPaid ? "\n(PAID)" : ""}',
      child: GestureDetector(
        onTap: isActuallyPaid ? null : () {
          setState(() {
            installment.isSelectedForPayment = !installment.isSelectedForPayment;
          });
        },
        child: Container(
          width: 75,
          height: 75,
          margin: const EdgeInsets.all(3.0),
          decoration: BoxDecoration(
              color: chipColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: borderColor, width: 1.5),
              boxShadow: [
                if(isCurrentlySelectedForPayment && !isActuallyPaid)
                  BoxShadow(color: colorScheme.primary.withOpacity(0.3), blurRadius: 2, spreadRadius: 0.5)
              ]
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      monthName,
                      style: textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: contentColor,
                      ),
                    ),
                    Text(
                      feeType,
                      style: textTheme.labelSmall?.copyWith(fontSize: 8, color: contentColor.withOpacity(0.8)),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '₹${installment.amountDue.toStringAsFixed(0)}',
                      style: textTheme.labelSmall?.copyWith(fontSize: 10, color: contentColor.withOpacity(0.9)),
                    ),
                  ],
                ),
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
        Text('Select Installments for Payment:', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Container(
            constraints: const BoxConstraints(maxHeight: 250, minHeight: 80),
            decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade200),
                borderRadius: BorderRadius.circular(8)
            ),
            child: _selectedStudent == null || _selectedStudent!.feeInstallments.isEmpty
                ? Center(child: Padding(padding: const EdgeInsets.all(16.0), child: Text("No fee structure found.", style: textTheme.titleSmall)))
                : Padding(
              padding: const EdgeInsets.all(4.0),
              child: SingleChildScrollView(
                child: Wrap(
                  spacing: 6.0,
                  runSpacing: 6.0,
                  children: _selectedStudent!.feeInstallments.map((installment) {
                    return _buildMonthChip(context, installment);
                  }).toList(),
                ),
              ),
            )
        ),
      ],
    );

    Widget feeSummaryWidget = Card(
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

    Widget paymentInputWidget = Column(
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
                style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 6)),
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
        if (_selectedPaymentMode == 'CHEQUE') ...[
          const SizedBox(height: 10),
          TextField(controller: _chequeDetailsController, decoration: InputDecoration(labelText: 'Cheque No. / Bank Name', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)), contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12))),
        ],
        if (_selectedPaymentMode == 'DIGITAL_PAYMENT') ...[
          const SizedBox(height: 10),
          TextField(controller: _transactionIdController, decoration: InputDecoration(labelText: 'Transaction ID / Ref No.', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)), contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12))),
        ],
        const SizedBox(height: 10),
        TextField(controller: _remarksController, decoration: InputDecoration(labelText: 'Remarks (Optional)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)), contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12)), maxLines: 2),
      ],
    );

    Widget actionButtonsWidget = Column(
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
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: _isProcessingPayment
                  ? Container(width: 20, height: 20, margin: const EdgeInsets.only(right: 8), child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                  : const Icon(Icons.check_circle_outline),
              label: Text(_isProcessingPayment ? 'PROCESSING...' : 'Process Payment & Generate Receipt'),
              onPressed: _isProcessingPayment ? null : _processPayment,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: Theme.of(context).textTheme.labelLarge?.copyWith(color: Theme.of(context).colorScheme.onPrimary, fontSize: 16),
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
