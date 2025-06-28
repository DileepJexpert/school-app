// lib/admin/pages/fee/transaction_history_page.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

// --- Data Model for a single transaction record ---
class FeeTransactionRecord {
  final String id; // Unique ID for the transaction itself
  final String studentName;
  final String className;
  final String admissionId;
  final String receiptNumber;
  final double paidAmount;
  final String paymentMode;
  final String academicYear;
  final DateTime createdDate; // When the transaction was recorded in system
  final DateTime receiptDate; // Date on the actual receipt
  final String status; // e.g., "Success", "Cancelled", "Discount", "Refunded"
  // Add other fields as needed, e.g., fee heads covered

  FeeTransactionRecord({
    required this.id,
    required this.studentName,
    required this.className,
    required this.admissionId,
    required this.receiptNumber,
    required this.paidAmount,
    required this.paymentMode,
    required this.academicYear,
    required this.createdDate,
    required this.receiptDate,
    required this.status,
  });
}

// --- Transaction History Page ---
class TransactionHistoryPage extends StatefulWidget {
  const TransactionHistoryPage({super.key});

  @override
  State<TransactionHistoryPage> createState() => _TransactionHistoryPageState();
}

class _TransactionHistoryPageState extends State<TransactionHistoryPage> {
  List<FeeTransactionRecord> _transactions = [];
  List<FeeTransactionRecord> _filteredTransactions = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Filter state variables
  DateTimeRange? _selectedDateRange;
  String? _selectedClassFilter;
  String? _selectedStatusFilter;
  final TextEditingController _searchController = TextEditingController();
  bool _showFilters = true; // To toggle filter section visibility

  // Mock data for filters (replace with actual data from your system)
  final List<String> _classListForFilter = ["All Classes", "Nursery A", "Nursery B", "1ST A", "2ND A", "8TH"];
  final List<String> _statusListForFilter = ["All Statuses", "Success", "Cancelled", "Discount", "Refunded"];

  // For PaginatedDataTable
  int _rowsPerPage = PaginatedDataTable.defaultRowsPerPage;
  int _sortColumnIndex = 7; // Default sort by Created Date (index based on current column order)
  bool _sortAscending = false; // Default descending

