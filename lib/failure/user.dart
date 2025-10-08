class VerificationResult {
  final bool verified;
  final String message;
  final double score;

  VerificationResult({
    required this.verified,
    required this.message,
    required this.score,
  });
}

class UserResult {
  final String uid;
  final String name;
  final String phone;
  final DateTime dob;
  final String drivingLicenseUrl;
  final bool isVerified;

  UserResult({
    required this.uid,
    required this.name,
    required this.phone,
    required this.dob,
    required this.drivingLicenseUrl,
    this.isVerified = false,
  });
}
