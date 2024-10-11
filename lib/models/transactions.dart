class Transactions {
  int? keyID;
  final String title;
  final double amount;
  final DateTime date;
  final String? contact; // Add contact field here
  final String? description; // Add description field here
  final String? field; // Add field (scientific field) here
  final String? image; // Add image path here

  Transactions({
    this.keyID,
    required this.title,
    required this.amount,
    required this.date,
    this.contact, // Include contact in constructor
    this.description, // Include description in constructor
    this.field, // Include field in constructor
    this.image, // Include image in constructor
  });
}