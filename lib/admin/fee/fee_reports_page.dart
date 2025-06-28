// lib/admin/pages/fee/fee_reports_page.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math';

class FeeReportSummary {
  final double totalCollected;
  final double totalDue;
  final double totalDiscountGiven;
  final int totalTransactions;

  FeeReportSummary({
    required this.totalCollected,
    required this.totalDue,
    required this.totalDiscountGiven,
    required this.totalTransactions,
  });
}

class FeeTransactionItem {
  final String id;
  final DateTime paymentDate;
  final String receiptNumber;
  final String studentName;
  final String className;
  final String rollNumber;
  final List<String> paidForMonths;
  final double grossAmount;
  final double discount;
  final double netAmountPaid;
  final String paymentMode;
  final String collectedBy;

  FeeTransactionItem({
    required this.id,
    required this.paymentDate,
    required this.receiptNumber,
    required this.studentName,
    required this.className,
    required this.rollNumber,
    required this.paidForMonths,
    required this.grossAmount,
    required this.discount,
    required this.netAmountPaid,
    required this.paymentMode,
    required this.collectedBy,
  });
}

class FeeReportsPage extends StatefulWidget {
  const FeeReportsPage({super.key});

  @override
  State<FeeReportsPage> createState() => _FeeReportsPageState();
}

class _FeeReportsPageState extends State<FeeReportsPage> {
  DateTimeRange? _selectedDateRange;
  String? _selectedClassFilter;
  String? _selectedPaymentModeFilter;
  final TextEditingController _searchQueryController = TextEditingController();

  FeeReportSummary? _reportSummary;
  List<FeeTransactionItem> _transactions = [];
  bool _isLoading = false;
  String? _errorMessage;

  final List<String> _classListForFilter = [
    "All Classes", "Nursery", "LKG", "UKG", "Class 1", "Class 10 A", "Class 12 Science"
  ];
  final List<String> _paymentModesForFilter = [
    "All Modes", "Cash", "Cheque", "Digital Payment", "Challan"
  ];

