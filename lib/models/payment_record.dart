// lib/models/payment_record.dart
import 'package:json_annotation/json_annotation.dart';

part 'payment_record.g.dart';

@JsonSerializable()
class PaymentRecord {
  final String receiptNumber;
  @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson) // Custom converter for DateTime
  final DateTime paymentDate;
  final double amountPaid;
  final String paymentMode;
  final List<String> paidForMonths;
  final String? remarks; // Nullable if optional
  final String? chequeDetails; // Nullable
  final String? transactionId; // Nullable

  PaymentRecord({
    required this.receiptNumber,
    required this.paymentDate,
    required this.amountPaid,
    required this.paymentMode,
    required this.paidForMonths,
    this.remarks,
    this.chequeDetails,
    this.transactionId,
  });

  factory PaymentRecord.fromJson(Map<String, dynamic> json) => _$PaymentRecordFromJson(json);
  Map<String, dynamic> toJson() => _$PaymentRecordToJson(this);

  // Helper functions for DateTime serialization (ISO 8601 string for dates)
  static DateTime _dateTimeFromJson(String dateString) => DateTime.parse(dateString);
  static String _dateTimeToJson(DateTime date) => date.toIso8601String().substring(0,10); // Send only YYYY-MM-DD
}