  @override
  void initState() {
    super.initState();
    // Set initial date range to last 30 days
    final now = DateTime.now();
    _selectedDateRange = DateTimeRange(
      start: now.subtract(const Duration(days: 30)),
      end: now,
    );
    _fetchTransactionHistory();
    _searchController.addListener(() {
      _applyFilters(); // Apply filters as user types in search
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchTransactionHistory() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // --- Simulate API Call ---
    // TODO: Replace with actual API call to your Spring Boot backend
    // Pass filter parameters: _selectedDateRange, _selectedClassFilter, _selectedStatusFilter, _searchController.text
    await Future.delayed(const Duration(seconds: 1));

    try {
      // Mocked Data (based on your example)
      final allMockTransactions = [
        FeeTransactionRecord(id: "T1", studentName: "Radhika Mishra", className: "2ND A", admissionId: "RS382", receiptNumber: "REC5001", paidAmount: 5000, paymentMode: "Digital Payment", academicYear: "2024-2025", createdDate: DateTime(2025,5,31,14,4), receiptDate: DateTime(2025,5,31), status: "Success"),
        FeeTransactionRecord(id: "T2", studentName: "Mohammad Ibrahim", className: "Nursery B", admissionId: "RS775", receiptNumber: "REC5002", paidAmount: 6100, paymentMode: "Digital Payment", academicYear: "2025-2026", createdDate: DateTime(2025,5,31,10,30), receiptDate: DateTime(2025,5,31), status: "Success"),
        FeeTransactionRecord(id: "T3", studentName: "Riya Nishad", className: "2ND A", admissionId: "RS449", receiptNumber: "REC5003", paidAmount: 850, paymentMode: "Digital Payment", academicYear: "2024-2025", createdDate: DateTime(2025,5,26,7,27), receiptDate: DateTime(2025,5,26), status: "Cancelled"),
        FeeTransactionRecord(id: "T4", studentName: "Khushi Nishad", className: "8TH", admissionId: "RS576", receiptNumber: "REC5004", paidAmount: 900, paymentMode: "Digital Payment", academicYear: "2024-2025", createdDate: DateTime(2025,5,26,7,26), receiptDate: DateTime(2025,5,26), status: "Cancelled"),
        FeeTransactionRecord(id: "T5", studentName: "Rishabh Gupta", className: "Nursery A", admissionId: "RS774", receiptNumber: "REC5005", paidAmount: 3700, paymentMode: "Digital Payment", academicYear: "2025-2026", createdDate: DateTime(2025,5,22,12,7), receiptDate: DateTime(2025,5,22), status: "Success"),
        FeeTransactionRecord(id: "T6", studentName: "Rishi Gupta", className: "1ST A", admissionId: "RS662", receiptNumber: "REC5006D", paidAmount: 400, paymentMode: "N/A", academicYear: "2024-2025", createdDate: DateTime(2025,5,22,11,23), receiptDate: DateTime(2025,5,22), status: "Discount"),
        FeeTransactionRecord(id: "T7", studentName: "Rishi Gupta", className: "1ST A", admissionId: "RS662", receiptNumber: "REC5006P", paidAmount: 3000, paymentMode: "Digital Payment", academicYear: "2024-2025", createdDate: DateTime(2025,5,22,11,23), receiptDate: DateTime(2025,5,22), status: "Success"),
      ];

      setState(() {
        _transactions = allMockTransactions;
        _applyFilters();
      });

    } catch (e) {
      setState(() {
        _errorMessage = "Failed to load transaction history: ${e.toString()}";
        _transactions = [];
        _filteredTransactions = [];
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _applyFilters() {
    List<FeeTransactionRecord> tempFiltered = List.from(_transactions);

    if (_selectedDateRange != null) {
      tempFiltered = tempFiltered.where((t) =>
      !t.receiptDate.isBefore(_selectedDateRange!.start) &&
          !t.receiptDate.isAfter(_selectedDateRange!.end.add(const Duration(days: 1)).subtract(const Duration(microseconds: 1)))
      ).toList();
    }
    if (_selectedClassFilter != null && _selectedClassFilter != "All Classes") {
      tempFiltered = tempFiltered.where((t) => t.className == _selectedClassFilter).toList();
    }
    if (_selectedStatusFilter != null && _selectedStatusFilter != "All Statuses") {
      tempFiltered = tempFiltered.where((t) => t.status == _selectedStatusFilter).toList();
    }
    String query = _searchController.text.toLowerCase();
    if (query.isNotEmpty) {
      tempFiltered = tempFiltered.where((t) =>
      t.studentName.toLowerCase().contains(query) ||
          t.admissionId.toLowerCase().contains(query) ||
          t.receiptNumber.toLowerCase().contains(query) ||
          t.className.toLowerCase().contains(query)
      ).toList();
    }
    setState(() {
      _filteredTransactions = tempFiltered;
      _sortTransactions();
    });
  }

  void _sortTransactions() {
    _filteredTransactions.sort((a, b) {
      int compare;
      // Ensure _sortColumnIndex is valid for the columns list
      // The columns are: Name, Class, Adm.ID, Receipt#, PaidAmt, PayMode, Acad.Yr, Created, ReceiptDt, Status, Action
      // Indices:        0,     1,     2,       3,        4,       5,        6,         7,         8,          9,        10
      switch (_sortColumnIndex) {
        case 0: compare = a.studentName.compareTo(b.studentName); break;
        case 1: compare = a.className.compareTo(b.className); break;
        case 2: compare = a.admissionId.compareTo(b.admissionId); break;
        case 3: compare = a.receiptNumber.compareTo(b.receiptNumber); break;
        case 4: compare = a.paidAmount.compareTo(b.paidAmount); break;
      // case 5: Pay Mode - not typically sorted unless specific need
      // case 6: Acad Year - might be useful
        case 7: compare = a.createdDate.compareTo(b.createdDate); break;
        case 8: compare = a.receiptDate.compareTo(b.receiptDate); break;
        case 9: compare = a.status.compareTo(b.status); break;
        default: compare = b.createdDate.compareTo(a.createdDate); // Default sort by created date descending
      }
      return _sortAscending ? compare : -compare;
    });
  }

  Future<void> _selectDateRangePicker(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      initialDateRange: _selectedDateRange ?? DateTimeRange(start: DateTime.now().subtract(const Duration(days: 30)), end: DateTime.now()),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDateRange) {
      setState(() {
        _selectedDateRange = picked;
      });
      _applyFilters();
    }
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text("Transaction History / Ledger", style: GoogleFonts.lato()),
        backgroundColor: colorScheme.primaryContainer,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPageActions(context, colorScheme), // New action row
            if (_showFilters) // Conditionally display filters
              _buildFilterControls(context, colorScheme, textTheme),
            const SizedBox(height: 16),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _errorMessage != null
                  ? Center(child: Text(_errorMessage!, style: TextStyle(color: Colors.red, fontSize: 16)))
                  : _filteredTransactions.isEmpty
                  ? Center(child: Text("No transactions found matching your criteria.", style: textTheme.titleMedium))
                  : _buildDataTable(textTheme),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageActions(BuildContext context, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton.icon(
            icon: Icon(_showFilters ? Icons.filter_list_off_outlined : Icons.filter_list_alt, color: colorScheme.primary), // Corrected Icon
            label: Text(_showFilters ? "Hide Filters" : "Show Filters", style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.w600)),
            onPressed: () {
              setState(() {
                _showFilters = !_showFilters;
              });
            },
            style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                side: BorderSide(color: colorScheme.primary.withOpacity(0.5))
            ),
          ),
          Row(
            children: [
              TextButton.icon(
                icon: Icon(Icons.print_outlined, color: colorScheme.secondary, size: 20),
                label: Text("Print", style: TextStyle(color: colorScheme.secondary)),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Print functionality not implemented yet.'))
                  );
                  // TODO: Implement Print
                },
                style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                icon: Icon(Icons.download_outlined, color: colorScheme.secondary, size: 20),
                label: Text("Download", style: TextStyle(color: colorScheme.secondary)),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Download functionality not implemented yet.'))
                  );
                  // TODO: Implement Download
                },
                style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
              ),
            ],
          ),
        ],
      ),
    );
  }


  Widget _buildFilterControls(BuildContext context, ColorScheme colorScheme, TextTheme textTheme) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Filters", style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600, color: colorScheme.secondary)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextButton.icon(
                    icon: Icon(Icons.calendar_today_outlined, color: colorScheme.primary),
                    label: Text(
                      _selectedDateRange != null
                          ? '${DateFormat('dd MMM yy').format(_selectedDateRange!.start)} - ${DateFormat('dd MMM yy').format(_selectedDateRange!.end)}'
                          : 'Select Date Range',
                      style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.w600),
                    ),
                    onPressed: () => _selectDateRangePicker(context),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 16.0,
              runSpacing: 12.0,
              children: [
                SizedBox(
                  width: 200,
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(labelText: 'Class', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
                    value: _selectedClassFilter ?? _classListForFilter.first,
                    items: _classListForFilter.map((String val) => DropdownMenuItem<String>(value: val, child: Text(val, style: textTheme.bodyMedium))).toList(),
                    onChanged: (String? newValue) => setState(() { _selectedClassFilter = newValue; _applyFilters(); }),
                  ),
                ),
                SizedBox(
                  width: 200,
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(labelText: 'Status', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
                    value: _selectedStatusFilter ?? _statusListForFilter.first,
                    items: _statusListForFilter.map((String val) => DropdownMenuItem<String>(value: val, child: Text(val, style: textTheme.bodyMedium))).toList(),
                    onChanged: (String? newValue) => setState(() { _selectedStatusFilter = newValue; _applyFilters(); }),
                  ),
                ),
                SizedBox(
                  width: 250,
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      labelText: 'Search Student/Adm#/Receipt#',
                      hintText: 'Type to search...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      prefixIcon: const Icon(Icons.search),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row( // Added Apply Filters button back inside the card for clarity
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('Apply Filters'),
                  onPressed: _fetchTransactionHistory, // This re-fetches and applies filters
                  style: ElevatedButton.styleFrom(backgroundColor: colorScheme.primary, foregroundColor: colorScheme.onPrimary),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataTable(TextTheme textTheme) {
    final List<DataColumn> columns = [
      DataColumn(label: Text('Student Name'), onSort: (columnIndex, ascending) => _onSort(columnIndex, ascending), tooltip: "Student's Full Name"),
      DataColumn(label: Text('Class'), onSort: (columnIndex, ascending) => _onSort(columnIndex, ascending)),
      DataColumn(label: Text('Adm. ID'), onSort: (columnIndex, ascending) => _onSort(columnIndex, ascending)),
      DataColumn(label: Text('Receipt #'), onSort: (columnIndex, ascending) => _onSort(columnIndex, ascending)),
      DataColumn(label: Text('Paid Amt.'), numeric: true, onSort: (columnIndex, ascending) => _onSort(columnIndex, ascending)),
      DataColumn(label: Text('Pay Mode')),
      DataColumn(label: Text('Acad. Year')),
      DataColumn(label: Text('Created Date'), onSort: (columnIndex, ascending) => _onSort(columnIndex, ascending)),
      DataColumn(label: Text('Receipt Date'), onSort: (columnIndex, ascending) => _onSort(columnIndex, ascending)),
      DataColumn(label: Text('Status'), onSort: (columnIndex, ascending) => _onSort(columnIndex, ascending)),
      DataColumn(label: Text('Action')),
    ];

    return PaginatedDataTable(
      header: Text('Transaction Records', style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
      rowsPerPage: _rowsPerPage,
      onRowsPerPageChanged: (value) {
        setState(() {
          _rowsPerPage = value ?? PaginatedDataTable.defaultRowsPerPage;
        });
      },
      sortColumnIndex: _sortColumnIndex,
      sortAscending: _sortAscending,
      columns: columns,
      source: _TransactionDataSource(_filteredTransactions, context),
      columnSpacing: 10, // Reduced for more columns
      showCheckboxColumn: false,
      dataRowMaxHeight: 52, // Default is 48, can adjust
    );
  }

  void _onSort(int columnIndex, bool ascending) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
      _sortTransactions();
    });
  }
}