  Map<String, double> _collectionByClassData = {};
  Map<String, double> _collectionByPaymentModeData = {};

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDateRange = DateTimeRange(
      start: DateTime(now.year, now.month, 1),
      end: DateTime(now.year, now.month, DateTime(now.year, now.month + 1, 0).day, 23, 59, 59),
    );
    _fetchReportData();
  }

  @override
  void dispose() {
    _searchQueryController.dispose();
    super.dispose();
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      initialDateRange: _selectedDateRange ?? DateTimeRange(
        start: DateTime.now().subtract(const Duration(days: 30)),
        end: DateTime.now(),
      ),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDateRange) {
      setState(() {
        _selectedDateRange = picked;
      });
      _fetchReportData();
    }
  }

  void _prepareChartData() {
    _collectionByClassData.clear();
    for (var transaction in _transactions) {
      _collectionByClassData.update(
        transaction.className,
            (value) => value + transaction.netAmountPaid,
        ifAbsent: () => transaction.netAmountPaid,
      );
    }

    _collectionByPaymentModeData.clear();
    for (var transaction in _transactions) {
      _collectionByPaymentModeData.update(
        transaction.paymentMode,
            (value) => value + transaction.netAmountPaid,
        ifAbsent: () => transaction.netAmountPaid,
      );
    }
  }

  Future<void> _fetchReportData() async {
    if (_selectedDateRange == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a date range."), backgroundColor: Colors.orangeAccent),
      );
      return;
    }
    setState(() { _isLoading = true; _errorMessage = null; });

    await Future.delayed(const Duration(seconds: 1));

    try {
      final random = Random();
      _reportSummary = FeeReportSummary(
        totalCollected: random.nextDouble() * 200000 + 50000,
        totalDue: random.nextDouble() * 50000,
        totalDiscountGiven: random.nextDouble() * 5000,
        totalTransactions: random.nextInt(100) + 20,
      );

      _transactions = List.generate(_reportSummary!.totalTransactions, (index) {
        final classes = ["Nursery", "LKG", "UKG", "Class 1", "Class 10 A", "Class 12 Science"];
        final paymentModes = ["Cash", "Cheque", "Digital Payment", "Challan"];
        String className = _selectedClassFilter == "All Classes" || _selectedClassFilter == null
            ? classes[random.nextInt(classes.length)]
            : _selectedClassFilter!;
        String paymentMode = _selectedPaymentModeFilter == "All Modes" || _selectedPaymentModeFilter == null
            ? paymentModes[random.nextInt(paymentModes.length)]
            : _selectedPaymentModeFilter!;

        double gross = 1000.0 + random.nextInt(4000);
        double discount = random.nextDouble() < 0.2 ? random.nextDouble() * 100 : 0.0;

        return FeeTransactionItem(
          id: 'TXN${1000 + index}',
          paymentDate: _selectedDateRange!.start.add(Duration(
            days: random.nextInt(_selectedDateRange!.duration.inDays + 1),
            hours: random.nextInt(12),
          )),
          receiptNumber: 'R${202400 + index}',
          studentName: 'Student ${String.fromCharCode(65 + random.nextInt(26))}${String.fromCharCode(65 + random.nextInt(26))}',
          className: className,
          rollNumber: '${random.nextInt(50) + 1}',
          paidForMonths: ['Month ${random.nextInt(3) + 1}'],
          grossAmount: gross,
          discount: discount,
          netAmountPaid: gross - discount,
          paymentMode: paymentMode,
          collectedBy: 'Admin',
        );
      }).where((item) {
        bool matchesSearch = _searchQueryController.text.isEmpty ||
            item.studentName.toLowerCase().contains(_searchQueryController.text.toLowerCase()) ||
            item.receiptNumber.toLowerCase().contains(_searchQueryController.text.toLowerCase());
        bool matchesClass = _selectedClassFilter == "All Classes" || _selectedClassFilter == null || item.className == _selectedClassFilter;
        bool matchesMode = _selectedPaymentModeFilter == "All Modes" || _selectedPaymentModeFilter == null || item.paymentMode == _selectedPaymentModeFilter;
        return matchesSearch && matchesClass && matchesMode;
      }).toList();

      if (_transactions.isEmpty && _searchQueryController.text.isNotEmpty) {
        _errorMessage = "No transactions found matching your current filter criteria.";
      }
      _prepareChartData();
    } catch (e) {
      _errorMessage = "Failed to load report: ${e.toString()}";
      _reportSummary = null;
      _transactions = [];
      _collectionByClassData = {};
      _collectionByPaymentModeData = {};
    } finally {
      setState(() { _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Fee Collection Report", style: GoogleFonts.oswald(
                fontSize: 26, fontWeight: FontWeight.bold, color: colorScheme.primary)),
            const SizedBox(height: 16),
            _buildFilterSection(context, colorScheme, textTheme),
            const SizedBox(height: 16),

            if (_isLoading)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else if (_errorMessage != null)
              Expanded(child: Center(child: Text(_errorMessage!,
                  style: TextStyle(color: colorScheme.error, fontSize: 16))))
            else if (_reportSummary == null && _transactions.isEmpty)
                Expanded(child: Center(child: Text("Apply filters to generate report.",
                    style: textTheme.titleMedium)))
              else
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_reportSummary != null)
                          _buildSummarySection(_reportSummary!, colorScheme, textTheme),
                        const SizedBox(height: 16),
                        if (_transactions.isNotEmpty)
                          _buildChartsSection(context, colorScheme, textTheme),
                        const SizedBox(height: 16),
                        if (_transactions.isNotEmpty)
                          _buildTransactionsTable(textTheme),
                        if (_transactions.isEmpty && _searchQueryController.text.isNotEmpty)
                          Center(child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text("No transactions found matching your current filter criteria.",
                                  style: textTheme.titleMedium))),
                      ],
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSection(BuildContext context, ColorScheme colorScheme, TextTheme textTheme) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Filters", style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600, color: colorScheme.secondary)),
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
                    onPressed: () => _selectDateRange(context),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 16.0, runSpacing: 12.0,
              children: [
                SizedBox(
                  width: 200,
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                        labelText: 'Class',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
                    value: _selectedClassFilter ?? _classListForFilter.first,
                    items: _classListForFilter.map((String val) => DropdownMenuItem<String>(
                        value: val, child: Text(val, style: textTheme.bodyMedium))).toList(),
                    onChanged: (String? newValue) => setState(() => _selectedClassFilter = newValue),
                  ),
                ),
                SizedBox(
                  width: 200,
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                        labelText: 'Payment Mode',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
                    value: _selectedPaymentModeFilter ?? _paymentModesForFilter.first,
                    items: _paymentModesForFilter.map((String val) => DropdownMenuItem<String>(
                        value: val, child: Text(val, style: textTheme.bodyMedium))).toList(),
                    onChanged: (String? newValue) => setState(() => _selectedPaymentModeFilter = newValue),
                  ),
                ),
                SizedBox(
                  width: 250,
                  child: TextField(
                    controller: _searchQueryController,
                    decoration: InputDecoration(
                      labelText: 'Search Student/Receipt#',
                      hintText: 'Name, ID, Receipt...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      prefixIcon: const Icon(Icons.search),
                    ),
                    onSubmitted: (_) => _fetchReportData(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.filter_list_rounded),
                  label: const Text('Apply Filters'),
                  onPressed: _fetchReportData,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary),
                ),
                const SizedBox(width: 10),
                OutlinedButton.icon(
                  icon: const Icon(Icons.download_outlined),
                  label: const Text('Export'),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Export functionality not implemented yet.')));
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummarySection(FeeReportSummary summary, ColorScheme colorScheme, TextTheme textTheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Wrap(
        spacing: 16.0, runSpacing: 16.0,
        alignment: WrapAlignment.spaceEvenly,
        children: [
          _buildSummaryCard("Total Collected", "₹${summary.totalCollected.toStringAsFixed(2)}",
              Icons.account_balance_wallet_outlined, Colors.green.shade700, colorScheme),
          _buildSummaryCard("Total Outstanding", "₹${summary.totalDue.toStringAsFixed(2)}",
              Icons.hourglass_empty_rounded, Colors.orange.shade700, colorScheme),
          _buildSummaryCard("Total Discounts", "₹${summary.totalDiscountGiven.toStringAsFixed(2)}",
              Icons.discount_outlined, Colors.blue.shade700, colorScheme),
          _buildSummaryCard("Total Transactions", summary.totalTransactions.toString(),
              Icons.receipt_long_outlined, Colors.purple.shade600, colorScheme),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color iconColor, ColorScheme colorScheme) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Container(
        width: 180,
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: iconColor.withOpacity(0.1),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(height: 8),
            Text(title, style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade700)),
            Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold, color: iconColor)),
          ],
        ),
      ),
    );
  }

  Widget _buildChartsSection(BuildContext context, ColorScheme colorScheme, TextTheme textTheme) {
    if (_collectionByClassData.isEmpty && _collectionByPaymentModeData.isEmpty) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(builder: (context, constraints) {
      bool isWide = constraints.maxWidth > 700;
      if (isWide) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_collectionByClassData.isNotEmpty)
              Expanded(child: _buildCollectionByClassBarChart(context, colorScheme, textTheme)),
            if (_collectionByClassData.isNotEmpty && _collectionByPaymentModeData.isNotEmpty)
              const SizedBox(width: 16),
            if (_collectionByPaymentModeData.isNotEmpty)
              Expanded(child: _buildPaymentModePieChart(context, colorScheme, textTheme)),
          ],
        );
      } else {
        return Column(
          children: [
            if (_collectionByClassData.isNotEmpty)
              _buildCollectionByClassBarChart(context, colorScheme, textTheme),
            if (_collectionByClassData.isNotEmpty && _collectionByPaymentModeData.isNotEmpty)
              const SizedBox(height: 16),
            if (_collectionByPaymentModeData.isNotEmpty)
              _buildPaymentModePieChart(context, colorScheme, textTheme),
          ],
        );
      }
    });
  }

  Widget _buildCollectionByClassBarChart(BuildContext context, ColorScheme colorScheme, TextTheme textTheme) {
    List<BarChartGroupData> barGroups = [];
    double maxY = 0;
    int i = 0;
    final List<Color> barColors = [
      Colors.blue.shade300,
      Colors.green.shade300,
      Colors.orange.shade300,
      Colors.purple.shade300,
      Colors.red.shade300,
      Colors.teal.shade300
    ];

    _collectionByClassData.forEach((className, totalAmount) {
      if (totalAmount > maxY) maxY = totalAmount;
      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: totalAmount,
              color: barColors[i % barColors.length],
              width: 16,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      );
      i++;
    });

    if (barGroups.isEmpty) return const SizedBox.shrink();
    maxY = maxY == 0 ? 100 : (maxY * 1.2);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Collection by Class", style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600)),
            const SizedBox(height: 20),
            SizedBox(
              height: 250,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: maxY,
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        String className = _collectionByClassData.keys.elementAt(group.x);
                        return BarTooltipItem(
                          '$className\n₹${rod.toY.toStringAsFixed(0)}',
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          final index = value.toInt();
                          if (index >= 0 && index < _collectionByClassData.keys.length) {
                            String className = _collectionByClassData.keys.elementAt(index);
                            String shortName = className.length > 8 ? "${className.substring(0,6)}..." : className;
                            return SideTitleWidget(
                              axisSide: meta.axisSide,
                              space: 4.0,
                              child: Text(
                                shortName,
                                style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold),
                              ),
                            );
                          }
                          return const SizedBox();
                        },
                        reservedSize: 30,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          if (value == 0 || value == maxY || value % (maxY / 5).ceil() == 0 && (maxY / 5).ceil() > 0) {
                            return Text(
                              (value/1000).toStringAsFixed(0)+'k',
                              style: const TextStyle(fontSize: 9),
                            );
                          }
                          return const SizedBox();
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: barGroups,
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: Colors.grey.shade300,
                      strokeWidth: 0.5,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentModePieChart(BuildContext context, ColorScheme colorScheme, TextTheme textTheme) {
    List<PieChartSectionData> pieSections = [];
    final List<Color> pieColors = [
      Colors.cyan.shade300,
      Colors.pink.shade300,
      Colors.amber.shade300,
      Colors.lightGreen.shade300,
      Colors.deepPurple.shade300
    ];
    int i = 0;
    double totalValue = _collectionByPaymentModeData.values.fold(0.0, (sum, item) => sum + item);

    if (totalValue == 0) return const SizedBox.shrink();

    _collectionByPaymentModeData.forEach((mode, amount) {
      final percentage = (amount / totalValue) * 100;
      pieSections.add(
        PieChartSectionData(
          color: pieColors[i % pieColors.length],
          value: amount,
          title: '${percentage.toStringAsFixed(1)}%',
          radius: 80,
          titleStyle: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.black.withOpacity(0.7)),
        ),
      );
      i++;
    });

    if (pieSections.isEmpty) return const SizedBox.shrink();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Collection by Payment Mode", style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600)),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: pieSections,
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                  pieTouchData: PieTouchData(
                    touchCallback: (FlTouchEvent event, pieTouchResponse) {},
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildChartLegend(_collectionByPaymentModeData, pieColors),
          ],
        ),
      ),
    );
  }

  Widget _buildChartLegend(Map<String, double> data, List<Color> colors) {
    List<Widget> legendItems = [];
    int i = 0;
    data.forEach((key, value) {
      legendItems.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 4.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 12, height: 12, color: colors[i % colors.length]),
              const SizedBox(width: 6),
              Text(key, style: const TextStyle(fontSize: 11)),
            ],
          ),
        ),
      );
      i++;
    });
    return Wrap(spacing: 16, runSpacing: 4, children: legendItems);
  }

  Widget _buildTransactionsTable(TextTheme textTheme) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(top: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      clipBehavior: Clip.antiAlias,
      child: PaginatedDataTable(
        header: Text('Detailed Transactions',
            style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
        rowsPerPage: 10,
        columns: const [
          DataColumn(label: Text('Date')),
          DataColumn(label: Text('Receipt#')),
          DataColumn(label: Text('Student')),
          DataColumn(label: Text('Class')),
          DataColumn(label: Text('Roll#')),
          DataColumn(label: Text('Months')),
          DataColumn(label: Text('Gross Amt'), numeric: true),
          DataColumn(label: Text('Discount'), numeric: true),
          DataColumn(label: Text('Net Paid'), numeric: true),
          DataColumn(label: Text('Mode')),
          DataColumn(label: Text('Collected By')),
        ],
        source: _FeeTransactionDataSource(_transactions, context),
        columnSpacing: 20,
      ),
    );
  }
}

