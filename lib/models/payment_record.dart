import 'package:json_annotation/json_annotation.dart';

part 'payment_record.g.dart';

/// Helper function to safely convert a 'num' (which can be int or double in JSON)
/// to a 'double' in Dart. Returns 0.0 if the value is null.
double _doubleFromNum(num? value) => value?.toDouble() ?? 0.0;

/// Helper function to parse date strings from JSON into DateTime objects.
DateTime _dateFromJson(String date) => DateTime.parse(date);

/// This model maps the JSON response for a single payment transaction.
@JsonSerializable()
class PaymentRecord {
  /// The unique ID of the transaction.
  @JsonKey(name: 'transactionId')
  final String id;

  final String receiptNumber;
  final String studentId;
  final String studentName;

  @JsonKey(fromJson: _dateFromJson)
  final DateTime paymentDate;

  @JsonKey(fromJson: _doubleFromNum)
  final double amountPaid;

  /// --- NEW: Added discount field ---
  @JsonKey(fromJson: _doubleFromNum, defaultValue: 0.0)
  final double discount;

  final String paymentMode;

  /// --- FIX: Renamed from 'paidForMonths' to 'paidForInstallments' ---
  @JsonKey(defaultValue: [])
  final List<String> paidForInstallments;

  final String? remarks;

  PaymentRecord({
    required this.id,
    required this.receiptNumber,
    required this.studentId,
    required this.studentName,
    required this.paymentDate,
    required this.amountPaid,
    required this.discount,
    required this.paymentMode,
    required this.paidForInstallments,
    this.remarks,
  });

  factory PaymentRecord.fromJson(Map<String, dynamic> json) => _$PaymentRecordFromJson(json);
  Map<String, dynamic> toJson() => _$PaymentRecordToJson(this);
}
