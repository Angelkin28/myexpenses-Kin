import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/expenses_provider.dart';
import '../models/category_model.dart';

class FilterBottomSheet extends StatelessWidget {
  const FilterBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    // We use watch to rebuild UI when filters change
    final provider = context.watch<ExpensesProvider>();

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filters',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () {
                    provider.clearCategoryFilters();
                    provider.setDateRangeFilter(null);
                    Navigator.pop(context);
                  },
                  child: const Text('Reset'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Date Range Picker
            Text('Date Range', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            InkWell(
              onTap: () async {
                final range = await showDateRangePicker(
                  context: context,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                  initialDateRange: provider.dateRange,
                );
                if (range != null) {
                  provider.setDateRangeFilter(range);
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.date_range, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(
                      provider.dateRange == null
                          ? 'Select Date Range'
                          : '${DateFormat.yMMMd().format(provider.dateRange!.start)} - ${DateFormat.yMMMd().format(provider.dateRange!.end)}',
                      style: TextStyle(
                        color: provider.dateRange == null
                            ? Colors.grey
                            : Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Categories Chips
            Text('Categories', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: ExpenseCategory.values.map((category) {
                final isSelected = provider.selectedCategories.contains(
                  category,
                );
                return FilterChip(
                  label: Text(category.name),
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                  selected: isSelected,
                  selectedColor: Theme.of(context).colorScheme.primary,
                  checkmarkColor: Colors.white,
                  avatar: Icon(
                    category.icon,
                    size: 16,
                    color: isSelected ? Colors.white : category.color,
                  ),
                  onSelected: (_) {
                    provider.toggleCategoryFilter(category);
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Apply Filters'),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
