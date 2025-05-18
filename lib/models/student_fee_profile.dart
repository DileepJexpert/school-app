// lib/models/student_fee_profile.dart
import 'package:json_annotation/json_annotation.dart';
import 'fee_installment.dart';
import 'payment_record.dart';

part 'student_fee_profile.g.dart';

@JsonSerializable(explicitToJson: true)
class StudentFeeProfile {
  final String id;
  final String name;
  final String className;
  final String rollNumber;
  final String parentName;
  final List<FeeInstallment> monthlyFees;
  final PaymentRecord? lastPayment; // Nullable

  final double totalAnnualFeeEstimate;
  final double totalPaidInSession;
  final double currentSessionOutstanding;
  final String nextDueDate;

  StudentFeeProfile({
    required this.id,
    required this.name,
    required this.className,
    required this.rollNumber,
    required this.parentName,
    required this.monthlyFees,
    this.lastPayment,
    required this.totalAnnualFeeEstimate,
    required this.totalPaidInSession,
    required this.currentSessionOutstanding,
    required this.nextDueDate,
  });

  factory StudentFeeProfile.fromJson(Map<String, dynamic> json) => _$StudentFeeProfileFromJson(json);
  Map<String, dynamic> toJson() => _$StudentFeeProfileToJson(this);
}
