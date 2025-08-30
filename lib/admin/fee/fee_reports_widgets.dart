import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

import 'package:school_website/models//fee_report_models.dart';
import 'fee_reports_page.dart';

// ---------------- FILTER SECTION ----------------
Widget buildFilterSection({
  required BuildContext context,
  required ColorScheme colorScheme,
  required TextTheme textTheme,
  required DateTimeRange? selectedDateRange,
  required String? selectedClassFilter,
  required String? selectedPaymentModeFilter,
  required TextEditingController searchController,
  required List<String> classListForFilter,
  required List<String> paymentModesForFilter,
  required VoidCallback onApplyFilters,
  required VoidCallback onSelectDateRange,
  required ValueChanged<String?> onClassFilterChange,
  required ValueChanged<String?> onPaymentModeChange,
}) {
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
                    selectedDateRange != null
                        ? '${DateFormat('dd MMM yy').format(selectedDateRange.start)} - ${DateFormat('dd MMM yy').format(selectedDateRange.end)}'
                        : 'Select Date Range',
                    style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.w600),
                  ),
                  onPressed: onSelectDateRange,
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
                  decoration: InputDecoration(
                      labelText: 'Class',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
                  value: selectedClassFilter ?? classListForFilter.first,
                  items: classListForFilter.map((String val) => DropdownMenuItem<String>(
                      value: val, child: Text(val, style: textTheme.bodyMedium))).toList(),
                  onChanged: onClassFilterChange,
                ),
              ),
              SizedBox(
                width: 200,
                child: DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                      labelText: 'Payment Mode',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
                  value: selectedPaymentModeFilter ?? paymentModesForFilter.first,
                  items: paymentModesForFilter.map((String val) => DropdownMenuItem<String>(
                      value: val, child: Text(val, style: textTheme.bodyMedium))).toList(),
                  onChanged: onPaymentModeChange,
                ),
              ),
              SizedBox(
                width: 250,
                child: TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    labelText: 'Search Student/Receipt#',
                    hintText: 'Name, ID, Receipt...',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    prefixIcon: const Icon(Icons.search),
                  ),
                  onSubmitted: (_) => onApplyFilters(),
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
                onPressed: onApplyFilters,
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

// ---------------- SUMMARY SECTION ----------------
Widget buildSummarySection(FeeReportSummary summary, ColorScheme colorScheme, TextTheme textTheme, BuildContext context) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: Wrap(
      spacing: 16.0,
      runSpacing: 16.0,
      alignment: WrapAlignment.spaceEvenly,
      children: [
        _buildSummaryCard("Total Collected", "₹${summary.totalCollected.toStringAsFixed(2)}",
            Icons.account_balance_wallet_outlined, Colors.green.shade700, context),
        _buildSummaryCard("Total Outstanding", "₹${summary.totalDue.toStringAsFixed(2)}",
            Icons.hourglass_empty_rounded, Colors.orange.shade700, context),
        _buildSummaryCard("Total Discounts", "₹${summary.totalDiscountGiven.toStringAsFixed(2)}",
            Icons.discount_outlined, Colors.blue.shade700, context),
        _buildSummaryCard("Total Transactions", summary.totalTransactions.toString(),
            Icons.receipt_long_outlined, Colors.purple.shade600, context),
      ],
    ),
  );
}

Widget _buildSummaryCard(String title, String value, IconData icon, Color iconColor, BuildContext context) {
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

// ---------------- CHARTS SECTION ----------------
Widget buildChartsSection(BuildContext context, ColorScheme colorScheme, TextTheme textTheme,
    Map<String, double> collectionByClassData, Map<String, double> collectionByPaymentModeData) {
  if (collectionByClassData.isEmpty && collectionByPaymentModeData.isEmpty) {
    return const SizedBox.shrink();
  }

  return LayoutBuilder(builder: (context, constraints) {
    bool isWide = constraints.maxWidth > 700;
    if (isWide) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (collectionByClassData.isNotEmpty)
            Expanded(child: _buildCollectionByClassBarChart(collectionByClassData, textTheme)),
          if (collectionByClassData.isNotEmpty && collectionByPaymentModeData.isNotEmpty)
            const SizedBox(width: 16),
          if (collectionByPaymentModeData.isNotEmpty)
            Expanded(child: _buildPaymentModePieChart(collectionByPaymentModeData, textTheme)),
        ],
      );
    } else {
      return Column(
        children: [
          if (collectionByClassData.isNotEmpty)
            _buildCollectionByClassBarChart(collectionByClassData, textTheme),
          if (collectionByClassData.isNotEmpty && collectionByPaymentModeData.isNotEmpty)
            const SizedBox(height: 16),
          if (collectionByPaymentModeData.isNotEmpty)
            _buildPaymentModePieChart(collectionByPaymentModeData, textTheme),
        ],
      );
    }
  });
}

