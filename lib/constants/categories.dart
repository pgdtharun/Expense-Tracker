import 'package:flutter/material.dart';

/// A fixed category used to classify an expense.
///
/// Keeping this as a simple enum (rather than free-text strings) means
/// filtering, charting, and validation all get compile-time safety instead
/// of relying on exact string matches.
enum ExpenseCategory {
  food,
  transport,
  shopping,
  bills,
  entertainment,
  health,
  education,
  other,
}

extension ExpenseCategoryX on ExpenseCategory {
  String get label {
    switch (this) {
      case ExpenseCategory.food:
        return 'Food';
      case ExpenseCategory.transport:
        return 'Transport';
      case ExpenseCategory.shopping:
        return 'Shopping';
      case ExpenseCategory.bills:
        return 'Bills';
      case ExpenseCategory.entertainment:
        return 'Entertainment';
      case ExpenseCategory.health:
        return 'Health';
      case ExpenseCategory.education:
        return 'Education';
      case ExpenseCategory.other:
        return 'Other';
    }
  }

  IconData get icon {
    switch (this) {
      case ExpenseCategory.food:
        return Icons.restaurant;
      case ExpenseCategory.transport:
        return Icons.directions_bus;
      case ExpenseCategory.shopping:
        return Icons.shopping_bag;
      case ExpenseCategory.bills:
        return Icons.receipt_long;
      case ExpenseCategory.entertainment:
        return Icons.movie;
      case ExpenseCategory.health:
        return Icons.local_hospital;
      case ExpenseCategory.education:
        return Icons.school;
      case ExpenseCategory.other:
        return Icons.category;
    }
  }

  Color get color {
    switch (this) {
      case ExpenseCategory.food:
        return const Color(0xFFFF7043);
      case ExpenseCategory.transport:
        return const Color(0xFF42A5F5);
      case ExpenseCategory.shopping:
        return const Color(0xFFAB47BC);
      case ExpenseCategory.bills:
        return const Color(0xFFFFCA28);
      case ExpenseCategory.entertainment:
        return const Color(0xFFEC407A);
      case ExpenseCategory.health:
        return const Color(0xFF26A69A);
      case ExpenseCategory.education:
        return const Color(0xFF5C6BC0);
      case ExpenseCategory.other:
        return const Color(0xFF78909C);
    }
  }

  /// The value persisted to Firestore. Kept separate from [label] so the
  /// stored value never breaks if the display text changes later.
  String get storageKey => name;

  static ExpenseCategory fromStorageKey(String key) {
    return ExpenseCategory.values.firstWhere(
      (c) => c.storageKey == key,
      orElse: () => ExpenseCategory.other,
    );
  }
}
