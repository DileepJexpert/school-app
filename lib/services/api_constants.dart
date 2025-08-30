// lib/services/api_constants.dart

class ApiConstants {
  /// The base URL for your deployed Spring Boot backend.
  /// For local development with an Android emulator, use 'http://10.0.2.2:8080'.
  /// For a physical device, use your computer's local network IP.
  /// For a deployed backend, use its public URL.
  static const String baseUrl = "http://localhost:8080/api";

  // --- Endpoints for Fee Collection & Student Profiles ---
  static const String studentProfileEndpoint = '/student-fee-profiles'; // e.g., /student-fee-profiles/{id}
  static const String searchStudentsEndpoint = '/fees/search';
  static const String collectFeeEndpoint = '/fees/collect';

  // --- NEW: Endpoint for Fee Structure Setup ---
  /// This is the endpoint for creating and fetching the master fee structures.
  /// It is used by the FeeSetupPage.
  static const String feeStructuresEndpoint = '/feestructures';

  // --- NEW: Endpoint for Reports ---
  /// This is the endpoint for the fee collection summary report.
  static const String feeCollectionReportEndpoint = '/fees/reports/collection-summary';
}
