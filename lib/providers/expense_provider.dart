import 'dart:async';

import 'package:flutter/foundation.dart';

import '../constants/categories.dart';
import '../models/expense.dart';
import '../services/expense_service.dart';

enum LoadStatus { loading, loaded, error }

/// The single source of truth for expense data and the current
/// filter/selection state (month, category, search).
///
/// The widget tree never talks to Firestore directly — it reads from here
/// and calls [addExpense]/[updateExpense]/[deleteExpense]. This keeps
/// Firestore concerns out of the UI layer and makes the filtering/summary
/// logic unit-testable independent of widgets.
class ExpenseProvider extends ChangeNotifier {
  final ExpenseService _service;
  final String userId;

  StreamSubscription<List<Expense>>? _subscription;

  List<Expense> _allExpenses = [];
  LoadStatus _status = LoadStatus.loading;
  String? _errorMessage;

  DateTime _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);
  ExpenseCategory? _categoryFilter;
  String _searchQuery = '';

  ExpenseProvider({
    required this.userId,
    ExpenseService? service,
  }) : _service = service ?? ExpenseService() {
    _listen();
  }

  // ---- Read-only state exposed to the UI ----

  LoadStatus get status => _status;
  String? get errorMessage => _errorMessage;
  DateTime get selectedMonth => _selectedMonth;
  ExpenseCategory? get categoryFilter => _categoryFilter;
  String get searchQuery => _searchQuery;
  bool get hasActiveFilters => _categoryFilter != null || _searchQuery.isNotEmpty;

  /// All expenses whose date falls in [_selectedMonth], ignoring the
  /// category/search filters — this is what the monthly total is based on.
  List<Expense> get expensesForSelectedMonth {
    return _allExpenses
        .where((e) =>
            e.date.year == _selectedMonth.year &&
            e.date.month == _selectedMonth.month)
        .toList();
  }

  /// [expensesForSelectedMonth] further narrowed by the category filter and
  /// search query — this is what the list view displays.
  List<Expense> get filteredExpenses {
    return expensesForSelectedMonth.where((e) {
      final matchesCategory =
          _categoryFilter == null || e.category == _categoryFilter;
      final query = _searchQuery.trim().toLowerCase();
      final matchesSearch = query.isEmpty ||
          e.title.toLowerCase().contains(query) ||
          (e.note?.toLowerCase().contains(query) ?? false);
      return matchesCategory && matchesSearch;
    }).toList();
  }

  double get monthlyTotal =>
      expensesForSelectedMonth.fold(0.0, (sum, e) => sum + e.amount);

  /// Category → total spend for the selected month, used to feed the pie
  /// chart. Categories with zero spend are omitted.
  Map<ExpenseCategory, double> get categoryTotals {
    final totals = <ExpenseCategory, double>{};
    for (final expense in expensesForSelectedMonth) {
      totals.update(
        expense.category,
        (value) => value + expense.amount,
        ifAbsent: () => expense.amount,
      );
    }
    return totals;
  }

  // ---- Firestore subscription ----

  void _listen() {
    _status = LoadStatus.loading;
    _subscription?.cancel();
    _subscription = _service.watchExpenses(userId).listen(
      (expenses) {
        _allExpenses = expenses;
        _status = LoadStatus.loaded;
        _errorMessage = null;
        notifyListeners();
      },
      onError: (Object error) {
        _status = LoadStatus.error;
        _errorMessage = 'Could not load expenses. Please check your '
            'connection and try again.';
        notifyListeners();
        if (kDebugMode) {
          // Keep the real error visible during development without
          // exposing internals in the UI.
          debugPrint('ExpenseProvider stream error: $error');
        }
      },
    );
  }

  /// Re-subscribes after a failed load (used by the error state's retry
  /// button).
  void retry() => _listen();

  // ---- Mutations ----

  Future<void> addExpense({
    required String title,
    required double amount,
    required ExpenseCategory category,
    required DateTime date,
    String? note,
  }) async {
    final expense = Expense(
      id: '', // ignored by ExpenseService.addExpense
      title: title.trim(),
      amount: amount,
      category: category,
      date: date,
      note: (note == null || note.trim().isEmpty) ? null : note.trim(),
      userId: userId,
      createdAt: DateTime.now(),
    );
    await _service.addExpense(expense);
  }

  Future<void> updateExpense(Expense original, {
    required String title,
    required double amount,
    required ExpenseCategory category,
    required DateTime date,
    String? note,
  }) async {
    final updated = original.copyWith(
      title: title.trim(),
      amount: amount,
      category: category,
      date: date,
      note: (note == null || note.trim().isEmpty) ? null : note.trim(),
    );
    await _service.updateExpense(updated);
  }

  Future<void> deleteExpense(String expenseId) async {
    await _service.deleteExpense(expenseId);
  }

  // ---- Filters ----

  void goToPreviousMonth() {
    _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1);
    notifyListeners();
  }

  void goToNextMonth() {
    _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1);
    notifyListeners();
  }

  void goToCurrentMonth() {
    final now = DateTime.now();
    _selectedMonth = DateTime(now.year, now.month);
    notifyListeners();
  }

  void setCategoryFilter(ExpenseCategory? category) {
    _categoryFilter = category;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void clearFilters() {
    _categoryFilter = null;
    _searchQuery = '';
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
