// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fee_installment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FeeInstallment _$FeeInstallmentFromJson(Map<String, dynamic> json) =>
    FeeInstallment(
      monthYear: json['monthYear'] as String,
      tuitionFee: (json['tuitionFee'] as num).toDouble(),
      transportFee: (json['transportFee'] as num).toDouble(),
      otherCharges: (json['otherCharges'] as num).toDouble(),
      lateFineApplied: (json['lateFineApplied'] as num).toDouble(),
      isPaid: json['isPaid'] as bool,
      totalMonthlyFeeWithFine:
          (json['totalMonthlyFeeWithFine'] as num).toDouble(),
      totalMonthlyFeeOriginal:
          (json['totalMonthlyFeeOriginal'] as num).toDouble(),
    );

Map<String, dynamic> _$FeeInstallmentToJson(FeeInstallment instance) =>
    <String, dynamic>{
      'monthYear': instance.monthYear,
      'tuitionFee': instance.tuitionFee,
      'transportFee': instance.transportFee,
      'otherCharges': instance.otherCharges,
      'lateFineApplied': instance.lateFineApplied,
      'isPaid': instance.isPaid,
      'totalMonthlyFeeWithFine': instance.totalMonthlyFeeWithFine,
      'totalMonthlyFeeOriginal': instance.totalMonthlyFeeOriginal,
    };
