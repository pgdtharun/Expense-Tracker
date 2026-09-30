import 'package:flutter/material.dart';

import '../utils/formatters.dart';

/// The header card showing the selected month, its total, and prev/next
/// navigation. Kept as a dumb widget — all it needs is passed in, so it has
/// no dependency on ExpenseProvider directly and stays easy to preview/test.
class SummaryCard extends StatelessWidget {
  final DateTime selectedMonth;
  final double total;
  final int expenseCount;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;
  final bool isCurrentMonth;
  final VoidCallback onJumpToCurrentMonth;

  const SummaryCard({
    super.key,
    required this.selectedMonth,
    required this.total,
    required this.expenseCount,
    required this.onPreviousMonth,
    required this.onNextMonth,
    required this.isCurrentMonth,
    required this.onJumpToCurrentMonth,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: onPreviousMonth,
                  icon: const Icon(Icons.chevron_left),
                  tooltip: 'Previous month',
                ),
                GestureDetector(
                  onTap: isCurrentMonth ? null : onJumpToCurrentMonth,
                  child: Column(
                    children: [
                      Text(
                        Formatters.monthYear(selectedMonth),
                        style: theme.textTheme.titleMedium,
                      ),
                      if (!isCurrentMonth)
                        Text(
                          'Tap to jump to this month',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.primary,
                          ),
                        ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: onNextMonth,
                  icon: const Icon(Icons.chevron_right),
                  tooltip: 'Next month',
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              Formatters.currency(total),
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              expenseCount == 1 ? '1 expense' : '$expenseCount expenses',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
