import 'package:account/databases/transaction_db.dart';
import 'package:flutter/foundation.dart';
import 'package:account/models/transactions.dart';

class TransactionProvider with ChangeNotifier {
  List<Transactions> transactions = [];

  List<Transactions> getTransaction() {
    return transactions;
  }

  /// Initializes the data from the database.
  Future<void> initData() async {
    try {
      var db = TransactionDB(dbName: 'transactions.db');
      transactions = await db.loadAllData();
      notifyListeners();  // Notify listeners when data is loaded
    } catch (e) {
      print('Error loading data: $e');
      // Consider providing user feedback here
    }
  }

  /// Adds a transaction to the database.
  Future<void> addTransaction(Transactions transaction) async {
    try {
      var db = TransactionDB(dbName: 'transactions.db');
      await db.insertDatabase(transaction);
      transactions.add(transaction);  // Add the new transaction directly
      notifyListeners();
    } catch (e) {
      print('Error adding transaction: $e');
    }
  }

  /// Deletes a transaction from the database.
Future<void> deleteTransaction(int? keyID) async {
  try {
    var db = TransactionDB(dbName: 'transactions.db');
    await db.deleteDatabase(keyID);  // ควรตรงกับประเภท int? ตอนนี้
    transactions.removeWhere((transaction) => transaction.keyID == keyID);
    notifyListeners();
  } catch (e) {
    print('Error deleting transaction: $e');
  }
}


  /// Updates an existing transaction in the database.
  Future<void> updateTransaction(Transactions transaction) async {
    try {
      var db = TransactionDB(dbName: 'transactions.db');
      await db.updateDatabase(transaction);
      // Optionally find and update the local list instead of reloading
      int index = transactions.indexWhere((t) => t.keyID == transaction.keyID);
      if (index != -1) {
        transactions[index] = transaction; // Update the local list
      }
      notifyListeners();
    } catch (e) {
      print('Error updating transaction: $e');
    }
  }
}
