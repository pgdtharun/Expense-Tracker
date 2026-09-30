import 'package:flutter/material.dart';

import '../constants/categories.dart';

/// Search field + horizontally scrolling category chips.
///
/// This is the "filter by category or date" requirement — date filtering
/// is handled by the month selector in [SummaryCard] (prev/next month),
/// while this bar handles the category and free-text filters within that
/// month.
///
/// A local [TextEditingController] (rather than rebuilding one from
/// [searchQuery] on every build) avoids the cursor jumping to the end of
/// the field on each keystroke.
class FilterBar extends StatefulWidget {
  final String searchQuery;
  final ValueChanged<String> onSearchChanged;
  final ExpenseCategory? selectedCategory;
  final ValueChanged<ExpenseCategory?> onCategorySelected;

  const FilterBar({
    super.key,
    required this.searchQuery,
    required this.onSearchChanged,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  State<FilterBar> createState() => _FilterBarState();
}

class _FilterBarState extends State<FilterBar> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.searchQuery);

  @override
  void didUpdateWidget(covariant FilterBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Keep in sync if the query is cleared elsewhere (e.g. "Clear filters").
    if (widget.searchQuery != _controller.text &&
        widget.searchQuery.isEmpty) {
      _controller.clear();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            controller: _controller,
            onChanged: widget.onSearchChanged,
            decoration: InputDecoration(
              hintText: 'Search expenses',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: widget.searchQuery.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _controller.clear();
                        widget.onSearchChanged('');
                      },
                    ),
              isDense: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              ChoiceChip(
                label: const Text('All'),
                selected: widget.selectedCategory == null,
                onSelected: (_) => widget.onCategorySelected(null),
              ),
              const SizedBox(width: 8),
              ...ExpenseCategory.values.map(
                (category) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    avatar: Icon(category.icon, size: 16),
                    label: Text(category.label),
                    selected: widget.selectedCategory == category,
                    onSelected: (_) => widget.onCategorySelected(
                      widget.selectedCategory == category ? null : category,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
