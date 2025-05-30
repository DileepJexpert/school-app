// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_record.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaymentRecord _$PaymentRecordFromJson(Map<String, dynamic> json) =>
    PaymentRecord(
      receiptNumber: json['receiptNumber'] as String,
      paymentDate:
          PaymentRecord._dateTimeFromJson(json['paymentDate'] as String),
      amountPaid: (json['amountPaid'] as num).toDouble(),
      paymentMode: json['paymentMode'] as String,
      paidForMonths: (json['paidForMonths'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      remarks: json['remarks'] as String?,
      chequeDetails: json['chequeDetails'] as String?,
      transactionId: json['transactionId'] as String?,
    );

Map<String, dynamic> _$PaymentRecordToJson(PaymentRecord instance) =>
    <String, dynamic>{
      'receiptNumber': instance.receiptNumber,
      'paymentDate': PaymentRecord._dateTimeToJson(instance.paymentDate),
      'amountPaid': instance.amountPaid,
      'paymentMode': instance.paymentMode,
      'paidForMonths': instance.paidForMonths,
      'remarks': instance.remarks,
      'chequeDetails': instance.chequeDetails,
      'transactionId': instance.transactionId,
    };