class _FeeTransactionDataSource extends DataTableSource {
  final List<FeeTransactionItem> _transactions;
  final BuildContext context;

  _FeeTransactionDataSource(this._transactions, this.context);

  @override
  DataRow? getRow(int index) {
    if (index >= _transactions.length) return null;
    final transaction = _transactions[index];
    return DataRow.byIndex(
      index: index,
      cells: [
        DataCell(Text(DateFormat('dd MMM yy').format(transaction.paymentDate))),
        DataCell(Text(transaction.receiptNumber)),
        DataCell(Text(transaction.studentName, overflow: TextOverflow.ellipsis)),
        DataCell(Text(transaction.className)),
        DataCell(Text(transaction.rollNumber)),
        DataCell(Tooltip(
            message: transaction.paidForMonths.join(', '),
            child: Text(transaction.paidForMonths.join(', ').length > 15
                ? '${transaction.paidForMonths.join(', ').substring(0,12)}...'
                : transaction.paidForMonths.join(', ')))),
        DataCell(Text(transaction.grossAmount.toStringAsFixed(2))),
        DataCell(Text(transaction.discount.toStringAsFixed(2))),
        DataCell(Text(transaction.netAmountPaid.toStringAsFixed(2),
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary))),
        DataCell(Text(transaction.paymentMode)),
        DataCell(Text(transaction.collectedBy)),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;
  @override
  int get rowCount => _transactions.length;
  @override
  int get selectedRowCount => 0;
}