Widget _buildCollectionByClassBarChart(Map<String, double> data, TextTheme textTheme) {
  final barGroups = <BarChartGroupData>[];
  double maxY = 0;
  int i = 0;
  final colors = [Colors.blue, Colors.green, Colors.orange, Colors.purple, Colors.red, Colors.teal];

  data.forEach((className, totalAmount) {
    if (totalAmount > maxY) maxY = totalAmount;
    barGroups.add(
      BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: totalAmount,
            color: colors[i % colors.length],
            width: 16,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
    i++;
  });

  return Card(
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Collection by Class", style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 20),
          SizedBox(
            height: 250,
            child: BarChart(
              BarChartData(
                maxY: maxY * 1.2,
                barGroups: barGroups,
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < data.keys.length) {
                          String className = data.keys.elementAt(index);
                          String shortName = className.length > 8 ? "${className.substring(0, 6)}..." : className;
                          return SideTitleWidget(
                            meta: meta,   // ✅ required in fl_chart >= 1.0.0
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
                          return SideTitleWidget(
                            meta: meta,   // ✅ required in fl_chart >= 1.0.0
                            space: 4.0,
                            child: Text(
                              (value / 1000).toStringAsFixed(0) + 'k',
                              style: const TextStyle(fontSize: 9),
                            ),
                          );
                        }
                        return const SizedBox();
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildPaymentModePieChart(Map<String, double> data, TextTheme textTheme) {
  final pieSections = <PieChartSectionData>[];
  final colors = [Colors.cyan, Colors.pink, Colors.amber, Colors.lightGreen, Colors.deepPurple];
  int i = 0;
  double totalValue = data.values.fold(0.0, (sum, item) => sum + item);

  data.forEach((mode, amount) {
    final percentage = (amount / totalValue) * 100;
    pieSections.add(
      PieChartSectionData(
        color: colors[i % colors.length],
        value: amount,
        title: '${percentage.toStringAsFixed(1)}%',
        radius: 80,
        titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black),
      ),
    );
    i++;
  });

  return Card(
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Collection by Payment Mode", style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: PieChart(PieChartData(sections: pieSections, centerSpaceRadius: 40)),
          ),
        ],
      ),
    ),
  );
}

// ---------------- TRANSACTIONS TABLE ----------------
Widget buildTransactionsTable(TextTheme textTheme, List<FeeTransactionItem> transactions, BuildContext context) {
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
      source: _FeeTransactionDataSource(transactions, context),
      columnSpacing: 20,
    ),
  );
}

class _FeeTransactionDataSource extends DataTableSource {
  final List<FeeTransactionItem> _transactions;
  final BuildContext context;

  _FeeTransactionDataSource(this._transactions, this.context);

  @override
  DataRow? getRow(int index) {
    if (index >= _transactions.length) return null;
    final txn = _transactions[index];
    return DataRow.byIndex(
      index: index,
      cells: [
        DataCell(Text(DateFormat('dd MMM yy').format(txn.paymentDate))),
        DataCell(Text(txn.receiptNumber)),
        DataCell(Text(txn.studentName, overflow: TextOverflow.ellipsis)),
        DataCell(Text(txn.className)),
        DataCell(Text(txn.rollNumber)),
        DataCell(Text(txn.paidForMonths.join(', '))),
        DataCell(Text(txn.grossAmount.toStringAsFixed(2))),
        DataCell(Text(txn.discount.toStringAsFixed(2))),
        DataCell(Text(txn.netAmountPaid.toStringAsFixed(2),
            style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary))),
        DataCell(Text(txn.paymentMode)),
        DataCell(Text(txn.collectedBy)),
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
