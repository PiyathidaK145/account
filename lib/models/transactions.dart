
class Transactions {
  final int? keyID;           // Unique identifier for the transaction
  final String title;         // Title of the transaction
  final double amount;        // Amount of the transaction (changed to double for consistency)
  final DateTime date;        // Date of the transaction
  final String contact;       // New field for contact information
  final String description;   // New field for description
  final String field;         // New field for scientific field
  final String? image;        // Optional image path

  Transactions({
     required this.keyID,
    required this.title,
    required this.amount,
    required this.date,
    required this.contact,
    required this.description,
    required this.field,
    this.image,
  });

  // Optional: Add a method to convert to a Map for database operations
  Map<String, dynamic> toMap() {
    return {
      'keyID': keyID,
      'title': title,
      'amount': amount,
      'date': date.toIso8601String(), // Convert DateTime to String
      'contact': contact,
      'description': description,
      'field': field,
      'image': image,
    };
  }

  // Optional: Add a factory method to create a Transactions object from a Map
  factory Transactions.fromMap(Map<String, dynamic> map) {
    return Transactions(
      keyID: map['keyID'],
      title: map['title'],
      amount: map['amount'],
      date: DateTime.parse(map['date']),
      contact: map['contact'],
      description: map['description'],
      field: map['field'],
      image: map['image'],
    );
  }
}
