// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'student_fee_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StudentFeeProfile _$StudentFeeProfileFromJson(Map<String, dynamic> json) =>
    StudentFeeProfile(
      id: json['id'] as String,
      name: json['name'] as String,
      className: json['className'] as String,
      rollNumber: json['rollNumber'] as String,
      parentName: json['parentName'] as String,
      monthlyFees: (json['monthlyFees'] as List<dynamic>)
          .map((e) => FeeInstallment.fromJson(e as Map<String, dynamic>))
          .toList(),
      lastPayment: json['lastPayment'] == null
          ? null
          : PaymentRecord.fromJson(json['lastPayment'] as Map<String, dynamic>),
      totalAnnualFeeEstimate:
          (json['totalAnnualFeeEstimate'] as num).toDouble(),
      totalPaidInSession: (json['totalPaidInSession'] as num).toDouble(),
      currentSessionOutstanding:
          (json['currentSessionOutstanding'] as num).toDouble(),
      nextDueDate: json['nextDueDate'] as String,
    );

Map<String, dynamic> _$StudentFeeProfileToJson(StudentFeeProfile instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'className': instance.className,
      'rollNumber': instance.rollNumber,
      'parentName': instance.parentName,
      'monthlyFees': instance.monthlyFees.map((e) => e.toJson()).toList(),
      'lastPayment': instance.lastPayment?.toJson(),
      'totalAnnualFeeEstimate': instance.totalAnnualFeeEstimate,
      'totalPaidInSession': instance.totalPaidInSession,
      'currentSessionOutstanding': instance.currentSessionOutstanding,
      'nextDueDate': instance.nextDueDate,
    };
