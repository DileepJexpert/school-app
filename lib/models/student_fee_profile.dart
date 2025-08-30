import 'package:json_annotation/json_annotation.dart';
import 'fee_installment.dart';
import 'payment_record.dart';

part 'student_fee_profile.g.dart';



@JsonSerializable(explicitToJson: true)
class StudentFeeProfile {
  @JsonKey(defaultValue: '')
  final String id;

  @JsonKey(defaultValue: '')
  final String name;

  @JsonKey(defaultValue: '')
  final String className;

  @JsonKey(defaultValue: '')
  final String rollNumber;

  @JsonKey(defaultValue: '')
  final String parentName;

  // Corrected: Renamed to 'feeInstallments' to match your page code
  @JsonKey(defaultValue: [])
  final List<FeeInstallment> feeInstallments;

  final PaymentRecord? lastPayment;

  // Corrected: Added fields to match your page code
  @JsonKey(defaultValue: 0.0)
  final double totalFees;

  @JsonKey(defaultValue: 0.0)
  final double paidFees;

  @JsonKey(defaultValue: 0.0)
  final double dueFees;

  @JsonKey(defaultValue: 0.0)
  final double totalDiscountGiven;

  StudentFeeProfile({
    required this.id,
    required this.name,
    required this.className,
    required this.rollNumber,
    required this.parentName,
    required this.feeInstallments,
    this.lastPayment,
    required this.totalFees,
    required this.paidFees,
    required this.dueFees,
    required this.totalDiscountGiven,
  });

  factory StudentFeeProfile.fromJson(Map<String, dynamic> json) => _$StudentFeeProfileFromJson(json);
  Map<String, dynamic> toJson() => _$StudentFeeProfileToJson(this);
}
