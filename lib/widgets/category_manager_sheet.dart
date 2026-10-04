import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/expense_provider.dart';
import 'add_category_dialog.dart';

class CategoryManagerSheet extends StatelessWidget {
  const CategoryManagerSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const CategoryManagerSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ExpenseProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Category Management',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Customize categories & budgets',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () {
                  AddCategoryDialog.show(
                    context,
                    onSave: (cat) => provider.addCategory(cat),
                  );
                },
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('New'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.separated(
              itemCount: provider.categories.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final category = provider.categories[index];
                final spent = provider.getCategoryTotal(category.id);
                final budget = category.budgetLimit;

                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: category.color.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(category.icon, color: category.color, size: 22),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  category.name,
                                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                                ),
                                if (category.isCustom) ...[
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF10B981).withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Text(
                                      'Custom',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF10B981),
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              budget != null
                                  ? 'Spent: ${currencyFormat.format(spent)} / ${currencyFormat.format(budget)}'
                                  : 'Spent: ${currencyFormat.format(spent)}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (category.isCustom)
                        IconButton(
                          icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFEF4444), size: 20),
                          onPressed: () {
                            provider.deleteCategory(category.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Removed category "${category.name}"')),
                            );
                          },
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
