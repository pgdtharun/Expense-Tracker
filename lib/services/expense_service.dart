import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/expense.dart';

/// All Firestore reads/writes for expenses live here, kept separate from
/// [ExpenseProvider] so the state-management layer doesn't know anything
/// about Firestore's API — it just consumes a Stream<List<Expense>> and
/// calls plain add/update/delete methods.
class ExpenseService {
  final FirebaseFirestore _firestore;

  ExpenseService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('expenses');

  /// Streams all expenses for [userId], newest first. A single stream
  /// covering the whole history keeps filtering/summing simple and fast
  /// (client-side, on an in-memory list) rather than issuing a new Firestore
  /// query for every filter change.
  Stream<List<Expense>> watchExpenses(String userId) {
    return _collection
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map(Expense.fromFirestore).toList());
  }

  Future<void> addExpense(Expense expense) async {
    await _collection.add(expense.toMap());
  }

  Future<void> updateExpense(Expense expense) async {
    await _collection.doc(expense.id).update(expense.toMap());
  }

  Future<void> deleteExpense(String expenseId) async {
    await _collection.doc(expenseId).delete();
  }
}
