// lib/models/fee_payment_request.dart
import 'package:json_annotation/json_annotation.dart';
import 'package:intl/intl.dart'; // For formatting date to YYYY-MM-DD

part 'fee_payment_request.g.dart';

@JsonSerializable()
class FeePaymentRequest {
  final String studentId;
  final List<String> selectedMonthsToPay;

  @JsonKey(toJson: _dateToJson) // Custom toJson for date
  final DateTime paymentDate;
  final String paymentMode;
  final double discountAmount;
  final String? remarks; // Nullable
  final String? chequeDetails; // Nullable
  final String? transactionId; // Nullable
  final double netAmountPaid;

  FeePaymentRequest({
    required this.studentId,
    required this.selectedMonthsToPay,
    required this.paymentDate,
    required this.paymentMode,
    required this.discountAmount,
    this.remarks,
    this.chequeDetails,
    this.transactionId,
    required this.netAmountPaid,
  });

  factory FeePaymentRequest.fromJson(Map<String, dynamic> json) => _$FeePaymentRequestFromJson(json);
  Map<String, dynamic> toJson() => _$FeePaymentRequestToJson(this);

  // Helper to format DateTime to 'YYYY-MM-DD' string for JSON
  static String _dateToJson(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }
}
