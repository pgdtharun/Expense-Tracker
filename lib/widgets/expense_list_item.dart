import 'package:flutter/material.dart';

import '../constants/categories.dart';
import '../models/expense.dart';
import '../utils/formatters.dart';

/// A single row in the expense history list. Wrapped in [Dismissible] by
/// the caller for swipe-to-delete, so this widget itself stays focused on
/// layout only.
class ExpenseListItem extends StatelessWidget {
  final Expense expense;
  final VoidCallback onTap;

  const ExpenseListItem({
    super.key,
    required this.expense,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final category = expense.category;

    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: category.color.withValues(alpha: 0.15),
        foregroundColor: category.color,
        child: Icon(category.icon, size: 20),
      ),
      title: Text(
        expense.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.bodyLarge,
      ),
      subtitle: Text(
        '${category.label} · ${Formatters.listDate(expense.date)}'
        '${expense.note != null ? ' · ${expense.note}' : ''}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Text(
        Formatters.currency(expense.amount),
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
