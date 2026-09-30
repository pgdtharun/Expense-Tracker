import 'package:cloud_firestore/cloud_firestore.dart';

import '../constants/categories.dart';

/// A single expense record.
///
/// Firestore stores [date] as a [Timestamp] and [amount] as a num, so
/// [fromFirestore]/[toMap] handle the conversion to/from the Dart types the
/// rest of the app works with.
class Expense {
  final String id;
  final String title;
  final double amount;
  final ExpenseCategory category;
  final DateTime date;
  final String? note;
  final String userId;
  final DateTime createdAt;

  const Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    required this.userId,
    required this.createdAt,
    this.note,
  });

  /// Builds an [Expense] from a Firestore document snapshot.
  factory Expense.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    if (data == null) {
      throw StateError('Expense document ${doc.id} has no data.');
    }
    return Expense(
      id: doc.id,
      title: data['title'] as String? ?? '',
      amount: (data['amount'] as num?)?.toDouble() ?? 0.0,
      category: ExpenseCategoryX.fromStorageKey(
        data['category'] as String? ?? ExpenseCategory.other.storageKey,
      ),
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      note: data['note'] as String?,
      userId: data['userId'] as String? ?? '',
      createdAt:
          (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Converts this expense into a map suitable for `Firestore.set()`.
  /// [id] is intentionally excluded — Firestore manages the document id.
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'amount': amount,
      'category': category.storageKey,
      'date': Timestamp.fromDate(date),
      'note': note,
      'userId': userId,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  /// Sentinel used so [copyWith] can tell "note not passed" (keep the
  /// existing value) apart from "note explicitly passed as null" (clear
  /// it) — a plain `note ?? this.note` can't distinguish those two cases
  /// and would silently keep a note the caller meant to clear.
  static const Object _unset = Object();

  Expense copyWith({
    String? title,
    double? amount,
    ExpenseCategory? category,
    DateTime? date,
    Object? note = _unset,
  }) {
    return Expense(
      id: id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      date: date ?? this.date,
      note: identical(note, _unset) ? this.note : note as String?,
      userId: userId,
      createdAt: createdAt,
    );
  }
}
