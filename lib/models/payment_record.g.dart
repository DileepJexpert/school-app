// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_record.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaymentRecord _$PaymentRecordFromJson(Map<String, dynamic> json) =>
    PaymentRecord(
      id: json['transactionId'] as String,
      receiptNumber: json['receiptNumber'] as String,
      studentId: json['studentId'] as String,
      studentName: json['studentName'] as String,
      paymentDate: _dateFromJson(json['paymentDate'] as String),
      amountPaid: _doubleFromNum(json['amountPaid'] as num?),
      discount: json['discount'] == null
          ? 0.0
          : _doubleFromNum(json['discount'] as num?),
      paymentMode: json['paymentMode'] as String,
      paidForInstallments: (json['paidForInstallments'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      remarks: json['remarks'] as String?,
    );

Map<String, dynamic> _$PaymentRecordToJson(PaymentRecord instance) =>
    <String, dynamic>{
      'transactionId': instance.id,
      'receiptNumber': instance.receiptNumber,
      'studentId': instance.studentId,
      'studentName': instance.studentName,
      'paymentDate': instance.paymentDate.toIso8601String(),
      'amountPaid': instance.amountPaid,
      'discount': instance.discount,
      'paymentMode': instance.paymentMode,
      'paidForInstallments': instance.paidForInstallments,
      'remarks': instance.remarks,
    };
