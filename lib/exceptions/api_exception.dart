import 'package:dio/dio.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic errorData;

  ApiException({
    required this.message,
    this.statusCode,
    this.errorData,
  });

  // Factory constructor to create an ApiException from a DioException
  factory ApiException.fromDioError(DioException dioError) {
    String errorMessage = "An unknown error occurred.";
    int? statusCode = dioError.response?.statusCode;
    dynamic errorData = dioError.response?.data;

    switch (dioError.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        errorMessage = "Connection timeout. Please check your internet connection.";
        break;
      case DioExceptionType.badResponse:
      // Try to parse a meaningful error message from the response body
        if (errorData is Map<String, dynamic> && errorData['message'] != null) {
          errorMessage = errorData['message'];
        } else {
          errorMessage = "Received invalid status code: $statusCode";
        }
        break;
      case DioExceptionType.cancel:
        errorMessage = "Request to the server was cancelled.";
        break;
      case DioExceptionType.connectionError:
        errorMessage = "Connection error. Please check your network.";
        break;
      case DioExceptionType.unknown:
      default:
        errorMessage = "An unexpected error occurred. Please try again.";
        break;
    }

    return ApiException(
      message: errorMessage,
      statusCode: statusCode,
      errorData: errorData,
    );
  }

  @override
  String toString() {
    return 'ApiException: $message (StatusCode: $statusCode)';
  }
}
