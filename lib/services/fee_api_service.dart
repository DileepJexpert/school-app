import 'package:dio/dio.dart';
import 'dart:convert';

import '../models/student_fee_profile.dart';
import '../models/fee_payment_request.dart';
import '../models/payment_record.dart';
import 'api_constants.dart';
import 'api_exception.dart';

class FeeApiService {
  final Dio _dio;
  final JsonEncoder _encoder = const JsonEncoder.withIndent('  ');

  FeeApiService({Dio? dio})
      : _dio = dio ?? Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));

  // ... (getStudentFeeProfileById and collectFee methods remain the same)
  Future<StudentFeeProfile> getStudentFeeProfileById(String studentId) async {
    print("--- [FeeApiService] getStudentFeeProfileById ---");
    print("Called with studentId: '$studentId'");
    if (studentId.isEmpty) {
      throw ApiException(message: "Student ID cannot be empty.");
    }
    final String endpoint = '${ApiConstants.studentProfileEndpoint}/$studentId';
    print("Making GET request to: ${_dio.options.baseUrl}$endpoint");
    try {
      final response = await _dio.get(endpoint);
      print("Response received with statusCode: ${response.statusCode}");
      print("Response data:\n${_encoder.convert(response.data)}");
      if (response.statusCode == 200 && response.data != null) {
        return StudentFeeProfile.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw ApiException(message: 'Failed to load student profile', statusCode: response.statusCode);
      }
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<PaymentRecord> collectFee(FeePaymentRequest paymentRequest) async {
    print("--- [FeeApiService] collectFee ---");
    final String endpoint = ApiConstants.collectFeeEndpoint;
    print("Making POST request to: ${_dio.options.baseUrl}$endpoint");
    print("Request payload:\n${_encoder.convert(paymentRequest.toJson())}");
    try {
      final response = await _dio.post(endpoint, data: paymentRequest.toJson());
      print("Response received with statusCode: ${response.statusCode}");
      print("Response data:\n${_encoder.convert(response.data)}");
      if (response.statusCode == 201 && response.data != null) {
        return PaymentRecord.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw ApiException(message: 'Fee collection failed', statusCode: response.statusCode);
      }
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /**
   * --- MODIFIED SEARCH METHOD ---
   * This now makes a GET request with query parameters, which is more standard
   * and aligns with the updated backend controller.
   */
  Future<List<StudentFeeProfile>> searchStudents({String? name, String? className, String? rollNumber}) async {
    print("--- [FeeApiService] searchStudents ---");
    print("Called with name: $name, class: $className, roll: $rollNumber");

    final Map<String, dynamic> queryParameters = {
      if (name != null && name.isNotEmpty) 'name': name,
      if (className != null && className.isNotEmpty) 'className': className,
      if (rollNumber != null && rollNumber.isNotEmpty) 'rollNumber': rollNumber,
    };

    final String endpoint = ApiConstants.searchStudentsEndpoint;
    print("Making GET request to: ${_dio.options.baseUrl}$endpoint");
    print("Query Parameters:\n$queryParameters");

    try {
      final response = await _dio.get(endpoint, queryParameters: queryParameters);
      print("Response received with statusCode: ${response.statusCode}");
      print("Response data:\n${_encoder.convert(response.data)}");

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> studentList = response.data;
        return studentList.map((json) => StudentFeeProfile.fromJson(json)).toList();
      } else {
        throw ApiException(message: 'Student search failed', statusCode: response.statusCode);
      }
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  // ... (getFeeStructureForYear and saveFeeStructure methods remain the same)
  Future<List<Map<String, dynamic>>> getFeeStructureForYear(String academicYear) async {
    print("--- [FeeApiService] getFeeStructureForYear ---");
    final String endpoint = ApiConstants.feeStructuresEndpoint;
    print("Making GET request to: ${_dio.options.baseUrl}$endpoint with query: year=$academicYear");
    try {
      final response = await _dio.get(endpoint, queryParameters: {'year': academicYear});
      print("Response received with statusCode: ${response.statusCode}");
      print("Response data:\n${_encoder.convert(response.data)}");
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data;
        return data.cast<Map<String, dynamic>>();
      } else {
        throw ApiException(message: 'Failed to load fee structure', statusCode: response.statusCode);
      }
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<void> saveFeeStructure(List<Map<String, dynamic>> payload) async {
    print("--- [FeeApiService] saveFeeStructure ---");
    final String endpoint = ApiConstants.feeStructuresEndpoint;
    print("Making POST request to: ${_dio.options.baseUrl}$endpoint");
    print("Request payload:\n${_encoder.convert(payload)}");
    try {
      final response = await _dio.post(endpoint, data: payload);
      print("Response received with statusCode: ${response.statusCode}");
      if (response.statusCode != 201) {
        throw ApiException(message: 'Failed to save fee structure', statusCode: response.statusCode);
      }
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}
