import 'package:json_annotation/json_annotation.dart';

part 'fee_installment.g.dart';

/// Helper function to safely convert a 'num' (which can be int or double in JSON)
/// to a 'double' in Dart. Returns 0.0 if the value is null.
double _doubleFromNum(num? value) => value?.toDouble() ?? 0.0;

/// This model maps a single fee installment from the backend's JSON response.
@JsonSerializable()
class FeeInstallment {
  /// The descriptive name of the fee, e.g., "Tuition Fee - JULY" or "Annual Fee".
  final String installmentName;

  /// The amount due for this specific installment.
  @JsonKey(fromJson: _doubleFromNum)
  final double amountDue;

  /// The payment status, e.g., "PENDING", "PAID".
  final String status;

  /// A UI-only property to track if the user has selected this installment for payment.
  /// It is not part of the JSON response and is initialized to false.
  @JsonKey(includeFromJson: false, includeToJson: false)
  bool isSelectedForPayment;

  FeeInstallment({
    required this.installmentName,
    required this.amountDue,
    required this.status,
    this.isSelectedForPayment = false,
  });

  /// Factory constructor to create a FeeInstallment from a JSON map.
  factory FeeInstallment.fromJson(Map<String, dynamic> json) => _$FeeInstallmentFromJson(json);

  /// Method to convert a FeeInstallment instance to a JSON map.
  Map<String, dynamic> toJson() => _$FeeInstallmentToJson(this);
}