class _TransactionDataSource extends DataTableSource {
  final List<FeeTransactionRecord> _transactions;
  final BuildContext context;

  _TransactionDataSource(this._transactions, this.context);

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'success': return Colors.green.shade700;
      case 'cancelled': return Colors.red.shade700;
      case 'discount': return Colors.blue.shade700;
      case 'refunded': return Colors.orange.shade700;
      default: return Colors.grey.shade700;
    }
  }

  @override
  DataRow? getRow(int index) {
    if (index >= _transactions.length) return null;
    final transaction = _transactions[index];
    return DataRow.byIndex(
      index: index,
      cells: [
        DataCell(Text(transaction.studentName, overflow: TextOverflow.ellipsis)),
        DataCell(Text(transaction.className)),
        DataCell(Text(transaction.admissionId)),
        DataCell(Text(transaction.receiptNumber, overflow: TextOverflow.ellipsis)),
        DataCell(Text('₹${transaction.paidAmount.toStringAsFixed(2)}')),
        DataCell(Text(transaction.paymentMode)),
        DataCell(Text(transaction.academicYear)),
        DataCell(Text(DateFormat('dd MMM yy, hh:mm a').format(transaction.createdDate))),
        DataCell(Text(DateFormat('dd MMM yy').format(transaction.receiptDate))),
        DataCell(
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getStatusColor(transaction.status).withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                transaction.status,
                style: TextStyle(color: _getStatusColor(transaction.status), fontWeight: FontWeight.w500, fontSize: 12),
              ),
            )
        ),
        DataCell(
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert_rounded, size: 20),
              tooltip: "Actions",
              onSelected: (value) {
                if (value == 'view_receipt') {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('View Receipt for ${transaction.receiptNumber} (Not Implemented)')));
                } else if (value == 'cancel_transaction' && transaction.status != "Cancelled") {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Cancel Transaction ${transaction.receiptNumber} (Not Implemented)')));
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: 'view_receipt',
                  child: Row(children: [Icon(Icons.receipt_outlined, size: 18), SizedBox(width: 8), Text('View Receipt')]),
                ),
                if (transaction.status != "Cancelled" && transaction.status != "Refunded")
                  const PopupMenuItem<String>(
                    value: 'cancel_transaction',
                    child: Row(children: [Icon(Icons.cancel_outlined, size: 18, color: Colors.red), SizedBox(width: 8), Text('Cancel')]),
                  ),
              ],
            )
        ),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;
  @override
  int get rowCount => _transactions.length; // Corrected: Use _transactions.length
  @override
  int get selectedRowCount => 0;
}
