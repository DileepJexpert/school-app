// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fee_payment_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FeePaymentRequest _$FeePaymentRequestFromJson(Map<String, dynamic> json) =>
    FeePaymentRequest(
      studentId: json['studentId'] as String,
      selectedMonthsToPay: (json['selectedMonthsToPay'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      paymentDate: DateTime.parse(json['paymentDate'] as String),
      paymentMode: json['paymentMode'] as String,
      discountAmount: (json['discountAmount'] as num).toDouble(),
      remarks: json['remarks'] as String?,
      chequeDetails: json['chequeDetails'] as String?,
      transactionId: json['transactionId'] as String?,
      netAmountPaid: (json['netAmountPaid'] as num).toDouble(),
    );

Map<String, dynamic> _$FeePaymentRequestToJson(FeePaymentRequest instance) =>
    <String, dynamic>{
      'studentId': instance.studentId,
      'selectedMonthsToPay': instance.selectedMonthsToPay,
      'paymentDate': FeePaymentRequest._dateToJson(instance.paymentDate),
      'paymentMode': instance.paymentMode,
      'discountAmount': instance.discountAmount,
      'remarks': instance.remarks,
      'chequeDetails': instance.chequeDetails,
      'transactionId': instance.transactionId,
      'netAmountPaid': instance.netAmountPaid,
    };
