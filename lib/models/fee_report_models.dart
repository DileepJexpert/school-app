import 'dart:convert';

class FeeReportResponse {
  final Summary summary;
  final List<ClassWiseFeeSummary> classSummaries;
  final List<PaymentModeSummary> paymentModeSummary;
  final TransactionsPage transactionsPage;
  final Filters filters;

  FeeReportResponse({
    required this.summary,
    required this.classSummaries,
    required this.paymentModeSummary,
    required this.transactionsPage,
    required this.filters,
  });

  factory FeeReportResponse.fromJson(Map<String, dynamic> json) {
    return FeeReportResponse(
      summary: Summary.fromJson(json['summary']),
      classSummaries: (json['classSummaries'] as List)
          .map((e) => ClassWiseFeeSummary.fromJson(e))
          .toList(),
      paymentModeSummary: (json['paymentModeSummary'] as List)
          .map((e) => PaymentModeSummary.fromJson(e))
          .toList(),
      transactionsPage: TransactionsPage.fromJson(json['transactionsPage']),
      filters: Filters.fromJson(json['filters']),
    );
  }
}

class Summary {
  final double totalCollected;
  final double totalDue;
  final double totalDiscountGiven;
  final int totalTransactions;

  Summary({
    required this.totalCollected,
    required this.totalDue,
    required this.totalDiscountGiven,
    required this.totalTransactions,
  });

  factory Summary.fromJson(Map<String, dynamic> json) {
    return Summary(
      totalCollected: (json['totalCollected'] ?? 0).toDouble(),
      totalDue: (json['totalDue'] ?? 0).toDouble(),
      totalDiscountGiven: (json['totalDiscountGiven'] ?? 0).toDouble(),
      totalTransactions: json['totalTransactions'] ?? 0,
    );
  }
}

class ClassWiseFeeSummary {
  final String? classForAdmission;
  final double totalCollectedInClass;
  final double totalDiscountInClass;
  final int transactionCountInClass;
  final List<PaymentModeBreakdown> paymentModeBreakdown;

  ClassWiseFeeSummary({
    required this.classForAdmission,
    required this.totalCollectedInClass,
    required this.totalDiscountInClass,
    required this.transactionCountInClass,
    required this.paymentModeBreakdown,
  });

  factory ClassWiseFeeSummary.fromJson(Map<String, dynamic> json) {
    return ClassWiseFeeSummary(
      classForAdmission: json['classForAdmission'],
      totalCollectedInClass: (json['totalCollectedInClass'] ?? 0).toDouble(),
      totalDiscountInClass: (json['totalDiscountInClass'] ?? 0).toDouble(),
      transactionCountInClass: json['transactionCountInClass'] ?? 0,
      paymentModeBreakdown: (json['paymentModeBreakdown'] as List)
          .map((e) => PaymentModeBreakdown.fromJson(e))
          .toList(),
    );
  }
}

class PaymentModeBreakdown {
  final String paymentMode;
  final double totalAmount;
  final double totalDiscount;
  final int transactionCount;

  PaymentModeBreakdown({
    required this.paymentMode,
    required this.totalAmount,
    required this.totalDiscount,
    required this.transactionCount,
  });

  factory PaymentModeBreakdown.fromJson(Map<String, dynamic> json) {
    return PaymentModeBreakdown(
      paymentMode: json['paymentMode'],
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      totalDiscount: (json['totalDiscount'] ?? 0).toDouble(),
      transactionCount: json['transactionCount'] ?? 0,
    );
  }
}

class PaymentModeSummary {
  final String paymentMode;
  final double totalAmount;

  PaymentModeSummary({required this.paymentMode, required this.totalAmount});

  factory PaymentModeSummary.fromJson(Map<String, dynamic> json) {
    return PaymentModeSummary(
      paymentMode: json['paymentMode'],
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
    );
  }
}

class TransactionsPage {
  final List<TransactionResponse> content;
  final int totalElements;
  final int totalPages;

  TransactionsPage({
    required this.content,
    required this.totalElements,
    required this.totalPages,
  });

  factory TransactionsPage.fromJson(Map<String, dynamic> json) {
    return TransactionsPage(
      content: (json['content'] as List)
          .map((e) => TransactionResponse.fromJson(e))
          .toList(),
      totalElements: json['totalElements'] ?? 0,
      totalPages: json['totalPages'] ?? 0,
    );
  }
}

class TransactionResponse {
  final String id;
  final String studentId;
  final String studentName;
  final String receiptNumber;
  final String paymentDate;
  final double amountPaid;
  final double discount;
  final String paymentMode;
  final List<String> paidForMonths;
  final String? remarks;
  final String? className;
  final String? rollNumber;
  final String collectedBy;

  TransactionResponse({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.receiptNumber,
    required this.paymentDate,
    required this.amountPaid,
    required this.discount,
    required this.paymentMode,
    required this.paidForMonths,
    this.remarks,
    this.className,
    this.rollNumber,
    required this.collectedBy,
  });

  factory TransactionResponse.fromJson(Map<String, dynamic> json) {
    return TransactionResponse(
      id: json['id'],
      studentId: json['studentId'],
      studentName: json['studentName'],
      receiptNumber: json['receiptNumber'],
      paymentDate: json['paymentDate'],
      amountPaid: (json['amountPaid'] ?? 0).toDouble(),
      discount: (json['discount'] ?? 0).toDouble(),
      paymentMode: json['paymentMode'],
      paidForMonths: List<String>.from(json['paidForMonths']),
      remarks: json['remarks'],
      className: json['className'],
      rollNumber: json['rollNumber'],
      collectedBy: json['collectedBy'],
    );
  }
}

class Filters {
  final List<String> classes;
  final List<String> paymentModes;

  Filters({required this.classes, required this.paymentModes});

  factory Filters.fromJson(Map<String, dynamic> json) {
    return Filters(
      classes: List<String>.from(json['classes']),
      paymentModes: List<String>.from(json['paymentModes']),
    );
  }
}
