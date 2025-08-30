part of 'fee_reports_page.dart';

import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../../models/fee_report_models.dart';
import 'fee_reports_page.dart';

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
      end: DateTime(now.year, now.month + 1, 0, 23, 59, 59),
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
      initialDateRange: _selectedDateRange,
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

  Future<void> _fetchReportData() async {
    if (_selectedDateRange == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a date range."), backgroundColor: Colors.orangeAccent),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      const baseUrl = "http://localhost:8080/api/reports/fees/report-summary";
      final queryParams = {
        "startDate": DateFormat("yyyy-MM-dd").format(_selectedDateRange!.start),
        "endDate": DateFormat("yyyy-MM-dd").format(_selectedDateRange!.end),
        if (_selectedClassFilter != null && _selectedClassFilter != "All Classes")
          "className": _selectedClassFilter!,
        if (_selectedPaymentModeFilter != null && _selectedPaymentModeFilter != "All Modes")
          "paymentMode": _selectedPaymentModeFilter!,
        if (_searchQueryController.text.isNotEmpty)
          "search": _searchQueryController.text,
        "page": "0",
        "size": "50",
      };

      final uri = Uri.parse(baseUrl).replace(queryParameters: queryParams);
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final report = FeeReportResponse.fromJson(data);

        setState(() {
          _reportSummary = FeeReportSummary(
            totalCollected: report.summary.totalCollected,
            totalDue: report.summary.totalDue,
            totalDiscountGiven: report.summary.totalDiscountGiven,
            totalTransactions: report.summary.totalTransactions,
          );

          _transactions = report.transactionsPage.content.map((txn) {
            return FeeTransactionItem(
              id: txn.id,
              paymentDate: DateTime.parse(txn.paymentDate),
              receiptNumber: txn.receiptNumber,
              studentName: txn.studentName,
              className: txn.className ?? "N/A",
              rollNumber: txn.rollNumber ?? "-",
              paidForMonths: txn.paidForMonths,
              grossAmount: txn.amountPaid + txn.discount,
              discount: txn.discount,
              netAmountPaid: txn.amountPaid,
              paymentMode: txn.paymentMode,
              collectedBy: txn.collectedBy,
            );
          }).toList();

          _collectionByClassData = {
            for (var c in report.classSummaries)
              c.classForAdmission ?? "Unknown": c.totalCollectedInClass
          };

          _collectionByPaymentModeData = {
            for (var pm in report.paymentModeSummary)
              pm.paymentMode: pm.totalAmount
          };
        });
      } else {
        setState(() {
          _errorMessage = "Failed to load report. Status: ${response.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Error fetching report: $e";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Center(
        child: Text("TODO: Build UI with widgets"),
      ),
    );
  }
}
