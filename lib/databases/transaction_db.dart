import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';
import 'package:account/models/transactions.dart';

class TransactionDB {
  String dbName;

  TransactionDB({required this.dbName});

  // Open the database
  Future<Database> openDatabase() async {
    Directory appDirectory = await getApplicationDocumentsDirectory();
    String dbLocation = join(appDirectory.path, dbName);

    DatabaseFactory dbFactory = databaseFactoryIo;
    Database db = await dbFactory.openDatabase(dbLocation);
    return db;
  }

  // Insert a new transaction into the database
 Future<int> insertDatabase(Transactions statement) async {
  var db = await openDatabase();
  var store = intMapStoreFactory.store('expense');
  try {
    var keyID = await store.add(db, {
      "title": statement.title,
      "amount": statement.amount,
      "date": statement.date.toIso8601String(),
      "contact": statement.contact,
      "description": statement.description,
      "field": statement.field,
      "image": statement.image,
    });
    return keyID;
  } catch (e) {
    print('Error inserting transaction: $e');
    return -1; // หรือจัดการข้อผิดพลาดตามที่จำเป็น
  } finally {
    await db.close();
  }
}


  // Load all transactions from the database
  Future<List<Transactions>> loadAllData() async {
    var db = await openDatabase();
    var store = intMapStoreFactory.store('expense');
    var snapshot = await store.find(
      db,
      finder: Finder(sortOrders: [SortOrder(Field.key, false)]),
    );
    List<Transactions> transactions = [];
    for (var record in snapshot) {
      transactions.add(Transactions(
        keyID: record.key,
        title: record['title'].toString(),
        amount: double.parse(record['amount'].toString()),
        date: DateTime.parse(record['date'].toString()),
        contact: record['contact'].toString(),        // New field for contact
        description: record['description'].toString(), // New field for description
        field: record['field'].toString(),            // New field for scientific field
        image: record['image']?.toString(),           // Optional image field
      ));
    }
    db.close();
    return transactions;
  }

  // Delete a transaction from the database
  Future<void> deleteDatabase(int? index) async {
    var db = await openDatabase();
    var store = intMapStoreFactory.store('expense');
    await store.delete(db, finder: Finder(filter: Filter.equals(Field.key, index)));
    db.close();
  }

  // Update an existing transaction in the database
  Future<void> updateDatabase(Transactions statement) async {
    var db = await openDatabase();
    var store = intMapStoreFactory.store('expense');
    var filter = Finder(filter: Filter.equals(Field.key, statement.keyID));

    var result = await store.update(
      db,
      {
        "title": statement.title,
        "amount": statement.amount,
        "date": statement.date.toIso8601String(),
        "contact": statement.contact,        // New field for contact
        "description": statement.description, // New field for description
        "field": statement.field,            // New field for scientific field
        "image": statement.image,            // Optional image field
      },
      finder: filter,
    );
    db.close();
    print('Update result: $result');
  }
}
