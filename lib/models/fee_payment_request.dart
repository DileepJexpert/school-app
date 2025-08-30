import 'package:json_annotation/json_annotation.dart';

part 'fee_payment_request.g.dart';

/// This model represents the JSON payload sent to the backend when collecting a fee.
@JsonSerializable()
class FeePaymentRequest {
  final String studentId;
  final double amount;
  final double discount; // Added discount field

  /// --- FIX: Renamed from 'months' to 'installmentNames' ---
  /// This now correctly matches the backend service and can hold any fee type.
  final List<String> installmentNames;

  final String paymentMode;
  final String? remarks;
  final String? chequeDetails;
  final String? transactionId;

  FeePaymentRequest({
    required this.studentId,
    required this.amount,
    required this.discount,
    required this.installmentNames,
    required this.paymentMode,
    this.remarks,
    this.chequeDetails,
    this.transactionId,
  });

  factory FeePaymentRequest.fromJson(Map<String, dynamic> json) => _$FeePaymentRequestFromJson(json);
  Map<String, dynamic> toJson() => _$FeePaymentRequestToJson(this);
}
