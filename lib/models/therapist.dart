class Therapist {
  final String name;
  final String specialization;
  final String address; // Simple address for now
  final String contact; // e.g., phone number or website
  final double latitude; // For map integration later
  final double longitude; // For map integration later

  Therapist({
    required this.name,
    required this.specialization,
    required this.address,
    required this.contact,
    required this.latitude,
    required this.longitude,
  });
}
