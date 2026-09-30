import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/expense.dart';
import '../providers/expense_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/expense_chart.dart';
import '../widgets/expense_list_item.dart';
import '../widgets/filter_bar.dart';
import '../widgets/state_widgets.dart';
import '../widgets/summary_card.dart';
import 'add_edit_expense_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Tracker'),
        actions: [
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, _) => IconButton(
              onPressed: themeProvider.toggleTheme,
              icon: Icon(
                themeProvider.isDarkMode
                    ? Icons.light_mode_outlined
                    : Icons.dark_mode_outlined,
              ),
              tooltip: 'Toggle theme',
            ),
          ),
        ],
      ),
      body: Consumer<ExpenseProvider>(
        builder: (context, provider, _) {
          return switch (provider.status) {
            LoadStatus.loading => const LoadingView(),
            LoadStatus.error => ErrorView(
                message: provider.errorMessage ?? 'Something went wrong.',
                onRetry: provider.retry,
              ),
            LoadStatus.loaded => _HomeContent(provider: provider),
          };
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const AddEditExpenseScreen()),
        ),
        tooltip: 'Add expense',
        child: const Icon(Icons.add),
      ),
    );
  }
}

/// Split out from [HomeScreen] so the loaded state's layout stays readable
/// and can rebuild independently once data's in.
class _HomeContent extends StatelessWidget {
  final ExpenseProvider provider;

  const _HomeContent({required this.provider});

  bool get _isCurrentMonth {
    final now = DateTime.now();
    return provider.selectedMonth.year == now.year &&
        provider.selectedMonth.month == now.month;
  }

  @override
  Widget build(BuildContext context) {
    final monthExpenses = provider.expensesForSelectedMonth;
    final filtered = provider.filteredExpenses;

    return RefreshIndicator(
      onRefresh: () async => provider.retry(),
      child: ListView(
        children: [
          SummaryCard(
            selectedMonth: provider.selectedMonth,
            total: provider.monthlyTotal,
            expenseCount: monthExpenses.length,
            onPreviousMonth: provider.goToPreviousMonth,
            onNextMonth: provider.goToNextMonth,
            isCurrentMonth: _isCurrentMonth,
            onJumpToCurrentMonth: provider.goToCurrentMonth,
          ),
          if (monthExpenses.isNotEmpty)
            ExpenseChart(categoryTotals: provider.categoryTotals),
          const SizedBox(height: 4),
          FilterBar(
            searchQuery: provider.searchQuery,
            onSearchChanged: provider.setSearchQuery,
            selectedCategory: provider.categoryFilter,
            onCategorySelected: provider.setCategoryFilter,
          ),
          const SizedBox(height: 8),
          _ExpenseHistorySection(
            monthExpenses: monthExpenses,
            filtered: filtered,
            hasActiveFilters: provider.hasActiveFilters,
            onClearFilters: provider.clearFilters,
          ),
        ],
      ),
    );
  }
}

class _ExpenseHistorySection extends StatelessWidget {
  final List<Expense> monthExpenses;
  final List<Expense> filtered;
  final bool hasActiveFilters;
  final VoidCallback onClearFilters;

  const _ExpenseHistorySection({
    required this.monthExpenses,
    required this.filtered,
    required this.hasActiveFilters,
    required this.onClearFilters,
  });

  @override
  Widget build(BuildContext context) {
    if (monthExpenses.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(top: 24),
        child: EmptyView(),
      );
    }

    if (filtered.isEmpty) {
        return const Padding(
          padding: EdgeInsets.only(top: 24),
        child: EmptyView(
          icon: Icons.filter_alt_off_outlined,
          title: 'No matching expenses',
          message: 'Try a different search term or category.',
        ),
      );
    }

    return Column(
      children: [
        if (hasActiveFilters)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                Text(
                  '${filtered.length} of ${monthExpenses.length} shown',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const Spacer(),
                TextButton(
                  onPressed: onClearFilters,
                  child: const Text('Clear filters'),
                ),
              ],
            ),
          ),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: filtered.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final expense = filtered[index];
            return Dismissible(
              key: ValueKey(expense.id),
              direction: DismissDirection.endToStart,
              confirmDismiss: (_) => showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Delete expense?'),
                  content: Text('This will permanently delete "${expense.title}".'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              ),
              onDismissed: (_) => context.read<ExpenseProvider>().deleteExpense(expense.id),
              background: Container(
                color: Theme.of(context).colorScheme.error,
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              child: ExpenseListItem(
                expense: expense,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => AddEditExpenseScreen(existingExpense: expense),
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 80), // clears the FAB
      ],
    );
  }
}
