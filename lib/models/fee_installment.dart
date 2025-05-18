// lib/models/fee_installment.dart
import 'package:json_annotation/json_annotation.dart';

part 'fee_installment.g.dart';

@JsonSerializable()
class FeeInstallment {
  final String monthYear;
  final double tuitionFee;
  final double transportFee;
  final double otherCharges;
  final double lateFineApplied;
  final bool isPaid;
  final double totalMonthlyFeeWithFine;
  final double totalMonthlyFeeOriginal;

  FeeInstallment({
    required this.monthYear,
    required this.tuitionFee,
    required this.transportFee,
    required this.otherCharges,
    required this.lateFineApplied,
    required this.isPaid,
    required this.totalMonthlyFeeWithFine,
    required this.totalMonthlyFeeOriginal,
  });

  factory FeeInstallment.fromJson(Map<String, dynamic> json) => _$FeeInstallmentFromJson(json);
  Map<String, dynamic> toJson() => _$FeeInstallmentToJson(this);
}
